/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Protocol Layer                                             ////
////  This block is typically referred to as the SEI in USB      ////
////  Specification. It encapsulates the Packet Assembler,       ////
////  disassembler, protocol engine and internal DMA             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org/cores/usb1_fucnt/////
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
//  $Id: usb1_pl.v,v 1.2 2002-09-25 06:06:49 rudi Exp $
//
//  $Date: 2002-09-25 06:06:49 $
//  $Revision: 1.2 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1.1.1  2002/09/19 12:07:28  rudi
//               Initial Checkin
//
//
//
//
//
//
//
//
//

module usb1_pl(	clk, rst,

		// UTMI Interface
		rx_data, rx_valid, rx_active, rx_err,
		tx_data, tx_valid, tx_valid_last, tx_ready,
		tx_first, tx_valid_out,

		token_valid,

		// Register File Interface
		fa,
		ep_sel, 
		x_busy,
		int_crc16_set, int_to_set, int_seqerr_set,

		// Misc
		frm_nat,
		pid_cs_err, nse_err,
		crc5_err,
		rx_size, rx_done,
		ctrl_setup, ctrl_in, ctrl_out,

		// Block Frames
		ep_bf_en, ep_bf_size,
		dropped_frame, misaligned_frame,

		// EP Interface
		csr,
		tx_data_st, rx_data_st, idma_re, idma_we,
		ep_empty, ep_full, send_stall

		);

// UTMI Interface
input		clk, rst;
input	[7:0]	rx_data;
input		rx_valid, rx_active, rx_err;
output	[7:0]	tx_data;
output		tx_valid;
output		tx_valid_last;
input		tx_ready;
output		tx_first;
input		tx_valid_out;

output		token_valid;

// Register File interface
input	[6:0]	fa;		// Function Address (as set by the controller)
output	[3:0]	ep_sel;		// Endpoint Number Input
output		x_busy;		// Indicates USB is busy

output		int_crc16_set;	// Set CRC16 error interrupt
output		int_to_set;	// Set time out interrupt
output		int_seqerr_set;	// Set PID sequence error interrupt

// Misc
output		pid_cs_err;	// pid checksum error
output		crc5_err;	// crc5 error
output	[31:0]	frm_nat;
output		nse_err;	// no such endpoint error
output	[7:0]	rx_size;
output		rx_done;
output		ctrl_setup;
output		ctrl_in;
output		ctrl_out;
input		ep_bf_en;
input	[6:0]	ep_bf_size;
output		dropped_frame, misaligned_frame;

// Endpoint Interfaces
input	[13:0]	csr;	
input	[7:0]	tx_data_st;
output	[7:0]	rx_data_st;
output		idma_re, idma_we;
input		ep_empty;
input		ep_full;

input		send_stall;

///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

// Packet Disassembler Interface
wire		clk, rst;
wire	[7:0]	rx_data;
wire		pid_OUT, pid_IN, pid_SOF, pid_SETUP;
wire		pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA;
wire		pid_ACK, pid_NACK, pid_STALL, pid_NYET;
wire		pid_PRE, pid_ERR, pid_SPLIT, pid_PING;
wire	[6:0]	token_fadr;
wire		token_valid;
wire		crc5_err;
wire	[10:0]	frame_no;
reg	[7:0]	rx_data_st;
wire	[7:0]	rx_data_st_d;
wire		rx_data_valid;
wire		rx_data_done;
wire		crc16_err;
wire		rx_seq_err;

// Packet Assembler Interface
wire		send_token;
wire	[1:0]	token_pid_sel;
wire		send_data;
wire	[1:0]	data_pid_sel;
wire	[7:0]	tx_data_st;
wire	[7:0]	tx_data_st_o;
wire		rd_next;

// IDMA Interface
wire		rx_dma_en;	// Allows the data to be stored
wire		tx_dma_en;	// Allows for data to be retrieved
wire		abort;		// Abort Transfer (time_out, crc_err or rx_error)
wire		idma_done;	// DMA is done

// Memory Arbiter Interface
wire		idma_we;
wire		idma_re;

// Local signals
wire		pid_bad;

reg		hms_clk;	// 0.5 Micro Second Clock
reg	[4:0]	hms_cnt;
reg	[10:0]	frame_no_r;	// Current Frame Number register
wire		frame_no_we;
reg	[11:0]	sof_time;	// Time since last sof
reg		clr_sof_time;
wire		fsel;		// This Function is selected
wire		match_o;

reg		frame_no_we_r;
reg		ctrl_setup;
reg		ctrl_in;
reg		ctrl_out;

wire		idma_we_d;
wire		ep_empty_int;
wire		rx_busy;
wire		tx_busy;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

assign x_busy = tx_busy | rx_busy;

// PIDs we should never receive
assign pid_bad = pid_ACK | pid_NACK | pid_STALL | pid_NYET | pid_PRE |
			pid_ERR | pid_SPLIT |  pid_PING;

assign match_o = !pid_bad & token_valid & !crc5_err;

// Receiving Setup
always @(posedge clk)
	ctrl_setup <= #1 token_valid & pid_SETUP & (ep_sel==4'h0);

always @(posedge clk)
	ctrl_in <= #1 token_valid & pid_IN & (ep_sel==4'h0);

always @(posedge clk)
	ctrl_out <= #1 token_valid & pid_OUT & (ep_sel==4'h0);

// Frame Number (from SOF token)
assign frame_no_we = token_valid & !crc5_err & pid_SOF;

always @(posedge clk)
	frame_no_we_r <= #1 frame_no_we;

always @(posedge clk or negedge rst)
	if(!rst)		frame_no_r <= #1 11'h0;
	else
	if(frame_no_we_r)	frame_no_r <= #1 frame_no;

//SOF delay counter
always @(posedge clk)
	clr_sof_time <= #1 frame_no_we;

always @(posedge clk)
	if(clr_sof_time)	sof_time <= #1 12'h0;
	else
	if(hms_clk)		sof_time <= #1 sof_time + 12'h1;

assign frm_nat = {4'h0, 1'b0, frame_no_r, 4'h0, sof_time};

// 0.5 Micro Seconds Clock Generator
always @(posedge clk or negedge rst)
	if(!rst)				hms_cnt <= #1 5'h0;
	else
	if(hms_clk | frame_no_we_r)		hms_cnt <= #1 5'h0;
	else					hms_cnt <= #1 hms_cnt + 5'h1;

always @(posedge clk)
	hms_clk <= #1 (hms_cnt == `USBF_HMS_DEL);

always @(posedge clk)
	rx_data_st <= rx_data_st_d;

///////////////////////////////////////////////////////////////////

// This function is addressed
assign fsel = (token_fadr == fa);

// Only write when we are addressed !!!
assign idma_we = idma_we_d & fsel; // moved full check to idma ...  & !ep_full;

///////////////////////////////////////////////////////////////////
//
// Module Instantiations
//

//Packet Decoder
usb1_pd	u0(	.clk(		clk		),
		.rst(		rst		),

		.rx_data(	rx_data		),
		.rx_valid(	rx_valid	),
		.rx_active(	rx_active	),
		.rx_err(	rx_err		),
		.pid_OUT(	pid_OUT		),
		.pid_IN(	pid_IN		),
		.pid_SOF(	pid_SOF		),
		.pid_SETUP(	pid_SETUP	),
		.pid_DATA0(	pid_DATA0	),
		.pid_DATA1(	pid_DATA1	),
		.pid_DATA2(	pid_DATA2	),
		.pid_MDATA(	pid_MDATA	),
		.pid_ACK(	pid_ACK		),
		.pid_NACK(	pid_NACK	),
		.pid_STALL(	pid_STALL	),
		.pid_NYET(	pid_NYET	),
		.pid_PRE(	pid_PRE		),
		.pid_ERR(	pid_ERR		),
		.pid_SPLIT(	pid_SPLIT	),
		.pid_PING(	pid_PING	),
		.pid_cks_err(	pid_cs_err	),
		.token_fadr(	token_fadr	),
		.token_endp(	ep_sel		),
		.token_valid(	token_valid	),
		.crc5_err(	crc5_err	),
		.frame_no(	frame_no	),
		.rx_data_st(	rx_data_st_d	),
		.rx_data_valid(	rx_data_valid	),
		.rx_data_done(	rx_data_done	),
		.crc16_err(	crc16_err	),
		.seq_err(	rx_seq_err	),
		.rx_busy(	rx_busy		)
		);

// Packet Assembler
usb1_pa	u1(	.clk(		clk		),
		.rst(		rst		),
		.tx_data(	tx_data		),
		.tx_valid(	tx_valid	),
		.tx_valid_last(	tx_valid_last	),
		.tx_ready(	tx_ready	),
		.tx_first(	tx_first	),
		.send_token(	send_token	),
		.token_pid_sel(	token_pid_sel	),
		.send_data(	send_data	),
		.data_pid_sel(	data_pid_sel	),
		.tx_data_st(	tx_data_st_o	),
		.rd_next(	rd_next		),
		.ep_empty(	ep_empty_int)
		);

// Internal DMA / Memory Arbiter Interface
usb1_idma
	u2(	.clk(		clk		),
		.rst(		rst		),

		.tx_valid(	tx_valid	),
		.rx_data_valid(	rx_data_valid	),
		.rx_data_done(	rx_data_done	),
		.send_data(	send_data	),
		.rd_next(	rd_next		),

		.tx_data_st_i(	tx_data_st	),
		.tx_data_st_o(	tx_data_st_o	),
		.ep_sel(	ep_sel		),

		.ep_bf_en(	ep_bf_en	),
		.ep_bf_size(	ep_bf_size	),
		.dropped_frame(dropped_frame	),
		.misaligned_frame(misaligned_frame),

		.tx_busy(	tx_busy		),

		.tx_dma_en(	tx_dma_en	),
		.rx_dma_en(	rx_dma_en	),
		.idma_done(	idma_done	),
		.size(		csr[8:0]	),
		.rx_cnt(	rx_size		),
		.rx_done(	rx_done		),
		.mwe(		idma_we_d	),
		.mre(		idma_re		),
		.ep_empty(	ep_empty	),
		.ep_empty_int(	ep_empty_int	),
		.ep_full(	ep_full		)
		);

// Protocol Engine
usb1_pe
	u3(	.clk(			clk			),
		.rst(			rst			),

		.tx_valid(		tx_valid_out		),
		.rx_active(		rx_active		),
		.pid_OUT(		pid_OUT			),
		.pid_IN(		pid_IN			),
		.pid_SOF(		pid_SOF			),
		.pid_SETUP(		pid_SETUP		),
		.pid_DATA0(		pid_DATA0		),
		.pid_DATA1(		pid_DATA1		),
		.pid_DATA2(		pid_DATA2		),
		.pid_MDATA(		pid_MDATA		),
		.pid_ACK(		pid_ACK			),
		.pid_PING(		pid_PING		),
		.token_valid(		token_valid		),
		.rx_data_done(		rx_data_done		),
		.crc16_err(		crc16_err		),
		.send_token(		send_token		),
		.token_pid_sel(		token_pid_sel		),
		.data_pid_sel(		data_pid_sel		),
		.rx_dma_en(		rx_dma_en		),
		.tx_dma_en(		tx_dma_en		),
		.abort(			abort			),
		.idma_done(		idma_done		),
		.fsel(			fsel			),
		.ep_sel(		ep_sel			),
		.ep_full(		ep_full			),
		.ep_empty(		ep_empty		),
		.match(			match_o			),
		.nse_err(		nse_err			),
		.int_upid_set(		int_upid_set		),
		.int_crc16_set(		int_crc16_set		),
		.int_to_set(		int_to_set		),
		.int_seqerr_set(	int_seqerr_set		),
		.csr(			csr			),
		.send_stall(		send_stall		)
		);

endmodule
