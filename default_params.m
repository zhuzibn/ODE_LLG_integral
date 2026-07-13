function cfg = default_params(overrides)
%DEFAULT_PARAMS Return the complete canonical LLGS parameter object.
%
% cfg = default_params() returns the effective defaults from the example
% driver. cfg = default_params(overrides) recursively applies known nested
% fields and rejects unknown fields.

cfg = struct();

cfg.material = struct();
cfg.material.Ms = 1000; % emu/cm3; converted internally with Ms * 1e3 to A/m
cfg.material.damping = 0.01; % dimensionless

cfg.geometry = struct();
cfg.geometry.LFL = 50e-9; % m, free-layer length
cfg.geometry.WFL = 50e-9; % m, free-layer width
cfg.geometry.tFL = 0.6e-9; % m, free-layer thickness
cfg.geometry.LHM = cfg.geometry.LFL * 1.1; % m, heavy-metal length
cfg.geometry.WHM = cfg.geometry.WFL * 1.1; % m, heavy-metal width
cfg.geometry.tHM = 2e-9; % m, heavy-metal thickness

cfg.solver = struct();
cfg.solver.runtime = 10e-9; % s
cfg.solver.tstep = 5e-12; % s
cfg.solver.method = 'rk4'; % supported solver selection
cfg.solver.dimensionless = 0; % binary flag
cfg.solver.g = []; % dimensionless scaling factor; required in dimensionless mode

cfg.fields = struct();
cfg.fields.anisotropy_mode = 2; % 1 = IMA, 2 = PMA
cfg.fields.Hk = 4 * pi * 1600 * 1e-4; % T, anisotropy field
cfg.fields.external = [0, 0, 0]; % T
cfg.fields.demag_tensor = [ ... % dimensionless demagnetization tensor
    0.01968237864387906, 0, 0; ...
    0, 0.01968237864387906, 0; ...
    0, 0, 0.960635227939411];
cfg.fields.dipole_enabled = 0; % binary flag
cfg.fields.dipole_tensor = zeros(3, 3); % dimensionless dipole interaction tensor

cfg.torques = struct();
cfg.torques.stt = struct();
cfg.torques.stt.damping_like_enabled = 1; % binary flag
cfg.torques.stt.field_like_enabled = 0; % binary flag
cfg.torques.stt.current_density = 0e10; % A/m2
cfg.torques.stt.free_layer_polarization = 0.4; % dimensionless
cfg.torques.stt.polarization = [0, 0, 1]; % dimensionless
cfg.torques.stt.pinned_magnetization = [0, 0, 1]; % dimensionless
cfg.torques.stt.field_like_ratio = 0; % dimensionless, FLT/DLT ratio

cfg.torques.sot = struct();
cfg.torques.sot.damping_like_enabled = 0; % binary flag
cfg.torques.sot.field_like_enabled = 0; % binary flag
cfg.torques.sot.current_density = 0e10; % A/m2
cfg.torques.sot.spin_hall_angle = 0.2; % dimensionless
cfg.torques.sot.spin_diffusion_length = 5e-9; % m
cfg.torques.sot.polarization = [0, 1, 0]; % dimensionless
cfg.torques.sot.field_like_ratio = 0; % dimensionless, FLT/DLT ratio

cfg.thermal = struct();
cfg.thermal.enabled = 0; % binary flag
cfg.thermal.temperature = 300; % K

cfg.initial = struct();
cfg.initial.magnetization = [sin(pi / 4), 0, cos(pi / 4)]; % dimensionless

cfg.output = struct();
cfg.output.plot = 1; % binary flag used by main.m
cfg.output.line_width = 2; % points, plotting only

if nargin >= 1 && ~isempty(overrides)
    cfg = apply_overrides(cfg, overrides, 'cfg');
end

validate_params(cfg);
end

function target = apply_overrides(target, overrides, path)
if ~(isstruct(overrides) && isscalar(overrides))
    error('LLGSParams:InvalidOverride', ...
        '%s overrides must be a scalar struct.', path);
end

names = fieldnames(overrides);
for idx = 1:numel(names)
    name = names{idx};
    field_path = [path '.' name];
    if ~isfield(target, name)
        error('LLGSParams:UnknownField', ...
            'Unknown parameter field "%s".', field_path);
    end
    if isstruct(target.(name))
        target.(name) = apply_overrides( ...
            target.(name), overrides.(name), field_path);
    else
        target.(name) = overrides.(name);
    end
end
end
