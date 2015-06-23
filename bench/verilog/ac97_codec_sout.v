/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Codec                                       ////
////  Serial Output Block                                        ////
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
//  $Id: ac97_codec_sout.v,v 1.2 2002-09-19 06:36:19 rudi Exp $
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

module ac97_codec_sout(clk, rst,

	sync, slt0, slt1, slt2, slt3, slt4, slt5,
	slt6, slt7, slt8, slt9, slt10, slt11, slt12,

	sdata_out
	);

input		clk, rst;

// --------------------------------------
// Misc Signals
input		sync;
input	[15:0]	slt0;
input	[19:0]	slt1;
input	[19:0]	slt2;
input	[19:0]	slt3;
input	[19:0]	slt4;
input	[19:0]	slt5;
input	[19:0]	slt6;
input	[19:0]	slt7;
input	[19:0]	slt8;
input	[19:0]	slt9;
input	[19:0]	slt10;
input	[19:0]	slt11;
input	[19:0]	slt12;

// --------------------------------------
// AC97 Codec Interface
output		sdata_out;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg		sdata_out_r;

reg	[15:0]	slt0_r;
reg	[19:0]	slt1_r;
reg	[19:0]	slt2_r;
reg	[19:0]	slt3_r;
reg	[19:0]	slt4_r;
reg	[19:0]	slt5_r;
reg	[19:0]	slt6_r;
reg	[19:0]	slt7_r;
reg	[19:0]	slt8_r;
reg	[19:0]	slt9_r;
reg	[19:0]	slt10_r;
reg	[19:0]	slt11_r;
reg	[19:0]	slt12_r;

reg		sync_r;
wire		sync_e;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

// Sync Edge detector
always @(posedge clk)
	sync_r <= #1 sync;

assign sync_e = sync & !sync_r;

////////////////////////////////////////////////////////////////////
//
// Serial Shift Register
//

/*
always @(negedge clk)
	sdata_out_r <= #1 slt0_r[15];

//assign	sdata_out = sdata_out_r;
*/

assign	sdata_out = slt0_r[15];

always @(posedge clk)
	if(sync_e)	slt0_r <= #1 slt0;
	else		slt0_r <= #1 {slt0_r[14:0], slt1_r[19]};

always @(posedge clk)
	if(sync_e)	slt1_r <= #1 slt1;
	else		slt1_r <= #1 {slt1_r[18:0], slt2_r[19]};

always @(posedge clk)
	if(sync_e)	slt2_r <= #1 slt2;
	else		slt2_r <= #1 {slt2_r[18:0], slt3_r[19]};

always @(posedge clk)
	if(sync_e)	slt3_r <= #1 slt3;
	else		slt3_r <= #1 {slt3_r[18:0], slt4_r[19]};

always @(posedge clk)
	if(sync_e)	slt4_r <= #1 slt4;
	else		slt4_r <= #1 {slt4_r[18:0], slt5_r[19]};

always @(posedge clk)
	if(sync_e)	slt5_r <= #1 slt5;
	else		slt5_r <= #1 {slt5_r[18:0], slt6_r[19]};

always @(posedge clk)
	if(sync_e)	slt6_r <= #1 slt6;
	else		slt6_r <= #1 {slt6_r[18:0], slt7_r[19]};

always @(posedge clk)
	if(sync_e)	slt7_r <= #1 slt7;
	else		slt7_r <= #1 {slt7_r[18:0], slt8_r[19]};

always @(posedge clk)
	if(sync_e)	slt8_r <= #1 slt8;
	else		slt8_r <= #1 {slt8_r[18:0], slt9_r[19]};

always @(posedge clk)
	if(sync_e)	slt9_r <= #1 slt9;
	else		slt9_r <= #1 {slt9_r[18:0], slt10_r[19]};

always @(posedge clk)
	if(sync_e)	slt10_r <= #1 slt10;
	else		slt10_r <= #1 {slt10_r[18:0], slt11_r[19]};

always @(posedge clk)
	if(sync_e)	slt11_r <= #1 slt11;
	else		slt11_r <= #1 {slt11_r[18:0], slt12_r[19]};

always @(posedge clk)
	if(sync_e)	slt12_r <= #1 slt12;
	else		slt12_r <= #1 {slt12_r[18:0], 1'b0 };


endmodule

