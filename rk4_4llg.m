%% 4th order Runge Kutta method, for LLG calaulation in both IMA, PMA MTJ with FLT and DLT
% usage: add path which contain this file, call the function
% don't create the same function in new project 

% call this function using: [,]=rk4_4llg(,)

%zzf,March.18,19.2016;
%1.changed based on PMA;2.add in FL torque
%% input
% Demag_, 3 by 3 matrix
% tstep is time step, unit [s]
% totstep is total number of steps
% m_init is initial magnetization, it is a 1-by-3 matrix, unit vector
% Ms: saturation magnetization, unit [emu/cm3]
% Hk: uniaxial anisotropy field, one value unit [tesla]
% Hext: applied field, 1-by-3 vector, unit [tesla]
% alp: damping constant
% P: polarization of FL and PL, currently only support same for both layer

% psj: unit 1-by-3 vector, spin flux polarization, 
% note in STT the reflection type is opposite to m_pin_layer

% dimensions LFL,WFL,tFL,LHM,WHM,tHM, unit [m]

%% output
%mmx,mmy,mmz: magnetization component, unit vector
%tt: simulation time list, unit [s]; plotting may convert to ns
%Icri: critical current for switching unit:[Ampere]
if ~(isscalar(runtime) && isnumeric(runtime) && isfinite(runtime) && runtime > 0)
    error('rk4_4llg:InvalidRuntime', 'runtime must be a finite positive scalar.');
end
if ~(isscalar(tstep) && isnumeric(tstep) && isfinite(tstep) && tstep > 0)
    error('rk4_4llg:InvalidTstep', 'tstep must be a finite positive scalar.');
end
if ~(isscalar(Ms) && isnumeric(Ms) && isfinite(Ms) && Ms > 0)
    error('rk4_4llg:InvalidMs', 'Ms must be a finite positive scalar.');
end
if ~(isscalar(tFL) && isnumeric(tFL) && isfinite(tFL) && tFL > 0)
    error('rk4_4llg:InvalidTFL', 'tFL must be a finite positive scalar.');
end
if ~(isscalar(alp) && isnumeric(alp) && isfinite(alp) && alp >= 0)
    error('rk4_4llg:InvalidAlpha', 'alp must be a finite nonnegative scalar.');
end
if ~(isscalar(IMAPMA) && isnumeric(IMAPMA) && isfinite(IMAPMA) && any(IMAPMA == [1, 2]))
    error('rk4_4llg:InvalidIMAPMA', 'IMAPMA must be 1 for IMA or 2 for PMA.');
end
if ~(isnumeric(m_init) && isvector(m_init) && numel(m_init) == 3 && all(isfinite(m_init(:))))
    error('rk4_4llg:InvalidInitialMagnetization', 'm_init must be a finite 3-component vector.');
end
if norm(m_init) == 0
    error('rk4_4llg:ZeroInitialMagnetization', 'm_init must have nonzero norm.');
end
if ~(isnumeric(Demag_) && isequal(size(Demag_), [3, 3]) && all(isfinite(Demag_(:))))
    error('rk4_4llg:InvalidDemag', 'Demag_ must be a finite 3-by-3 demagnetization tensor.');
end
if ~(isscalar(jc_STT) && isnumeric(jc_STT) && isfinite(jc_STT))
    error('rk4_4llg:InvalidJcSTT', 'jc_STT must be a finite scalar.');
end
if ~(isscalar(jc_SOT) && isnumeric(jc_SOT) && isfinite(jc_SOT))
    error('rk4_4llg:InvalidJcSOT', 'jc_SOT must be a finite scalar.');
end
if ~(isnumeric(Hext) && isvector(Hext) && numel(Hext) == 3 && all(isfinite(Hext(:))))
    error('rk4_4llg:InvalidHext', 'Hext must be a finite 3-component vector.');
end
if ~(isnumeric(PolSTT) && isvector(PolSTT) && numel(PolSTT) == 3 && all(isfinite(PolSTT(:))))
    error('rk4_4llg:InvalidPolSTT', 'PolSTT must be a finite 3-component vector.');
end
if ~(isnumeric(polSOT) && isvector(polSOT) && numel(polSOT) == 3 && all(isfinite(polSOT(:))))
    error('rk4_4llg:InvalidPolSOT', 'polSOT must be a finite 3-component vector.');
end
if ~(isnumeric(mmmPL) && isvector(mmmPL) && numel(mmmPL) == 3 && all(isfinite(mmmPL(:))))
    error('rk4_4llg:InvalidPinnedLayerMagnetization', 'mmmPL must be a finite 3-component vector.');
end
if dimensionlessLLG
    Hk_=Hk;
    Hk=[1*(FL_width<FL_length)*Hk,1*(FL_width>FL_length)*Hk,0];
    tau_c=(g*Hk(2*(FL_width>FL_length)+1*(FL_width<FL_length)))/(1+alp^2); %natural time constant 1/s
    scal=1;
else
    %Hk=[1,1,1];%normalization purpose
    tau_c=1;
    scal=gam/(1+alp^2);%scale parameter
end
ts1=tstep*tau_c; %time step

n_steps=round(runtime / tstep);
totstep=n_steps + 1;
tt=(0:n_steps)' * tstep;
ct1=1; %count 1
mmx=zeros(totstep,1);%(:,1)is top layer, (:,2)is bottom layer
mmy=zeros(totstep,1);
mmz=zeros(totstep,1);
mmx(1,1)=m_init(1);mmy(1,1)=m_init(2);mmz(1,1)=m_init(3);
while ct1<=n_steps       
mm1=[mmx(ct1,1),mmy(ct1,1),mmz(ct1,1)]; %top 

%% current calc
    if (0) %unit conversion Tesla-->A/m,debug use
    hhtmp=(hh*Hk(2)*1e7)/4/pi;   
    hk=(hk*Hk(2)*1e7)/4/pi;
    hd=(hd*Hk(2)*1e7)/4/pi;
    hext=(hext*Hk(2)*1e7)/4/pi;
    hdipole=(hdipole*Hk(2)*1e7)/4/pi;
    end
    %% legacy unit notes:
    %e_tmp:[e],unit electron charge
    %hbar_tmp:[ev.s]
    %d_tmp:[m],FL thickness
    %Hk_tmp:[Tesla]
    
    mmm=mm1;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc_STT,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,jc_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk1=scal*dmdt;
    
    mmm=mm1+kk1*ts1/2;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc_STT,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,jc_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk2=scal*dmdt;
    
    mmm=mm1+kk2*ts1/2;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc_STT,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,jc_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk3=scal*dmdt;
    
    mmm=mm1+kk3*ts1;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc_STT,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,jc_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk4=scal*dmdt;
   
    mn1=mm1+ts1/6*(kk1+2*kk2+2*kk3+kk4);
    mn1=mn1/norm(mn1);
    mmx(ct1+1,1)=mn1(1);mmy(ct1+1,1)=mn1(2);mmz(ct1+1,1)=mn1(3);
    
    ct1=ct1+1;
end
