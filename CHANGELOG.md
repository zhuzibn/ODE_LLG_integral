## Source Code Changes

### 2026-06-05 — Fail early on invalid RK4 configuration

- Added pre-integration validation in `rk4_4llg.m` for required scalar values, magnetization/current vector shapes, `IMAPMA`, demagnetization tensor shape, and nonzero initial magnetization norm.
- Kept numerical integration, LLGS formulas, torque signs, thermal-noise handling, and RK4 stage logic unchanged.
- Prevention: keep configuration validation before any integration setup or field evaluation so invalid inputs fail with explicit identifiers instead of producing late dimension or numerical errors.

### 2026-06-04 — Fix RK4 time grid off-by-one

- Removed the redundant caller-side totstep assignment from main.m; rk4_4llg.m now owns n_steps and stored sample count calculation.
- Updated `rk4_4llg.m` to define integration intervals with `n_steps = round(runtime / tstep)` and stored samples with `totstep = n_steps + 1`.
- Replaced the `linspace` time grid with `tt = (0:n_steps)' * tstep`, stores the initial magnetization at index 1, and advances the RK loop exactly `n_steps` times so `tt`, `mmx`, `mmy`, and `mmz` have matching lengths.
- Left LLGS formulas, torque signs, thermal-noise calls, and the RK4 stage logic unchanged.
- Prevention: keep integration interval count and stored sample count as separate variables in future timestep changes, and run the benchmark comparison after edits to `rk4_4llg.m`.

### 2026-06-03 — Ignore generated benchmark outputs

- Added a root `.gitignore` to keep generated benchmark outputs under `benchmarks/current/` and `benchmarks/reports/` out of version control.
- Included standard transient-tool ignore entries for `.sisyphus/`, `.ruff_cache/`, and `**/__pycache__/`.
- Prevention: keep generated benchmark results and reports untracked unless a future task explicitly calls for committing reviewed artifacts.

### 2026-06-03 — Benchmark harness for deterministic LLGS regression checks

- Added `benchmarks/run_all_benchmarks.m` to run fixed PMA benchmark cases from isolated case directories, seed MATLAB with `rng(1, 'twister')`, call the original `rk4_4llg.m` script, and save deterministic current outputs containing `tt`, `mmx`, `mmy`, `mmz`, `final_m`, `max_norm_error`, and metadata.
- Added `benchmarks/compare_to_baseline.m` to compare `benchmarks/current/*.mat` against manually frozen files in `benchmarks/baseline/*.mat` using a strict default tolerance of `1e-10`, with optional relaxed tolerance such as `compare_to_baseline(1e-6)`.
- Added three benchmark cases under `benchmarks/cases/`: `pma_relax_no_current`, `pma_stt_current`, and `pma_sot_current`, each with its own local `conf_file.m` and `params.m`.
- Added `benchmarks/README.md` and placeholder files for the `benchmarks/current/` and `benchmarks/baseline/` directories.
- Prevention: keep benchmark baselines frozen by copying reviewed current `.mat` files into `benchmarks/baseline/` manually only after intentional review; do not have the runner overwrite baseline files automatically.
