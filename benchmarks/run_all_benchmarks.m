function results = run_all_benchmarks()
%RUN_ALL_BENCHMARKS Generate current LLGS benchmark result files.
%
% The baseline directory is intentionally not modified by this harness.

repo_root = fileparts(fileparts(mfilename('fullpath')));
bench_root = fileparts(mfilename('fullpath'));
cases_root = fullfile(bench_root, 'cases');
current_root = fullfile(bench_root, 'current');

case_names = { ...
    'pma_relax_no_current', ...
    'pma_stt_current', ...
    'pma_sot_current' ...
    };

if ~exist(current_root, 'dir')
    mkdir(current_root);
end

addpath(repo_root);

results = struct([]);
for case_idx = 1:numel(case_names)
    case_name = case_names{case_idx};
    case_dir = fullfile(cases_root, case_name);
    out_file = fullfile(current_root, [case_name '.mat']);

    fprintf('Running %s...\n', case_name);
    result = run_one_case(repo_root, case_dir, case_name);
    save(out_file, '-struct', 'result');

    results(case_idx).case_name = case_name; %#ok<AGROW>
    results(case_idx).output_file = out_file; %#ok<AGROW>
    results(case_idx).final_m = result.final_m; %#ok<AGROW>
    results(case_idx).max_norm_error = result.max_norm_error; %#ok<AGROW>
end

fprintf('Saved %d benchmark result file(s) to %s\n', numel(case_names), current_root);
end

function result = run_one_case(repo_root, case_dir, case_name)
original_dir = pwd;
cleanup = onCleanup(@() cd(original_dir));

rng(1, 'twister');
addpath(repo_root);
cd(case_dir);

params();
config = benchmark_config(case_name);
params_struct = struct( ...
    'runtime', runtime, 'tstep', tstep, 'Ms', Ms, 'tFL', tFL, ...
    'alp', alp, 'm_init', m_init, 'Demag_', Demag_, ...
    'jc_STT', jc_STT, 'jc_SOT', jc_SOT, 'Hext', Hext, ...
    'PolSTT', PolSTT, 'polSOT', polSOT, 'mmmPL', mmmPL, ...
    'Hk', Hk, 'LFL', LFL, 'WFL', WFL, ...
    'facFLT_SHE', facFLT_SHE, 'K12Dipole', K12Dipole, ...
    'PolFL', PolFL, 'facFLT_STT', facFLT_STT, ...
    'thetaSH', thetaSH, 'tHM', tHM, 'lambdaSF', lambdaSF, ...
    'TT', TT, 'config', config, 'constants', physical_constants());

[tt, mmx, mmy, mmz] = rk4_4llg_solver(params_struct);

trajectory = [mmx(:), mmy(:), mmz(:)];
final_m = trajectory(end, :);
norm_error = abs(sqrt(sum(trajectory.^2, 2)) - 1);

metadata = struct();
metadata.case_name = case_name;
metadata.rng_seed = 1;
metadata.rng_algorithm = 'twister';
metadata.case_relative_path = fullfile('benchmarks', 'cases', case_name);
metadata.source_files = {'LLG_solver.m', 'field_eta.m', 'rk4_4llg_solver.m'};
metadata.output_fields = {'tt', 'mmx', 'mmy', 'mmz', 'final_m', 'max_norm_error', 'metadata'};
metadata.tolerance_default = 1e-10;

metadata.parameters = struct();
metadata.parameters.runtime = runtime;
metadata.parameters.tstep = tstep;
metadata.parameters.totstep = numel(tt);
metadata.parameters.m_init = m_init;
metadata.parameters.Ms = Ms;
metadata.parameters.alp = alp;
metadata.parameters.Hk = Hk;
metadata.parameters.Hext = Hext;
metadata.parameters.jc_STT = jc_STT;
metadata.parameters.jc_SOT = jc_SOT;
metadata.parameters.thetaSH = thetaSH;
metadata.parameters.thermalnois = config.thermalnois;
metadata.parameters.dimensionlessLLG = config.dimensionlessLLG;

result = struct();
result.tt = tt;
result.mmx = mmx;
result.mmy = mmy;
result.mmz = mmz;
result.final_m = final_m;
result.max_norm_error = max(norm_error);
result.metadata = metadata;
end

function config = benchmark_config(case_name)
switch case_name
    case 'pma_relax_no_current'
        overrides = struct('STT_DLT', 0);
    case 'pma_stt_current'
        overrides = struct();
    case 'pma_sot_current'
        overrides = struct('STT_DLT', 0, 'SOT_DLT', 1);
    otherwise
        error('ODE_LLG_integral:UnknownBenchmarkCase', ...
            'Unknown benchmark case "%s".', case_name);
end
config = make_config(overrides);
end
