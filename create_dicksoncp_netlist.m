function [netlist,Vin_node,Vout_node,VL_node] = create_dicksoncp_netlist(file_open_attemts_max,file_name,subckt_string,run_time,Vin,f,N,Rin,Lin,Rout,Cout,Cout_ESR,Cout_ESL,Cout_RL,C,C_ESR,C_ESL,C_RL)
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
% function [netlist,Vin_node,Vout_node,VL_node] = create_dicksoncp_netlist(file_open_attemts_max,file_name,subckt_string,run_time,Vin,f,N,Rin,Lin,Rout,Cout,Cout_ESR,Cout_ESL,Cout_RL,C,C_ESR,C_ESL,C_RL)
%
% This function generates a netlist file for a Dickson charge pump, which
% is readable by LTSpice. The Dickson charge pump netlist can then be used
% in LTspice similation.
% 
% Inputs:
%   file_open_attemts_max: Maximum number of attempts to open new netlist
%       file. Must be at least 1.
%   file_name: String name to be used for netlist file (.net extension will be
%       added automatically)
%   subckt_string: String defining the diode subcircuit, including package
%       parasitics.
%   run_time: Stop time for transient simulation [s]
%   Vin: Amplitude of sinusoidal generator voltage (Typically related to 
%       generator power by Pin[W] = Vin[V]^2/(8*Rin[Ohms])) [V]
%   f: Voltage generator frequency [Hz]
%   N: Number of Dickson charge pump stages, where there are two oppositely
%       oriented diodes per stage
%   Rin: Generator input resistance [Ohms]
%   Lin: Generator input inductance [H]
%   Rout: Charge pump load resistance (Output DC power can be computed as 
%       Pout[W] = Vout[V]^2/Rout) [Ohms]
%   Cout: Output capacitance, which is parallel to Rout [F]
%   Cout_ESR: Output capacitor effective series resistance [Ohms]
%   Cout_ESL: Output capacitor effective series inductance [H]
%   Cout_RL: Output capacitor parallel leakage resistance [Ohms]
%   C: Stage capacitance [F]
%   C_ESR: Stage capacitor effective series resistance [Ohms]
%   C_ESL: Stage capacitor effective series inductance [H]
%   C_RL: Stage capacitor parallel leakage resistance [Ohms]
% Outputs:
%   netlist: String containing the name of the created netlist file
%   Vin_node: String containing the name of the node where the generator
%       voltage is measured
%   Vout_node: String containing the name of the node where the output
%       voltage is measured (voltage across Rout)
%   VL_node: String containing the name of the node where the charge pump
%       input impedance is measured (i.e. the node after the generator
%       resistance)

    Vin_node = 'in'; % Name of input node
    Vout_node = 'out'; % Name of output node
    VL_node = 'l'; % Name of load node where input impedance is computed

    % Find name of diode subckt
    tempstr = textscan(subckt_string,'%s');
    subckt_name = tempstr{1}{2};
    
    % Open netlist file, output error afte rtoo many failed attempts
    netlist = [file_name,'.net'];
    fid = fopen(netlist,'wt');
    count_fopen = 0;
    while(fid==-1)
        count_fopen = count_fopen+1;
        fid = fopen([file_name,'.net'],'wt');
        if count_fopen > file_open_attemts_max
            error(['Unable to create file ',file_name,'.net']);
        end
    end
    
    % Check if Lin should be included, permitting only positive inductances
    if Lin<=0
        Vnode = [' ',VL_node];
    else
        Vnode = ' p';
    end
    
    % Create netlist
    fprintf(fid, '* N Stage Charge Pump \n');
    fprintf(fid, ['Vg ',Vin_node,' 0 SINE(0 ',num2str(Vin),' ',num2str(f),')\n']);
    fprintf(fid, ['Rin ',Vin_node,' ',VL_node,' ',num2str(Rin),'\n']);
    if Lin>0
        fprintf(fid, ['Lin ',VL_node,Vnode,' ',num2str(Lin),'\n']);
    end
    
    n1 = ' N1';
    n2 = ' N2';
    n3 = ' N3';
    
    if C_ESR<=0 && C_ESL<=0
        n2 = Vnode;
    elseif C_ESR<=0
        n3 = Vnode;
    elseif C_ESL<=0
        n3 = n2;
    end
    
    fprintf(fid, ['XD1 0',n1,' ',subckt_name,'\n']);
    fprintf(fid, ['C1',n1,n2,' ',num2str(C),'\n']);
    if C_RL>0
        fprintf(fid, ['Rl1',n1,n2,' ',num2str(C_RL),'\n']);
    end
    if C_ESL>0
        fprintf(fid, ['L1',n2,n3,' ',num2str(C_ESL),'\n']);
    end
    if C_ESR>0
        fprintf(fid, ['Rs1',n3,Vnode,' ',num2str(C_ESR),'\n']);
    end
    
    for n=2:N
        i1 = num2str(2*n-2);
        i2 = num2str(2*n-1);
        
        n0 = [' N',num2str((n-2)*6+1)];
        n1 = [' N',num2str((n-2)*6+4)];
        n2 = [' N',num2str((n-2)*6+5)];
        n3 = [' N',num2str((n-2)*6+6)];
        n4 = [' N',num2str((n-2)*6+7)];
        n5 = [' N',num2str((n-2)*6+8)];
        n6 = [' N',num2str((n-2)*6+9)];
        
        if C_ESR<=0 && C_ESL<=0
            n2 = ' 0';
            n5 = Vnode;
        elseif C_ESR<=0
            n3 = ' 0';
            n6 = Vnode;
        elseif C_ESL<=0
            n3 = n2;
            n6 = n5;
        end
        
        fprintf(fid, ['XD',i1,n0,n1,' ',subckt_name,'\n']);
        
        fprintf(fid, ['C',i1,n1,n2,' ',num2str(C),'\n']);
        if C_RL>0
            fprintf(fid, ['Rl',i1,n1,n2,' ',num2str(C_RL),'\n']);
        end
        if C_ESL>0
            fprintf(fid, ['L',i1,n2,n3,' ',num2str(C_ESL),'\n']);
        end
        if C_ESR>0
            fprintf(fid, ['Rs',i1,n3,' 0 ',num2str(C_ESR),'\n']);
        end
        
        fprintf(fid, ['XD',i2,n1,n4,' ',subckt_name,'\n']);
        
        fprintf(fid, ['C',i2,n4,n5,' ',num2str(C),'\n']);
        if C_RL>0
            fprintf(fid, ['Rl',i2,n4,n5,' ',num2str(C_RL),'\n']);
        end
        if C_ESL>0
            fprintf(fid, ['L',i2,n5,n6,' ',num2str(C_ESL),'\n']);
        end
        if C_ESR>0
            fprintf(fid, ['Rs',i2,n6,Vnode,' ',num2str(C_ESR),'\n']);
        end
    end
    
    i1 = num2str(2*N);

    n0 = [' N',num2str((N-1)*6+1)];
    n1 = [' ',Vout_node];
    n2 = [' N',num2str((N-2)*6+5)];
    n3 = [' N',num2str((N-2)*6+6)];
    
    if Cout_ESR<=0 && Cout_ESL<=0
        n2 = ' 0';
    elseif Cout_ESR<=0
        n3 = ' 0';
    elseif Cout_ESL<=0
        n3 = n2;
    end
    
    fprintf(fid, ['XD',i1,n0,n1,' ',subckt_name,'\n']);
    
    fprintf(fid, ['C_out',n1,n2,' ',num2str(Cout),'\n']);
    if Cout_RL>0
        fprintf(fid, ['Rl_cout',n1,n2,' ',num2str(Cout_RL),'\n']);
    end
    if Cout_ESL>0
        fprintf(fid, ['L_cout',n2,n3,' ',num2str(Cout_ESL),'\n']);
    end
    if Cout_ESR>0
        fprintf(fid, ['Rs_cout',n3,' 0 ',num2str(Cout_ESR),'\n']);
    end
    fprintf(fid, ['Rout',n1,' 0 ',num2str(Rout),'\n']);
    
    fprintf(fid, subckt_string);
    fprintf(fid, ['.tran 0 ',num2str(run_time),' 0\n']);
    fprintf(fid, '.options reltol=1e-5\n');
    fprintf(fid, '.backanno\n');
    fprintf(fid, '.end\n');

    % Close file
    fclose(fid);
end