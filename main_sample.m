% template for main.m, 
% usage:copy to new dir, rename to main.m, change parameters
clear all;clc;close all;
rng shuffle
%*******configuration**********
conf_file();
runtime=10e-9;
tstep=5e-12;
%**********paramaters**********
%constant
constantfile();
%dimensions
LFL=50e-9;WFL=50e-9;tFL=0.6e-9; %[m]
LHM=LFL*1.1;WHM=WFL*1.1;tHM=2e-9;
%known parameters
Ms=1000;%[emu/cm3]=Ms*1e3 A/m
%unknown parameters
alp=0.01; %[dimensionless]
Hk=4*pi*1600*1e-4;%[T]=1600emu/cm3
Hext=[0,0,0]; %[T]
%% STT parameters
jc_STT=0e10;%[A/m2]
PolFL=0.4;%polarization of FL layer [dimensionless]
PolSTT=[0,0,1];%[dimensionless]
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
init_theta=45/180*pi;init_phi=0;
m_init=[sin(init_theta)*cos(init_phi),sin(init_theta)*sin(init_phi),cos(init_theta)];
mmmPL=[0,0,1];
%% others
TT=300;%[K]

if dipolee
    %to do
else
   K12Dipole=zeros(3,3); 
end

Dx=0.01968237864387906;Dy=0.01968237864387906;
Dz=0.960635227939411;%from online calculator
Demag_=[Dx,0,0;0,Dy,0;0,0,Dz];
%% calc
totstep=round(runtime/tstep);
%**********dynamics**********
rk4_4llg();
figure;
plot(tt*1e9,mmx,tt*1e9,mmy,tt*1e9,mmz,'linewidth',2)
xlabel('time(ns)');ylabel('m')
legend('mx','my','mz')








