Python port of the GluA2 round table pipeline
===============================================

Files:
- `glua2_metadata.py`: load/resolve metadata from `metadata_glua2.*`.
- `glua2_labels.py`: load Allen label table (csv/xlsx/mat) and map RGB PNGs to CCF ids.
- `glua2_ccf.py`: load CCF tree and assign coarse 12-region names.
- `glua2_processing.py`: per-file logic mirroring `get_table_glua2` and hemi/both handling.
- `glua2_pipeline.py`: round-level CLI that mirrors `get_round_data_GluA2.m` (Parquet writer).
- `compare_outputs.py`: helper to diff MATLAB vs Python parquet outputs.
- `requirements.txt`: Python dependencies.

Usage (example):
```
python glua2_pipeline.py \
  --base-dir U:\Unbiased\Matlab\GluA2\round1 \
  --xml-dir U:\Unbiased\Matlab\GluA2\round1 \
  --output-dir U:\Unbiased\Matlab\GluA2\python_out \
  --round 1 \
  --metadata metadata_glua2.csv \
  --label-table path\to\LabelTables.csv \
  --ccf-tree path\to\CCF_tree.csv \
  --hemi-mat hemi.mat \
  --apply-calib 1
```

Notes:
- The CLI filters out overlay PNGs and keeps every other file (MATLAB `1:2:end`).
- AP values are read from `<animal>_lin.xml` in `--xml-dir`, following MATLAB trimming logic.
- Hemisphere splitting uses `hemi.mat` if available; otherwise falls back to `Hemi='both'`.
- Calibration:
  - `--apply-calib 0`: no calibration (raw intensities).
  - `--apply-calib 1`: expects MAT with `Calibration` and `Blank` arrays (`--calib-path`).
  - `--apply-calib 2`: expects MAT with struct `calibration` (slope_ratio, offset).
- Parquet columns mirror MATLAB outputs, including pixel-level lists (`fp`, `tau_values`, `PixelValues`, `bbox`).

Parity testing:
1) Run MATLAB pipeline to get `GluA2_round_<n>.parquet`.
2) Run the Python CLI on the same inputs.
3) Compare with `python compare_outputs.py --matlab path\to\matlab.parquet --python path\to\python.parquet`.
