function PROUT(NOUT, TIME, NUMNP, NE, NDOF)
%*************************************************************************
% Print converged displacements and stresses
%*************************************************************************
%%
  global SIGMA DISPTD DDEPSG
  %
   fprintf(NOUT,'\r\n\r\nTIME = %11.3e\r\n\r\nNodal Displacements\r\n',TIME);
   fprintf(NOUT,'\r\n Node          U1          U2 ');
  for I=1:NUMNP
    II=NDOF*(I-1);
     fprintf(NOUT,'\r\n%5d %11.3e %11.3e',I,DISPTD(II+1:II+2));
  end
   fprintf(NOUT,'\r\n\r\nElement Stress\r\n');
  fprintf(NOUT,'\r\n        S11         S22         S12');
  for I=1:NE
       fprintf(NOUT,'\r\nElement %5d',I);
      II=(I-1)*4;
      fprintf(NOUT,'\r\n%11.3e %11.3e %11.3e',SIGMA(1:3,II+1:II+4));
  end
%   fprintf(NOUT,'\r\n\r\nElement Strain\r\n');
%   fprintf(NOUT,'\r\n        E11         E22         E12');
 % for I=1:NE
%       fprintf(NOUT,'\r\nElement %5d',I);
 %     II=(I-1)*4;
 %     fprintf(NOUT,'\r\n %11.3e %11.3e %11.3e',DDEPSG(1:3,II+1:II+4));
  %end
  %fprintf(NOUT,'\r\n\r\n');
end
