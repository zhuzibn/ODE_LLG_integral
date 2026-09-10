function validate_params(cfg)
%VALIDATE_PARAMS Validate the complete canonical nested LLGS parameters.

schema = parameter_schema();
validate_struct_schema(cfg, schema, 'cfg');

validate_positive_scalar(cfg.solver.runtime, 'cfg.solver.runtime');
validate_positive_scalar(cfg.solver.tstep, 'cfg.solver.tstep');
if ~(ischar(cfg.solver.method) && isrow(cfg.solver.method) ...
        && strcmp(cfg.solver.method, 'rk4'))
    invalid('cfg.solver.method', 'the character vector ''rk4''');
end
validate_flag(cfg.solver.dimensionless, 'cfg.solver.dimensionless');
if cfg.solver.dimensionless
    validate_finite_scalar(cfg.solver.g, 'cfg.solver.g');
elseif ~(isempty(cfg.solver.g) || is_finite_scalar(cfg.solver.g))
    invalid('cfg.solver.g', 'empty or a finite real numeric scalar');
end

validate_positive_scalar(cfg.material.Ms, 'cfg.material.Ms');
validate_nonnegative_scalar(cfg.material.damping, 'cfg.material.damping');

validate_finite_scalar(cfg.geometry.LFL, 'cfg.geometry.LFL');
validate_finite_scalar(cfg.geometry.WFL, 'cfg.geometry.WFL');
validate_positive_scalar(cfg.geometry.tFL, 'cfg.geometry.tFL');
validate_finite_scalar(cfg.geometry.LHM, 'cfg.geometry.LHM');
validate_finite_scalar(cfg.geometry.WHM, 'cfg.geometry.WHM');
validate_finite_scalar(cfg.geometry.tHM, 'cfg.geometry.tHM');

if ~(is_finite_scalar(cfg.fields.anisotropy_mode) ...
        && any(cfg.fields.anisotropy_mode == [1, 2]))
    invalid('cfg.fields.anisotropy_mode', '1 (IMA) or 2 (PMA)');
end
validate_finite_scalar(cfg.fields.Hk, 'cfg.fields.Hk');
validate_vector3(cfg.fields.external, 'cfg.fields.external');
validate_tensor3(cfg.fields.demag_tensor, 'cfg.fields.demag_tensor');
validate_flag(cfg.fields.dipole_enabled, 'cfg.fields.dipole_enabled');
validate_tensor3(cfg.fields.dipole_tensor, 'cfg.fields.dipole_tensor');

validate_flag(cfg.torques.stt.damping_like_enabled, ...
    'cfg.torques.stt.damping_like_enabled');
validate_flag(cfg.torques.stt.field_like_enabled, ...
    'cfg.torques.stt.field_like_enabled');
validate_finite_scalar(cfg.torques.stt.current_density, ...
    'cfg.torques.stt.current_density');
validate_finite_scalar(cfg.torques.stt.free_layer_polarization, ...
    'cfg.torques.stt.free_layer_polarization');
validate_vector3(cfg.torques.stt.polarization, ...
    'cfg.torques.stt.polarization');
validate_unit_vector3(cfg.torques.stt.polarization, ...
    'cfg.torques.stt.polarization');
validate_vector3(cfg.torques.stt.pinned_magnetization, ...
    'cfg.torques.stt.pinned_magnetization');
validate_unit_vector3(cfg.torques.stt.pinned_magnetization, ...
    'cfg.torques.stt.pinned_magnetization');
validate_finite_scalar(cfg.torques.stt.field_like_ratio, ...
    'cfg.torques.stt.field_like_ratio');

validate_flag(cfg.torques.sot.damping_like_enabled, ...
    'cfg.torques.sot.damping_like_enabled');
validate_flag(cfg.torques.sot.field_like_enabled, ...
    'cfg.torques.sot.field_like_enabled');
validate_finite_scalar(cfg.torques.sot.current_density, ...
    'cfg.torques.sot.current_density');
validate_finite_scalar(cfg.torques.sot.spin_hall_angle, ...
    'cfg.torques.sot.spin_hall_angle');
validate_finite_scalar(cfg.torques.sot.spin_diffusion_length, ...
    'cfg.torques.sot.spin_diffusion_length');
validate_vector3(cfg.torques.sot.polarization, ...
    'cfg.torques.sot.polarization');
validate_unit_vector3(cfg.torques.sot.polarization, ...
    'cfg.torques.sot.polarization');
validate_finite_scalar(cfg.torques.sot.field_like_ratio, ...
    'cfg.torques.sot.field_like_ratio');

validate_flag(cfg.thermal.enabled, 'cfg.thermal.enabled');
validate_finite_scalar(cfg.thermal.temperature, 'cfg.thermal.temperature');
if cfg.thermal.enabled
    validate_positive_scalar(cfg.geometry.LFL, 'cfg.geometry.LFL');
    validate_positive_scalar(cfg.geometry.WFL, 'cfg.geometry.WFL');
    validate_nonnegative_scalar( ...
        cfg.thermal.temperature, 'cfg.thermal.temperature');
end

validate_vector3(cfg.initial.magnetization, ...
    'cfg.initial.magnetization');
if norm(cfg.initial.magnetization) == 0
    error('rk4_4llg:ZeroInitialMagnetization', ...
        ['Invalid parameter "cfg.initial.magnetization": expected a ' ...
        'finite 3-component vector with nonzero norm.']);
end
validate_unit_vector3(cfg.initial.magnetization, ...
    'cfg.initial.magnetization');

validate_flag(cfg.output.plot, 'cfg.output.plot');
validate_positive_scalar(cfg.output.line_width, 'cfg.output.line_width');
end

function schema = parameter_schema()
schema = struct();
schema.material = struct('Ms', [], 'damping', []);
schema.geometry = struct( ...
    'LFL', [], 'WFL', [], 'tFL', [], ...
    'LHM', [], 'WHM', [], 'tHM', []);
schema.solver = struct( ...
    'runtime', [], 'tstep', [], 'method', [], ...
    'dimensionless', [], 'g', []);
schema.fields = struct( ...
    'anisotropy_mode', [], 'Hk', [], 'external', [], ...
    'demag_tensor', [], 'dipole_enabled', [], 'dipole_tensor', []);
schema.torques = struct();
schema.torques.stt = struct( ...
    'damping_like_enabled', [], 'field_like_enabled', [], ...
    'current_density', [], 'free_layer_polarization', [], ...
    'polarization', [], 'pinned_magnetization', [], ...
    'field_like_ratio', []);
schema.torques.sot = struct( ...
    'damping_like_enabled', [], 'field_like_enabled', [], ...
    'current_density', [], 'spin_hall_angle', [], ...
    'spin_diffusion_length', [], 'polarization', [], ...
    'field_like_ratio', []);
schema.thermal = struct('enabled', [], 'temperature', []);
schema.initial = struct('magnetization', []);
schema.output = struct('plot', [], 'line_width', []);
end

function validate_struct_schema(value, schema, path)
if ~(isstruct(value) && isscalar(value))
    invalid(path, 'a scalar struct');
end

expected = fieldnames(schema);
actual = fieldnames(value);
for idx = 1:numel(expected)
    name = expected{idx};
    field_path = [path '.' name];
    if ~isfield(value, name)
        error('LLGSParams:MissingField', ...
            'Missing required parameter "%s".', field_path);
    end
    if isstruct(schema.(name))
        validate_struct_schema(value.(name), schema.(name), field_path);
    end
end
for idx = 1:numel(actual)
    name = actual{idx};
    if ~isfield(schema, name)
        error('LLGSParams:UnknownField', ...
            'Unknown parameter field "%s.%s".', path, name);
    end
end
end

function validate_finite_scalar(value, path)
if ~is_finite_scalar(value)
    invalid(path, 'a finite real numeric scalar');
end
end

function valid = is_finite_scalar(value)
valid = isnumeric(value) && isreal(value) && isscalar(value) ...
    && isfinite(value);
end

function validate_positive_scalar(value, path)
if ~(is_finite_scalar(value) && value > 0)
    invalid(path, 'a finite positive real numeric scalar');
end
end

function validate_nonnegative_scalar(value, path)
if ~(is_finite_scalar(value) && value >= 0)
    invalid(path, 'a finite nonnegative real numeric scalar');
end
end

function validate_flag(value, path)
if ~(is_finite_scalar(value) && any(value == [0, 1]))
    invalid(path, 'the binary numeric flag 0 or 1');
end
end

function validate_vector3(value, path)
if ~(isnumeric(value) && isreal(value) && isvector(value) ...
        && numel(value) == 3 && all(isfinite(value(:))))
    invalid(path, 'a finite real numeric 3-component vector');
end
end

function validate_tensor3(value, path)
if ~(isnumeric(value) && isreal(value) ...
        && isequal(size(value), [3, 3]) && all(isfinite(value(:))))
    invalid(path, 'a finite real numeric 3-by-3 tensor');
end
end

function validate_unit_vector3(value, path)
unit_tolerance = 1e-12;
if abs(norm(value) - 1) > unit_tolerance
    invalid(path, 'a unit-length finite real numeric 3-component vector');
end
end

function invalid(path, expected)
identifier = invalid_identifier(path);
error(identifier, ...
    'Invalid parameter "%s": expected %s.', path, expected);
end

function identifier = invalid_identifier(path)
switch path
    case 'cfg.solver.runtime'
        identifier = 'rk4_4llg:InvalidRuntime';
    case 'cfg.solver.tstep'
        identifier = 'rk4_4llg:InvalidTstep';
    case 'cfg.material.Ms'
        identifier = 'rk4_4llg:InvalidMs';
    case 'cfg.geometry.tFL'
        identifier = 'rk4_4llg:InvalidTFL';
    case 'cfg.material.damping'
        identifier = 'rk4_4llg:InvalidAlpha';
    case 'cfg.fields.anisotropy_mode'
        identifier = 'rk4_4llg:InvalidIMAPMA';
    case 'cfg.solver.g'
        identifier = 'rk4_4llg:InvalidGFactor';
    case 'cfg.initial.magnetization'
        identifier = 'rk4_4llg:InvalidInitialMagnetization';
    case 'cfg.fields.demag_tensor'
        identifier = 'rk4_4llg:InvalidDemag';
    case 'cfg.torques.stt.current_density'
        identifier = 'rk4_4llg:InvalidJcSTT';
    case 'cfg.torques.sot.current_density'
        identifier = 'rk4_4llg:InvalidJcSOT';
    case 'cfg.fields.external'
        identifier = 'rk4_4llg:InvalidHext';
    case 'cfg.torques.stt.polarization'
        identifier = 'rk4_4llg:InvalidPolSTT';
    case 'cfg.torques.sot.polarization'
        identifier = 'rk4_4llg:InvalidPolSOT';
    case 'cfg.torques.stt.pinned_magnetization'
        identifier = 'rk4_4llg:InvalidPinnedLayerMagnetization';
    otherwise
        identifier = 'LLGSParams:InvalidValue';
end
end
