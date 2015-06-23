/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller Definitions                      ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.5  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.4  2002/03/11 03:21:22  rudi
//
//               - Added defines to select fifo depth between 4, 8 and 16 entries.
//
//               Revision 1.3  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.2  2001/08/10 08:09:42  rudi
//
//               - Removed RTY_O output.
//               - Added Clock and Reset Inputs to documentation.
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//
//               Revision 1.1  2001/08/03 06:54:49  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:14  rudi
//               Initial Checkin
//
//
//
//

`timescale 1ns / 10ps

/////////////////////////////////////////////////////////////////////
// This AC97 Controller supports up to 6 Output and 3 Input Channels.
// Comment out the define statement for which channels you do not wish
// to support in your implementation. The main Left and Right channels
// are always supported. 

// Surround Left + Right
// `define AC97_SURROUND		1

// Center Channel
// `define AC97_CENTER		1

// LFE Channel
// `define AC97_LFE		1

// Stereo Input
// `define AC97_SIN		1

// Mono Microphone Input
// `define AC97_MICIN		1

/////////////////////////////////////////////////////////////////////
//
// This define selects how the WISHBONE interface determines if
// the internal register file is selected.
// This should be a simple address decoder. "wb_addr_i" is the
// WISHBONE address bus (32 bits wide).
// **** tame:
// The AC97 controller has 16 registers occupying an address space of
// 17 32-bit words (1 address is reserved). 5 bits are needed to decode
// the individual registers.
// With the configuration of AC97_REG_SEL as 0xfff from the MSB's of the
// AHB address, the AC97 core must reside in the I/O area of the LEON
// AHB controller.
`define	AC97_REG_SEL		(wb_addr_i[31:20] == 12'h fff)

/////////////////////////////////////////////////////////////////////
//
// This is a prescaler that generates a pulse every 250 nS.
// The value here should one less than the actually calculated
// value.
// For a 200 MHz wishbone clock, this value is 49 (50-1).
// **** tame:
// For a 25 MHz clock, the prescaler value is 5, roughly.
// (250 ns / 40 ns = 6.25; 6.25 - 1 = 5.25 -> integer 5)
`define	AC97_250_PS	6'h5

/////////////////////////////////////////////////////////////////////
//
// AC97 Cold reset Must be asserted for at least 1uS. The AC97
// controller will stretch the reset pulse to at least 1uS.
// The reset timer is driven by the AC97_250_PS prescaler.
// This value should probably be never changed. Adjust the
// AC97_250_PS instead.
// **** tame:
// Since the prescaler cycle is less than only 240 ns instead of
// 250 ns, 5 cycles are needed.
`define	AC97_RST_DEL	3'h4

/////////////////////////////////////////////////////////////////////
//
// This value indicates for how long the resume signaling (asserting sync)
// should be done. This counter is driven by the AC97_250_PS prescaler.
// This value times 250nS is the duration of the resume signaling.
// The actual value must be incremented by one, as we do not know
// the current state of the prescaler, and must somehow insure we
// meet the minimum 1uS length. This value should probably be never
// changed. Modify the AC97_250_PS instead.
`define AC97_RES_SIG	3'h5

/////////////////////////////////////////////////////////////////////
//
// If the bit clock is absent for at least two "predicted" bit
// clock periods (163 nS) we should signal "suspended".
// This value defines how many WISHBONE cycles must pass without
// any change on the bit clock input before we signal "suspended".
// For a 200 MHz WISHBONE clock this would be about (163/5) 33 cycles.
`define AC97_SUSP_DET	6'h5

/////////////////////////////////////////////////////////////////////
//
// Select FIFO Depth. For most applications a FIFO depth of 4 should
// be sufficient. For systems with slow interrupt processing or slow
// DMA response or systems with low internal bus bandwidth you might
// want to increase the FIFO sizes to reduce the interrupt/DMA service
// request frequencies.
// Service request frequency can be calculated as follows:
// Channel bandwidth / FIFO size = Service Request Frequency
// For Example: 48KHz / 4 = 12 kHz
//
// Select Input FIFO depth by uncommenting ONE of the following define
// statements:
`define AC97_IN_FIFO_DEPTH_4
//`define AC97_IN_FIFO_DEPTH_8
//`define AC97_IN_FIFO_DEPTH_16
//
// Select Output FIFO depth by uncommenting ONE of the following define
// statements:
`define AC97_OUT_FIFO_DEPTH_4
//`define AC97_OUT_FIFO_DEPTH_8
//`define AC97_OUT_FIFO_DEPTH_16

/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  Codec Register Access Module                               ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.3  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.2  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.1  2001/08/03 06:54:49  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:18  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_cra(clk, rst,

		crac_we, crac_din, crac_out,
		crac_wr_done, crac_rd_done,

		valid, out_slt1, out_slt2,
		in_slt2,

		crac_valid, crac_wr
		);

input		clk, rst;
input		crac_we;
output	[15:0]	crac_din;
input	[31:0]	crac_out;
output		crac_wr_done, crac_rd_done;

input		valid;
output	[19:0]	out_slt1;
output	[19:0]	out_slt2;
input	[19:0]	in_slt2;

output		crac_valid;
output		crac_wr;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg		crac_wr;
reg		crac_rd;
reg		crac_rd_done;
reg	[15:0]	crac_din;
reg		crac_we_r;
reg		valid_r;
wire		valid_ne;
wire		valid_pe;
reg		rdd1, rdd2, rdd3;

////////////////////////////////////////////////////////////////////
//
// Codec Register Data Path
//

// Control
assign out_slt1[19]    = crac_out[31];
assign out_slt1[18:12] = crac_out[22:16];
assign out_slt1[11:0]  = 12'h0;

// Write Data
assign out_slt2[19:4] = crac_out[15:0];
assign out_slt2[3:0] = 4'h0;

// Read Data
always @(posedge clk or negedge rst)
   begin
	if(!rst)		crac_din <= #1 16'h0;
	else
	if(crac_rd_done)	crac_din <= #1 in_slt2[19:4];
   end

////////////////////////////////////////////////////////////////////
//
// Codec Register Access Tracking
//

assign crac_valid = crac_wr | crac_rd;

always @(posedge clk)
	crac_we_r <= #1 crac_we;

always @(posedge clk or negedge rst)
	if(!rst)			crac_wr <= #1 1'b0;
	else
	if(crac_we_r & !crac_out[31])	crac_wr <= #1 1'b1;
	else
	if(valid_ne)			crac_wr <= #1 1'b0;

assign crac_wr_done = crac_wr & valid_ne;

always @(posedge clk or negedge rst)
	if(!rst)			crac_rd <= #1 1'b0;
	else
	if(crac_we_r & crac_out[31])	crac_rd <= #1 1'b1;
	else
	if(rdd1 & valid_pe)		crac_rd <= #1 1'b0;

always @(posedge clk or negedge rst)
	if(!rst)			rdd1 <= #1 1'b0;
	else
	if(crac_rd & valid_ne)		rdd1 <= #1 1'b1;
	else
	if(!crac_rd)			rdd1 <= #1 1'b0;

always @(posedge clk or negedge rst)
	if(!rst)					rdd2 <= #1 1'b0;
	else
	if( (crac_rd & valid_ne) | (!rdd3 & rdd2) )	rdd2 <= #1 1'b1;
	else
	if(crac_rd_done)				rdd2 <= #1 1'b0;

always @(posedge clk or negedge rst)
	if(!rst)			rdd3 <= #1 1'b0;
	else
	if(rdd2 & valid_pe)		rdd3 <= #1 1'b1;
	else
	if(crac_rd_done)		rdd3 <= #1 1'b0;

always @(posedge clk)
	crac_rd_done <= #1 rdd3 & valid_pe;

always @(posedge clk)
	valid_r <= #1 valid;

assign valid_ne = !valid & valid_r;

assign valid_pe = valid & !valid_r;

endmodule

/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  DMA Interface                                              ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.4  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.3  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.2  2001/08/10 08:09:42  rudi
//
//               - Removed RTY_O output.
//               - Added Clock and Reset Inputs to documentation.
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//
//               Revision 1.1  2001/08/03 06:54:49  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:18  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_dma_if(clk, rst,
		o3_status, o4_status, o6_status, o7_status, o8_status, o9_status,
		o3_empty, o4_empty, o6_empty, o7_empty, o8_empty, o9_empty,
		i3_status, i4_status, i6_status,
		i3_full, i4_full, i6_full,

		oc0_cfg, oc1_cfg, oc2_cfg, oc3_cfg, oc4_cfg, oc5_cfg,
		ic0_cfg, ic1_cfg, ic2_cfg,

		dma_req, dma_ack);

input		clk, rst;
input	[1:0]	o3_status, o4_status, o6_status, o7_status, o8_status, o9_status;
input		o3_empty, o4_empty, o6_empty, o7_empty, o8_empty, o9_empty;
input	[1:0]	i3_status, i4_status, i6_status;
input		i3_full, i4_full, i6_full;
input	[7:0]	oc0_cfg;
input	[7:0]	oc1_cfg;
input	[7:0]	oc2_cfg;
input	[7:0]	oc3_cfg;
input	[7:0]	oc4_cfg;
input	[7:0]	oc5_cfg;
input	[7:0]	ic0_cfg;
input	[7:0]	ic1_cfg;
input	[7:0]	ic2_cfg;
output	[8:0]	dma_req;
input	[8:0]	dma_ack;

////////////////////////////////////////////////////////////////////
//
// DMA Request Modules
//

ac97_dma_req u0(.clk(		clk		),
		.rst(		rst		),
		.cfg(		oc0_cfg		),
		.status(	o3_status	),
		.full_empty(	o3_empty	),
		.dma_req(	dma_req[0]	),
		.dma_ack(	dma_ack[0]	)
		);

ac97_dma_req u1(.clk(		clk		),
		.rst(		rst		),
		.cfg(		oc1_cfg		),
		.status(	o4_status	),
		.full_empty(	o4_empty	),
		.dma_req(	dma_req[1]	),
		.dma_ack(	dma_ack[1]	)
		);

`ifdef AC97_CENTER
ac97_dma_req u2(.clk(		clk		),
		.rst(		rst		),
		.cfg(		oc2_cfg		),
		.status(	o6_status	),
		.full_empty(	o6_empty	),
		.dma_req(	dma_req[2]	),
		.dma_ack(	dma_ack[2]	)
		);
`else
assign dma_req[2] = 1'b0;
`endif

`ifdef AC97_SURROUND
ac97_dma_req u3(.clk(		clk		),
		.rst(		rst		),
		.cfg(		oc3_cfg		),
		.status(	o7_status	),
		.full_empty(	o7_empty	),
		.dma_req(	dma_req[3]	),
		.dma_ack(	dma_ack[3]	)
		);

ac97_dma_req u4(.clk(		clk		),
		.rst(		rst		),
		.cfg(		oc4_cfg		),
		.status(	o8_status	),
		.full_empty(	o8_empty	),
		.dma_req(	dma_req[4]	),
		.dma_ack(	dma_ack[4]	)
		);
`else
assign dma_req[3] = 1'b0;
assign dma_req[4] = 1'b0;
`endif

`ifdef AC97_LFE
ac97_dma_req u5(.clk(		clk		),
		.rst(		rst		),
		.cfg(		oc5_cfg		),
		.status(	o9_status	),
		.full_empty(	o9_empty	),
		.dma_req(	dma_req[5]	),
		.dma_ack(	dma_ack[5]	)
		);
`else
assign dma_req[5] = 1'b0;
`endif

`ifdef AC97_SIN
ac97_dma_req u6(.clk(		clk		),
		.rst(		rst		),
		.cfg(		ic0_cfg		),
		.status(	i3_status	),
		.full_empty(	i3_full		),
		.dma_req(	dma_req[6]	),
		.dma_ack(	dma_ack[6]	)
		);

ac97_dma_req u7(.clk(		clk		),
		.rst(		rst		),
		.cfg(		ic1_cfg		),
		.status(	i4_status	),
		.full_empty(	i4_full		),
		.dma_req(	dma_req[7]	),
		.dma_ack(	dma_ack[7]	)
		);
`else
assign dma_req[6] = 1'b0;
assign dma_req[7] = 1'b0;
`endif

`ifdef AC97_MICIN
ac97_dma_req u8(.clk(		clk		),
		.rst(		rst		),
		.cfg(		ic2_cfg		),
		.status(	i6_status	),
		.full_empty(	i6_full		),
		.dma_req(	dma_req[8]	),
		.dma_ack(	dma_ack[8]	)
		);
`else
assign dma_req[8] = 1'b0;
`endif

endmodule


/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  DMA Request Module                                         ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.3  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.2  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.1  2001/08/03 06:54:49  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:16  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_dma_req(clk, rst, cfg, status, full_empty, dma_req, dma_ack);
input		clk, rst;
input	[7:0]	cfg;
input	[1:0]	status;
input		full_empty;
output		dma_req;
input		dma_ack;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//
reg	dma_req_d;
reg	dma_req_r1;
reg	dma_req;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(cfg or status or full_empty)
	case(cfg[5:4])	// synopsys parallel_case full_case
			// REQ = Ch_EN & DMA_EN & Status
			// 1/4 full/empty
	   2'h2: dma_req_d = cfg[0] & cfg[6] & (full_empty | (status == 2'h0));
			// 1/2 full/empty
	   2'h1: dma_req_d = cfg[0] & cfg[6] & (full_empty | (status[1] == 1'h0));
			// 3/4 full/empty
	   2'h0: dma_req_d = cfg[0] & cfg[6] & (full_empty | (status < 2'h3));
	   2'h3: dma_req_d = cfg[0] & cfg[6] & full_empty;
	endcase

always @(posedge clk)
	dma_req_r1 <= #1 dma_req_d & !dma_ack;

always @(posedge clk or negedge rst)
	if(!rst)				dma_req <= #1 1'b0;
	else
	if(dma_req_r1 & dma_req_d & !dma_ack) 	dma_req <= #1 1'b1;
	else
	if(dma_ack) 				dma_req <= #1 1'b0;

endmodule

/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  FIFO Control Module                                        ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.3  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.2  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.1  2001/08/03 06:54:49  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:18  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_fifo_ctrl(	clk, 
			valid, ch_en, srs, full_empty, req, crdy,
			en_out, en_out_l
			);
input		clk;
input		valid;
input		ch_en;		// Channel Enable
input		srs;		// Sample Rate Select
input		full_empty;	// Fifo Status
input		req;		// Codec Request
input		crdy;		// Codec Ready
output		en_out;		// Output read/write pulse
output		en_out_l;	// Latched Output

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	en_out_l, en_out_l2;
reg	full_empty_r;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
	if(!valid)	full_empty_r <= #1 full_empty;

always @(posedge clk)
	if(valid & ch_en & !full_empty_r & crdy & (!srs | (srs & req) ) )
		en_out_l <= #1 1'b1;
	else
	if(!valid & !(ch_en & !full_empty_r & crdy & (!srs | (srs & req) )) )
		en_out_l <= #1 1'b0;

always @(posedge clk)
	en_out_l2 <= #1 en_out_l & valid;

assign en_out = en_out_l & !en_out_l2 & valid;

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  Output FIFO                                                ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.5  2002/11/14 17:10:12  rudi
//               Fixed a bug in the IN-FIFO - 18 bit samples where not alligned correctly.
//
//               Revision 1.4  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.3  2002/03/11 03:21:22  rudi
//
//               - Added defines to select fifo depth between 4, 8 and 16 entries.
//
//               Revision 1.2  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:14  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

`ifdef AC97_IN_FIFO_DEPTH_4

// 4 entry deep verion of the input FIFO

module ac97_in_fifo(clk, rst, en, mode, din, we, dout, re, status, full, empty);

input		clk, rst;
input		en;
input	[1:0]	mode;
input	[19:0]	din;
input		we;
output	[31:0]	dout;
input		re;
output	[1:0]	status;
output		full;
output		empty;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	mem[0:3];
reg	[31:0]	dout;

reg	[3:0]	wp;
reg	[2:0]	rp;

wire	[3:0]	wp_p1;

reg	[1:0]	status;
reg	[15:0]	din_tmp1;
reg	[31:0]	din_tmp;
wire		m16b;
reg		full, empty;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign m16b = (mode == 2'h0);	// 16 Bit Mode

always @(posedge clk)
	if(!en)		wp <= #1 4'h0;
	else
	if(we)		wp <= #1 wp_p1;

assign wp_p1 = m16b ? (wp + 4'h1) : (wp + 4'h2);

always @(posedge clk)
	if(!en)		rp <= #1 3'h0;
	else
	if(re)		rp <= #1 rp + 3'h1;

always @(posedge clk)
	status <= #1 ((rp[1:0] - wp[2:1]) - 2'h1);

always @(posedge clk)
	empty <= #1 (wp[3:1] == rp[2:0]) & (m16b ? !wp[0] : 1'b0);

always @(posedge clk)
	full  <= #1 (wp[2:1] == rp[1:0]) & (wp[3] != rp[2]);

// Fifo Output
always @(posedge clk)
	dout <= #1 mem[ rp[1:0] ];

// Fifo Input Half Word Latch
always @(posedge clk)
	if(we & !wp[0])	din_tmp1 <= #1 din[19:4];

always @(mode or din_tmp1 or din)
	case(mode)	// synopsys parallel_case full_case
	   2'h0: din_tmp = {din[19:4], din_tmp1};	// 16 Bit Output
	   2'h1: din_tmp = {14'h0, din[19:2]};		// 18 bit Output
	   2'h2: din_tmp = {11'h0, din[19:0]};		// 20 Bit Output
	endcase

always @(posedge clk)
	if(we & (!m16b | (m16b & wp[0]) ) )	mem[ wp[2:1] ] <= #1 din_tmp;

endmodule

`endif

`ifdef AC97_IN_FIFO_DEPTH_8

// 8 entry deep verion of the input FIFO

module ac97_in_fifo(clk, rst, en, mode, din, we, dout, re, status, full, empty);

input		clk, rst;
input		en;
input	[1:0]	mode;
input	[19:0]	din;
input		we;
output	[31:0]	dout;
input		re;
output	[1:0]	status;
output		full;
output		empty;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	mem[0:7];
reg	[31:0]	dout;

reg	[4:0]	wp;
reg	[3:0]	rp;

wire	[4:0]	wp_p1;

reg	[1:0]	status;
reg	[15:0]	din_tmp1;
reg	[31:0]	din_tmp;
wire		m16b;
reg		full, empty;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign m16b = (mode == 2'h0);	// 16 Bit Mode

always @(posedge clk)
	if(!en)		wp <= #1 5'h0;
	else
	if(we)		wp <= #1 wp_p1;

assign wp_p1 = m16b ? (wp + 5'h1) : (wp + 5'h2);

always @(posedge clk)
	if(!en)		rp <= #1 4'h0;
	else
	if(re)		rp <= #1 rp + 4'h1;

always @(posedge clk)
	status <= #1 ((rp[2:1] - wp[3:2]) - 2'h1);

always @(posedge clk)
	empty <= #1 (wp[4:1] == rp[3:0]) & (m16b ? !wp[0] : 1'b0);

always @(posedge clk)
	full  <= #1 (wp[3:1] == rp[2:0]) & (wp[4] != rp[3]);

// Fifo Output
always @(posedge clk)
	dout <= #1 mem[ rp[2:0] ];

// Fifo Input Half Word Latch
always @(posedge clk)
	if(we & !wp[0])	din_tmp1 <= #1 din[19:4];

always @(mode or din_tmp1 or din)
	case(mode)	// synopsys parallel_case full_case
	   2'h0: din_tmp = {din[19:4], din_tmp1};	// 16 Bit Output
	   2'h1: din_tmp = {14'h0, din[19:2]};		// 18 bit Output
	   2'h2: din_tmp = {11'h0, din[19:0]};		// 20 Bit Output
	endcase

always @(posedge clk)
	if(we & (!m16b | (m16b & wp[0]) ) )	mem[ wp[3:1] ] <= #1 din_tmp;

endmodule

`endif


`ifdef AC97_IN_FIFO_DEPTH_16

// 16 entry deep verion of the input FIFO

module ac97_in_fifo(clk, rst, en, mode, din, we, dout, re, status, full, empty);

input		clk, rst;
input		en;
input	[1:0]	mode;
input	[19:0]	din;
input		we;
output	[31:0]	dout;
input		re;
output	[1:0]	status;
output		full;
output		empty;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	mem[0:15];
reg	[31:0]	dout;

reg	[5:0]	wp;
reg	[4:0]	rp;

wire	[5:0]	wp_p1;

reg	[1:0]	status;
reg	[15:0]	din_tmp1;
reg	[31:0]	din_tmp;
wire		m16b;
reg		full, empty;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign m16b = (mode == 2'h0);	// 16 Bit Mode

always @(posedge clk)
	if(!en)		wp <= #1 6'h0;
	else
	if(we)		wp <= #1 wp_p1;

assign wp_p1 = m16b ? (wp + 6'h1) : (wp + 6'h2);

always @(posedge clk)
	if(!en)		rp <= #1 5'h0;
	else
	if(re)		rp <= #1 rp + 5'h1;

always @(posedge clk)
	status <= #1 ((rp[3:2] - wp[4:3]) - 2'h1);

always @(posedge clk)
	empty <= #1 (wp[5:1] == rp[4:0]) & (m16b ? !wp[0] : 1'b0);

always @(posedge clk)
	full  <= #1 (wp[4:1] == rp[3:0]) & (wp[5] != rp[4]);

// Fifo Output
always @(posedge clk)
	dout <= #1 mem[ rp[3:0] ];

// Fifo Input Half Word Latch
always @(posedge clk)
	if(we & !wp[0])	din_tmp1 <= #1 din[19:4];

always @(mode or din_tmp1 or din)
	case(mode)	// synopsys parallel_case full_case
	   2'h0: din_tmp = {din[19:4], din_tmp1};	// 16 Bit Output
	   2'h1: din_tmp = {14'h0, din[19:2]};		// 18 bit Output
	   2'h2: din_tmp = {11'h0, din[19:0]};		// 20 Bit Output
	endcase

always @(posedge clk)
	if(we & (!m16b | (m16b & wp[0]) ) )	mem[ wp[4:1] ] <= #1 din_tmp;

endmodule

`endif
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  Interrupt Logic                                            ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.3  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.2  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:18  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_int(clk, rst,

		// Register File Interface
		int_set,

		// FIFO Interface
		cfg, status, full_empty, full, empty, re, we
		);

input		clk, rst;
output	[2:0]	int_set;

input	[7:0]	cfg;
input	[1:0]	status;
input		full_empty, full, empty, re, we;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[2:0]	int_set;

////////////////////////////////////////////////////////////////////
//
// Interrupt Logic
//

always @(posedge clk or negedge rst)
	if(!rst)	int_set[0] <= #1 1'b0;
	else
	case(cfg[5:4])	// synopsys parallel_case full_case
			// 1/4 full/empty
	   2'h2: int_set[0] <= #1 cfg[0] & (full_empty | (status == 2'h0));
			// 1/2 full/empty
	   2'h1: int_set[0] <= #1 cfg[0] & (full_empty | (status[1] == 1'h0));
			// 3/4 full/empty
	   2'h0: int_set[0] <= #1 cfg[0] & (full_empty | (status < 2'h3));	
	   2'h3: int_set[0] <= #1 cfg[0] & full_empty;
	endcase

always @(posedge clk or negedge rst)
	if(!rst)	int_set[1] <= #1 1'b0;
	else
	if(empty & re)	int_set[1] <= #1 1'b1;

always @(posedge clk or negedge rst)
	if(!rst)	int_set[2] <= #1 1'b0;
	else
	if(full & we)	int_set[2] <= #1 1'b1;

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  Output FIFO                                                ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.4  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.3  2002/03/11 03:21:22  rudi
//
//               - Added defines to select fifo depth between 4, 8 and 16 entries.
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:16  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

`ifdef AC97_OUT_FIFO_DEPTH_4

// 4 Entry Deep version of the Output FIFO

module ac97_out_fifo(clk, rst, en, mode, din, we, dout, re, status, full, empty);

input		clk, rst;
input		en;
input	[1:0]	mode;
input	[31:0]	din;
input		we;
output	[19:0]	dout;
input		re;
output	[1:0]	status;
output		full;
output		empty;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	mem[0:3];

reg	[2:0]	wp;
reg	[3:0]	rp;

wire	[2:0]	wp_p1;

reg	[1:0]	status;
reg	[19:0]	dout;
wire	[31:0]	dout_tmp;
wire	[15:0]	dout_tmp1;
wire		m16b;
reg		empty;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign m16b = (mode == 2'h0);	// 16 Bit Mode

always @(posedge clk)
	if(!en)		wp <= #1 3'h0;
	else
	if(we)		wp <= #1 wp_p1;

assign wp_p1 = wp + 3'h1;

always @(posedge clk)
	if(!en)		rp <= #1 4'h0;
	else
	if(re & m16b)	rp <= #1 rp + 4'h1;
	else
	if(re & !m16b)	rp <= #1 rp + 4'h2;

always @(posedge clk)
	status <= #1 (wp[1:0] - rp[2:1]) - 2'h1;

wire	[3:0]	rp_p1 = rp[3:0] + 4'h1;

always @(posedge clk)
	empty <= #1 (rp_p1[3:1] == wp[2:0]) & (m16b ? rp_p1[0] : 1'b1);

assign full  = (wp[1:0] == rp[2:1]) & (wp[2] != rp[3]);

// Fifo Output
assign dout_tmp = mem[ rp[2:1] ];

// Fifo Output Half Word Select
assign dout_tmp1 = rp[0] ? dout_tmp[31:16] : dout_tmp[15:0];

always @(posedge clk)
	if(!en)		dout <= #1 20'h0;
	else
	if(re)
		case(mode)	// synopsys parallel_case full_case
		   2'h0: dout <= #1 {dout_tmp1, 4'h0};		// 16 Bit Output
		   2'h1: dout <= #1 {dout_tmp[17:0], 2'h0};	// 18 bit Output
		   2'h2: dout <= #1 dout_tmp[19:0];		// 20 Bit Output
		endcase

always @(posedge clk)
	if(we)	mem[wp[1:0]] <= #1 din;

endmodule

`endif

`ifdef AC97_OUT_FIFO_DEPTH_8

// 8 Entry Deep version of the Output FIFO

module ac97_out_fifo(clk, rst, en, mode, din, we, dout, re, status, full, empty);

input		clk, rst;
input		en;
input	[1:0]	mode;
input	[31:0]	din;
input		we;
output	[19:0]	dout;
input		re;
output	[1:0]	status;
output		full;
output		empty;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	mem[0:7];

reg	[3:0]	wp;
reg	[4:0]	rp;

wire	[3:0]	wp_p1;

reg	[1:0]	status;
reg	[19:0]	dout;
wire	[31:0]	dout_tmp;
wire	[15:0]	dout_tmp1;
wire		m16b;
reg		empty;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign m16b = (mode == 2'h0);	// 16 Bit Mode

always @(posedge clk)
	if(!en)		wp <= #1 4'h0;
	else
	if(we)		wp <= #1 wp_p1;

assign wp_p1 = wp + 4'h1;

always @(posedge clk)
	if(!en)		rp <= #1 5'h0;
	else
	if(re & m16b)	rp <= #1 rp + 5'h1;
	else
	if(re & !m16b)	rp <= #1 rp + 5'h2;

always @(posedge clk)
	status <= #1 (wp[2:1] - rp[3:2]) - 2'h1;

wire	[4:0]	rp_p1 = rp[4:0] + 5'h1;

always @(posedge clk)
	empty <= #1 (rp_p1[4:1] == wp[3:0]) & (m16b ? rp_p1[0] : 1'b1);

assign full  = (wp[2:0] == rp[3:1]) & (wp[3] != rp[4]);

// Fifo Output
assign dout_tmp = mem[ rp[3:1] ];

// Fifo Output Half Word Select
assign dout_tmp1 = rp[0] ? dout_tmp[31:16] : dout_tmp[15:0];

always @(posedge clk)
	if(!en)		dout <= #1 20'h0;
	else
	if(re)
		case(mode)	// synopsys parallel_case full_case
		   2'h0: dout <= #1 {dout_tmp1, 4'h0};		// 16 Bit Output
		   2'h1: dout <= #1 {dout_tmp[17:0], 2'h0};	// 18 bit Output
		   2'h2: dout <= #1 dout_tmp[19:0];		// 20 Bit Output
		endcase


always @(posedge clk)
	if(we)	mem[wp[2:0]] <= #1 din;

endmodule

`endif


`ifdef AC97_OUT_FIFO_DEPTH_16

// 16 Entry Deep version of the Output FIFO

module ac97_out_fifo(clk, rst, en, mode, din, we, dout, re, status, full, empty);

input		clk, rst;
input		en;
input	[1:0]	mode;
input	[31:0]	din;
input		we;
output	[19:0]	dout;
input		re;
output	[1:0]	status;
output		full;
output		empty;


////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	mem[0:15];

reg	[4:0]	wp;
reg	[5:0]	rp;

wire	[4:0]	wp_p1;

reg	[1:0]	status;
reg	[19:0]	dout;
wire	[31:0]	dout_tmp;
wire	[15:0]	dout_tmp1;
wire		m16b;
reg		empty;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign m16b = (mode == 2'h0);	// 16 Bit Mode

always @(posedge clk)
	if(!en)		wp <= #1 5'h0;
	else
	if(we)		wp <= #1 wp_p1;

assign wp_p1 = wp + 4'h1;

always @(posedge clk)
	if(!en)		rp <= #1 6'h0;
	else
	if(re & m16b)	rp <= #1 rp + 6'h1;
	else
	if(re & !m16b)	rp <= #1 rp + 6'h2;

always @(posedge clk)
	status <= #1 (wp[3:2] - rp[4:3]) - 2'h1;

wire	[5:0]	rp_p1 = rp[5:0] + 6'h1;

always @(posedge clk)
	empty <= #1 (rp_p1[5:1] == wp[4:0]) & (m16b ? rp_p1[0] : 1'b1);

assign full  = (wp[3:0] == rp[4:1]) & (wp[4] != rp[5]);

// Fifo Output
assign dout_tmp = mem[ rp[4:1] ];

// Fifo Output Half Word Select
assign dout_tmp1 = rp[0] ? dout_tmp[31:16] : dout_tmp[15:0];

always @(posedge clk)
	if(!en)		dout <= #1 20'h0;
	else
	if(re)
		case(mode)	// synopsys parallel_case full_case
		   2'h0: dout <= #1 {dout_tmp1, 4'h0};		// 16 Bit Output
		   2'h1: dout <= #1 {dout_tmp[17:0], 2'h0};	// 18 bit Output
		   2'h2: dout <= #1 dout_tmp[19:0];		// 20 Bit Output
		endcase


always @(posedge clk)
	if(we)	mem[wp[3:0]] <= #1 din;

endmodule

`endif
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  PCM Request Controller                                     ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.4  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.3  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.2  2001/08/10 08:09:42  rudi
//
//               - Removed RTY_O output.
//               - Added Clock and Reset Inputs to documentation.
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:17  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_prc(clk, rst,

		// SR Slot Interface
		valid, in_valid, out_slt0,
		in_slt0, in_slt1,

		// Codec Register Access
		crac_valid, crac_wr,

		// Channel Configuration
		oc0_cfg, oc1_cfg, oc2_cfg, oc3_cfg, oc4_cfg, oc5_cfg,
		ic0_cfg, ic1_cfg, ic2_cfg,

		// FIFO Status
		o3_empty, o4_empty, o6_empty, o7_empty, o8_empty,
		o9_empty, i3_full, i4_full, i6_full,

		// FIFO Control
		o3_re, o4_re, o6_re, o7_re, o8_re, o9_re,
		i3_we, i4_we, i6_we

	);
input		clk, rst;

input		valid;
input	[2:0]	in_valid;
output	[15:0]	out_slt0;
input	[15:0]	in_slt0;
input	[19:0]	in_slt1;

input		crac_valid;
input		crac_wr;

input	[7:0]	oc0_cfg;
input	[7:0]	oc1_cfg;
input	[7:0]	oc2_cfg;
input	[7:0]	oc3_cfg;
input	[7:0]	oc4_cfg;
input	[7:0]	oc5_cfg;

input	[7:0]	ic0_cfg;
input	[7:0]	ic1_cfg;
input	[7:0]	ic2_cfg;

input		o3_empty;
input		o4_empty;
input		o6_empty;
input		o7_empty;
input		o8_empty;
input		o9_empty;
input		i3_full;
input		i4_full;
input		i6_full;

output		o3_re;
output		o4_re;
output		o6_re;
output		o7_re;
output		o8_re;
output		o9_re;
output		i3_we;
output		i4_we;
output		i6_we;
		
////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire		o3_re_l;
wire		o4_re_l;
wire		o6_re_l;
wire		o7_re_l;
wire		o8_re_l;
wire		o9_re_l;

reg		crac_valid_r;
reg		crac_wr_r;

////////////////////////////////////////////////////////////////////
//
// Output Tag Assembly
//

assign out_slt0[15] = |out_slt0[14:6];

assign out_slt0[14] = crac_valid_r;
assign out_slt0[13] = crac_wr_r;

assign out_slt0[12] = o3_re_l;
assign out_slt0[11] = o4_re_l;
assign out_slt0[10] = 1'b0;
assign out_slt0[09] = o6_re_l;
assign out_slt0[08] = o7_re_l;
assign out_slt0[07] = o8_re_l;
assign out_slt0[06] = o9_re_l;
assign out_slt0[5:0] = 6'h0;

////////////////////////////////////////////////////////////////////
//
// FIFO Control
//

always @(posedge clk)
	if(valid)	crac_valid_r <= #1 crac_valid;

always @(posedge clk)
	if(valid)	crac_wr_r <= #1 crac_valid & crac_wr;

// Output Channel 0 (Out Slot 3)
ac97_fifo_ctrl u0(
		.clk(		clk 		),
		.valid(		valid		),
		.ch_en(		oc0_cfg[0]	),
		.srs(		oc0_cfg[1]	),
		.full_empty(	o3_empty	),
		.req(		~in_slt1[11]	),
		.crdy(		in_slt0[15]	),
		.en_out(	o3_re		),
		.en_out_l(	o3_re_l		)
		);

// Output Channel 1 (Out Slot 4)
ac97_fifo_ctrl u1(
		.clk(		clk 		),
		.valid(		valid		),
		.ch_en(		oc1_cfg[0]	),
		.srs(		oc1_cfg[1]	),
		.full_empty(	o4_empty	),
		.req(		~in_slt1[10]	),
		.crdy(		in_slt0[15]	),
		.en_out(	o4_re		),
		.en_out_l(	o4_re_l		)
		);

`ifdef AC97_CENTER
// Output Channel 2 (Out Slot 6)
ac97_fifo_ctrl u2(
		.clk(		clk 		),
		.valid(		valid		),
		.ch_en(		oc2_cfg[0]	),
		.srs(		oc2_cfg[1]	),
		.full_empty(	o6_empty	),
		.req(		~in_slt1[8]	),
		.crdy(		in_slt0[15]	),
		.en_out(	o6_re		),
		.en_out_l(	o6_re_l		)
		);
`else
assign o6_re = 1'b0;
assign o6_re_l = 1'b0;
`endif

`ifdef AC97_SURROUND
// Output Channel 3 (Out Slot 7)
ac97_fifo_ctrl u3(
		.clk(		clk 		),
		.valid(		valid		),
		.ch_en(		oc3_cfg[0]	),
		.srs(		oc3_cfg[1]	),
		.full_empty(	o7_empty	),
		.req(		~in_slt1[7]	),
		.crdy(		in_slt0[15]	),
		.en_out(	o7_re		),
		.en_out_l(	o7_re_l		)
		);

// Output Channel 4 (Out Slot 8)
ac97_fifo_ctrl u4(
		.clk(		clk 		),
		.valid(		valid		),
		.ch_en(		oc4_cfg[0]	),
		.srs(		oc4_cfg[1]	),
		.full_empty(	o8_empty	),
		.req(		~in_slt1[6]	),
		.crdy(		in_slt0[15]	),
		.en_out(	o8_re		),
		.en_out_l(	o8_re_l		)
		);
`else
assign o7_re = 1'b0;
assign o7_re_l = 1'b0;
assign o8_re = 1'b0;
assign o8_re_l = 1'b0;
`endif

`ifdef AC97_LFE
// Output Channel 5 (Out Slot 9)
ac97_fifo_ctrl u5(
		.clk(		clk 		),
		.valid(		valid		),
		.ch_en(		oc5_cfg[0]	),
		.srs(		oc5_cfg[1]	),
		.full_empty(	o9_empty	),
		.req(		~in_slt1[5]	),
		.crdy(		in_slt0[15]	),
		.en_out(	o9_re		),
		.en_out_l(	o9_re_l		)
		);
`else
assign o9_re = 1'b0;
assign o9_re_l = 1'b0;
`endif

`ifdef AC97_SIN
// Input Channel 0 (In Slot 3)
ac97_fifo_ctrl u6(
		.clk(		clk 		),
		.valid(		in_valid[0]	),
		.ch_en(		ic0_cfg[0]	),
		.srs(		ic0_cfg[1]	),
		.full_empty(	i3_full		),
		.req(		in_slt0[12]	),
		.crdy(		in_slt0[15]	),
		.en_out(	i3_we		),
		.en_out_l(			)
		);

// Input Channel 1 (In Slot 4)
ac97_fifo_ctrl u7(
		.clk(		clk 		),
		.valid(		in_valid[1]	),
		.ch_en(		ic1_cfg[0]	),
		.srs(		ic1_cfg[1]	),
		.full_empty(	i4_full		),
		.req(		in_slt0[11]	),
		.crdy(		in_slt0[15]	),
		.en_out(	i4_we		),
		.en_out_l(			)
		);
`else
assign i3_we = 1'b0;
assign i4_we = 1'b0;
`endif

`ifdef AC97_MICIN
// Input Channel 2 (In Slot 6)
ac97_fifo_ctrl u8(
		.clk(		clk 		),
		.valid(		in_valid[2]	),
		.ch_en(		ic2_cfg[0]	),
		.srs(		ic2_cfg[1]	),
		.full_empty(	i6_full		),
		.req(		in_slt0[9]	),
		.crdy(		in_slt0[15]	),
		.en_out(	i6_we		),
		.en_out_l(			)
		);
`else
assign i6_we = 1'b0;
`endif

endmodule


/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  Register File                                              ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.4  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.3  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.2  2001/08/10 08:09:42  rudi
//
//               - Removed RTY_O output.
//               - Added Clock and Reset Inputs to documentation.
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:17  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_rf(clk, rst,

		adr, rf_dout, rf_din,
		rf_we, rf_re, int, ac97_rst_force,
		resume_req, suspended,

		crac_we, crac_din, crac_out,
		crac_rd_done, crac_wr_done,

		oc0_cfg, oc1_cfg, oc2_cfg, oc3_cfg, oc4_cfg, oc5_cfg,
		ic0_cfg, ic1_cfg, ic2_cfg,
		oc0_int_set, oc1_int_set, oc2_int_set, oc3_int_set,
		oc4_int_set, oc5_int_set,
		ic0_int_set, ic1_int_set, ic2_int_set

		);

input		clk,rst;

input	[3:0]	adr;
output	[31:0]	rf_dout;
input	[31:0]	rf_din;
input		rf_we;
input		rf_re;
output		int;
output		ac97_rst_force;
output		resume_req;
input		suspended;

output		crac_we;
input	[15:0]	crac_din;
output	[31:0]	crac_out;
input		crac_rd_done, crac_wr_done;

output	[7:0]	oc0_cfg;
output	[7:0]	oc1_cfg;
output	[7:0]	oc2_cfg;
output	[7:0]	oc3_cfg;
output	[7:0]	oc4_cfg;
output	[7:0]	oc5_cfg;

output	[7:0]	ic0_cfg;
output	[7:0]	ic1_cfg;
output	[7:0]	ic2_cfg;

input	[2:0]	oc0_int_set;
input	[2:0]	oc1_int_set;
input	[2:0]	oc2_int_set;
input	[2:0]	oc3_int_set;
input	[2:0]	oc4_int_set;
input	[2:0]	oc5_int_set;
input	[2:0]	ic0_int_set;
input	[2:0]	ic1_int_set;
input	[2:0]	ic2_int_set;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	rf_dout;

reg	[31:0]	csr_r;
reg	[31:0]	occ0_r;
reg	[15:0]	occ1_r;
reg	[23:0]	icc_r;
reg	[31:0]	crac_r;
reg	[28:0]	intm_r;
reg	[28:0]	ints_r;
reg		int;
wire	[28:0]	int_all;
wire	[31:0]	csr, occ0, occ1, icc, crac, intm, ints;
reg	[15:0]	crac_dout_r;
reg		ac97_rst_force;
reg		resume_req;

// Aliases
assign csr  = {30'h0, suspended, 1'h0};
assign occ0 = occ0_r;
assign occ1 = {16'h0, occ1_r};
assign icc  = {8'h0,  icc_r};
assign crac = {crac_r[7], 8'h0, crac_r[6:0], crac_din};
assign intm = {3'h0, intm_r};
assign ints = {3'h0, ints_r};

assign crac_out = {crac_r[7], 8'h0, crac_r[6:0], crac_dout_r};

////////////////////////////////////////////////////////////////////
//
// Register WISHBONE Interface
//

always @(adr or csr or occ0 or occ1 or icc or crac or intm or ints)
	case(adr[2:0])	// synopsys parallel_case full_case
	   0: rf_dout = csr;
	   1: rf_dout = occ0;
	   2: rf_dout = occ1;
	   3: rf_dout = icc;
	   4: rf_dout = crac;
	   5: rf_dout = intm;
	   6: rf_dout = ints;
	endcase

always @(posedge clk or negedge rst)
	if(!rst)			csr_r <= #1 1'b0;
	else
	if(rf_we & (adr[2:0]==3'h0))	csr_r <= #1 rf_din;

always @(posedge clk)
	if(rf_we & (adr[2:0]==3'h0))	ac97_rst_force <= #1 rf_din[0];
	else				ac97_rst_force <= #1 1'b0;

always @(posedge clk)
	if(rf_we & (adr[2:0]==3'h0))	resume_req <= #1 rf_din[1];
	else				resume_req <= #1 1'b0;

always @(posedge clk or negedge rst)
	if(!rst)			occ0_r <= #1 1'b0;
	else
	if(rf_we & (adr[2:0]==3'h1))	occ0_r <= #1 rf_din;

always @(posedge clk or negedge rst)
	if(!rst)			occ1_r <= #1 1'b0;
	else
	if(rf_we & (adr[2:0]==3'h2))	occ1_r <= #1 rf_din[23:0];

always @(posedge clk or negedge rst)
	if(!rst)			icc_r <= #1 1'b0;
	else
	if(rf_we & (adr[2:0]==3'h3))	icc_r <= #1 rf_din[23:0];

assign crac_we = rf_we & (adr[2:0]==3'h4);

always @(posedge clk or negedge rst)
	if(!rst)			crac_r <= #1 1'b0;
	else
	if(crac_we) 			crac_r <= #1 {rf_din[31], rf_din[22:16]};

always @(posedge clk)
	if(crac_we)			crac_dout_r <= #1 rf_din[15:0];

always @(posedge clk or negedge rst)
	if(!rst)			intm_r <= #1 1'b0;
	else
	if(rf_we & (adr[2:0]==3'h5))	intm_r <= #1 rf_din[28:0];

// Interrupt Source Register
always @(posedge clk or negedge rst)
	if(!rst)			ints_r <= #1 1'b0;
	else
	if(rf_re & (adr[2:0]==3'h6))	ints_r <= #1 1'b0;
	else
	   begin
		if(crac_rd_done)	ints_r[0] <= #1 1'b1;
		if(crac_wr_done)	ints_r[1] <= #1 1'b1;
		if(oc0_int_set[0])	ints_r[2] <= #1 1'b1;
		if(oc0_int_set[1])	ints_r[3] <= #1 1'b1;
		if(oc0_int_set[2])	ints_r[4] <= #1 1'b1;
		if(oc1_int_set[0])	ints_r[5] <= #1 1'b1;
		if(oc1_int_set[1])	ints_r[6] <= #1 1'b1;
		if(oc1_int_set[2])	ints_r[7] <= #1 1'b1;
`ifdef AC97_CENTER
		if(oc2_int_set[0])	ints_r[8] <= #1 1'b1;
		if(oc2_int_set[1])	ints_r[9] <= #1 1'b1;
		if(oc2_int_set[2])	ints_r[10] <= #1 1'b1;
`endif

`ifdef AC97_SURROUND
		if(oc3_int_set[0])	ints_r[11] <= #1 1'b1;
		if(oc3_int_set[1])	ints_r[12] <= #1 1'b1;
		if(oc3_int_set[2])	ints_r[13] <= #1 1'b1;
		if(oc4_int_set[0])	ints_r[14] <= #1 1'b1;
		if(oc4_int_set[1])	ints_r[15] <= #1 1'b1;
		if(oc4_int_set[2])	ints_r[16] <= #1 1'b1;
`endif

`ifdef AC97_LFE
		if(oc5_int_set[0])	ints_r[17] <= #1 1'b1;
		if(oc5_int_set[1])	ints_r[18] <= #1 1'b1;
		if(oc5_int_set[2])	ints_r[19] <= #1 1'b1;
`endif

`ifdef AC97_SIN
		if(ic0_int_set[0])	ints_r[20] <= #1 1'b1;
		if(ic0_int_set[1])	ints_r[21] <= #1 1'b1;
		if(ic0_int_set[2])	ints_r[22] <= #1 1'b1;
		if(ic1_int_set[0])	ints_r[23] <= #1 1'b1;
		if(ic1_int_set[1])	ints_r[24] <= #1 1'b1;
		if(ic1_int_set[2])	ints_r[25] <= #1 1'b1;
`endif

`ifdef AC97_MICIN
		if(ic2_int_set[0])	ints_r[26] <= #1 1'b1;
		if(ic2_int_set[1])	ints_r[27] <= #1 1'b1;
		if(ic2_int_set[2])	ints_r[28] <= #1 1'b1;
`endif
	   end

////////////////////////////////////////////////////////////////////
//
// Register Internal Interface
//

assign oc0_cfg = occ0[7:0];
assign oc1_cfg = occ0[15:8];
assign oc2_cfg = occ0[23:16];
assign oc3_cfg = occ0[31:24];
assign oc4_cfg = occ1[7:0];
assign oc5_cfg = occ1[15:8];

assign ic0_cfg = icc[7:0];
assign ic1_cfg = icc[15:8];
assign ic2_cfg = icc[23:16];

////////////////////////////////////////////////////////////////////
//
// Interrupt Generation
//

assign int_all = intm_r & ints_r;

always @(posedge clk)
	int <= #1 |int_all;

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller Reset Module                     ////
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
//// Copyright (C) 2001 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:19  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_rst(clk, rst, rst_force, ps_ce, ac97_rst_);
input		clk, rst;
input		rst_force;
output		ps_ce;
output		ac97_rst_;

reg		ac97_rst_;
reg	[2:0]	cnt;
wire		ce;
wire		to;
reg	[5:0]	ps_cnt;
wire		ps_ce;

always @(posedge clk or negedge rst)
	if(!rst)	ac97_rst_ <= #1 0;
	else
	if(rst_force)	ac97_rst_ <= #1 0;
	else
	if(to)		ac97_rst_ <= #1 1;

assign to = (cnt == `AC97_RST_DEL);

always @(posedge clk or negedge rst)
	if(!rst)	cnt <= #1 0;
	else
	if(rst_force)	cnt <= #1 0;
	else
	if(ce)		cnt <= #1 cnt + 1;

assign ce = ps_ce & (cnt != `AC97_RST_DEL);

always @(posedge clk or negedge rst)
	if(!rst)		ps_cnt <= #1 0;
	else
	if(ps_ce | rst_force)	ps_cnt <= #1 0;
	else			ps_cnt <= #1 ps_cnt + 1;

assign ps_ce = (ps_cnt == `AC97_250_PS);

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.2  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:15  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_sin(clk, rst,

	out_le, slt0, slt1, slt2, slt3, slt4,
	slt6, 

	sdata_in
	);

input		clk, rst;

// --------------------------------------
// Misc Signals
input	[5:0]	out_le;
output	[15:0]	slt0;
output	[19:0]	slt1;
output	[19:0]	slt2;
output	[19:0]	slt3;
output	[19:0]	slt4;
output	[19:0]	slt6;

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
reg	[19:0]	slt6;

////////////////////////////////////////////////////////////////////
//
// Output Registers
//

always @(posedge clk)
	if(out_le[0])	slt0 <= #1 sr[15:0];

always @(posedge clk)
	if(out_le[1])	slt1 <= #1 sr;

always @(posedge clk)
	if(out_le[2])	slt2 <= #1 sr;

always @(posedge clk)
	if(out_le[3])	slt3 <= #1 sr;

always @(posedge clk)
	if(out_le[4])	slt4 <= #1 sr;

always @(posedge clk)
	if(out_le[5])	slt6 <= #1 sr;

////////////////////////////////////////////////////////////////////
//
// Serial Shift Register
//

always @(negedge clk)
	sdata_in_r <= #1 sdata_in;

always @(posedge clk)
	sr <= #1 {sr[18:0], sdata_in_r };

endmodule


/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  Serial Output Controller                                   ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.3  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.2  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:15  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_soc(clk, wclk, rst,
		ps_ce, resume, suspended,
		sync, out_le, in_valid, ld, valid
		);

input		clk, wclk, rst;
input		ps_ce;
input		resume;
output		suspended;
output		sync;
output	[5:0]	out_le;
output	[2:0]	in_valid;
output		ld;
output		valid;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[7:0]	cnt;
reg		sync_beat;
reg		sync_resume;
reg	[5:0]	out_le;
reg		ld;
reg		valid;
reg	[2:0]	in_valid;
reg		bit_clk_r;
reg		bit_clk_r1;
reg		bit_clk_e;
reg		suspended;
wire		to;
reg	[5:0]	to_cnt;
reg	[3:0]	res_cnt;
wire		resume_done;

assign sync = sync_beat | sync_resume;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk or negedge rst)
	if(!rst)		cnt <= #1 8'hff;
	else
	if(suspended)		cnt <= #1 8'hff;
	else			cnt <= #1 cnt + 8'h1;

always @(posedge clk)
	ld <= #1 (cnt == 8'h00);

always @(posedge clk)
	sync_beat <= #1 (cnt == 8'h00) | ((cnt > 8'h00) & (cnt < 8'h10));

always @(posedge clk)
	valid <= #1 (cnt > 8'h39);

always @(posedge clk)
	out_le[0] <= #1 (cnt == 8'h11);		// Slot 0 Latch Enable

always @(posedge clk)
	out_le[1] <= #1 (cnt == 8'h25);		// Slot 1 Latch Enable

always @(posedge clk)
	out_le[2] <= #1 (cnt == 8'h39);		// Slot 2 Latch Enable

always @(posedge clk)
	out_le[3] <= #1 (cnt == 8'h4d);		// Slot 3 Latch Enable

always @(posedge clk)
	out_le[4] <= #1 (cnt == 8'h61);		// Slot 4 Latch Enable

always @(posedge clk)
	out_le[5] <= #1 (cnt == 8'h89);		// Slot 6 Latch Enable

always @(posedge clk)
	in_valid[0] <= #1 (cnt > 8'h4d);	// Input Slot 3 Valid

always @(posedge clk)
	in_valid[1] <= #1 (cnt > 8'h61);	// Input Slot 3 Valid

always @(posedge clk)
	in_valid[2] <= #1 (cnt > 8'h89);	// Input Slot 3 Valid

////////////////////////////////////////////////////////////////////
//
// Suspend Detect
//

always @(posedge wclk)
	bit_clk_r <= #1 clk;

always @(posedge wclk)
	bit_clk_r1 <= #1 bit_clk_r;

always @(posedge wclk)
	bit_clk_e <= #1 (bit_clk_r & !bit_clk_r1) | (!bit_clk_r & bit_clk_r1);

always @(posedge wclk)
	suspended <= #1 to;

assign to = (to_cnt == `AC97_SUSP_DET);

always @(posedge wclk or negedge rst)
	if(!rst)		to_cnt <= #1 6'h0;
	else
	if(bit_clk_e)		to_cnt <= #1 6'h0;
	else
	if(!to)			to_cnt <= #1 to_cnt + 6'h1;

////////////////////////////////////////////////////////////////////
//
// Resume Signaling
//

always @(posedge wclk or negedge rst)
	if(!rst)			sync_resume <= #1 1'b0;
	else
	if(resume_done)			sync_resume <= #1 1'b0;
	else
	if(suspended & resume)		sync_resume <= #1 1'b1;

assign resume_done = (res_cnt == `AC97_RES_SIG);

always @(posedge wclk)
	if(!sync_resume)	res_cnt <= #1 4'h0;
	else
	if(ps_ce)		res_cnt <= #1 res_cnt + 4'h1;

endmodule
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.2  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:15  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_sout(clk, rst,

	so_ld, slt0, slt1, slt2, slt3, slt4,
	slt6, slt7, slt8, slt9,

	sdata_out
	);

input		clk, rst;

// --------------------------------------
// Misc Signals
input		so_ld;
input	[15:0]	slt0;
input	[19:0]	slt1;
input	[19:0]	slt2;
input	[19:0]	slt3;
input	[19:0]	slt4;
input	[19:0]	slt6;
input	[19:0]	slt7;
input	[19:0]	slt8;
input	[19:0]	slt9;

// --------------------------------------
// AC97 Codec Interface
output		sdata_out;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire		sdata_out;

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

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

////////////////////////////////////////////////////////////////////
//
// Serial Shift Register
//

assign	sdata_out = slt0_r[15];

always @(posedge clk)
	if(so_ld)	slt0_r <= #1 slt0;
	else		slt0_r <= #1 {slt0_r[14:0], slt1_r[19]};

always @(posedge clk)
	if(so_ld)	slt1_r <= #1 slt1;
	else		slt1_r <= #1 {slt1_r[18:0], slt2_r[19]};

always @(posedge clk)
	if(so_ld)	slt2_r <= #1 slt2;
	else		slt2_r <= #1 {slt2_r[18:0], slt3_r[19]};

always @(posedge clk)
	if(so_ld)	slt3_r <= #1 slt3;
	else		slt3_r <= #1 {slt3_r[18:0], slt4_r[19]};

always @(posedge clk)
	if(so_ld)	slt4_r <= #1 slt4;
	else		slt4_r <= #1 {slt4_r[18:0], slt5_r[19]};

always @(posedge clk)
	if(so_ld)	slt5_r <= #1 20'h0;
	else		slt5_r <= #1 {slt5_r[18:0], slt6_r[19]};

always @(posedge clk)
	if(so_ld)	slt6_r <= #1 slt6;
	else		slt6_r <= #1 {slt6_r[18:0], slt7_r[19]};

always @(posedge clk)
	if(so_ld)	slt7_r <= #1 slt7;
	else		slt7_r <= #1 {slt7_r[18:0], slt8_r[19]};

always @(posedge clk)
	if(so_ld)	slt8_r <= #1 slt8;
	else		slt8_r <= #1 {slt8_r[18:0], slt9_r[19]};

always @(posedge clk)
	if(so_ld)	slt9_r <= #1 slt9;
	else		slt9_r <= #1 {slt9_r[18:0], slt10_r[19]};

always @(posedge clk)
	if(so_ld)	slt10_r <= #1 20'h0;
	else		slt10_r <= #1 {slt10_r[18:0], slt11_r[19]};

always @(posedge clk)
	if(so_ld)	slt11_r <= #1 20'h0;
	else		slt11_r <= #1 {slt11_r[18:0], slt12_r[19]};

always @(posedge clk)
	if(so_ld)	slt12_r <= #1 20'h0;
	else		slt12_r <= #1 {slt12_r[18:0], 1'b0 };

endmodule

/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller                                  ////
////  WISHBONE Interface Module                                  ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.4  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.3  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.2  2001/08/10 08:09:42  rudi
//
//               - Removed RTY_O output.
//               - Added Clock and Reset Inputs to documentation.
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:16  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_wb_if(clk, rst,

		wb_data_i, wb_data_o, wb_addr_i, wb_sel_i, wb_we_i, wb_cyc_i,
		wb_stb_i, wb_ack_o, wb_err_o, 

		adr, dout, rf_din, i3_din, i4_din, i6_din,
		rf_we, rf_re, o3_we, o4_we, o6_we, o7_we, o8_we, o9_we,
		i3_re, i4_re, i6_re

		);

input		clk,rst;

// WISHBONE Interface
input	[31:0]	wb_data_i;
output	[31:0]	wb_data_o;
input	[31:0]	wb_addr_i;
input	[3:0]	wb_sel_i;
input		wb_we_i;
input		wb_cyc_i;
input		wb_stb_i;
output		wb_ack_o;
output		wb_err_o;

// Internal Interface
output	[3:0]	adr;
output	[31:0]	dout;
input	[31:0]	rf_din, i3_din, i4_din, i6_din;
output		rf_we;
output		rf_re;
output		o3_we, o4_we, o6_we, o7_we, o8_we, o9_we;
output		i3_re, i4_re, i6_re;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[31:0]	wb_data_o;
reg	[31:0]	dout;
reg		wb_ack_o;

reg		rf_we;
reg		o3_we, o4_we, o6_we, o7_we, o8_we, o9_we;
reg		i3_re, i4_re, i6_re;

reg		we1, we2;
wire		we;
reg		re2, re1;
wire		re;

////////////////////////////////////////////////////////////////////
//
// Modules
//

assign adr = wb_addr_i[5:2];

assign wb_err_o = 1'b0;

always @(posedge clk)
	dout <= #1 wb_data_i;

always @(posedge clk)
	case(wb_addr_i[6:2])	// synopsys parallel_case full_case
	   5'he: wb_data_o <= #1 i3_din;
	   5'hf: wb_data_o <= #1 i4_din;
	   5'h10: wb_data_o <= #1 i6_din;
	   default: wb_data_o <= #1 rf_din;
	endcase

always @(posedge clk)
	re1 <= #1 !re2 & wb_cyc_i & wb_stb_i & !wb_we_i & `AC97_REG_SEL;

always @(posedge clk)
	re2 <= #1 re & wb_cyc_i & wb_stb_i & !wb_we_i ;

assign re = re1 & !re2 & wb_cyc_i & wb_stb_i & !wb_we_i;

assign rf_re = re & (wb_addr_i[6:2] < 5'h8);

always @(posedge clk)
	we1 <= #1 !we & wb_cyc_i & wb_stb_i & wb_we_i & `AC97_REG_SEL;

always @(posedge clk)
	we2 <= #1 we1 & wb_cyc_i & wb_stb_i & wb_we_i;

assign we = we1 & !we2 & wb_cyc_i & wb_stb_i & wb_we_i;

always @(posedge clk)
	wb_ack_o <= #1 (re | we) & wb_cyc_i & wb_stb_i & ~wb_ack_o;

always @(posedge clk)
	rf_we <= #1 we & (wb_addr_i[6:2] < 5'h8);

always @(posedge clk)
	o3_we <= #1 we & (wb_addr_i[6:2] == 5'h8);

always @(posedge clk)
	o4_we <= #1 we & (wb_addr_i[6:2] == 5'h9);

always @(posedge clk)
	o6_we <= #1 we & (wb_addr_i[6:2] == 5'ha);

always @(posedge clk)
	o7_we <= #1 we & (wb_addr_i[6:2] == 5'hb);

always @(posedge clk)
	o8_we <= #1 we & (wb_addr_i[6:2] == 5'hc);

always @(posedge clk)
	o9_we <= #1 we & (wb_addr_i[6:2] == 5'hd);

always @(posedge clk)
	i3_re <= #1 re & (wb_addr_i[6:2] == 5'he);

always @(posedge clk)
	i4_re <= #1 re & (wb_addr_i[6:2] == 5'hf);

always @(posedge clk)
	i6_re <= #1 re & (wb_addr_i[6:2] == 5'h10);

endmodule

/////////////////////////////////////////////////////////////////////
////                                                             ////
////  WISHBONE AC 97 Controller Top Level                        ////
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
//  $Id: ac97_top.v,v 1.4 2006/11/20 17:13:43 tame Exp $
//
//  $Date: 2006/11/20 17:13:43 $
//  $Revision: 1.4 $
//  $Author: tame $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: ac97_top.v,v $
//               Revision 1.4  2006/11/20 17:13:43  tame
//               Originally calculated values used.
//
//               Revision 1.3  2006/09/11 13:12:13  tame
//               Tried out high timing settings - works in hardware.
//
//               Revision 1.2  2006/08/16 08:46:04  tame
//               AC97 core: register set read/writable in first simulations; in hardware, however,
//               not yet
//
//               Revision 1.1  2006/08/14 15:25:09  tame
//               added ac97 codec from OpenCores
//               adapted configuration in ac97_defines module
//
//               Revision 1.4  2002/09/19 06:30:56  rudi
//               Fixed a bug reported by Igor. Apparently this bug only shows up when
//               the WB clock is very low (2x bit_clk). Updated Copyright header.
//
//               Revision 1.3  2002/03/05 04:44:05  rudi
//
//               - Fixed the order of the thrash hold bits to match the spec.
//               - Many minor synthesis cleanup items ...
//
//               Revision 1.2  2001/08/10 08:09:42  rudi
//
//               - Removed RTY_O output.
//               - Added Clock and Reset Inputs to documentation.
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//
//               Revision 1.1  2001/08/03 06:54:50  rudi
//
//
//               - Changed to new directory structure
//
//               Revision 1.1.1.1  2001/05/19 02:29:14  rudi
//               Initial Checkin
//
//
//
//

// `include "ac97_defines.v"

module ac97_top(clk_i, rst_i,

	wb_data_i, wb_data_o, wb_addr_i, wb_sel_i, wb_we_i, wb_cyc_i,
	wb_stb_i, wb_ack_o, wb_err_o, 

	int_o, dma_req_o, dma_ack_i,
	suspended_o,

	bit_clk_pad_i, sync_pad_o, sdata_pad_o, sdata_pad_i,
	ac97_resetn_pad_o
	);

input		clk_i, rst_i;

// --------------------------------------
// WISHBONE SLAVE INTERFACE 
input	[31:0]	wb_data_i;
output	[31:0]	wb_data_o;
input	[31:0]	wb_addr_i;
input	[3:0]	wb_sel_i;
input		wb_we_i;
input		wb_cyc_i;
input		wb_stb_i;
output		wb_ack_o;
output		wb_err_o;

// --------------------------------------
// Misc Signals
output		int_o;
output	[8:0]	dma_req_o;
input	[8:0]	dma_ack_i;

// --------------------------------------
// Suspend Resume Interface
output		suspended_o;

// --------------------------------------
// AC97 Codec Interface
input		bit_clk_pad_i;
output		sync_pad_o;
output		sdata_pad_o;
input		sdata_pad_i;
output		ac97_resetn_pad_o;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

// Serial Output register interface
wire	[15:0]	out_slt0;
wire	[19:0]	out_slt1;
wire	[19:0]	out_slt2;
wire	[19:0]	out_slt3;
wire	[19:0]	out_slt4;
wire	[19:0]	out_slt6;
wire	[19:0]	out_slt7;
wire	[19:0]	out_slt8;
wire	[19:0]	out_slt9;

// Serial Input register interface
wire	[15:0]	in_slt0;
wire	[19:0]	in_slt1;
wire	[19:0]	in_slt2;
wire	[19:0]	in_slt3;
wire	[19:0]	in_slt4;
wire	[19:0]	in_slt6;

// Serial IO Controller Interface
wire		ld;
wire		valid;
wire	[5:0]	out_le;
wire	[2:0]	in_valid;
wire		ps_ce;

// Valid Sync
reg		valid_s1, valid_s;
reg	[2:0]	in_valid_s1, in_valid_s;

// Out FIFO interface
wire	[31:0]	wb_din;
wire	[1:0]	o3_mode, o4_mode, o6_mode, o7_mode, o8_mode, o9_mode;
wire		o3_re, o4_re, o6_re, o7_re, o8_re, o9_re;
wire		o3_we, o4_we, o6_we, o7_we, o8_we, o9_we;
wire	[1:0]	o3_status, o4_status, o6_status, o7_status, o8_status, o9_status;
wire		o3_full, o4_full, o6_full, o7_full, o8_full, o9_full;
wire		o3_empty, o4_empty, o6_empty, o7_empty, o8_empty, o9_empty;

// In FIFO interface
wire	[31:0]	i3_dout, i4_dout, i6_dout;
wire	[1:0]	i3_mode, i4_mode, i6_mode;
wire		i3_we, i4_we, i6_we;
wire		i3_re, i4_re, i6_re;
wire	[1:0]	i3_status, i4_status, i6_status;
wire		i3_full, i4_full, i6_full;
wire		i3_empty, i4_empty, i6_empty;

// Register File Interface
wire	[3:0]	adr;
wire	[31:0]	rf_dout;
wire	[31:0]	rf_din;
wire		rf_we;
wire		rf_re;
wire		ac97_rst_force;
wire		resume_req;
wire		crac_we;
wire	[15:0]	crac_din;
wire	[31:0]	crac_out;
wire	[7:0]	oc0_cfg;
wire	[7:0]	oc1_cfg;
wire	[7:0]	oc2_cfg;
wire	[7:0]	oc3_cfg;
wire	[7:0]	oc4_cfg;
wire	[7:0]	oc5_cfg;
wire	[7:0]	ic0_cfg;
wire	[7:0]	ic1_cfg;
wire	[7:0]	ic2_cfg;
wire	[2:0]	oc0_int_set;
wire	[2:0]	oc1_int_set;
wire	[2:0]	oc2_int_set;
wire	[2:0]	oc3_int_set;
wire	[2:0]	oc4_int_set;
wire	[2:0]	oc5_int_set;
wire	[2:0]	ic0_int_set;
wire	[2:0]	ic1_int_set;
wire	[2:0]	ic2_int_set;

// CRA Module interface
wire		crac_valid;
wire		crac_wr;
wire		crac_wr_done, crac_rd_done;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

// Sync Valid to WISHBONE Clock
always @(posedge clk_i)
	valid_s1 <= #1 valid;

always @(posedge clk_i)
	valid_s <= #1 valid_s1;

always @(posedge clk_i)
	in_valid_s1 <= #1 in_valid;

always @(posedge clk_i)
	in_valid_s <= #1 in_valid_s1;

// "valid_s" Indicates when any of the outputs to the output S/R may
// change or when outputs from input S/R may be sampled
assign o3_mode = oc0_cfg[3:2];
assign o4_mode = oc1_cfg[3:2];
assign o6_mode = oc2_cfg[3:2];
assign o7_mode = oc3_cfg[3:2];
assign o8_mode = oc4_cfg[3:2];
assign o9_mode = oc5_cfg[3:2];
assign i3_mode = ic0_cfg[3:2];
assign i4_mode = ic1_cfg[3:2];
assign i6_mode = ic2_cfg[3:2];

////////////////////////////////////////////////////////////////////
//
// Modules
//

ac97_sout	u0(
		.clk(		bit_clk_pad_i	),
		.rst(		rst_i		),
		.so_ld(		ld		),
		.slt0(		out_slt0	),
		.slt1(		out_slt1	),
		.slt2(		out_slt2	),
		.slt3(		out_slt3	),
		.slt4(		out_slt4	),
		.slt6(		out_slt6	),
		.slt7(		out_slt7	),
		.slt8(		out_slt8	),
		.slt9(		out_slt9	),
		.sdata_out(	sdata_pad_o	)
		);

ac97_sin	u1(
		.clk(		bit_clk_pad_i	),
		.rst(		rst_i		),
		.out_le(	out_le		),
		.slt0(		in_slt0		),
		.slt1(		in_slt1		),
		.slt2(		in_slt2		),
		.slt3(		in_slt3		),
		.slt4(		in_slt4		),
		.slt6(		in_slt6		),
		.sdata_in(	sdata_pad_i	)
		);

ac97_soc	u2(
		.clk(		bit_clk_pad_i	),
		.wclk(		clk_i		),
		.rst(		rst_i		),
		.ps_ce(		ps_ce		),
		.resume(	resume_req	),
		.suspended(	suspended_o	),
		.sync(		sync_pad_o	),
		.out_le(	out_le		),
		.in_valid(	in_valid	),
		.ld(		ld		),
		.valid(		valid		)
		);

ac97_out_fifo	u3(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		oc0_cfg[0]	),
		.mode(		o3_mode		),
		.din(		wb_din		),
		.we(		o3_we		),
		.dout(		out_slt3	),
		.re(		o3_re		),
		.status(	o3_status	),
		.full(		o3_full		),
		.empty(		o3_empty	)
		);

ac97_out_fifo	u4(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		oc1_cfg[0]	),
		.mode(		o4_mode		),
		.din(		wb_din		),
		.we(		o4_we		),
		.dout(		out_slt4	),
		.re(		o4_re		),
		.status(	o4_status	),
		.full(		o4_full		),
		.empty(		o4_empty	)
		);

`ifdef AC97_CENTER
ac97_out_fifo	u5(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		oc2_cfg[0]	),
		.mode(		o6_mode		),
		.din(		wb_din		),
		.we(		o6_we		),
		.dout(		out_slt6	),
		.re(		o6_re		),
		.status(	o6_status	),
		.full(		o6_full		),
		.empty(		o6_empty	)
		);
`else
assign out_slt6 = 20'h0;
assign o6_status = 2'h0;
assign o6_full = 1'b0;
assign o6_empty = 1'b0;
`endif

`ifdef AC97_SURROUND
ac97_out_fifo	u6(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		oc3_cfg[0]	),
		.mode(		o7_mode		),
		.din(		wb_din		),
		.we(		o7_we		),
		.dout(		out_slt7	),
		.re(		o7_re		),
		.status(	o7_status	),
		.full(		o7_full		),
		.empty(		o7_empty	)
		);

ac97_out_fifo	u7(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		oc4_cfg[0]	),
		.mode(		o8_mode		),
		.din(		wb_din		),
		.we(		o8_we		),
		.dout(		out_slt8	),
		.re(		o8_re		),
		.status(	o8_status	),
		.full(		o8_full		),
		.empty(		o8_empty	)
		);
`else
assign out_slt7 = 20'h0;
assign o7_status = 2'h0;
assign o7_full = 1'b0;
assign o7_empty = 1'b0;
assign out_slt8 = 20'h0;
assign o8_status = 2'h0;
assign o8_full = 1'b0;
assign o8_empty = 1'b0;
`endif

`ifdef AC97_LFE
ac97_out_fifo	u8(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		oc5_cfg[0]	),
		.mode(		o9_mode		),
		.din(		wb_din		),
		.we(		o9_we		),
		.dout(		out_slt9	),
		.re(		o9_re		),
		.status(	o9_status	),
		.full(		o9_full		),
		.empty(		o9_empty	)
		);
`else
assign out_slt9 = 20'h0;
assign o9_status = 2'h0;
assign o9_full = 1'b0;
assign o9_empty = 1'b0;
`endif

`ifdef AC97_SIN
ac97_in_fifo	u9(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		ic0_cfg[0]	),
		.mode(		i3_mode		),
		.din(		in_slt3		),
		.we(		i3_we		),
		.dout(		i3_dout		),
		.re(		i3_re		),
		.status(	i3_status	),
		.full(		i3_full		),
		.empty(		i3_empty	)
		);

ac97_in_fifo	u10(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		ic1_cfg[0]	),
		.mode(		i4_mode		),
		.din(		in_slt4		),
		.we(		i4_we		),
		.dout(		i4_dout		),
		.re(		i4_re		),
		.status(	i4_status	),
		.full(		i4_full		),
		.empty(		i4_empty	)
		);
`else
assign i3_dout = 20'h0;
assign i3_status = 2'h0;
assign i3_full = 1'b0;
assign i3_empty = 1'b0;
assign i4_dout = 20'h0;
assign i4_status = 2'h0;
assign i4_full = 1'b0;
assign i4_empty = 1'b0;
`endif

`ifdef AC97_MICIN
ac97_in_fifo	u11(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.en(		ic2_cfg[0]	),
		.mode(		i6_mode		),
		.din(		in_slt6		),
		.we(		i6_we		),
		.dout(		i6_dout		),
		.re(		i6_re		),
		.status(	i6_status	),
		.full(		i6_full		),
		.empty(		i6_empty	)
		);
`else
assign i6_dout = 20'h0;
assign i6_status = 2'h0;
assign i6_full = 1'b0;
assign i6_empty = 1'b0;
`endif

ac97_wb_if	u12(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.wb_data_i(	wb_data_i	),
		.wb_data_o(	wb_data_o	),
		.wb_addr_i(	wb_addr_i	),
		.wb_sel_i(	wb_sel_i	),
		.wb_we_i(	wb_we_i		),
		.wb_cyc_i(	wb_cyc_i	),
		.wb_stb_i(	wb_stb_i	),
		.wb_ack_o(	wb_ack_o	),
		.wb_err_o(	wb_err_o	),
		.adr(		adr		),
		.dout(		wb_din		),
		.rf_din(	rf_dout		),
		.i3_din(	i3_dout		),
		.i4_din(	i4_dout		),
		.i6_din(	i6_dout		),
		.rf_we(		rf_we		),
		.rf_re(		rf_re		),
		.o3_we(		o3_we		),
		.o4_we(		o4_we		),
		.o6_we(		o6_we		),
		.o7_we(		o7_we		),
		.o8_we(		o8_we		),
		.o9_we(		o9_we		),
		.i3_re(		i3_re		),
		.i4_re(		i4_re		),
		.i6_re(		i6_re		)
		);

ac97_rf	u13(	.clk(		clk_i		),
		.rst(		rst_i		),
		.adr(		adr		),
		.rf_dout(	rf_dout		),
		.rf_din(	wb_din		),
		.rf_we(		rf_we		),
		.rf_re(		rf_re		),
		.int(		int_o		),
		.ac97_rst_force(ac97_rst_force	),
		.resume_req(	resume_req	),
		.suspended(	suspended_o	),
		.crac_we(	crac_we		),
		.crac_din(	crac_din	),
		.crac_out(	crac_out	),
		.crac_wr_done(	crac_wr_done	),
		.crac_rd_done(	crac_rd_done	),
		.oc0_cfg(	oc0_cfg		),
		.oc1_cfg(	oc1_cfg		),
		.oc2_cfg(	oc2_cfg		),
		.oc3_cfg(	oc3_cfg		),
		.oc4_cfg(	oc4_cfg		),
		.oc5_cfg(	oc5_cfg		),
		.ic0_cfg(	ic0_cfg		),
		.ic1_cfg(	ic1_cfg		),
		.ic2_cfg(	ic2_cfg		),
		.oc0_int_set(	oc0_int_set	),
		.oc1_int_set(	oc1_int_set	),
		.oc2_int_set(	oc2_int_set	),
		.oc3_int_set(	oc3_int_set	),
		.oc4_int_set(	oc4_int_set	),
		.oc5_int_set(	oc5_int_set	),
		.ic0_int_set(	ic0_int_set	),
		.ic1_int_set(	ic1_int_set	),
		.ic2_int_set(	ic2_int_set	)
		);

ac97_prc u14(	.clk(		clk_i		),
		.rst(		rst_i		),
		.valid(		valid_s		),
		.in_valid(	in_valid_s	),
		.out_slt0(	out_slt0	),
		.in_slt0(	in_slt0		),
		.in_slt1(	in_slt1		),
		.crac_valid(	crac_valid	),
		.crac_wr(	crac_wr		),
		.oc0_cfg(	oc0_cfg		),
		.oc1_cfg(	oc1_cfg		),
		.oc2_cfg(	oc2_cfg		),
		.oc3_cfg(	oc3_cfg		),
		.oc4_cfg(	oc4_cfg		),
		.oc5_cfg(	oc5_cfg		),
		.ic0_cfg(	ic0_cfg		),
		.ic1_cfg(	ic1_cfg		),
		.ic2_cfg(	ic2_cfg		),
		.o3_empty(	o3_empty	),
		.o4_empty(	o4_empty	),
		.o6_empty(	o6_empty	),
		.o7_empty(	o7_empty	),
		.o8_empty(	o8_empty	),
		.o9_empty(	o9_empty	),
		.i3_full(	i3_full		),
		.i4_full(	i4_full		),
		.i6_full(	i6_full		),
		.o3_re(		o3_re		),
		.o4_re(		o4_re		),
		.o6_re(		o6_re		),
		.o7_re(		o7_re		),
		.o8_re(		o8_re		),
		.o9_re(		o9_re		),
		.i3_we(		i3_we		),
		.i4_we(		i4_we		),
		.i6_we(		i6_we		)
		);

ac97_cra u15(	.clk(		clk_i		),
		.rst(		rst_i		),
		.crac_we(	crac_we		),
		.crac_din(	crac_din	),
		.crac_out(	crac_out	),
		.crac_wr_done(	crac_wr_done	),
		.crac_rd_done(	crac_rd_done	),
		.valid(		valid_s		),
		.out_slt1(	out_slt1	),
		.out_slt2(	out_slt2	),
		.in_slt2(	in_slt2		),
		.crac_valid(	crac_valid	),
		.crac_wr(	crac_wr		)
		);

ac97_dma_if u16(.clk(		clk_i		),
		.rst(		rst_i		),
		.o3_status(	o3_status	),
		.o4_status(	o4_status	),
		.o6_status(	o6_status	),
		.o7_status(	o7_status	),
		.o8_status(	o8_status	),
		.o9_status(	o9_status	),
		.o3_empty(	o3_empty	),
		.o4_empty(	o4_empty	),
		.o6_empty(	o6_empty	),
		.o7_empty(	o7_empty	),
		.o8_empty(	o8_empty	),
		.o9_empty(	o9_empty	),
		.i3_status(	i3_status	),
		.i4_status(	i4_status	),
		.i6_status(	i6_status	),
		.i3_full(	i3_full		),
		.i4_full(	i4_full		),
		.i6_full(	i6_full		),
		.oc0_cfg(	oc0_cfg		),
		.oc1_cfg(	oc1_cfg		),
		.oc2_cfg(	oc2_cfg		),
		.oc3_cfg(	oc3_cfg		),
		.oc4_cfg(	oc4_cfg		),
		.oc5_cfg(	oc5_cfg		),
		.ic0_cfg(	ic0_cfg		),
		.ic1_cfg(	ic1_cfg		),
		.ic2_cfg(	ic2_cfg		),
		.dma_req(	dma_req_o	),
		.dma_ack(	dma_ack_i	)
		);

ac97_int	u17(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	oc0_int_set	),
		.cfg(		oc0_cfg		),
		.status(	o3_status	),
		.full_empty(	o3_empty	),
		.full(		o3_full		),
		.empty(		o3_empty	),
		.re(		o3_re		),
		.we(		o3_we		)
		);

ac97_int	u18(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	oc1_int_set	),
		.cfg(		oc1_cfg		),
		.status(	o4_status	),
		.full_empty(	o4_empty	),
		.full(		o4_full		),
		.empty(		o4_empty	),
		.re(		o4_re		),
		.we(		o4_we		)
		);

`ifdef AC97_CENTER
ac97_int	u19(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	oc2_int_set	),
		.cfg(		oc2_cfg		),
		.status(	o6_status	),
		.full_empty(	o6_empty	),
		.full(		o6_full		),
		.empty(		o6_empty	),
		.re(		o6_re		),
		.we(		o6_we		)
		);
`else
assign oc2_int_set = 1'b0;
`endif

`ifdef AC97_SURROUND
ac97_int	u20(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	oc3_int_set	),
		.cfg(		oc3_cfg		),
		.status(	o7_status	),
		.full_empty(	o7_empty	),
		.full(		o7_full		),
		.empty(		o7_empty	),
		.re(		o7_re		),
		.we(		o7_we		)
		);

ac97_int	u21(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	oc4_int_set	),
		.cfg(		oc4_cfg		),
		.status(	o8_status	),
		.full_empty(	o8_empty	),
		.full(		o8_full		),
		.empty(		o8_empty	),
		.re(		o8_re		),
		.we(		o8_we		)
		);
`else
assign oc3_int_set = 1'b0;
assign oc4_int_set = 1'b0;
`endif

`ifdef AC97_LFE
ac97_int	u22(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	oc5_int_set	),
		.cfg(		oc5_cfg		),
		.status(	o9_status	),
		.full_empty(	o9_empty	),
		.full(		o9_full		),
		.empty(		o9_empty	),
		.re(		o9_re		),
		.we(		o9_we		)
		);
`else
assign oc5_int_set = 1'b0;
`endif

`ifdef AC97_SIN
ac97_int	u23(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	ic0_int_set	),
		.cfg(		ic0_cfg		),
		.status(	i3_status	),
		.full_empty(	i3_full		),
		.full(		i3_full		),
		.empty(		i3_empty	),
		.re(		i3_re		),
		.we(		i3_we		)
		);

ac97_int	u24(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	ic1_int_set	),
		.cfg(		ic1_cfg		),
		.status(	i4_status	),
		.full_empty(	i4_full		),
		.full(		i4_full		),
		.empty(		i4_empty	),
		.re(		i4_re		),
		.we(		i4_we		)
		);
`else
assign ic0_int_set = 1'b0;
assign ic1_int_set = 1'b0;
`endif

`ifdef AC97_MICIN
ac97_int	u25(
		.clk(		clk_i		),
		.rst(		rst_i		),
		.int_set(	ic2_int_set	),
		.cfg(		ic2_cfg		),
		.status(	i6_status	),
		.full_empty(	i6_full		),
		.full(		i6_full		),
		.empty(		i6_empty	),
		.re(		i6_re		),
		.we(		i6_we		)
		);
`else
assign ic2_int_set = 1'b0;
`endif

ac97_rst	u26(
		.clk(		clk_i				),
		.rst(		rst_i 				),
		.rst_force(	ac97_rst_force			),
		.ps_ce(		ps_ce				),
		.ac97_rst_(	ac97_resetn_pad_o		)
		);

endmodule


