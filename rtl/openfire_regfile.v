/*	MODULE: openfire_regfile

	DESCRIPTION: This module instantiates two, dual-port aynchronous memories.  In
Xilinx parts this synthesizes to Select (LUT-based) RAM.  To handle half-word 
and byte loads, MUXes and a feedback loop are used such that only the desired
portions of the previous word are modified.

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

Revision 0.3 27/03/2007 Antonio J Anton
Removed memory load unalignment handling (moved to arbitrer)

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
`include "openfire_define.v"

module openfire_regfile (
`ifdef FSL_LINK
	fsl_s_data,
`endif
	reset, clock,
	regA_addr, regB_addr, regD_addr, result, pc_regfile,
	dmem_data, regfile_input_sel, we_regfile,
	we_alu_branch, 
	regA, regB, regD, enable
);

input 		reset;				// From top level
input 		clock;
input	[4:0]		regA_addr;		// From DECODE
input	[4:0]		regB_addr;
input	[4:0]		regD_addr;
input	[3:0]		regfile_input_sel;
input				we_alu_branch;
input	[31:0]	result;			// From EXECUTE
input	[`A_SPACE+1:0]	pc_regfile;
input				we_regfile;
input				enable;
input	[31:0]	dmem_data;		// From DMEM
`ifdef FSL_LINK
input	[31:0]	fsl_s_data;		// From FSL
`endif

output [31:0]	regA;
output [31:0]	regB;
output [31:0]	regD;

reg	[31:0]	input_data;

wire				write_en;
wire	[31:0]	extended_pc;

// Write to registers on we_alu_branch OR we_load
//	UNLESS r0 is the target. r0 MUST always be zero. (|regD_addr) isolates R0
// Allow write on reset to load r0 with zero.
assign	write_en = reset ? 1'b1 : (we_alu_branch | we_regfile) & (|regD_addr) & enable;

// extended PC to datapath width
assign extended_pc[31:`A_SPACE+2] = 0;
assign extended_pc[`A_SPACE+1:0]  = pc_regfile;

// Input select into REGFILE
always@(
`ifdef FSL_LINK
			fsl_s_data or
`endif
			dmem_data or extended_pc or result or regfile_input_sel or write_en or clock
)
begin
	case(regfile_input_sel)
	`RF_dmem_byte:			input_data <= dmem_data[31:24];		// update byte
	`RF_dmem_halfword:	input_data <= dmem_data[31:16];		// update halfword
	`RF_dmem_wholeword:	input_data <= dmem_data;				// update word
	`RF_alu_result:		input_data <= result;
	`RF_pc:					input_data <= extended_pc;
`ifdef FSL_LINK
	`RF_fsl:					input_data <= fsl_s_data;
`endif
	default:
		begin
			input_data <= 0;
//synthesis translate_off
	 		if(write_en & ~clock & (regfile_input_sel != `RF_zero)) $display("ERROR! REGFILE input selector set to illegal value %d at PC %x", regfile_input_sel, pc_regfile);
//synthesis translate_on
		end
	endcase
end

// We need a 3-port register file -- create from 2, 2-port SRAMs
// Tie write ports together
openfire_rf_sram 	RF_BANK0 (
	.clock(clock), 
	.read_addr(regA_addr), 
	.write_addr(regD_addr), 
	.data_in(input_data), 
	.we(write_en), 
	.read_data_out(regA), 
	.write_data_out(regD)
);

openfire_rf_sram 	RF_BANK1 (
	.clock(clock), 
	.read_addr(regB_addr), 
	.write_addr(regD_addr), 
	.data_in(input_data), 
	.we(write_en), 
	.read_data_out(regB), 
	.write_data_out( ) 
);
	
endmodule
