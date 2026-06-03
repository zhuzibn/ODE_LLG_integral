# AGENTS.md — ODE_LLG_integral

## Project purpose
This repository contains MATLAB macrospin code for integrating LLGS / LLG dynamics with STT and SOT torque terms.

## Scientific rules
- Treat this as scientific research code, not a generic software project.
- Do not change physics formulas unless you can derive and explain the change.
- Preserve the LLGS sign convention unless explicitly justified.
- Check dimensional consistency: Tesla, A/m2, emu/cm3 to A/m, seconds, nanoseconds.
- Check that magnetization remains normalized.
- Distinguish code-quality improvements from physics-model changes.
- When proposing a physics change, cite the exact file/line and explain the expected effect.

## Repository structure
- main_sample.m: example driver; copy to main.m for runs.
- conf_file_sample.m: configuration template; copy to conf_file.m.
- LLG_solver.m: LLGS right-hand side.
- field_eta.m: effective field and torque coefficient calculation.
- rk4_4llg.m: RK4 time integration loop.

## Safety rules
- First perform read-only analysis.
- Do not modify files until asked.
- Before editing, produce a prioritized plan.
- Keep all changes on a new git branch.
- After edits, show `git diff` and explain every change.
- Prefer adding tests/examples/documentation before refactoring physics.

## Benchmark regression rule

Before modifying scientific code, inspect the frozen baseline in `benchmarks/baseline/`.

After any change to:
- LLG_solver.m
- field_eta.m
- rk4_4llg.m
- conf_file_sample.m
- benchmark case parameters

run:

```bash
matlab -batch "run('benchmarks/run_all_benchmarks.m'); run('benchmarks/compare_to_baseline.m')"
```

Rules:

- Do not update `benchmarks/baseline/*.mat` unless the user explicitly says to accept new physics/numerics.
- Report benchmark comparison before summarizing code changes.
- If results differ, classify the difference as:
  1. expected numerical roundoff,
  2. expected behavior change,
  3. unexpected regression.
- For code-quality-only changes, the strict tolerance is `1e-10`.
- For intentional numerical refactors, ask before relaxing tolerance.

## Source Code Changes

### 2026-06-03 — Benchmark harness for deterministic LLGS regression checks
- Added `benchmarks/run_all_benchmarks.m` to run fixed PMA benchmark cases from isolated case directories, seed MATLAB with `rng(1, 'twister')`, call the original `rk4_4llg.m` script, and save deterministic current outputs containing `tt`, `mmx`, `mmy`, `mmz`, `final_m`, `max_norm_error`, and metadata.
- Added `benchmarks/compare_to_baseline.m` to compare `benchmarks/current/*.mat` against manually frozen files in `benchmarks/baseline/*.mat` using a strict default tolerance of `1e-10`, with optional relaxed tolerance such as `compare_to_baseline(1e-6)`.
- Added three benchmark cases under `benchmarks/cases/`: `pma_relax_no_current`, `pma_stt_current`, and `pma_sot_current`, each with its own local `conf_file.m` and `params.m`.
- Added `benchmarks/README.md` and placeholder files for the `benchmarks/current/` and `benchmarks/baseline/` directories.
- Prevention: keep benchmark baselines frozen by copying reviewed current `.mat` files into `benchmarks/baseline/` manually only after intentional review; do not have the runner overwrite baseline files automatically.
