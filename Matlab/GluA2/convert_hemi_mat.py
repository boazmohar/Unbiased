"""
Utility to convert hemi ground-truth polygons from MATLAB gTruth to a simple JSON.

Expected MATLAB layout (matches do_hemi_glua2):
- gTruth.DataSource.Source: list of filenames
- gTruth.LabelData: Nx2 cell, column 0 = right polys, column 1 = left polys

If the input MAT contains an MCOS (MatlabOpaque) groundTruth object, this script
will emit instructions to export a struct from MATLAB (exportToStruct) and retry.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List, Optional

import numpy as np
from scipy.io import loadmat
from scipy.io.matlab._mio5_params import MatlabOpaque


def _normalize_poly(poly: Any) -> Optional[List[List[float]]]:
    """Convert MATLAB-ish polygon storage to a plain list of [x, y] floats."""

    if poly is None:
        return None
    arr = np.asarray(poly)
    if arr.dtype == object and arr.size > 0:
        return _normalize_poly(arr.flat[0])
    if arr.ndim == 2 and arr.shape[1] == 2:
        return arr.astype(float).tolist()
    return None


def convert_hemi_mat(input_path: Path, output_json: Path) -> None:
    mat = loadmat(input_path, squeeze_me=True, struct_as_record=False)

    # Direct source/labels variables (preferred when saved manually from MATLAB)
    if "sources" in mat and "labels" in mat:
        srcs = mat["sources"]
        lbls = mat["labels"]
        if isinstance(srcs, np.ndarray):
            sources_list = [str(s) for s in srcs.tolist()]
        else:
            sources_list = [str(srcs)]
        data_array = np.asarray(lbls)
        polygons: Dict[str, Dict[str, Optional[List[List[float]]]]] = {}
        for idx, src in enumerate(sources_list):
            fname = Path(src).name
            right_raw = data_array[idx, 0] if data_array.ndim >= 2 else None
            left_raw = data_array[idx, 1] if data_array.ndim >= 2 and data_array.shape[1] > 1 else None
            polygons[fname] = {
                "right": _normalize_poly(right_raw),
                "left": _normalize_poly(left_raw),
            }
        output_json.parent.mkdir(parents=True, exist_ok=True)
        output_json.write_text(json.dumps(polygons, indent=2))
        print(f"Wrote polygons for {len(polygons)} files to {output_json}")
        return

    # Resolve a struct-like ground truth object.
    gtruth = None
    for key, val in mat.items():
        if key.startswith("__"):
            continue
        if isinstance(val, MatlabOpaque):
            continue
        if hasattr(val, "DataSource") and hasattr(val, "LabelData"):
            gtruth = val
            break

    if gtruth is None:
        # Handle case where MATLAB saved a struct as "gtStruct" or similar.
        for key, val in mat.items():
            if key.startswith("__"):
                continue
            if hasattr(val, "DataSource") and hasattr(val, "LabelData"):
                gtruth = val
                break

    if gtruth is None:
        raise RuntimeError(
            "No struct-like gTruth found. If your MAT contains a groundTruth object, "
            "convert it in MATLAB, e.g.:\n"
            "  load('hemi.mat'); gtStruct = struct(gTruth);\n"
            "  save('hemi_struct.mat','gtStruct','-v7');"
        )

    sources = getattr(getattr(gtruth, "DataSource", None), "Source", None)
    label_data = getattr(gtruth, "LabelData", None)
    if sources is None or label_data is None:
        raise RuntimeError("gTruth is missing DataSource.Source or LabelData fields.")

    if isinstance(sources, np.ndarray):
        sources_list = [str(s) for s in sources.tolist()]
    elif isinstance(sources, list):
        sources_list = [str(s) for s in sources]
    else:
        sources_list = [str(sources)]

    if isinstance(label_data, np.ndarray):
        data_array = label_data
    else:
        data_array = np.asarray(label_data)

    polygons: Dict[str, Dict[str, Optional[List[List[float]]]]] = {}
    for idx, src in enumerate(sources_list):
        fname = Path(src).name
        right_raw = data_array[idx, 0] if data_array.ndim >= 2 else None
        left_raw = data_array[idx, 1] if data_array.ndim >= 2 and data_array.shape[1] > 1 else None
        polygons[fname] = {
            "right": _normalize_poly(right_raw),
            "left": _normalize_poly(left_raw),
        }

    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(polygons, indent=2))
    print(f"Wrote polygons for {len(polygons)} files to {output_json}")


def main() -> None:
    ap = argparse.ArgumentParser(description="Convert hemi.mat gTruth to JSON polygons")
    ap.add_argument("input", type=Path, help="hemi.mat (with gTruth struct)")
    ap.add_argument(
        "--output-json",
        type=Path,
        default=Path("hemi_polygons.json"),
        help="Where to write the polygon mapping",
    )
    args = ap.parse_args()
    convert_hemi_mat(args.input, args.output_json)


if __name__ == "__main__":
    main()
