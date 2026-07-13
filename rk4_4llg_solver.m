function [tt, mmx, mmy, mmz] = rk4_4llg_solver(params)
%RK4_4LLG_SOLVER Integrate LLGS dynamics from nested or legacy parameters.
%
% The default_params() nested layout is canonical. The historical flat
% params layout is accepted temporarily through normalize_params().

[params, constants] = normalize_params(params);

runtime = params.runtime;
tstep = params.tstep;
alp = params.alp;
config = params.config;
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
