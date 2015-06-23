/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Codec                                       ////
////  Serial Input Block                                         ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/ac97_ctrl/ ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: ac97_codec_sin.v,v 1.2 2002-09-19 06:36:19 rudi Exp $
//
//  $Date: 2002-09-19 06:36:19 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1  2002/02/13 08:22:32  rudi
//
//               Added test bench for public release
//
//
//
//

`include "ac97_defines.v"

module ac97_codec_sin(clk, rst,

	sync,
	slt0, slt1, slt2, slt3, slt4, slt5,
	slt6, slt7, slt8, slt9, slt10, slt11, slt12,

	sdata_in
	);

input		clk, rst;

// --------------------------------------
// Misc Signals
input		sync;
output	[15:0]	slt0;
output	[19:0]	slt1;
output	[19:0]	slt2;
output	[19:0]	slt3;
output	[19:0]	slt4;
output	[19:0]	slt5;
output	[19:0]	slt6;
output	[19:0]	slt7;
output	[19:0]	slt8;
output	[19:0]	slt9;
output	[19:0]	slt10;
output	[19:0]	slt11;
output	[19:0]	slt12;

// --------------------------------------
// AC97 Codec Interface
input		sdata_in;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg		sdata_in_r;
reg	[19:0]	sr;

reg	[15:0]	slt0;
reg	[19:0]	slt1;
reg	[19:0]	slt2;
reg	[19:0]	slt3;
reg	[19:0]	slt4;
reg	[19:0]	slt5;
reg	[19:0]	slt6;
reg	[19:0]	slt7;
reg	[19:0]	slt8;
reg	[19:0]	slt9;
reg	[19:0]	slt10;
reg	[19:0]	slt11;
reg	[19:0]	slt12;

wire	[12:0]	le;

////////////////////////////////////////////////////////////////////
//
// Latch Enable logic
//

// Sync Edge Detector
reg		sync_r;
wire		sync_e;

always @(posedge clk)
	sync_r <= #1 sync;

assign sync_e = sync & !sync_r;

// Frame Counter
reg	[7:0]	cnt;

always @(posedge clk)
	if(sync_e)	cnt <= #1 0;
	else		cnt <= #1 cnt + 1;

assign le[0] = (cnt == 16);
assign le[1] = (cnt == 36);
assign le[2] = (cnt == 56);
assign le[3] = (cnt == 76);
assign le[4] = (cnt == 96);
assign le[5] = (cnt == 116);
assign le[6] = (cnt == 136);
assign le[7] = (cnt == 156);
assign le[8] = (cnt == 176);
assign le[9] = (cnt == 196);
assign le[10] = (cnt == 216);
assign le[11] = (cnt == 236);
assign le[12] = (cnt == 0);

////////////////////////////////////////////////////////////////////
//
// Output registers
//

always @(posedge clk)
	if(le[0])	slt0 <= #1 sr[15:0];

always @(posedge clk)
	if(le[1])	slt1 <= #1 sr;

always @(posedge clk)
	if(le[2])	slt2 <= #1 sr;

always @(posedge clk)
	if(le[3])	slt3 <= #1 sr;

always @(posedge clk)
	if(le[4])	slt4 <= #1 sr;

always @(posedge clk)
	if(le[5])	slt5 <= #1 sr;

always @(posedge clk)
	if(le[6])	slt6 <= #1 sr;

always @(posedge clk)
	if(le[7])	slt7 <= #1 sr;

always @(posedge clk)
	if(le[8])	slt8 <= #1 sr;

always @(posedge clk)
	if(le[9])	slt9 <= #1 sr;

always @(posedge clk)
	if(le[10])	slt10 <= #1 sr;

always @(posedge clk)
	if(le[11])	slt11 <= #1 sr;

always @(posedge clk)
	if(le[12])	slt12 <= #1 sr;

////////////////////////////////////////////////////////////////////
//
// Serial Shift Register
//

always @(negedge clk)
	sdata_in_r <= #1 sdata_in;

always @(posedge clk)
	sr <= #1 {sr[18:0], sdata_in_r };

endmodule


