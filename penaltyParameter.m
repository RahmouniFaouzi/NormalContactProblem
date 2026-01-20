%% Main Script: 
% Penalty Parameter Sensitivity (10^1 to 10^9)
% Constants: Depth = 50, Theta = 15, Tool Advancement = 3.
% Dr. Faouzi Rahmouni
% rahmounifaouzi01@gmail.com

clear, clc,  close all

addpath(genpath('Functions'));
addpath(genpath('Bucket Sort'));

fprintf('================================================\n');
fprintf('       STARTING PENALTY PARAMETER RUN           \n');
fprintf('================================================\n');

L = 100; 
W = 100;
theta = 15;           % Fixed Angle
depth = 50;           % Fixed Depth
toolStepSize  = 3;    % Fixed Speed
cuttingLength = 3;
maxIterations = 100;
tol = 1e-6;

% Material Properties
PROP = [121000, 8600, 0.27, 4700, theta];

% --- PENALTY PARAMETERS TO STUDY ---
% Generates: [10, 100, 1000, ... 1,000,000,000]
exponents = 1:9; 
studyPenalties = 10.^exponents; 

for i = 1:length(studyPenalties)
    currentPenalty = studyPenalties(i);
    fprintf('--> Running Case %d/9: Penalty Parameter = 10e%d\n', i, exponents(i));
    
    % MESH & BCs 
    numEle = 100;
    nnx = numEle+1; nny = numEle+1;
    
    XYZ = square_node_array([0 0],[L 0],[L W],[0 W], nnx, nny);
    nodePattern = [1, 2, nnx+2, nnx+1];
    LE = make_elem(nodePattern, numEle, numEle, 1, nnx);
    
    tol_pos = 1e-6;
    bottomNodes = find(abs(XYZ(:,2) - 0) < tol_pos)';
    leftNodes   = find(abs(XYZ(:,1) - 0) < tol_pos)';
    topNodes    = find(abs(XYZ(:,2) - L) < tol_pos)';
    limitZ = W - depth;
    rightNodes = find(abs(XYZ(:,1) - L) < tol_pos & XYZ(:,2) <= limitZ)';
    
    SDISPT = BoundaryCond(bottomNodes, rightNodes, leftNodes, topNodes, 0, 0, 2, 0);

    % Tool Position
    startPoint = [100, 100 - depth];
    [ELXYM.FIRST, ELXYM.Conect, ELXYM.Elemen_con] = Shape_Master(...
        0, 0, startPoint, 100, 100, [1 1]);
    ELXYM.second = ELXYM.FIRST;

    % C. SOLVER
    dt = 1.0; % toolStepSize / cuttingLength;
    TIMS = [0; 1.0; dt; 0; 1.0];

    try
        NLFE(maxIterations, tol, 1e10, TIMS, 1, PROP, SDISPT, ...
             XYZ, LE, ELXYM, toolStepSize, currentPenalty);
    catch ME
        fprintf('Error in Case %d: %s\n', i, ME.message);
    end
end