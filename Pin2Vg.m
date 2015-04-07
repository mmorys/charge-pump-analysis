function Vg = Pin2Vg(P_dBm,Rin)
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
% function Vg = Pin2Vg(P_dBm,Rin)
%
% Converts RF input power in dBm to the equivalent generator voltage in V 
% given a generator series resistance of Rin.
%
% Inputs:
%   P_dBm: Incident power [dBm]
% Outputs:
%   Vg: Generator voltage [V]

    P_W = 10.^((P_dBm-30)./10);
    Vg = sqrt(8*Rin*P_W);
