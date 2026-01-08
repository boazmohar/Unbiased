"""
Per-file debug helper to compare Python vs MATLAB region coverage.

Usage:
  python single_file_region_debug.py \
    --file "Slide 1 of 1-Region 001.png" \
    --base /groups/spruston/home/moharb/Data/GluA2_round1_try1 \
    --hemi /groups/spruston/home/moharb/Data/GluA2_round1_try1/hemi_polygons.json

Outputs a text report (and CSV of the merged counts) in the current folder.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd
from skimage.draw import polygon2mask

from glua2_labels import load_label_table, map_png_to_labels
from glua2_processing import (
    _load_hemi_polygons,
    _read_image,
    _read_tiff,
    _resize_nearest,
    process_file,
)
from glua2_metadata import load_metadata


def _ccf_from_label_image(label_image: np.ndarray, label_meta: List[Dict[str, object]]) -> np.ndarray:
    """Convert label_image indices -> CCF IDs using label_meta from map_png_to_labels."""

    lookup = np.zeros(len(label_meta) + 1, dtype=np.int32)
    for idx, meta in enumerate(label_meta):
        lookup[idx + 1] = int(meta.get("ccf_id", 0))
    return lookup[label_image]


def _summarize_ids(arr: np.ndarray, id_to_name: Dict[int, str]) -> List[Tuple[int, str, int]]:
    ids, counts = np.unique(arr, return_counts=True)
    out: List[Tuple[int, str, int]] = []
    for i, c in zip(ids, counts):
        if i == 0:
            continue
        out.append((int(i), id_to_name.get(int(i), "unknown"), int(c)))
    out.sort(key=lambda x: -x[2])
    return out


def debug_single_file(
    file_name: str,
    base_dir: Path,
    hemi_path: Path,
    label_table_path: Path,
    metadata_path: Path,
    matlab_parquet: Path,
    output_dir: Path,
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)

    stem = Path(file_name).stem
    file_path = base_dir / file_name
    png_path = base_dir / f"{stem}_nl.png"
    mask_path = base_dir / f"{stem}_Probabilities.tif"
    pulse_path = base_dir / f"{stem}_CY5.tiff"
    chase_path = base_dir / f"{stem}_CY3.tiff"

    if not png_path.exists():
        raise FileNotFoundError(f"PNG not found: {png_path}")
    if not mask_path.exists():
        raise FileNotFoundError(f"Mask not found: {mask_path}")

    png = _read_image(png_path)
    mask = _read_tiff(mask_path)
    # Match MATLAB style: keep mask values >= 128
    bin_mask = (mask >= 128).astype(np.uint8)

    if not pulse_path.exists() or not chase_path.exists():
        pulse_path = base_dir / f"{stem}-CY5.tiff"
        chase_path = base_dir / f"{stem}-CY3.tiff"
    raw_pulse = _read_tiff(pulse_path)
    raw_chase = _read_tiff(chase_path)

    label_table = load_label_table(label_table_path)
    id_to_name = {int(row["ID"]): str(row["Name"]) for _, row in label_table.iterrows()}

    # Map labels from the atlas PNG; match MATLAB order: label->mask space->raw space.
    label_image, label_meta = map_png_to_labels(png, label_table)
    if label_image.shape[:2] != mask.shape[:2]:
        label_image = _resize_nearest(label_image, mask.shape[:2])
    label_raw = _resize_nearest(label_image, raw_pulse.shape)
    bin_mask_raw = _resize_nearest(bin_mask, raw_pulse.shape).astype(bool)

    ccf_raw = _ccf_from_label_image(label_raw, label_meta)
    ccf_masked = ccf_raw[bin_mask_raw]

    hemi_polygons = _load_hemi_polygons(hemi_path)
    hemi_entry = hemi_polygons.get(file_name, {})
    hemi_masks: Dict[str, np.ndarray] = {}
    if hemi_entry.get("right") is not None and hemi_entry.get("left") is not None:
        right_poly = np.round(np.column_stack((hemi_entry["right"][:, 1], hemi_entry["right"][:, 0])))
        left_poly = np.round(np.column_stack((hemi_entry["left"][:, 1], hemi_entry["left"][:, 0])))
        right_mask = polygon2mask(bin_mask.shape, right_poly)
        left_mask = polygon2mask(bin_mask.shape, left_poly)
        hemi_masks["right"] = _resize_nearest(right_mask.astype(np.uint8), raw_pulse.shape).astype(bool)
        hemi_masks["left"] = _resize_nearest(left_mask.astype(np.uint8), raw_pulse.shape).astype(bool)

    hemi_counts: Dict[str, List[Tuple[int, str, int]]] = {}
    for hemi_name, hm in hemi_masks.items():
        hemi_counts[hemi_name] = _summarize_ids(ccf_raw[hm & bin_mask_raw], id_to_name)

    # Python pipeline output grouped by CCF_ID/Hemi.
    metadata = load_metadata(metadata_path)
    py_df = process_file(
        file_path,
        base_dir,
        base_dir,
        1,
        label_table,
        metadata,
        apply_calib=1,
        hemi_mat=hemi_path,
    )
    py_group = (
        py_df.groupby(["CCF_ID", "Hemi"], dropna=False)[["N", "P_Mean", "C_Mean"]]
        .sum()
        .reset_index()
    )

    # MATLAB parquet subset for the same file.
    if matlab_parquet.exists():
        mat_df = pd.read_parquet(matlab_parquet)
        mat_file = mat_df[mat_df["File"] == file_name]
        mat_group = (
            mat_file.groupby(["CCF_ID", "Hemi"], dropna=False)[["N", "P_Mean", "C_Mean"]]
            .sum()
            .reset_index()
        )
    else:
        mat_group = pd.DataFrame()

    merged = pd.merge(
        py_group,
        mat_group,
        on=["CCF_ID", "Hemi"],
        how="outer",
        suffixes=("_py", "_mat"),
    )
    merged.fillna(0, inplace=True)
    merged["N_diff"] = merged["N_py"] - merged["N_mat"]
    merged["P_diff"] = merged["P_Mean_py"] - merged["P_Mean_mat"]
    merged["C_diff"] = merged["C_Mean_py"] - merged["C_Mean_mat"]

    report_path = output_dir / f"{stem}_debug_report.txt"
    csv_path = output_dir / f"{stem}_debug_merge.csv"

    with report_path.open("w") as f:
        f.write(f"File: {file_name}\n")
        f.write(f"PNG shape: {png.shape}, mask shape: {mask.shape}, raw shape: {raw_pulse.shape}\n")
        f.write(f"Mask sum (raw space): {int(bin_mask_raw.sum())}\n")
        if hemi_masks:
            f.write(
                "Hemi mask sums: "
                + ", ".join(f"{k}={int(v.sum())}" for k, v in hemi_masks.items())
                + "\n"
            )
        f.write("\nTop labels in label_raw (all pixels):\n")
        for cid, name, count in _summarize_ids(ccf_raw, id_to_name)[:20]:
            f.write(f"{cid:6d} | {name} | {count}\n")
        f.write("\nTop labels after probability mask:\n")
        for cid, name, count in _summarize_ids(ccf_masked, id_to_name)[:20]:
            f.write(f"{cid:6d} | {name} | {count}\n")
        for hemi_name, entries in hemi_counts.items():
            f.write(f"\nTop labels in hemi '{hemi_name}' (after prob mask):\n")
            for cid, name, count in entries[:20]:
                f.write(f"{cid:6d} | {name} | {count}\n")

        f.write("\nPython grouped stats (CCF_ID, Hemi -> N, P_Mean, C_Mean):\n")
        f.write(py_group.to_string(index=False))
        if not mat_group.empty:
            f.write("\n\nMATLAB grouped stats:\n")
            f.write(mat_group.to_string(index=False))
            f.write("\n\nMerged diffs (N_diff = py - mat):\n")
            f.write(merged.to_string(index=False))

    merged.to_csv(csv_path, index=False)

    print(f"Wrote report to {report_path}")
    print(f"Wrote merged CSV to {csv_path}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", required=True, help="PNG filename, e.g. 'Slide 1 of 1-Region 001.png'")
    ap.add_argument("--base", required=True, type=Path, help="Base data directory")
    ap.add_argument("--hemi", required=True, type=Path, help="Path to hemi_polygons.json or hemi.mat")
    ap.add_argument("--label-table", type=Path, default=Path("/groups/spruston/home/moharb/Data/GluA2_round1_try1/LabelTables.csv"))
    ap.add_argument("--metadata", type=Path, default=Path("/groups/spruston/home/moharb/Data/metadata_glua2.csv"))
    ap.add_argument("--matlab-parquet", type=Path, default=Path("/groups/spruston/home/moharb/Data/GluA2_round_1.parquet"))
    ap.add_argument("--output-dir", type=Path, default=Path("."), help="Where to write the report/CSV")
    args = ap.parse_args()

    debug_single_file(
        args.file,
        args.base,
        args.hemi,
        args.label_table,
        args.metadata,
        args.matlab_parquet,
        args.output_dir,
    )


if __name__ == "__main__":
    main()
