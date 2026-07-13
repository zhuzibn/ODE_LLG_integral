% Resolve paths relative to this script so it works from any current folder.
repo_root = fileparts(fileparts(mfilename('fullpath')));
tests_root = fileparts(mfilename('fullpath'));

addpath(repo_root);
results = runtests(tests_root);
disp(results);

% Return a nonzero MATLAB batch status when any test fails.
assert(all([results.Passed]), 'ODE_LLG_integral:TestsFailed', ...
    'One or more tests failed.');
