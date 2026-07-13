## Source Code Changes

### 2026-07-13 — Migrate to one nested parameter interface

- Added `default_params()` as the complete canonical LLGS parameter factory, with documented dimensional units and strict recursive overrides that reject unknown fields.
- Added direct nested-schema and value validation before integration, including solver/flag selections and dimensionless/thermal feature dependencies.
- Kept historical flat `params`, `config`, `constants`, and optional `g` handling through one explicit compatibility adapter; no deprecation warning is emitted.
- Migrated `main.m`, tests, and the deterministic benchmark harness to the nested API while retaining `make_config()` only for legacy callers.
- Verified the full test suite and all frozen benchmark trajectories at the unchanged `1e-10` tolerance; LLGS formulas, torque signs, RK4 stages/arithmetic, stochastic behavior, time grid, normalization, defaults, and unit conventions were unchanged.
- Prevention: keep all public inputs in `default_params()`, validate before computation, and compare nested and legacy trajectories whenever the compatibility boundary changes.

### 2026-06-07 — Remove duplicate example driver

- Removed `main_sample.m` after verifying it was byte-for-byte identical to `main.m`.
- Kept `main.m` as the single editable example driver and updated the README accordingly.
- Prevention: maintain one canonical example driver so configuration and API migrations cannot leave duplicate copies out of sync.

### 2026-06-07 — Refactor configuration and RK4 interfaces without physics changes

- Added `make_config.m` and `physical_constants.m` to expose configuration flags and physical constants as explicit structs.
- Added callable `rk4_4llg_solver(params)` returning `tt`, `mmx`, `mmy`, and `mmz`.
- Removed hidden `conf_file` and `constantfile` execution from `field_eta.m`; configuration and constants are now explicit arguments supplied by the solver or direct tests.
- Clarified that the existing `6.58211951440e-16` torque coefficient is numerically hbar in eV.s, equivalently hbar/e in J.s/C, without changing its value or use.
- Migrated `main.m`, the deterministic benchmark harness, and tests to the callable struct-based API.
- Removed the root workspace compatibility scripts and benchmark case configuration scripts after all active callers were migrated.
- Factored the repeated field-plus-LLG RK stage evaluation into a local helper only after the benchmark comparison and all tests passed.
- Kept LLGS formulas, torque signs, unit conventions, RK4 stage states, arithmetic order, thermal-noise behavior, and frozen benchmark baselines unchanged.
- Prevention: keep physics inputs explicit at computational boundaries and require exact deterministic benchmark comparison plus the full test suite after future RK/config refactors.

### 2026-06-07 — Add minimal C1, C4, and C5 tests

- Added a deterministic zero-current, no-torque, no-noise test that checks magnetization norm conservation over a short run.
- Added unit tests for the existing `Ms` emu/cm3-to-A/m/Tesla conversion and a fixed-parameter STT coefficient scale.
- Added validation tests for invalid `IMAPMA`, negative `tstep`, negative `tFL`, and zero initial magnetization, checking the existing explicit error identifiers.
- Added `tests/run_all_tests.m` as the aggregate MATLAB test entry point; no LLGS formulas, RK4 logic, thermal-noise behavior, or benchmark baselines were changed.
- Added concise comments explaining each test's scientific intent, expected formula, validation condition, and script-workspace fixture.
- Prevention: run `matlab -batch "run('tests/run_all_tests.m')"` and the frozen benchmark comparison after changes affecting configuration, units, torque coefficients, or integration.

### 2026-06-07 — Stop tracking the local fix checklist

- Added `/fix.md` to `.gitignore` and removed the file from Git tracking while preserving the local working copy.
- Prevention: keep machine-local project checklists ignored so local status updates are not published unintentionally.

### 2026-06-05 — Pin text line-ending policy

- Added `.gitattributes` rules to disable Git text conversion for MATLAB (`*.m`) and Markdown (`*.md`) files, preserving their existing line endings byte-for-byte.
- Set local Git configuration to disable automatic platform-dependent line-ending conversion.
- Prevention: keep line-ending behavior explicit in `.gitattributes` so future comment and documentation edits do not create Git-induced CRLF/LF churn.

### 2026-06-05 — Document units and clean stale comments

- Added a `README.md` Units section covering seconds internally, optional ns plotting, Tesla fields, `Ms` entered as emu/cm3 and converted with `Ms*1e3`, A/m2 current density, and meter-scale layer dimensions.
- Corrected stale root MATLAB comments for normalized magnetization, meter dimensions, `tt` units, SOT/STT DLT versus FLT labels, and field-equivalent torque coefficient labels.
- Kept executable MATLAB formulas, benchmark baselines, LLGS signs, and RK4 logic unchanged.
- Prevention: keep the README Units section as the single convention reference and update comments when variables or plotting conversions change.

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

## Error Logs

### 2026-06-07 — Test fixture omitted physical constants

- The initial C1 test run failed because the script-based RK4 solver expected `gam` and the other values from `constantfile.m` in its caller workspace.
- Resolved by loading the existing `constantfile.m` from the test fixture before invoking `rk4_4llg.m`.
- Prevention: initialize both configuration values and project constants in fixtures that invoke workspace-dependent MATLAB scripts.
