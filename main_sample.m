% template for main.m, 
% usage:copy to new dir, rename to main.m, change parameters
clear all;clc;close all;
%*******configuration**********
conf_file();
runtime=10e-9;
tstep=0.1e-9;
machineselect=1;%1\room 2\lab 3\cluster
switch machineselect
    case 1
     addpath('D:\Dropbox\phd\code\general\gitcontrol\constant');   
    case 2
     addpath('E:\dropbox\Dropbox\phd\code\general\constant'); 
    case 3 
end
%**********paramaters**********
%constant
constantfile();
%dimensions
LFL=50e-9;WFL=50e-9;tFL=0.6e-9;
LHM=LFL*1.1;WHM=WFL*1.1;tHM=2e-9;
%known parameters
Ms=1000;%[emu/cm3]=1e6 A/m
%unknown parameters
alp=0.01;
Hk=4*pi*800*1e-4;%[T]=800emu/cm3
P=0.4;%polarization of FL layer
thetaSH=0.2;
%initial condition
init_theta=5/180*pi;init_phi=0;
Hext=[0,0,0];
polSOT=[0,1,0];%spin flux polarization
PolFL=[0,0,1];
facFLT_STT=0.2;%ratio of FLT over DLT
lambdaSF=5e-9;%spin diffusion length
Ic=3e-3;%[Ampere]
TT=300;%[K]
mmmPL=[0,0,1];
if dipolee
    %to do
else
   K12Dipole=zeros(3,3); 
end
%calc
if SOT_FLT
    facFLT_SHE=2;%ratio of FLT/DLT
else
    facFLT_SHE=0;
end
totstep=round(runtime/tstep);
m_init=[sin(init_theta)*cos(init_phi),sin(init_theta)*sin(init_phi),cos(init_theta)];
Dx=0.01968237864387906;Dy=0.01968237864387906;
Dz=0.960635227939411;%from online calculator
Demag_=[Dx,0,0;0,Dy,0;0,0,Dz];
jc=Ic/(LHM*tHM);%[A/m2]
js_SOT=jc*thetaSH;%amplitide of spin current density [A/m2]
%**********dynamics**********
rk4_4llg();









