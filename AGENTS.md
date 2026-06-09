# AGENTS.md — ODE_LLG_integral

## Project purpose

This repository contains MATLAB macrospin code for integrating LLGS / LLG dynamics with STT and SOT torque terms.

Treat this as scientific research code, not a generic software project. Numerical correctness and physical consistency are more important than broad refactoring.

## Scientific rules

- Do not change physics formulas unless explicitly asked, or unless you can derive and explain the change.
- Preserve the existing LLGS sign convention unless explicitly justified.
- Check dimensional consistency for units such as Tesla, A/m^2, emu/cm^3 to A/m, seconds, and nanoseconds.
- Check that magnetization remains normalized when relevant.
- Distinguish code-quality improvements from physics-model changes.
- When proposing a physics change, cite the exact file/function/line region and explain the expected effect.
- Prefer tests, examples, comments, and unit documentation before refactoring scientific formulas.

## Repository structure

- `main_sample.m`: example driver; use as a template for local runs.
- `conf_file_sample.m`: configuration template; use as a template for local runs.
- `LLG_solver.m`: LLGS right-hand side.
- `field_eta.m`: effective field and torque coefficient calculation.
- `rk4_4llg.m`: RK4 time integration loop.
- `benchmarks/`: deterministic regression benchmark harness.
- `benchmarks/baseline/`: frozen benchmark reference outputs.

Do not overwrite a user's existing `main.m` or `conf_file.m` unless explicitly asked.

## Workflow rules

- For investigation or review tasks, first perform read-only analysis.
- For code-changing tasks, inspect the relevant files before editing.
- Before non-trivial edits, produce a short prioritized plan with verification steps.
- Use a new task branch for non-trivial changes unless already on an appropriate branch.
- Do not create commits, push, or open pull requests unless explicitly asked.
- Keep edits surgical and directly tied to the user's request.
- Preserve the existing MATLAB code style.
- Do not replace existing solvers or rewrite large files unless requested.
- Do not run broad formatters or line-ending normalization unless explicitly requested.
- After edits, inspect `git diff --stat` and `git diff --check`.
- Summarize the diff and explain every changed file. Show the full diff only if requested.

## Safety rules

- Do not change LLGS equations or physical formulas unless explicitly asked.
- For numerical changes, run the relevant validation script if available.
- Document physical units for newly added parameters.
- If unexpected benchmark or numerical changes appear, stop and report them before continuing.
- If MATLAB is unavailable in the current environment, report that clearly instead of claiming benchmark results.

## Benchmark regression rule

Before modifying scientific code, inspect the frozen baseline in `benchmarks/baseline/`.

After any change to:

- `LLG_solver.m`
- `field_eta.m`
- `rk4_4llg.m`
- `conf_file_sample.m`
- benchmark case parameters

run:

```bash
matlab -batch "run('benchmarks/run_all_benchmarks.m'); run('benchmarks/compare_to_baseline.m')"
```

If `matlab` is not on `PATH`, check whether MATLAB is available through the local environment. If it is still unavailable, report that the benchmark could not be run.

Rules:

- Do not update `benchmarks/baseline/*.mat` unless the user explicitly says to accept new physics or new numerics.
- Report benchmark comparison before summarizing code changes.
- If results differ, classify the difference as:
  1. expected numerical roundoff,
  2. expected behavior change,
  3. unexpected regression.
- For code-quality-only changes, the strict tolerance is `1e-10`.
- For intentional numerical refactors, ask before relaxing tolerance.

## Code improvement rule

- The required improvements are listed in `fix.md`.
- For tasks that implement items from `fix.md`, mark the corresponding items as done after the code improvement is complete and verified.
- Do not mark unrelated `fix.md` items as done.
- If an item in `fix.md` is ambiguous, explain the ambiguity before changing code.
