"""CCF tree utilities for assigning coarse region names."""

from __future__ import annotations

from pathlib import Path
from typing import List, Optional

import numpy as np
import pandas as pd
from scipy.io import loadmat


MAJOR_ACRONYMS = [
    "Isocortex",
    "OLF",
    "HPF",
    "CTXsp",
    "STR",
    "PAL",
    "TH",
    "HY",
    "MB",
    "P",
    "CB",
    "MY",
    "fiber tracts",
    "VS",
]


def load_ccf_tree(tree_path: Path) -> pd.DataFrame:
    """
    Load the Allen CCF tree.

    Expected columns: id, name, acronym, structure_id_path.
    Supports CSV, XLSX, or MAT with struct `CCF_tree`.
    """

    suffix = tree_path.suffix.lower()
    if suffix == ".csv":
        df = pd.read_csv(tree_path)
    elif suffix in {".xlsx", ".xls"}:
        df = pd.read_excel(tree_path)
    elif suffix == ".mat":
        mat = loadmat(tree_path, squeeze_me=True, struct_as_record=False)
        if "CCF_tree" not in mat:
            raise ValueError("MAT file does not contain 'CCF_tree'")
        tree = mat["CCF_tree"]
        df = pd.DataFrame(
            {
                "id": np.asarray(tree.id).ravel(),
                "name": [str(x) for x in np.asarray(tree.name).ravel()],
                "acronym": [str(x) for x in np.asarray(tree.acronym).ravel()],
                "structure_id_path": [str(x) for x in np.asarray(tree.structure_id_path).ravel()],
            }
        )
    else:
        raise ValueError(f"Unsupported tree format: {suffix}")
    df["id"] = df["id"].astype(int)
    return df


def _major_ids(tree: pd.DataFrame) -> List[int]:
    ids: List[int] = []
    for acronym in MAJOR_ACRONYMS:
        matches = tree[tree["acronym"] == acronym]
        if len(matches) == 0:
            continue
        ids.append(int(matches.iloc[0]["id"]))
    return ids


def assign_major_regions(
    df: pd.DataFrame, tree: pd.DataFrame, id_column: str = "CCF_ID"
) -> pd.Series:
    """Assign coarse region names mirroring MATLAB's 12-region mapping."""

    ids = _major_ids(tree)
    full_names = [tree.loc[tree["id"] == i, "name"].iloc[0] for i in ids]
    id_to_full = dict(zip(ids, full_names))

    def _map_row(ccf_id: int) -> Optional[str]:
        if ccf_id in (0, 997):
            return "root"
        matches = tree[tree["id"] == ccf_id]
        if len(matches) == 0:
            return None
        path = str(matches.iloc[0]["structure_id_path"])
        path_ids = [int(x) for x in path.strip("/").split("/") if x]
        inter = [i for i in path_ids if i in ids]
        if not inter:
            return None
        pick = inter[0]
        return id_to_full.get(pick)

    return df[id_column].apply(_map_row)

