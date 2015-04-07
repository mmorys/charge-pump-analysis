function [DC_level,DC_start,RMS_ripple,DC_REACHED] = steady_state_detect(x,slope_change_thresh,DC_periods,T_fund)
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
% function [DC_level,DC_start,RMS_ripple,DC_REACHED] = steady_state_detect(x,slope_change_thresh,DC_periods,T_fund)
%
% Function for detecting steady state convergence of a signal x. The steady
% state convergence tests for the average change of the signal, and
% determines that steady state occurs when the average change of the signal
% amplitude approaches 0. Steady state will be determined where the average
% rate of change of the signal is slope_change_thresh times smaller than
% the average rate of change of the signal at its beginning.
%
% Inputs:
%   x: One-dimensional signal on which steady state detection is to be
%       performed
%   slope_change_thresh: The factor by which the average rate of change of
%       the signal must decrease for steady state to be declared
%   DC_periods: (optional) The minimum number of T_fund periods that must
%       be present in x after the beginning of steady state detection for
%       steady state to be declared
%   T_fund: (optional)The fundamental discrete freuqency present in the 
%       steady state of the signal (To go from T in Hz to T_fund, simply 
%       run T_fund=round(T/Ts) where Ts is the sampling period in Hz)
% Outputs:
%   DC_level: Mean amplitude of the signal at steady state
%   DC_start: Index of x at which steady state is determined to start
%   RMS_ripple: RMS ripple amplitude in the steady state region
%   DC_REACHED: Boolean value, true if DC_start has been found to exist in
%       the input signal x and the duration of the steady state region is
%       longer than DC_periods*T_fund


    DC_offset = 0.02; % The startt_ind is chosen where x_avg < DC_level*(1-DC_offset)
    DC_level = 0;
    DC_start = 0;
    DC_REACHED = false;

    % Set DC_periods to 50 by defualt
    if ~exist('DC_periods','var')
        DC_periods = 50;
    end
    
    % Find strongest frequency component of signal and assume that as the
    % fundamental frequency, if none is provided by the user
    if ~exist('T_fund','var')
        len = length(x);
        start_ind = floor(len/2);
        [f,X] = ffft(x(start_ind:end),1,true,0);
        f_zero_ind = length(f)/2+1;
        dc_freqs_to_ignore = 3;
        [~,peakF_ind] = max(abs(X(f_zero_ind+dc_freqs_to_ignore:end)));
        peakF_ind = peakF_ind+f_zero_ind+dc_freqs_to_ignore-1;
        T_fund = round(1/f(peakF_ind));
    end
    
    % Determine how many fundamental periods are in the signal
    n_periods = floor(length(x)/T_fund);
    
    % Quit if the signal is less than the number of periods needed for
    % steady state convergence
    if(n_periods<DC_periods)
        DC_level = mean(x);
        return
%         error('Insufficient length of x for specified number of DC_periods needed');
    end
    
    % Perform a sliding average of the signal, averaginf out over one
    % fundamental period
    x_avg = zeros(n_periods,1);
    for ind = 1:n_periods
        x_avg(ind) = mean(x((ind-1)*T_fund+1:ind*T_fund));
    end
    
    % Compute DC level and start time
    DC_level = mean(x_avg(end-DC_periods:end));
    
    % Compute DC start time, or time when DC state reached
    if DC_level>=0
        DC_start_ind = find(x_avg>=DC_level*(1-DC_offset) & x_avg<=DC_level*(1+DC_offset),1,'first');
    else
        DC_start_ind = find(x_avg<=DC_level*(1-DC_offset) & x_avg>=DC_level*(1+DC_offset),1,'first');
    end
    DC_start = round((DC_start_ind-0.5)*T_fund);
    
    % Compute RMS ripple level of output voltage
    RMS_ripple = sqrt(mean((x(DC_start:end)-DC_level).^2));
    
    % Check if DC convergence criterion is met
    dx_avg = abs(diff(x_avg));
    [max_slope,max_slope_index] = max(dx_avg);
    
    % End if the steepest slope in the signal is detected within the
    % required steady state region
    if max_slope_index >= n_periods-DC_periods
        return
%         error('Insufficient length of x. Max slope of x detected in DC region.')
    end
    
    % Determine if the slope change criterion is met for steady state to be
    % declared
    final_slope_firsthalf = mean(dx_avg(end-DC_periods:end-ceil(DC_periods/2)));
    final_slope_secondhalf = mean(dx_avg(end-floor(DC_periods/2):end));
    final_slope = max([final_slope_firsthalf,final_slope_secondhalf]);
    
    slope_change_meas = max_slope/final_slope;
    if slope_change_meas > slope_change_thresh
        DC_REACHED = true;
    end
    