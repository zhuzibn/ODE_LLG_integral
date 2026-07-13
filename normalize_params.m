function [params, constants, was_legacy] = normalize_params(input_params)
%NORMALIZE_PARAMS Convert public LLGS parameters to one flat compute layout.
%
% The nested object from default_params() is canonical. The historical flat
% struct remains a temporary compatibility input and is converted before the
% same validation and computation path is used.

if ~(isstruct(input_params) && isscalar(input_params))
    error('LLGSParams:InvalidInput', ...
        'Solver input must be a scalar parameter struct.');
end

has_nested_marker = isfield(input_params, 'material');
has_legacy_marker = isfield(input_params, 'runtime');
if has_nested_marker && has_legacy_marker
    error('LLGSParams:AmbiguousLayout', ...
        'Parameter input cannot mix nested and legacy-flat layouts.');
elseif has_nested_marker
    cfg = input_params;
    constants = physical_constants();
    was_legacy = false;
elseif has_legacy_marker
    [cfg, constants] = legacy_to_nested(input_params);
    was_legacy = true;
else
    error('LLGSParams:UnknownLayout', ...
        ['Parameter input must be the nested default_params() layout or ' ...
        'the temporary legacy-flat layout.']);
end

validate_params(cfg);
params = nested_to_compute_params(cfg);
end

function [cfg, constants] = legacy_to_nested(params)
required = { ...
    'runtime', 'tstep', 'Ms', 'tFL', 'alp', 'm_init', 'Demag_', ...
    'jc_STT', 'jc_SOT', 'Hext', 'PolSTT', 'polSOT', 'mmmPL', ...
    'Hk', 'LFL', 'WFL', 'facFLT_SHE', 'K12Dipole', 'PolFL', ...
    'facFLT_STT', 'thetaSH', 'tHM', 'lambdaSF', 'TT', 'config', ...
    'constants'};
allowed = [required, {'g'}];
names = fieldnames(params);
for idx = 1:numel(required)
    if ~isfield(params, required{idx})
        error('rk4_4llg:MissingParameter', ...
            'Missing required legacy parameter "%s".', required{idx});
    end
end
for idx = 1:numel(names)
    if ~any(strcmp(names{idx}, allowed))
        error('LLGSParams:UnknownField', ...
            'Unknown legacy parameter field "%s".', names{idx});
    end
end

validate_legacy_config(params.config);
validate_constants(params.constants);

cfg = default_params();
cfg.solver.runtime = params.runtime;
cfg.solver.tstep = params.tstep;
cfg.solver.dimensionless = params.config.dimensionlessLLG;
if isfield(params, 'g')
    cfg.solver.g = params.g;
end
cfg.material.Ms = params.Ms;
cfg.material.damping = params.alp;
cfg.geometry.LFL = params.LFL;
cfg.geometry.WFL = params.WFL;
cfg.geometry.tFL = params.tFL;
cfg.geometry.tHM = params.tHM;
cfg.fields.anisotropy_mode = params.config.IMAPMA;
cfg.fields.Hk = params.Hk;
cfg.fields.external = params.Hext;
cfg.fields.demag_tensor = params.Demag_;
cfg.fields.dipole_enabled = params.config.dipolee;
cfg.fields.dipole_tensor = params.K12Dipole;
cfg.torques.stt.damping_like_enabled = params.config.STT_DLT;
cfg.torques.stt.field_like_enabled = params.config.STT_FLT;
cfg.torques.stt.current_density = params.jc_STT;
cfg.torques.stt.free_layer_polarization = params.PolFL;
cfg.torques.stt.polarization = params.PolSTT;
cfg.torques.stt.pinned_magnetization = params.mmmPL;
cfg.torques.stt.field_like_ratio = params.facFLT_STT;
cfg.torques.sot.damping_like_enabled = params.config.SOT_DLT;
cfg.torques.sot.field_like_enabled = params.config.SOT_FLT;
cfg.torques.sot.current_density = params.jc_SOT;
cfg.torques.sot.spin_hall_angle = params.thetaSH;
cfg.torques.sot.spin_diffusion_length = params.lambdaSF;
cfg.torques.sot.polarization = params.polSOT;
cfg.torques.sot.field_like_ratio = params.facFLT_SHE;
cfg.thermal.enabled = params.config.thermalnois;
cfg.thermal.temperature = params.TT;
cfg.initial.magnetization = params.m_init;
constants = params.constants;
end

function validate_legacy_config(config)
expected = { ...
    'IMAPMA', 'SOT_DLT', 'SOT_FLT', 'STT_DLT', 'STT_FLT', ...
    'dipolee', 'thermalnois', 'dimensionlessLLG'};
if ~(isstruct(config) && isscalar(config))
    error('LLGSParams:InvalidLegacyConfig', ...
        'Legacy parameter "config" must be a scalar struct.');
end
names = fieldnames(config);
for idx = 1:numel(expected)
    if ~isfield(config, expected{idx})
        error('rk4_4llg:MissingParameter', ...
            'Missing required legacy parameter "config.%s".', expected{idx});
    end
end
for idx = 1:numel(names)
    if ~any(strcmp(names{idx}, expected))
        error('LLGSParams:UnknownField', ...
            'Unknown legacy parameter field "config.%s".', names{idx});
    end
end
end

function validate_constants(constants)
required = {'gam', 'hbar_over_e_eVs_or_Js_per_C', 'kb'};
if ~(isstruct(constants) && isscalar(constants))
    error('LLGSParams:InvalidLegacyConstants', ...
        'Legacy parameter "constants" must be a scalar struct.');
end
for idx = 1:numel(required)
    name = required{idx};
    if ~isfield(constants, name)
        error('rk4_4llg:MissingParameter', ...
            'Missing required legacy parameter "constants.%s".', name);
    end
    value = constants.(name);
    if ~(isnumeric(value) && isreal(value) && isscalar(value) ...
            && isfinite(value))
        error('LLGSParams:InvalidLegacyConstants', ...
            ['Invalid legacy parameter "constants.%s": expected a ' ...
            'finite real numeric scalar.'], name);
    end
end
end

function params = nested_to_compute_params(cfg)
params = struct();
params.runtime = cfg.solver.runtime;
params.tstep = cfg.solver.tstep;
params.Ms = cfg.material.Ms;
params.tFL = cfg.geometry.tFL;
params.alp = cfg.material.damping;
params.m_init = cfg.initial.magnetization;
params.Demag_ = cfg.fields.demag_tensor;
params.jc_STT = cfg.torques.stt.current_density;
params.jc_SOT = cfg.torques.sot.current_density;
params.Hext = cfg.fields.external;
params.PolSTT = cfg.torques.stt.polarization;
params.polSOT = cfg.torques.sot.polarization;
params.mmmPL = cfg.torques.stt.pinned_magnetization;
params.Hk = cfg.fields.Hk;
params.LFL = cfg.geometry.LFL;
params.WFL = cfg.geometry.WFL;
params.facFLT_SHE = cfg.torques.sot.field_like_ratio;
params.K12Dipole = cfg.fields.dipole_tensor;
params.PolFL = cfg.torques.stt.free_layer_polarization;
params.facFLT_STT = cfg.torques.stt.field_like_ratio;
params.thetaSH = cfg.torques.sot.spin_hall_angle;
params.tHM = cfg.geometry.tHM;
params.lambdaSF = cfg.torques.sot.spin_diffusion_length;
params.TT = cfg.thermal.temperature;
params.config = struct( ...
    'IMAPMA', cfg.fields.anisotropy_mode, ...
    'SOT_DLT', cfg.torques.sot.damping_like_enabled, ...
    'SOT_FLT', cfg.torques.sot.field_like_enabled, ...
    'STT_DLT', cfg.torques.stt.damping_like_enabled, ...
    'STT_FLT', cfg.torques.stt.field_like_enabled, ...
    'dipolee', cfg.fields.dipole_enabled, ...
    'thermalnois', cfg.thermal.enabled, ...
    'dimensionlessLLG', cfg.solver.dimensionless);
if cfg.solver.dimensionless
    params.g = cfg.solver.g;
end
end
