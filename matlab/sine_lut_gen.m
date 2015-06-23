% This m-file generates the LUT files in '../VHDL/sine_lut'
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

functionhandle = @sine_lut;
global phase_width;

for phase_width=8:2:16
    for ampl_width=8:2:16
        generate_vhdl_lut('sine_lut','PHASE_WIDTH', phase_width, 'AMPL_WIDTH', ampl_width, functionhandle, 'sine_lut', '../VHDL/sine_lut')
    end;
end;