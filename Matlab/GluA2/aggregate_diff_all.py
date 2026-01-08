"""
Compute Python vs MATLAB diffs for all PNG files and plot aggregate histograms.

Usage:
  python aggregate_diff_all.py \
    --base /groups/spruston/home/moharb/Data/GluA2_round1_try1 \
    --hemi /groups/spruston/home/moharb/Data/GluA2_round1_try1/hemi_polygons.json
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict, List

import matplotlib.pyplot as plt
import pandas as pd

from glua2_labels import load_label_table
from glua2_metadata import load_metadata
from glua2_processing import process_file


def _plot_hist(series: pd.Series, title: str, out_path: Path) -> None:
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.hist(series, bins=80, color="steelblue", edgecolor="black")
    ax.set_title(title)
    ax.set_xlabel(series.name)
    ax.set_ylabel("count")
    fig.tight_layout()
    fig.savefig(out_path, dpi=150)
    plt.close(fig)
    print(f"Wrote {out_path}")


def aggregate_diffs(
    base_dir: Path,
    hemi_path: Path,
    label_table_path: Path,
    metadata_path: Path,
    matlab_parquet: Path,
    output_prefix: Path,
) -> None:
    label_table = load_label_table(label_table_path)
    metadata = load_metadata(metadata_path)
    mat_df = pd.read_parquet(matlab_parquet)

    png_files = sorted(
        p for p in base_dir.glob("*.png") if not p.name.endswith("_nl.png") and "_mask" not in p.name
    )
    if not png_files:
        raise RuntimeError(f"No PNG files found in {base_dir}")

    merged_rows: List[pd.DataFrame] = []

    for idx, png_path in enumerate(png_files, 1):
        print(f"[{idx}/{len(png_files)}] processing {png_path.name}")
        py_df = process_file(
            png_path,
            base_dir,
            base_dir,
            1,
            label_table,
            metadata,
            apply_calib=1,
            hemi_mat=hemi_path,
        )
        if py_df.empty:
            continue
        py_group = (
            py_df.groupby(["CCF_ID", "Hemi"], dropna=False)[["N", "P_Mean", "C_Mean"]]
            .sum()
            .reset_index()
        )
        py_group["File"] = png_path.name

        mat_file = mat_df[mat_df["File"] == png_path.name]
        mat_group = (
            mat_file.groupby(["CCF_ID", "Hemi"], dropna=False)[["N", "P_Mean", "C_Mean"]]
            .sum()
            .reset_index()
        )

        merged = pd.merge(
            py_group,
            mat_group,
            on=["CCF_ID", "Hemi"],
            how="outer",
            suffixes=("_py", "_mat"),
        )
        merged["File"] = png_path.name
        merged.fillna(0, inplace=True)
        merged["N_diff"] = merged["N_py"] - merged["N_mat"]
        merged["P_diff"] = merged["P_Mean_py"] - merged["P_Mean_mat"]
        merged["C_diff"] = merged["C_Mean_py"] - merged["C_Mean_mat"]

        merged_rows.append(merged)

    if not merged_rows:
        raise RuntimeError("No merged rows produced.")

    all_merged = pd.concat(merged_rows, ignore_index=True)
    csv_path = output_prefix.with_suffix(".all_diff.csv")
    all_merged.to_csv(csv_path, index=False)
    print(f"Wrote {csv_path}")

    # Aggregate histograms across all rows.
    for col in ["N_diff", "P_diff", "C_diff"]:
        if col not in all_merged.columns:
            continue
        out_path = output_prefix.with_suffix(f".{col}.png")
        _plot_hist(all_merged[col], f"{col} (all files)", out_path)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True, type=Path, help="Base data directory with PNGs/TIFs")
    ap.add_argument("--hemi", required=True, type=Path, help="Path to hemi_polygons.json or hemi.mat")
    ap.add_argument(
        "--label-table",
        type=Path,
        default=Path("/groups/spruston/home/moharb/Data/GluA2_round1_try1/LabelTables.csv"),
    )
    ap.add_argument(
        "--metadata",
        type=Path,
        default=Path("/groups/spruston/home/moharb/Data/metadata_glua2.csv"),
    )
    ap.add_argument(
        "--matlab-parquet",
        type=Path,
        default=Path("/groups/spruston/home/moharb/Data/GluA2_round_1.parquet"),
    )
    ap.add_argument(
        "--out-prefix",
        type=Path,
        default=Path("all_regions_diff"),
        help="Output prefix for CSV/PNGs (written in current directory)",
    )
    args = ap.parse_args()

    aggregate_diffs(
        args.base,
        args.hemi,
        args.label_table,
        args.metadata,
        args.matlab_parquet,
        args.out_prefix,
    )


if __name__ == "__main__":
    main()
