% This is the definition of the function to be generated as LUT
% 
% Copyright (C) 2009 Martin Kumm
% 
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program; 
% if not, see <http://www.gnu.org/licenses/>.

function ret = sine_lut(x)
global phase_width;
ret = sin((x-1)/2^phase_width * 2 * pi);
