"""Per-file processing to mirror MATLAB get_table_glua2 / do_*_glua2."""

from __future__ import annotations

import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple

import numpy as np
import pandas as pd
from PIL import Image
from scipy.io import loadmat
from skimage.draw import polygon2mask
from skimage.transform import resize
from tifffile import imread as tiff_imread

from glua2_labels import map_png_to_labels
from glua2_metadata import AnimalMetadata, resolve_metadata

logger = logging.getLogger(__name__)


@dataclass
class Calibration:
    """Calibration information."""

    calibration: Optional[np.ndarray] = None
    blank: Optional[np.ndarray] = None
    slope_ratio: Optional[float] = None
    offset: Optional[float] = None


def _load_calibration(apply_calib: int, calib_path: Optional[Path]) -> Calibration:
    """
    Load calibration based on apply_calib.

    apply_calib == 1: expects MAT file with `Calibration` and `Blank`
    apply_calib == 2: expects MAT file with struct `calibration` containing slope_ratio/offset
    """

    if apply_calib == 0:
        return Calibration()
    # Default fallback values mirroring getCalibration('20x_SlideScanner_0p5NA')
    default_calib = {673: 2691.5, 552: 1495.4}
    default_blank = {673: 348.0, 552: 207.0}

    if calib_path is None:
        calib_arr = np.full(1024, np.nan)
        blank_arr = np.full(1024, np.nan)
        for k, v in default_calib.items():
            calib_arr[k] = v
        for k, v in default_blank.items():
            blank_arr[k] = v
        return Calibration(calibration=calib_arr, blank=blank_arr)

    mat = loadmat(calib_path, squeeze_me=True, struct_as_record=False)
    if apply_calib == 1:
        calib = mat.get("Calibration")
        blank = mat.get("Blank")
        # Allow MAT files that store calibration as maps/dicts
        if calib is None or blank is None:
            calib_arr = np.full(1024, np.nan)
            blank_arr = np.full(1024, np.nan)
            # Fallback to defaults if not present
            for k, v in default_calib.items():
                calib_arr[k] = v
            for k, v in default_blank.items():
                blank_arr[k] = v
        else:
            calib_arr = np.asarray(calib).ravel()
            blank_arr = np.asarray(blank).ravel()
        return Calibration(calibration=calib_arr, blank=blank_arr)
    if apply_calib == 2:
        new_calib = mat.get("calibration")
        if new_calib is None:
            return Calibration()
        return Calibration(
            slope_ratio=float(getattr(new_calib, "slope_ratio", np.nan)),
            offset=float(getattr(new_calib, "offset", np.nan)),
        )
    return Calibration()


def _read_image(path: Path) -> np.ndarray:
    return np.array(Image.open(path))


def _read_tiff(path: Path) -> np.ndarray:
    arr = np.asarray(tiff_imread(path, key=0))
    # MATLAB imread defaults to the first page; if an extra channel/page axis remains, take the first.
    if arr.ndim > 2:
        arr = arr[0]
    return np.asarray(arr)


def _resize_nearest(arr: np.ndarray, shape: Sequence[int]) -> np.ndarray:
    return resize(arr, shape, order=0, preserve_range=True, anti_aliasing=False).astype(arr.dtype)


def _normalize_polygon(poly: object) -> Optional[np.ndarray]:
    """Convert MATLAB-ish polygon storage to an Nx2 array."""

    if poly is None:
        return None
    if isinstance(poly, np.ndarray):
        if poly.dtype == object and poly.size > 0:
            poly = poly.flat[0]
        if isinstance(poly, np.ndarray) and poly.ndim == 2 and poly.shape[1] == 2:
            return poly.astype(float)
    if isinstance(poly, (list, tuple)) and len(poly) > 0:
        arr = np.asarray(poly)
        if arr.ndim == 2 and arr.shape[1] == 2:
            return arr.astype(float)
    return None


def _load_hemi_polygons(hemi_path: Path) -> Dict[str, Dict[str, np.ndarray]]:
    """
    Load hemi polygons from hemi.mat saved in MATLAB.

    Returns mapping: filename -> {'right': poly, 'left': poly}, filename without directories.
    """

    polygons: Dict[str, Dict[str, np.ndarray]] = {}

    # Support JSON produced by convert_hemi_mat.py
    if hemi_path.suffix.lower() == ".json":
        import json

        data = json.loads(hemi_path.read_text())
        for fname, hemi_dict in data.items():
            # Normalize filename: keep both raw key and basename (handles Windows paths).
            raw_name = str(fname)
            base_name = raw_name.replace("\\", "/").split("/")[-1]
            r = _normalize_polygon(hemi_dict.get("right"))
            l = _normalize_polygon(hemi_dict.get("left"))
            entry = {"right": r, "left": l}
            polygons[raw_name] = entry
            polygons[base_name] = entry
        return polygons

    mat = loadmat(hemi_path, squeeze_me=True, struct_as_record=False)
    gtruth = mat.get("gTruth")
    if gtruth is None:
        return polygons

    sources = getattr(getattr(gtruth, "DataSource", None), "Source", None)
    label_data = getattr(gtruth, "LabelData", None)
    if sources is None or label_data is None:
        return polygons

    # Normalize sources to list of filenames.
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

    for idx, src in enumerate(sources_list):
        fname = Path(src).name
        if idx >= data_array.shape[0]:
            continue
        right_raw = data_array[idx, 0] if data_array.ndim >= 2 else None
        left_raw = data_array[idx, 1] if data_array.ndim >= 2 and data_array.shape[1] > 1 else None
        right_poly = _normalize_polygon(right_raw)
        left_poly = _normalize_polygon(left_raw)
        polygons[fname] = {"right": right_poly, "left": left_poly}

    return polygons


def _bounding_box(mask: np.ndarray) -> Optional[tuple]:
    coords = np.argwhere(mask)
    if coords.size == 0:
        return None
    min_row, min_col = coords.min(axis=0)
    max_row, max_col = coords.max(axis=0)
    width = max_col - min_col + 1
    height = max_row - min_row + 1
    # MATLAB BoundingBox: [x y width height] where x = col, y = row
    return (float(min_col), float(min_row), float(width), float(height))


def _compute_region_rows(
    label_image: np.ndarray,
    label_meta: List[Dict[str, object]],
    raw_pulse: np.ndarray,
    raw_chase: np.ndarray,
    hemi_mask: Optional[np.ndarray],
    hemi_label: str,
    meta: AnimalMetadata,
    ap: float,
    slice_idx: int,
    file_name: str,
    apply_calib: int,
    calibration: Calibration,
    bbox: Optional[Tuple[float, float, float, float]],
) -> List[Dict[str, object]]:
    rows: List[Dict[str, object]] = []
    if hemi_mask is not None:
        label_img = label_image * hemi_mask.astype(label_image.dtype)
    else:
        label_img = label_image

    labels = np.unique(label_img)
    labels = labels[labels > 0]
    round_id_placeholder = None

    for label in labels:
        region_mask = label_image == label
        if hemi_mask is not None:
            region_mask = region_mask & hemi_mask
        if not np.any(region_mask):
            continue

        raw_p = raw_pulse[region_mask].astype(float)
        raw_c = raw_chase[region_mask].astype(float)

        p_vals = raw_p.copy()
        c_vals = raw_c.copy()

        if apply_calib == 1 and calibration.calibration is not None and calibration.blank is not None:
            p_vals = (p_vals - calibration.blank[673]) / calibration.calibration[673]
            c_vals = (c_vals - calibration.blank[552]) / calibration.calibration[552]
        elif apply_calib == 2 and calibration.slope_ratio is not None and calibration.offset is not None:
            c_vals = c_vals
            p_vals = p_vals * calibration.slope_ratio - calibration.offset

        s_vals = p_vals + c_vals

        p_mean = float(np.nanmedian(p_vals))
        p_std = float(np.nanstd(p_vals))
        n_count = int(np.nansum(raw_p > 0))
        c_mean = float(np.nanmedian(c_vals))
        c_std = float(np.nanstd(c_vals))
        fraction = p_mean / (p_mean + c_mean) if (p_mean + c_mean) != 0 else np.nan
        sum_sd = float(np.nanstd(s_vals))

        f = raw_p / (raw_p + raw_c)
        f = f[np.isfinite(f)]
        tau_values = np.abs(meta.p_c_interval / np.log(1.0 / f))
        tau = float(np.abs(meta.p_c_interval / np.log(1.0 / fraction))) if np.isfinite(fraction) else np.nan

        centroid_coords = np.argwhere(region_mask)
        centroid = (
            float(np.nanmean(centroid_coords[:, 0])),
            float(np.nanmean(centroid_coords[:, 1])),
        )

        lmeta = label_meta[label - 1]
        rows.append(
            {
                "ANM": meta.animal_id,
                "Sex": meta.sex,
                "groupName": meta.group,
                "AP": float(ap),
                "Slice": int(slice_idx),
                "Name": lmeta["ccf_name"],
                "CCF_ID": int(lmeta["ccf_id"]),
                "tau": tau,
                "tau_values": tau_values.tolist(),
                "fp": f.tolist(),
                "P_Mean": p_mean,
                "P_STD": p_std,
                "N": n_count,
                "C_Mean": c_mean,
                "C_STD": c_std,
                "fraction": fraction,
                "sum_sd": sum_sd,
                "File": file_name,
                "Age": int(meta.age_days),
                "Line": int(meta.line),
                "SizeX": int(raw_pulse.shape[0]),
                "SizeY": int(raw_pulse.shape[1]),
                "Hemi": hemi_label,
                "Centroid": centroid,
                "Round": round_id_placeholder,  # to be overwritten by caller
                "PixelValues": raw_p.tolist(),
                "bbox": bbox,
            }
        )
    return rows


def process_file(
    file_path: Path,
    base_dir: Path,
    xml_dir: Path,
    round_id: int,
    label_table: pd.DataFrame,
    metadata: pd.DataFrame,
    apply_calib: int = 1,
    hemi_mat: Optional[Path] = None,
    calib_path: Optional[Path] = None,
) -> pd.DataFrame:
    """
    Process a single PNG (non-overlay) file into a row-per-region DataFrame.
    """

    meta_row = resolve_metadata(metadata, round_id, file_path.name)
    ap_info = get_ap_from_xml(meta_row.animal_id, file_path.name, xml_dir)
    ap = ap_info["AP"]
    slice_idx = ap_info["index"]

    stem = file_path.stem
    png_path = base_dir / f"{stem}_nl.png"
    if not png_path.exists():
        logger.warning("Missing nl png: %s", png_path)
        return pd.DataFrame()

    png = _read_image(png_path)
    mask_path = base_dir / f"{stem}_Probabilities.tif"
    if not mask_path.exists():
        logger.warning("Missing mask: %s", mask_path)
        return pd.DataFrame()
    mask = _read_tiff(mask_path)
    # Match MATLAB thresholding: keep pixels >= 128
    bin_mask = (mask >= 128).astype(np.uint16)

    pulse_path = base_dir / f"{stem}_CY5.tiff"
    chase_path = base_dir / f"{stem}_CY3.tiff"
    if not pulse_path.exists() or not chase_path.exists():
        pulse_path = base_dir / f"{stem}-CY5.tiff"
        chase_path = base_dir / f"{stem}-CY3.tiff"
    raw_pulse = _read_tiff(pulse_path).astype(np.float32)
    raw_chase = _read_tiff(chase_path).astype(np.float32)

    bin_mask2 = _resize_nearest(bin_mask, raw_pulse.shape)
    raw_pulse = np.where(bin_mask2 > 0, raw_pulse, np.nan)
    raw_chase = np.where(bin_mask2 > 0, raw_chase, np.nan)
    # Match MATLAB: set zeros to NaN after masking so background doesn’t skew medians.
    raw_pulse[raw_pulse == 0] = np.nan
    raw_chase[raw_chase == 0] = np.nan

    label_image, label_meta = map_png_to_labels(png, label_table)
    # Align labels to the probability mask (polygon) space first, then to raw image space.
    if label_image.shape[:2] != mask.shape[:2]:
        label_image = _resize_nearest(label_image, mask.shape[:2])
    label_image = _resize_nearest(label_image, raw_pulse.shape)

    hemi_polygons = {}
    if hemi_mat is not None and hemi_mat.exists():
        hemi_polygons = _load_hemi_polygons(hemi_mat)

    calibration = _load_calibration(apply_calib, calib_path)

    rows: List[Dict[str, object]] = []
    hemi_info = hemi_polygons.get(file_path.name)
    if hemi_info and hemi_info.get("right") is not None and hemi_info.get("left") is not None:
        label_shape = mask.shape[:2]
        # Match MATLAB poly2mask behavior more closely by rounding vertices to pixel centers.
        right_poly = np.round(np.column_stack((hemi_info["right"][:, 1], hemi_info["right"][:, 0])))
        left_poly = np.round(np.column_stack((hemi_info["left"][:, 1], hemi_info["left"][:, 0])))
        right_mask = polygon2mask(label_shape, right_poly)
        left_mask = polygon2mask(label_shape, left_poly)
        right_mask = _resize_nearest(right_mask.astype(np.uint8), raw_pulse.shape).astype(bool)
        left_mask = _resize_nearest(left_mask.astype(np.uint8), raw_pulse.shape).astype(bool)
        bbox_right = _bounding_box(right_mask)
        bbox_left = _bounding_box(left_mask)
        rows.extend(
            _compute_region_rows(
                label_image,
                label_meta,
                raw_pulse,
                raw_chase,
                hemi_mask=right_mask,
                hemi_label="right",
                meta=meta_row,
                ap=ap,
                slice_idx=slice_idx,
                file_name=file_path.name,
                apply_calib=apply_calib,
                calibration=calibration,
                bbox=bbox_right,
            )
        )
        rows.extend(
            _compute_region_rows(
                label_image,
                label_meta,
                raw_pulse,
                raw_chase,
                hemi_mask=left_mask,
                hemi_label="left",
                meta=meta_row,
                ap=ap,
                slice_idx=slice_idx,
                file_name=file_path.name,
                apply_calib=apply_calib,
                calibration=calibration,
                bbox=bbox_left,
            )
        )
    else:
        bbox_both = _bounding_box(np.isfinite(raw_pulse))
        rows.extend(
            _compute_region_rows(
                label_image,
                label_meta,
                raw_pulse,
                raw_chase,
                hemi_mask=None,
                hemi_label="both",
                meta=meta_row,
                ap=ap,
                slice_idx=slice_idx,
                file_name=file_path.name,
                apply_calib=apply_calib,
                calibration=calibration,
                bbox=bbox_both,
            )
        )

    df = pd.DataFrame(rows)
    if df.empty:
        return df

    df["Round"] = round_id

    return df


def get_ap_from_xml(animal_id: str, filename: str, xml_dir: Path) -> Dict[str, float]:
    """
    Reproduce MATLAB get_AP_glua2: read <animal_id>_lin.xml and find AP for filename.
    """

    xml_path = xml_dir / f"{animal_id}_lin.xml"
    if not xml_path.exists():
        raise FileNotFoundError(f"AP xml not found: {xml_path}")

    # Mirror MATLAB's readtable(delimiter='=') behavior to pull the AP values.
    cols = [
        "Var1",
        "Name",
        "Var3",
        "Var4",
        "Var5",
        "Var6",
        "Var7",
        "AP",
        "Var9",
        "Var10",
        "Var11",
        "Var12",
        "Var13",
        "Var14",
        "Var15",
    ]
    df = pd.read_csv(xml_path, sep="=", names=cols, engine="python")

    # Coerce AP by extracting the first numeric token, matching MATLAB TrimNonNumeric.
    ap_str = df["AP"].astype(str)
    ap_vals = ap_str.str.extract(r"([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)", expand=False)
    aps = ap_vals.astype(float)

    def _trim(key: str) -> str:
        return key[1:-4] if len(key) > 4 else key

    names = df["Name"].astype(str).apply(_trim)
    valid = aps.notna()

    target = Path(filename).stem
    valid_names = names[valid].reset_index(drop=True)
    valid_aps = aps[valid].reset_index(drop=True)
    matches = [i for i, k in valid_names.items() if target in k or filename in k]
    if not matches:
        raise ValueError(f"No AP entry found in {xml_path} for {filename}")
    idx = matches[0]
    return {"AP": float(valid_aps.loc[idx]), "index": int(idx) + 1}
