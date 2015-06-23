// ============================================================================
// 2011 Robert Finch
//
//	WXGASyncGen1680x1050_60Hz.v
//		WXGA sync generator
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
//
//
//	WXGA video sync generator.
//
//	Input clock:     73.529 MHz (50 MHz * 25/17)
//	Horizontal freq: 65.186 kHz	(generated)
//	Vertical freq:   59.968  Hz (generated)
//
//	This module generates the basic sync timing signals required for a
//	WXGA display.
//
//	Note to self
//	Webpack 13.1i  xc3s1200e-4fg320
//	26 FF's / 53 slices / 97 LUTs / 152.532 MHz (speed Spartan3e-4)
// ============================================================================

module WXGASyncGen1680x1050_60Hz(rst, clk, hSync, vSync, blank, border, eol, eof);
// 147.136320 MHz
// 73.56816 Mhz
// 73.529412 MHz actual 50 * 25/17
parameter phSyncOn  = 48;		//   48 front porch
parameter phSyncOff = 136;		//   92 sync
parameter phBlankOff = 280;		//  144 back porch
parameter phBorderOff = 284;	//    4 border
parameter phBorderOn = 1124;	//  840 display
parameter phBlankOn = 1128;		//    4 border
parameter phTotal = 1128;		// 1128 total clocks
// 65220 = 60 * 1088 kHz
parameter pvSyncOn  = 1;		//    1 front porch
parameter pvSyncOff = 4;		//    3 vertical sync
parameter pvBlankOff = 34;		//   30 back porch
parameter pvBorderOff = 36;		//    2 border
parameter pvBorderOn = 1086;	// 1050 display
parameter pvBlankOn = 1087;  	//    1 border
parameter pvTotal = 1087;		// 1087 total scan lines
// 60 Hz
// 840x1050
input rst;			// reset
input clk;			// video clock
output hSync, vSync;	// sync outputs
output blank;			// blanking output
output border;
output eol;			// end of line
output eof;			// end of frame

//---------------------------------------------------------------------
//---------------------------------------------------------------------

wire [11:0] hCtr;	// count from 1 to 2256
wire [11:0] vCtr;	// count from 1 to 1087

wire vBlank, hBlank;
reg blank;
reg border;

assign eol     = hCtr == phTotal;
assign eof     = vCtr == pvTotal && eol;

assign vSync = vCtr >= pvSyncOn && vCtr < pvSyncOff;
assign hSync = !(hCtr >= phSyncOn && hCtr < phSyncOff);
assign vBlank = vCtr >= pvBlankOn || vCtr < pvBlankOff;
assign hBlank = hCtr >= phBlankOn || hCtr < phBlankOff;
assign vBorder = vCtr >= pvBorderOn || vCtr < pvBorderOff;
assign hBorder = hCtr >= phBorderOn || hCtr < phBorderOff;

counter #(12) u1 (.rst(rst), .clk(clk), .ce(1'b1), .ld(eol), .d(12'd1), .q(hCtr) );
counter #(12) u2 (.rst(rst), .clk(clk), .ce(eol),  .ld(eof), .d(12'd1), .q(vCtr) );

always @(posedge clk)
    blank <= hBlank|vBlank;
always @(posedge clk)
    border <= hBorder|vBorder;

endmodule

