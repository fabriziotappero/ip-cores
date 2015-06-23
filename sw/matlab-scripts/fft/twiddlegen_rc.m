function twiddlegen_rc(N,tbits) 
%   twiddlegen_rc(N,tbits) 
%       Thi s function generates all the roms needed for an 
%       FFT  of N points.  Twiddle factors are tbits wide. 
% 
%       This program uses: 
%       romgen_rc.m 
%            |-frac2bin.m 
%           |-writeb in.m 
% 
 
numpoints=N; 
rnum=1; 
while numpoints>4 
    romgen_rc(numpoints,N,tbits,rnum); 
    rnum=rnum+1; 
    numpoints=numpoints/4; 
end 
