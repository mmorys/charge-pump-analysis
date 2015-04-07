function y = goertzel_general_shortened(x,indvec)
%
% --------------------- Begin BSD License ---------------------
% Copyright (c) 2012, Pavel Rajmic
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
% --------------------- End BSD License ---------------------
%
% GOERTZEL_GENERAL_SHORTENED(X,INDVEC) computes DTFT of one-dimensional
% signal X at 'indices' contained in INDVEC, using the generalized (and shortened)
% second-order Goertzel algorithm.
% Thanks to the generalization, the 'indices' can be non-integer valued
% in the range 0 to N-1, where N is the length of X.
% (Index 0 corresponds to the DC component.)
% Integers in INDVEC result in the classical DFT coefficients.
%
% The output is a column complex vector of length LENGTH(INDVEC) containing
% the desired DTFT values.
%
% See also: goertzel_classic.
       
% (c) 2009-2012, Pavel Rajmic, Brno University of Technology, Czech Rep.



%% Check the input arguments
if nargin < 2
    error('Not enough input arguments')
end
if ~isvector(x) || isempty(x)
    error('X must be a nonempty vector')
end

if ~isvector(indvec) || isempty(indvec)
    error('INDVEC must be a nonempty vector')
end
if ~isreal(indvec)
    error('INDVEC must contain real numbers')
end
% if isinteger(indvec)
%     disp('Warning: The traditional Goertzel algorithm is a bit more effective in case of INDVEC being integer-valued')
% end

lx = length(x);
x = reshape(x,lx,1); %forcing x to be column


%% Initialization
no_freq = length(indvec); %number of frequencies to compute
y = zeros(no_freq,1); %memory allocation for the output coefficients


%% Computation via second-order system
% loop over the particular frequencies
for cnt_freq = 1:no_freq
    
    %for a single frequency:
    %a/ precompute the constants
    pik_term = 2*pi*(indvec(cnt_freq))/(lx);
    cos_pik_term2 = cos(pik_term) * 2;
    cc = exp(-1i*pik_term); % complex constant
    %b/ state variables
    s0 = 0;
    s1 = 0;
    s2 = 0;
    %c/ 'main' loop
    for ind = 1:lx-1 %number of iterations is (by one) less than the length of signal
        %new state
        s0 = x(ind) + cos_pik_term2 * s1 - s2;  % (*)
        %shifting the state variables
        s2 = s1;
        s1 = s0;
    end
    %d/ final computations
    s0 = x(lx) + cos_pik_term2 * s1 - s2; %correspond to one extra performing of (*)
    y(cnt_freq) = s0 - s1*cc; %resultant complex coefficient
    
    %complex multiplication substituting the last iteration
    %and correcting the phase for (potentially) non-integer valued
    %frequencies at the same time
    y(cnt_freq) = y(cnt_freq) * exp(-1i*pik_term*(lx-1));
end