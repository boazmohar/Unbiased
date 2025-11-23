"""Metadata loading and lookup for GluA2 processing."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Tuple

import pandas as pd


@dataclass(frozen=True)
class AnimalMetadata:
    """Resolved metadata for a single file/animal."""

    animal_id: str
    sex: str
    group: str
    line: int
    dob: pd.Timestamp
    perfusion: pd.Timestamp
    age_days: int
    p_c_interval: int
    match_type: str
    slide_start: Optional[int]
    slide_end: Optional[int]
    slide: Optional[int]


def load_metadata(metadata_path: Path) -> pd.DataFrame:
    """Load metadata CSV/XLSX that mirrors metadata_glua2.* layout."""

    if metadata_path.suffix.lower() in {".xlsx", ".xls"}:
        df = pd.read_excel(metadata_path)
    else:
        df = pd.read_csv(metadata_path)
    # Normalize column types.
    if "dob" in df.columns:
        df["dob"] = pd.to_datetime(df["dob"])
    if "perfusion" in df.columns:
        df["perfusion"] = pd.to_datetime(df["perfusion"])
    return df


def _parse_filename(filename: str, round_id: int) -> Tuple[str, Optional[int]]:
    """
    Infer animal_id and slide number from the filename, following MATLAB rules.

    Round != 11: "<animal> <slide>.png"
    Round 11: "<animal>_<digits>.png" where digits may include a 4-digit suffix.
    """

    stem = Path(filename).stem
    if round_id == 11:
        parts = stem.split("_")
        animal = parts[0] if parts else stem
        slide = None
        if len(parts) >= 2:
            digits = "".join(ch for ch in parts[1] if ch.isdigit())
            if digits:
                # MATLAB strips a 4-digit suffix; preserve the same behavior.
                trimmed = digits[:-4] if len(digits) > 4 else digits
                if trimmed:
                    slide = int(trimmed)
    else:
        parts = stem.split()
        animal = parts[0] if parts else stem
        slide = None
        if len(parts) >= 2:
            # MATLAB parse_name_glua2 pulls the second token as the slide number.
            maybe_slide = "".join(ch for ch in parts[1] if ch.isdigit())
            if not maybe_slide and len(parts) >= 1:
                maybe_slide = "".join(ch for ch in parts[-1] if ch.isdigit())
            slide = int(maybe_slide) if maybe_slide else None
    return animal, slide


def resolve_metadata(meta: pd.DataFrame, round_id: int, filename: str) -> AnimalMetadata:
    """Resolve a metadata row for the given filename and round."""

    animal, slide = _parse_filename(filename, round_id)
    candidates = meta[meta["round"] == round_id]
    row = None
    if round_id == 11:
        matches = candidates[candidates["animal_id"] == animal]
        if len(matches) == 0:
            raise ValueError(f"No metadata match for animal '{animal}' in round {round_id}")
        row = matches.iloc[0]
    else:
        if slide is None:
            raise ValueError(f"Could not parse slide number from '{filename}' for round {round_id}")
        matches = candidates[
            (candidates["match_type"] == "slide_range")
            & (candidates["slide_start"] <= slide)
            & (candidates["slide_end"] >= slide)
        ]
        if len(matches) == 0:
            raise ValueError(
                f"No metadata match for slide {slide} in round {round_id} (file '{filename}')"
            )
        row = matches.iloc[0]

    return AnimalMetadata(
        animal_id=str(row["animal_id"]),
        sex=str(row["sex"]),
        group=str(row["group"]),
        line=int(row["line"]),
        dob=row["dob"],
        perfusion=row["perfusion"],
        age_days=int(row["age_days"]),
        p_c_interval=int(row["p_c_interval"]),
        match_type=str(row["match_type"]),
        slide_start=int(row["slide_start"]) if pd.notna(row["slide_start"]) else None,
        slide_end=int(row["slide_end"]) if pd.notna(row["slide_end"]) else None,
        slide=slide,
    )
