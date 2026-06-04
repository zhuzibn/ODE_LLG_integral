A. Must-Fix Correctness Issues

    1. Fix time grid off-by-one
       Risk: low implementation risk, high scientific impact.
       Smallest safe implementation: define samples as totstep = round(runtime/tstep) + 1 and t = (0:totstep-1)' * tstep;
       keep RK loop as while ct1 < totstep. This aligns stored states with actual integration time.

    2. Fix thermal-noise handling in RK4
       Risk: medium, because this changes stochastic trajectories.
       Smallest safe implementation: generate one thermal field per full timestep in rk4_4llg.m and pass it into all four
       field_eta calls. Document that this is still an RK-style approximation, not a full stochastic integrator redesign.

    3. Normalize RK intermediate magnetization states
       Risk: medium, because trajectories may change.
       Smallest safe implementation: after mmm = mm1 + ..., apply mmm = mmm / norm(mmm) before field/torque evaluation.
       Add a zero-norm guard.

    4. Make invalid configuration fail early
       Risk: low.
       Smallest safe implementation: add explicit validation for IMAPMA, vector sizes, positive Ms, positive tFL, positive
       tstep, finite alp, and valid demag shape before integration starts.

  B. Reproducibility Improvements

    1. Replace rng shuffle with controlled seed
       Risk: low.
       Smallest safe implementation: add rng_seed in main.m or config; call rng(rng_seed) and print/save the seed. Allow
       rng_seed = [] only when nondeterministic runs are intentionally requested.

    2. Record simulation metadata
       Risk: low.
       Smallest safe implementation: after each run, create a struct containing config flags, material parameters, units,
       seed, git commit if available, and timestamp.

    3. Remove hidden config reloads from computational functions
       Risk: medium because current behavior depends on workspace scripts.
       Smallest safe implementation: first pass config flags explicitly into field_eta; keep old wrapper behavior
       temporarily if needed. Do not change formulas in the same patch.

    4. Document unit convention in one place
       Risk: low.
       Smallest safe implementation: add a short “Units” section to README or local project docs: fields in Tesla, Ms in
       emu/cm3 converted by Ms*1e3, currents in A/m2, time in seconds, plotted time in ns.

  C. Test Coverage

    1. Deterministic zero-current norm conservation
       Risk: low.
       Smallest safe implementation: run a short no-STT/no-SOT/no-noise simulation and assert abs(norm(m)-1) < tolerance
       for all stored states.

    2. Known-field precession sanity test
       Risk: low to medium.
       Smallest safe implementation: with alp=0, no demag/no torques, constant field along z, check that mz stays constant
       and precession frequency matches gam*H.

    3. Damping decreases magnetic energy
       Risk: medium because energy definition must match field model.
       Smallest safe implementation: use a simple uniaxial or constant-field case and assert monotonic relaxation within
       numerical tolerance.

    4. Unit conversion tests
       Risk: low.
       Smallest safe implementation: assert 4*pi*Ms*1e-4 == mu_0*(Ms*1e3) within tolerance; assert torque coefficient
       scale for a known current/material set.

    5. Configuration validation tests
       Risk: low.
       Smallest safe implementation: intentionally pass invalid IMAPMA, bad demag shape, negative thickness, and confirm
       clear errors.

  D. Refactoring Without Physics Changes

    1. Convert rk4_4llg.m from script to function
       Risk: medium because many variables are currently workspace-dependent.
       Smallest safe implementation: introduce a new function wrapper returning tt, mmx, mmy, mmz; keep the old script
       entry as a thin compatibility layer during transition.

    2. Convert conf_file.m and constantfile.m into structs
       Risk: medium.
       Smallest safe implementation: add make_config() and physical_constants() helpers, then migrate call sites
       gradually. Avoid formula changes.

    3. Clarify hbar torque coefficient naming
       Risk: low.
       Smallest safe implementation: rename or alias hbar to hbar_over_e_eVs_or_Js_per_C only in comments first, then
       later replace with explicit SI expression hbar_Js / ele.

    4. Clean stale comments and wrong docs
       Risk: low.
       Smallest safe implementation: fix comments claiming tt is ns in all modes, dimensions are nm, and FLT comments that
       say DLT.

    5. Factor duplicated RK stage calls
       Risk: low to medium.
       Smallest safe implementation: create a local helper for “evaluate RHS at magnetization” after tests exist, so the
       four stages cannot drift apart.

  E. Optional Physics-Model Extensions

  1. Finite-thickness SOT spin-diffusion factor
     Risk: medium physics risk.
     Smallest safe implementation: add a config flag such as SOT_spin_diffusion_model = 'none' | 'sech'; default to
     current behavior, and document the formula.

  2. Proper stochastic LLG integrator
     Risk: high physics/modeling risk.
     Smallest safe implementation: add a separate heun_llg or sllg_step path rather than replacing RK4. Validate against
     thermal equilibrium statistics.

     deterministic runs. Use diagnostics only at first; do not feed them back into dynamics.

  3. Adaptive timestep or stability warnings
     Risk: medium.
     Smallest safe implementation: add warnings based on gam * max(|H_eff|) * tstep, then later consider adaptive
     stepping only after baseline tests exist.