%% Main Simulation Script
% Description: 
% This script initializes and executes a non-linear finite element analysis (FEA) 
% for Effect of tool advancement simulation. 
% Dr. Faouzi Rahmouni
% rahmounifaouzi01@gmail.com

clear, clc, close all

addpath(genpath('Functions'));
addpath(genpath('Bucket Sort'));

fprintf('================================================\n');
fprintf('   STARTING TOOL ADVANCEMENT SENSITIVITY RUN    \n');
fprintf('================================================\n');

%% Global Parameters Definition

% --- Geometry Settings ---
L = 100.0;             % Domain Length
W = 100.0;             % Domain Width
depth = 50.0;          % Cutting depth

% To obtain accurate, publication-quality results, use a 100×100 element mesh.
numElementsX = 100;    % Elements in X direction
numElementsY = 100;    % Elements in Y direction

% --- Material Properties (Fixed Theta) ---
thetaFixed = 15;       % Fixed Fiber Orientation (Degrees)
matProps = struct(...
    'E1', 121000, ...  % Young's Modulus 1
    'E2', 8600, ...    % Young's Modulus 2
    'nu12', 0.27, ...  % Poisson's Ratio
    'G', 4700 ...      % Shear Modulus
);

% Pack Properties: [E1, E2, nu12, G, theta]
PROP = [matProps.E1, matProps.E2, matProps.nu12, matProps.G, thetaFixed];

% --- Tool & Contact Parameters ---
penaltyStiffness = 1e7;   % Contact penalty (OMEGAN)
cuttingLength    = 10.0;  % Total distance for the cut
alpha = 0; gamma = 0;     % Tool orientation angles

% Tool Shape Configuration
toolParams = struct(...
    'StartPoint', [100, 100 - depth], ... 
    'ALength', 100, ...
    'BLength', 100, ...
    'Displacement', [1 1] ...
);

% --- Simulation Study Parameters ---
% The specific tool advancement values you requested
toolAdvancementValues = [0.1, 0.5, 1.5, 3.0]; 

% Solver Tolerances
maxIterations = 100;      % ITRA
absTol        = 1.0e10;   % ATOL
normTol       = 6;        % NTOL
cnvTol        = 1e-6;     % TOL (Convergence Tolerance)

%% Mesh Generation

fprintf('--> Generating Finite Element Mesh...\n');

nnx = numElementsX + 1;
nny = numElementsY + 1;

% Generate Nodes and Elements
XYZ = square_node_array([0 0], [L 0], [L W], [0 W], nnx, nny);
nodePattern = [1, 2, nnx+2, nnx+1];
LE = make_elem(nodePattern, numElementsX, numElementsY, 1, nnx);

% Mesh Statistics
numNodes = size(XYZ, 1);
numElems = size(LE, 1);
fprintf('    Nodes: %d, Elements: %d\n', numNodes, numElems);

%% Boundary Conditions

fprintf('--> Applying Boundary Conditions...\n');

% Identify Boundary Nodes
tol = 1e-6;
bottomNodes = find(abs(XYZ(:,2) - 0) < tol)';
leftNodes   = find(abs(XYZ(:,1) - 0) < tol)';
topNodes    = find(abs(XYZ(:,2) - L) < tol)';

% Right Boundary: Exclude nodes above the cutting depth
limitZ = W - depth;
rightNodes  = find(abs(XYZ(:,1) - L) < tol & XYZ(:,2) <= limitZ)';

% Apply Prescribed Displacements
SDISPT = BoundaryCond(bottomNodes, rightNodes, leftNodes, topNodes, 0, 0, 2, 0);

%% Tool Initialization (Master Surface)

[ELXYM.FIRST, ELXYM.Conect, ELXYM.Elemen_con] = Shape_Master(...
    alpha, gamma, toolParams.StartPoint, toolParams.ALength, ...
    toolParams.BLength, toolParams.Displacement);
ELXYM.second = ELXYM.FIRST;

%% Solver Loop (Iterating Tool Advancement)

fprintf('--> Starting Parameter Study Loop...\n');

outputFile = 'output.txt';
fid = fopen(outputFile, 'w');
if fid == -1, error('Could not open output file.'); end

% Loop through the requested advancement values: 0.1, 0.5, 1.5, 3
for i = 1:length(toolAdvancementValues)
    
    currentToolAd = toolAdvancementValues(i);
    
    fprintf('-----------------********---------------------\n');
    fprintf('    Running Case %d/%d: Tool Advancement = %.2f\n', ...
            i, length(toolAdvancementValues), currentToolAd);
        
    % --- Update Time Stepping Based on New Tool Advancement ---
    tFinal = 1.0;
    
    % Time Increment (dt) changes because speed changes
    dt = 1.0;  % currentToolAd / cuttingLength; 
    
    % Safety check for dt
    if dt <= 0 || isinf(dt)
        warning('Invalid dt calculated for ToolAd %.2f. Skipping.', currentToolAd);
        continue;
    end
    
    % Load Increments [Start End Increment InitialFactor FinalFactor]
    TIMS = [0; tFinal; dt; 0; tFinal];
    
    try
        % Call Main Solver Function
        NLFE(maxIterations, cnvTol, absTol, TIMS, fid, PROP, SDISPT, ...
             XYZ, LE, ELXYM, currentToolAd, penaltyStiffness);
         
        fprintf('    Case completed successfully.\n');
    catch ME
        fprintf('    Error in Case %d: %s\n', i, ME.message);
    end
end

fclose(fid);
fprintf('================================================\n');
fprintf('All simulations completed. Results saved to %s\n', outputFile);
fprintf('================================================\n');