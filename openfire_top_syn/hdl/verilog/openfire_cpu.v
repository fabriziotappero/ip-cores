/*

MODULE: openfire_cpu

DESCRIPTION: This is the top module for the openfire processor, instantiating
the fetch, decode, execute, pipeline_ctrl, and register file modules.

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

Revision 0.3, 12/17/2005 SDC
Fixed PC size bug

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
// pc is output to create FSL_debug port at the next level up
module openfire_cpu (
	clock, reset, stall,                                       // inputs
	dmem_data_in, imem_data_in,
	dmem_addr, imem_addr, dmem_data_out, dmem_we, dmem_en, pc, // outputs
	fsl0_s_control, fsl0_s_exists, fsl0_m_full, 
	fsl0_m_control, fsl0_m_write, fsl0_s_read, 
	fsl1_s_control, fsl1_s_exists, fsl1_m_full, 
	fsl1_m_control, fsl1_m_write, fsl1_s_read, 
	fsl2_s_control, fsl2_s_exists, fsl2_m_full, 
	fsl2_m_control, fsl2_m_write, fsl2_s_read, 
	fsl3_s_control, fsl3_s_exists, fsl3_m_full, 
	fsl3_m_control, fsl3_m_write, fsl3_s_read, 
	fsl4_s_control, fsl4_s_exists, fsl4_m_full, 
	fsl4_m_control, fsl4_m_write, fsl4_s_read, 
	fsl5_s_control, fsl5_s_exists, fsl5_m_full, 
	fsl5_m_control, fsl5_m_write, fsl5_s_read, 
	fsl6_s_control, fsl6_s_exists, fsl6_m_full, 
	fsl6_m_control, fsl6_m_write, fsl6_s_read, 
	fsl7_s_control, fsl7_s_exists, fsl7_m_full, 
	fsl7_m_control, fsl7_m_write, fsl7_s_read,
	fsl0_s_data, fsl1_s_data, fsl2_s_data, fsl3_s_data, 
	fsl4_s_data, fsl5_s_data, fsl6_s_data, fsl7_s_data, 
	fsl0_m_data, fsl1_m_data, fsl2_m_data, fsl3_m_data, 
	fsl4_m_data, fsl5_m_data, fsl6_m_data, fsl7_m_data );	   // FSL
`else
module openfire_cpu (
	clock, reset, stall,                                       // inputs
	dmem_data_in, imem_data_in,
	dmem_addr, imem_addr, dmem_data_out, dmem_we, dmem_en);    // outputs
`endif

input		clock;
input		reset;
input		stall;
input	[31:0]	dmem_data_in;
input	[31:0]	imem_data_in;

output	[31:0]	dmem_data_out;
output	[31:0]	dmem_addr;
output	[31:0]	imem_addr;
output		dmem_we;
output		dmem_en;  // Change: Added dmem_en signal to indicate dmem access

wire	[31:0]	dmem_addr_internal;
wire		branch_taken;
wire	[`D_WIDTH-1:0]	pc_branch;
wire	[`D_WIDTH-1:0]	pc_decode;
wire	[`D_WIDTH-1:0]	pc_exe_rf;
wire	[31:0]	instruction;
wire	[4:0]	regA_addr;
wire	[4:0]	regB_addr;
wire	[4:0]	regD_addr;
wire	[`D_WIDTH-1:0]	immediate;

wire	[1:0]	alu_inputA_sel;
wire	[1:0]	alu_inputB_sel;
wire	[1:0]	alu_inputC_sel;
wire	[3:0]	alu_fns_sel;
wire	[2:0]	comparator_fns_sel;
wire		we_alu_branch;
wire		we_load;
wire		we_store;
wire	[2:0]	regfile_input_sel;
wire	[1:0]	dmem_input_sel;
wire		delay_bit;
wire	[`D_WIDTH-1:0]	result;

wire	[`D_WIDTH-1:0]	regA;
wire	[`D_WIDTH-1:0]	regB;
wire	[`D_WIDTH-1:0]	regD;
wire		we_load_dly;
wire		we_store_dly;
wire		update_carry;
wire		stall_exe;
wire		stall_decode;
wire		stall_fetch;
wire		instr_complete;
wire		flush;
wire		branch_instr;
wire	[1:0]	byte_sel;

`ifdef FSL_LINK
//From Decode Logic
wire		fsl_get;
wire		fsl_cmd_vld;
wire		fsl_control;
wire		fsl_blocking;
wire [2:0]	fsl_number;
//FSL Specific Wires
input  wire		fsl0_s_control;
input  wire		fsl0_s_exists;
input  wire		fsl0_m_full;
output wire		fsl0_m_control;
output wire		fsl0_m_write;
output wire		fsl0_s_read;
input  wire		fsl1_s_control;
input  wire		fsl1_s_exists;
input  wire		fsl1_m_full;
output wire		fsl1_m_control;
output wire		fsl1_m_write;
output wire		fsl1_s_read;
input  wire		fsl2_s_control;
input  wire		fsl2_s_exists;
input  wire		fsl2_m_full;
output wire		fsl2_m_control;
output wire		fsl2_m_write;
output wire		fsl2_s_read;
input  wire		fsl3_s_control;
input  wire		fsl3_s_exists;
input  wire		fsl3_m_full;
output wire		fsl3_m_control;
output wire		fsl3_m_write;
output wire		fsl3_s_read;
input  wire		fsl4_s_control;
input  wire		fsl4_s_exists;
input  wire		fsl4_m_full;
output wire		fsl4_m_control;
output wire		fsl4_m_write;
output wire		fsl4_s_read;
input  wire		fsl5_s_control;
input  wire		fsl5_s_exists;
input  wire		fsl5_m_full;
output wire		fsl5_m_control;
output wire		fsl5_m_write;
output wire		fsl5_s_read;
input  wire		fsl6_s_control;
input  wire		fsl6_s_exists;
input  wire		fsl6_m_full;
output wire		fsl6_m_control;
output wire		fsl6_m_write;
output wire		fsl6_s_read;
input  wire		fsl7_s_control;
input  wire		fsl7_s_exists;
input  wire		fsl7_m_full;
output wire		fsl7_m_control;
output wire		fsl7_m_write;
output wire		fsl7_s_read;

input wire [31:0]	fsl0_s_data;
input wire [31:0]	fsl1_s_data;
input wire [31:0]	fsl2_s_data;
input wire [31:0]	fsl3_s_data;
input wire [31:0]	fsl4_s_data;
input wire [31:0]	fsl5_s_data;
input wire [31:0]	fsl6_s_data;
input wire [31:0]	fsl7_s_data;
output reg [31:0]	fsl0_m_data;
output reg [31:0]	fsl1_m_data;
output reg [31:0]	fsl2_m_data;
output reg [31:0]	fsl3_m_data;
output reg [31:0]	fsl4_m_data;
output reg [31:0]	fsl5_m_data;
output reg [31:0]	fsl6_m_data;
output reg [31:0]	fsl7_m_data;

//For FSL PC DEBUG
output	[31:0]	pc;
`endif

assign dmem_we = we_store_dly;
assign dmem_en = we_store_dly | we_load_dly;
assign dmem_addr = dmem_addr_internal;	// Change: Address is now byte-addressed

openfire_fetch	FETCH ( .stall(stall_fetch), .clock(clock), 
	.reset(reset), .branch_taken(branch_taken), 
	.pc_branch(pc_branch), .idata(imem_data_in), .imem_addr(imem_addr),
	.pc_decode(pc_decode), .instruction(instruction));

`ifdef FSL_LINK
assign pc = pc_exe_rf;	// Change: adjusted PC width to 32 bits
//assign fsl_m_data = {{(32-`D_WIDTH){1'b0}},regA}; // zero pad FSL to 32-bits
always @ (regA or fsl_number) begin
	fsl0_m_data = 0;
	fsl1_m_data = 0;
	fsl2_m_data = 0;
	fsl3_m_data = 0;
	fsl4_m_data = 0;
	fsl5_m_data = 0;
	fsl6_m_data = 0;
	fsl7_m_data = 0;

	case (fsl_number)
		0 : fsl0_m_data = regA;
		1 : fsl1_m_data = regA;
		2 : fsl2_m_data = regA;
		3 : fsl3_m_data = regA;
		4 : fsl4_m_data = regA;
		5 : fsl5_m_data = regA;
		6 : fsl6_m_data = regA;
		7 : fsl7_m_data = regA;
	endcase
end

openfire_decode	DECODE (.clock(clock), .stall(stall_decode), 
	.reset(reset), .pc_decode(pc_decode), .instruction(instruction), 
	.regA_addr(regA_addr), 
	.regB_addr(regB_addr), .regD_addr(regD_addr), 
	.immediate(immediate), .pc_exe(pc_exe_rf),	
	.alu_inputA_sel(alu_inputA_sel), .alu_inputB_sel(alu_inputB_sel), 
	.alu_inputC_sel(alu_inputC_sel), .alu_fns_sel(alu_fns_sel), 
	.comparator_fns_sel(comparator_fns_sel), .branch_instr(branch_instr),
	.we_alu_branch(we_alu_branch), .we_load(we_load), 
	.we_store(we_store), .regfile_input_sel(regfile_input_sel), 
	.dmem_input_sel(dmem_input_sel), .flush(flush), 
	.delay_bit(delay_bit), .update_carry(update_carry),
	.fsl_get(fsl_get), .fsl_control(fsl_control), 
	.fsl_blocking(fsl_blocking), .fsl_cmd_vld(fsl_cmd_vld),
	.fsl_number(fsl_number));
	
openfire_execute 	EXECUTE (.clock(clock), .reset(reset), 
	.stall(stall_exe), .immediate(immediate), 
	.pc_exe(pc_exe_rf), .alu_inputA_sel(alu_inputA_sel),
	.alu_inputB_sel(alu_inputB_sel), .alu_inputC_sel(alu_inputC_sel),
	.alu_fns_sel(alu_fns_sel), .comparator_fns_sel(comparator_fns_sel),	
	.we_load(we_load), .we_store(we_store), .update_carry(update_carry),
	.regA(regA), .regB(regB), .regD(regD), .alu_result(result),
        .pc_branch(pc_branch), .branch_taken(branch_taken), .dmem_input_sel(dmem_input_sel), 	
	.we_regfile(we_load_dly), .we_store_dly(we_store_dly), 
	.dmem_addr(dmem_addr_internal), .dmem_data_in(dmem_data_in),
	.dmem_data_out(dmem_data_out), .instr_complete(instr_complete),
	.byte_sel(byte_sel),
	.branch_instr(branch_instr), 
	.fsl_get(fsl_get), .fsl_cmd_vld(fsl_cmd_vld), .fsl_control(fsl_control), 
	.fsl_blocking(fsl_blocking), .fsl_number(fsl_number),

	.fsl0_s_control(fsl0_s_control),
	.fsl0_s_exists(fsl0_s_exists),
	.fsl0_m_full(fsl0_m_full), 
	.fsl0_m_control(fsl0_m_control), 
	.fsl0_m_write(fsl0_m_write), 
	.fsl0_s_read(fsl0_s_read), 
	.fsl1_s_control(fsl1_s_control),
	.fsl1_s_exists(fsl1_s_exists),
	.fsl1_m_full(fsl1_m_full), 
	.fsl1_m_control(fsl1_m_control), 
	.fsl1_m_write(fsl1_m_write), 
	.fsl1_s_read(fsl1_s_read), 
	.fsl2_s_control(fsl2_s_control),
	.fsl2_s_exists(fsl2_s_exists),
	.fsl2_m_full(fsl2_m_full), 
	.fsl2_m_control(fsl2_m_control), 
	.fsl2_m_write(fsl2_m_write), 
	.fsl2_s_read(fsl2_s_read), 
	.fsl3_s_control(fsl3_s_control),
	.fsl3_s_exists(fsl3_s_exists),
	.fsl3_m_full(fsl3_m_full), 
	.fsl3_m_control(fsl3_m_control), 
	.fsl3_m_write(fsl3_m_write), 
	.fsl3_s_read(fsl3_s_read), 
	.fsl4_s_control(fsl4_s_control),
	.fsl4_s_exists(fsl4_s_exists),
	.fsl4_m_full(fsl4_m_full), 
	.fsl4_m_control(fsl4_m_control), 
	.fsl4_m_write(fsl4_m_write), 
	.fsl4_s_read(fsl4_s_read), 
	.fsl5_s_control(fsl5_s_control),
	.fsl5_s_exists(fsl5_s_exists),
	.fsl5_m_full(fsl5_m_full), 
	.fsl5_m_control(fsl5_m_control), 
	.fsl5_m_write(fsl5_m_write), 
	.fsl5_s_read(fsl5_s_read), 
	.fsl6_s_control(fsl6_s_control),
	.fsl6_s_exists(fsl6_s_exists),
	.fsl6_m_full(fsl6_m_full), 
	.fsl6_m_control(fsl6_m_control), 
	.fsl6_m_write(fsl6_m_write), 
	.fsl6_s_read(fsl6_s_read), 
	.fsl7_s_control(fsl7_s_control),
	.fsl7_s_exists(fsl7_s_exists),
	.fsl7_m_full(fsl7_m_full), 
	.fsl7_m_control(fsl7_m_control), 
	.fsl7_m_write(fsl7_m_write), 
	.fsl7_s_read(fsl7_s_read) 
);
	
openfire_regfile 	REGFILE (.reset(reset), .clock(clock), .regA_addr(regA_addr),
	.regB_addr(regB_addr), .regD_addr(regD_addr), .result(result),
	.pc_regfile(pc_exe_rf), .dmem_data(dmem_data_in),
	.regfile_input_sel(regfile_input_sel), .we_load_dly(we_load_dly),
	.we_alu_branch(we_alu_branch), .regA(regA), .regB(regB), .regD(regD),
	.enable(~stall_exe), .dmem_addr_lsb(byte_sel), .fsl_number(fsl_number),
	.fsl0_s_data(fsl0_s_data),
	.fsl1_s_data(fsl1_s_data),
	.fsl2_s_data(fsl2_s_data),
	.fsl3_s_data(fsl3_s_data),
	.fsl4_s_data(fsl4_s_data),
	.fsl5_s_data(fsl5_s_data),
	.fsl6_s_data(fsl6_s_data),
	.fsl7_s_data(fsl7_s_data)
	);
`else
openfire_decode	DECODE (.clock(clock), .stall(stall_decode), 
	.reset(reset), .pc_decode(pc_decode), .instruction(instruction), 
	.regA_addr(regA_addr), 
	.regB_addr(regB_addr), .regD_addr(regD_addr), 
	.immediate(immediate), .pc_exe(pc_exe_rf),	
	.alu_inputA_sel(alu_inputA_sel), .alu_inputB_sel(alu_inputB_sel), 
	.alu_inputC_sel(alu_inputC_sel), .alu_fns_sel(alu_fns_sel), 
	.comparator_fns_sel(comparator_fns_sel), 
	.we_alu_branch(we_alu_branch), .we_load(we_load), 
	.we_store(we_store), .regfile_input_sel(regfile_input_sel), 
	.dmem_input_sel(dmem_input_sel), .flush(flush),  .branch_instr(branch_instr),
	.delay_bit(delay_bit), .update_carry(update_carry));
	
openfire_execute 	EXECUTE (.clock(clock), .reset(reset), 
	.stall(stall_exe), .immediate(immediate), 
	.pc_exe(pc_exe_rf), .alu_inputA_sel(alu_inputA_sel),
	.alu_inputB_sel(alu_inputB_sel), .alu_inputC_sel(alu_inputC_sel),
	.alu_fns_sel(alu_fns_sel), .comparator_fns_sel(comparator_fns_sel),	
	.we_load(we_load), .we_store(we_store), .update_carry(update_carry),
	.regA(regA), .regB(regB), .regD(regD), .alu_result(result), 
        .pc_branch(pc_branch), .branch_taken(branch_taken), .dmem_input_sel(dmem_input_sel), 	
	.we_regfile(we_load_dly), .we_store_dly(we_store_dly), .branch_instr(branch_instr),
	.dmem_addr(dmem_addr_internal), .dmem_data_in(dmem_data_in), .byte_sel(byte_sel),
	.dmem_data_out(dmem_data_out), .instr_complete(instr_complete));
	
openfire_regfile 	REGFILE (.reset(reset), .clock(clock), .regA_addr(regA_addr),
	.regB_addr(regB_addr), .regD_addr(regD_addr), .result(result),
	.pc_regfile(pc_exe_rf), .dmem_data(dmem_data_in),
	.regfile_input_sel(regfile_input_sel), .we_load_dly(we_load_dly),
	.we_alu_branch(we_alu_branch), .regA(regA), .regB(regB), .regD(regD),
	.enable(~stall_exe), .dmem_addr_lsb(byte_sel));
`endif

openfire_pipeline_ctrl PIPELINE (.clock(clock), .reset(reset), .stall(stall), .flush(flush),	
	.branch_taken(branch_taken), .instr_complete(instr_complete), .delay_bit(delay_bit),	
	.stall_fetch(stall_fetch), .stall_decode(stall_decode), .stall_exe(stall_exe));	
	
endmodule
