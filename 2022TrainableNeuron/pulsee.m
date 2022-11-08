%% generate pulse
%{
% usage
jpulse=1;%enable pulse
pulsewidth=30e-9;%[s] pulse width
starttime=5e-9;%[s]
risetime=0.1e-9;%[s]
downtime=0.1e-9;%[s]
totstep=round((runtime+starttime)/tstepa);
t_=linspace(0,runtime+starttime,totstep);
if (runtime+starttime)<(starttime+pulsewidth)
    error('endtime has to be larger than starttime+pulsewidth')
end
jc_=pulsee(starttime,totstep,tstep,pulsewidth,risetime,downtime,Jc0,t_);
%}
function jc_=pulsee(starttime,endtime,tstep,pulsewidth,risetime,downtime,jc)
if (0)%example
    starttime=1e-9;%[s]
    endtime=10e-9;%[s]
    tstep=10e-12;%[s]
    pulsewidth=5e-9;%[s]
    risetime=100e-12;%[s]
    downtime=100e-12;%[s]
    jc=1e11;%[A/m2]
end

stabletime=pulsewidth-risetime-downtime;
startstep=floor(starttime/tstep);
risestep=floor(risetime/tstep);
downstep=floor(downtime/tstep);
stablestep=floor(stabletime/tstep);
endstep=floor(endtime/tstep);

lattertime=endstep-startstep-risestep-stablestep-downstep;

jc_=[zeros(1,startstep),linspace(0,jc,risestep),jc*ones(1,stablestep),...
    linspace(jc,0,downstep),zeros(1,lattertime)];
% if (0)
%     figure;
%     plot(t_*1e9,jc_STT*1e-11);
%     xlabel('time(ns)');ylabel('jc(e-11A/m2)');
% end
end
