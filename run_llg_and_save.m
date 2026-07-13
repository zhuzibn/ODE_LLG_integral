function result = run_llg_and_save(cfg, output_file)
%RUN_LLG_AND_SAVE Validate, run, and save one reproducible LLGS result.
%
% result = run_llg_and_save(cfg, output_file) saves a versioned result
% struct containing the exact validated parameters and solver outputs.

if ~(ischar(output_file) && isrow(output_file) && ~isempty(output_file))
    error('LLGSGUI:InvalidOutputFile', ...
        'output_file must be a nonempty character vector.');
end

[output_folder, ~, extension] = fileparts(output_file);
if ~isempty(output_folder) && ~isfolder(output_folder)
    error('LLGSGUI:MissingOutputFolder', ...
        'Output folder does not exist: %s', output_folder);
end
if ~strcmpi(extension, '.mat')
    error('LLGSGUI:InvalidOutputExtension', ...
        'Output file must use the .mat extension.');
end

validate_params(cfg);
[tt, mmx, mmy, mmz] = rk4_4llg_solver(cfg);

result = struct();
result.schema_version = 1;
result.params = cfg;
result.tt = tt;
result.mmx = mmx;
result.mmy = mmy;
result.mmz = mmz;
result.created_utc = char(datetime('now', 'TimeZone', 'UTC', ...
    'Format', 'yyyy-MM-dd''T''HH:mm:ssXXX'));

save(output_file, 'result');
end
