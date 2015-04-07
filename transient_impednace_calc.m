function [f,S11_rel,Gamma,Vinc_f0] = transient_impednace_calc(Ts,Vinc,Vrefl,f0,full_Prefl)
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
% function [f,S11_rel,Gamma,Vinc_f0] = transient_impednace_calc(Ts,Vinc,Vrefl,f0,full_Prefl)
%
% Funciton to compute S11 based on computed transient Vinc (V+) and Vrefl
% (V-). First V+ and V- are expressed in the frequency domain, called Sinc
% and Srefl in this function. S11 is then just Srefl/Sinc, i.e. V-/V+ in
% the frequency domain, at the frequency f0 of the incident wave. The
% reflected power is also computed at all frequnecies relative to the
% incident power at f0. Therefore, this value is exactly S11 only at the
% input frequency f0, and relative backscattered power otherwise. Showing
% S11 at all frequencies does not make sense in this situation because
% there is no (ignoring numerical quantization error) input power at any
% other frequencies, but due to diode nonlinearilites there is "reflected"
% power at other frequencies. Therefore, S11 at these frequencies would be
% huge (ideally infinity) and not very meaningful.
% 
% Inputs:
%   Ts: Sampling period of Vinc and Vrefl [s]
%   Vinc: Computed V+ at port of interest [V]
%   Vrefl: Computed V- at port of interest [V]
%   f0: Frequency of interest [Hz]
%   full_Prefl: (optional) Boolean. If true, Prefl_rel is full FFT at all 
%       frequnecies. If false, Prefl_rel is just given for f0.
% Outputs:
%   f: one dimensional array of frequencies [Hz]
%   S11_rel: Array of relative "reflected" powers [dB]
%   Gamma: Complex reflection coefficient value at f0
%       (Take 20*log10(abs(Gamma)) to get power as in S11_rel)

    % Use Hamming window for Fourier transform (false by default) 
    HAMMING_WINDOW = false;
    
    % IF unspecified, set full_Prefl = false
    if ~exist('full_Prefl','var')
        full_Prefl = false;
    end
    
    Fs = 1/Ts; % Sampling frequency [Hz]
    NFFT = length(Vinc); % Length of FFT to use
    f0ind = f0/Fs*NFFT; % Index (non-integer is ok) of desired frequency
    
    % Run Goertzel algorithm to get incident and reflected voltage phasor
    % at desired frequency f0
    Vinc_f0 = goertzel_general_shortened(Vinc,f0ind)/NFFT*2;
    Vrefl_f0 = goertzel_general_shortened(Vrefl,f0ind)/NFFT*2;
    
    % Complex reflection coefficient
    Gamma = Vrefl_f0./Vinc_f0;
    
    % Compute indicent "power" (unscaled by Rin at this point)
    Pinc_f0 = 20*log10(abs(Vinc_f0));
    
    if full_Prefl
        % If relative reflected power is desired at all frequencies, perform
        % FFT on voltages and scale reflected power by incident power at f0
        if HAMMING_WINDOW
            Vrefl = Vrefl.*(hamming(length(Vrefl)).');
        end
        [f,Vrefl_f_all] = ffft(Vrefl,Fs,false);
        Vrefl_f_all = Vrefl_f_all*2;
        S11_rel = 20*log10(abs(Vrefl_f_all))-Pinc_f0;
    else
        f=f0;
        S11_rel = 20*log10(abs(Vrefl_f0))-Pinc_f0;
    end
end
    
    
    
    