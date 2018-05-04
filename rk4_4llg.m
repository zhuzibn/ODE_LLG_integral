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

% dimension FL_length,FL_width,FL_thickness, unit [nm]

%% output
%mmx,mmy,mmz: magnetization component, unit vector
%tt: simulation time list, unit [ns]
%Icri: critical current for switching unit:[Ampere]
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

ct1=1; %count 1
t=linspace(0,runtime,totstep);
mmx=zeros(totstep,1);%(:,1)is top layer, (:,2)is bottom layer
mmy=zeros(totstep,1);
mmz=zeros(totstep,1);
mmx(1,1)=m_init(1);mmy(1,1)=m_init(2);mmz(1,1)=m_init(3);
while ct1<totstep       
mm1=[mmx(ct1,1),mmy(ct1,1),mmz(ct1,1)]; %top 

%% current calc
    if (0) %unit conversion Tesla-->A/m,debug use
    hhtmp=(hh*Hk(2)*1e7)/4/pi;   
    hk=(hk*Hk(2)*1e7)/4/pi;
    hd=(hd*Hk(2)*1e7)/4/pi;
    hext=(hext*Hk(2)*1e7)/4/pi;
    hdipole=(hdipole*Hk(2)*1e7)/4/pi;
    end
    %% unit convension:
    %e_tmp:[e],unit electron charge
    %hbar_tmp:[ev.s]
    %d_tmp:[m],FL thickness
    %Hk_tmp:[Gauss]
    
    mmm=mm1;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,js_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk1=scal*dmdt;
    
    mmm=mm1+kk1*ts1/2;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,js_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk2=scal*dmdt;
    
    mmm=mm1+kk2*ts1/2;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,js_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk3=scal*dmdt;
    
    mmm=mm1+kk3*ts1;
    [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,LFL,WFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,js_SOT,TT,alp,tstep,thermalnois);
    dmdt=LLG_solver(alp,mmm,hh,polSOT,PolSTT,sttdlt,sttflt,sotdlt,sotflt);
    kk4=scal*dmdt;
   
    mn1=mm1+ts1/6*(kk1+2*kk2+2*kk3+kk4);
    mn1=mn1/norm(mn1);
    mmx(ct1+1,1)=mn1(1);mmy(ct1+1,1)=mn1(2);mmz(ct1+1,1)=mn1(3);
    
    ct1=ct1+1;
end
if dimensionlessLLG
    tt=t/tau_c*1e9;%unit[ns]
else
    tt=t;
end