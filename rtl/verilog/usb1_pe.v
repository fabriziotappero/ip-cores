/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Protocol Engine                                            ////
////  Performs automatic protocol functions                      ////
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
//  $Id: usb1_pe.v,v 1.1.1.1 2002-09-19 12:07:24 rudi Exp $
//
//  $Date: 2002-09-19 12:07:24 $
//  $Revision: 1.1.1.1 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//
//
//
//
//
//

`include "usb1_defines.v"

module usb1_pe(	clk, rst,

		// UTMI Interfaces
		tx_valid, rx_active,

		// PID Information
		pid_OUT, pid_IN, pid_SOF, pid_SETUP,
		pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA,
		pid_ACK, pid_PING,

		// Token Information
		token_valid, 

		// Receive Data Output
		rx_data_done, crc16_err,

		// Packet Assembler Interface
		send_token, token_pid_sel,
		data_pid_sel,

		// IDMA Interface
		rx_dma_en, tx_dma_en,
		abort,
		idma_done,

		// Register File Interface

		fsel,
		ep_sel, match, nse_err,
		ep_full, ep_empty,

		int_upid_set, int_crc16_set, int_to_set, int_seqerr_set,
		csr,
		send_stall

		);

input		clk, rst;
input		tx_valid, rx_active;

// Packet Disassembler Interface
		// Decoded PIDs (used when token_valid is asserted)
input		pid_OUT, pid_IN, pid_SOF, pid_SETUP;
input		pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA;
input		pid_ACK, pid_PING;

input		token_valid;		// Token is valid

input		rx_data_done;		// Indicates end of a transfer
input		crc16_err;		// Data packet CRC 16 error

// Packet Assembler Interface
output		send_token;
output	[1:0]	token_pid_sel;
output	[1:0]	data_pid_sel;

// IDMA Interface
output		rx_dma_en;	// Allows the data to be stored
output		tx_dma_en;	// Allows for data to be retrieved
output		abort;		// Abort Transfer (time_out, crc_err or rx_error)
input		idma_done;	// DMA is done indicator

input		ep_full;	// Indicates the endpoints fifo is full
input		ep_empty;	// Indicates the endpoints fifo is empty

// Register File interface
input		fsel;		// This function is selected
input	[3:0]	ep_sel;		// Endpoint Number Input
input		match;		// Endpoint Matched
output		nse_err;	// no such endpoint error

output		int_upid_set;	// Set unsupported PID interrupt
output		int_crc16_set;	// Set CRC16 error interrupt
output		int_to_set;	// Set time out interrupt
output		int_seqerr_set;	// Set PID sequence error interrupt

input	[13:0]	csr;		// Internal CSR Output

input		send_stall;	// Force sending a STALL during setup


///////////////////////////////////////////////////////////////////
//
// Local Wires and Registers
//

// tx token decoding
parameter	ACK   = 0,
		NACK  = 1,
		STALL = 2,
		NYET  = 3;

// State decoding
parameter	[9:0]	// synopsys enum state
		IDLE	= 10'b000000_0001,
		TOKEN	= 10'b000000_0010,
		IN	= 10'b000000_0100,
		IN2	= 10'b000000_1000,
		OUT	= 10'b000001_0000,
		OUT2A	= 10'b000010_0000,
		OUT2B	= 10'b000100_0000,
		UPDATEW	= 10'b001000_0000,
		UPDATE	= 10'b010000_0000,
		UPDATE2	= 10'b100000_0000;

reg	[1:0]	token_pid_sel;
reg	[1:0]	token_pid_sel_d;
reg		send_token;
reg		send_token_d;
reg		rx_dma_en, tx_dma_en;
reg		int_seqerr_set_d;
reg		int_seqerr_set;
reg		int_upid_set;

reg		match_r;

// Endpoint Decoding
wire		IN_ep, OUT_ep, CTRL_ep;		// Endpoint Types
wire		txfr_iso, txfr_bulk, txfr_int;	// Transfer Types

reg	[1:0]	uc_dpd;

// Buffer checks
reg	[9:0]	/* synopsys enum state */ state, next_state;
// synopsys state_vector state

// PID next and current decoders
reg	[1:0]	next_dpid;
reg	[1:0]	this_dpid;
reg		pid_seq_err;
wire	[1:0]	tr_fr_d;

wire	[13:0]	size_next;
wire		buf_smaller;

// After sending Data in response to an IN token from host, the
// host must reply with an ack. The host has XXXnS to reply.
// "rx_ack_to" indicates when this time has expired.
// rx_ack_to_clr, clears the timer
reg		rx_ack_to_clr;
reg		rx_ack_to_clr_d;
reg		rx_ack_to;
reg	[7:0]	rx_ack_to_cnt;

// After sending a OUT token the host must send a data packet.
// The host has XX nS to send the packet. "tx_data_to" indicates
// when this time has expired.
// tx_data_to_clr, clears the timer
wire		tx_data_to_clr;
reg		tx_data_to;
reg	[7:0]	tx_data_to_cnt;

wire	[7:0]	rx_ack_to_val, tx_data_to_val;


wire	[1:0]	next_bsel;
reg		uc_stat_set_d;
reg		uc_dpd_set;

reg		in_token;
reg		out_token;
reg		setup_token;

wire		in_op, out_op;	// Indicate a IN or OUT operation

reg	[1:0]	allow_pid;

reg		nse_err;
reg		abort;

wire	[1:0]	ep_type, txfr_type;

///////////////////////////////////////////////////////////////////
//
// Misc Logic
//

// Endpoint/CSR Decoding
assign IN_ep   = csr[9];
assign OUT_ep  = csr[10];
assign CTRL_ep = csr[11];

assign txfr_iso  = csr[12];
assign txfr_bulk = csr[13];
assign txfr_int = !csr[12] & !csr[13];

assign ep_type = csr[10:9];
assign txfr_type = csr[13:12];

always @(posedge clk)
	match_r <= #1 match  & fsel;

// No Such Endpoint Indicator
always @(posedge clk)
	nse_err <= #1 token_valid & (pid_OUT | pid_IN | pid_SETUP) & !match;

always @(posedge clk)
	send_token <= #1 send_token_d;

always @(posedge clk)
	token_pid_sel <= #1 token_pid_sel_d;

///////////////////////////////////////////////////////////////////
//
// Data Pid Storage
//

reg	[1:0]	ep0_dpid, ep1_dpid, ep2_dpid, ep3_dpid;
reg	[1:0]	ep4_dpid, ep5_dpid, ep6_dpid, ep7_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep0_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h0))	ep0_dpid <= next_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep1_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h1))	ep1_dpid <= next_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep2_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h2))	ep2_dpid <= next_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep3_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h3))	ep3_dpid <= next_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep4_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h4))	ep4_dpid <= next_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep5_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h5))	ep5_dpid <= next_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep6_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h6))	ep6_dpid <= next_dpid;

always @(posedge clk or negedge rst)
	if(!rst)				ep7_dpid <= 2'b00;
	else
	if(uc_dpd_set & (ep_sel == 4'h7))	ep7_dpid <= next_dpid;

always @(posedge clk)
	case(ep_sel)
	   4'h0: uc_dpd <= ep0_dpid;
	   4'h1: uc_dpd <= ep1_dpid;
	   4'h2: uc_dpd <= ep2_dpid;
	   4'h3: uc_dpd <= ep3_dpid;
	   4'h4: uc_dpd <= ep4_dpid;
	   4'h5: uc_dpd <= ep5_dpid;
	   4'h6: uc_dpd <= ep6_dpid;
	   4'h7: uc_dpd <= ep7_dpid;
	endcase

///////////////////////////////////////////////////////////////////
//
// Data Pid Sequencer
//

assign tr_fr_d = 2'h0;

always @(posedge clk)	// tr/mf:ep/type:tr/type:last dpd
	casex({tr_fr_d,ep_type,txfr_type,uc_dpd})	// synopsys full_case parallel_case
	   8'b0?_01_01_??: next_dpid <= #1 2'b00;	// ISO txfr. IN, 1 tr/mf

	   8'b10_01_01_?0: next_dpid <= #1 2'b01;	// ISO txfr. IN, 2 tr/mf
	   8'b10_01_01_?1: next_dpid <= #1 2'b00;	// ISO txfr. IN, 2 tr/mf

	   8'b11_01_01_00: next_dpid <= #1 2'b01;	// ISO txfr. IN, 3 tr/mf
	   8'b11_01_01_01: next_dpid <= #1 2'b10;	// ISO txfr. IN, 3 tr/mf
	   8'b11_01_01_10: next_dpid <= #1 2'b00;	// ISO txfr. IN, 3 tr/mf

	   8'b0?_10_01_??: next_dpid <= #1 2'b00;	// ISO txfr. OUT, 1 tr/mf

	   8'b10_10_01_??: 				// ISO txfr. OUT, 2 tr/mf
			   begin	// Resynchronize in case of PID error
				case({pid_MDATA, pid_DATA1})	// synopsys full_case parallel_case
				  2'b10: next_dpid <= #1 2'b01;
				  2'b01: next_dpid <= #1 2'b00;
				endcase
			   end

	   8'b11_10_01_00: 				// ISO txfr. OUT, 3 tr/mf
			   begin	// Resynchronize in case of PID error
				case({pid_MDATA, pid_DATA2})	// synopsys full_case parallel_case
				  2'b10: next_dpid <= #1 2'b01;
				  2'b01: next_dpid <= #1 2'b00;
				endcase
			   end
	   8'b11_10_01_01: 				// ISO txfr. OUT, 3 tr/mf
			   begin	// Resynchronize in case of PID error
				case({pid_MDATA, pid_DATA2})	// synopsys full_case parallel_case
				  2'b10: next_dpid <= #1 2'b10;
				  2'b01: next_dpid <= #1 2'b00;
				endcase
			   end
	   8'b11_10_01_10: 				// ISO txfr. OUT, 3 tr/mf
			   begin	// Resynchronize in case of PID error
				case({pid_MDATA, pid_DATA2})	// synopsys full_case parallel_case
				  2'b10: next_dpid <= #1 2'b01;
				  2'b01: next_dpid <= #1 2'b00;
				endcase
			   end

	   8'b??_01_00_?0,				// IN/OUT endpoint only
	   8'b??_10_00_?0: next_dpid <= #1 2'b01;	// INT transfers

	   8'b??_01_00_?1,				// IN/OUT endpoint only
	   8'b??_10_00_?1: next_dpid <= #1 2'b00;	// INT transfers

	   8'b??_01_10_?0,				// IN/OUT endpoint only
	   8'b??_10_10_?0: next_dpid <= #1 2'b01;	// BULK transfers

	   8'b??_01_10_?1,				// IN/OUT endpoint only
	   8'b??_10_10_?1: next_dpid <= #1 2'b00;	// BULK transfers

	   8'b??_00_??_??:				// CTRL Endpoint
		casex({setup_token, in_op, out_op, uc_dpd})	// synopsys full_case parallel_case
		   5'b1_??_??: next_dpid <= #1 2'b11;	// SETUP operation
		   5'b0_10_0?: next_dpid <= #1 2'b11;	// IN operation
		   5'b0_10_1?: next_dpid <= #1 2'b01;	// IN operation
		   5'b0_01_?0: next_dpid <= #1 2'b11;	// OUT operation
		   5'b0_01_?1: next_dpid <= #1 2'b10;	// OUT operation
		endcase

	endcase

// Current PID decoder

// Allow any PID for ISO. transfers when mode full speed or tr_fr is zero
always @(pid_DATA0 or pid_DATA1 or pid_DATA2 or pid_MDATA)
	case({pid_DATA0, pid_DATA1, pid_DATA2, pid_MDATA} ) // synopsys full_case parallel_case
	   4'b1000: allow_pid = 2'b00;
	   4'b0100: allow_pid = 2'b01;
	   4'b0010: allow_pid = 2'b10;
	   4'b0001: allow_pid = 2'b11;
	endcase

always @(posedge clk)	// tf/mf:ep/type:tr/type:last dpd
	casex({tr_fr_d,ep_type,txfr_type,uc_dpd})	// synopsys full_case parallel_case
	   8'b0?_01_01_??: this_dpid <= #1 2'b00;	// ISO txfr. IN, 1 tr/mf

	   8'b10_01_01_?0: this_dpid <= #1 2'b01;	// ISO txfr. IN, 2 tr/mf
	   8'b10_01_01_?1: this_dpid <= #1 2'b00;	// ISO txfr. IN, 2 tr/mf

	   8'b11_01_01_00: this_dpid <= #1 2'b10;	// ISO txfr. IN, 3 tr/mf
	   8'b11_01_01_01: this_dpid <= #1 2'b01;	// ISO txfr. IN, 3 tr/mf
	   8'b11_01_01_10: this_dpid <= #1 2'b00;	// ISO txfr. IN, 3 tr/mf

	   8'b00_10_01_??: this_dpid <= #1 allow_pid;	// ISO txfr. OUT, 0 tr/mf
	   8'b01_10_01_??: this_dpid <= #1 2'b00;	// ISO txfr. OUT, 1 tr/mf

	   8'b10_10_01_?0: this_dpid <= #1 2'b11;	// ISO txfr. OUT, 2 tr/mf
	   8'b10_10_01_?1: this_dpid <= #1 2'b01;	// ISO txfr. OUT, 2 tr/mf

	   8'b11_10_01_00: this_dpid <= #1 2'b11;	// ISO txfr. OUT, 3 tr/mf
	   8'b11_10_01_01: this_dpid <= #1 2'b11;	// ISO txfr. OUT, 3 tr/mf
	   8'b11_10_01_10: this_dpid <= #1 2'b10;	// ISO txfr. OUT, 3 tr/mf

	   8'b??_01_00_?0,				// IN/OUT endpoint only
	   8'b??_10_00_?0: this_dpid <= #1 2'b00;	// INT transfers
	   8'b??_01_00_?1,				// IN/OUT endpoint only
	   8'b??_10_00_?1: this_dpid <= #1 2'b01;	// INT transfers

	   8'b??_01_10_?0,				// IN/OUT endpoint only
	   8'b??_10_10_?0: this_dpid <= #1 2'b00;	// BULK transfers
	   8'b??_01_10_?1,				// IN/OUT endpoint only
	   8'b??_10_10_?1: this_dpid <= #1 2'b01;	// BULK transfers

	   8'b??_00_??_??:				// CTRL Endpoint
		casex({setup_token,in_op, out_op, uc_dpd})	// synopsys full_case parallel_case
		   5'b1_??_??: this_dpid <= #1 2'b00;	// SETUP operation
		   5'b0_10_0?: this_dpid <= #1 2'b00;	// IN operation
		   5'b0_10_1?: this_dpid <= #1 2'b01;	// IN operation
		   5'b0_01_?0: this_dpid <= #1 2'b00;	// OUT operation
		   5'b0_01_?1: this_dpid <= #1 2'b01;	// OUT operation
		endcase
	endcase

// Assign PID for outgoing packets
assign data_pid_sel = this_dpid;

// Verify PID for incoming data packets
always @(posedge clk)
	pid_seq_err <= #1 !(	(this_dpid==2'b00 & pid_DATA0) |
				(this_dpid==2'b01 & pid_DATA1) |
				(this_dpid==2'b10 & pid_DATA2) |
				(this_dpid==2'b11 & pid_MDATA)	);

///////////////////////////////////////////////////////////////////
//
// IDMA Setup & src/dst buffer select
//

// For Control endpoints things are different:
// buffer0 is used for OUT (incoming) data packets
// buffer1 is used for IN (outgoing) data packets

// Keep track of last token for control endpoints
always @(posedge clk or negedge rst)
	if(!rst)		in_token <= #1 1'b0;
	else
	if(pid_IN)		in_token <= #1 1'b1;
	else
	if(pid_OUT | pid_SETUP)	in_token <= #1 1'b0;

always @(posedge clk or negedge rst)
	if(!rst)		out_token <= #1 1'b0;
	else
	if(pid_OUT | pid_SETUP)	out_token <= #1 1'b1;
	else
	if(pid_IN)		out_token <= #1 1'b0;

always @(posedge clk or negedge rst)
	if(!rst)		setup_token <= #1 1'b0;
	else
	if(pid_SETUP)		setup_token <= #1 1'b1;
	else
	if(pid_OUT | pid_IN)	setup_token <= #1 1'b0;

// Indicates if we are performing an IN operation
assign	in_op = IN_ep | (CTRL_ep & in_token);

// Indicates if we are performing an OUT operation
assign	out_op = OUT_ep | (CTRL_ep & out_token);


///////////////////////////////////////////////////////////////////
//
// Determine if packet is to small or to large
// This is used to NACK and ignore packet for OUT endpoints
//


///////////////////////////////////////////////////////////////////
//
// Register File Update Logic
//

always @(posedge clk)
	uc_dpd_set <= #1 uc_stat_set_d;

// Abort signal
always @(posedge clk)
	abort <= #1 match & fsel & (state != IDLE);

///////////////////////////////////////////////////////////////////
//
// TIME OUT TIMERS
//

// After sending Data in response to an IN token from host, the
// host must reply with an ack. The host has 622nS in Full Speed
// mode and 400nS in High Speed mode to reply.
// "rx_ack_to" indicates when this time has expired.
// rx_ack_to_clr, clears the timer

always @(posedge clk)
	rx_ack_to_clr <= #1 tx_valid | rx_ack_to_clr_d;

always @(posedge clk)
	if(rx_ack_to_clr)	rx_ack_to_cnt <= #1 8'h0;
	else			rx_ack_to_cnt <= #1 rx_ack_to_cnt + 8'h1;

always @(posedge clk)
	rx_ack_to <= #1 (rx_ack_to_cnt == rx_ack_to_val);

assign rx_ack_to_val = `USBF_RX_ACK_TO_VAL_FS;

// After sending a OUT token the host must send a data packet.
// The host has 622nS in Full Speed mode and 400nS in High Speed
// mode to send the data packet.
// "tx_data_to" indicates when this time has expired.
// "tx_data_to_clr" clears the timer

assign	tx_data_to_clr = rx_active;

always @(posedge clk)
	if(tx_data_to_clr)	tx_data_to_cnt <= #1 8'h0;
	else			tx_data_to_cnt <= #1 tx_data_to_cnt + 8'h1;

always @(posedge clk)
	tx_data_to <= #1 (tx_data_to_cnt == tx_data_to_val);

assign tx_data_to_val = `USBF_TX_DATA_TO_VAL_FS;

///////////////////////////////////////////////////////////////////
//
// Interrupts
//
reg	pid_OUT_r, pid_IN_r, pid_PING_r, pid_SETUP_r;

always @(posedge clk)
	pid_OUT_r <= #1 pid_OUT;

always @(posedge clk)
	pid_IN_r <= #1 pid_IN;

always @(posedge clk)
	pid_PING_r <= #1 pid_PING;

always @(posedge clk)
	pid_SETUP_r <= #1 pid_SETUP;

always @(posedge clk)
	int_upid_set <= #1 match_r & !pid_SOF & (
				( OUT_ep & !(pid_OUT_r | pid_PING_r))		|
				(  IN_ep &  !pid_IN_r)				|
				(CTRL_ep & !(pid_IN_r | pid_OUT_r | pid_PING_r | pid_SETUP_r))
					);


assign int_to_set  = ((state == IN2) & rx_ack_to) | ((state == OUT) & tx_data_to);

assign int_crc16_set = rx_data_done & crc16_err;

always @(posedge clk)
	int_seqerr_set <= #1 int_seqerr_set_d;

reg	send_stall_r;

always @(posedge clk or negedge rst)
	if(!rst)	send_stall_r <= #1 1'b0;
	else
	if(send_stall)	send_stall_r <= #1 1'b1;
	else	
	if(send_token)	send_stall_r <= #1 1'b0;

///////////////////////////////////////////////////////////////////
//
// Main Protocol State Machine
//

always @(posedge clk or negedge rst)
	if(!rst)	state <= #1 IDLE;
	else
	if(match)	state <= #1 IDLE;
	else		state <= #1 next_state;

always @(state or 
	pid_seq_err or idma_done or ep_full or ep_empty or
	token_valid or pid_ACK or rx_data_done or
	tx_data_to or crc16_err or 
	rx_ack_to or pid_PING or txfr_iso or txfr_int or
	CTRL_ep or pid_IN or pid_OUT or IN_ep or OUT_ep or pid_SETUP or pid_SOF
	or match_r or abort or send_stall_r
	)
   begin
	next_state = state;
	token_pid_sel_d = ACK;
	send_token_d = 1'b0;
	rx_dma_en = 1'b0;
	tx_dma_en = 1'b0;
	uc_stat_set_d = 1'b0;
	rx_ack_to_clr_d = 1'b1;
	int_seqerr_set_d = 1'b0;

	case(state)	// synopsys full_case parallel_case
	   IDLE:
		   begin
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state IDLE (%t)", $time);
`endif
`ifdef USBF_DEBUG
		if(rst & match_r & !pid_SOF)
		begin
		if(match_r === 1'bx)	$display("ERROR: IDLE: match_r is unknown. (%t)", $time);
		if(pid_SOF === 1'bx)	$display("ERROR: IDLE: pid_SOF is unknown. (%t)", $time);
		if(CTRL_ep === 1'bx)	$display("ERROR: IDLE: CTRL_ep is unknown. (%t)", $time);
		if(pid_IN === 1'bx)	$display("ERROR: IDLE: pid_IN is unknown. (%t)", $time);
		if(pid_OUT === 1'bx)	$display("ERROR: IDLE: pid_OUT is unknown. (%t)", $time);
		if(pid_SETUP === 1'bx)	$display("ERROR: IDLE: pid_SETUP is unknown. (%t)", $time);
		if(pid_PING === 1'bx)	$display("ERROR: IDLE: pid_PING is unknown. (%t)", $time);
		if(IN_ep === 1'bx)	$display("ERROR: IDLE: IN_ep is unknown. (%t)", $time);
		if(OUT_ep === 1'bx)	$display("ERROR: IDLE: OUT_ep is unknown. (%t)", $time);
		end
`endif
// synopsys translate_on

			if(match_r & !pid_SOF)
			   begin
/*
				if(ep_stall)		// Halt Forced send STALL
				   begin
					token_pid_sel_d = STALL;
					send_token_d = 1'b1;
					next_state = TOKEN;
				   end
				else
*/
				if(IN_ep | (CTRL_ep & pid_IN))
				   begin
					if(txfr_int & ep_empty)
					   begin
						token_pid_sel_d = NACK;
						send_token_d = 1'b1;
						next_state = TOKEN;
					   end
					else
					   begin
						tx_dma_en = 1'b1;
						next_state = IN;
					   end
				   end
				else
				if(OUT_ep | (CTRL_ep & (pid_OUT | pid_SETUP)))
				   begin
					rx_dma_en = 1'b1;
					next_state = OUT;
				   end
			   end
		   end

	   TOKEN:
		   begin
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state TOKEN (%t)", $time);
`endif
// synopsys translate_on
			next_state = IDLE;
		   end

	   IN:
		   begin
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state IN (%t)", $time);
`endif
`ifdef USBF_DEBUG
		if(idma_done === 1'bx)	$display("ERROR: IN: idma_done is unknown. (%t)", $time);
		if(txfr_iso === 1'bx)	$display("ERROR: IN: txfr_iso is unknown. (%t)", $time);
`endif
// synopsys translate_on
			rx_ack_to_clr_d = 1'b0;
			if(idma_done)
			   begin
				if(txfr_iso)	next_state = UPDATE;
				else		next_state = IN2;
			   end

		   end
	   IN2:
		   begin
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state IN2 (%t)", $time);
`endif
`ifdef USBF_DEBUG
		if(rx_ack_to === 1'bx)	$display("ERROR: IN2: rx_ack_to is unknown. (%t)", $time);
		if(token_valid === 1'bx)$display("ERROR: IN2: token_valid is unknown. (%t)", $time);
		if(pid_ACK === 1'bx)	$display("ERROR: IN2: pid_ACK is unknown. (%t)", $time);
`endif
// synopsys translate_on
			rx_ack_to_clr_d = 1'b0;
			// Wait for ACK from HOST or Timeout
			if(rx_ack_to)	next_state = IDLE;
			else
			if(token_valid & pid_ACK)
			   begin
				next_state = UPDATE;
			   end
		   end

	   OUT:
		   begin
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state OUT (%t)", $time);
`endif
`ifdef USBF_DEBUG
		if(tx_data_to === 1'bx)	$display("ERROR: OUT: tx_data_to is unknown. (%t)", $time);
		if(crc16_err === 1'bx)	$display("ERROR: OUT: crc16_err is unknown. (%t)", $time);
		if(abort === 1'bx)	$display("ERROR: OUT: abort is unknown. (%t)", $time);
		if(rx_data_done === 1'bx)$display("ERROR: OUT: rx_data_done is unknown. (%t)", $time);
		if(txfr_iso === 1'bx)	$display("ERROR: OUT: txfr_iso is unknown. (%t)", $time);
		if(pid_seq_err === 1'bx)$display("ERROR: OUT: rx_data_done is unknown. (%t)", $time);
`endif
// synopsys translate_on
			if(tx_data_to | crc16_err | abort )
				next_state = IDLE;
			else
			if(rx_data_done)
			   begin		// Send Ack
				if(txfr_iso)
				   begin
					if(pid_seq_err)		int_seqerr_set_d = 1'b1;
					next_state = UPDATEW;
				   end
				else		next_state = OUT2A;
			   end
		   end

	   OUT2B:
		   begin	// This is a delay State to NACK to small or to
				// large packets. this state could be skipped
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state OUT2B (%t)", $time);
`endif
`ifdef USBF_DEBUG
		if(abort === 1'bx)	$display("ERROR: OUT2A: abort is unknown. (%t)", $time);
`endif
// synopsys translate_on
			if(abort)	next_state = IDLE;
			else		next_state = OUT2B;
		   end
	   OUT2A:
		   begin	// Send ACK/NACK/NYET
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state OUT2A (%t)", $time);
`endif
`ifdef USBF_DEBUG
		if(abort === 1'bx)	$display("ERROR: OUT2A: abort is unknown. (%t)", $time);
		if(pid_seq_err === 1'bx)$display("ERROR: OUT2A: rx_data_done is unknown. (%t)", $time);
`endif
// synopsys translate_on
			if(abort)	next_state = IDLE;
			else

			if(send_stall_r)
			   begin
				token_pid_sel_d = STALL;
				send_token_d = 1'b1;
				next_state = IDLE;
			   end
			else
			if(ep_full)
			   begin
				token_pid_sel_d = NACK;
				send_token_d = 1'b1;
				next_state = IDLE;
			   end
			else
			   begin
				token_pid_sel_d = ACK;
				send_token_d = 1'b1;
				if(pid_seq_err)	next_state = IDLE;
				else		next_state = UPDATE;
			   end
		   end

	   UPDATEW:
		   begin
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state UPDATEW (%t)", $time);
`endif
// synopsys translate_on
			next_state = UPDATE;
		   end

	   UPDATE:
		   begin
// synopsys translate_off
`ifdef USBF_VERBOSE_DEBUG
		$display("PE: Entered state UPDATE (%t)", $time);
`endif
// synopsys translate_on
			uc_stat_set_d = 1'b1;
			next_state = IDLE;
		   end
	endcase
   end

endmodule

