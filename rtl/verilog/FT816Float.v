`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2014  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
// FT816Float.v
//  - Triple precision floating point accelerator
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// 1600 LUTs 350 FF's
// 140 MHz
// ============================================================================
//
`define SIMULATION	1'b1

module FT816Float(rst, clk, vda, rw, ad, db, rdy);
parameter pIOAddress = 24'hFEA200;
parameter pRdyStyle = 1'b1;
parameter EMSB = 15;
parameter FMSB = 79;
parameter TRUE = 1'b1;
parameter FALSE = 1'b0;
parameter FADD = 8'd1;
parameter FSUB = 8'd2;
parameter FMUL = 8'd3;
parameter FDIV = 8'd4;
parameter FIX2FLT = 8'd5;
parameter FLT2FIX = 8'd6;
parameter FABS = 8'd7;
parameter ABS = 8'd7;
parameter NABS = 8'd8;
parameter FNABS = 8'd8;
parameter MD1 = 8'd10;
parameter ABSSWP = 8'd11;
parameter ABSSWP1 = 8'd12;
parameter NORM1 = 8'd13;
parameter NORM = 8'd14;
parameter ADD = 8'd15;
parameter FCOMPL = 8'd16;
parameter FNEG = 8'd16;
parameter SWAP = 8'd17;
parameter FIXED_ADD = 8'h81;
parameter FIXED_SUB = 8'h82;
parameter FIXED_MUL = 8'h83;
parameter FIXED_DIV = 8'h84;
parameter FIXED_ABS = 8'h87;
parameter FIXED_NEG = 8'h90;
parameter SWPALG = 8'd18;
parameter ADDEND = 8'd19;
parameter ALGNSW = 8'd20;
parameter RTLOG = 8'd22;
parameter FMUL1 = 8'd24;
parameter FMUL2 = 8'd25;
parameter MUL1 = 8'd26;
parameter FMUL3 = 8'd27;
parameter MUL2 = 8'd28;
parameter MDEND = 8'd29;
parameter FDIV1 = 8'd30;
parameter MD2 = 8'd31;
parameter MD3 = 8'd32;
parameter OVCHK = 8'd34;
parameter OVFL = 8'd35;
parameter DIV1 = 8'd36;
parameter IDLE = 8'd62;
parameter RESET = 8'd63;

input rst;
input clk;
input vda;
input rw;
input [23:0] ad;
inout tri [7:0] db;
output rdy;

reg [7:0] cmd;
reg [7:0] state;
reg [5:0] state_stk [3:0];
//reg [3:0] sp;
reg [1:0] sign;
reg [EMSB:0] acc;
reg [7:0] y;
reg [EMSB+FMSB+1:0] FAC1;
reg [EMSB+FMSB+1:0] FAC2;
reg [FMSB:0] E;
wire [EMSB:0] FAC1_exp = FAC1[EMSB+FMSB+1:FMSB+1];
wire [FMSB:0] FAC1_man = FAC1[FMSB:0];
wire [EMSB:0] FAC2_exp = FAC2[EMSB+FMSB+1:FMSB+1];
wire [FMSB:0] FAC2_man = FAC2[FMSB:0];

reg addOrSub;
wire [FMSB+1:0] sum = addOrSub ? FAC2_man - FAC1_man : FAC2_man + FAC1_man;
wire [FMSB+1:0] dif = FAC2_man - E;
wire [FMSB+1:0] neg = {FMSB+1{1'b0}} - FAC1_man;
wire [EMSB+1:0] expdif = FAC2_exp - FAC1_exp;
// Note the carry flag must be extended manually!
reg cf,vf,nf;
wire [EMSB+1:0] exp_sum = acc + FAC1_exp + {15'd0,cf};	// FMUL
wire [EMSB+1:0] exp_dif = acc - FAC1_exp - {15'd0,~cf};	// FDIV
reg [FMSB:0] rem;
reg isRTAR;
reg busy;
reg shiftBy16;
reg isFixedPoint;
reg [7:0] dbo;

wire eq = FAC1==FAC2;
wire gt = (FAC1[FMSB]^FAC2[FMSB]) ? FAC2[FMSB] : // If the signs are different, whichever one is positive
		   FAC1_exp==FAC2_exp ? (FAC1_man > FAC2_man) :	// if exponents are equal check mantissa
		   FAC1_exp > FAC2_exp;	// else compare exponents
wire lt = !(gt|eq);
wire zf = ~|FAC1;

wire cs = vda && (ad[23:8]==pIOAddress[23:8]);
reg rdy1,rdy2;
always @(posedge clk)
if (rst) begin
	rdy1 <= 1'b1;
	rdy2 <= 1'b1;
end
else begin
	rdy1 <= cs & ~rdy1;
	rdy2 <= cs & rdy1;
end
assign rdy = cs ? (rw ? rdy2 : 1'b1) : pRdyStyle;
assign db = cs & rw ? dbo : {8{1'bz}};

// This is a clock cycle counter used in simulation to determine the number of
// cycles a given operation takes to complete.
reg [11:0] cyccnt;

always @(posedge clk)
if (rst) begin
	next_state(RESET);
`ifdef SIMULATION
	FAC1 <= 96'd0;	// for simulation
	FAC2 <= 96'd0;
`endif
end
else begin
`ifdef SIMULATION
	cyccnt <= cyccnt + 1;
`endif
	cmd <= 8'h00;
	if (cs & ~rw)
		case(ad[7:0])
		8'h00:	FAC1[7:0] <= db;
		8'h01:	FAC1[15:8] <= db;
		8'h02:	FAC1[23:16] <= db;
		8'h03:	FAC1[31:24] <= db;
		8'h04:	FAC1[39:32] <= db;
		8'h05:	FAC1[47:40] <= db;
		8'h06:	FAC1[55:48] <= db;
		8'h07:	FAC1[63:56] <= db;
		8'h08:	FAC1[71:64] <= db;
		8'h09:	FAC1[79:72] <= db;
		8'h0A:	FAC1[87:80] <= db;
		8'h0B:	FAC1[95:88] <= db;
		8'h0E:	cmd <= db;
		8'h10:	FAC2[7:0] <= db;
		8'h11:	FAC2[15:8] <= db;
		8'h12:	FAC2[23:16] <= db;
		8'h13:	FAC2[31:24] <= db;
		8'h14:	FAC2[39:32] <= db;
		8'h15:	FAC2[47:40] <= db;
		8'h16:	FAC2[55:48] <= db;
		8'h17:	FAC2[63:56] <= db;
		8'h18:	FAC2[71:64] <= db;
		8'h19:	FAC2[79:72] <= db;
		8'h1A:	FAC2[87:80] <= db;
		8'h1B:	FAC2[95:88] <= db;
		endcase

	case(ad[7:0])
	8'h00:	dbo <= FAC1[7:0];
	8'h01:	dbo <= FAC1[15:8];
	8'h02:	dbo <= FAC1[23:16];
	8'h03:	dbo <= FAC1[31:24];
	8'h04:	dbo <= FAC1[39:32];
	8'h05:	dbo <= FAC1[47:40];
	8'h06:	dbo <= FAC1[55:48];
	8'h07:	dbo <= FAC1[63:56];
	8'h08:	dbo <= FAC1[71:64];
	8'h09:	dbo <= FAC1[79:72];
	8'h0A:	dbo <= FAC1[87:80];
	8'h0B:	dbo <= FAC1[95:88];
	8'h0E:	dbo <= {busy,2'b00,lt,eq,gt,zf,vf};
	8'h10:	dbo <= FAC2[7:0];
	8'h11:	dbo <= FAC2[15:8];
	8'h12:	dbo <= FAC2[23:16];
	8'h13:	dbo <= FAC2[31:24];
	8'h14:	dbo <= FAC2[39:32];
	8'h15:	dbo <= FAC2[47:40];
	8'h16:	dbo <= FAC2[55:48];
	8'h17:	dbo <= FAC2[63:56];
	8'h18:	dbo <= FAC2[71:64];
	8'h19:	dbo <= FAC2[79:72];
	8'h1A:	dbo <= FAC2[87:80];
	8'h1B:	dbo <= FAC2[95:88];
	endcase

case(state)
RESET:
	begin
//		sp <= 4'h0;
		next_state(IDLE);
	end

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

IDLE:
	begin
`ifdef SIMULATION
		if (cyccnt > 0)
			$display("Cycle Count=%d", cyccnt);
		cyccnt <= 12'h0;
`endif
		busy <= 1'b0;
//		sp <= 4'h0;
		isFixedPoint <= FALSE;
		case(cmd)
		FADD:	begin push_state(IDLE); next_state(FADD); busy <= 1'b1; addOrSub <= 1'b0; end
		FSUB:	begin push_state(IDLE); next_state(FSUB); busy <= 1'b1; addOrSub <= 1'b0; end
		FMUL:	begin push_state(IDLE); next_state(FMUL); busy <= 1'b1; addOrSub <= 1'b0; end 
		FDIV:	begin push_state(IDLE); next_state(FDIV); busy <= 1'b1; end
		FIX2FLT:	begin push_state(IDLE); next_state(FIX2FLT); busy <= 1'b1; end
		FLT2FIX:	begin push_state(IDLE); next_state(FLT2FIX); busy <= 1'b1; end
		FNEG:		begin push_state(IDLE); next_state(FCOMPL); busy <= 1'b1; end
		FABS:		begin push_state(IDLE); next_state(ABS); busy <= 1'b1; end
		FNABS:		begin push_state(IDLE); next_state(NABS); busy <= 1'b1; end
		SWAP:		begin push_state(IDLE); next_state(SWAP); busy <= 1'b1; end
		// Fixed point operations
		FIXED_ADD:	begin push_state(IDLE); next_state(FADD); busy <= 1'b1; isFixedPoint <= TRUE; addOrSub <= 1'b0; end
		FIXED_SUB:	begin push_state(IDLE); next_state(FSUB); busy <= 1'b1; isFixedPoint <= TRUE; addOrSub <= 1'b0; end
		FIXED_MUL:	begin push_state(IDLE); next_state(FMUL); busy <= 1'b1; isFixedPoint <= TRUE; addOrSub <= 1'b0; end
		FIXED_DIV:	begin push_state(IDLE); next_state(FDIV); busy <= 1'b1; isFixedPoint <= TRUE; end
		FIXED_NEG:	begin push_state(IDLE); next_state(FCOMPL); busy <= 1'b1; isFixedPoint <= TRUE; end
		FIXED_ABS:	begin push_state(IDLE); next_state(ABS); busy <= 1'b1; isFixedPoint <= TRUE; end
		endcase
	end

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

MD1:
	begin
		$display("MD1");
		sign <= {sign[1:0],1'b0};
		next_state(ABSSWP);
		push_state(ABSSWP);
	end
ABSSWP:
	begin
		if (~FAC1_man[FMSB]) begin
			next_state(ABSSWP1);
		end
		else begin
			push_state(ABSSWP1);
			sign <= sign + 2'd1;
			next_state(FCOMPL);
		end
	end
ABSSWP1:
	begin
		cf <= 1'b1;
		next_state(SWAP);
	end


//-----------------------------------------------------------------------------
// Take the absolute value of FAC1
//-----------------------------------------------------------------------------

ABS:
	begin
		if (FAC1_man[FMSB])
			next_state(FCOMPL);
		else
			pop_state();
	end

//-----------------------------------------------------------------------------
// Take the negative absolute value of FAC1
//-----------------------------------------------------------------------------

NABS:
	begin
		if (~FAC1_man[FMSB])
			next_state(FCOMPL);
		else
			pop_state();
	end

//-----------------------------------------------------------------------------
// Normalize
// - Decrement exponent and shift left
// - Normalization is normally the last step of an operation.
// - If possible the FAC is shifted by 16 bits at a time. This helps with
//   the many small constants that are usually present.
//-----------------------------------------------------------------------------
NORM:
	begin
	if (isFixedPoint)	// nothing to do for fixed point
		pop_state();
	else begin
	$display("Normalize FAC1H %h", FAC1[FMSB:FMSB-15]);
	if (FAC1[FMSB]!=FAC1[FMSB-1] || ~|FAC1_exp) begin
		$display("Normal: %h",FAC1);
		pop_state();
	end
	// If the mantissa is zero, set the the exponent to zero. Otherwise 
	// normalization could spin for thousands of clock cycles decrementing
	// the exponent to zero.
	else if (~|FAC1_man) begin
		FAC1[EMSB+FMSB+1:FMSB+1] <= 16'h0;
		pop_state();
	end
	else if (FAC1[FMSB:FMSB-15]=={16{FAC1[FMSB]}}) begin
		$display("shift by 16");
		FAC1[EMSB+FMSB+1:FMSB+1] <= FAC1[EMSB+FMSB+1:FMSB+1] - 16'd16;
		FAC1[FMSB:0] <= {FAC1[FMSB-16:0],16'h0};
	end
	else begin
		FAC1[EMSB+FMSB+1:FMSB+1] <= FAC1[EMSB+FMSB+1:FMSB+1] - 16'd1;
		FAC1[FMSB:0] <= {FAC1[FMSB-1:0],1'b0};
	end
	end
	end

//-----------------------------------------------------------------------------
// Add mantissa's and compute carry and overflow.
// This is used by both ADD and MUL.
//-----------------------------------------------------------------------------

ADD:
	begin
		FAC1[FMSB:0] <= sum[FMSB:0];
		cf <= sum[FMSB+1];
		vf <= (sum[FMSB] ^ FAC2[FMSB]) & (1'b1 ^ FAC1[FMSB] ^ FAC2[FMSB]);
		pop_state();
	end

//-----------------------------------------------------------------------------
// Negate
//-----------------------------------------------------------------------------

// Complement FAC1
FCOMPL:
	begin
		$display("FCOMPL");
		FAC1[FMSB:0] <= neg[FMSB:0];
		cf <= ~neg[FMSB+1];
		vf <= neg[FMSB]==FAC1[FMSB];
		if (isFixedPoint)
			pop_state();
		else
			next_state(ADDEND);
	end

//-----------------------------------------------------------------------------
// Swap FAC1 and FAC2
//-----------------------------------------------------------------------------

SWAP:
	begin
		$display("Swapping FAC1 and FAC2");
		FAC1 <= FAC2;
		FAC2 <= FAC1;
		E <= FAC2[FMSB:0];
		acc <= FAC1_exp;
		pop_state();
	end

//-----------------------------------------------------------------------------
// Subtract
// - subtract first complements the FAC then performs an ADD operation.
//-----------------------------------------------------------------------------

FSUB:
	begin
//		if (isFixedPoint)
//			push_state(FADD);
//		else
//			push_state(SWPALG);
		push_state(FADD);
		next_state(FCOMPL);
	end
SWPALG:
	begin
		push_state(FADD);
		next_state(ALGNSW);
	end

//-----------------------------------------------------------------------------
// Addition
//-----------------------------------------------------------------------------

FADD:
	begin
		cf <= ~expdif[EMSB+1];	// Must set carry flag from compare
		// If the exponents are too different then one of the values will
		// become zero, so the result is just the larger value. This check
		// is to prevent shifting thousands of times.
		if (expdif[15] ? expdif < 16'hFFB0 : expdif[15:0] > 16'h0050) begin
			FAC1 <= expdif[15] ? FAC2 : FAC1;
			pop_state();
		end
		else if (|expdif[15:0] & !isFixedPoint)
			next_state(SWPALG);
		else begin
			if (!isFixedPoint) push_state(ADDEND);
			next_state(ADD);
		end
	end
ADDEND:
	begin
		if (!vf)
			next_state(NORM);
		else begin
			isRTAR <= FALSE;
			next_state(RTLOG);
		end
	end
ALGNSW:
	begin
		if (!cf)
			next_state(SWAP);
		else begin
			isRTAR <= TRUE;
			next_state(RTLOG);
		end
	end

//-----------------------------------------------------------------------------
// Right shift, logical or arithmetic.
//-----------------------------------------------------------------------------

RTLOG:
	begin
		FAC1[EMSB+FMSB+1:FMSB+1] <= FAC1[EMSB+FMSB+1:FMSB+1] + 16'd1;
		if (FAC1[EMSB+FMSB+1:FMSB+1]==16'hFFFF)
			next_state(OVFL);
		else begin
			FAC1[FMSB:0] <= {isRTAR ? FAC1_man[FMSB] : cf,FAC1[FMSB:1]};
			E[FMSB:0] <= {FAC1[0],E[FMSB-1:1]};
			cf <= E[0];
			pop_state();
		end
	end

//-----------------------------------------------------------------------------
// Mulyiply
//-----------------------------------------------------------------------------

FMUL:
	begin
		next_state(MD1);
		push_state(FMUL1);
	end
FMUL1:
	begin
		acc <= exp_sum[EMSB:0];
		cf <= exp_sum[EMSB+1];
		push_state(MUL1);
		next_state(MD2);
	end
MUL1:
	begin
		// inline RTLOG1 code
		FAC1[FMSB:0] <= {1'b0,FAC1[FMSB:1]};
		E[FMSB:0] <= {FAC1[0],E[FMSB-1:1]};
		cf <= E[0];
		next_state(FMUL3);
		//push_state(FMUL3);
		//next_state(RTLOG1);
	end
FMUL3:
	begin
		if (cf) begin
			FAC1[FMSB:0] <= sum[FMSB:0];
			cf <= sum[FMSB+1];
			vf <= (sum[FMSB] ^ FAC2[FMSB]) & (1'b1 ^ FAC1[FMSB] ^ FAC2[FMSB]);
		end
		y <= y - 8'd1;
		if (y==8'd0)
			next_state(MDEND);
		else
			next_state(MUL1);
	end
MDEND:
	begin
		sign <= {1'b0,sign[1]};
		if (~sign[0])
			next_state(NORM);
		else
			next_state(FCOMPL);
	end

//-----------------------------------------------------------------------------
// Divide
//-----------------------------------------------------------------------------
FDIV:
	begin
		push_state(FDIV1);
		next_state(MD1);
	end
FDIV1:
	begin
		acc <= exp_dif[EMSB:0];
		cf <= ~exp_dif[EMSB+1];
		$display("acc=%h %h %h", exp_dif, acc, FAC1_exp);
		push_state(DIV1);
		next_state(MD2);
	end
DIV1:
	begin
		$display("FAC1=%h, FAC2=%h, E=%h", FAC1, FAC2, E);
		y <= y - 8'd1;
		FAC1[FMSB:0] <= {FAC1[FMSB:0],~dif[FMSB+1]};
		if (dif[FMSB+1]) begin
			FAC2[FMSB:0] <= {FAC2[FMSB-1:0],1'b0};
			if (FAC2[FMSB]) begin
				next_state(OVFL);
			end
			else if (y!=8'd1)
				next_state(DIV1);
			else begin
				rem <= dif;
				next_state(MDEND);
			end
		end
		else begin
			FAC2[FMSB:0] <= {dif[FMSB-1:0],1'b0};
			if (dif[FMSB]) begin
				next_state(OVFL);
			end
			else if (y!=8'd1)
				next_state(DIV1);
			else begin
				rem <= dif;
				next_state(MDEND);
			end
		end
	end

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
MD2:
	begin
		FAC1[FMSB:0] <= 80'h0;
		if (isFixedPoint) begin
			y <= 8'h4F;
			pop_state();
		end
		else if (cf)
			next_state(OVCHK);
		else if (acc[EMSB])
			next_state(MD3);
		else begin
			pop_state();
			next_state(NORM);
		end
	end
MD3:
	begin
		acc[EMSB] <= ~acc[EMSB];
		FAC1[EMSB+FMSB+1:FMSB+1] <= {~acc[EMSB],acc[EMSB-1:0]};
		y <= 8'h4F;
		pop_state();
	end
OVCHK:
	begin
		if (~acc[EMSB])
			next_state(MD3);
		else
			next_state(OVFL);
	end
OVFL:
	begin
		vf <= 1'b1;
		next_state(IDLE);
	end

//-----------------------------------------------------------------------------
// FIX2FLT
// - convert 64 bit fixed point number to floating point
//-----------------------------------------------------------------------------

FIX2FLT:
	begin
		FAC1[EMSB+FMSB+1:FMSB+1] <= 16'h804E;	// exponent = 78
		next_state(NORM);
	end

//-----------------------------------------------------------------------------
// FLT2FIX
// - convert floating point number to fixed point.
//-----------------------------------------------------------------------------

FLT2FIX:
	begin
		// If the exponent is too small then no amount of shifting will
		// result in a non-zero number. In this case we just set the 
		// FAC to zero. Otherwise FLT2FIX would spin for thousands of cycles
		// until the exponent incremented finally to 803Eh.
		if (FAC1_exp < 16'h7FB0) begin
			FAC1[79:0] <= 80'd0;
			FAC1[95:80] <= 16'h804E;
			pop_state();
		end
		// If the exponent is too large, we can't right shift and the value
		// would overflow a 64-bit integer, so we just set it to the max.
		else if (FAC1_exp > 16'h804E) begin
			vf <= 1'b1;
			FAC1[95:80] <= 16'h804E;
			FAC1[79:0] <= FAC1[79] ? 80'h80000000000000000000 : 80'h7FFFFFFFFFFFFFFFFFFF;
			pop_state();
		end
		else if (FAC1_exp==16'h804E)
			pop_state();
		else begin
			push_state(FLT2FIX);
			isRTAR <= TRUE;
			next_state(RTLOG);
		end
	end
endcase
end

/*
DIVBY10:
	begin
		FAC2[EMSB+FMSB+1:FMSB+1] <= 16'h8003;
		FAC2[FMSB] <= 1'b0;		// +ve
		FAC2[FMSB-1:75] <= 4'hA;	// 10
		FAC2[74:0] <= 75'd0;
		next_state(FDIV);
	end
*/
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
task push_state;
input [5:0] st;
begin
	state_stk[0] <= st;
	state_stk[1] <= state_stk[0];
	state_stk[2] <= state_stk[1];
	state_stk[3] <= state_stk[2];
//	state_stk[sp-4'd1] <= st;
//	sp <= sp - 4'd1;
end
endtask

task pop_state;
begin
	state <= state_stk[0];
	state_stk[0] <= state_stk[1];
	state_stk[1] <= state_stk[2];
	state_stk[2] <= state_stk[3];
	state_stk[3] <= IDLE;
//	next_state(state_stk[sp]);
//	sp <= sp + 4'd1;
end
endtask

task next_state;
input [7:0] st;
begin
	state <= st;
end
endtask

endmodule
