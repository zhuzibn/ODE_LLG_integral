function plot_benchmark_result(result, output_file)
%PLOT_BENCHMARK_RESULT Save one benchmark's magnetization evolution.

figure_handle = figure('Visible', 'off');
figure_cleanup = onCleanup(@() close(figure_handle));
axes_handle = axes(figure_handle);

plot(axes_handle, result.tt * 1e9, result.mmx, ...
    result.tt * 1e9, result.mmy, ...
    result.tt * 1e9, result.mmz, ...
    'LineWidth', 1.5);
xlabel(axes_handle, 'time (ns)');
ylabel(axes_handle, 'm');
title(axes_handle, ['Evolution of magnetization: ' result.metadata.case_name], ...
    'Interpreter', 'none');
legend(axes_handle, 'm_x', 'm_y', 'm_z', 'Location', 'best');
grid(axes_handle, 'on');

exportgraphics(figure_handle, output_file, 'Resolution', 150);
end
