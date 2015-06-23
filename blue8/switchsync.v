/*
    This file is part of Blue8.

    Foobar is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Foobar is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with Blue8.  If not, see <http://www.gnu.org/licenses/>.

    Blue8 by Al Williams alw@al-williams.com

*/

// this synchronizes a "switch" which may be async and
// long, and this outputs a single pulse. The switch is assmed
// to already be debounced
module switchsync(clk,d,q);
input clk,d;
output q;
reg q;
reg s0;	 
initial q=0;
initial s0=0;
always @(posedge clk) begin
  if (s0==1'b0 && d==1'b1) q=1'b1; else q=1'b0;
  s0=d;
end
endmodule