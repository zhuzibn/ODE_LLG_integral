runtime = 2e-9;
tstep = 5e-12;

LFL = 50e-9;
WFL = 50e-9;
tFL = 0.6e-9;
LHM = LFL * 1.1;
WHM = WFL * 1.1;
tHM = 2e-9;

Ms = 1000;
alp = 0.01;
Hk = 4 * pi * 1600 * 1e-4;
Hext = [0, 0, 0];

jc_STT = 0;
PolFL = 0.4;
PolSTT = [0, 0, 1];
facFLT_STT = 0;

thetaSH = 0.2;
lambdaSF = 5e-9;
polSOT = [0, 1, 0];
jc_SOT = 0;
facFLT_SHE = 0;

init_theta = 45 / 180 * pi;
init_phi = 0;
m_init = [sin(init_theta) * cos(init_phi), sin(init_theta) * sin(init_phi), cos(init_theta)];
mmmPL = [0, 0, 1];

TT = 300;
K12Dipole = zeros(3, 3);

Dx = 0.01968237864387906;
Dy = 0.01968237864387906;
Dz = 0.960635227939411;
Demag_ = [Dx, 0, 0; 0, Dy, 0; 0, 0, Dz];
