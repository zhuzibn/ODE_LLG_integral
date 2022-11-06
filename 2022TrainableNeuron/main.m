% template for main.m,
% usage:copy to new dir, rename to main.m, change parameters
clear all;clc;close all;
%*******configuration**********
conf_file();
runtime=40e-9;
tstep=5e-12;
% machineselect=1;%1\room 2\lab 3\cluster
% switch machineselect
%     case 1
%      addpath('D:\Dropbox\phd\code\general\gitcontrol\constant');
%     case 2
%      addpath('E:\dropbox\Dropbox\phd\code\general\constant');
%     case 3
% end
%**********paramaters**********
%constant
constantfile();
%dimensions
LFL=15e-9;WFL=15e-9;tFL=1.3e-9;
volumm=LFL*WFL*tFL;
LHM=LFL*1.1;WHM=WFL*1.1;tHM=2e-9;
%known parameters
Ms=1.58*1e4/(4*pi);%[emu/cm3]=1.58 [T]
%unknown parameters
alp=0.0122;
Ku_Bulk=2.2452E5; %[J/m3]
Ku_Interface = 1.286E-3;
Ku=Ku_Bulk+Ku_Interface/tFL;%[J/m3]
Mstmp=Ms*1e3;%[A/m]
Hk=2*Ku/Mstmp;%[T]
clear Mstmp
Hext=[0,0,0];
%% STT parameters
% jc_STT=777e10;%[A/m2]
starttime=5e-9;%[s]
endtime=runtime;%[s]
%    tstep=5e-12;%[s]
pulsewidth=30e-9;%[s]
risetime=100e-12;%[s]
downtime=100e-12;%[s]
%     jc=1e11;%[A/m2]
jc=88e9;%[A/m2]
%jc=13e9;%[A/m2]

PolFL=0.4;%polarization of FL layer
PolSTT=[0,0,1];
if STT_FLT
    facFLT_STT=0.2;%ratio of FLT over DLT
else
    facFLT_STT=0;
end
%% SOT parameters
thetaSH=0.2;
lambdaSF=5e-9;%spin diffusion length
polSOT=[0,1,0];%spin flux polarization
jc_SOT=0e10;%[A/m2]
if SOT_FLT
    facFLT_SHE=2;%ratio of FLT/DLT
else
    facFLT_SHE=0;
end
%% initial condition
init_theta=(175)/180*pi;init_phi=0;
m_init=[sin(init_theta)*cos(init_phi),sin(init_theta)*sin(init_phi),cos(init_theta)];
mmmPL=[0,0,1];
%% others
TT=300;%[K]

if dipolee
    %to do
else
    K12Dipole=zeros(3,3);
end

Dx=0.08829195120216121;Dy=0.08829195120216121;
Dz=0.8234160828228502;%from online calculator
Demag_=[Dx,0,0;0,Dy,0;0,0,Dz];
%% calc
totstep=round(runtime/tstep);
Edelta=(Ku-0.5*(Ms*1e3)*(Ms*4*pi*1e-4))*volumm/(kb*TT);%energy barrier
Hktmp=2*(Ku-0.5*(Ms*1e3)*(Ms*4*pi*1e-4))/Ms*1e-3;
Ic=jc*LFL*WFL;
%**********dynamics**********
rk4_4llg();
save('final88_1.mat')
if (0)
    figure;
    plot(tt*1e9,mmx,tt*1e9,mmy,tt*1e9,mmz,'linewidth',2)
    xlabel('time(ns)');ylabel('m')
    legend('mx','my','mz')
end







