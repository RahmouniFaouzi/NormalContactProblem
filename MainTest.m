clear
close all
clc

% ******************************************************************************
% ***                            I N P  U T                                  ***
% ******************************************************************************
disp('************************************************')
disp('***          S T A R T I N G    R  U N        ***')
disp('************************************************')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Material parametre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L=2;                                            % lenght
W=2;                                            % Width
E1=48000; E2=12000; nu12=0.19; G=6000;theta=13; % poission ratio % young modulas %Shear modulus
Alpha=0; Gamma=0; depth=1; N=[2 2-depth];       % first point
Alength=2; Blength=2; Dis=[1 1];
OMEGAN = 1e7;                               % Penalety parametre
Z = W-depth;                                % Excludes nodes above the depth Cutting
% Tool velocity
Cutting_Length = 0.1;          % cutting way --------->
Tool_Vitesse = 0.5/60;         % 0.5 metre/minit  ; 8.34e-3 m/s 
t_final = Cutting_Length/Tool_Vitesse;
Tool_Ad = 0.1;                 % Displacement of the tool in one increment
delt    = Tool_Ad/Tool_Vitesse;% Delta Time
%------------------------------------------------------------------------------------------
% INITIALIZING DATA STRUCTURES                                                             
numx = 30;      numy = numx;                                % element on x,y direction                                     
nnx  = numx+1; nny  = numy+1;                         % nodes on x,y direction 

% GENERATING MESH
XYZ = square_node_array([0 0],[L 0],[L W],[0 W],nnx,nny);

% conectivity Matrix
node_pattern = [ 1 2 nnx+2 nnx+1 ];
LE = make_elem(node_pattern,numx,numy,1,nnx);

% 
numnode  = size(XYZ,1); % number of all nodes 
numelem  = size(LE,1);  % number of all nodes 
% Finding node groups for boundary conditions

bottomNodes = find(XYZ(:,2)==0)';
rightNodes  = find(XYZ(:,1)==L)';
leftNodes   = find(XYZ(:,1)==0)'; 
topNodes    = find(XYZ(:,2)==L)';

% Exclude Nodes of cutting depth 
rightNodes   = find(XYZ(:,1)==L & XYZ(:,2)<=Z )';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prescribed Contact Tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MASTER SHAPE 
%---------------

[ELXYM.FIRST,ELXYM.Conect,ELXYM.Elemen_con]=Shape_Master(Alpha,Gamma,N,Alength,Blength,Dis);
ELXYM.second = ELXYM.FIRST ;
% PLOT MESH
figure;
hold on
plot_mesh(XYZ,LE,'Q4','g.-');
plot(ELXYM.FIRST(:,1), ELXYM.FIRST(:,2), '-*');
plot(ELXYM.second(:,1), ELXYM.second(:,2), '-*');
for i=1:size(XYZ,1)
    x1=XYZ(i,1); x2=XYZ(i,2);
    text(x1,x2,num2str(i))
    end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prescribed displacements [Node, DOF, Value]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SDISPT = BoundaryCond(bottomNodes,rightNodes,leftNodes,topNodes,0,0,2,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load increments [Start End Increment InitialFactor FinalFactor]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TIMS = [0 t_final delt 0 t_final]';
PROP = [E1 E2 nu12 G theta];                     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Set program parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ITRA = 100; ATOL = 1.0E10; NTOL = 6; TOL = 1e-6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Calling main function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NOUT = fopen('output.txt','w');
NLFE(ITRA,TOL,ATOL,TIMS,NOUT,PROP,SDISPT,XYZ,LE,ELXYM,Tool_Ad,OMEGAN)
fclose(NOUT);
