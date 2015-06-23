`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   BMSTU
// Engineer:  Oleg Odintsov
// 
// Create Date:    10:50:36 02/15/2012 
// Design Name: 
// Module Name:    my6502 
// Project Name:    Agat Hardware Project
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Fixed NMI bug
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


// Specify following define to allow external 
//		clocking for phi1 and phi2
//	In such case you may use ag6502_ext_clock module
//		with baseclk frequency ~ 10 x phi_0
`define AG6502_EXTERNAL_CLOCK


`ifndef AG6502_EXTERNAL_CLOCK
module ag6502_clock(input phi_0, output phi_1, output phi_2);
	wire phi_01;
	not#3(phi_1,phi_0);
	or(phi_01,~phi_0, phi_1);
	not#1(phi_2, phi_01);
endmodule


`else

module ag6502_phase_shift(input baseclk, input phi_0, output reg phi_1);
	parameter DELAY = 1; // delay in waves of baseclk
	initial phi_1 = 0;
	integer cnt = 0;
	
	always @(posedge baseclk) begin
		if (phi_0 != phi_1) begin
			if (!cnt) begin phi_1 <= phi_0; cnt <= DELAY; end
			else cnt <= cnt - 1;
		end
	end
endmodule

// baseclk is used to simulate delays on a real hardware
module ag6502_ext_clock(input baseclk, input phi_0, output phi_1, output phi_2);
	parameter DELAY1 = 3, DELAY2 = 1; // delays in waves of baseclk
	
	wire phi_1_neg, phi_01;
	
	ag6502_phase_shift#DELAY1 d1(baseclk, phi_0, phi_1_neg);
	assign phi_1 = ~phi_1_neg;
	
	and(phi_01, phi_0, phi_1_neg);
	ag6502_phase_shift#DELAY2 d2(baseclk, phi_01, phi_2);
endmodule

`endif


`define ALU_ORA	3'd0
`define ALU_AND	3'd1
`define ALU_EOR	3'd2
`define ALU_ADC	3'd3
`define ALU_ASL	3'd4
`define ALU_LSR	3'd5
`define ALU_ROL	3'd6
`define ALU_ROR	3'd7


module ag6502_decimal(ADD, D_IN, NEG, CORR);
	input wire[4:0] ADD;
	input wire D_IN, NEG;
	output wire[4:0] CORR;
	wire C9 = {ADD[4]^NEG, ADD[3:0]} > 5'd9;
	
	assign CORR = D_IN?{C9^NEG, C9?ADD[3:0] + (NEG?4'd10:4'd6): ADD[3:0]}: ADD;
endmodule


module ag6502_alu(A, B, OP, NEG, C_IN, D_IN, R, C_OUT, V_OUT);
	input wire[7:0] A, B;
	input wire[2:0] OP;
	input wire C_IN, D_IN, NEG;
	output wire[7:0] R;
	output wire C_OUT, V_OUT;
	
	wire[4:0] ADD_L;
	ag6502_decimal DL({1'b0, A[3:0]} + {1'b0, B[3:0]} + C_IN, D_IN, NEG, ADD_L);
	wire CF_H = ADD_L[4];

	wire[4:0] ADD_H;
	ag6502_decimal DH({1'b0, A[7:4]} + {1'b0, B[7:4]} + CF_H, D_IN, NEG, ADD_H);

	assign
		{C_OUT,R} = (OP==`ALU_ORA)? A | B:
				(OP==`ALU_AND)? A & B:
				(OP==`ALU_EOR)? A ^ B:
				(OP==`ALU_ADC)? {ADD_H, ADD_L[3:0]}:
				(OP==`ALU_ASL)? {A[7], A[6:0], 1'b0}:
				(OP==`ALU_LSR)? {A[0], 1'b0, A[7:1]}:
				(OP==`ALU_ROL)? {A[7], A[6:0], C_IN}:
				(OP==`ALU_ROR)? {A[0], C_IN, A[7:1]}:
				8'bX;
	assign V_OUT = (A[7] == B[7]) && (A[7] != R[7]);
endmodule

/*
	System AB/DB discipline:
	1. For CPU
		Phi1 up => CPU set ab/db_out buses
		Phi2 down => CPU reads data from db_in
	2. For Memory / other devices
		Phi2 up => perform read/write operation
*/


module ag6502(input phi_0,
`ifdef AG6502_EXTERNAL_CLOCK
		input phi_1, input phi_2,
`else
		output phi_1, output phi_2,
`endif
		output reg[15:0] ab,
		output wire read,
		input[7:0] db_in, output reg[7:0] db_out,
		input rdy,
		input rst, input irq, input nmi,
		input so,
		output sync);
		
`ifndef AG6502_EXTERNAL_CLOCK
	ag6502_clock cgen(phi_0, phi_1, phi_2);
`endif

	reg rdyg = 1;
	
	reg[2:0] T = 7;
	reg[7:0] IR ='h00;
	
	reg[15:0] PC = 0;
	wire[7:0] PCH = PC[15:8], PCL = PC[7:0];
	reg[7:0] EAL, EAH;
	wire[15:0] EA = {EAH, EAL};
	
	reg FLAG_C, FLAG_Z, FLAG_I, FLAG_D, FLAG_B, FLAG_V, FLAG_N;
	
	reg[7:0] AC, X, Y, S = 0;
	wire[7:0] P = {FLAG_N, FLAG_V, 1'b1, FLAG_B, FLAG_D, FLAG_I, FLAG_Z, FLAG_C};
	wire[7:0] SB;
	
	
	wire[7:0] ALU_A, ALU_B;
	wire[7:0] RES;
	wire[2:0] ALU_OP;
	reg[8:0] eALU; // with carry
	wire[7:0] ALU = eALU;
	wire ALU_CF = eALU[8];
	
	wire CF_IN, DF_IN;
	wire CF_OUT, VF_OUT;
	
	reg so_prev = 0;
	reg nmi_prev = 0;
	wire irq_active = ~irq & ~FLAG_I;
	wire nmi_active = ~nmi & nmi_prev;
	wire int_active = irq_active | nmi_active;
	wire rst_active = ~rst;
	wire so_active = so & ~so_prev;
	
	wire[7:0] IR_in = int_active?8'b0:db_in;

	wire[1:0] vec_bits=
			nmi_active?2'b01:
			rst_active?2'b10:
			2'b11;
	
	wire[15:0] vec_addr = {{13{1'b1}}, vec_bits, 1'b0};
	
	wire[10:0] L = {T, IR};
	
	`include "states.v"
	
	assign read = ~A_RW_W;
	assign sync = !T;
	
	assign SB = A_SB_DB? db_in:
					A_SB_AC? AC:
					A_SB_X? X:
					A_SB_Y? Y:
					A_SB_S? S:
					A_SB_P? P:
					A_SB_ALU? ALU:
					A_SB_0? 8'b0:
					A_SB_PCH? PCH:
					A_SB_PCL? PCL:
					8'bX;
	
	assign CF_IN = A_ALU_CF_0? 1'b0:
					A_ALU_CF_1? 1'b1:
					A_ALU_CF_ALUC? ALU_CF:
					FLAG_C;
					
	assign DF_IN = A_ALU_DF_D? FLAG_D: 1'b0;
	
	assign ALU_A = 
					A_ALU_A_AC? AC:
					A_ALU_A_X? X:
					A_ALU_A_Y? Y:
					A_ALU_A_DB? db_in:
					A_ALU_A_EAL? EAL:
					A_ALU_A_ALU? ALU:
					A_ALU_A_S? S:
					A_ALU_A_SIGN? (EAL[7]?8'b11111111:8'b00000001):
					8'bX;
	
	assign ALU_B = A_ALU_B_SB? SB:
					A_ALU_B_NOTSB? ~SB:
					8'bX;

	assign ALU_OP = A_ALU_OP_ADC? `ALU_ADC:
					A_ALU_OP_ORA? `ALU_ORA:
					A_ALU_OP_EOR? `ALU_EOR:
					A_ALU_OP_AND? `ALU_AND:
					A_ALU_OP_ASL? `ALU_ASL:
					A_ALU_OP_LSR? `ALU_LSR:
					A_ALU_OP_ROL? `ALU_ROL:
					A_ALU_OP_ROR? `ALU_ROR:
					8'bX;

	ag6502_alu alu(ALU_A, ALU_B, ALU_OP, A_ALU_B_NOTSB, CF_IN, DF_IN, RES, CF_OUT, VF_OUT);
	
	always @(posedge phi_1) begin
		if (E_AB__PC) ab <= PC;
		else if (E_AB__EA) ab <= EA;
		else if (E_AB__S) ab <= {8'b1, S};

		if (E_DB__SB) db_out <= SB;
		else if (E_DB__PCH) db_out <= PCH;
		else if (E_DB__PCL) db_out <= PCL;
		else if (E_DB__P) db_out <= P;
		else if (E_DB__ALU) db_out <= ALU;
		
		if (read) rdyg <= rdy;
	end


	wire cond;
	
	assign cond = 
			E_T__0IFNF__IR_5_?(FLAG_N != IR[5]):
			E_T__0IFVF__IR_5_?(FLAG_V != IR[5]):
			E_T__0IFCF__IR_5_?(FLAG_C != IR[5]):
			E_T__0IFZF__IR_5_?(FLAG_Z != IR[5]):
			E_T__0IFZF__IR_5_?(FLAG_Z != IR[5]):
			E_T__0IF_C7F? CF_OUT == EAL[7]:
			E_T__0;
	
	always @(negedge phi_2) if (rdyg) begin
		if (E_PC__PC_1) begin
			if (T || (!int_active && !rst_active)) PC <= PC + 1;
		end else if (E_PC__EA) PC <= EA;
		else begin
			if (E_PCH__RES) PC[15:8] <= RES;
			if (E_PCL__ALU) PC[7:0] <= ALU;
			else if (E_PCL__RES) PC[7:0] <= RES;
			else if (E_PCL__EAL) PC[7:0] <= EAL;
			else if (E_PCL__DB) PC[7:0] <= db_in;
		end
		
		if (!T) begin
			IR <= IR_in;
			if (!IR_in) begin // BRK instruction
				{EAH, EAL} <= vec_addr;
			end
			nmi_prev <= nmi;
		end
		
		if (E_N_Z__SB) begin FLAG_Z <= !SB; FLAG_N <= SB[7]; end
		else if (E_N_Z__RES) begin FLAG_Z <= !RES; FLAG_N <= RES[7]; end
		else if (E_N_Z__SB_RES) begin FLAG_Z <= !RES; FLAG_N <= SB[7]; end
		
		if (E_C__RES) FLAG_C <= CF_OUT;
		if (E_V__RES) FLAG_V <= VF_OUT;
		else if (E_V__SB_6_) FLAG_V <= SB[6];
		
		if (E_EAL__DB) EAL <= db_in;
		else if (E_EAL__ALU) EAL <= ALU;

		
		if (E_EA__DB) {EAH, EAL} <= { 8'b0, db_in };
		else if (E_EAH__DB) EAH <= db_in;
		else if (E_EAH__ALU) EAH <= ALU;
		
		if (E_AC__SB) AC <= SB;
		else if (E_AC__RES) AC <= RES;
		
		if (E_S__ALU) S <= ALU;
		
		if (E_X__SB) X <= SB;
		else if (E_X__RES) X <= RES;
		
		if (E_Y__SB) Y <= SB;
		else if (E_Y__RES) Y <= RES;
		
		if (E_S__SB) S <= SB;
		if (E_P__SB) {FLAG_N, FLAG_V, FLAG_B, FLAG_D, FLAG_I, FLAG_Z, FLAG_C} <= {SB[7], SB[6], SB[4], SB[3], SB[2], SB[1], SB[0]};
		else if (E_P__DB) {FLAG_N, FLAG_V, FLAG_B, FLAG_D, FLAG_I, FLAG_Z, FLAG_C} <= {db_in[7], db_in[6], db_in[4], db_in[3], db_in[2], db_in[1], db_in[0]};
		
		if (E_CF__IR_5_) FLAG_C <= IR[5];
		if (E_IF__IR_5_) FLAG_I <= IR[5];
		if (E_DF__IR_5_) FLAG_D <= IR[5];
		if (E_VF__0) FLAG_V <= 0;
		else if (so_active) FLAG_V <= 1;
		so_prev <= so;
		
		eALU <= {CF_OUT, RES};
		
		if (cond) begin
			T <= 0;
			if (!IR) begin
				FLAG_B <= !int_active;
				FLAG_I <= 1;
			end
		end else T <= T + ((E_T__T_1IF_ALUCZ && !ALU_CF)?2: 1);

		if (rst_active) begin
			T <= 1;
			IR <= 0;
			{EAH, EAL} <= vec_addr;
		end
	end


endmodule

