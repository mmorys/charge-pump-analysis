%% user_inputs.m
%
% --------------------- Begin GPL Statement ---------------------
% Copyright 2015 Marcin M. Morys
%
% This file is part of charge-pump-analysis.
% 
% charge-pump-analysis is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% charge-pump-analysis is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with charge-pump-analysis. If not, see <http://www.gnu.org/licenses/>.
% --------------------- End GPL Statement ---------------------
%
% This is the user input file, where all user settings are provided for
% the executable charge_pump_analysis.m

%% Execution performance parameters
    STORE_BACKUP = false; % Boolean to choose whether to store backup mat file with all the results
    ITERATIVE_MATCHING = true; % Simulate CP with initial input (generator) resistance/inductance, compute CP input impedance, then resimulate with matched input generator
        COMPUTE_REFL_AT_ALL_FREQ = false; % Boolean to choose whether to compute relative backscattered power from charge pump at all frequencies (nonlinear harmonics, not just input frequency). This may lengthen computation time and is not needed for impedance matching, which is only done at input center frequency.
        FORCE_CONTINUE_AFTER_CONVERGED = false; % Continue to simulate iterative impedance matching until max_adaptive_runs limit is reached, even if reflection_threshold criterion has been reached
        max_adaptive_runs = 5; % Maximum number of adaptive impedance runs.
        reflection_threshold = -30; % When antenna to charge pump return loss is less than this value, iterative impedance matching ends [dB]
    PROMPT_IF_DC_REACHED = false; % If true, a prompt will appear once DC steady state is estimated, and the user must determine whether to continue current transient sim with more time or confirm that DC is reached. Under normal operation this is set to false, but can be set to true if steady-state estimation is giving false positives and the user wants to continue the simulation.
    SHOW_PLOTS = true; % If true, transient sim plots are shown after every run. Otherwise no plots are shown
    NEW_FIG_FOR_EACH_SIM = false; % If true, a new figure is generated for each combintation of charge pump/diode parameters. Otherwise, the same figure is overwritten after each simulation. This should be kept false when sweeping a large number of parameters, but can be useful for comparing a few parameter combintaions side by side.
    periods_initial = 200; % Number of fundamental frequency (f) periods to simulate in initial LTspice run (i.e. the starting simulation time in seconds is periods_initial/f)
    max_spice_sim_periods = 5e4; % Maximum number of fundamental frequency (f) periods to simulate up to in Spice before giving up on DC convergence and moving on to next case.
    min_dc_estim_length = 100; % Output voltage must be at steady state for at least min_dc_estim_length/f in order to compute input impedance
    slope_change_thresh = 1e3; % Threshold for DC steady-state detection. A higher value is a stricter steady-state convergence criterion, and will take longer to simulate. This is the ratio of the initial CP charging slope to the steady-state charging slope.
    MATCH_CoutESL_TO_Cout = false; % Automatically change Cout_ESL to resonate with Cout (i.e. 2*pi*f*Cout_ESL-1/(2*pi*f*Cout)=0 ), creating a virtual short circuit at the fundamental frequency at the output node, reducing the ripple.
    interp_method = 'spline'; % Interpolation method used to resample time domain data with even sampling periods (see built-in interp1(...) function documentation)
    file_open_attemts_max = 10; % Maximum number of times to attempt to open a netlist or diode file before throwing an error.
    netlist_name = 'CP_Netlist'; % Name to give the created netlist file (the .net extension will be appended automatically). The same name will be given to the LTSpice output .raw file.
    
%% Dickson charge pump parameters
% All parameters are specified as scalar values in an array. If there is 
% more than one value in any of the arrays, the code will automatically 
% iterate over all combinations of CP parameters.
    % 1 - RF Input power [dBm]
    Pin = [-20, 0];
    
    % 2 - RF input frequency [Hz]
    f = [915e6];
    
    % 3 - Number of charge pump stages
    Nstages = [1];
    
    % 4 - Input resistance [Ohms]
    Rin = [50];

    % 5 - Input inductance [H] (0 to ignore inductor in simulation)
    Lin = [0];
    
    % 6 - Output resistance [Ohms]
    Rout = [30];
    
    % 7 - Output capacitance [F]
    Cout = [50e-12];

    % 8 - Output capacitor effective series resistance [Ohms]
    Cout_ESR = [0];
    
    % 9 - Output capacitor effective series inductance [H]
    Cout_ESL = [0];
    
    % 10 - Output capacitor leakage resistance [Ohms]
    Cout_RL = [0];
    
    % 11 - Stage capacitance [F]
    C = [1e-12];

    % 12 - Stage capacitor effective series resistance [Ohms]
    C_ESR = [0];
    
    % 13 - Stage capacitor effective series inductance [H]
    C_ESL = [0];
    
    % 14 - Stage capacitor leakage resistance [Ohms]
    C_RL = [0];
    
    % Define cell array containing all simulation parameters defined above
    % - DO NOT EDIT
    cp_parameter_list = {'Pin','f','Nstages','Rin','Lin','Rout','Cout',...
        'Cout_ESR','Cout_ESL','Cout_RL','C','C_ESR','C_ESL','C_RL'};
    
%% Diode parameters
    DIODE_FROM_PARAMETERS = true; % Boolean to choose whether to create diode model
        % using the parameters specified by the user below, or to use a
        % diode pre-defined in the diode (.dio) file
    
    % Set diode file path
    % (Use double slashes in path so Matlab interprets them correctly)
    if DIODE_FROM_PARAMETERS
        diode_path = [pwd,'\custom.dio'];
    else
        % The default LTspice diode path on Windows operating system is
        % 'C:\\Program Files (x86)\\LTC\\LTspiceIV\\lib\\cmp\\standard.dio'
        diode_path = 'C:\Program Files (x86)\LTC\LTspiceIV\lib\cmp\standard.dio';
    end
    % Convert all single backslashes in the path to double backslashes to
    % be properly interpreted by MATLAB
    diode_path = double_backslash(diode_path);
    
    % Define diode parameters
    if DIODE_FROM_PARAMETERS
        % Enter the diode parameters here. Each parameter can be a
        % one-dimensional array of values.
        Is = [3e-6]; % Saturation current [A]
        Rs = [25]; % Series resistance [Ohms]
        N = [1.06]; % Ideality factor [unitless]
        Cjo = [0.18e-12]; % Zero-bias junction capacitance [F]
        BV = [3.8]; % Reverse breakdown voltage [V]
        IBV = [300e-6]; % Current at reverse breakdown [A]
        Vj = [0.35]; % Junction potential [V]
        M = [0.5]; % Grading coefficient [unitless]
        Eg = [0.69]; % Energy Gap [eV]
        Xti = [2]; % Saturation current temperature coefficient [unitless]
        type = {'Schottky'}; % Diode type
        
        % Define cell array containing all simulation parameters defined
        % above - DO NOT EDIT
            diode_parameter_list = {'Is','Rs','N','Cjo','BV','IBV','Vj',...
                'M','Eg','Xti','type'};
    else
        % Enter names of diodes in a cell array here, as they are defined
        diode_names = {'HSMS2850','SMS7630'};
        
        % Define cell array containing all simulation parameters defined
        % above - DO NOT EDIT
            diode_parameter_list = {'diode_names'};
    end
    
%% Diode subcircuit definition
    % Here the diode is included in a subcircuit definition so that
    % package parasitics can be defined if desired. If no diode package
    % parasitics are desired, leave the subckt_parasitics section blank
    % (i.e. subckt_parasitics = ''). Each Spice line must be followed with
    % '\n' to indicate a newline in the netlist.
    
    % Example of diode model defined above being used with no package
    % parasitics
    subckt_header = '.SUBCKT Diode_Model N_anode N_cathode\n'; % Shouldn't have to edit
    subckt_diode = 'D1 N_anode N_cathode DIODE_NAME\n'; % Don't change DIODE_NAME. The actual diode name from the Diode Parameters section above will be replaced automatically.
    subckt_parasitics = '';
    subckt_dmodel = '.model D D\n'; % Shouldn't have to edit
    subckt_dpath = ['.lib ',diode_path,'\n']; % Shouldn't have to edit
    subckt_end = '.ENDS Diode_Model\n'; % Shouldn't have to edit
    
%     % Example of custom IV curve defined diode model with parallel
%     % parasitic capacitance across voltage defined current source
%     % In subckt_header below, N_cathode is placed before N_anode to flip
%     % the diode around, where the anode of the diode in the circuit is
%     % located where the cathode would typically be. This voltage controlled
%     % current source defines a tunnel diode IV curve which is being
%     % operated in reverse in the circuit
%     subckt_header = '.SUBCKT Diode_Model N_cathode N_anode\n'; % Shouldn't have to edit
%     subckt_diode = 'B1 N_anode N_cathode I=0.00 + 0.0022*10**4*V(N_anode,N_cathode) - 0.0200*10**4*V(N_anode,N_cathode)**2 + 0.0425*10**4*V(N_anode,N_cathode)**3 + 0.0940*10**4*V(N_anode,N_cathode)**4 - 0.2720*10**4*V(N_anode,N_cathode)**5 - 0.4724*10**4*V(N_anode,N_cathode)**6 + 1.1122*10**4*V(N_anode,N_cathode)**7 + 1.2168*10**4*V(N_anode,N_cathode)**8 - 2.3464*10**4*V(N_anode,N_cathode)**9 - 1.0995*10**4*V(N_anode,N_cathode)**10 + 2.0943*10**4*V(N_anode,N_cathode)**11\n'; % Don't change DIODE_NAME. The actual diode name from the Diode Parameters section above will be replaced automatically.
%     subckt_parasitics = 'C1 N_anode N_cathode 0.3p\n';
%     subckt_end = '.ENDS Diode_Model\n'; % Shouldn't have to edit
    
    
    