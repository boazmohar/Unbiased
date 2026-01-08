"""
Walkthrough of the per-file steps (Python port) for inspection/debugging.

This mirrors the MATLAB order for a single file:
- Load atlas PNG (RGB labels), probabilities mask, raw CY5/CY3.
- Map PNG colors to label indices.
- Resize labels once to raw image size (mask and PNG are already same size).
- Build hemisphere masks from hemi_polygons.json.
- Apply probability mask and hemi masks to compute region pixel counts.

Run:
  python pipeline_inspect_example.py --file "Slide 1 of 1-Region 001.png" \\
    --base /groups/spruston/home/moharb/Data/GluA2_round1_try1 \\
    --hemi /groups/spruston/home/moharb/Data/GluA2_round1_try1/hemi_polygons.json
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict

import numpy as np
import pandas as pd
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


def inspect_file(
    file_name: str,
    input_dir: Path,
    hemi_json: Path,
    label_table_path: Path | None = None,
    metadata_path: Path | None = None,
    output_dir: Path | None = None,
) -> None:
    in_dir = Path(input_dir)
    out_dir = Path(output_dir) if output_dir else in_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    png_path = in_dir / file_name
    mask_path = in_dir / f"{png_path.stem}_Probabilities.tif"
    cy5_path = in_dir / f"{png_path.stem}_CY5.tiff"
    cy3_path = in_dir / f"{png_path.stem}_CY3.tiff"
    lt_path = label_table_path or in_dir / "LabelTables.csv"
    label_table = load_label_table(lt_path)

    png = np.array(Image.open(png_path))
    mask = np.array(tiff.imread(mask_path, key=0))
    raw_pulse = np.array(tiff.imread(cy5_path, key=0))
    raw_chase = np.array(tiff.imread(cy3_path, key=0))
    bin_mask = (mask >= 128).astype(np.uint16)

    # Map labels from PNG, then resize once to raw image size.
    label_image, label_meta = map_png_to_labels(png, label_table)
    label_raw = _resize_nearest(label_image, raw_pulse.shape)

    # Resize probability mask to raw image size.
    bin_mask_raw = _resize_nearest(bin_mask, raw_pulse.shape)

    # Apply probability mask (zeros -> nan to match MATLAB handling).
    pulse_masked = np.where(bin_mask_raw > 0, raw_pulse, np.nan)
    chase_masked = np.where(bin_mask_raw > 0, raw_chase, np.nan)
    pulse_masked[pulse_masked == 0] = np.nan
    chase_masked[chase_masked == 0] = np.nan

    # Hemisphere masks.
    hemi_polys = load_hemi_polygons(hemi_json)
    hemi = hemi_polys.get(file_name)
    hemi_masks = {}
    if hemi:
        right_poly = np.column_stack((hemi["right"][:, 1], hemi["right"][:, 0]))
        left_poly = np.column_stack((hemi["left"][:, 1], hemi["left"][:, 0]))
        right_mask = polygon2mask(mask.shape, right_poly)
        left_mask = polygon2mask(mask.shape, left_poly)
        right_mask = _resize_nearest(right_mask.astype(np.uint8), raw_pulse.shape).astype(bool)
        left_mask = _resize_nearest(left_mask.astype(np.uint8), raw_pulse.shape).astype(bool)
        hemi_masks = {"right": right_mask, "left": left_mask}

    # Report shapes/sums.
    print(f"PNG dims: {png.shape}, mask dims: {mask.shape}, raw dims: {raw_pulse.shape}")
    print(f"Mask sum (raw space): {bin_mask_raw.sum()}")
    if hemi_masks:
        print(
            "Hemi mask sums (raw space):",
            {k: v.sum() for k, v in hemi_masks.items()},
            "overlap",
            int(np.logical_and.reduce(list(hemi_masks.values())).sum()),
        )

    # Quick region pixel counts for a target ID (main olfactory bulb).
    id_to_name = {int(row["ID"]): row["Name"] for _, row in label_table.iterrows()}
    target_id = next((k for k, v in id_to_name.items() if "Main olfactory bulb" in v), None)
    if target_id is not None:
        region_raw = label_raw == target_id
        region_masked = region_raw & (bin_mask_raw > 0)
        print(
            f"Main olfactory bulb pixels: total {int(region_raw.sum())}, "
            f"masked {int(region_masked.sum())}"
        )
        if hemi_masks:
            for side, hm in hemi_masks.items():
                r = region_masked & hm
                print(f"  {side}: {int(r.sum())} pixels")

    # Save a small summary parquet and CSVs (Python output and MATLAB subset) under the base directory.
    summary = pd.DataFrame(
        {
            "file": [file_name],
            "png_shape": [png.shape],
            "mask_shape": [mask.shape],
            "raw_shape": [raw_pulse.shape],
            "mask_sum_raw": [int(bin_mask_raw.sum())],
        }
    )
    summary_path = out_dir / "tmp_single_python.parquet"
    summary.to_parquet(summary_path, index=False)
    print(f"Wrote summary to {summary_path}")

    # Full Python per-region output to CSV.
    from glua2_processing import process_file as _process_file
    from glua2_metadata import load_metadata

    meta_path = metadata_path or Path("/groups/spruston/home/moharb/Data/metadata_glua2.csv")
    meta = load_metadata(meta_path) if meta_path and meta_path.exists() else pd.DataFrame()
    df_full = _process_file(
        in_dir / file_name,
        in_dir,
        in_dir,
        1,
        label_table,
        meta,
        apply_calib=1,
        hemi_mat=hemi_json,
        calib_path=None,
    )
    df_full["File"] = file_name
    # Drop large list columns before writing head(10)
    drop_cols = [c for c in ["PixelValues", "fp", "tau_values", "bbox"] if c in df_full.columns]
    df_small = df_full.drop(columns=drop_cols)
    python_csv = out_dir / f"{file_name}_python_head10.csv"
    df_small.head(10).to_csv(python_csv, index=False)
    print(f"Wrote Python head(10) CSV to {python_csv}")

    # MATLAB subset to CSV (if parquet exists at the expected path).
    matlab_parquet = Path("/groups/spruston/home/moharb/Data/GluA2_round_1.parquet")
    if matlab_parquet.exists():
        m = pd.read_parquet(matlab_parquet)
        m_subset = m[m["File"] == file_name]
        # MATLAB output already excludes Python-only list columns; just head(10).
        matlab_csv = out_dir / f"{file_name}_matlab_head10.csv"
        m_subset.head(10).to_csv(matlab_csv, index=False)
        print(f"Wrote MATLAB head(10) CSV to {matlab_csv}")
    else:
        print(f"MATLAB parquet not found at {matlab_parquet}; skipping MATLAB CSV.")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--file", required=True, help="PNG filename (e.g., 'Slide 1 of 1-Region 001.png')")
    ap.add_argument("--base", required=True, type=Path, help="Input base directory with files")
    ap.add_argument("--hemi", required=True, type=Path, help="hemi_polygons.json")
    ap.add_argument("--label-table", required=False, type=Path, help="LabelTables.csv path")
    ap.add_argument("--metadata", required=False, type=Path, help="metadata_glua2.csv path")
    ap.add_argument("--output-dir", required=False, type=Path, help="Where to write CSV/parquet outputs")
    args = ap.parse_args()
    inspect_file(args.file, args.base, args.hemi, args.label_table, args.metadata, args.output_dir)


if __name__ == "__main__":
    main()
