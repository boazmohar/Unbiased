"""Round-level driver to mirror get_round_data_GluA2.m in Python."""

from __future__ import annotations

import argparse
import logging
import re
from pathlib import Path
from typing import Iterable, List, Sequence

import numpy as np
import pandas as pd

from glua2_ccf import assign_major_regions, load_ccf_tree
from glua2_labels import load_label_table
from glua2_metadata import load_metadata
from glua2_processing import process_file

logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
logger = logging.getLogger(__name__)


def _discretize_ap(ap_values: pd.Series, ap_range: Sequence[float]) -> pd.Series:
    bins = np.array(ap_range, dtype=float)
    labels = pd.cut(ap_values, bins=bins, labels=False, right=True, include_lowest=True)
    # MATLAB discretize returns 1-based bin indices.
    return labels.astype("Int64") + 1


def _compute_layers(names: pd.Series) -> pd.Series:
    layers = []
    for name in names:
        match = re.search(r"[lL]ayer\s(\d)", str(name))
        if match:
            val = int(match.group(1))
            layers.append(2 if val == 3 else val)
        else:
            layers.append(0)
    layers = pd.Series(layers, index=names.index, dtype="Int64")
    ca1 = names.str.contains("CA1", na=False)
    ca2 = names.str.contains("CA2", na=False)
    ca3 = names.str.contains("CA3", na=False)
    layers.loc[ca1] = 7
    layers.loc[ca2] = 8
    layers.loc[ca3] = 9
    return layers


def _compute_valid_flags(df: pd.DataFrame, px_threshold: int) -> pd.Series:
    exclude = {"root", "fiber tracts", "ventricular systems"}
    excluded = df["new_names"].fillna("").isin(exclude)
    valid = (~excluded) & (df["N"] > px_threshold)
    return valid.astype(int)


def discover_files(base_dir: Path) -> List[Path]:
    files = sorted(base_dir.glob("*.png"))
    files = [f for f in files if "overlay" not in f.name]
    files = files[::2]  # match MATLAB 1:2:end behavior
    return files


def run_round(
    base_dir: Path,
    output_dir: Path,
    xml_dir: Path,
    round_id: int,
    metadata_path: Path,
    label_table_path: Path,
    ccf_tree_path: Path,
    ap_range: Sequence[float],
    px_threshold: int,
    apply_calib: int,
    hemi_mat: Path | None,
    calib_path: Path | None,
) -> Path:
    metadata = load_metadata(metadata_path)
    label_table = load_label_table(label_table_path)
    ccf_tree = load_ccf_tree(ccf_tree_path) if ccf_tree_path else None

    files = discover_files(base_dir)
    logger.info("Found %d PNG files (after filtering overlays/every-other).", len(files))

    all_rows: List[pd.DataFrame] = []
    for f in files:
        try:
            df = process_file(
                f,
                base_dir=base_dir,
                xml_dir=xml_dir,
                round_id=round_id,
                label_table=label_table,
                metadata=metadata,
                apply_calib=apply_calib,
                hemi_mat=hemi_mat,
                calib_path=calib_path,
            )
            if not df.empty:
                all_rows.append(df)
        except Exception as exc:  # keep going but surface issues
            logger.exception("Failed on %s: %s", f.name, exc)

    if not all_rows:
        raise RuntimeError("No data rows were produced.")

    tbl = pd.concat(all_rows, ignore_index=True)
    tbl["AP2"] = _discretize_ap(tbl["AP"], ap_range)
    if ccf_tree is not None:
        tbl["new_names"] = assign_major_regions(tbl, ccf_tree, id_column="CCF_ID")
    else:
        tbl["new_names"] = None
    tbl["valid"] = _compute_valid_flags(tbl, px_threshold)
    tbl["layer"] = _compute_layers(tbl["Name"])

    output_dir.mkdir(parents=True, exist_ok=True)
    out_path = output_dir / f"GluA2_round_{round_id}.parquet"
    tbl.to_parquet(out_path, index=False)
    logger.info("Wrote %s", out_path)
    return out_path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Python port of get_round_data_GluA2.m")
    p.add_argument("--base-dir", required=True, type=Path, help="Directory containing PNG/TIFF inputs")
    p.add_argument("--output-dir", required=True, type=Path, help="Directory to write parquet output")
    p.add_argument("--xml-dir", required=True, type=Path, help="Directory containing *_lin.xml AP files")
    p.add_argument("--round", required=True, type=int, dest="round_id")
    p.add_argument("--metadata", default=Path("metadata_glua2.csv"), type=Path)
    p.add_argument("--label-table", required=True, type=Path)
    p.add_argument("--ccf-tree", required=False, type=Path, default=None)
    p.add_argument("--ap-range", default="0:50:550", help="Edges for AP bins, e.g., '0:50:550'")
    p.add_argument("--px-threshold", type=int, default=20)
    p.add_argument("--apply-calib", type=int, default=1, choices=[0, 1, 2])
    p.add_argument("--hemi-mat", type=Path, default=None)
    p.add_argument("--calib-path", type=Path, default=None)
    return p.parse_args()


def parse_ap_range(spec: str) -> List[float]:
    if ":" in spec:
        start, step, stop = spec.split(":")
        return list(np.arange(float(start), float(stop) + float(step), float(step)))
    return [float(x) for x in spec.split(",") if x]


def main() -> None:
    args = parse_args()
    ap_range = parse_ap_range(args.ap_range)
    run_round(
        base_dir=args.base_dir,
        output_dir=args.output_dir,
        xml_dir=args.xml_dir,
        round_id=args.round_id,
        metadata_path=args.metadata,
        label_table_path=args.label_table,
        ccf_tree_path=args.ccf_tree,
        ap_range=ap_range,
        px_threshold=args.px_threshold,
        apply_calib=args.apply_calib,
        hemi_mat=args.hemi_mat,
        calib_path=args.calib_path,
    )


if __name__ == "__main__":
    main()
