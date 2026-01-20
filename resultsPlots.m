%% Plotting Script
% 1. Penalty Parameter Sensitivity
% 2. Cutting Depth Sensitivity
% 3. Tool Advancement Validation
% 4. Mesh Density Convergence

clear, clc, close all

%% =========================================================================
%  FIGURE 1: PENALTY PARAMETER SENSITIVITY
%  =========================================================================
fprintf('Generating Figure 1: Penalty Parameter Sensitivity...\n');

% --- Data Definition ---
penalty_vals     = [1e1 1e2 1e3 1e4 1e5 1e6 1e7 1e8 1e9];   
force_glass_pen  = [22.67 170.31 624.62 559.50 448.51 437.68 436.53 436.51 436.51];
force_carbon_pen = [24.58 193.24 826.13 884.22 699.75 662.08 659.80 659.71 659.71];

% Converged Reference
conv_glass  = 436.51;
conv_carbon = 659.71;

% --- Plotting ---
figure('Name', 'Fig 1 - Penalty Parameter', 'Color', 'w', 'NumberTitle', 'off');
hold on; grid on; box on;

% Main Curves
plot(penalty_vals, force_glass_pen, 'o-r', 'LineWidth', 2, 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'DisplayName', 'Glass/Epoxy');
plot(penalty_vals, force_carbon_pen, 's-b', 'LineWidth', 2, 'MarkerSize', 10, ...
    'MarkerFaceColor', 'b', 'DisplayName', 'Carbon/Epoxy');

% Convergence Lines
plot([1e1 1e9], [conv_glass conv_glass], 'k--', 'LineWidth', 1.5, ...
    'DisplayName', 'Converged Solution');
plot([1e1 1e9], [conv_carbon conv_carbon], 'k--', 'LineWidth', 1.5, ...
    'HandleVisibility', 'off');

% Formatting
xlabel('Penalty Parameter (\omega_n)', 'FontWeight', 'bold');
ylabel('Normal Contact Force (N)', 'FontWeight', 'bold');
set(gca, 'XScale', 'log'); 
xlim([1e1 1e9]);
legend('Location', 'best');
set(gca, 'FontSize', 14, 'LineWidth', 1.5);


%% =========================================================================
%  FIGURE 2: CUTTING DEPTH SENSITIVITY
%  =========================================================================
fprintf('Generating Figure 2: Cutting Depth Sensitivity...\n');

% --- Data Definition ---
depth_vals = [15 30 50]; 
force_carbon_depth = [982.38  812.82 659.80];
conv_carbon_line   = [659.80 659.80 659.80];
force_glass_depth  = [413.92 400.26 436.53];
conv_glass_line    = [436.53 436.53 436.53];

% --- Plotting ---
figure('Name', 'Fig 2 - Cutting Depth', 'Color', 'w', 'NumberTitle', 'off');
hold on; grid on; box on;

% Curves
h1 = plot(depth_vals, force_carbon_depth, 'o-b', 'LineWidth', 2, 'MarkerSize', 10, ...
    'MarkerFaceColor', 'b', 'DisplayName', 'Carbon/Epoxy'); 
h2 = plot(depth_vals, force_glass_depth, 'd-r', 'LineWidth', 2, 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'DisplayName', 'Glass/Epoxy'); 

% Reference
h3 = plot(depth_vals, conv_carbon_line, 's--k', 'LineWidth', 1.5, 'MarkerSize', 6, ...
    'DisplayName', 'Converged Solution'); 
plot(depth_vals, conv_glass_line, 's--k', 'LineWidth', 1.5, 'MarkerSize', 6, ...
    'HandleVisibility', 'off');

% Formatting
xlabel('Cutting Depth (mm)', 'FontWeight', 'bold');
ylabel('Normal Contact Force (N)', 'FontWeight', 'bold');
legend([h1 h2 h3], 'Location', 'northwest');
ylim([0 1500]);
set(gca, 'XTick', depth_vals);
set(gca, 'FontSize', 14, 'LineWidth', 1.5);


%% =========================================================================
%  FIGURE 3: TOOL ADVANCEMENT VALIDATION
%  =========================================================================
fprintf('Generating Figure 3: Tool Advancement Validation...\n');

% --- Data Definition ---
tool_adv = [0.1 0.5 1.5 3];
abaqus_carbon = [23.4200  116.1100  342.0200  659.0100];
model_carbon  = [23.4900  116.3200  342.3300  659.8000];
abaqus_glass  = [14.1200   71.1200  215.4800  436.0300];
model_glass   = [14.3100   71.5500  215.8100  436.5300];

% --- Plotting ---
figure('Name', 'Fig 3 - Tool Advancement', 'Color', 'w', 'NumberTitle', 'off');
hold on; grid on; box on;

% Carbon Comparison
plot(tool_adv, abaqus_carbon, 'o-b', 'LineWidth', 1.5, 'MarkerSize', 10, ...
    'DisplayName', 'Carbon/Epoxy - Abaqus');
plot(tool_adv, model_carbon,  's--b', 'LineWidth', 2, 'MarkerSize', 8, ...
    'MarkerFaceColor', 'b', 'DisplayName', 'Carbon/Epoxy - Proposed');

% Glass Comparison
plot(tool_adv, abaqus_glass, 'o-r', 'LineWidth', 1.5, 'MarkerSize', 10, ...
    'DisplayName', 'Glass/Epoxy - Abaqus');
plot(tool_adv, model_glass,  's--r', 'LineWidth', 2, 'MarkerSize', 8, ...
    'MarkerFaceColor', 'r', 'DisplayName', 'Glass/Epoxy - Proposed');

% Formatting
xlabel('Tool Advancement (mm)', 'FontWeight', 'bold');
ylabel('Normal Contact Force (N)', 'FontWeight', 'bold');
legend('Location', 'northwest');
set(gca, 'FontSize', 14, 'LineWidth', 1.5);


%% =========================================================================
%  FIGURE 4: MESH DENSITY CONVERGENCE
%  =========================================================================
fprintf('Generating Figure 4: Mesh Density Convergence...\n');

% --- Data Definition ---
mesh_elems = [100 900 3600 10000];
force_carbon_mesh = [7282.15 2269.80 1116.12 659.80];
conv_carbon_mesh  = [659.80  659.80  659.80  659.80];
force_glass_mesh  = [5310.68 1594.30 753.25 436.53];
conv_glass_mesh   = [436.53  436.53  436.53 436.53];

% --- Plotting ---
figure('Name', 'Fig 4 - Mesh Density', 'Color', 'w', 'NumberTitle', 'off');
hold on; grid on; box on;

% Curves
h1 = plot(mesh_elems, force_carbon_mesh, 'o-b', 'LineWidth', 2, 'MarkerSize', 10, ...
    'MarkerFaceColor', 'b', 'DisplayName', 'Carbon/Epoxy'); 
h2 = plot(mesh_elems, force_glass_mesh, 'd-r', 'LineWidth', 2, 'MarkerSize', 10, ...
    'MarkerFaceColor', 'r', 'DisplayName', 'Glass/Epoxy'); 

% Reference
h3 = plot(mesh_elems, conv_carbon_mesh, 's--k', 'LineWidth', 1.5, 'MarkerSize', 6, ...
    'DisplayName', 'Converged Solution'); 
plot(mesh_elems, conv_glass_mesh, 's--k', 'LineWidth', 1.5, 'MarkerSize', 6, ...
    'HandleVisibility', 'off');

% Formatting
xlabel('Mesh Density (Number of Elements)', 'FontWeight', 'bold');
ylabel('Normal Contact Force (N)', 'FontWeight', 'bold');
legend([h1 h2 h3], 'Location', 'northeast');
set(gca, 'FontSize', 14, 'LineWidth', 1.5);
% Optional: set(gca, 'XScale', 'log');

fprintf('All figures generated successfully.\n');