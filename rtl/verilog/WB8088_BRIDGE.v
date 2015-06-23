// ============================================================================
//  8088 to WISHBONE bus bridge
//
//
//  2009 Robert T Finch
//  robfinch<remove>@opencores.org
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//  Verilog 
//
//  Connects an internal WISHBONE bus to the regular 8088 bus.
//  If there is a hold acknowledge, a number of line have to be tri-stated.
//
//  Slice 16 / LUTs 30 / FF's 5 / 307.977 MHz
// ============================================================================
//
`ifndef CT_INTA
`include "cycle_types.v"
`endif

module wb8088_bridge(
rst_i, clk_i, 
nmi_i, irq_i, busy_i, inta_o,
stb_o, ack_i, we_o, adr_o, dat_i, dat_o,
ie, cyc_type, S43,
RESET, CLK, NMI, INTR, INTA_n, ALE, DEN_n, DT_R, IO_M, RD_n, WR_n, READY, A, AD, SSO,
TEST_n, HOLD, HLDA
);
parameter T0 = 3'd0;
parameter T1 = 3'd1;
parameter T2 = 3'd2;
parameter T3 = 3'd3;
parameter T4 = 3'd4;

output rst_i;
output clk_i;
output nmi_i;
output irq_i;
output busy_i;
input inta_o;
input stb_o;
output ack_i;
input we_o;
input [19:0] adr_o;
input [7:0] dat_o;
output [7:0] dat_i;

input ie;
input [2:0] cyc_type;
input [1:0] S43;

input RESET;
input CLK;
input NMI;
input INTR;
output INTA_n;
output ALE;
output DEN_n;
output DT_R;
output IO_M;
output RD_n;
output WR_n;
input READY;
output [19:8] A;
tri [19:8] A;
inout [7:0] AD;
tri [7:0] AD;
output SSO;
input TEST_n;
input HOLD;
output HLDA;

reg HLDA;
reg [2:0] Tcyc;				// "T" cycle
wire IsT1 = Tcyc==T1;
wire IsT2 = Tcyc==T2;
wire IsT3 = Tcyc==T3;
wire IsT4 = Tcyc==T4;
wire IsT23 = (Tcyc==T2) || (Tcyc==T3);

assign rst_i = RESET;
assign clk_i = CLK;
assign irq_i = INTR;
assign nmi_i = NMI;
assign busy_i = TEST_n;
// Will not get to T4 unless READY is active
assign ack_i = IsT3 & READY;
assign ALE = IsT1 && !CLK;	// high pulse during clock low
assign RD_n = HLDA ? 1'bz : !(stb_o && !we_o && IsT23);
assign WR_n = HLDA ? 1'bz : !(stb_o &&  we_o && IsT23);
assign INTA_n = !(inta_o & IsT23);
assign dat_i = AD[7:0];

assign AD[7:0] = HLDA ? 8'bz : IsT1 ? (inta_o ? 8'bz : adr_o[7:0]) :	// address cycle
							   (we_o ? dat_o : 8'bz);		// data cycle
assign A[15:8] = (HLDA | inta_o) ? 8'bz : adr_o[15:8];
assign A[19:16] = HLDA ? 4'bz : IsT1 ? adr_o[19:16] : {1'b0,ie,S43};
												

assign DEN_n = HLDA ? 1'bz : !(we_o ? IsT23 || (IsT4 && !CLK) :
			          (CLK && IsT2) || IsT3 || (IsT4 && !CLK));
assign DT_R = HLDA ? 1'bz : we_o;
assign IO_M = cyc_type==`CT_RDIO || cyc_type==`CT_WRIO || cyc_type==`CT_HALT || cyc_type==`CT_INTA;
assign SSO = cyc_type==`CT_RDIO || cyc_type==`CT_HALT || cyc_type==`CT_RDMEM || cyc_type==`CT_PASSIVE;

// T State generator
// Tcyc:
// - bus cycle state machine
// The machine sits in state T0 until a bus request is present, then transitions to state T1.
// The machine sits in state T1 if there is a HOLD present
// State T2 always moves to state T3
// The machine sits in state T3 until the bus transfer is acknowledged
// State T4 waits for the WISHBONE bus to acknowledge bus cycle completion.

always @(negedge CLK)
	if (RESET)
		Tcyc <= T4;
	else begin
		case(Tcyc)
		T0: if (stb_o) Tcyc <= T1;	// If there is a request for a bus cycle
		T1: Tcyc <= HOLD ? T1 : T2;	// HOLD in the T1 state
		T2: Tcyc <= T3;				// always move to next
		T3:	if (READY) Tcyc <= T4;	// wait for READY signal
		T4:	if (!stb_o) Tcyc <= T0;	// wait for end of bus cycle
		default: Tcyc <= T4;
		endcase
	end

// HOLD generator
// - drive HLDA low as soon as HOLD goes low
// - drive HLDA active if there is a HOLD during T1 or T4
//
always @(negedge CLK)
	if (RESET)
		HLDA <= 1'b0;
	else begin
		if (HOLD) begin
			if (Tcyc==T1) HLDA <= 1'b1;
			if (Tcyc==T4) HLDA <= 1'b1;
		end
		else
			HLDA <= 1'b0;
	end

endmodule

