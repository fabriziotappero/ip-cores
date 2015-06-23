// ============================================================================
// 2011 Robert Finch
//
//	WXGASyncGen1680x1050_60Hz_tb.v
//		WXGA sync generator test bench
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================

module WXGASyncGen1680x1050_60Hz_tb();

reg clk;
reg rst;

initial begin
	clk = 1;
	rst = 0;
	#100 rst = 1;
	#100 rst = 0;
end

always #6.8000 clk = ~clk;	//  73.529 MHz

WXGASyncGen1680x1050_60Hz u1
(
.rst(rst),
.clk(clk),
.hSync(),
.vSync(),
.blank(),
.border(),
.eol(),
.eof()
);

endmodule
