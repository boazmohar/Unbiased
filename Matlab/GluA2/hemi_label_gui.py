"""
GUI helper to draw right/left hemisphere polygons on PNG images.

Usage:
  python hemi_label_gui.py --image-dir /path/to/pngs --output hemi_polygons.json

Keys:
  r / l : set active side (right/left)
  n / p : next/previous image (or arrow keys)
  c     : clear polygon for active side
  s     : save JSON
  q     : quit
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MplPolygon
from matplotlib.widgets import PolygonSelector


def _normalize_poly(poly: object) -> Optional[List[List[float]]]:
    if poly is None:
        return None
    arr = np.asarray(poly, dtype=float)
    if arr.ndim != 2 or arr.shape[1] != 2:
        return None
    return arr.tolist()


def _load_existing(path: Optional[Path]) -> Dict[str, Dict[str, Optional[List[List[float]]]]]:
    if path is None or not path.exists():
        return {}
    data = json.loads(path.read_text())
    normalized: Dict[str, Dict[str, Optional[List[List[float]]]]] = {}
    for key, entry in data.items():
        base = str(key).replace("\\", "/").split("/")[-1]
        right = _normalize_poly(entry.get("right") if isinstance(entry, dict) else None)
        left = _normalize_poly(entry.get("left") if isinstance(entry, dict) else None)
        normalized[base] = {"right": right, "left": left}
    return normalized


class HemiLabelGUI:
    def __init__(
        self,
        image_paths: List[Path],
        output_path: Path,
        existing: Dict[str, Dict[str, Optional[List[List[float]]]]],
    ) -> None:
        if not image_paths:
            raise ValueError("No images found to label.")
        self.image_paths = image_paths
        self.output_path = output_path
        self.current_idx = 0
        self.current_side = "right"
        self.polygons: Dict[str, Dict[str, Optional[List[List[float]]]]] = {
            p.name: {"right": None, "left": None} for p in image_paths
        }
        for name, entry in existing.items():
            if name in self.polygons:
                self.polygons[name] = {
                    "right": _normalize_poly(entry.get("right")),
                    "left": _normalize_poly(entry.get("left")),
                }
        self.extra_entries = {name: entry for name, entry in existing.items() if name not in self.polygons}

        self.fig, self.ax = plt.subplots()
        self.ax.set_axis_off()
        self.image_artist = self.ax.imshow(self._read_image(self.image_paths[0]), origin="upper")
        self.right_patch = MplPolygon(
            np.zeros((0, 2)),
            closed=True,
            fill=True,
            facecolor="#e45756",
            edgecolor="#e45756",
            alpha=0.25,
            linewidth=2,
            visible=False,
        )
        self.left_patch = MplPolygon(
            np.zeros((0, 2)),
            closed=True,
            fill=True,
            facecolor="#4c78a8",
            edgecolor="#4c78a8",
            alpha=0.25,
            linewidth=2,
            visible=False,
        )
        self.ax.add_patch(self.right_patch)
        self.ax.add_patch(self.left_patch)
        self.selector = PolygonSelector(self.ax, self._on_select, useblit=True)
        self.fig.canvas.mpl_connect("key_press_event", self._on_key)
        self._status_text = self.fig.text(
            0.01,
            0.01,
            "",
            fontsize=9,
            ha="left",
            va="bottom",
        )
        self._update_view()

    def _read_image(self, path: Path) -> np.ndarray:
        return plt.imread(path)

    def _current_name(self) -> str:
        return self.image_paths[self.current_idx].name

    def _current_entry(self) -> Dict[str, Optional[List[List[float]]]]:
        return self.polygons[self._current_name()]

    def _update_view(self) -> None:
        path = self.image_paths[self.current_idx]
        img = self._read_image(path)
        self.image_artist.set_data(img)
        height, width = img.shape[0], img.shape[1]
        self.ax.set_xlim(0, width)
        self.ax.set_ylim(height, 0)
        entry = self._current_entry()
        self._update_patch(self.right_patch, entry.get("right"))
        self._update_patch(self.left_patch, entry.get("left"))
        self._update_title()
        self.fig.canvas.draw_idle()

    def _update_patch(self, patch: MplPolygon, verts: Optional[List[List[float]]]) -> None:
        if verts is None or len(verts) < 3:
            patch.set_visible(False)
            patch.set_xy(np.zeros((0, 2)))
            return
        patch.set_visible(True)
        patch.set_xy(np.asarray(verts, dtype=float))

    def _update_title(self) -> None:
        name = self._current_name()
        entry = self._current_entry()
        r_ok = "yes" if entry.get("right") else "no"
        l_ok = "yes" if entry.get("left") else "no"
        title = f"{name} [{self.current_idx + 1}/{len(self.image_paths)}] side={self.current_side}"
        status = f"right={r_ok} left={l_ok}"
        self.ax.set_title(title)
        self._status_text.set_text(
            "r/l: select side | n/p: next/prev | c: clear | s: save | q: quit"
            f"\n{status}"
        )

    def _on_select(self, verts: List[List[float]]) -> None:
        if len(verts) < 3:
            return
        entry = self._current_entry()
        entry[self.current_side] = [[float(x), float(y)] for x, y in verts]
        if self.current_side == "right":
            self._update_patch(self.right_patch, entry[self.current_side])
        else:
            self._update_patch(self.left_patch, entry[self.current_side])
        self._update_title()
        self.fig.canvas.draw_idle()

    def _on_key(self, event) -> None:  # type: ignore[override]
        if event.key in {"r", "l"}:
            self.current_side = "right" if event.key == "r" else "left"
            self._update_title()
            self.fig.canvas.draw_idle()
            return
        if event.key in {"n", "right"}:
            self._next_image()
            return
        if event.key in {"p", "left"}:
            self._prev_image()
            return
        if event.key == "c":
            entry = self._current_entry()
            entry[self.current_side] = None
            if self.current_side == "right":
                self._update_patch(self.right_patch, None)
            else:
                self._update_patch(self.left_patch, None)
            self._update_title()
            self.fig.canvas.draw_idle()
            return
        if event.key == "s":
            self.save()
            return
        if event.key == "q":
            self.save()
            plt.close(self.fig)

    def _next_image(self) -> None:
        if self.current_idx < len(self.image_paths) - 1:
            self.current_idx += 1
            self._update_view()

    def _prev_image(self) -> None:
        if self.current_idx > 0:
            self.current_idx -= 1
            self._update_view()

    def save(self) -> None:
        data = dict(self.extra_entries)
        data.update(self.polygons)
        self.output_path.parent.mkdir(parents=True, exist_ok=True)
        self.output_path.write_text(json.dumps(data, indent=2))
        print(f"Wrote {self.output_path} with {len(data)} entries.")


def _collect_images(image_dir: Path, pattern: str, exclude: List[str]) -> List[Path]:
    files = sorted(image_dir.glob(pattern))
    if exclude:
        files = [p for p in files if not any(ex in p.name for ex in exclude)]
    return files


def main() -> None:
    ap = argparse.ArgumentParser(description="Draw hemi polygons for PNG images.")
    ap.add_argument("--image-dir", required=True, type=Path, help="Directory of PNG images")
    ap.add_argument(
        "--output",
        type=Path,
        default=Path("hemi_polygons.json"),
        help="Output JSON path",
    )
    ap.add_argument(
        "--existing",
        type=Path,
        default=None,
        help="Optional existing hemi_polygons.json to resume",
    )
    ap.add_argument("--pattern", type=str, default="*.png", help="Glob for images")
    ap.add_argument(
        "--exclude",
        nargs="*",
        default=[],
        help="Substrings to skip (e.g. _mask _hemi _labels)",
    )
    args = ap.parse_args()

    image_paths = _collect_images(args.image_dir, args.pattern, args.exclude)
    if not image_paths:
        raise SystemExit(f"No images found in {args.image_dir} with pattern {args.pattern}")

    existing_path = args.existing
    if existing_path is None and args.output.exists():
        existing_path = args.output
    existing = _load_existing(existing_path)

    gui = HemiLabelGUI(image_paths, args.output, existing)
    plt.show()


if __name__ == "__main__":
    main()
