# LLGS Benchmarks

These benchmarks freeze deterministic trajectories from the original LLGS scripts without modifying the solver files.

## Generate Current Results

From MATLAB at the repository root:

```matlab
addpath('benchmarks')
run_all_benchmarks
```

The runner writes `.mat` files to `benchmarks/current/`. Each file contains `tt`, `mmx`, `mmy`, `mmz`, `final_m`, `max_norm_error`, and `metadata`.

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
