function [ELXYM,Conect,Elemen_con]=Shape_Master(Alp,Gam,N,Alengh,Blengh,Dis)
% Master Discritisation
%                  3
%           |      /
%  Blengh   |alh  /  dis(2)
%           |    /    Alengh
%       2   | N /----------Gam  1
%                dis(1)
% Input :
%       Alp,Gam : corners of Masters line  N:First point 
%       Alengh,Blengh: lengh of two lines 
%       Dis: Rafinement of  two lines
% Output
%      ELXYM: Matrix of coordinates 
% Auther Email: rahmounifaouzi01@gmail.com
%%%

% Dis FIRST LINE:
% ---------------
E0=[Alengh+N(1) (Alengh*tand(Gam))+N(2);N(1) N(2);Blengh*tand(Alp)+N(1) Blengh+N(2)];
ELXYM=zeros(Dis(1)+Dis(2)+1,2);
ELXYM(1,:)=E0(1,:);
ELXYM(Dis(1)+1,:)=E0(2,:);
MOY=Alengh/Dis(1);
MOY1=(E0(1,2)-E0(2,2))/Dis(1);
for I=2:Dis(1)
    ELXYM(I,1)=E0(1,1)-MOY;
    ELXYM(I,2)=E0(1,2)-MOY1;
    MOY=MOY+(Alengh/Dis(1));
    MOY1=MOY1+(E0(1,2)-E0(2,2))/Dis(1);
end
% Dis SECOND LINE:
% ---------------
ELXYM(Dis(1)+Dis(2)+1,:)=E0(3,:);
MOY=Blengh/Dis(2);
MOY1=abs((E0(2,1)-E0(3,1))/Dis(2));
for I=Dis(1)+2:Dis(1)+Dis(2)
    ELXYM(I,1)=E0(2,1)+MOY1;
    ELXYM(I,2)=E0(2,2)+MOY;
    MOY=MOY+(Blengh/Dis(2));
    MOY1=MOY1+abs((E0(2,1)-E0(3,1))/Dis(2));
end
% Element Conectivity:
% --------------------
NElemen=Dis(1)+Dis(2);
Conect=zeros(NElemen,4);
Elemen_con=zeros(NElemen,2);
for i=1:NElemen
    Conect(i,:)=[ELXYM(i,:) ELXYM(i+1,:)];
    Elemen_con(i,:)=[i i+1];
end
end
%[ELXYM,Conect,Elemen_con]=Shape_Master(6,3,[3 2],4,10,[1 1])
% Example
% clear;clc;close all;
% Alp=0; % 
% Gam=0;
% N=[3 2];% first point
% Alengh=3;Blengh=5;Dis=[9 30];N=[3 2];
% %
% figure
% hold on
% xlim([0 10])
% plot(ELXYM(:,1), ELXYM(:,2), '-*');
% axis equal