function [tt, mmx, mmy, mmz] = rk4_4llg_solver(params)
%RK4_4LLG_SOLVER Integrate LLGS dynamics from explicit parameters.

validate_params(params);

runtime = params.runtime;
tstep = params.tstep;
alp = params.alp;
config = params.config;
constants = params.constants;
Hk = params.Hk;

if config.dimensionlessLLG
    Hk = [1 * (params.WFL < params.LFL) * Hk, ...
        1 * (params.WFL > params.LFL) * Hk, 0];
    tau_c = (params.g * Hk(2 * (params.WFL > params.LFL) ...
        + 1 * (params.WFL < params.LFL))) / (1 + alp^2);
    scal = 1;
else
    tau_c = 1;
    scal = constants.gam / (1 + alp^2);
end
ts1 = tstep * tau_c;

n_steps = round(runtime / tstep);
totstep = n_steps + 1;
tt = (0:n_steps)' * tstep;
mmx = zeros(totstep, 1);
mmy = zeros(totstep, 1);
mmz = zeros(totstep, 1);
mmx(1) = params.m_init(1);
mmy(1) = params.m_init(2);
mmz(1) = params.m_init(3);

for step_idx = 1:n_steps
    mm1 = [mmx(step_idx), mmy(step_idx), mmz(step_idx)];

    kk1 = evaluate_rhs(mm1, Hk, params, config, constants, scal);
    kk2 = evaluate_rhs(mm1 + kk1 * ts1 / 2, ...
        Hk, params, config, constants, scal);
    kk3 = evaluate_rhs(mm1 + kk2 * ts1 / 2, ...
        Hk, params, config, constants, scal);
    kk4 = evaluate_rhs(mm1 + kk3 * ts1, ...
        Hk, params, config, constants, scal);

    mn1 = mm1 + ts1 / 6 * (kk1 + 2 * kk2 + 2 * kk3 + kk4);
    mn1 = mn1 / norm(mn1);
    mmx(step_idx + 1) = mn1(1);
    mmy(step_idx + 1) = mn1(2);
    mmz(step_idx + 1) = mn1(3);
end
end

function kk = evaluate_rhs(mmm, Hk, params, config, constants, scal)
[hh, sttdlt, sttflt, sotdlt, sotflt] = field_eta( ...
    mmm, Hk, params.Demag_, params.Hext, params.jc_STT, ...
    params.tFL, params.Ms, params.facFLT_SHE, params.K12Dipole, ...
    params.mmmPL, params.PolFL, params.LFL, params.WFL, ...
    params.facFLT_STT, params.thetaSH, params.tHM, params.lambdaSF, ...
    params.jc_SOT, params.TT, params.alp, params.tstep, config, constants);
dmdt = LLG_solver(params.alp, mmm, hh, params.polSOT, params.PolSTT, ...
    sttdlt, sttflt, sotdlt, sotflt);
kk = scal * dmdt;
end

function validate_params(params)
required_fields = { ...
    'runtime', 'tstep', 'Ms', 'tFL', 'alp', 'm_init', 'Demag_', ...
    'jc_STT', 'jc_SOT', 'Hext', 'PolSTT', 'polSOT', 'mmmPL', ...
    'Hk', 'LFL', 'WFL', 'facFLT_SHE', 'K12Dipole', 'PolFL', ...
    'facFLT_STT', 'thetaSH', 'tHM', 'lambdaSF', 'TT', 'config', ...
    'constants'};
for idx = 1:numel(required_fields)
    name = required_fields{idx};
    if ~isfield(params, name)
        error('rk4_4llg:MissingParameter', ...
            'Missing required parameter "%s".', name);
    end
end

if ~(isscalar(params.runtime) && isnumeric(params.runtime) ...
        && isfinite(params.runtime) && params.runtime > 0)
    error('rk4_4llg:InvalidRuntime', ...
        'runtime must be a finite positive scalar.');
end
if ~(isscalar(params.tstep) && isnumeric(params.tstep) ...
        && isfinite(params.tstep) && params.tstep > 0)
    error('rk4_4llg:InvalidTstep', ...
        'tstep must be a finite positive scalar.');
end
if ~(isscalar(params.Ms) && isnumeric(params.Ms) ...
        && isfinite(params.Ms) && params.Ms > 0)
    error('rk4_4llg:InvalidMs', 'Ms must be a finite positive scalar.');
end
if ~(isscalar(params.tFL) && isnumeric(params.tFL) ...
        && isfinite(params.tFL) && params.tFL > 0)
    error('rk4_4llg:InvalidTFL', 'tFL must be a finite positive scalar.');
end
if ~(isscalar(params.alp) && isnumeric(params.alp) ...
        && isfinite(params.alp) && params.alp >= 0)
    error('rk4_4llg:InvalidAlpha', ...
        'alp must be a finite nonnegative scalar.');
end
if ~(isscalar(params.config.IMAPMA) && isnumeric(params.config.IMAPMA) ...
        && isfinite(params.config.IMAPMA) ...
        && any(params.config.IMAPMA == [1, 2]))
    error('rk4_4llg:InvalidIMAPMA', ...
        'IMAPMA must be 1 for IMA or 2 for PMA.');
end
if params.config.dimensionlessLLG
    if ~isfield(params, 'g')
        error('rk4_4llg:MissingParameter', ...
            'Missing required parameter "g" for dimensionless LLG.');
    end
    validate_finite_scalar(params.g, 'rk4_4llg:InvalidGFactor', ...
        'g must be a finite scalar.');
end
if ~(isnumeric(params.m_init) && isvector(params.m_init) ...
        && numel(params.m_init) == 3 && all(isfinite(params.m_init(:))))
    error('rk4_4llg:InvalidInitialMagnetization', ...
        'm_init must be a finite 3-component vector.');
end
if norm(params.m_init) == 0
    error('rk4_4llg:ZeroInitialMagnetization', ...
        'm_init must have nonzero norm.');
end
if ~(isnumeric(params.Demag_) && isequal(size(params.Demag_), [3, 3]) ...
        && all(isfinite(params.Demag_(:))))
    error('rk4_4llg:InvalidDemag', ...
        'Demag_ must be a finite 3-by-3 demagnetization tensor.');
end
validate_finite_scalar(params.jc_STT, 'rk4_4llg:InvalidJcSTT', ...
    'jc_STT must be a finite scalar.');
validate_finite_scalar(params.jc_SOT, 'rk4_4llg:InvalidJcSOT', ...
    'jc_SOT must be a finite scalar.');
validate_vector3(params.Hext, 'rk4_4llg:InvalidHext', ...
    'Hext must be a finite 3-component vector.');
validate_vector3(params.PolSTT, 'rk4_4llg:InvalidPolSTT', ...
    'PolSTT must be a finite 3-component vector.');
validate_vector3(params.polSOT, 'rk4_4llg:InvalidPolSOT', ...
    'polSOT must be a finite 3-component vector.');
validate_vector3(params.mmmPL, ...
    'rk4_4llg:InvalidPinnedLayerMagnetization', ...
    'mmmPL must be a finite 3-component vector.');
end

function validate_finite_scalar(value, identifier, message)
if ~(isscalar(value) && isnumeric(value) && isfinite(value))
    error(identifier, message);
end
end

function validate_vector3(value, identifier, message)
if ~(isnumeric(value) && isvector(value) && numel(value) == 3 ...
        && all(isfinite(value(:))))
    error(identifier, message);
end
end
