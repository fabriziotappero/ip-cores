% ICDF_GEN    Generate inverse of the normal cumulative distribution function
% 
% The calling syntax is:
%     x = icdf_gen(r)
% 
% Input:
%     z: pseudorandom numbers
% 
% Output:
%     x: Gaussian random numbers, n x 1 vector of 32-bit integer (s<16,11>)
% 

% Copyright (C) 2014, Guangxi Liu <guangxi.liu@opencores.org>
%
% This source file may be used and distributed without restriction provided
% that this copyright statement is not removed from the file and that any
% derivative work contains the original copyright notice and the associated
% disclaimer.
%
% This source file is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation; either version 2.1 of the License,
% or (at your option) any later version.
%
% This source is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
% License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with this source; if not, download it from
% http://www.opencores.org/lgpl.shtml
