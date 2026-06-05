# ODE_LLG_integral
there are five matlab files in this folder, "main_sample.m" and "conf_file_sample.m" are changable according to your need, the others should not be modified unless you understand it.
1. main_sample.m: start file
2. conf_file_sample.m: configuration file
3. rk4_4llg.m: conjoining function
4. field_eta.m: function which calculates effective field
5. LLG_solver.m: function of integration evolver

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
