// ============================================================================
// (C) 2012 Robert Finch
//
//	WXGASyncGen1366x768_60Hz.v
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
//	Input clock:     85.86 MHz (50 MHz * 12/7) (85.7142)
//	Horizontal freq: 47.7 kHz	(generated) (47.619KHz)
//	Vertical freq:   60.00  Hz (generated)  (59.89 Hz)
//
//	This module generates the basic sync timing signals required for a
//	WXGA display.
//
// ============================================================================

module WXGASyncGen1366x768_60Hz(rst, clk, hSync, vSync, blank, border);
parameter phSyncOn  = 72;		//   72 front porch
parameter phSyncOff = 216;		//  144 sync
parameter phBlankOff = 434;		//  212 back porch
parameter phBorderOff = 434;	//    0 border
parameter phBorderOn = 1800;	// 1366 display
parameter phBlankOn = 1800;		//    0 border
parameter phTotal = 1800;		// 1800 total clocks
// 47.7 = 60 * 795 kHz
parameter pvSyncOn  = 2;		//    1 front porch
parameter pvSyncOff = 5;		//    3 vertical sync
parameter pvBlankOff = 27;		//   23 back porch
parameter pvBorderOff = 27;		//    2 border	0
parameter pvBorderOn = 795;		//  768 display
parameter pvBlankOn = 795;  	//    1 border	0
parameter pvTotal = 795;		//  795 total scan lines
// 60 Hz
// 1366x768
input rst;			// reset
input clk;			// video clock
output reg hSync, vSync;	// sync outputs
output blank;			// blanking output
output border;

//---------------------------------------------------------------------
//---------------------------------------------------------------------

wire [11:0] hCtr;	// count from 1 to 1800
wire [11:0] vCtr;	// count from 1 to 795

wire vBlank, hBlank;
wire hSync1,vSync1;
reg blank;
reg border;

wire eol = hCtr==phTotal;
wire eof = vCtr==pvTotal && eol;

assign vSync1 = vCtr >= pvSyncOn && vCtr < pvSyncOff;
assign hSync1 = !(hCtr >= phSyncOn && hCtr < phSyncOff);
assign vBlank = vCtr >= pvBlankOn || vCtr < pvBlankOff;
assign hBlank = hCtr >= phBlankOn || hCtr < phBlankOff;
assign vBorder = vCtr >= pvBorderOn || vCtr < pvBorderOff;
assign hBorder = hCtr >= phBorderOn || hCtr < phBorderOff;

counter #(12) u1 (.rst(rst), .clk(clk), .ce(1'b1), .ld(eol), .d(12'd1), .q(hCtr) );
counter #(12) u2 (.rst(rst), .clk(clk), .ce(eol),  .ld(eof), .d(12'd1), .q(vCtr) );

always @(posedge clk)
    blank <= #1 hBlank|vBlank;
always @(posedge clk)
    border <= #1 hBorder|vBorder;
always @(posedge clk)
	hSync <= #1 hSync1;
always @(posedge clk)
	vSync <= #1 vSync1;

endmodule

