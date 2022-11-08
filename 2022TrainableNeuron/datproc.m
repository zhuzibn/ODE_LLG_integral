clear all;close all;clc
addpath('D:\tmp\people\xinyue\MTJ\STT\thermal')
if (1)% one level
    datrange=[22:2:28];
    szdate=size(datrange,2);
    mzz_=zeros(szdate,1);
    for ctdat=1:szdate
        datname=sprintf('final%d.mat',datrange(ctdat));
        load(datname);
        datrange(ctdat)
        mzz_(ctdat)=mmz(end-1);
        if (1)
figure;
plot(tt*1e9,mmx,tt*1e9,mmy,tt*1e9,mmz,'linewidth',2)
xlabel('time(ns)');ylabel('m')
legend('mx','my','mz')
close all
        end
    end
end

if (0)%two level
    datrang1=[42:1:49];%
    datrang2=[1:1:100];%
    mzz_=zeros(size(datrang1,2),size(datrang2,2));
    for ctdat1=1:size(datrang1,2)
        for ctdat2=1:size(datrang2,2)
        datname=sprintf('final%d_%d.mat',datrang1(ctdat1),datrang2(ctdat2));
        load(datname);
        [datrang1(ctdat1),datrang2(ctdat2)]
        mzz_(ctdat1,ctdat2)=mmz(end-1);
                if (1)
figure;
plot(tt*1e9,mmx,tt*1e9,mmy,tt*1e9,mmz,'linewidth',2)
xlabel('time(ns)');ylabel('m')
legend('mx','my','mz')
close all
        end
        end
    end
    mzp1ind=mzz_>0.9;%switched case
    mzp1=sum(mzp1ind,2)/size(datrang2,2);
end
%% compare with previous result
if (0)
    figure
    plot(tt,mmy','-b','LineWidth',2);
    hold on
    clear all
    load('test.mat');
    plot(tt,mmy','-r','LineWidth',1);
    xlabel('time(ns)','fontsize',15);ylabel('my','fontsize',15)
    %xlim([0,15]);ylim([-1.05,1.05]);
    set(gca,'fontsize',20)
    legend('new','old')
end
