function ITGZONE(XYZ, LE, NOUT)
%*************************************************************************
% Check element connectivity and calculate volume
%*************************************************************************
%%
EPS=1E-7;
NE = size(LE,1);
VOLUME=0;
for I=1:NE
    ELXY=XYZ(LE(I,:),:);
    [~, ~, DET] = SHAPEL([0 0], ELXY);
    DVOL = 4*DET;
    if DVOL < EPS
        fprintf(NOUT,'\n??? Negative Jacobian ???\nElement connectivity\n');
        fprintf(NOUT,'%5d',LE(I,:));
        fprintf(NOUT,'\nNodal Coordinates\n');
        fprintf(NOUT,'%10.3e %10.3e %10.3e\n',ELXY');
        error('Negative Jacobian');
    end
    VOLUME = VOLUME + DVOL;
end
end