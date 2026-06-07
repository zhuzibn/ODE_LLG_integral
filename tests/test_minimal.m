function tests = test_minimal
%TEST_MINIMAL Minimal deterministic tests for C1, C4, and C5.
tests = functiontests(localfunctions);
end

function testZeroCurrentNormConservation(testCase)
% C1: isolate deterministic field-driven dynamics over a short interval.
cfg = validConfiguration();
cfg.runtime = 100e-12;
cfg.tstep = 1e-12;
cfg.jc_STT = 0;
cfg.jc_SOT = 0;
cfg.STT_DLT = 0;
cfg.STT_FLT = 0;
cfg.SOT_DLT = 0;
cfg.SOT_FLT = 0;
cfg.thermalnois = 0;

trajectory = runSolver(cfg);
norm_error = abs(vecnorm(trajectory, 2, 2) - 1);

% rk4_4llg normalizes every stored state, so only roundoff is expected.
verifyLessThanOrEqual(testCase, max(norm_error), 1e-12);
end

function testMsUnitConversion(testCase)
% C4: Ms is entered in emu/cm3 and converted to A/m with Ms * 1e3.
Ms = 1000;
mu_0 = 1.25663706143592e-6;
expected_tesla = mu_0 * (Ms * 1e3);

% A unit x demag factor isolates the x-directed demagnetization field.
[hh, ~, ~, ~, ~] = field_eta( ...
    [1, 0, 0], 0, diag([1, 0, 0]), [0, 0, 0], 0, ...
    1e-9, Ms, 0, zeros(3), [0, 0, 1], 0.4, 1e-9, 1e-9, 0, ...
    0, 1e-9, 1e-9, 0, 0, 0, 1e-12, ...
    make_config(struct('STT_DLT', 0)), physical_constants());

verifyEqual(testCase, 4 * pi * Ms * 1e-4, expected_tesla, ...
    'RelTol', 1e-12);
verifyEqual(testCase, hh(1), -4 * pi * Ms * 1e-4, ...
    'RelTol', 1e-12);
end

function testSttTorqueCoefficientScale(testCase)
% C4: choose perpendicular free/pinned moments so dot(m, mPL) is zero.
mmm = [1, 0, 0];
mmmPL = [0, 0, 1];
jc_STT = 1e11;
tFL = 1e-9;
Ms = 1000;
PolFL = 0.4;
hbar = 6.58211951440e-16;

[~, sttdlt, sttflt, sotdlt, sotflt] = field_eta( ...
    mmm, 0, zeros(3), [0, 0, 0], jc_STT, ...
    tFL, Ms, 0, zeros(3), mmmPL, PolFL, 1e-9, 1e-9, 0, ...
    0, 1e-9, 1e-9, 0, 0, 0, 1e-12, ...
    make_config(), physical_constants());

% Reproduce the existing field_eta TMR efficiency and Jp expressions.
expected_efficiency = PolFL / (1 + PolFL^2 * dot(mmm, mmmPL));
expected_sttdlt = jc_STT / (2 * tFL * (Ms * 1e3) / hbar) ...
    * expected_efficiency;

verifyEqual(testCase, sttdlt, expected_sttdlt, 'RelTol', 1e-12);
verifyEqual(testCase, sttflt, 0, 'AbsTol', 0);
verifyEqual(testCase, sotdlt, 0, 'AbsTol', 0);
verifyEqual(testCase, sotflt, 0, 'AbsTol', 0);
end

function testInvalidIMAPMA(testCase)
% C5: geometry mode must be exactly 1 (IMA) or 2 (PMA).
cfg = validConfiguration();
cfg.IMAPMA = 3;
verifyError(testCase, @() runSolver(cfg), 'rk4_4llg:InvalidIMAPMA');
end

function testNegativeTstep(testCase)
% C5: integration cannot proceed with a nonpositive timestep.
cfg = validConfiguration();
cfg.tstep = -1e-12;
verifyError(testCase, @() runSolver(cfg), 'rk4_4llg:InvalidTstep');
end

function testNegativeTFL(testCase)
% C5: layer thickness enters torque and thermal-field denominators.
cfg = validConfiguration();
cfg.tFL = -1e-9;
verifyError(testCase, @() runSolver(cfg), 'rk4_4llg:InvalidTFL');
end

function testBadInitialMagnetization(testCase)
% C5: a zero vector cannot be normalized into a magnetization direction.
cfg = validConfiguration();
cfg.m_init = [0, 0, 0];
verifyError(testCase, @() runSolver(cfg), ...
    'rk4_4llg:ZeroInitialMagnetization');
end

function trajectory = runSolver(cfg)
params = rmfield(cfg, { ...
    'IMAPMA', 'STT_DLT', 'STT_FLT', 'SOT_DLT', 'SOT_FLT', ...
    'dipolee', 'thermalnois', 'dimensionlessLLG'});
params.config = make_config(struct( ...
    'IMAPMA', cfg.IMAPMA, ...
    'STT_DLT', cfg.STT_DLT, ...
    'STT_FLT', cfg.STT_FLT, ...
    'SOT_DLT', cfg.SOT_DLT, ...
    'SOT_FLT', cfg.SOT_FLT, ...
    'dipolee', cfg.dipolee, ...
    'thermalnois', cfg.thermalnois, ...
    'dimensionlessLLG', cfg.dimensionlessLLG));
params.constants = physical_constants();
[~, mmx, mmy, mmz] = rk4_4llg_solver(params);
trajectory = [mmx(:), mmy(:), mmz(:)];
end

function cfg = validConfiguration()
% Return the smallest complete, deterministic PMA configuration accepted by
% rk4_4llg. Individual validation tests override one field at a time.
cfg.runtime = 100e-12;
cfg.tstep = 1e-12;
cfg.Ms = 1000;
cfg.tFL = 0.6e-9;
cfg.alp = 0.01;
cfg.IMAPMA = 2;
cfg.m_init = [sqrt(0.5), 0, sqrt(0.5)];
cfg.Demag_ = diag([0.02, 0.02, 0.96]);
cfg.jc_STT = 0;
cfg.jc_SOT = 0;
cfg.Hext = [0, 0, 0];
cfg.PolSTT = [0, 0, 1];
cfg.polSOT = [0, 1, 0];
cfg.mmmPL = [0, 0, 1];
cfg.dimensionlessLLG = 0;
cfg.Hk = 4 * pi * 1600 * 1e-4;
cfg.LFL = 50e-9;
cfg.WFL = 50e-9;
cfg.facFLT_SHE = 0;
cfg.K12Dipole = zeros(3);
cfg.PolFL = 0.4;
cfg.facFLT_STT = 0;
cfg.thetaSH = 0.2;
cfg.tHM = 2e-9;
cfg.lambdaSF = 5e-9;
cfg.TT = 300;
cfg.thermalnois = 0;
cfg.STT_DLT = 0;
cfg.STT_FLT = 0;
cfg.SOT_DLT = 0;
cfg.SOT_FLT = 0;
cfg.dipolee = 0;
end
