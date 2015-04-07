function [ time, Vout, Vinc, Vrefl ] = interpret_raw_data( rawfile, Vin_node, Vout_node, VL_node)
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
% function [ time, Vout, Vinc, Vrefl ] = interpret_raw_data( rawfile, Vin_node, Vout_node, VL_node)
%
% Function to extract arrays of input, output, and load voltages from
% LTspice output .raw file. 
% 
% Inputs: 
%   rawfile: String containing the name of the rawfile created by LTspice
%   Vin_node: String containing the name of the input generator voltage
%       node
%   Vout_node: String containing the name of the output voltage
%   VL_node: String containing the name of the load voltage, where the
%       charge pump impedance is to be evaluated
% Outputs:
%   time: Array of time values at which all other output voltages are
%       sampled
%   Vout: Array of output voltages
%   Vinc: Array of incident wave voltages at the VL_node (i.e. V+)
%   Vrefl: Array of reflected wave voltages at the VL_node (i.e. V-)


% Extract data structure from Spice raw output file
data=LTspice2Matlab(rawfile);

% Create node names to look for in data structure
Vin_name = ['V(',Vin_node,')'];
Vout_name = ['V(',Vout_node,')'];
VL_name = ['V(',VL_node,')'];

% Find the node data in the extracted data structure
in_index = find(strcmp(data.variable_name_list, Vin_name));
if isempty(in_index)
    error(['Error: ',Vin_name,' was not found in the raw file list of nodes.']);
end
out_index = find(strcmp(data.variable_name_list, Vout_name));
if isempty(out_index)
    error(['Error: ',Vout_name,' was not found in the raw file list of nodes.']);
end
L_index = find(strcmp(data.variable_name_list, VL_name));
if isempty(L_index)
    error(['Error: ',VL_name,' was not found in the raw file list of nodes.']);
end

%Collect data from structure
Vin=data.variable_mat(in_index,:);
Vout=data.variable_mat(out_index,:);
Vl=data.variable_mat(L_index,:);
time=data.time_vect;

% Compute incident and reflected voltage waveforms
Vinc = Vin/2; % V+
Vrefl = (2*Vl-Vin)/2; %V-
% To get S11, you can take the FFT of V- and V+ and then do V-/V+ in the
% frequency domain. This will be valid at the frequency of the input wave
% for the nonlinear circuit.





