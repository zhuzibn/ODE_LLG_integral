function config = make_config(overrides)
%MAKE_CONFIG Return LLGS feature flags as an explicit configuration struct.
%
% Selection guide:
%   IMAPMA          1 = in-plane magnetic anisotropy (IMA).
%                   2 = perpendicular magnetic anisotropy (PMA).
%   SOT_DLT         1 = include damping-like spin-orbit torque; 0 = disable.
%   SOT_FLT         1 = use facFLT_SHE in the example driver; 0 sets it to 0.
%                   SOT_DLT must also be 1 for SOT coefficients to be used.
%   STT_DLT         1 = include damping-like spin-transfer torque; 0 = disable.
%   STT_FLT         1 = use facFLT_STT in the example driver; 0 sets it to 0.
%                   STT_DLT must also be 1 for STT coefficients to be used.
%   dipolee         1 = include the K12Dipole interaction field; 0 = disable.
%   thermalnois     1 = include a random thermal field; 0 = deterministic.
%                   Enabling it requires Statistics Toolbox normrnd().
%   dimensionlessLLG
%                   1 = use dimensionless LLG time scaling; 0 = SI-time mode.
%                   Enabling it requires params.g in rk4_4llg_solver().
%
% Except for IMAPMA, selections are binary flags: use only 0 or 1.

config = struct( ...
    'IMAPMA', 2, ...
    'SOT_DLT', 0, ...
    'SOT_FLT', 0, ...
    'STT_DLT', 1, ...
    'STT_FLT', 0, ...
    'dipolee', 0, ...
    'thermalnois', 0, ...
    'dimensionlessLLG', 0);

if nargin < 1 || isempty(overrides)
    return;
end

override_names = fieldnames(overrides);
for idx = 1:numel(override_names)
    name = override_names{idx};
    if ~isfield(config, name)
        error('make_config:UnknownField', ...
            'Unknown configuration field "%s".', name);
    end
    config.(name) = overrides.(name);
end
end
