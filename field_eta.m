%% function for effective field calculation
% usage: add path which contain this file, call the function
% don't create the same function in new project 
%input
%1. mmm, normalized magnetization, [1x3] unit vector
%2. Hk, crystalline anisotropy field, double, [Tesla]
%3. Demag_, demagnetizing tensor, [3x3] matrix
%4. Hext, external field, [1x3] vector, [Tesla]
%5. jc_STT, spin current density, double, [A/m2]
%6. tFL, free layer thickness, double, [m]
%7. Ms, saturation magnetization, double, [emu/cm3]
%8. facFLT_SHE,ratio of FLT/DLT
%9. K12Dipole, dipole tensor, [3x3] matrix
%10. mmmPL: normalized magnetization of PL
%11. PolFL:polarization of FL, dimensionless
%12. lFL: length of FL [m]
%13. wFL: width of FL [m]
%14. facFLT_STT:ratio of STT FLT/DLT
%15. thetaSH:spin Hall angle
%16. tHM:[m] thickness of HM
%17. lambdaSF: [m]spin diffusion length
%18. jc_SOT:[A/m2] SOT current density
%19. TT:[K] Temperature
%20. alp:damping constant, dimensionless
%21. tstep: [s] time step
%22. config: configuration flags from make_config()
%23. constants: physical constants from physical_constants()
%output
%1. hh,total effective field excluding FLT terms, [1x3] vector, [Tesla]
%2. sttdlt, STT DLT field-equivalent coefficient, double, [Tesla]
%3. sttflt, STT FLT field-equivalent coefficient, double, [Tesla]
%4. sotdlt, SOT DLT field-equivalent coefficient, double, [Tesla]
%5. sotflt, SOT FLT field-equivalent coefficient, double, [Tesla]
function [hh,sttdlt,sttflt,sotdlt,sotflt]=field_eta(mmm,Hk,Demag_,Hext,jc_STT,...
    tFL,Ms,facFLT_SHE,K12Dipole,mmmPL,PolFL,lFL,wFL,facFLT_STT,...
    thetaSH,tHM,lambdaSF,jc_SOT,TT,alp,tstep,config,constants)
switch config.IMAPMA
    case 1%IMA
        hk=[0,Hk,0].*mmm; %anisotropy field
        Hd=4*pi*Ms*Demag_*1e-4;%Tesla
        hd=(-Hd*mmm')'; %demagnetizing field
        hext=Hext;
        if config.dipolee
            hdipole = 4*pi*1e-7*(K12Dipole*Ms*1e3*mmmPL')';%[Tesla]
        else
            hdipole=[0,0,0];
        end
    case 2%PMA
        hk=[0,0,Hk]*mmm(3);
        Hd=4*pi*Ms*Demag_*1e-4;%Tesla
        hd=(-Hd*mmm')';%([3x3]*[3x1])'=[1x3]
        hext=Hext;
        if config.dipolee
            hdipole = 4*pi*1e-7*(K12Dipole*Ms*1e3*mmmPL')';%[Tesla]
        else
            hdipole=[0,0,0];
        end
end
% Numerically hbar in eV.s, equivalently hbar/e in J.s/C for this coefficient.
Jp=2*tFL*(Ms*1e3)/constants.hbar_over_e_eVs_or_Js_per_C;
if config.STT_DLT
    efficiencyselect=2;
    switch efficiencyselect%only for IMA, to modify to fit for PMA
        case 1
            b=1/(-4+((1+P)^3)*(3+mmm(2)*(wPL>lPL)+mmm(1)*(wPL<lPL)))/(4*(P^(3/2)));
            %Slonswski torque efficiency for GMR
        case 2%Slonswski torque efficiency for TMR
%             switch IMAPMA
%                 case 1%IMA
                    %b=PolFL/(1+(PolFL^2)*(mmm(2)*(wFL>lFL)+mmm(1)*(wFL<lFL)));
                    b=PolFL/(1+(PolFL^2)*(dot(mmm,mmmPL)));
%                 case 2%PMA
%                     b=P/(1+(P^2)*mmm(3));
%             end
        case 3
            b=0.8; % fixed torque efficiency
        case 4 %multireflection [2015-Multiple Reflection Effect on Spin-Transfer Torque-Weiwei Zhu]
            %problematic
            %         theta=acos(dot(mmm,m_PLinit));
            %         [f12a,f21a]=torque_eff(P1,P2,theta);
            %         b=f12a;
    end
    sttdlt=jc_STT/Jp*b;
    sttflt=facFLT_STT*sttdlt;
else
    sttdlt=0;
    sttflt=0;
end
if config.SOT_DLT
    %sotdlt=thetaSH*jc_SOT/Jp*(1-sech(tHM/lambdaSF));%to modify to auto get easy (y) axis
    sotdlt=thetaSH*jc_SOT/Jp;
    sotflt=facFLT_SHE*sotdlt;
else
    sotdlt=0;
    sotflt=0;
end
%% thermal fluctuation
if config.thermalnois==1%1(0) (not) enable thermal noise
    hthermtmp=sqrt(2*constants.kb*TT*alp/(lFL*wFL*tFL*Ms*1e3*constants.gam*(1+alp^2)*tstep));%[T]
    hthermx=normrnd(0,hthermtmp);hthermy=normrnd(0,hthermtmp);hthermz=normrnd(0,hthermtmp);
    htherm=[hthermx,hthermy,hthermz];
else
    htherm=[0,0,0];
end
hh=hk+hd+hext+hdipole+htherm; %total field
end