%% Main Simulation Script
% Description: 
% Study the effect of CUTTING DEPTH (15, 30, 50) on the simulation.
% Constants: Theta = 15, Tool Advancement = 3.
% Dr. Faouzi Rahmouni
% rahmounifaouzi01@gmail.com

clear, clc,  close all

addpath(genpath('Functions'));
addpath(genpath('Bucket Sort'));

fprintf('================================================\n');
fprintf('      STARTING CUTTING DEPTH SENSITIVITY RUN    \n');
fprintf('================================================\n');

%% Global Parameters Definition

% --- Geometry Constants ---
L = 100.0;             % Domain Length
W = 100.0;             % Domain Width
% To obtain accurate, publication-quality results, use a 100×100 element mesh.
numElementsX = 100;    % Elements in X direction
numElementsY = 100;    % Elements in Y direction

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
penaltyStiffness = 1e7;  % Contact penalty (OMEGAN)
cuttingLength    = 3;    % Total distance for the cut
toolStepSize     = 3;    % Fixed Tool Advancement
alpha = 0; gamma = 0;    % Tool orientation

% Solver Tolerances
maxIterations = 100;
absTol        = 1.0e10;
normTol       = 6;
cnvTol        = 1e-6;

% --- Parameter Study: Cutting Depths ---
studyDepths = [15, 30, 50]; 

%% 3. Mesh Generation (Static)
% The node grid (XYZ) does not change, only the boundary groups change.

fprintf('--> Generating Base Mesh...\n');
nnx = numElementsX + 1;
nny = numElementsY + 1;

XYZ = square_node_array([0 0], [L 0], [L W], [0 W], nnx, nny);
nodePattern = [1, 2, nnx+2, nnx+1];
LE = make_elem(nodePattern, numElementsX, numElementsY, 1, nnx);

% Identify static boundary nodes (Bottom, Left, Top)
tol = 1e-6;
bottomNodes = find(abs(XYZ(:,2) - 0) < tol)';
leftNodes   = find(abs(XYZ(:,1) - 0) < tol)';
topNodes    = find(abs(XYZ(:,2) - L) < tol)';

fprintf('    Mesh generated successfully.\n');

%% Loop: Effect of Cutting Depth

outputFile = 'output_depth_study.txt';
fid = fopen(outputFile, 'w');
if fid == -1, error('Could not open output file.'); end

fprintf('--> Starting Depth Loop (Depths: %s)...\n', num2str(studyDepths));

for i = 1:length(studyDepths)
    
    currentDepth = studyDepths(i);
    
    fprintf('    --------------------------------------------\n');
    fprintf('    Running Case %d/%d: Cutting Depth = %d\n', ...
            i, length(studyDepths), currentDepth);
        
    % Update Boundary Conditions for New Depth
    % Right Edge: Only hold nodes strictly BELOW the cut line (W - Depth)
    limitZ = W - currentDepth;
    rightNodes = find(abs(XYZ(:,1) - L) < tol & XYZ(:,2) <= limitZ)';
    
    % Recalculate Prescribed Displacements
    SDISPT = BoundaryCond(bottomNodes, rightNodes, leftNodes, topNodes, 0, 0, 2, 0);
    
    % Update Tool Position for New Depth
    % Tool must start at [100, 100 - Depth]
    startPoint = [100, 100 - currentDepth];
    
    [ELXYM.FIRST, ELXYM.Conect, ELXYM.Elemen_con] = Shape_Master(...
        alpha, gamma, startPoint, 100, 100, [1 1]);
    ELXYM.second = ELXYM.FIRST;
    
    % Time Integration Setup
    tFinal = 1.0;
    dt   = 1.0; % toolStepSize / cuttingLength; 
    TIMS = [0; tFinal; dt; 0; tFinal];
    
    % Run Solver
    try
        NLFE(maxIterations, cnvTol, absTol, TIMS, fid, PROP, SDISPT, ...
             XYZ, LE, ELXYM, toolStepSize, penaltyStiffness, 0);
         
        fprintf('    Depth %d completed successfully.\n', currentDepth);
    catch ME
        fprintf('    Error at Depth %d: %s\n', currentDepth, ME.message);
    end
end

fprintf('================================================\n');
fprintf('All simulations completed. Results saved to %s\n', outputFile);
fprintf('================================================\n');