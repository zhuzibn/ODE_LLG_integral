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
cfg = benchmark_params(case_name);
cfg.solver.runtime = runtime;
cfg.solver.tstep = tstep;
cfg.material.Ms = Ms;
cfg.material.damping = alp;
cfg.geometry.LFL = LFL;
cfg.geometry.WFL = WFL;
cfg.geometry.tFL = tFL;
cfg.geometry.LHM = LHM;
cfg.geometry.WHM = WHM;
cfg.geometry.tHM = tHM;
cfg.fields.Hk = Hk;
cfg.fields.external = Hext;
cfg.fields.demag_tensor = Demag_;
cfg.fields.dipole_tensor = K12Dipole;
cfg.torques.stt.current_density = jc_STT;
cfg.torques.stt.free_layer_polarization = PolFL;
cfg.torques.stt.polarization = PolSTT;
cfg.torques.stt.pinned_magnetization = mmmPL;
cfg.torques.stt.field_like_ratio = facFLT_STT;
cfg.torques.sot.current_density = jc_SOT;
cfg.torques.sot.spin_hall_angle = thetaSH;
cfg.torques.sot.spin_diffusion_length = lambdaSF;
cfg.torques.sot.polarization = polSOT;
cfg.torques.sot.field_like_ratio = facFLT_SHE;
cfg.thermal.temperature = TT;
cfg.initial.magnetization = m_init;
cfg.output.plot = 0;

[tt, mmx, mmy, mmz] = rk4_4llg_solver(cfg);

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
metadata.parameters.thermalnois = cfg.thermal.enabled;
metadata.parameters.dimensionlessLLG = cfg.solver.dimensionless;

result = struct();
result.tt = tt;
result.mmx = mmx;
result.mmy = mmy;
result.mmz = mmz;
result.final_m = final_m;
result.max_norm_error = max(norm_error);
result.metadata = metadata;
end

function cfg = benchmark_params(case_name)
cfg = default_params();
switch case_name
    case 'pma_relax_no_current'
        cfg.torques.stt.damping_like_enabled = 0;
    case 'pma_stt_current'
    case 'pma_sot_current'
        cfg.torques.stt.damping_like_enabled = 0;
        cfg.torques.sot.damping_like_enabled = 1;
    otherwise
        error('ODE_LLG_integral:UnknownBenchmarkCase', ...
            'Unknown benchmark case "%s".', case_name);
end
end
