function tests = test_parameter_interface
%TEST_PARAMETER_INTERFACE Canonical and legacy LLGS parameter API tests.
tests = functiontests(localfunctions);
end

function testDefaultParamsIsCompleteAndValid(testCase)
cfg = default_params();
verifyWarningFree(testCase, @() validate_params(cfg));
verifyEqual(testCase, fieldnames(cfg), { ...
    'material'; 'geometry'; 'solver'; 'fields'; 'torques'; ...
    'thermal'; 'initial'; 'output'});
end

function testNestedDefaultsMatchOldEffectiveDefaults(testCase)
cfg = default_params();
legacy = old_default_params();
[compute, constants] = normalize_params(cfg);

legacy = rmfield(legacy, {'constants'});
verifyEqual(testCase, compute, legacy);
verifyEqual(testCase, constants, physical_constants());
end

function testNestedSolverNeedsNoCallerConstants(testCase)
cfg = default_params(struct( ...
    'solver', struct('runtime', 20e-12, 'tstep', 5e-12), ...
    'output', struct('plot', 0)));
[tt, mmx, mmy, mmz] = rk4_4llg_solver(cfg);
verifySize(testCase, [tt, mmx, mmy, mmz], [5, 4]);
end

function testNestedAndLegacyTrajectoriesMatch(testCase)
cfg = default_params(struct( ...
    'solver', struct('runtime', 200e-12, 'tstep', 5e-12), ...
    'fields', struct('external', [20e-3, 0, 0]), ...
    'torques', struct('stt', struct('current_density', 5e10)), ...
    'output', struct('plot', 0)));
legacy = old_default_params();
legacy.runtime = cfg.solver.runtime;
legacy.tstep = cfg.solver.tstep;
legacy.Hext = cfg.fields.external;
legacy.jc_STT = cfg.torques.stt.current_density;

[tt_new, x_new, y_new, z_new] = rk4_4llg_solver(cfg);
[tt_old, x_old, y_old, z_old] = rk4_4llg_solver(legacy);
verifyEqual(testCase, tt_new, tt_old, 'AbsTol', 0);
verifyEqual(testCase, x_new, x_old, 'AbsTol', 1e-12);
verifyEqual(testCase, y_new, y_old, 'AbsTol', 1e-12);
verifyEqual(testCase, z_new, z_old, 'AbsTol', 1e-12);
end

function testUnknownOverrideFieldFails(testCase)
verifyError(testCase, ...
    @() default_params(struct('solver', struct('tstepp', 1e-12))), ...
    'LLGSParams:UnknownField');
end

function testUnknownAndMissingNestedFieldsFail(testCase)
cfg = default_params();
cfg.material.extra = 1;
verifyError(testCase, @() validate_params(cfg), ...
    'LLGSParams:UnknownField');

cfg = default_params();
cfg.fields = rmfield(cfg.fields, 'external');
verifyError(testCase, @() validate_params(cfg), ...
    'LLGSParams:MissingField');
end

function testInvalidScalarTypeAndNonfiniteFail(testCase)
cfg = default_params();
cfg.material.Ms = '1000';
verifyError(testCase, @() validate_params(cfg), 'rk4_4llg:InvalidMs');

cfg = default_params();
cfg.torques.sot.current_density = Inf;
verifyError(testCase, @() validate_params(cfg), ...
    'rk4_4llg:InvalidJcSOT');
end

function testInvalidVectorAndTensorShapesFail(testCase)
cfg = default_params();
cfg.fields.external = [0, 0];
verifyError(testCase, @() validate_params(cfg), 'rk4_4llg:InvalidHext');

cfg = default_params();
cfg.fields.dipole_tensor = zeros(2, 2);
verifyError(testCase, @() validate_params(cfg), ...
    'LLGSParams:InvalidValue');
end

function testInvalidSelectionsAndFlagsFail(testCase)
cfg = default_params();
cfg.solver.method = 'euler';
verifyError(testCase, @() validate_params(cfg), ...
    'LLGSParams:InvalidValue');

cfg = default_params();
cfg.fields.anisotropy_mode = 3;
verifyError(testCase, @() validate_params(cfg), ...
    'rk4_4llg:InvalidIMAPMA');

cfg = default_params();
cfg.thermal.enabled = 2;
verifyError(testCase, @() validate_params(cfg), ...
    'LLGSParams:InvalidValue');
end

function testFeatureDependentValuesFailBeforeIntegration(testCase)
cfg = default_params();
cfg.solver.dimensionless = 1;
verifyError(testCase, @() rk4_4llg_solver(cfg), ...
    'rk4_4llg:InvalidGFactor');

cfg = default_params();
cfg.thermal.enabled = 1;
cfg.geometry.LFL = 0;
verifyError(testCase, @() rk4_4llg_solver(cfg), ...
    'LLGSParams:InvalidValue');
end

function params = old_default_params()
cfg = make_config();
params = struct( ...
    'runtime', 10e-9, 'tstep', 5e-12, 'Ms', 1000, 'tFL', 0.6e-9, ...
    'alp', 0.01, 'm_init', [sin(pi / 4), 0, cos(pi / 4)], ...
    'Demag_', diag([0.01968237864387906, ...
        0.01968237864387906, 0.960635227939411]), ...
    'jc_STT', 0e10, 'jc_SOT', 0e10, 'Hext', [0, 0, 0], ...
    'PolSTT', [0, 0, 1], 'polSOT', [0, 1, 0], ...
    'mmmPL', [0, 0, 1], 'Hk', 4 * pi * 1600 * 1e-4, ...
    'LFL', 50e-9, 'WFL', 50e-9, 'facFLT_SHE', 0, ...
    'K12Dipole', zeros(3), 'PolFL', 0.4, 'facFLT_STT', 0, ...
    'thetaSH', 0.2, 'tHM', 2e-9, 'lambdaSF', 5e-9, 'TT', 300, ...
    'config', cfg, 'constants', physical_constants());
end
