function NLFE(ITRA,TOL,ATOL,TIMS,NOUT,PROP,SDISPT,XYZ,LE,ELXYM,Tool_Ad,OMEGAN)
%***********************************************************************
% MAIN PROGRAM FOR HYPERELASTIC/ELASTOPLASTIC ANALYSIS
%***********************************************************************
%%
global DISPDD DISPTD FORCE GKF DISPPD	% Global variables
%
[NUMNP, NDOF] = size(XYZ);				% Analysis parameters
NE = size(LE,1);
NEQ = NDOF*NUMNP;
%
DISPTD=zeros(NEQ,1); DISPDD=zeros(NEQ,1);	% Nodal displacement & increment
ETAN=S_Mat(PROP); 	% Initialize material properties
%
ITGZONE(XYZ, LE, NOUT);					% Check element connectivity
%
% Load increments [Start End Increment InitialLoad FinalLoad]
ILOAD=1;						    % First load increment
TIMEF=TIMS(1,ILOAD);				% Starting time
TIMEI=TIMS(2,ILOAD);				% Ending time
DELTA=TIMS(3,ILOAD);				% Time increment
TIME = TIMEF;						% Starting time
CUR1=TIMS(4,ILOAD);					% Starting load factor
CUR2=TIMS(5,ILOAD);					% Ending load factor

% Load increment loop
%----------------------------------------------------------------------
ISTEP = -1; FLAG10 = 1;
while(FLAG10 == 1)					    % Solution has been converged
    FLAG10 = 0; FLAG20 = 1;
    %
    CDISP = DISPTD; 					% Store converged displacement
    
    % Update stresses and history variables
    UPDATE=true; LTAN=false;
    ELAST3D(ETAN, UPDATE, LTAN, NE, NDOF, XYZ, LE);
    
    % Print results
    if(ISTEP>=0), PROUT(NOUT, TIME, NUMNP, NE, NDOF); end
    
    TIME = TIME + DELTA;	% Increase time
    ISTEP = ISTEP + 1;
    if ((TIME-TIMEI)>1E-10)	% Time passed the end time
        FLAG10 = 0;			% Stop the program
        break;
    end
    % Load factor and prescribed displacements
    FACTOR = CUR1 + (TIME-TIMEF)/(TIMEI-TIMEF)*(CUR2-CUR1);
    SDISP = DELTA*SDISPT(:,3)/(TIMEI-TIMEF)*(CUR2-CUR1);
    
    % Update Nodes Position
    XYZ = XYZ + reshape(DISPTD,2,length(DISPTD)/2)';
    ELXYM.second = ELXYM.second -[Tool_Ad 0;Tool_Ad 0;Tool_Ad 0];
    
    % Start convergence iteration
    %------------------------------------------------------------------
    ITER = 0;
    DISPDD = zeros(NEQ,1);
    while(FLAG20 == 1)
        FLAG20 = 0;
        ITER = ITER + 1;
        % Here Degradation Initialize global stiffness K and residual vector F
        GKF = sparse(NEQ,NEQ);
        FORCE = sparse(NEQ,1);
        
        % Assemble K and F
        UPDATE=false; LTAN=true;
        ELAST3D(ETAN, UPDATE, LTAN, NE, NDOF, XYZ, LE);
        
        % Contact Process
        [Force_Contact,Contact_Stiffness]= Contact_Process(XYZ,ELXYM,NEQ,OMEGAN,LTAN,Tool_Ad);
        FORCE = FORCE + Force_Contact;
        GKF   = GKF   + Contact_Stiffness;
        
        % Prescribed displacement BC
        NDISP=size(SDISPT,1);
        if NDISP~=0
            FIXEDDOF=NDOF*(SDISPT(:,1)-1)+SDISPT(:,2);
            GKF(FIXEDDOF,:)=zeros(NDISP,NEQ);
            GKF(FIXEDDOF,FIXEDDOF)=PROP(1)*eye(NDISP);
            %
            FORCE(FIXEDDOF)=0;
            if ITER==1, FORCE(FIXEDDOF) = PROP(1)*SDISP(:); end
        end
        
        % Solve the system equation
        if(FLAG10 == 0)
            DISPPD = DISPDD;
            SOLN = GKF\FORCE;
            DISPDD = DISPDD + SOLN;
            DISPTD = DISPTD + SOLN;
            FLAG20 = 1;
        else
            FLAG20 = 0;
        end
        if(FLAG10 == 1), break; end
        
        % Check convergence
        
        FIXEDDOF=NDOF*(SDISPT(:,1)-1)+SDISPT(:,2);
        ALLDOF=1:NEQ;
        FREEDOF=setdiff(ALLDOF,FIXEDDOF);
        RESN=max(abs(FORCE(FREEDOF)));
        
        %
        if(RESN<TOL) % Solution converged
            FLAG10 = 1;
            FLAG20 = 0;
            OUTPUT(1, ITER, RESN, TIME, DELTA)
        end
        if (ITER>=ITRA)	 % Max Iteration
            fprintf('Not converged. Max Iteration Reached \n');
            FLAG20 = 0;
            FLAG10 = 0;
            break;
        end
        if (RESN>ATOL),fprintf(1,'RSDUE Max Then ATOL = %3d\n',ATOL);end
        
    end 							%20 Convergence iteration
    figure;
    hold on
    coord = XYZ+reshape(DISPTD,2,length(DISPTD)/2)';
    plot_mesh(coord,LE,'Q4','g.-');
    plot(ELXYM.second(:,1), ELXYM.second(:,2), '-*');
end 								%10 Load increment
%
% Successful end of program
fprintf(1,'\t\t *** Successful end of program ***\n');
fprintf(NOUT,'\t\t *** Successful end of program ***\n');
end