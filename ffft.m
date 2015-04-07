function [f,X] = ffft(x,Fs,useNFFT,oversampling)
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
% function [f,X] = ffft(x,Fs,useNFFT,oversampling)
%
% A wrapper function for MATLAB's fft function that outputs the frequency 
% vector and fft values, properly scaled and shifted. To plot magnitude of
% the Fourier transformed data, simply use plot(f,abs(X)).
%
% Inputs:
%   x: complex data vector
%   Fs: sampling rate (Hz)
%   useNFFT: (optional) Boolean value. If true, the fft length is
%       2^nextpow2(length(x)+oversampling). If false, the fft length is
%       length(x).
%   oversampling: (optional) See useNFFT above
% Outputs:
%   f: Vector of frequencies (Hz)
%   X: Vector of complex fft amplitudes, already fftshifted to align
%       with double sided spectrum of f

if ~exist('useNFFT','var')
    useNFFT = false;
end
if ~exist('oversampling','var')
    oversampling = 0;
end

L = length(x);
if useNFFT
    NFFT = 2^(nextpow2(L)+oversampling);
else
    NFFT = L;
end
f = linspace(-Fs/2,Fs/2-Fs/NFFT,NFFT);
X = fftshift(fft(x,NFFT))/NFFT;