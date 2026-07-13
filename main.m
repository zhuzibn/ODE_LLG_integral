% Example simulation driver; override canonical defaults for a local run.
clear all;clc;close all;
rng shuffle

cfg = default_params();

% Example overrides:
% cfg.solver.runtime = 10e-9; % s
% cfg.torques.stt.current_density = 0e10; % A/m2

[tt,mmx,mmy,mmz] = rk4_4llg_solver(cfg);

if cfg.output.plot
    figure;
    plot(tt*1e9,mmx,tt*1e9,mmy,tt*1e9,mmz, ...
        'linewidth',cfg.output.line_width)
    xlabel('time(ns)');ylabel('m')
    legend('mx','my','mz')
end
