/*

MODULE: openfire_primitives

DESCRIPTION: Contains all submodules called by the design.

CONTENTS:
openfire_compare		comparator for conditional branchs & CMPU instr
openfire_alu	
openfire_rf_sram		registerfile
openfire_sram			synchronous SRAM for memories -- synthesizes to BRAMs	
openfire_instr_sram		same as above except includes INITIAL statement to load
				instructions for simulation
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
SOFTWARE.

*/


/**********************************
 * Comparator for Branches & CMPU *
 **********************************/
module openfire_compare (
	in0, in1, fns,		// inputs
	out);			// outputs

input	[`D_WIDTH-1:0]	in0;
input	[`D_WIDTH-1:0]	in1;
input	[2:0]		fns;

output			out;

reg			out;

wire			cmp_out;

`ifdef FAST_CMP
	wire		cmp_dual_out;

	// A single comparator could be used, but timing is tight.
	// A single comparator can reach 100 MHz in a 2vp-7 part, but not in a -6 speed grade.
	assign cmp_dual_out = (in0 > in1);
	assign cmp_out = (in0[`D_WIDTH-2:0] > 0);

	always@(in0 or in1 or cmp_out or fns or cmp_dual_out)
	begin

		// Verilog treats all signals as unsigned
		case(fns)
		`CMP_equal:		out <= (in0 == 0);
		`CMP_not_equal:		out <= (in0 != 0);
		`CMP_lessthan:		out <= (in0[`D_WIDTH-1] == 1); // negative number
		`CMP_lt_equal:		out <= (in0 == 0) | (in0[`D_WIDTH-1] == 1);
		`CMP_greaterthan:	out <= cmp_out & (in0[`D_WIDTH-1] == 0);
		`CMP_gt_equal:		out <= (cmp_out | (in0[`D_WIDTH-2:0] == 0)) & (in0[`D_WIDTH-1] == 0);
		`CMP_one:		out <= 1'b1;	// used for unconditional branchs
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
	reg     [`D_WIDTH-1:0]  cmp_in_a;
	reg     [`D_WIDTH-1:0]  cmp_in_b;

	assign cmp_out = (cmp_in_a > cmp_in_b);

	always@(in0 or in1 or cmp_out or fns)
	begin
		cmp_in_a        <= {1'b0, in0[`D_WIDTH-2:0]};
		cmp_in_b        <= 0;
		// Verilog treats all signals as unsigned
		case(fns)
		`CMP_equal:             out <= (in0 == 0);
		`CMP_not_equal:         out <= (in0 != 0);
		`CMP_lessthan:          out <= (in0[`D_WIDTH-1] == 1); // negative number
		`CMP_lt_equal:          out <= (in0 == 0) | (in0[`D_WIDTH-1] == 1);
		`CMP_greaterthan:       out <= cmp_out & (in0[`D_WIDTH-1] == 0);
		`CMP_gt_equal:          out <= (cmp_out | (in0[`D_WIDTH-2:0] == 0)) & (in0[`D_WIDTH-1] == 0);
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

	reg     [`D_WIDTH-2:0]  cmp_in_a;

	assign cmp_out = (cmp_in_a > 0);

	always@(in0, in1, cmp_out, fns)
	begin
		cmp_in_a        <= in0[`D_WIDTH-2:0];
		// Verilog treats all signals as unsigned
		case(fns)
		`CMP_equal:             out <= (in0 == 0);
		`CMP_not_equal:         out <= (in0 != 0);
		`CMP_lessthan:          out <= (in0[`D_WIDTH-1] == 1); // negative number
		`CMP_lt_equal:          out <= (in0 == 0) | (in0[`D_WIDTH-1] == 1);
		`CMP_greaterthan:       out <= cmp_out & (in0[`D_WIDTH-1] == 0);
		`CMP_gt_equal:          out <= (cmp_out | (in0[`D_WIDTH-2:0] == 0)) & (in0[`D_WIDTH-1] == 0);
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
	
input	[`D_WIDTH-1:0]	a;
input	[`D_WIDTH-1:0]	b;
input			c_in;
input	[3:0]		fns;
input			clock;
input			reset;
input			stall;

output	[`D_WIDTH-1:0]	alu_result;
output	[31:0]		dmem_addr;
output			c_out;
output			alu_multicycle_instr;
output			alu_multicycle_instr_complete;

reg	[`D_WIDTH-1:0]	alu_result;
reg	[`D_WIDTH-1:0]	adder_out;
reg			c_out;
reg			alu_multicycle_instr;
reg	[2:0]		mul_counter;

reg	[`D_WIDTH-1:0]	mul_result;
reg	[`D_WIDTH-1:0]	mul_tmp1;
reg	[`D_WIDTH-1:0]	a_in;
reg	[`D_WIDTH-1:0]	b_in;

`ifdef MUL
// Force tools to infer pipelined Mult - allows use of code on devices other than Xilinx FPGAs
// Mult takes 5 execute cycles to complete at 32-bits
`ifdef DATAPATH_32
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
`else // 16-bit datapath completes in single cycle
assign alu_multicycle_instr_complete = 0;

always@(a or b)
	mul_result <= a * b;
`endif
`endif

// dmem_addr comes straight from adder to by-pass ALU output MUX for timing
`ifdef DATAPATH_32
assign dmem_addr = adder_out;
`else // 16-bit case
assign dmem_addr = {16'b0, adder_out};
`endif

// --> need stall prevention in ALU below?

// ALU result selection
`ifdef MUL
always@(a or b or c_in or fns or mul_result)
`else
always@(a or b or c_in or fns)
`endif
begin
	if(~stall) begin

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
				alu_result <= {{(`D_WIDTH-8){a[7]}}, a[7:0]};
				c_out <= 0;
		end	
	`ALU_sex16:
		begin
				alu_result <= {{(`D_WIDTH-16){a[15]}}, a[15:0]};
				c_out <= 0;
		end
	`ALU_shiftR_arth:
		begin
				alu_result <= {a[`D_WIDTH-1], a[`D_WIDTH-1:1]};
				c_out <= a[0];
		end	
	`ALU_shiftR_log:
		begin
				alu_result <= {1'b0, a[`D_WIDTH-1:1]};
				c_out <= a[0];
		end
	`ALU_shiftR_c:
		begin
				alu_result <= {c_in, a[`D_WIDTH-1:1]};
				c_out <= a[0];
		end
	`ALU_compare:		{c_out, alu_result} <= a + b + c_in;
	`ALU_compare_uns:	{c_out, alu_result} <= a + b + c_in;	// comparator determines MSB
`ifdef MUL
	`ALU_multiply:		
		begin
`ifdef DATAPATH_32
				alu_multicycle_instr <= 1;
`endif
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
end // end if(~stall)
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
	read_data_out, write_data_out);					// outputs

parameter	addr_width = 5;	// 32 registers

input				clock;
input	[addr_width-1:0]	read_addr;
input	[addr_width-1:0]	write_addr;
input	[`D_WIDTH-1:0]		data_in;
input				we;

output	[`D_WIDTH-1:0]		read_data_out;
output	[`D_WIDTH-1:0]		write_data_out;

reg	[`D_WIDTH-1:0]		MEM [(1 << addr_width) - 1:0];

integer i;
initial
begin
        for(i=0; i < ( 1 << addr_width); i=i+1)
                MEM[i] <= 0;
end

always@(posedge clock)
begin
	if (we)
		MEM[write_addr] <= data_in;
end

assign read_data_out = MEM[read_addr];
assign write_data_out = MEM[write_addr];

endmodule

/******************************
 * Dual Port Synchronious RAM *
 * 1 write port, 1 read port  *
 * sync writes, sync reads    *
 ******************************/
module openfire_data_sram(
	clock, enable,					// inputs
	read_addr, write_addr, data_in, we,
	data_out);					// outputs

input			clock;
input			enable;
input	[`DM_SIZE-1:0]	read_addr;
input	[`DM_SIZE-1:0]	write_addr;
input	[31:0]		data_in;
input			we;

output	[31:0]		data_out;

reg	[31:0]		MEM [(1 << `DM_SIZE) - 1:0];
reg	[31:0]		data_out;

initial $readmemh("data.rom", MEM);

always@(posedge clock)
begin
	if (enable)
		begin
			if (we)
				MEM[write_addr] <= data_in;
			data_out <= MEM[read_addr];
		end
end // end always@

endmodule


/******************************
 * Dual Port   Sync RAM       *
 * 1 write port, 1 read port  *
 * LOADS INSTR into MEM	      *
 ******************************/
module openfire_instr_sram(
	clock, enable,					// inputs
	read_addr, write_addr, data_in, we,
	data_out);					// outputs

input			clock;
input			enable;
input	[`IM_SIZE-1:0]	read_addr;
input	[`IM_SIZE-1:0]	write_addr;
input	[31:0]		data_in;
input			we;

output	[31:0]		data_out;

reg	[31:0]		MEM [(1 << `IM_SIZE) - 1:0];
reg	[31:0]		data_out;

// initial statement for loading instructions in simulation
// initial $readmemh("instr.rom", MEM);

always@(posedge clock)
begin
	if (enable)
		begin
			if (we)
				MEM[write_addr] <= data_in;
			data_out <= MEM[read_addr];
		end
end // end always@

endmodule


/******************************
 * Dual Port   Sync RAM       *
 * 1 write port, 1 read port  *
 * LOADS INSTR into MEM	      *
 ******************************/
// Used for combined Data and Instr mem
module openfire_dual_sram(
	clock, enable, wr_clock,			// inputs
	read_addr, write_addr, data_in, we,
	data_out, wr_data_out);					// outputs

input				clock;
input				wr_clock;
input				enable;
input	[`IM_SIZE-1:0]		read_addr;
input	[`IM_SIZE-1:0]		write_addr;
input	[31:0]			data_in;
input				we;

output	[31:0]			data_out;
output	[31:0]			wr_data_out;

reg	[31:0]			MEM [(1 << `BRAM_SIZE) - 1:0];
reg	[31:0]			data_out;
reg	[31:0]			wr_data_out;

// initial statement for loading instructions in simulation
// initial $readmemh("instr.rom", MEM);

always@(posedge wr_clock)
begin
	if (enable)
		begin
			if (we)
				MEM[write_addr] <= data_in;
			wr_data_out <= MEM[write_addr];
		end
end // end always@

always@(posedge clock)
begin
	if(enable)
		data_out <= MEM[read_addr];
end

endmodule

/*****************************************************************************/

module openfire_named_sram_16k (
	dmem_clk,
	dmem_en,
	dmem_we,
	dmem_addr,
	dmem_data_i,
	dmem_data_o,

	imem_clk,
	imem_en,
	imem_addr,
	imem_data_o
);

	input  wire        dmem_clk;
	input  wire        dmem_en;
	input  wire        dmem_we;
	input  wire [11:0] dmem_addr;
	input  wire [31:0] dmem_data_i;
	output wire [31:0] dmem_data_o;

	input  wire        imem_clk;
	input  wire        imem_en;
	input  wire [11:0] imem_addr;
	output wire [31:0] imem_data_o;

    RAMB16_S4_S4 bus0_ram0(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[3:0]),   .DOA(dmem_data_o[3:0]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[3:0]));
    RAMB16_S4_S4 bus0_ram1(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[7:4]),   .DOA(dmem_data_o[7:4]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[7:4]));
    RAMB16_S4_S4 bus0_ram2(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[11:8]),  .DOA(dmem_data_o[11:8]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[11:8]));
    RAMB16_S4_S4 bus0_ram3(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[15:12]), .DOA(dmem_data_o[15:12]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[15:12]));
    RAMB16_S4_S4 bus0_ram4(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[19:16]), .DOA(dmem_data_o[19:16]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[19:16]));
    RAMB16_S4_S4 bus0_ram5(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[23:20]), .DOA(dmem_data_o[23:20]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[23:20]));
    RAMB16_S4_S4 bus0_ram6(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[27:24]), .DOA(dmem_data_o[27:24]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[27:24]));
    RAMB16_S4_S4 bus0_ram7(
        .CLKA(dmem_clk), .ENA(dmem_en), .WEA(dmem_we), .ADDRA(dmem_addr), .DIA(dmem_data_i[31:28]), .DOA(dmem_data_o[31:28]), 
        .CLKB(imem_clk), .ENB(imem_en),                .ADDRB(imem_addr),                           .DOB(imem_data_o[31:28]));

endmodule
