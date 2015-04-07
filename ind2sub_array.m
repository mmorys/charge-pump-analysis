function indices = ind2sub_array(matsize,index)
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
% function indices = ind2sub_array(matsize,index)
%
% Function that takes as its input an array containing the size of each
% dimension of some n-dimensional matrix, and the desired index, and
% outputs the index in each dimension of the matrix, counting down from the
% first to the last index. This is similar to the MATLAB built-in function
% ind2sub, but does not require the user to output to a n-dimesnional
% output vector. The output is itself a 1xn array.

% Inputs:
%   matsize: 1xn array specifying the number of elements in each dimension
%       of an n-dimensional matrix
%   index: The single linear index desired from matrix matsize
% Outputs:
%   indices: 1xn array containing the index of each dimension corresponding
%       to the linear index

    L = prod(matsize);
    if index>L
        error('Index out of bounds.')
    end
    N = length(matsize);
    indices = ones(size(matsize));
    units = circshift(cumprod(matsize),[0,1]);
    units(1) = 1;
    for ind = N:-1:1
        if index>units(ind)
            indices(ind) = ceil(index/units(ind));
            index = index-(indices(ind)-1)*units(ind);
        end
    end