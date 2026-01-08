"""
Plot histograms of Python - MATLAB differences for N, P_Mean, and C_Mean.

Usage:
  python plot_diff_hist.py --csv Slide\ 1\ of\ 1-Region\ 001_debug_merge.csv --out diff_region001
"""

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


def plot_diffs(csv_path: Path, out_prefix: Path) -> None:
    df = pd.read_csv(csv_path)
    for col in ["N_diff", "P_diff", "C_diff"]:
        if col not in df.columns:
            continue
        fig, ax = plt.subplots(figsize=(6, 4))
        ax.hist(df[col], bins=50, color="steelblue", edgecolor="black")
        ax.set_title(f"{csv_path.name}: {col}")
        ax.set_xlabel(col)
        ax.set_ylabel("count")
        fig.tight_layout()
        out_path = out_prefix.with_suffix(f".{col}.png")
        fig.savefig(out_path, dpi=150)
        plt.close(fig)
        print(f"Wrote {out_path}")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", required=True, type=Path, help="Merged diff CSV (from single_file_region_debug.py)")
    ap.add_argument("--out", required=True, type=Path, help="Output prefix (without extension)")
    args = ap.parse_args()
    plot_diffs(args.csv, args.out)


if __name__ == "__main__":
    main()
