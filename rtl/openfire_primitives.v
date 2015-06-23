/*	MODULE: openfire_primitives

	DESCRIPTION: Contains all submodules called by the design.

CONTENTS:
openfire_compare		comparator for conditional branchs & CMPU instr
openfire_alu	
openfire_rf_sram		registerfile

TO DO:

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

Revision 0.3, 12/17/2005 SDC
Fixed Register File zeroing function for simulation

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
SOFTWARE	*/

`include "openfire_define.v"

/**********************************
 * Comparator for Branches & CMPU *
 **********************************/
module openfire_compare (
	in0, in1, fns,		// inputs
	out);				// outputs

input	[31:0]	in0;
input	[31:0]	in1;
input	[2:0]		fns;
output			out;

reg			out;

wire			cmp_out;

`ifdef FAST_CMP
	wire		cmp_dual_out;

	// A single comparator could be used, but timing is tight.
	// A single comparator can reach 100 MHz in a 2vp-7 part, but not in a -6 speed grade.
	assign cmp_dual_out = (in0 > in1);
	assign cmp_out = (in0[30:0] > 0);

	always@(in0 or in1 or cmp_out or fns or cmp_dual_out)
	begin

		// Verilog treats all signals as unsigned
		case(fns)
		`CMP_equal:			out <= (in0 == 0);
		`CMP_not_equal:	out <= (in0 != 0);
		`CMP_lessthan:		out <= (in0[31] == 1); // negative number
		`CMP_lt_equal:		out <= (in0 == 0) | (in0[31] == 1);
		`CMP_greaterthan:	out <= cmp_out & (in0[31] == 0);
		`CMP_gt_equal:		out <= (cmp_out | (in0[30:0] == 0)) & (in0[31] == 0);
		`CMP_one:			out <= 1'b1;	// used for unconditional branchs
		`CMP_dual_inputs:	out <= cmp_dual_out;  // used only for CMPU instruction
		default:
			begin
				out <= 1'b0;
				$display("ERROR! Comparator set to illegal function!");
			end
		endcase
	end // always@
`else
`ifdef CMP
	// Force tools to synthesize only a single 32-bit comparator... cannot reach 100 MHz in a 2vp speed grade 6 part
	reg     [31:0]  cmp_in_a;
	reg     [31:0]  cmp_in_b;

	assign cmp_out = (cmp_in_a > cmp_in_b);

	always@(in0 or in1 or cmp_out or fns)
	begin
		cmp_in_a        <= {1'b0, in0[30:0]};
		cmp_in_b        <= 0;
		// Verilog treats all signals as unsigned
		case(fns)
		`CMP_equal:             out <= (in0 == 0);
		`CMP_not_equal:         out <= (in0 != 0);
		`CMP_lessthan:          out <= (in0[31] == 1); // negative number
		`CMP_lt_equal:          out <= (in0 == 0) | (in0[31] == 1);
		`CMP_greaterthan:       out <= cmp_out & (in0[31] == 0);
		`CMP_gt_equal:          out <= (cmp_out | (in0[30:0] == 0)) & (in0[30] == 0);
		`CMP_one:               out <= 1'b1;    // used for unconditional branchs
		`CMP_dual_inputs:       
			begin   // used only for CMPU instruction
					cmp_in_a        <= in0;
					cmp_in_b        <= in1;
					out             <= cmp_out;
			end
		default:
			begin
				out <= 1'b0;
				$display("ERROR! Comparator set to illegal function!");
			end
		endcase
	end // always@
`else // Do not allow CMPU instruction

	reg     [30:0]  cmp_in_a;

	assign cmp_out = (cmp_in_a > 0);

	always@(in0, in1, cmp_out, fns)
	begin
		cmp_in_a        <= in0[30:0];
		// Verilog treats all signals as unsigned
		case(fns)
		`CMP_equal:             out <= (in0 == 0);
		`CMP_not_equal:         out <= (in0 != 0);
		`CMP_lessthan:          out <= (in0[31] == 1); // negative number
		`CMP_lt_equal:          out <= (in0 == 0) | (in0[31] == 1);
		`CMP_greaterthan:       out <= cmp_out & (in0[31] == 0);
		`CMP_gt_equal:          out <= (cmp_out | (in0[30:0] == 0)) & (in0[31] == 0);
		`CMP_one:               out <= 1'b1;    // used for unconditional branchs
		default:
			begin
				out <= 1'b0;
				$display("ERROR! Comparator set to illegal function!");
			end
		endcase
	end // always@
`endif
`endif

endmodule

/**************
 * Custom ALU *
 **************/
module openfire_alu (
	a, b, c_in, fns, clock,	reset, stall,	// inputs
	alu_result, c_out, dmem_addr,		// output
	alu_multicycle_instr, alu_multicycle_instr_complete);		
	
input	[31:0]	a;
input	[31:0]	b;
input			 	c_in;
input	[3:0]		fns;
input				clock;
input				reset;
input				stall;

output [31:0]	alu_result;
output [31:0]	dmem_addr;
output			c_out;
output			alu_multicycle_instr;
output			alu_multicycle_instr_complete;

reg	[31:0]	alu_result;
reg	[31:0]	adder_out;
reg				c_out;
reg				alu_multicycle_instr;
reg	[2:0]		mul_counter;

reg	[31:0]	mul_result;
reg	[31:0]	mul_tmp1;
reg	[31:0]	a_in;
reg	[31:0]	b_in;

`ifdef MUL
// Force tools to infer pipelined Mult - allows use of code on devices other than Xilinx FPGAs
// Mult takes 5 execute cycles to complete at 32-bits
assign alu_multicycle_instr_complete = (mul_counter == 3'b011);

always@(posedge clock)
begin
	if(reset)
		begin
			a_in		<= 0;
			b_in		<= 0;
			mul_tmp1	<= 0;
			mul_result	<= 0;
			mul_counter	<= 0;
		end
	else if (~stall)
		begin	// infer pipelined multiplier
			a_in		<= a;
			b_in		<= b;
			mul_tmp1	<= a_in * b_in;
			mul_result	<= mul_tmp1;
			if (mul_counter == 3)
				mul_counter 	<= 0;
			else if(alu_multicycle_instr)
				mul_counter 	<= mul_counter + 1;
		end
end
`endif

// dmem_addr comes straight from adder to by-pass ALU output MUX for timing
assign dmem_addr = adder_out;

// ALU result selection
`ifdef MUL
always@(a or b or c_in or fns or mul_result)
`else
always@(a or b or c_in or fns)
`endif
begin
	{c_out, adder_out}	<= a + b + c_in;
	alu_multicycle_instr 	<= 0;
	case(fns)
	//`ALU_add:		{c_out, alu_result} <= a + b + c_in;
	`ALU_logic_or:
		begin
				alu_result <= a | b;
				c_out <= 0;
		end
	`ALU_logic_and:
		begin
				alu_result <= a & b;
				c_out <= 0;
		end	
	`ALU_logic_xor:
		begin
				alu_result <= a ^ b;
				c_out <= 0;
		end	
	`ALU_sex8:
		begin
				alu_result <= {{(24){a[7]}}, a[7:0]};
				c_out <= 0;
		end	
	`ALU_sex16:
		begin
				alu_result <= {{(16){a[15]}}, a[15:0]};
				c_out <= 0;
		end
	`ALU_shiftR_arth:
		begin
				alu_result <= {a[31], a[31:1]};
				c_out <= a[0];
		end	
	`ALU_shiftR_log:
		begin
				alu_result <= {1'b0, a[31:1]};
				c_out <= a[0];
		end
	`ALU_shiftR_c:
		begin
				alu_result <= {c_in, a[31:1]};
				c_out <= a[0];
		end
	`ALU_compare:		{c_out, alu_result} <= a + b + c_in;
	`ALU_compare_uns:	{c_out, alu_result} <= a + b + c_in;	// comparator determines MSB
`ifdef MUL
	`ALU_multiply:		
		begin
				alu_multicycle_instr <= 1;
				alu_result <= mul_result;
				c_out <= 0;
		end
`endif
	default: //`ALU_add -- moved to default for speed considerations
		begin
			{c_out, alu_result} <= a + b + c_in;
			if(fns != `ALU_add) $display("ERROR! ALU set to illegal or unimplemented function!");
		end
	endcase
end // end always@

endmodule

/*********************************************
 * Register File SRAM                        *
 * Created from 2, 2-bank SRAMs              *
 * Async Reads, Sync Writes                  *
 * Targets dual-port distributed Select RAM  *
 *********************************************/
module openfire_rf_sram(
	clock,
	read_addr, write_addr, data_in, we,		// inputs
	read_data_out, write_data_out);			// outputs

parameter	addr_width = 5;	// 32 registers

input				clock;
input	[addr_width-1:0]	read_addr;
input	[addr_width-1:0]	write_addr;
input	[31:0]		data_in;
input				we;

output [31:0]	read_data_out;
output [31:0]	write_data_out;

reg	[31:0]		MEM [(1 << addr_width) - 1:0];

//synthesis translate_off
integer i;
initial
begin
        for(i=0; i < ( 1 << addr_width); i=i+1)
                MEM[i] <= 0;
end
//synthesis translate_on

always@(posedge clock)
begin
	if (we)
		MEM[write_addr] <= data_in;
end

assign read_data_out = MEM[read_addr];
assign write_data_out = MEM[write_addr];

endmodule

