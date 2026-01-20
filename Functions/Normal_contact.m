function [FORCE ,STIFF]=Normal_contact(OMEGAN,ELXY,LTAN,XYZ,KL,Tool_Ad,ii)
%=======================================================================
% Contact Between a Flexible Body (slave) and a Rigid Body (Master)
% Normal forces function campute normal forces Fc and stifness contact Kc
% Input :
%         OMEGAN : normal penalty parametre
%         ELXY   : pair of master and slvave coordinate
%                  ELXY=[Xs Xm1 Xm2
%                        Ys Ym1 Ym2]
% Output
%     FORCE : normal forces
%     STIFF : normal contact stiffness
% This code modified from THE BOOK OF N.K.HIM
% contact auther
% email : rahmounifaouzi01@gmail.com
%========================================================================
FORCE=[];   STIFF=[];
if ii == 2                                    
     XN = [-1 ; 0];  % campute XN and XT if the rake angle NOT 90° or 0°
else
     XN = [0  ;-1];
end
% NORMAL GAP FUNCTION Gn = (X_s - X_1).N
GAPN = (ELXY(:,1)- ELXY(:,2))'*XN;


% CHECK IMPENETRATION CONDITION
if (GAPN >= 0), return; end        

% VERIFICATION PROCESS
XYZV = XYZ;
XYZV(:,1) = XYZV(:,1)- (1.001*Tool_Ad);

A = [XYZ(KL,:), XYZV(KL,:)];
B = [ELXY(:,2)' ,ELXY(:,3)'];

intersect  = segment_Intersect(A,B);
if ~intersect, return; end

if LTAN
    % CONTACT FORCE Fc=W*Gn*e_n
    FORCE = -OMEGAN*GAPN*XN;
    
    % FORM STIFFNESS  Kc=W*e_n*e_n'
    STIFF = OMEGAN*(XN*XN');
end
end
