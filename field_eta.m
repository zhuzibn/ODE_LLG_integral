%% function for effective field calculation
% usage: add path which contain this file, call the function
% don't create the same function in new project 

%input
%1. mmm, magnetization, [1x3] vector, [emu/cm3]
%2. Hk, crystalline anisotropy field, double, [Tesla]
%3. Demag_, demagnetizing tensor, [3x3] matrix
%4. Hext, external field, [1x3] vector, [Tesla]
%5. js, spin current density, double, [A/m2]
%6. tFL, free layer thickness, double, [m]
%7. Ms, saturation magnetization, double, [emu/cm3]
%output
%1. hh,total effective field (include SOT FLT), [1x3] vector, [Tesla]
%2. a_parallel, STT+SOT DLT cofficient, double, [Tesla]
%3. a_perpendicular, STT FLT cofficient, double, [Tesla]
function [hh,a_parallel,a_perpendicular]=field_eta(mmm,Hk,Demag_,Hext,js,tFL,Ms)
conf_file();%load configuration
constantfile();%load constant
switch IMAPMA
    case 1%IMA
        hk=Hk_*[0,0,1].*mmm/Hk(2*(wPL>lPL)+1*(wPL<lPL)); %anisotropy field
        hd=(-Hd*mmm'/Hk(2*(wPL>lPL)+1*(wPL<lPL)))'; %demagnetizing field
        hext=Hext/Hk(2*(wPL>lPL)+1*(wPL<lPL));
        hdipole=((HdipoleFL*m_PLinit')/Hk(2*(wPL>lPL)+1*(wPL<lPL)))';
    case 2%PMA
        hk=[0,0,Hk]*mmm(3);
        Hd=4*pi*Ms*Demag_*1e-4;%Tesla
        hd=(-Hd*mmm')';%([3x3]*[3x1])'=[1x3]
        hext=Hext;
        if dipolee
            %add code to calc hdipole
        else
            hdipole=0;
        end
end
Jp=2*tFL*(Ms*1e3)/hbar;
if STT_DLT
    efficiencyselect=2;
    switch efficiencyselect%only for IMA, to modify to fit for PMA
        case 1
            b=1/(-4+((1+P)^3)*(3+mmm(2)*(wPL>lPL)+mmm(1)*(wPL<lPL)))/(4*(P^(3/2)));
            %Slonswski torque efficiency for GMR
        case 2%Slonswski torque efficiency for TMR
            switch IMAPMA
                case 1%IMA
                    b=P1/(1+(P1^2)*(mmm(2)*(wPL>lPL)+mmm(1)*(wPL<lPL)));
                case 2%PMA
                    b=P/(1+(P^2)*mmm(3));
            end
        case 3
            b=0.8; % fixed torque efficiency
        case 4 %multireflection [2015-Multiple Reflection Effect on Spin-Transfer Torque-Weiwei Zhu]
            %problematic
            %         theta=acos(dot(mmm,m_PLinit));
            %         [f12a,f21a]=torque_eff(P1,P2,theta);
            %         b=f12a;
    end
    Je=Ie/cross_area;%[Ampere/cm2]
    a_parallel_STT=Je/Jp*b*STTpolarizer;
    if STT_FLT
        a_perpendicular_STT=factorFieldLikeSTT*a_parallel_STT*V_MTJ_local;
    end
end
if SOT_DLT
    a_parallel_SHE=js/Jp;%to modify to auto get easy (y) axis
    if SOT_FLT
        a_perpendicular_SHE=fac_FLT_by_DLT_SHE*a_parallel_SHE*shepolarizer;
    else
        a_perpendicular_SHE=0;
    end
end
%% damping like torque
if STT_DLT && SOT_DLT
    a_parallel=a_parallel_STT+a_parallel_SHE;
elseif STT_DLT
    a_parallel=a_parallel_STT;
elseif SOT_DLT
    a_parallel=a_parallel_SHE;
end
%% field like torque
if STT_FLT
    a_perpendicular=a_perpendicular_STT;
else
    a_perpendicular=0;
end
hh=hk+hd+hext+hdipole+a_perpendicular_SHE; %total field
end