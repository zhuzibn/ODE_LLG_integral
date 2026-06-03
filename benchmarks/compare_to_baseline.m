function summary = compare_to_baseline(tol)
%COMPARE_TO_BASELINE Compare current benchmark outputs with frozen baseline.
%
% Usage:
%   compare_to_baseline()       % strict default tolerance, 1e-10
%   compare_to_baseline(1e-6)   % relaxed tolerance for intentional refactors

if nargin < 1 || isempty(tol)
    tol = 1e-10;
end

bench_root = fileparts(mfilename('fullpath'));
current_root = fullfile(bench_root, 'current');
baseline_root = fullfile(bench_root, 'baseline');

current_files = dir(fullfile(current_root, '*.mat'));
if isempty(current_files)
    error('No current benchmark files found in %s. Run run_all_benchmarks first.', current_root);
end

summary = struct([]);

fprintf('Tolerance: %.3g\n', tol);
fprintf('%-24s %14s %14s %14s %14s %8s\n', ...
    'case name', 'max abs err', 'rms err', 'final diff', 'max norm err', 'pass');
fprintf('%-24s %14s %14s %14s %14s %8s\n', ...
    repmat('-', 1, 24), repmat('-', 1, 14), repmat('-', 1, 14), ...
    repmat('-', 1, 14), repmat('-', 1, 14), repmat('-', 1, 8));

for idx = 1:numel(current_files)
    current_file = fullfile(current_root, current_files(idx).name);
    baseline_file = fullfile(baseline_root, current_files(idx).name);
    [~, case_name] = fileparts(current_files(idx).name);

    if ~exist(baseline_file, 'file')
        summary(idx) = failed_row(case_name, NaN, NaN, NaN, NaN, false); %#ok<AGROW>
        fprintf('%-24s %14s %14s %14s %14s %8s\n', ...
            case_name, 'missing', 'missing', 'missing', 'missing', 'FAIL');
        continue;
    end

    current = load(current_file);
    baseline = load(baseline_file);

    current_traj = [current.mmx(:), current.mmy(:), current.mmz(:)];
    baseline_traj = [baseline.mmx(:), baseline.mmy(:), baseline.mmz(:)];

    if ~isequal(size(current_traj), size(baseline_traj)) || ~isequal(size(current.tt), size(baseline.tt))
        summary(idx) = failed_row(case_name, NaN, NaN, NaN, current.max_norm_error, false); %#ok<AGROW>
        fprintf('%-24s %14s %14s %14s %14.6e %8s\n', ...
            case_name, 'size mismatch', 'size mismatch', 'size mismatch', current.max_norm_error, 'FAIL');
        continue;
    end

    trajectory_delta = current_traj - baseline_traj;
    max_abs_trajectory_error = max(abs(trajectory_delta(:)));
    rms_trajectory_error = sqrt(mean(trajectory_delta(:).^2));
    final_m_diff = norm(current.final_m(:) - baseline.final_m(:));
    max_norm_error = current.max_norm_error;

    passed = max_abs_trajectory_error <= tol && ...
        rms_trajectory_error <= tol && ...
        final_m_diff <= tol && ...
        max_norm_error <= tol;

    summary(idx).case_name = case_name; %#ok<AGROW>
    summary(idx).max_abs_trajectory_error = max_abs_trajectory_error; %#ok<AGROW>
    summary(idx).rms_trajectory_error = rms_trajectory_error; %#ok<AGROW>
    summary(idx).final_m_diff = final_m_diff; %#ok<AGROW>
    summary(idx).max_norm_error = max_norm_error; %#ok<AGROW>
    summary(idx).passed = passed; %#ok<AGROW>

    fprintf('%-24s %14.6e %14.6e %14.6e %14.6e %8s\n', ...
        case_name, max_abs_trajectory_error, rms_trajectory_error, ...
        final_m_diff, max_norm_error, pass_label(passed));
end

if any(~[summary.passed])
    error('One or more benchmark comparisons failed.');
end
end

function row = failed_row(case_name, max_abs_trajectory_error, rms_trajectory_error, final_m_diff, max_norm_error, passed)
row = struct();
row.case_name = case_name;
row.max_abs_trajectory_error = max_abs_trajectory_error;
row.rms_trajectory_error = rms_trajectory_error;
row.final_m_diff = final_m_diff;
row.max_norm_error = max_norm_error;
row.passed = passed;
end

function label = pass_label(passed)
if passed
    label = 'PASS';
else
    label = 'FAIL';
end
end
