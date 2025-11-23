"""Quick comparison helper: MATLAB parquet vs Python parquet."""

from __future__ import annotations

import argparse
import sys

import numpy as np
import pandas as pd


def compare(matlab_path: str, python_path: str, numeric_tol: float = 1e-6) -> None:
    m = pd.read_parquet(matlab_path)
    p = pd.read_parquet(python_path)

    print(f"MATLAB rows: {len(m)}, Python rows: {len(p)}")
    common_cols = [c for c in m.columns if c in p.columns]
    missing_in_py = [c for c in m.columns if c not in p.columns]
    missing_in_matlab = [c for c in p.columns if c not in m.columns]
    print(f"Common columns ({len(common_cols)}): {common_cols}")
    if missing_in_py:
        print("Only in MATLAB:", missing_in_py)
    if missing_in_matlab:
        print("Only in Python:", missing_in_matlab)

    for col in common_cols:
        if pd.api.types.is_numeric_dtype(m[col]) and pd.api.types.is_numeric_dtype(p[col]):
            diff = (m[col].astype(float) - p[col].astype(float)).abs()
            max_diff = diff.max(skipna=True)
            mismatches = (diff > numeric_tol).sum()
            print(f"{col}: max_abs_diff={max_diff}, mismatches>{numeric_tol}: {mismatches}")
        else:
            mismatches = (m[col].astype(str) != p[col].astype(str)).sum()
            print(f"{col}: string mismatches: {mismatches}")


def main(argv: list[str]) -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--matlab", required=True, help="Path to MATLAB parquet")
    parser.add_argument("--python", required=True, help="Path to Python parquet")
    parser.add_argument("--tol", type=float, default=1e-6, help="Numeric tolerance")
    args = parser.parse_args(argv)
    compare(args.matlab, args.python, numeric_tol=args.tol)


if __name__ == "__main__":
    main(sys.argv[1:])
