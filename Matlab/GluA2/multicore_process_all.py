"""
Multicore wrapper to run `process_file` across all PNGs in a directory.

This keeps the per-file logic identical to the existing pipeline but spreads
the work across CPU cores using ProcessPoolExecutor.

Usage example:
  python multicore_process_all.py \
    --base /groups/spruston/home/moharb/Data/GluA2_round1_try1 \
    --hemi /groups/spruston/home/moharb/Data/GluA2_round1_try1/hemi_polygons.json \
    --label-table /groups/spruston/home/moharb/Data/GluA2_round1_try1/LabelTables.csv \
    --metadata /groups/spruston/home/moharb/Data/metadata_glua2.csv \
    --apply-calib 1 \
    --max-workers 8 \
    --out all_regions_parquet.parquet
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable, List, Optional, Tuple

import pandas as pd
from concurrent.futures import ProcessPoolExecutor, as_completed

from glua2_labels import load_label_table
from glua2_metadata import load_metadata
from glua2_processing import process_file


def _chunked(iterable: Iterable[Path], n: int) -> Iterable[Tuple[Path, ...]]:
    chunk: List[Path] = []
    for item in iterable:
        chunk.append(item)
        if len(chunk) == n:
            yield tuple(chunk)
            chunk = []
    if chunk:
        yield tuple(chunk)


def _process_one(
    png_path: Path,
    base_dir: Path,
    label_table_path: Path,
    metadata_path: Path,
    hemi_path: Optional[Path],
    apply_calib: int,
) -> pd.DataFrame:
    # Load per-worker to avoid pickling large objects; overhead is minor vs IO.
    label_table = load_label_table(label_table_path)
    metadata = load_metadata(metadata_path)
    df = process_file(
        png_path,
        base_dir,
        base_dir,
        1,
        label_table,
        metadata,
        apply_calib=apply_calib,
        hemi_mat=hemi_path,
    )
    return df


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", required=True, type=Path, help="Base directory containing PNG/TIF inputs")
    ap.add_argument("--hemi", type=Path, help="Path to hemi_polygons.json or hemi.mat")
    ap.add_argument("--label-table", type=Path, required=True, help="LabelTables.csv/xlsx/mat path")
    ap.add_argument("--metadata", type=Path, required=True, help="metadata_glua2.csv path")
    ap.add_argument("--apply-calib", type=int, default=1, choices=[0, 1, 2], help="applyCalib mode")
    ap.add_argument("--max-workers", type=int, default=None, help="Number of processes (defaults to cpu count)")
    ap.add_argument(
        "--out",
        type=Path,
        default=Path("all_regions_parquet.parquet"),
        help="Output parquet path (in current directory if relative)",
    )
    args = ap.parse_args()

    base_dir = args.base
    png_files = sorted(
        p
        for p in base_dir.glob("*.png")
        if not p.name.endswith("_nl.png") and "_mask" not in p.name and "_hemi" not in p.name
    )
    if not png_files:
        raise RuntimeError(f"No PNG files found in {base_dir}")

    print(f"Found {len(png_files)} PNG files. Using up to {args.max_workers or 'all'} workers.")
    results: List[pd.DataFrame] = []

    with ProcessPoolExecutor(max_workers=args.max_workers) as ex:
        futures = {
            ex.submit(
                _process_one,
                png_path,
                base_dir,
                args.label_table,
                args.metadata,
                args.hemi,
                args.apply_calib,
            ): png_path
            for png_path in png_files
        }
        for idx, fut in enumerate(as_completed(futures), 1):
            png = futures[fut]
            try:
                df = fut.result()
                if df is not None and not df.empty:
                    results.append(df)
                print(f"[{idx}/{len(futures)}] done: {png.name} ({len(df)} rows)")
            except Exception as e:  # noqa: BLE001
                print(f"[{idx}/{len(futures)}] FAILED: {png.name} -> {e}")

    if not results:
        raise RuntimeError("No results produced; check errors above.")

    all_df = pd.concat(results, ignore_index=True)
    out_path = args.out
    out_path.parent.mkdir(parents=True, exist_ok=True)
    all_df.to_parquet(out_path, index=False)
    print(f"Wrote {out_path} with {len(all_df)} rows across {len(png_files)} files.")


if __name__ == "__main__":
    main()
