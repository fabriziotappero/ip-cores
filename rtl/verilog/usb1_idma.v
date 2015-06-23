/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Internal DMA Engine                                        ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb1_funct/////
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
//  $Id: usb1_idma.v,v 1.2 2002-09-25 06:06:49 rudi Exp $
//
//  $Date: 2002-09-25 06:06:49 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1.1.1  2002/09/19 12:07:38  rudi
//               Initial Checkin
//
//
//
//
//
//

`include "usb1_defines.v"

module usb1_idma(	clk, rst,

		// Packet Disassembler/Assembler interface
		rx_data_valid,
		rx_data_done, 
		send_data,
		rd_next,

		tx_valid,
		tx_data_st_i,
		tx_data_st_o,

		// Protocol Engine
		tx_dma_en, rx_dma_en, idma_done,
		ep_sel,

		// Register File Manager Interface
		size,
		rx_cnt, rx_done,
		tx_busy,

		// Block Frames
		ep_bf_en, ep_bf_size,
		dropped_frame, misaligned_frame,

		// Memory Arb interface
		mwe, mre, ep_empty, ep_empty_int, ep_full
		);


// Packet Disassembler/Assembler interface
input		clk, rst;
input		rx_data_valid;
input		rx_data_done;
output		send_data;
input		rd_next;

input		tx_valid;
input	[7:0]	tx_data_st_i;
output	[7:0]	tx_data_st_o;

// Protocol Engine
input		tx_dma_en;
input		rx_dma_en;
output		idma_done;	// DMA is done
input	[3:0]	ep_sel;

// Register File Manager Interface
input	[8:0]	size;		// MAX PL Size in bytes
output	[7:0]	rx_cnt;
output		rx_done;
output		tx_busy;

input		ep_bf_en;
input	[6:0]	ep_bf_size;
output		dropped_frame;
output		misaligned_frame;

// Memory Arb interface
output		mwe;
output		mre;
input		ep_empty;
output		ep_empty_int;
input		ep_full;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

reg		tx_dma_en_r;
reg	[8:0]	sizd_c;			// Internal size counter
wire		adr_incw;
wire		adr_incb;
wire		siz_dec;
wire		mwe;			// Memory Write enable
wire		mre;			// Memory Read enable
reg		mwe_r;
reg		sizd_is_zero;		// Indicates when all bytes have been
					// transferred
wire		sizd_is_zero_d;
reg		idma_done;		// DMA transfer is done
wire		send_data;		// Enable UTMI Transmitter
reg		rx_data_done_r;
reg		rx_data_valid_r;
wire		ff_re, ff_full, ff_empty;
reg		ff_we, ff_we1;
reg		tx_dma_en_r1;
reg		tx_dma_en_r2;
reg		tx_dma_en_r3;
reg		send_data_r;
wire		ff_clr;
reg	[7:0]	rx_cnt;
reg	[7:0]	rx_cnt_r;
reg		ep_empty_r;
reg		ep_empty_latched;
wire		ep_empty_int;
reg	[6:0]	ec;
wire		ec_clr;
reg		dropped_frame;
reg	[6:0]	rc_cnt;
wire		rc_clr;
reg		ep_full_latched;
wire		ep_full_int;
reg		misaligned_frame;
reg		tx_valid_r;
wire		tx_valid_e;

///////////////////////////////////////////////////////////////////
//
// For IN Block Frames transmit frames in [ep_bf_size] byte quantities
//

`ifdef USB1_BF_ENABLE

always @(posedge clk)
	if(!rst)		ec <= #1 7'h0;
	else
	if(!ep_bf_en | ec_clr)	ec <= #1 7'h0;
	else
	if(mre)			ec <= #1 ec + 7'h1;

assign ec_clr = (ec == ep_bf_size) | tx_dma_en; 

always @(posedge clk)
	if(!rst)	ep_empty_latched <= #1 1'b0;
	else
	if(ec_clr)	ep_empty_latched <= #1 ep_empty;

assign ep_empty_int = ep_bf_en ? ep_empty_latched : ep_empty;
`else
assign ep_empty_int = ep_empty;
`endif
///////////////////////////////////////////////////////////////////
//
// For OUT Block Frames always store in [ep_bf_size] byte chunks
// if fifo can't accept [ep_bf_size] bytes junk the entire [ep_bf_size]
// byte frame
//

`ifdef USB1_BF_ENABLE
always @(posedge clk)
	if(!rst)		rc_cnt <= #1 7'h0;
	else
	if(!ep_bf_en | rc_clr)	rc_cnt <= #1 7'h0;
	else
	if(mwe_r)		rc_cnt <= #1 rc_cnt + 7'h1;

assign rc_clr = ((rc_cnt == ep_bf_size) & mwe_r) | rx_dma_en; 

always @(posedge clk)
	if(!rst)	ep_full_latched <= #1 1'b0;
	else
	if(rc_clr)	ep_full_latched <= #1 ep_full;

assign ep_full_int = ep_bf_en ? ep_full_latched : ep_full;

always @(posedge clk)
	dropped_frame <= #1 rc_clr & ep_full & ep_bf_en;

always @(posedge clk)
	misaligned_frame <= #1 rx_data_done_r & ep_bf_en & (rc_cnt!=7'd00);
`else
assign ep_full_int = ep_full;

always @(posedge clk)
	dropped_frame <= #1 1'b0;

always @(posedge clk)
	misaligned_frame <= #1 1'b0;

`endif

// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
always @(posedge dropped_frame)
	$display("WARNING: BF: Droped one OUT frame (no space in FIFO) (%t)",$time);

always @(posedge misaligned_frame)
	$display("WARNING: BF: Received misaligned frame (%t)",$time);
`endif
// synopsys translate_on

///////////////////////////////////////////////////////////////////
//
// FIFO interface
//

always @(posedge clk)
	mwe_r <= #1 rx_data_valid;

assign mwe = mwe_r & !ep_full_int;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
	rx_data_valid_r <= #1 rx_data_valid;

always @(posedge clk)
	rx_data_done_r <= #1 rx_data_done;

// Generate one cycle pulses for tx and rx dma enable
always @(posedge clk)
	tx_dma_en_r <= #1 tx_dma_en;

always @(posedge clk)
	tx_dma_en_r1 <= tx_dma_en_r;

always @(posedge clk)
	tx_dma_en_r2 <= tx_dma_en_r1;

always @(posedge clk)
	tx_dma_en_r3 <= tx_dma_en_r2;

// DMA Done Indicator
always @(posedge clk)
	idma_done <= #1 (rx_data_done_r | sizd_is_zero_d | ep_empty_int);

///////////////////////////////////////////////////////////////////
//
// RX Size Counter
//

always @(posedge clk or negedge rst)
	if(!rst)			rx_cnt_r <= #1 8'h00;
	else
	if(rx_data_done_r)		rx_cnt_r <= #1 8'h00;
	else
	if(rx_data_valid)		rx_cnt_r <= #1 rx_cnt_r + 8'h01;

always @(posedge clk or negedge rst)
	if(!rst)		rx_cnt <= #1 8'h00;
	else
	if(rx_data_done_r)	rx_cnt <= #1 rx_cnt_r;

assign rx_done = rx_data_done_r;

///////////////////////////////////////////////////////////////////
//
// Transmit Size Counter (counting backward from input size)
// For MAX packet size
//

always @(posedge clk or negedge rst)
	if(!rst)			sizd_c <= #1 9'h1ff;
	else
	if(tx_dma_en)			sizd_c <= #1 size;
	else
	if(siz_dec)			sizd_c <= #1 sizd_c - 9'h1;

assign siz_dec = (tx_dma_en_r | tx_dma_en_r1 | rd_next) & !sizd_is_zero_d;

assign sizd_is_zero_d = sizd_c == 9'h0;

always @(posedge clk)
	sizd_is_zero <= #1 sizd_is_zero_d;

///////////////////////////////////////////////////////////////////
//
// TX Logic
//

assign tx_busy = send_data | tx_dma_en_r | tx_dma_en;

always @(posedge clk)
	tx_valid_r <= #1 tx_valid;

assign tx_valid_e = tx_valid_r & !tx_valid;

// Since we are prefetching two entries in to our fast fifo, we
// need to know when exactly ep_empty was asserted, as we might
// only need 1 or 2 bytes. This is for ep_empty_r

always @(posedge clk or negedge rst)
	if(!rst)				ep_empty_r <= #1 1'b0;
	else
	if(!tx_valid)				ep_empty_r <= #1 1'b0;
	else
	if(tx_dma_en_r2)			ep_empty_r <= #1 ep_empty_int;

always @(posedge clk or negedge rst)
	if(!rst)				send_data_r <= #1 1'b0;
	else
	if((tx_dma_en_r & !ep_empty_int))		send_data_r <= #1 1'b1;
	else
	if(rd_next & (sizd_is_zero_d | (ep_empty_int & !sizd_is_zero_d)) )
						send_data_r <= #1 1'b0;

assign send_data = (send_data_r & !ep_empty_r & 
		!(sizd_is_zero & size==9'h01)) | tx_dma_en_r1;

assign mre = (tx_dma_en_r1 | tx_dma_en_r | rd_next) &
		!sizd_is_zero_d & !ep_empty_int & (send_data | tx_dma_en_r1 | tx_dma_en_r);

always @(posedge clk)
	ff_we1 <= mre;

always @(posedge clk)
	ff_we <= ff_we1;

assign ff_re = rd_next;

assign ff_clr = !tx_valid;

///////////////////////////////////////////////////////////////////
//
// IDMA fast prefetch fifo
//

// tx fifo
usb1_fifo2 ff(
	.clk(		clk		),
	.rst(		rst		),
	.clr(		ff_clr		),
	.din(		tx_data_st_i	),
	.we(		ff_we		),
	.dout(		tx_data_st_o	),
	.re(		ff_re		)
	);

endmodule


