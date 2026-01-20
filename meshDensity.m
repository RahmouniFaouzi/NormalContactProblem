%% Main Simulation Script
% Description: 
% Study the effect of MESH DENSITY (100, 900, 3600, 10000 elements) on the simulation.
% Constants: Depth = 50, Theta = 15, Tool Advancement = 3.
% Dr. Faouzi Rahmouni
% rahmounifaouzi01@gmail.com

clear, clc, close all

addpath(genpath('Functions'));
addpath(genpath('Bucket Sort'));

fprintf('================================================\n');
fprintf('       STARTING MESH DENSITY SENSITIVITY RUN    \n');
fprintf('================================================\n');

%% Global Fixed Parameters

% --- Geometry Constants ---
L = 100.0;             % Domain Length
W = 100.0;             % Domain Width
depth = 50.0;          % Fixed Cutting depth

% --- Material Properties (Fixed Theta = 15) ---
thetaFixed = 15;
matProps = struct(...
    'E1', 121000, ...
    'E2', 8600, ...
    'nu12', 0.27, ...
    'G', 4700 ...
);
PROP = [matProps.E1, matProps.E2, matProps.nu12, matProps.G, thetaFixed];

% --- Tool & Solver Parameters ---
penaltyStiffness = 1e7;   % Contact penalty (OMEGAN)
cuttingLength    = 3;     % Total distance for the cut
toolStepSize     = 3;     % Fixed Tool Advancement
alpha = 0; gamma = 0;     % Tool orientation

% Tool Start Position (Fixed)
toolStart = [100, 100 - depth];

% Solver Tolerances
maxIterations = 100;
absTol        = 1.0e10;
normTol       = 6;
cnvTol        = 1e-6;

% --- Parameter Study: Mesh Densities (Total Elements) ---
studyMeshTotal = [100, 900, 3600, 10000]; 

%% Loop: Effect of Mesh Density

outputFile = 'output_mesh_study.txt';
fid = fopen(outputFile, 'w');
if fid == -1, error('Could not open output file.'); end

fprintf('--> Starting Mesh Loop (Elements: %s)...\n', num2str(studyMeshTotal));

for i = 1:length(studyMeshTotal)
    
    currentTotal = studyMeshTotal(i);
    elemsPerSide = sqrt(currentTotal); % e.g., sqrt(100) = 10x10 grid
    
    fprintf('    --------------------------------------------\n');
    fprintf('    Running Case %d/%d: Total Elements = %d (%dx%d Grid)\n', ...
            i, length(studyMeshTotal), currentTotal, elemsPerSide, elemsPerSide);
        
    % Generate New Mesh for this Density
    numElementsX = elemsPerSide;
    numElementsY = elemsPerSide;
    nnx = numElementsX + 1;
    nny = numElementsY + 1;

    XYZ = square_node_array([0 0], [L 0], [L W], [0 W], nnx, nny);
    nodePattern = [1, 2, nnx+2, nnx+1];
    LE = make_elem(nodePattern, numElementsX, numElementsY, 1, nnx);
    
    % Update Boundary Conditions for New Nodes
    tol = 1e-6;
    bottomNodes = find(abs(XYZ(:,2) - 0) < tol)';
    leftNodes   = find(abs(XYZ(:,1) - 0) < tol)';
    topNodes    = find(abs(XYZ(:,2) - L) < tol)';
    
    % Right Edge: Only hold nodes strictly BELOW the cut line
    limitZ = W - depth;
    rightNodes  = find(abs(XYZ(:,1) - L) < tol & XYZ(:,2) <= limitZ)';
    
    SDISPT = BoundaryCond(bottomNodes, rightNodes, leftNodes, topNodes, 0, 0, 2, 0);
    
    % Tool Initialization
    [ELXYM.FIRST, ELXYM.Conect, ELXYM.Elemen_con] = Shape_Master(...
        alpha, gamma, toolStart, 100, 100, [1 1]);
    ELXYM.second = ELXYM.FIRST;
    
    % Time Integration Setup
    tFinal = 1.0;
    dt   = 1.0; % toolStepSize / cuttingLength; 
    TIMS = [0; tFinal; dt; 0; tFinal];
    
    % Run Solver
    try
        NLFE(maxIterations, cnvTol, absTol, TIMS, fid, PROP, SDISPT, ...
             XYZ, LE, ELXYM, toolStepSize, penaltyStiffness);
         
        fprintf('    Mesh Size %d completed successfully.\n', currentTotal);
    catch ME
        fprintf('    Error at Mesh Size %d: %s\n', currentTotal, ME.message);
    end
end

fclose(fid);
fprintf('================================================\n');
fprintf('All simulations completed. Results saved to %s\n', outputFile);
fprintf('================================================\n');
