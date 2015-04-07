function color_rgb = color_choice(choice)
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
% function color_rgb = color_choice(choice)
%
% Function used to create output color based of the specified index, useful
% for plotting multiple overlaid plots using the "hold on" command
%
% Inputs:
%   choice: Positive integer index specifying the color RGB values to be 
%       output. If the choice valuse is greater than the number of colors
%       in the list, the plot color will wrap around back to the first in
%       the list in a modulo fashion.
% Outputs:
%   color_rgb: Array of RGB values for the specified color

color_list = {[0,0,1],... %blue
    [1,0,0],... %red
    [0,0.4,0],... %dark green
    [1,0,1],... %magenta
    [0,1,1],... %cyan
    [1,0.65,0],... %orange
    [0.58,0,0.83],... %violet
    [0.55,0.27,0.07],... %brown
    [0,1,0],... %light green
    [0.5,0.5,0.5],... %gray
    [0,0,0]}; %black

num_colors = length(color_list);
color_rgb = color_list{mod(choice-1,num_colors)+1};