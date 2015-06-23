% CTG_SEED    Generate Combined Tausworthe Generator seed
%
% The calling syntax is:
%     z = ctg_seed(s)
%
% Input:
%     s: seed, unsigned 32-bit integer
%
% Output:
%     z: initial internal state, 3 x 1 vector of unsigned 64-bit integer

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
