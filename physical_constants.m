function constants = physical_constants()
%PHYSICAL_CONSTANTS Return the constants used by the LLGS calculations.

constants = struct();
constants.gam = 1.760859644e11; % rad/(s.T)
constants.ele = 1.602176565e-19; % C
constants.mu_0 = 1.25663706143592e-06; % T.m/A
constants.mub = 9.274e-24; % J/T, Bohr magneton
% Numerically hbar in eV.s, or equivalently hbar/e in J.s/C.
constants.hbar_over_e_eVs_or_Js_per_C = 6.58211951440e-16;
constants.kb = 1.38064852e-23; % J/K, Boltzmann constant
end
