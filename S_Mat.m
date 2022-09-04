function SGlobal = S_Mat(PROP)
%  function returns the plan stress stiffness 
%   matrix for fiber-reinforced materials 
E1=PROP(1);   E2=PROP(2);     G=PROP(4);
nu12=PROP(3); theta=PROP(5);nu21=(E2/E1)*nu12;

%- material stifness (plan stress) ref: https://www.scirp.org/html/58041_58041.htm
SLocal = [E1/(1-(nu12*nu21))          (nu21*E1)/(1-(nu12*nu21))      0
         (nu12*E2)/(1-(nu12*nu21))        E2/(1-(nu12*nu21))         0
                 0                               0                   G];	     
%- rot matrix
n = sin(theta*pi/180);
m = cos(theta*pi/180);
T = [m*m    n*n  -2*m*n 
     n*n    m*m   2*m*n 
     m*n   -m*n   m*m-n*n];

%- Global matrix
SGlobal = T * SLocal * T';
end
