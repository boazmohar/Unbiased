"""
Debug helpers to visualize mask/label/hemi alignment and centroids for a single file.

Outputs written to the current working directory by default:
- <file>_labels_raw.png: label indices (resized to raw) as a color map.
- <file>_mask_raw.png: probability mask (binary) resized to raw.
- <file>_hemi_right_raw.png / _hemi_left_raw.png: hemi masks resized to raw.
- <file>_labels_masked.png: labels intersected with mask.
- <file>_labels_hemi_right.png / _labels_hemi_left.png: labels intersected with hemi masks.
- Prints centroids and pixel counts for a target region (default: Main olfactory bulb) for each hemi.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict

import matplotlib.pyplot as plt
import numpy as np
import tifffile as tiff
from PIL import Image
from skimage.draw import polygon2mask

from glua2_labels import load_label_table, map_png_to_labels
from glua2_processing import _resize_nearest


def load_hemi_polygons(hemi_path: Path) -> Dict[str, Dict[str, np.ndarray]]:
    data = json.loads(hemi_path.read_text())
    norm: Dict[str, Dict[str, np.ndarray]] = {}
    for k, v in data.items():
        key = k.replace("\\\\", "/").replace("\\", "/")
        base = Path(key).name
        right = np.asarray(v.get("right"), dtype=float)
        left = np.asarray(v.get("left"), dtype=float)
        norm[base] = {"right": right, "left": left}
    return norm


def save_image(arr: np.ndarray, path: Path, cmap: str = "viridis") -> None:
    plt.figure(figsize=(6, 6))
    plt.imshow(arr, cmap=cmap)
    plt.axis("off")
    plt.tight_layout()
    path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(path, dpi=150)
    plt.close()
    print(f"Wrote {path}")


def debug_one(file_name: str, base_dir: Path, hemi_json: Path, label_table_path: Path, output_dir: Path) -> None:
    base = Path(base_dir)
    out = Path(output_dir)
    # Prefer atlas _nl.png; fall back to plain .png if missing.
    png_base = base / file_name
    png_path = base / f"{png_base.stem}_nl.png"
    if not png_path.exists():
        png_path = png_base
    mask_path = base / f"{png_base.stem}_Probabilities.tif"
    cy5_path = base / f"{png_base.stem}_CY5.tiff"
    label_table = load_label_table(label_table_path)

    png = np.array(Image.open(png_path))
    mask = np.array(tiff.imread(mask_path, key=0))
    raw = np.array(tiff.imread(cy5_path, key=0))
    bin_mask = (mask > 128).astype(np.uint8)

    # Labels: PNG -> label indices -> resize to raw
    label_image, label_meta = map_png_to_labels(png, label_table)
    label_raw = _resize_nearest(label_image, raw.shape)

    # Mask to raw
    mask_raw = _resize_nearest(bin_mask, raw.shape)

    # Hemi masks
    hemi_polys = load_hemi_polygons(hemi_json)
    hemi = hemi_polys.get(file_name)
    hemi_masks = {}
    if hemi:
        right_poly = np.column_stack((hemi["right"][:, 1], hemi["right"][:, 0]))
        left_poly = np.column_stack((hemi["left"][:, 1], hemi["left"][:, 0]))
        right_mask = polygon2mask(mask.shape, right_poly)
        left_mask = polygon2mask(mask.shape, left_poly)
        right_mask = _resize_nearest(right_mask.astype(np.uint8), raw.shape).astype(bool)
        left_mask = _resize_nearest(left_mask.astype(np.uint8), raw.shape).astype(bool)
        hemi_masks = {"right": right_mask, "left": left_mask}

    # Save visuals
    save_image(label_raw, out / f"{png_path.stem}_labels_raw.png", cmap="tab20")
    save_image(mask_raw, out / f"{png_path.stem}_mask_raw.png", cmap="gray")
    if hemi_masks:
        save_image(hemi_masks["right"], out / f"{png_path.stem}_hemi_right_raw.png", cmap="gray")
        save_image(hemi_masks["left"], out / f"{png_path.stem}_hemi_left_raw.png", cmap="gray")
    labels_masked = label_raw * (mask_raw > 0)
    save_image(labels_masked, out / f"{png_path.stem}_labels_masked.png", cmap="tab20")
    if hemi_masks:
        save_image(labels_masked * hemi_masks["right"], out / f"{png_path.stem}_labels_hemi_right.png", cmap="tab20")
        save_image(labels_masked * hemi_masks["left"], out / f"{png_path.stem}_labels_hemi_left.png", cmap="tab20")

    # Centroid debug for main olfactory bulb
    id_to_name = {int(row["ID"]): row["Name"] for _, row in label_table.iterrows()}
    target_id = next((k for k, v in id_to_name.items() if "Main olfactory bulb" in v), None)
    if target_id is not None:
        region_raw = label_raw == target_id
        region_masked = region_raw & (mask_raw > 0)
        def centroid(mask: np.ndarray) -> tuple[float, float]:
            idx = np.argwhere(mask)
            return (float(idx[:, 0].mean()), float(idx[:, 1].mean())) if idx.size > 0 else (np.nan, np.nan)
        print(f"Target ID {target_id} ({id_to_name[target_id]})")
        print("  region_raw pixels", int(region_raw.sum()), "centroid", centroid(region_raw))
        print("  region_masked pixels", int(region_masked.sum()), "centroid", centroid(region_masked))
        if hemi_masks:
            for side, hm in hemi_masks.items():
                r = region_masked & hm
                print(f"  {side}: pixels {int(r.sum())}, centroid {centroid(r)}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", required=True, help="PNG filename (e.g., 'Slide 1 of 1-Region 001.png')")
    ap.add_argument("--base", required=True, type=Path, help="Input base directory with files")
    ap.add_argument("--hemi", required=True, type=Path, help="hemi_polygons.json")
    ap.add_argument("--label-table", required=True, type=Path, help="LabelTables.csv path")
    ap.add_argument("--output-dir", required=False, type=Path, default=Path("."), help="Where to write debug images")
    args = ap.parse_args()
    debug_one(args.file, args.base, args.hemi, args.label_table, args.output_dir)


if __name__ == "__main__":
    main()
