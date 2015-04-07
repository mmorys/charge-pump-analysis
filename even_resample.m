function [t_resamp,x_resamp] = even_resample(t,x,interp_type,Tsamp)
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
% function [t_resamp,x_resamp] = even_resample(t,x,interp_type,Tsamp)
%
% Function used to resample the input array with a consistent sampling
%   rate. This is useful when you need to perform a fourier transform on
%   data that is sampled at a variable sample rate.
%
% Inputs:
%   t: One-dimensional array of sampling times
%   x: Array of sampled values (must be the same size as t)
%   interp_type: (optional) Type of interpolation to use, 'linear' by 
%       default (see interp1 documentation for more details)
%   Tsamp: (optional) Sampling period to use for output (must be same units
%       as t)
% Outputs:
%   t_resamp: Evenly resampled array of time points [same units as t]
%   x_resamp: Evenly resampled array of values [same units as x]

    % interp_type is linear by default if unspecified
    if ~exist('interp_type','var')
        interp_type = 'linear';
    end
    
    % If the sampling period is unspecifed, determine it from the given
    % sampled array using the smallest recurring sampling period present in
    % the variable sample rate array t
    if ~exist('Tsamp','var')
        % Compute the sampling periods
        d = diff(t);
        % Group the sampling periods into histogram bins, with 100 sampling
        % period values in each bin on average
        % Choose a threshold which is half the average histogram bin count
        avg_vals_per_bin = 100;
        thresh = avg_vals_per_bin/2;
        num_Tlength_samples = round(length(t)/avg_vals_per_bin);
        [nelements,centers] = hist(d,num_Tlength_samples);
        % Choose as the resampling period the smallest sampling period 
        % which is also frequenct in the data. This method is to prevent
        % severly oversampling data with a miniscule sampling period that
        % may only occur once in the data.
        Tsamp_ind = find(nelements>thresh,1,'first')-1;
        if Tsamp_ind<1
            Tsamp_ind = 1;
        end
        Tsamp = centers(Tsamp_ind);
    end
    
    % Resample t and x, using specified interpolation method
    t_resamp = t(1):Tsamp:t(end);
    x_resamp = interp1(t,x,t_resamp,interp_type);
    