function [SF, GDSF, DET] = SHAPEL(XI, ELXY)
%*************************************************************************
% Compute shape function, derivatives, and determinant of Q4 element
%*************************************************************************
%%
  XNODE=[-1  1  1 -1 ;  % 4   3
         -1 -1  1  1 ]; % 1   2
  QUAR = 0.25;
  SF=zeros(4,1);
  DSF=zeros(2,4);
  for I=1:4
    XP = XNODE(1,I);
    YP = XNODE(2,I);
    %
    XI0 = [1+XI(1)*XP 1+XI(2)*YP];
    %
    SF(I) = QUAR*XI0(1)*XI0(2);
    DSF(1,I) = QUAR*XP*XI0(2);
    DSF(2,I) = QUAR*YP*XI0(1);
  end
  GJ = DSF*ELXY;
  DET = det(GJ);
  GJINV=inv(GJ);
  GDSF=GJINV*DSF;
  
end