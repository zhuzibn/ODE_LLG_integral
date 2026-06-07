# ODE_LLG_integral

The root solver uses explicit configuration, constants, and parameter structs:

1. `main.m`: editable example driver.
2. `make_config.m`: creates configuration flags.
3. `physical_constants.m`: returns the physical constants.
4. `rk4_4llg_solver.m`: callable RK4 integration function.
5. `field_eta.m`: calculates effective fields and torque coefficients.
6. `LLG_solver.m`: evaluates the LLGS right-hand side.

Create a configuration with `make_config()`, collect simulation inputs in a
`params` struct, and call:

```matlab
[tt, mmx, mmy, mmz] = rk4_4llg_solver(params);
```

## Units

- Time inputs (`runtime`, `tstep`) and the stored `tt` array are in seconds internally. Plotting code may convert time to nanoseconds with `tt*1e9`.
- Effective fields and field inputs (`Hk`, `Hext`, demagnetizing, dipole, thermal, and torque-equivalent fields) use Tesla.
- Saturation magnetization `Ms` is entered in emu/cm3. The code converts it to A/m where needed with `Ms*1e3`.
- Current densities (`jc_STT`, `jc_SOT`) are in A/m2.
- Free-layer and heavy-metal dimensions (`LFL`, `WFL`, `tFL`, `LHM`, `WHM`, `tHM`, `lambdaSF`) are in meters.

7. If you used this code for your experiments or found it helpful, selectively cite the following papers:  
**SOT switching of Mn3Sn**: [Appl. Phys. Lett. 127, 022407 (2025)], [Phys. Rev. B 109, 134433 (2024)]  
**SOT switching of NiO**: [Appl. Phys. Lett. 125, 182403 (2024)]  
**SOT switching of collinear antiferromagnet**: [J. Appl. Phys. 133, 153904 (2023)]  
**SOT switching of perpendicular ferromagnet**: [Phys. Rev. B 110, 184428 (2024)], [J. Appl. Phys. 125, 183902 (2019)]  
**STT switching of ferrimagnet**: [J. Appl. Phys. 133, 153903 (2023)]  
**SOT switching of ferrimagnet**: [J. Appl. Phys. 124, 193901 (2018)]  
