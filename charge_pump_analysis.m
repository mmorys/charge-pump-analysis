%%  charge_pump_analysis.m
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
% This is the main executable script of the charge-pump-analysis
% application. Enter all desired inputs by modifying the user_inputs.m file
% and then run this script.

%% Load user inputs given in user_inputs.m file
user_inputs;

%% Create cell array of diode and charge pump parameters to iterate over
parameter_list = [cp_parameter_list,diode_parameter_list]; % Cell array containing diode and charge pump parameters as strings, taken from user_inputs.m file
num_parameters = length(parameter_list);

% Create N-dimensional numerical array of parameters, each dimension
% containing all the values to iteratie over for each parameter
parameters = cell(1,num_parameters);
num_diode_parameters = length(diode_parameter_list);
for ind=1:num_parameters
    eval(['parameters{ind} = ',parameter_list{ind},';']);
    eval(['pind.',parameter_list{ind},' = ',num2str(ind),';']);
end

%% Create array of the dimensions of parameters
parameters_size = zeros(size(parameters));
for ind=1:length(parameters_size)
    parameters_size(ind) = length(parameters{ind});
end

%% Create arrays for storing results
Vdc_array = zeros(parameters_size);
Vripple_array = Vdc_array;
Zcp_array = Vdc_array;
Zin_array = Vdc_array;
Impedance_error = Vdc_array;
unconverged_sims = [];

tic;
mydatestr=sprintf('%d-',fix(clock));
mydatestr = mydatestr(1:end-1);

num_sims = prod(parameters_size);

%% Iterate over every combination of parameters
for ind = 1:num_sims
    
    % Determine current combination of parameters to run
    v = ind2sub_array(parameters_size,ind);
    
    % Store inital Rin and Lin
    Rin_current = Rin(v(pind.Rin));
    Lin_current = Lin(v(pind.Lin));
    
    % Create diode model for current simulation
    if DIODE_FROM_PARAMETERS
        diode_name = create_diode_model(file_open_attemts_max,diode_path,Is(v(pind.Is)),Rs(v(pind.Rs)),Cjo(v(pind.Cjo)),Nstages(v(pind.N)),BV(v(pind.BV)),IBV(v(pind.IBV)),Eg(v(pind.Eg)),Vj(v(pind.Vj)),Xti(v(pind.Xti)),M(v(pind.M)),type{v(pind.type)});
    else
        diode_name = diode_names{v(pind.diode_names)};
    end
    
    % Insert diode name into diode subcircuit
    nameind = strfind(subckt_diode,'DIODE_NAME');
    if ~isempty(nameind)
        subckt_diode_name = [subckt_diode(1:nameind-1),diode_name,subckt_diode(nameind+10:end)];
        subckt_string = [subckt_header,subckt_diode_name,subckt_parasitics,subckt_dmodel,subckt_dpath,subckt_end];
    else
        subckt_string = [subckt_header,subckt_diode_name,subckt_parasitics,subckt_end];
    end
       
    % Set Lout based on f to minimize output ripple
    if MATCH_CoutESL_TO_Cout
        Lout = 1/((2*pi*f(v(pind.f)))^2*Cout(v(pind.Cout)));
    end
    
    % Create plot axes
    if (SHOW_PLOTS || PROMPT_IF_DC_REACHED)
        if (NEW_FIG_FOR_EACH_SIM || ind==1)
            myfig = figure;
            time_axes = subplot(2,1,1);
            freq_axes = subplot(2,1,2);
        else
            hold(time_axes,'off')
            hold(freq_axes,'off')
        end
    end
    
    % Initialize adaptive impedance matching iteration variables
    adaptive_run_count = 0;
    REFL_THRESH_REACHED = false;
    Vdc_previous = -Inf;
    T_fund = 1/f(v(pind.f));
    run_time = periods_initial*T_fund;
    
    % Run adaptive impedance simulation
    while( ( ITERATIVE_MATCHING && adaptive_run_count<max_adaptive_runs && (~REFL_THRESH_REACHED || FORCE_CONTINUE_AFTER_CONVERGED) ) || (~ITERATIVE_MATCHING && adaptive_run_count==0))
        
        % Compute source generator voltage from Pin and Rin
        Vg = Pin2Vg(Pin(v(pind.Pin)),Rin_current);
        
        % Function to create Spice netlist and run simulation, output raw
        % file name using subckt for diode model
        [netlist,Vin_node,Vout_node,VL_node] = create_dicksoncp_netlist(file_open_attemts_max,netlist_name,...
            subckt_string,run_time,Vg,f(v(pind.f)),Nstages(v(pind.Nstages)),...
            Rin_current,Lin_current,Rout(v(pind.Rout)),...
            Cout(v(pind.Cout)),Cout_ESR(v(pind.Cout_ESR)),...
            Cout_ESL(v(pind.Cout_ESL)),Cout_RL(v(pind.Cout_RL)),...
            C(v(pind.C)),C_ESR(v(pind.C_ESR)),C_ESL(v(pind.C_ESL)),...
            C_RL(v(pind.C_RL)));

        % Run LTSpice simulation using a system command
        rawfile = [netlist_name,'.raw'];
        if exist(rawfile,'file')==2
            delete(rawfile);
        end
        
        system(['scad3 -run -b ',netlist]);
        while(exist(rawfile,'file')==0)
            system(['scad3 -run -b ',netlist]);
        end
        
        % Collect time domain voltage data for input and output nodes
        [time,Vout,Vinc,Vrefl] = interpret_raw_data( rawfile, Vin_node, Vout_node, VL_node);
        
        % Resample voltage data to have a constant sampling rate, since
        % Spice uses variable step sizes during simulation
        [t,Vout] = even_resample(time,Vout,interp_method);
        Vinc = interp1(time,Vinc,t,interp_method);
        Vrefl = interp1(time,Vrefl,t,interp_method);
        Ts = t(2)-t(1);
        
        % Number of samples per fundamental input period
        Tn_fund = round(T_fund/Ts);
        
        % Compute ouput DC voltage
        [Vdc,Tnstart_Vdc,Vripple,DC_REACHED] = steady_state_detect(Vout,slope_change_thresh,min_dc_estim_length,Tn_fund);
        Tstart_Vdc = Tnstart_Vdc*Ts;
        
        % Plot current output voltage data
        if SHOW_PLOTS || (~DC_REACHED && PROMPT_IF_DC_REACHED)
            plot(time_axes,t,Vout,'Color',color_choice(adaptive_run_count+1),'LineStyle','-');
            hold(time_axes,'on')
            plot(time_axes,[Tstart_Vdc,t(end)],[Vdc,Vdc],'k');
            plot(time_axes,[Tstart_Vdc,time(end)],[Vdc+Vripple,Vdc+Vripple],'k:');
            plot(time_axes,[Tstart_Vdc,time(end)],[Vdc-Vripple,Vdc-Vripple],'k:');
            
            xlabel(time_axes,'Time (s)')
            ylabel(time_axes,'DC Voltage (V)')
        end
        
        % Prompt if DC reached
        if PROMPT_IF_DC_REACHED
            drawnow;
            
            choice = questdlg('Has DC state been reached?','DC Reached?','Yes, stop sim','No, continue sim','Yes, stop sim');
            if strcmp(choice,'Yes, stop sim')
                DC_REACHED = true;
            end
        end
        
        % If DC has not been reached, rerun simulation with more time
        if ~DC_REACHED
            run_time = run_time*2;
            if run_time > max_spice_sim_periods*T_fund;
                run_time = max_spice_sim_periods*T_fund;
                continue
            elseif run_time == max_spice_sim_periods*T_fund;
                unconverged_sims = [unconverged_sims,ind];
            else
                continue
            end
        end
        
        % Store DC voltage and ripple
        Vdc_array(ind) = Vdc;
        Vripple_array(ind) = Vripple;
        % Compute input impedance
        Vinc_steady_state = Vinc(Tnstart_Vdc:end);
        Vrefl_steady_state = Vrefl(Tnstart_Vdc:end);
        if mod(Vinc_steady_state,2)
            Vinc_steady_state = Vinc_steady_state(1:end-1);
            Vrefl_steady_state = Vrefl_steady_state(1:end-1);
        end
        
        % Use Goertzel algorithm to compute charge pump reflection
        % coefficient at input frequency
        [freqs,S11_rel,Gamma,Vinc_f0_goertzel] = transient_impednace_calc(Ts,Vinc_steady_state,Vrefl_steady_state,f(v(pind.f)),COMPUTE_REFL_AT_ALL_FREQ);
        
        % Compute charge pump impedance from reflection coefficient
        Zcp_with_inductor = Rin_current*(1+Gamma)/(1-Gamma);
        
        % Compute return loss at fundamental frequency
        S11_f0 = 20*log10(abs(Gamma));

        % Compute error in impedance estimate from Goertzel algorithm by
        % comparing the measured input voltage with the actual input
        % voltage magnitude and phase
        Vinc_f0_actual_amp = Vg/2;
        Vinc_f0_actual_phase = rem(t(Tnstart_Vdc),T_fund)/T_fund*2*pi-pi/2;
        Vinc_f0_actual = Vinc_f0_actual_amp*exp(1i*Vinc_f0_actual_phase);
        Impedance_error(ind) = abs(Vinc_f0_goertzel-Vinc_f0_actual)/abs(Vinc_f0_actual);
        if Impedance_error(ind) > 0.01
            warning(['Error in impedance calculation greater than 1% for ind=',num2str(ind)])
        end
        
        % Store source and charge pump impedances from current run
        Zin_array(ind) = Rin_current+1i*2*pi*f(v(pind.f))*Lin_current;
        Zcp_array(ind) = Zcp_with_inductor-1i*2*pi*f(v(pind.f))*Lin_current;
        
        % Update source resistance/inductance to match computed charge pump
        % impedance
        if ITERATIVE_MATCHING
            Rin_match = real(Zcp_with_inductor);
            if Rin_match > 0
                Rin_current = Rin_match;
            else
                Rin_current = 1;
            end
            Lin_match = -imag(Zcp_with_inductor)/(2*pi*f(v(pind.f)));
            if (Lin_current+Lin_match)>0
                Lin_current = Lin_current+Lin_match;
            else
                Lin_current = 0;
            end

            if S11_f0 < reflection_threshold
                REFL_THRESH_REACHED = true;
            end
        end
        
        % Plot generator to charge pump return loss
        if SHOW_PLOTS
            plot(freq_axes,freqs*1e-9,S11_rel,'Color',color_choice(adaptive_run_count+1));
            hold(freq_axes,'on')
            plot(freq_axes,f(v(pind.f))*1e-9,S11_f0,'Color',color_choice(adaptive_run_count+1),'Marker','x');
            xlim(freq_axes,[0,10*f(v(pind.f))*1e-9])
            xlabel(freq_axes,'Frequency (GHz)')
            ylabel(freq_axes,'Return Loss (dB)')
            drawnow
        end
        
        % Increment the run counter
        adaptive_run_count = adaptive_run_count+1;
    end
    disp(['Input impedance: ',num2str(Zcp_array(ind))])
    disp(['Matching inductance: ',num2str(Lin_current)])
    
    % Display progress and save data every 10th simulation run
    if mod(ind,10)==0
        disp(['Diode ',num2str(diode_ind),'/',num2str(num_diodes),'. Percent complete: ',num2str(ind/numel(Vdc_array)*100),'%. Time remaining: ',datestr(tcurr*(num_sims-ind)/(ind*86400),'DD:HH:MM:SS'),', Time elapsed: ',datestr(tcurr/86400,'DD:HH:MM:SS')]);
        if STORE_BACKUP
            save(['backup-',mydatestr,'.mat'],'Vdc_array','Vripple_array','Zcp_array','unconverged_sims','parameters');
        end
    end
    
    
end

if STORE_BACKUP
    save(['backup-',mydatestr,'.mat'],'Vdc_array','Vripple_array','Zcp_array','unconverged_sims','parameters');
end

% Delete raw file
[temp,namepart,extpart] = fileparts(rawfile); 
delete(rawfile);
delete([namepart,'.op',extpart])
    
    
    
    