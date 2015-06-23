
`timescale 1 ns / 100 ps

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
module openfire_opb (
    OPB_DBus, OPB_errAck, OPB_MGrant, OPB_retry, OPB_timeout, OPB_xferAck,
    M_BE, M_ABus, M_busLock, M_DBus, M_request, M_RNW, M_select, M_seqAddr, 
    PROC_enable, PROC_we, PROC_ABus, PROC_DBus, PROC_stall, OPB_data2PROC,
    PROC_ack, OPB_busy, OPB_WAIT_ON_OTHERS, clock, reset
);

parameter C_ENABLE_CSCOPE = 0;

////////// Incoming from OPB //////////
input  wire [31:0] OPB_DBus;       // incoming data from OPB
input  wire        OPB_errAck;		// incoming error acknowledge from OPB (ignored)
input  wire        OPB_MGrant;     // incoming master grant from OPB
input  wire        OPB_retry;		// incoming retry request from OPB (ignored)
input  wire        OPB_timeout;    // incoming timeout signal from opb (ignored)
input  wire        OPB_xferAck;    // incoming txfer acknowledgement from OPB

////////// Outgoing to OPB //////////
output wire [0:3]  M_BE;            // output byte enable to OPB
output wire [0:31] M_ABus;          // output address bus to OPB - registered
output wire        M_busLock;       // output bus lock to OPB    (ignored)
output wire [0:31] M_DBus;          // output data bus to OPB
output wire        M_request;       // output request for access to OPB
output wire        M_RNW;           // read not write
output wire        M_select;        // output access control to OPB
output wire        M_seqAddr;       // are output addresses sequential? (ignored)

////////// Incoming from OpenFire //////////
input  wire        PROC_enable;      // incoming request from processor
input  wire        PROC_we;			 // write enable
input  wire [31:0] PROC_ABus;        // incoming address bus from processor
input  wire [31:0] PROC_DBus;    // incoming data from processor
input  wire        OPB_WAIT_ON_OTHERS;

////////// Outgoing to OpenFire //////////
output wire        OPB_busy;         // OPB bus is busy (Request, TX, Timeout, Retry)
output wire        PROC_stall;       // stall out to processor during OPB r/w
output wire        PROC_ack;         // ackknowledge transaction back to OpenFire
output reg  [31:0] OPB_data2PROC;    // data out to processor

////////// Internals //////////
input  wire        clock, reset;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

localparam STATE_WAIT_EN  = 16'b0000_0000_0000_0001;
localparam STATE_REQ_ACS  = 16'b0000_0000_0000_0010;
localparam STATE_TXRX     = 16'b0000_0000_0000_0100;
localparam STATE_DONE     = 16'b0000_0000_0000_1000;
//localparam STATE_TIMEOUT  = 16'b0000_0000_0001_0000;
localparam STATE_RETRY    = 16'b0000_0000_0010_0000;

reg [15:0] currstate, nextstate;
reg [31:0] PROC_ABus_latch, PROC_DBus_latch;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
wire stall_states = ((currstate == STATE_REQ_ACS) || 
	                 (currstate == STATE_TXRX)    || 
					 (currstate == STATE_RETRY));
wire nostall_states = (currstate == STATE_DONE);
//wire nostall_states = ((currstate == STATE_DONE) ||
//	                 (currstate == STATE_TIMEOUT));
assign PROC_stall = (stall_states || PROC_enable) && !(nostall_states);

assign PROC_ack = (currstate == STATE_DONE);
assign M_BE = (currstate == STATE_TXRX) ? 4'b1111 : 4'b0000;
assign M_busLock = 1'b0;
assign M_request = currstate == STATE_REQ_ACS;
assign M_RNW = (currstate == STATE_TXRX) ? !PROC_we : 1'b0;
assign M_select = currstate == STATE_TXRX;
assign M_seqAddr = 1'b0;
assign OPB_busy = (currstate == STATE_REQ_ACS) || (currstate == STATE_TXRX) || (currstate == STATE_RETRY);

assign M_ABus = M_select           ? PROC_ABus_latch : 32'b0;
assign M_DBus = M_select & PROC_we ? PROC_DBus_latch : 32'b0;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

always @ (posedge clock or posedge reset) begin
	if(reset) begin
		currstate <= STATE_WAIT_EN;
		OPB_data2PROC <= 32'h0;
	end else begin
		currstate <= nextstate;

		OPB_data2PROC <= (OPB_xferAck & M_RNW) ? OPB_DBus : OPB_data2PROC; // might want to set this to zero
	end
end

always @ (posedge clock or posedge reset) begin
	if(reset) begin
		PROC_ABus_latch <= 32'h0;
		PROC_DBus_latch <= 32'h0;
	end else begin
		if(currstate == STATE_WAIT_EN) begin
			PROC_ABus_latch <= PROC_ABus;
			PROC_DBus_latch <= PROC_DBus;
		end
	end
end

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

wire bus_timeout, bus_retry;
assign bus_timeout = OPB_timeout & !(OPB_xferAck | OPB_retry);
assign bus_retry = OPB_retry;

always @ (currstate or nextstate or PROC_enable or PROC_we or PROC_ABus 
	      or PROC_DBus or OPB_DBus or OPB_errAck or OPB_MGrant or OPB_retry 
	      or OPB_timeout or OPB_xferAck or bus_timeout or bus_retry) begin

	if(currstate & STATE_WAIT_EN) nextstate = PROC_enable ? STATE_REQ_ACS : STATE_WAIT_EN; 
	else if(currstate & STATE_REQ_ACS) nextstate = OPB_MGrant ? STATE_TXRX : STATE_REQ_ACS; 
	else if(currstate & STATE_TXRX) begin 
		if(OPB_xferAck) nextstate = STATE_DONE;
		else if(bus_timeout) nextstate = STATE_DONE;
//		else if(bus_timeout) nextstate = STATE_TIMEOUT;
		else if(bus_retry) nextstate = STATE_RETRY;
		else nextstate = STATE_TXRX;
	end
	else if(currstate & STATE_DONE) nextstate = OPB_WAIT_ON_OTHERS ? STATE_DONE : STATE_WAIT_EN;
//	else if(currstate & STATE_TIMEOUT) nextstate = OPB_WAIT_ON_OTHERS ? STATE_TIMEOUT : STATE_WAIT_EN;
	else if(currstate & STATE_RETRY) nextstate = STATE_REQ_ACS;
	else nextstate = STATE_WAIT_EN;
end

///////////////////////////////////////////////////////////////////////////////
//
// Chipscope instantiation.
//

generate if(C_ENABLE_CSCOPE == 1) begin : OPB_CHIPSCOPE

	wire [35:0] control;
	wire [31:0] trig0;
	wire [31:0] trig1;
	wire [31:0] trig2;
	wire [31:0] trig3;
	wire [31:0] trig4;
	wire [31:0] trig5;
	wire [31:0] trig6;
	wire [31:0] trig7;
	
	assign trig0 = OPB_DBus;
	assign trig1 = M_ABus;
	assign trig2 = M_DBus;
	assign trig3 = PROC_ABus;
	assign trig4 = PROC_DBus;
	assign trig5 = OPB_data2PROC;
	assign trig6 = {currstate,nextstate};
	assign trig7 = {12'b0,
		OPB_errAck,
		OPB_MGrant,
		OPB_retry,
		OPB_timeout,
		OPB_xferAck,
		M_BE,			// 4 bits
		M_busLock,
		M_request,
		M_RNW,
		M_select,
		M_seqAddr,
		PROC_enable,
		PROC_we,
		OPB_WAIT_ON_OTHERS,
		OPB_busy,
		PROC_stall,
		PROC_ack
		};
	

	ila i_ila
	(
		.control(control),
		.clk(clock),
		.trig0(trig0),
		.trig1(trig1),
		.trig2(trig2),
		.trig3(trig3),
		.trig4(trig4),
		.trig5(trig5),
		.trig6(trig6),
		.trig7(trig7)
	);
	
	icon i_icon
	(
		.control0(control)
	);
	
end endgenerate

endmodule

///////////////////////////////////////////////////////////////////////////////
//
// Black box definitions for chipscope modules, if needed.
//
/*
module ila
	(
	control,
	clk,
	trig0,
	trig1,
	trig2,
	trig3,
	trig4,
	trig5,
	trig6,
	trig7
	);
	input [35:0] control;
	input clk;
	input [31:0] trig0;
	input [31:0] trig1;
	input [31:0] trig2;
	input [31:0] trig3;
	input [31:0] trig4;
	input [31:0] trig5;
	input [31:0] trig6;
	input [31:0] trig7;
endmodule


module icon 
(
	control0
);
output [35:0] control0;
endmodule*/
