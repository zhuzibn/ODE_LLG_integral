# LLGS Benchmarks

These benchmarks compare deterministic trajectories from the canonical
`rk4_4llg_solver(cfg)` nested-parameter API against frozen reference outputs.
All three cases run for 6 ns with a 5 ps timestep.

## Generate Current Results

From MATLAB at the repository root:

```matlab
addpath('benchmarks')
run_all_benchmarks
```

The runner writes `.mat` files to `benchmarks/current/`. Each file contains `tt`, `mmx`, `mmy`, `mmz`, `final_m`, `max_norm_error`, and `metadata`.

It also writes one PNG per case to `benchmarks/reports/`. Each figure plots
`m_x`, `m_y`, and `m_z` together against time in nanoseconds.

## Create Frozen Baselines

After reviewing the generated current results, copy the accepted `.mat` files into `benchmarks/baseline/` manually. The runner never updates baselines automatically.

## Compare Against Baseline

```matlab
addpath('benchmarks')
compare_to_baseline
```

The default tolerance is `1e-10`. For an intentional numerical refactor, use:

```matlab
compare_to_baseline(1e-6)
```
