//////////////////////////////////////////////////////////////////
//                                                              //
//  Barrel Shifter for Amber 2 Core                             //
//                                                              //
//  The design is optimized for Altera family of FPGAs,         //
//  and it can be used directly or adapted other N-to-1 LUT     //
//  FPGA platforms.                                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Provides 32-bit shifts LSL, LSR, ASR and ROR                //
//                                                              //
//  Author(s):                                                  //
//      - Dmitry Tarnyagin, dmitry.tarnyagin@lockless.no        //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010-2013 Authors and OPENCORES.ORG            //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
//////////////////////////////////////////////////////////////////


module a23_barrel_shift_fpga (

input       [31:0]          i_in,
input                       i_carry_in,
input       [7:0]           i_shift_amount,     // uses 8 LSBs of Rs, or a 5 bit immediate constant
input                       i_shift_imm_zero,   // high when immediate shift value of zero selected
input       [1:0]           i_function,

output      [31:0]          o_out,
output                      o_carry_out

);

`include "a23_localparams.vh"

wire [31:0] rot_prod;                           // Input rotated by the shift amount

wire [1:0]  lsl_out;                            // LSL: {carry, bit_31}
wire [1:0]  lsr_out;                            // LSR: {carry, bit_31}
wire [1:0]  asr_out;                            // ASR: {carry, bit_31}
wire [1:0]  ror_out;                            // ROR: {carry, bit_31}

reg [32:0]  lsl_mask;                           // Left-hand mask
reg [32:0]  lsr_mask;                           // Right-hand mask
reg [15:0]  low_mask;                           // Mask calculation helper

reg [4:0]   shift_amount;                       // Shift amount for the low-level shifter

reg [2:0]   lsl_selector;                       // Left shift {shift_32, shift_over, shift_amount[4]}
reg [2:0]   lsr_selector;                       // Right shift {shift_32, shift_over, shift_amount[4]}
reg [3:0]   low_selector;                       // {shift_amount[3:0]}

reg         shift_nzero;                        // Amount is not zero
reg         shift_over;                         // Amount is 32 or higher
reg         shift_32;                           // Amount is exactly 32
reg         asr_sign;                           // Sign for ASR shift
reg         direction;                          // Shift direction

wire [31:0] p_r;                                // 1 bit rotated rot_prod
wire [31:0] p_l;                                // Alias for the rot_prod 


// Implementation details:
// Design is based on masking of rotated input by a left- and right- hand masks.
// Rotated product calculation requires 5 levels of combinational logic, and masks
// must be ready before the product is ready. In fact masks require just 3 to 4 levels
// of logic cells using 4-to-1/2x3-to-1 Altera.

always @*
begin
	shift_32 = i_shift_amount == 32;

	shift_over = |i_shift_amount[7:5];

	shift_nzero = |i_shift_amount[7:0];

	shift_amount = i_shift_amount[4:0];

	if (i_shift_imm_zero) begin
		if (i_function == LSR || i_function == ASR) begin
			// The form of the shift field which might be
			// expected to correspond to LSR #0 is used
			// to encode LSR #32, which has a zero result
			// with bit 31 of Rm as the carry output. 
			shift_nzero = 1'b1;
			shift_over = 1'b1;
			// Redundant and can be optimized out
			// shift_32 = 1'b1;
		end else if (i_function == ROR) begin
			// RXR, (ROR w/ imm 0)
			shift_amount[0] = 1'b1;
			shift_nzero = 1'b1;
		end
	end

	// LSB sub-selector calculation. Usually it is taken
	// directly from the shift_amount, but ROR requires
	// no masking at all.
	case (i_function)
		LSL: low_selector = shift_amount[3:0];
		LSR: low_selector = shift_amount[3:0];
		ASR: low_selector = shift_amount[3:0];
		ROR: low_selector = 4'b0000;
	endcase

	// Left-hand MSB sub-selector calculation. Opaque for every function but LSL.
	case (i_function)
		LSL: lsl_selector = {shift_32, shift_over, shift_amount[4]};
		LSR: lsl_selector = 3'b0_1_0; // Opaque mask selector
		ASR: lsl_selector = 3'b0_1_0; // Opaque mask selector
		ROR: lsl_selector = 3'b0_1_0; // Opaque mask selector
	endcase

	// Right-hand MSB sub-selector calculation. Opaque for LSL, transparent for ROR.
	case (i_function)
		LSL: lsr_selector = 3'b0_1_0; // Opaque mask selector
		LSR: lsr_selector = {shift_32, shift_over, shift_amount[4]};
		ASR: lsr_selector = {shift_32, shift_over, shift_amount[4]};
		ROR: lsr_selector = 3'b0_0_0; // Transparent mask selector
	endcase

	// Direction
	case (i_function)
		LSL: direction = 1'b0; // Left shift
		LSR: direction = 1'b1; // Right shift
		ASR: direction = 1'b1; // Right shift
		ROR: direction = 1'b1; // Right shift
	endcase

	// Sign for ASR shift
	asr_sign = 1'b0;
	if (i_function == ASR && i_in[31])
		asr_sign = 1'b1;
end

// Generic rotate. Theoretical cost: 32x5 4-to-1 LUTs.
// Practically a bit higher due to high fanout of "direction".
generate
genvar i, j;
	for (i = 0; i < 5; i = i + 1)
	begin : netgen
		wire [31:0] in;
		reg [31:0] out;
		for (j = 0; j < 32; j = j + 1)
		begin : net
			always @*
				out[j] = in[j] & (~shift_amount[i] ^ direction) |
					 in[wrap(j, i)] & (shift_amount[i] ^ direction);
		end
	end

	// Order is reverted with respect to volatile shift_amount[0]
	assign netgen[4].in = i_in;
	for (i = 1; i < 5; i = i + 1)
	begin : router
		assign netgen[i-1].in = netgen[i].out;
	end
endgenerate

// Aliasing
assign rot_prod = netgen[0].out;

// Submask calculated from LSB sub-selector.
// Cost: 16 4-to-1 LUTs.
always @*
case (low_selector) // synthesis full_case parallel_case
	4'b0000:	low_mask = 16'hffff;
	4'b0001:	low_mask = 16'hfffe;
	4'b0010:	low_mask = 16'hfffc;
	4'b0011:	low_mask = 16'hfff8;
	4'b0100:	low_mask = 16'hfff0;
	4'b0101:	low_mask = 16'hffe0;
	4'b0110:	low_mask = 16'hffc0;
	4'b0111:	low_mask = 16'hff80;
	4'b1000:	low_mask = 16'hff00;
	4'b1001:	low_mask = 16'hfe00;
	4'b1010:	low_mask = 16'hfc00;
	4'b1011:	low_mask = 16'hf800;
	4'b1100:	low_mask = 16'hf000;
	4'b1101:	low_mask = 16'he000;
	4'b1110:	low_mask = 16'hc000;
	4'b1111:	low_mask = 16'h8000;
endcase

// Left-hand mask calculation.
// Cost: 33 4-to-1 LUTs.
always @*
casez (lsl_selector) // synthesis full_case parallel_case
	7'b1??:	lsl_mask =  33'h_1_0000_0000;
	7'b01?:	lsl_mask =  33'h_0_0000_0000;
	7'b001:	lsl_mask = { 1'h_1, low_mask, 16'h_0000};
	7'b000:	lsl_mask = {17'h_1_ffff, low_mask};
endcase

// Right-hand mask calculation.
// Cost: 33 4-to-1 LUTs.
always @*
casez (lsr_selector) // synthesis full_case parallel_case
	7'b1??:	lsr_mask =  33'h_1_0000_0000;
	7'b01?:	lsr_mask =  33'h_0_0000_0000;
	7'b000:	lsr_mask = { 1'h_1, bit_swap(low_mask), 16'h_ffff};
	7'b001:	lsr_mask = {17'h_1_0000, bit_swap(low_mask)};
endcase

// Alias: right-rotated
assign p_r = {rot_prod[30:0], rot_prod[31]};

// Alias: left-rotated
assign p_l = rot_prod[31:0];

// ROR MSB, handling special cases
assign ror_out[0] = i_shift_imm_zero ?	i_carry_in :
					p_r[31];

// ROR carry, handling special cases
assign ror_out[1] = i_shift_imm_zero ?	i_in[0] :
			shift_nzero ?	p_r[31] :
					i_carry_in;

// LSL MSB
assign lsl_out[0] = 	p_l[31] & lsl_mask[31];

// LSL carry, handling special cases
assign lsl_out[1] = 	shift_nzero ?	p_l[0] & lsl_mask[32]:
					i_carry_in;

// LSR MSB
assign lsr_out[0] = 	p_r[31] & lsr_mask[31];

// LSR carry, handling special cases
assign lsr_out[1] = i_shift_imm_zero ?	i_in[31] :
			shift_nzero ?	p_r[31] & lsr_mask[32]:
					i_carry_in;

// ASR MSB
assign asr_out[0] = 	i_in[31] ?	i_in[31] :
					p_r[31] & lsr_mask[31] ;

// LSR carry, handling special cases
assign asr_out[1] =	shift_over ?	i_in[31] :
			shift_nzero ?	p_r[31] :
					i_carry_in;

// Carry and MSB are calculated as above
assign {o_carry_out, o_out[31]} = i_function == LSL ? lsl_out :
                              i_function == LSR ? lsr_out :
                              i_function == ASR ? asr_out :
                                                  ror_out ;

// And the rest of result is the masked rotated input.
assign o_out[30:0] =	(p_l[30:0] & lsl_mask[30:0]) |
			(p_r[30:0] & lsr_mask[30:0]) |
			(~lsr_mask[30:0] & {31{asr_sign}});

// Rotate: calculate bit pos for level "level" and offset "pos"
function [4:0] wrap;
input integer pos;
input integer level;
integer out;
begin
	out = pos - (1 << level);
	wrap = out[4:0];
end
endfunction

// Swap bits in the input 16-bit value
function [15:0] bit_swap;
input [15:0] value;
integer i;
begin
	for (i = 0; i < 16; i = i + 1)
		bit_swap[i] = value[15 - i];
end
endfunction

endmodule
