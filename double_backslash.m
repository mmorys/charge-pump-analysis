function out = double_backslash(input)
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
% function out = double_backslash(input)
%
% A function which takes as its input a string with backslashes '\' and
%   converts them all to double backslashes '\\'
%
% Inputs:
%   input: A string containing backslashes '\'
% Outputs: 
%   out: A string containing double backslashes '\\' in place of each '\'

    slash_inds = find(input=='\');
    num_slashes = length(slash_inds);
    
    out = input(1:slash_inds(1));
    for ind = 1:num_slashes-1
        out = [out,'\',input(slash_inds(ind)+1:slash_inds(ind+1))];
    end
    out = [out,'\',input(slash_inds(end)+1:end)];