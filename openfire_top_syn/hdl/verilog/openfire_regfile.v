/*

MODULE: openfire_regfile

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


`ifdef FSL_LINK
module openfire_regfile (
	reset, clock,							// top level
	regA_addr, regB_addr, regD_addr, result, pc_regfile, 		// inputs
	dmem_data, regfile_input_sel, we_load_dly, dmem_addr_lsb,
	we_alu_branch, fsl_number,
	fsl0_s_data, fsl1_s_data, fsl2_s_data, fsl3_s_data, 
	fsl4_s_data, fsl5_s_data, fsl6_s_data, fsl7_s_data, 
	regA, regB, regD, enable);					// outputs
`else
module openfire_regfile (
	reset, clock,							// top level
	regA_addr, regB_addr, regD_addr, result, pc_regfile, 		// inputs
	dmem_data, regfile_input_sel, we_load_dly, dmem_addr_lsb,
	we_alu_branch,
	regA, regB, regD, enable);					// outputs
`endif

// From top level
input 		reset;
input 		clock;

// From DECODE
input	[4:0]	regA_addr;
input	[4:0]	regB_addr;
input	[4:0]	regD_addr;
input	[2:0]	regfile_input_sel;
input		we_alu_branch;

// From EXECUTE
input	[`D_WIDTH-1:0]	result;
input	[`D_WIDTH-1:0]	pc_regfile;
input			we_load_dly;
input			enable;
input	[1:0]		dmem_addr_lsb;

`ifdef FSL_LINK
// From FSL
input	[31:0]		fsl0_s_data;
input	[31:0]		fsl1_s_data;
input	[31:0]		fsl2_s_data;
input	[31:0]		fsl3_s_data;
input	[31:0]		fsl4_s_data;
input	[31:0]		fsl5_s_data;
input	[31:0]		fsl6_s_data;
input	[31:0]		fsl7_s_data;
input	[2:0]		fsl_number;
`endif

// From DMEM
input	[31:0]		dmem_data;

output	[`D_WIDTH-1:0]	regA;
output	[`D_WIDTH-1:0]	regB;
output	[`D_WIDTH-1:0]	regD;

reg	[`D_WIDTH-1:0]	input_data;

wire			write_en;
wire	[`D_WIDTH-1:0]	extended_pc;

// Write to registers on we_alu_branch OR we_load_dly
//	UNLESS r0 is the target. r0 MUST always be zero. (|regD_addr) isolates R0
// Allow write on reset to load r0 with zero.
assign	write_en = reset ? 1'b1 : (we_alu_branch | we_load_dly) & (|regD_addr) & enable;

// extended PC to datapath width
assign extended_pc = pc_regfile;

// Input select into REGFILE
`ifdef FSL_LINK
always@(dmem_data or extended_pc or result or regfile_input_sel or dmem_addr_lsb or write_en or clock or
        fsl0_s_data or fsl1_s_data or fsl2_s_data or fsl3_s_data or 
        fsl4_s_data or fsl5_s_data or fsl6_s_data or fsl7_s_data or fsl_number	)
`else
always@(dmem_data or extended_pc or result or regfile_input_sel or dmem_addr_lsb or write_en or clock)
`endif
`ifdef DATAPATH_32
begin
	case(regfile_input_sel)
	`RF_dmem_byte:
		case(dmem_addr_lsb)	// selects which Byte to update in registers
		2'b00:		input_data <= {24'b0, dmem_data[31:24]};
		2'b01:		input_data <= {24'b0, dmem_data[23:16]};
		2'b10:		input_data <= {24'b0, dmem_data[15:8]};
		2'b11:		input_data <= {24'b0, dmem_data[7:0]};
		endcase
	`RF_dmem_halfword:
		case(dmem_addr_lsb)	// selects which half-word to update
		2'b00:		input_data <= {16'b0, dmem_data[31:16]};
		default:		// unaligned access!
			begin
				input_data <= {16'b0, dmem_data[15:0]};
				if(write_en & ~clock & (dmem_addr_lsb ==2'b10)) $display("ERROR! Unaligned HalfWord Load at PC %x", pc_regfile);
			end
		endcase
	`RF_dmem_wholeword:	input_data <= dmem_data;
	`RF_alu_result:		input_data <= result;
	`RF_pc:			input_data <= extended_pc;
	`RF_zero:		input_data <= 0;
`ifdef FSL_LINK
	`RF_fsl:	begin
		case (fsl_number)
			0 : input_data <= fsl0_s_data;
			1 : input_data <= fsl1_s_data;
			2 : input_data <= fsl2_s_data;
			3 : input_data <= fsl3_s_data;
			4 : input_data <= fsl4_s_data;
			5 : input_data <= fsl5_s_data;
			6 : input_data <= fsl6_s_data;
			7 : input_data <= fsl7_s_data;
			default : input_data <= 32'hDEADBEEF;
		endcase
	end
`endif
	default:	
		begin
			input_data <= 0;	// for simulation
			if(write_en & ~clock) $display("ERROR! REGFILE input selector set to illegal value %d at PC %x", regfile_input_sel, pc_regfile);
		end
	endcase
end
`else // 16-bit datapath!
begin
	case(regfile_input_sel)
	`RF_dmem_byte:
		case(dmem_addr_lsb)	// selects which Byte to update in registers
		2'b00:		input_data <= {8'b0, dmem_data[31:24]};
		2'b01:		input_data <= {8'b0, dmem_data[23:16]};
		2'b10:		input_data <= {8'b0, dmem_data[15:8]};
		2'b11:		input_data <= {8'b0, dmem_data[7:0]};
		endcase
	`RF_dmem_halfword:
		case(dmem_addr_lsb)	// selects which half-word to update
		2'b00:		input_data <= dmem_data[31:16];
		2'b10:		input_data <= dmem_data[15:0];
		default:		// unaligned access!
			begin
				input_data <= dmem_data[31:16];
				if(write_en & ~clock) $display("ERROR! Unaligned HalfWord Load at PC %x", pc_regfile);
			end
		endcase
	`RF_dmem_wholeword:
		case(dmem_addr_lsb)
		2'b00:		input_data <= dmem_data[15:0];
		default:		// unaligned access!
			begin
				input_data <= dmem_data;
				if(write_en & ~clock) $display("ERROR! Unaligned Word Load at PC %x", pc_regfile);
			end
		endcase
	`RF_alu_result:		input_data <= result;
	`RF_pc:			input_data <= extended_pc;
	`RF_zero:		input_data <= 0;
`ifdef FSL_LINK
	`RF_fsl:
		case (fsl_number)
			0 : input_data <= fsl0_s_data[15:0];
			1 : input_data <= fsl1_s_data[15:0];
			2 : input_data <= fsl2_s_data[15:0];
			3 : input_data <= fsl3_s_data[15:0];
			4 : input_data <= fsl4_s_data[15:0];
			5 : input_data <= fsl5_s_data[15:0];
			6 : input_data <= fsl6_s_data[15:0];
			7 : input_data <= fsl7_s_data[15:0];
			default : input_data <= 16'hBEEF;
		endcase
	end
`endif
	default:	
		begin
			input_data <= 0;
			if(write_en & ~clock) $display("ERROR! REGFILE input selector set to illegal value %d at PC %x", regfile_input_sel, pc_regfile);
		end
	endcase
end
`endif

// We need a 3-port register file -- create from 2, 2-port SRAMs
// Tie write ports together
openfire_rf_sram 	RF_BANK0 (.clock(clock), .read_addr(regA_addr), 
			.write_addr(regD_addr), .data_in(input_data), 
			.we(write_en), .read_data_out(regA), .write_data_out(regD));

openfire_rf_sram 	RF_BANK1 (.clock(clock), .read_addr(regB_addr), 
			.write_addr(regD_addr), .data_in(input_data), 
			.we(write_en), .read_data_out(regB));	
	
endmodule
