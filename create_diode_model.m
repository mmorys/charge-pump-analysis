function diode_name = create_diode_model(file_open_attemts_max,diode_path,Is,Rs,Cjo,N,BV,IBV,Eg,Vj,Xti,M,type)
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
% function diode_name = create_diode_model(file_open_attemts_max,diode_path,Is,Rs,Cjo,N,BV,IBV,Eg,Vj,Xti,M,type)
%
% Function for creating a Spice diode model in a .dio file based on the
% input diode parameters.
%
% Inputs:
%   file_open_attemts_max: Maximum number of attempts to make at opening
%       the .dio file to write to
%   diode_path: Path and name of the diode file to be written to
% 	Is =  % Saturation current [A]
%   Rs = % Series resistance [Ohms]
%   Cjo = % Zero-bias junction capacitance [F]
%   N = % Ideality factor [unitless]
%   BV = % Reverse breakdown voltage [V]
%   IBV = % Current at reverse breakdown [A]
%   Eg = % Energy Gap [eV]
%   Vj = % Junction potential [V]
%   Xti = % Saturation current temperature coefficient [unitless]
%   M = % Grading coefficient [unitless]
%   type = % Diode type
% Outputs:
%   diode_name: Name of the diode created in the .dio file

diode_name = 'customdiode';

% Convert non-string parameters to strings
if isnumeric(Is)
    Is = num2str(Is);
end
if isnumeric(Rs)
    Rs = num2str(Rs);
end
if isnumeric(Cjo)
    Cjo = num2str(Cjo);
end
if isnumeric(N)
    N = num2str(N);
end
if isnumeric(BV)
    BV = num2str(BV);
end
if isnumeric(IBV)
    IBV = num2str(IBV);
end
if isnumeric(Eg)
    Eg = num2str(Eg);
end
if isnumeric(Vj)
    Vj = num2str(Vj);
end
if isnumeric(Xti)
    Xti = num2str(Xti);
end
if isnumeric(M)
    M = num2str(M);
end

% Open editable .dio file to write to
fout = fopen(diode_path,'wt');
count_fopen = 0;
while(fout==-1)
    count_fopen = count_fopen+1;
    fout = fopen(diode_path,'wt');
    if count_fopen > file_open_attemts_max
        error(['Try running with administrator privileges. Unable to edit file ',diode_path]);
    end
end

% Write the diode parameters to the file using the Spice diode syntax
fprintf(fout, '* Custom diode file.\n');
fprintf(fout, '*\n');
fprintf(fout,['.model ',diode_name,' D(Is=',Is,' Rs=',Rs,' N=',N,...
    ' Cjo=',Cjo,' BV=',BV,' IBV=',IBV,' Vj=',Vj,' M=',M,...
    ' Eg=',Eg,' Xti=',Xti,' mfg=Custom',' type=',type,')\n']);
fclose(fout);

end

