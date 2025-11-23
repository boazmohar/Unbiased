"""Label table helpers for mapping RGB atlas PNGs to CCF IDs and names."""

from __future__ import annotations

from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd
from scipy.io import loadmat


def load_label_table(path: Path) -> pd.DataFrame:
    """
    Load the Allen label table.

    Supported formats:
    - CSV with columns: ID, Name, R, G, B
    - XLSX with the same columns
    - MAT file containing struct/table `LabelTables` with the above fields
    """

    suffix = path.suffix.lower()
    if suffix == ".csv":
        df = pd.read_csv(path)
    elif suffix in {".xlsx", ".xls"}:
        df = pd.read_excel(path)
    elif suffix == ".mat":
        mat = loadmat(path, squeeze_me=True, struct_as_record=False)
        if "LabelTables" not in mat:
            raise ValueError("MAT file does not contain 'LabelTables'")
        lt = mat["LabelTables"]
        df = pd.DataFrame(
            {
                "ID": np.asarray(lt.ID).ravel(),
                "Name": [str(x) for x in np.asarray(lt.Name).ravel()],
                "R": np.asarray(lt.R).ravel(),
                "G": np.asarray(lt.G).ravel(),
                "B": np.asarray(lt.B).ravel(),
            }
        )
    else:
        raise ValueError(f"Unsupported label table format: {suffix}")
    # Normalize dtype
    df["ID"] = df["ID"].astype(int)
    df["R"] = df["R"].astype(int)
    df["G"] = df["G"].astype(int)
    df["B"] = df["B"].astype(int)
    return df


def map_png_to_labels(
    png: np.ndarray, label_table: pd.DataFrame
) -> Tuple[np.ndarray, List[Dict[str, object]]]:
    """
    Map an RGB atlas PNG to label indices and associated CCF metadata.

    Returns:
    - label_image: 2D array of label indices (1-based)
    - label_meta: list where label_meta[i] corresponds to label i+1
                  and contains {'ccf_id', 'ccf_name'}
    Unknown colors are mapped to ccf_id=0 and ccf_name='root'.
    """

    if png.ndim != 3 or png.shape[2] != 3:
        raise ValueError("PNG array must be HxWx3 RGB")

    flat = png.reshape(-1, 3)
    unique_colors, inverse = np.unique(flat, axis=0, return_inverse=True)
    label_image = inverse.reshape(png.shape[:2]) + 1  # 1-based labels

    legend = label_table[["R", "G", "B"]].values
    legend_lookup = {tuple(color): idx for idx, color in enumerate(legend.tolist())}

    label_meta: List[Dict[str, object]] = []
    for color in unique_colors:
        key = tuple(int(v) for v in color.tolist())
        legend_idx = legend_lookup.get(key)
        if legend_idx is None:
            label_meta.append({"ccf_id": 0, "ccf_name": "root"})
        else:
            row = label_table.iloc[legend_idx]
            label_meta.append({"ccf_id": int(row["ID"]), "ccf_name": str(row["Name"])})

    return label_image.astype(np.int32), label_meta

