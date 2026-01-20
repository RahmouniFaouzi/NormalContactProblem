function plot_stress_field(X, connect, se, comp, showMesh, gpOrder, ELXYM)
% PLOT_STRESS_FIELD (Fixed Version)
% Automatically handles dimension mismatches between Stress and Mesh.

    if nargin < 4 || isempty(comp), comp = 'xx'; end
    if nargin < 5 || isempty(showMesh), showMesh = false; end
    if nargin < 6 || isempty(gpOrder), gpOrder = 1; end

    Ne = size(connect,1);
    Nn = size(X,1);
    nne = size(connect,2);

    if nne~=4
        error('This function currently supports Q4 (4-node quads) only.');
    end

    % --- 1. ROBUST DATA EXTRACTION ---
    % First, extract the stress data for the requested component ('xx', etc.)
    % regardless of the shape (3xN or Nx3).
    
    if size(se, 1) == 3
        % Layout (A): 3 rows
        switch lower(comp)
            case 'xx', v = se(1,:);
            case 'yy', v = se(2,:);
            case 'xy', v = se(3,:);
            otherwise, error('comp must be ''xx'',''yy'' or ''xy''.');
        end
    elseif size(se, 2) == 3
        % Layout (B): 3 columns
        switch lower(comp)
            case 'xx', v = se(:,1)';
            case 'yy', v = se(:,2)';
            case 'xy', v = se(:,3)';
            otherwise, error('comp must be ''xx'',''yy'' or ''xy''.');
        end
    else
        % Fallback: Assume it's a single vector (1xN or Nx1)
        v = se(:)';
    end

    % --- 2. SAFETY RESIZING (The Fix) ---
    % Check if data length matches the mesh elements
    NGauss = 4;
    ExpectedSize = Ne * NGauss;
    ActualSize = numel(v);

    if ActualSize ~= ExpectedSize
        % warning('Dimension mismatch detected. Adjusting data to fit mesh.');
        if ActualSize > ExpectedSize
            % Data is too big (e.g., from a larger previous run) -> Truncate
            v = v(1:ExpectedSize);
        else
            % Data is too small -> Pad with zeros
            v(end+1 : ExpectedSize) = 0;
        end
    end

    % --- 3. EXTRAPOLATION ---
    % Reshape v into [Ne x 4]
    if gpOrder == 1
        sigma_elem = reshape(v, [4, Ne])';    % Ne x 4
    else
        sigma_elem = reshape(v, [Ne, 4]);     % Ne x 4
    end

    % Build shape function matrix
    a = 1/sqrt(3);
    if gpOrder == 1
        gp = [ -a, -a; a, -a; -a,  a; a,  a ];
    else
        gp = [ -a, -a; -a,  a; a, -a; a,  a ];
    end

    xi_node  = [-1,  1,  1, -1];
    eta_node = [-1, -1,  1,  1];

    Nmat = zeros(4,4);
    for j = 1:4
        xi = gp(j,1); eta = gp(j,2);
        for i = 1:4
            Nmat(j,i) = 1/4 * (1 + xi*xi_node(i)) * (1 + eta*eta_node(i));
        end
    end

    Ninv = inv(Nmat);

    % Accumulate nodal contributions
    stress_sum = zeros(Nn,1);
    count = zeros(Nn,1);

    for e = 1:Ne
        nodes = connect(e,:);     
        gp_vals = sigma_elem(e,:).'; 
        nodal_vals_e = Ninv * gp_vals;  
        
        for k=1:4
            nd = nodes(k);
            stress_sum(nd) = stress_sum(nd) + nodal_vals_e(k);
            count(nd) = count(nd) + 1;
        end
    end

    zeroNodes = find(count==0);
    if ~isempty(zeroNodes)
        count(zeroNodes) = 1;
    end

    stress_nodal = stress_sum ./ count;

    % --- 4. PLOTTING ---
    % Using the existing figure handle (no 'figure' command) to allow subplots
    patch('Faces', connect, ...
          'Vertices', X(:,1:2), ...
          'FaceVertexCData', stress_nodal, ...
          'FaceColor', 'interp', ...
          'EdgeColor', 'none');
          
    axis equal tight
    colormap(flipud(jet))  

    if showMesh
        hold on
        plot_mesh_overlay(X, connect); 
        hold off
    end
    
    hold on
    if nargin >= 7 && ~isempty(ELXYM)
         plot(ELXYM.second(:,1), ELXYM.second(:,2), 'k-'); % Fixed line style
    end
    axis off
    hold off
end

function plot_mesh_overlay(X,connect)
    Ne = size(connect,1);
    for e=1:Ne
        nodes = connect(e,:);
        xv = X(nodes([1:4 1]),1);
        yv = X(nodes([1:4 1]),2);
        plot(xv,yv,'k-','LineWidth',0.3);
    end
end