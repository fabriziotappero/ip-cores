/*

MODULE: openfire_top_syn

DESCRIPTION: This is the top level module for synthesis.  A single, joint 
memory is used for both instructions and data.  This memory is a Xilinx 
coregen generated BRAM component.  However, any synchronous dual-port memory
would work.

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

COPYRIGHT:
Copyright (c) 2005 Stephen Douglas Craven

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.

*/


module openfire_top_syn (
// DEFINE IOPB LINK PORTS
	IOPB_DBus, IOPB_errAck, IOPB_MGrant, IOPB_retry, IOPB_timeout, IOPB_xferAck,
    IM_BE, IM_ABus, IM_busLock, IM_DBus, IM_request, IM_RNW, IM_select, IM_seqAddr, 
// END IOPB LINK PORTS
// DEFINE DOPB LINK PORTS
	DOPB_DBus, DOPB_errAck, DOPB_MGrant, DOPB_retry, DOPB_timeout, DOPB_xferAck,
    DM_BE, DM_ABus, DM_busLock, DM_DBus, DM_request, DM_RNW, DM_select, DM_seqAddr, 
// END DOPB LINK PORTS
// DEFINE FSL0 LINK PORTS
	//	FSL0_Clk, FSL0_Rst,
	FSL0_S_DATA,     FSL0_S_CONTROL,     FSL0_S_READ,      FSL0_S_EXISTS,   FSL0_S_CLK,
	FSL0_M_DATA,     FSL0_M_CONTROL,     FSL0_M_WRITE,     FSL0_M_FULL,     FSL0_M_CLK,
	FSL1_S_DATA,     FSL1_S_CONTROL,     FSL1_S_READ,      FSL1_S_EXISTS,   FSL1_S_CLK,
	FSL1_M_DATA,     FSL1_M_CONTROL,     FSL1_M_WRITE,     FSL1_M_FULL,     FSL1_M_CLK,
	FSL2_S_DATA,     FSL2_S_CONTROL,     FSL2_S_READ,      FSL2_S_EXISTS,   FSL2_S_CLK,
	FSL2_M_DATA,     FSL2_M_CONTROL,     FSL2_M_WRITE,     FSL2_M_FULL,     FSL2_M_CLK,
	FSL3_S_DATA,     FSL3_S_CONTROL,     FSL3_S_READ,      FSL3_S_EXISTS,   FSL3_S_CLK,
	FSL3_M_DATA,     FSL3_M_CONTROL,     FSL3_M_WRITE,     FSL3_M_FULL,     FSL3_M_CLK,
	FSL4_S_DATA,     FSL4_S_CONTROL,     FSL4_S_READ,      FSL4_S_EXISTS,   FSL4_S_CLK,
	FSL4_M_DATA,     FSL4_M_CONTROL,     FSL4_M_WRITE,     FSL4_M_FULL,     FSL4_M_CLK,
	FSL5_S_DATA,     FSL5_S_CONTROL,     FSL5_S_READ,      FSL5_S_EXISTS,   FSL5_S_CLK,
	FSL5_M_DATA,     FSL5_M_CONTROL,     FSL5_M_WRITE,     FSL5_M_FULL,     FSL5_M_CLK,
	FSL6_S_DATA,     FSL6_S_CONTROL,     FSL6_S_READ,      FSL6_S_EXISTS,   FSL6_S_CLK,
	FSL6_M_DATA,     FSL6_M_CONTROL,     FSL6_M_WRITE,     FSL6_M_FULL,     FSL6_M_CLK,
	FSL7_S_DATA,     FSL7_S_CONTROL,     FSL7_S_READ,      FSL7_S_EXISTS,   FSL7_S_CLK,
	FSL7_M_DATA,     FSL7_M_CONTROL,     FSL7_M_WRITE,     FSL7_M_FULL,     FSL7_M_CLK,
	FSL_M_DATA_DBG, FSL_M_CONTROL_DBG, FSL_M_WRITE_DBG, FSL_M_FULL_DBG, FSL_M_CLK_DBG,
// END FSL0 LINK PORTS
	clock, reset
);

parameter C_EXT_RESET_HIGH = 0;
parameter C_DOPB_ADDR_LO = 32'h30000000;
parameter C_DOPB_ADDR_HI = 32'h50000000;
parameter C_IOPB_ENABLE = 1;
parameter C_DOPB_ENABLE = 1;
parameter C_IOPB_CSCOPE = 0;
parameter C_DOPB_CSCOPE = 0;
parameter C_FSL_LINKS = 8;
parameter C_FSL_DEBUG = 0;
parameter C_OF_CSCOPE = 0;

input		clock;
input		reset;

//input		FSL0_Clk;
//input		FSL0_Rst;

`ifdef FSL_LINK
input  wire FSL0_S_CONTROL;
input  wire FSL0_S_EXISTS;
input  wire FSL0_M_FULL;
output wire FSL0_M_CONTROL;
output wire FSL0_M_WRITE;
output wire FSL0_S_READ;

input  wire FSL1_S_CONTROL;
input  wire FSL1_S_EXISTS;
input  wire FSL1_M_FULL;
output wire FSL1_M_CONTROL;
output wire FSL1_M_WRITE;
output wire FSL1_S_READ;

input  wire FSL2_S_CONTROL;
input  wire FSL2_S_EXISTS;
input  wire FSL2_M_FULL;
output wire FSL2_M_CONTROL;
output wire FSL2_M_WRITE;
output wire FSL2_S_READ;

input  wire FSL3_S_CONTROL;
input  wire FSL3_S_EXISTS;
input  wire FSL3_M_FULL;
output wire FSL3_M_CONTROL;
output wire FSL3_M_WRITE;
output wire FSL3_S_READ;

input  wire FSL4_S_CONTROL;
input  wire FSL4_S_EXISTS;
input  wire FSL4_M_FULL;
output wire FSL4_M_CONTROL;
output wire FSL4_M_WRITE;
output wire FSL4_S_READ;

input  wire FSL5_S_CONTROL;
input  wire FSL5_S_EXISTS;
input  wire FSL5_M_FULL;
output wire FSL5_M_CONTROL;
output wire FSL5_M_WRITE;
output wire FSL5_S_READ;

input  wire FSL6_S_CONTROL;
input  wire FSL6_S_EXISTS;
input  wire FSL6_M_FULL;
output wire FSL6_M_CONTROL;
output wire FSL6_M_WRITE;
output wire FSL6_S_READ;

input  wire FSL7_S_CONTROL;
input  wire FSL7_S_EXISTS;
input  wire FSL7_M_FULL;
output wire FSL7_M_CONTROL;
output wire FSL7_M_WRITE;
output wire FSL7_S_READ;

input  wire [31:0] FSL0_S_DATA;
input  wire [31:0] FSL1_S_DATA;
input  wire [31:0] FSL2_S_DATA;
input  wire [31:0] FSL3_S_DATA;
input  wire [31:0] FSL4_S_DATA;
input  wire [31:0] FSL5_S_DATA;
input  wire [31:0] FSL6_S_DATA;
input  wire [31:0] FSL7_S_DATA;
output wire [31:0] FSL0_M_DATA;
output wire [31:0] FSL1_M_DATA;
output wire [31:0] FSL2_M_DATA;
output wire [31:0] FSL3_M_DATA;
output wire [31:0] FSL4_M_DATA;
output wire [31:0] FSL5_M_DATA;
output wire [31:0] FSL6_M_DATA;
output wire [31:0] FSL7_M_DATA;

output wire	FSL0_M_CLK;
output wire	FSL0_S_CLK;
output wire	FSL1_M_CLK;
output wire	FSL1_S_CLK;
output wire	FSL2_M_CLK;
output wire	FSL2_S_CLK;
output wire	FSL3_M_CLK;
output wire	FSL3_S_CLK;
output wire	FSL4_M_CLK;
output wire	FSL4_S_CLK;
output wire	FSL5_M_CLK;
output wire	FSL5_S_CLK;
output wire	FSL6_M_CLK;
output wire	FSL6_S_CLK;
output wire	FSL7_M_CLK;
output wire	FSL7_S_CLK;

// Debug Outputs
input  wire			FSL_M_FULL_DBG;
output wire [31:0]	FSL_M_DATA_DBG;
output wire			FSL_M_CONTROL_DBG;
output wire			FSL_M_WRITE_DBG;
output wire			FSL_M_CLK_DBG;

`endif

// DEFINE IOPB LINK PORTS/WIRES
input  wire [0:31] IOPB_DBus;       // incoming data from OPB
input  wire        IOPB_errAck;		// incoming error acknowledge from OPB (ignored)
input  wire        IOPB_MGrant;     // incoming master grant from OPB
input  wire        IOPB_retry;		// incoming retry request from OPB (ignored)
input  wire        IOPB_timeout;    // incoming timeout signal from opb (ignored)
input  wire        IOPB_xferAck;    // incoming txfer acknowledgement from OPB

output wire [0:31] IM_ABus;          // output address bus to OPB
output wire [0:3]  IM_BE;            // output byte enable to OPB
output wire        IM_busLock;       // output bus lock to OPB    (ignored)
output wire [0:31] IM_DBus;          // output data bus to OPB
output wire        IM_request;       // output request for access to OPB
output wire        IM_RNW;           // read not write
output wire        IM_select;        // output access control to OPB
output wire        IM_seqAddr;       // are output addresses sequential? (ignored)
// END IOPB LINK PORTS/WIRES

// DEFINE DOPB LINK PORTS/WIRES
input  wire [0:31] DOPB_DBus;       // incoming data from OPB
input  wire        DOPB_errAck;		// incoming error acknowledge from OPB (ignored)
input  wire        DOPB_MGrant;     // incoming master grant from OPB
input  wire        DOPB_retry;		// incoming retry request from OPB (ignored)
input  wire        DOPB_timeout;    // incoming timeout signal from opb (ignored)
input  wire        DOPB_xferAck;    // incoming txfer acknowledgement from OPB

output wire [0:31] DM_ABus;          // output address bus to OPB
output wire [0:3]  DM_BE;            // output byte enable to OPB
output wire        DM_busLock;       // output bus lock to OPB    (ignored)
output wire [0:31] DM_DBus;          // output data bus to OPB
output wire        DM_request;       // output request for access to OPB
output wire        DM_RNW;           // read not write
output wire        DM_select;        // output access control to OPB
output wire        DM_seqAddr;       // are output addresses sequential? (ignored)
// END DOPB LINK PORTS/WIRES

wire	[31:0]	imem_data_rd;
wire	[31:0]	imem_data2cpu;
wire	[31:0]	imem_addr;

wire	[31:0]	dmem_data_wr;
wire	[31:0]	dmem_data_rd;
wire	[31:0]	dmem_data2mem;
wire	[31:0]	dmem_data2cpu;
wire	[31:0]	dmem_addr;
wire		dmem_we;
wire		dmem_en;
wire		PROC_stall;

wire		reset_correct_polarity;

// IOPB WIRES/REGS
wire		IOPB_PROC_stall;
wire        IOPB_Address;
wire        IOPB_Access;
wire [31:0] IOPB_data2PROC;
wire        IOPB_ack;
wire        IOPB_busy;
// END IOPB WIRES

// DOPB WIRES/REGS
wire		DOPB_PROC_stall;
wire        DOPB_Address;
reg         DOPB_Address_dly;
wire        DOPB_Access;
wire [31:0] DOPB_data2PROC;
wire        DOPB_ack;
wire        DOPB_busy;
// END DOPB WIRES

always @ (posedge clock) begin
	if(reset_correct_polarity) DOPB_Address_dly <= 1'b0;
	else DOPB_Address_dly <= (!PROC_stall) ? DOPB_Address : DOPB_Address_dly;
end

assign PROC_stall = DOPB_PROC_stall | IOPB_PROC_stall;

// IOPB ASSIGNS
assign IOPB_Address = (imem_addr[31] | imem_addr[30] | imem_addr[29] | imem_addr[28]);
assign IOPB_Access = IOPB_Address;
assign imem_data_rd = IOPB_Access ? IOPB_data2PROC : imem_data2cpu;
// END IOPB ASSIGNS

// DOPB ASSIGNS
assign DOPB_Address = (dmem_addr[31] | dmem_addr[30] | dmem_addr[29] | dmem_addr[28]);
assign DOPB_Access = DOPB_Address & dmem_en;
assign dmem_data_rd = (DOPB_Address || DOPB_Address_dly) ? DOPB_data2PROC : dmem_data2cpu;
assign dmem_data2mem = dmem_data_wr;
// END DOPB ASSIGNS

// Determine polarity (active high or low) or core reset
generate
	if(C_EXT_RESET_HIGH) begin : RESET_ACTIVE_HI
		assign reset_correct_polarity = reset;
	end else begin : RESET_ACTIVE_LOW
		assign reset_correct_polarity = ~reset;
	end
endgenerate

`ifdef FSL_LINK

assign FSL0_S_CLK = clock;
assign FSL0_M_CLK = clock;
assign FSL1_S_CLK = clock;
assign FSL1_M_CLK = clock;
assign FSL2_S_CLK = clock;
assign FSL2_M_CLK = clock;
assign FSL3_S_CLK = clock;
assign FSL3_M_CLK = clock;
assign FSL4_S_CLK = clock;
assign FSL4_M_CLK = clock;
assign FSL5_S_CLK = clock;
assign FSL5_M_CLK = clock;
assign FSL6_S_CLK = clock;
assign FSL6_M_CLK = clock;
assign FSL7_S_CLK = clock;
assign FSL7_M_CLK = clock;
assign FSL_M_CLK_DBG = clock;

assign FSL_M_CONTROL_DBG = 1'b0;

// debugging only... force PC outside
assign FSL_M_WRITE_DBG = ~FSL_M_FULL_DBG;

openfire_cpu OPENFIRE0 (
	.clock(clock),
    .reset(reset_correct_polarity),
    .stall(PROC_stall),
	.dmem_data_in(dmem_data_rd),
	.dmem_data_out(dmem_data_wr),
	.dmem_addr(dmem_addr),
    .dmem_we(dmem_we),
    .dmem_en(dmem_en),
    .imem_data_in(imem_data_rd),
    .imem_addr(imem_addr), 
    .pc(FSL_M_DATA_DBG), // PC added for debugging
	.fsl0_s_control	(FSL0_S_CONTROL),
	.fsl0_s_exists	(FSL0_S_EXISTS),
	.fsl0_m_full	(FSL0_M_FULL),
	.fsl0_m_control	(FSL0_M_CONTROL),
	.fsl0_m_write	(FSL0_M_WRITE),
	.fsl0_s_read	(FSL0_S_READ),
	.fsl1_s_control	(FSL1_S_CONTROL),
	.fsl1_s_exists	(FSL1_S_EXISTS),
	.fsl1_m_full	(FSL1_M_FULL),
	.fsl1_m_control	(FSL1_M_CONTROL),
	.fsl1_m_write	(FSL1_M_WRITE),
	.fsl1_s_read	(FSL1_S_READ),
	.fsl2_s_control	(FSL2_S_CONTROL),
	.fsl2_s_exists	(FSL2_S_EXISTS),
	.fsl2_m_full	(FSL2_M_FULL),
	.fsl2_m_control	(FSL2_M_CONTROL),
	.fsl2_m_write	(FSL2_M_WRITE),
	.fsl2_s_read	(FSL2_S_READ),
	.fsl3_s_control	(FSL3_S_CONTROL),
	.fsl3_s_exists	(FSL3_S_EXISTS),
	.fsl3_m_full	(FSL3_M_FULL),
	.fsl3_m_control	(FSL3_M_CONTROL),
	.fsl3_m_write	(FSL3_M_WRITE),
	.fsl3_s_read	(FSL3_S_READ),
	.fsl4_s_control	(FSL4_S_CONTROL),
	.fsl4_s_exists	(FSL4_S_EXISTS),
	.fsl4_m_full	(FSL4_M_FULL),
	.fsl4_m_control	(FSL4_M_CONTROL),
	.fsl4_m_write	(FSL4_M_WRITE),
	.fsl4_s_read	(FSL4_S_READ),
	.fsl5_s_control	(FSL5_S_CONTROL),
	.fsl5_s_exists	(FSL5_S_EXISTS),
	.fsl5_m_full	(FSL5_M_FULL),
	.fsl5_m_control	(FSL5_M_CONTROL),
	.fsl5_m_write	(FSL5_M_WRITE),
	.fsl5_s_read	(FSL5_S_READ),
	.fsl6_s_control	(FSL6_S_CONTROL),
	.fsl6_s_exists	(FSL6_S_EXISTS),
	.fsl6_m_full	(FSL6_M_FULL),
	.fsl6_m_control	(FSL6_M_CONTROL),
	.fsl6_m_write	(FSL6_M_WRITE),
	.fsl6_s_read	(FSL6_S_READ),
	.fsl7_s_control	(FSL7_S_CONTROL),
	.fsl7_s_exists	(FSL7_S_EXISTS),
	.fsl7_m_full	(FSL7_M_FULL),
	.fsl7_m_control	(FSL7_M_CONTROL),
	.fsl7_m_write	(FSL7_M_WRITE),
	.fsl7_s_read	(FSL7_S_READ),
	.fsl0_s_data	(FSL0_S_DATA),
	.fsl1_s_data	(FSL1_S_DATA),
	.fsl2_s_data	(FSL2_S_DATA),
	.fsl3_s_data	(FSL3_S_DATA),
	.fsl4_s_data	(FSL4_S_DATA),
	.fsl5_s_data	(FSL5_S_DATA),
	.fsl6_s_data	(FSL6_S_DATA),
	.fsl7_s_data	(FSL7_S_DATA),
	.fsl0_m_data	(FSL0_M_DATA),
	.fsl1_m_data	(FSL1_M_DATA),
	.fsl2_m_data	(FSL2_M_DATA),
	.fsl3_m_data	(FSL3_M_DATA),
	.fsl4_m_data	(FSL4_M_DATA),
	.fsl5_m_data	(FSL5_M_DATA),
	.fsl6_m_data	(FSL6_M_DATA),
	.fsl7_m_data	(FSL7_M_DATA) );
`else
openfire_cpu OPENFIRE0 (
	.clock(clock),
    .reset(reset_correct_polarity),
    .stall(PROC_stall),
	.dmem_data_in(dmem_data_rd),
    .imem_data_in(imem_data_rd),
	.dmem_addr(dmem_addr),
    .imem_addr(imem_addr), 
	.dmem_data_out(dmem_data_wr),
    .dmem_we(dmem_we),
    .dmem_en(dmem_en));
`endif

openfire_named_sram_16k MEM(
	.dmem_clk(clock), 
	.dmem_addr((dmem_addr >> 2)),
	.dmem_data_i(dmem_data2mem),
	.dmem_data_o(dmem_data2cpu),
	.dmem_en(1'b1),
	.dmem_we(dmem_we & !DOPB_Access),

	.imem_clk(~clock),
	.imem_addr((imem_addr >> 2)),
	.imem_data_o(imem_data2cpu),
	.imem_en(1'b1)
);

// In order to complete instruction Fetch in a single cycle, the read clock
// on the instruction port is inverted.  During the first phase of the Fetch
// stage, the PC is supplied to the memory address bus.  At the falling edge
// of the clock, this address is clocked into the instruction memory.  During
// the second Fetch stage phase the memory fetchs the instruction and places
// it on the data bus.  On the next rising edge, the instruction word is
// clocked in and decoded.

generate if(C_DOPB_ENABLE) begin: DOPB_MODULE
openfire_opb #(
	.C_ENABLE_CSCOPE(C_DOPB_CSCOPE)
) opb0(
    .OPB_DBus      (DOPB_DBus),
    .OPB_errAck    (DOPB_errAck),
    .OPB_MGrant    (DOPB_MGrant),
    .OPB_retry     (DOPB_retry),
    .OPB_timeout   (DOPB_timeout),
    .OPB_xferAck   (DOPB_xferAck),
    .M_BE          (DM_BE),
    .M_ABus        (DM_ABus),
    .M_busLock     (DM_busLock),
    .M_DBus        (DM_DBus),
    .M_request     (DM_request),
    .M_RNW         (DM_RNW),
    .M_select      (DM_select),
    .M_seqAddr     (DM_seqAddr),
    .PROC_enable   (DOPB_Access),
    .PROC_we       (dmem_we),
    .PROC_ABus     (dmem_addr),
    .PROC_DBus     (dmem_data2mem),
    .PROC_stall    (DOPB_PROC_stall),
    .PROC_ack      (DOPB_ack),
	.OPB_WAIT_ON_OTHERS(IOPB_busy),
    .OPB_busy      (DOPB_busy),
    .OPB_data2PROC (DOPB_data2PROC),
    .clock         (clock),
    .reset         (reset_correct_polarity)
);
end endgenerate

generate if(C_IOPB_ENABLE) begin: IOPB_MODULE
openfire_opb #(
	.C_ENABLE_CSCOPE(C_IOPB_CSCOPE)
	) opb1 (
    .OPB_DBus      (IOPB_DBus),
    .OPB_errAck    (IOPB_errAck),
    .OPB_MGrant    (IOPB_MGrant),
    .OPB_retry     (IOPB_retry),
    .OPB_timeout   (IOPB_timeout),
    .OPB_xferAck   (IOPB_xferAck),
    .M_BE          (IM_BE),
    .M_ABus        (IM_ABus),
    .M_busLock     (IM_busLock),
    .M_DBus        (IM_DBus),
    .M_request     (IM_request),
    .M_RNW         (IM_RNW),
    .M_select      (IM_select),
    .M_seqAddr     (IM_seqAddr),
    .PROC_enable   (IOPB_Access),
    .PROC_we       (1'b0),
    .PROC_ABus     (imem_addr),
    .PROC_DBus     (32'h00000000),
    .PROC_stall    (IOPB_PROC_stall),
    .PROC_ack      (IOPB_ack),
	.OPB_WAIT_ON_OTHERS(1'b0),
    .OPB_busy      (IOPB_busy),
    .OPB_data2PROC (IOPB_data2PROC),
    .clock         (clock),
    .reset         (reset_correct_polarity)
);
end endgenerate

///////////////////////////////////////////////////////////////////////////////
//
// Chipscope instantiation.
//

generate if(C_OF_CSCOPE == 1) begin : OPENFIRE_CHIPSCOPE

	wire [35:0] control;
	wire [31:0] trig0;
	wire [31:0] trig1;
	wire [31:0] trig2;
	wire [31:0] trig3;
	wire [31:0] trig4;
	wire [31:0] trig5;
	wire [31:0] trig6;
	wire [31:0] trig7;
	
	assign trig0 = IOPB_DBus;
	assign trig1 = imem_addr;
	assign trig2 = DOPB_DBus;
	assign trig3 = dmem_addr;
	assign trig4 = dmem_data2mem;
	assign trig5 = DOPB_data2PROC;
	assign trig6 = 32'b0;
	assign trig7 = {7'b0,
		reset_correct_polarity,
		dmem_en,
		dmem_we,
		PROC_stall,
		DOPB_MGrant,
		DOPB_xferAck,
		DM_request,
		DM_RNW,
		DM_select,
		DOPB_Access,
		DOPB_Address,
		DOPB_Address_dly,
		DOPB_PROC_stall,
		DOPB_ack,
		DOPB_busy,
		IOPB_MGrant,
		IOPB_xferAck,
		IM_request,
		IM_RNW,
		IM_select,
		IOPB_Access,
		IOPB_Address,
		IOPB_PROC_stall,
		IOPB_ack,
		IOPB_busy
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
endmodule

