# ODE_LLG_integral

The root solver uses one validated, nested parameter object:

1. `main.m`: editable example driver.
2. `default_params.m`: creates the complete canonical parameter object.
3. `validate_params.m`: validates its schema, values, and feature dependencies.
4. `rk4_4llg_solver.m`: callable RK4 integration function.
5. `field_eta.m`: calculates effective fields and torque coefficients.
6. `LLG_solver.m`: evaluates the LLGS right-hand side.

Create the defaults, override the values needed for the run, and call the
solver without caller-workspace variables or caller-supplied constants:

```matlab
cfg = default_params();
cfg.solver.runtime = 10e-9;
[tt, mmx, mmy, mmz] = rk4_4llg_solver(cfg);
```

`default_params(overrides)` also accepts a small recursive struct override.
Every named field must already exist in the default object, so misspellings
are rejected:

```matlab
cfg = default_params(struct( ...
    'solver', struct('runtime', 2e-9, 'tstep', 5e-12), ...
    'thermal', struct('enabled', 0)));
```

## Parameter GUI

Start the simple parameter editor from the repository root:

```matlab
llg_parameter_gui
```

The table exposes the canonical `default_params()` values and shows each unit
or allowed selection. Initial magnetization is entered as polar angle `theta`
from +z and azimuthal angle `phi` from +x, both in degrees; the GUI converts
these angles to `cfg.initial.magnetization`. **Run and Save** validates the
edited struct, calls `rk4_4llg_solver`, plots the magnetization, and writes one
MAT file containing a versioned `result` struct. `result.params` is the exact
validated parameter struct used for the run; the time and magnetization
outputs are stored as `result.tt`, `result.mmx`, `result.mmy`, and
`result.mmz`.

## Parameter groups

- `cfg.material`: saturation magnetization and damping.
- `cfg.geometry`: free-layer and heavy-metal dimensions.
- `cfg.solver`: runtime, timestep, solver selection, and dimensionless mode.
- `cfg.fields`: anisotropy mode/field, external field, demagnetization, and dipole inputs.
- `cfg.torques.stt` and `cfg.torques.sot`: feature flags, currents, polarizations, and torque coefficients.
- `cfg.thermal`: thermal-noise flag and temperature.
- `cfg.initial`: initial magnetization.
- `cfg.output`: example plotting controls; these do not enter the solver physics.

The only supported solver selection is `cfg.solver.method = 'rk4'`. The
solver obtains immutable values from `physical_constants()` internally.

## Legacy compatibility

`rk4_4llg_solver` temporarily continues to accept the historical flat
`params` struct, including its `config`, `constants`, and optional `g` fields.
That input is converted to the canonical nested layout, validated, and run
through the same computational path. `make_config()` remains only as a
compatibility helper for those callers and is not a second default interface.

## Units

- Time inputs (`runtime`, `tstep`) and the stored `tt` array are in seconds internally. Plotting code may convert time to nanoseconds with `tt*1e9`.
- Effective fields and field inputs (`Hk`, `Hext`, demagnetizing, dipole, thermal, and torque-equivalent fields) use Tesla.
- Saturation magnetization `Ms` is entered in emu/cm3. The code converts it to A/m where needed with `Ms*1e3`.
- Current densities (`jc_STT`, `jc_SOT`) are in A/m2.
- Free-layer and heavy-metal dimensions (`LFL`, `WFL`, `tFL`, `LHM`, `WHM`, `tHM`, `spin_diffusion_length`) are in meters.

7. If you used this code for your experiments or found it helpful, selectively cite the following papers:  
**SOT switching of Mn3Sn**: [Appl. Phys. Lett. 127, 022407 (2025)], [Phys. Rev. B 109, 134433 (2024)]  
**SOT switching of NiO**: [Appl. Phys. Lett. 125, 182403 (2024)]  
**SOT switching of collinear antiferromagnet**: [J. Appl. Phys. 133, 153904 (2023)]  
**SOT switching of perpendicular ferromagnet**: [Phys. Rev. B 110, 184428 (2024)], [J. Appl. Phys. 125, 183902 (2019)]  
**STT switching of ferrimagnet**: [J. Appl. Phys. 133, 153903 (2023)]  
**SOT switching of ferrimagnet**: [J. Appl. Phys. 124, 193901 (2018)]  
