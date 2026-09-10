function tests = test_llgs_consistency
%TEST_LLGS_CONSISTENCY LLGS algebra, torque gating, and unit-vector tests.
tests = functiontests(localfunctions);
end

function testExplicitLLMatchesImplicitGilbert(testCase)
alpha = 0.17;
gamma = physical_constants().gam;
m = [0.2, -0.3, sqrt(0.87)];
field = [0.4, -0.2, 0.7];
p_sot = [0, 1, 0];
p_stt = [1, 0, 0];
sot_dlt = 0.031;
sot_flt = -0.014;
stt_dlt = 0.022;
stt_flt = 0.009;

gilbert_rhs = -cross(m, field) ...
    - stt_dlt*cross(m, cross(m, p_stt)) ...
    + stt_flt*cross(m, p_stt) ...
    - sot_dlt*cross(m, cross(m, p_sot)) ...
    + sot_flt*cross(m, p_sot);
cross_m = [0, -m(3), m(2); m(3), 0, -m(1); -m(2), m(1), 0];
expected = (eye(3) - alpha*cross_m) \ (gamma*gilbert_rhs(:));

explicit = gamma/(1 + alpha^2)*LLG_solver(alpha, m, field, p_sot, ...
    p_stt, stt_dlt, stt_flt, sot_dlt, sot_flt);
verifyEqual(testCase, explicit(:), expected, 'RelTol', 1e-14);
end

function testSttFlagsAreIndependent(testCase)
ratio = -0.3;
base = expected_stt_base();
for dlt_enabled = 0:1
    for flt_enabled = 0:1
        [stt_dlt, stt_flt, ~, ~] = torque_coefficients( ...
            dlt_enabled, flt_enabled, 0, 0, ratio, 0.5);
        verifyEqual(testCase, stt_dlt, dlt_enabled*base, 'RelTol', 1e-14);
        verifyEqual(testCase, stt_flt, flt_enabled*ratio*base, ...
            'RelTol', 1e-14);
    end
end
end

function testSotFlagsAreIndependent(testCase)
ratio = 0.5;
base = expected_sot_base();
for dlt_enabled = 0:1
    for flt_enabled = 0:1
        [~, ~, sot_dlt, sot_flt] = torque_coefficients( ...
            0, 0, dlt_enabled, flt_enabled, -0.3, ratio);
        verifyEqual(testCase, sot_dlt, dlt_enabled*base, 'RelTol', 1e-14);
        verifyEqual(testCase, sot_flt, flt_enabled*ratio*base, ...
            'RelTol', 1e-14);
    end
end
end

function testNonUnitVectorsAreRejected(testCase)
paths = { ...
    {'initial', 'magnetization'}, ...
    {'torques', 'stt', 'polarization'}, ...
    {'torques', 'stt', 'pinned_magnetization'}, ...
    {'torques', 'sot', 'polarization'}};
identifiers = { ...
    'rk4_4llg:InvalidInitialMagnetization', ...
    'rk4_4llg:InvalidPolSTT', ...
    'rk4_4llg:InvalidPinnedLayerMagnetization', ...
    'rk4_4llg:InvalidPolSOT'};
for idx = 1:numel(paths)
    cfg = default_params();
    cfg = setfield(cfg, paths{idx}{:}, [2, 0, 0]); %#ok<SFLD>
    verifyError(testCase, @() validate_params(cfg), identifiers{idx});
end
end

function [stt_dlt, stt_flt, sot_dlt, sot_flt] = torque_coefficients( ...
        stt_dlt_enabled, stt_flt_enabled, sot_dlt_enabled, ...
        sot_flt_enabled, stt_ratio, sot_ratio)
config = make_config(struct( ...
    'STT_DLT', stt_dlt_enabled, 'STT_FLT', stt_flt_enabled, ...
    'SOT_DLT', sot_dlt_enabled, 'SOT_FLT', sot_flt_enabled));
[~, stt_dlt, stt_flt, sot_dlt, sot_flt] = field_eta( ...
    [1, 0, 0], 0, zeros(3), [0, 0, 0], 1e11, ...
    1e-9, 1000, sot_ratio, zeros(3), [0, 0, 1], 0.4, ...
    1e-9, 1e-9, stt_ratio, 0.2, 1e-9, 1e-9, 2e11, ...
    0, 0.02, 1e-12, config, physical_constants());
end

function base = expected_stt_base()
constants = physical_constants();
reference_current = 2*1e-9*(1000*1e3) ...
    / constants.hbar_over_e_eVs_or_Js_per_C;
efficiency = 0.4/(1 + 0.4^2*dot([1, 0, 0], [0, 0, 1]));
base = 1e11/reference_current*efficiency;
end

function base = expected_sot_base()
constants = physical_constants();
reference_current = 2*1e-9*(1000*1e3) ...
    / constants.hbar_over_e_eVs_or_Js_per_C;
base = 0.2*2e11/reference_current;
end
