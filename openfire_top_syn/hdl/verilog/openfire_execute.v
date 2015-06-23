/*

MODULE: openfire_execute

DESCRIPTION: The execute module instantiates the alu and comparator and
updates the Machine Status Register (MSR).  This module produces a status
signal, instr_complete, when the currently executing instruction is finished.

TO DO:
- Add interrupt handling
- Add exception handling
- Complete MSR
- Add all other special registers: EAR, ESR, ESS
- Add OPB interface

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

Revision 0.3, 12/17/2005 SDC
Fixed PC size bug and CMP bug for case when both rA and rB are negative.

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
module openfire_execute (
	clock, reset, stall,					// top level
	immediate, pc_exe, alu_inputA_sel, alu_inputB_sel, 	// inputs
	alu_inputC_sel, alu_fns_sel, comparator_fns_sel, 	
	we_load, we_store, regA, dmem_input_sel,
	regB, regD, update_carry, dmem_data_in, branch_instr,
	fsl_number, fsl_cmd_vld, fsl_get, fsl_blocking, fsl_control,	//FSL
	alu_result, pc_branch, branch_taken, 			// outputs
	we_regfile, we_store_dly, dmem_addr,  
	dmem_data_out, instr_complete, byte_sel,
	fsl0_s_control, fsl0_s_exists, fsl0_m_full, fsl0_m_control, fsl0_m_write, fsl0_s_read,
	fsl1_s_control, fsl1_s_exists, fsl1_m_full, fsl1_m_control, fsl1_m_write, fsl1_s_read,
	fsl2_s_control, fsl2_s_exists, fsl2_m_full, fsl2_m_control, fsl2_m_write, fsl2_s_read,
	fsl3_s_control, fsl3_s_exists, fsl3_m_full, fsl3_m_control, fsl3_m_write, fsl3_s_read,
	fsl4_s_control, fsl4_s_exists, fsl4_m_full, fsl4_m_control, fsl4_m_write, fsl4_s_read,
	fsl5_s_control, fsl5_s_exists, fsl5_m_full, fsl5_m_control, fsl5_m_write, fsl5_s_read,
	fsl6_s_control, fsl6_s_exists, fsl6_m_full, fsl6_m_control, fsl6_m_write, fsl6_s_read,
	fsl7_s_control, fsl7_s_exists, fsl7_m_full, fsl7_m_control, fsl7_m_write, fsl7_s_read
	);
`else
module openfire_execute (
	clock, reset, stall,					// top level
	immediate, pc_exe, alu_inputA_sel, alu_inputB_sel, 	// inputs
	alu_inputC_sel, alu_fns_sel, comparator_fns_sel,	
	we_load, we_store, regA, dmem_input_sel,
	regB, regD, update_carry, dmem_data_in, branch_instr,
	alu_result, pc_branch, branch_taken, 			// outputs
	we_regfile, we_store_dly, dmem_addr, 
	dmem_data_out, instr_complete, byte_sel);
`endif
	
// From top level -- all active high unless otherwise noted
input		stall;
input		reset;
input		clock;

// From DECODE module
input	[`D_WIDTH-1:0]	immediate;
input	[`D_WIDTH-1:0]	pc_exe;			// pc for use by EXECUTE
input	[1:0]		alu_inputA_sel;
input	[1:0]		alu_inputB_sel;
input	[1:0]		alu_inputC_sel;
input	[3:0]		alu_fns_sel;
input	[2:0]		comparator_fns_sel;
input 			we_load;		// write_en for regfile on Load
input			we_store;		// write_en for DMEM on Store
input			update_carry;
input	[1:0]		dmem_input_sel;
input			branch_instr;

`ifdef FSL_LINK
//From Decode Logic
input			fsl_get;
input			fsl_control;
input			fsl_blocking;
input			fsl_cmd_vld;
input [2:0]		fsl_number;

//From FSL Ports
input  wire		fsl0_s_control;
input  wire		fsl0_s_exists;
input  wire		fsl0_m_full;
output reg		fsl0_m_control;
output reg		fsl0_m_write;
output reg		fsl0_s_read;

input  wire		fsl1_s_control;
input  wire		fsl1_s_exists;
input  wire		fsl1_m_full;
output reg		fsl1_m_control;
output reg		fsl1_m_write;
output reg		fsl1_s_read;

input  wire		fsl2_s_control;
input  wire		fsl2_s_exists;
input  wire		fsl2_m_full;
output reg		fsl2_m_control;
output reg		fsl2_m_write;
output reg		fsl2_s_read;

input  wire		fsl3_s_control;
input  wire		fsl3_s_exists;
input  wire		fsl3_m_full;
output reg		fsl3_m_control;
output reg		fsl3_m_write;
output reg		fsl3_s_read;

input  wire		fsl4_s_control;
input  wire		fsl4_s_exists;
input  wire		fsl4_m_full;
output reg		fsl4_m_control;
output reg		fsl4_m_write;
output reg		fsl4_s_read;

input  wire		fsl5_s_control;
input  wire		fsl5_s_exists;
input  wire		fsl5_m_full;
output reg		fsl5_m_control;
output reg		fsl5_m_write;
output reg		fsl5_s_read;

input  wire		fsl6_s_control;
input  wire		fsl6_s_exists;
input  wire		fsl6_m_full;
output reg		fsl6_m_control;
output reg		fsl6_m_write;
output reg		fsl6_s_read;

input  wire		fsl7_s_control;
input  wire		fsl7_s_exists;
input  wire		fsl7_m_full;
output reg		fsl7_m_control;
output reg		fsl7_m_write;
output reg		fsl7_s_read;

//Internal
reg			fsl_complete;

//Internal, Assigned to fsl[fsl_number]
reg			fsl_s_control;
reg			fsl_s_exists;
reg			fsl_m_full;

reg			fsl_m_control;
reg			fsl_m_write;
reg			fsl_s_read;

always @ (fsl_number or fsl0_s_control or fsl0_s_exists or fsl0_m_full or
						fsl1_s_control or fsl1_s_exists or fsl1_m_full or
						fsl2_s_control or fsl2_s_exists or fsl2_m_full or
						fsl3_s_control or fsl3_s_exists or fsl3_m_full or
						fsl4_s_control or fsl4_s_exists or fsl4_m_full or
						fsl5_s_control or fsl5_s_exists or fsl5_m_full or
						fsl6_s_control or fsl6_s_exists or fsl6_m_full or
						fsl7_s_control or fsl7_s_exists or fsl7_m_full  ) begin 
			
	fsl0_m_control= 0;
	fsl0_m_write  = 0;
	fsl0_s_read   = 0;
	fsl1_m_control= 0;
	fsl1_m_write  = 0;
	fsl1_s_read   = 0;
	fsl2_m_control= 0;
	fsl2_m_write  = 0;
	fsl2_s_read   = 0;
	fsl3_m_control= 0;
	fsl3_m_write  = 0;
	fsl3_s_read   = 0;
	fsl4_m_control= 0;
	fsl4_m_write  = 0;
	fsl4_s_read   = 0;
	fsl5_m_control= 0;
	fsl5_m_write  = 0;
	fsl5_s_read   = 0;
	fsl6_m_control= 0;
	fsl6_m_write  = 0;
	fsl6_s_read   = 0;
	fsl7_m_control= 0;
	fsl7_m_write  = 0;
	fsl7_s_read   = 0;

	case (fsl_number)
		0 : begin
			fsl_s_control = fsl0_s_control;
			fsl_s_exists  = fsl0_s_exists;
			fsl_m_full    = fsl0_m_full;
			fsl0_m_control= fsl_m_control;
			fsl0_m_write  = fsl_m_write;
			fsl0_s_read   = fsl_s_read;
		end
		1 : begin
			fsl_s_control = fsl1_s_control;
			fsl_s_exists  = fsl1_s_exists;
			fsl_m_full    = fsl1_m_full;
			fsl1_m_control= fsl_m_control;
			fsl1_m_write  = fsl_m_write;
			fsl1_s_read   = fsl_s_read;
		end
		2 : begin
			fsl_s_control = fsl2_s_control;
			fsl_s_exists  = fsl2_s_exists;
			fsl_m_full    = fsl2_m_full;
			fsl2_m_control= fsl_m_control;
			fsl2_m_write  = fsl_m_write;
			fsl2_s_read   = fsl_s_read;
		end
		3 : begin
			fsl_s_control = fsl3_s_control;
			fsl_s_exists  = fsl3_s_exists;
			fsl_m_full    = fsl3_m_full;
			fsl3_m_control= fsl_m_control;
			fsl3_m_write  = fsl_m_write;
			fsl3_s_read   = fsl_s_read;
		end
		4 : begin
			fsl_s_control = fsl4_s_control;
			fsl_s_exists  = fsl4_s_exists;
			fsl_m_full    = fsl4_m_full;
			fsl4_m_control= fsl_m_control;
			fsl4_m_write  = fsl_m_write;
			fsl4_s_read   = fsl_s_read;
		end
		5 : begin
			fsl_s_control = fsl5_s_control;
			fsl_s_exists  = fsl5_s_exists;
			fsl_m_full    = fsl5_m_full;
			fsl5_m_control= fsl_m_control;
			fsl5_m_write  = fsl_m_write;
			fsl5_s_read   = fsl_s_read;
		end
		6 : begin
			fsl_s_control = fsl6_s_control;
			fsl_s_exists  = fsl6_s_exists;
			fsl_m_full    = fsl6_m_full;
			fsl6_m_control= fsl_m_control;
			fsl6_m_write  = fsl_m_write;
			fsl6_s_read   = fsl_s_read;
		end
		7 : begin
			fsl_s_control = fsl7_s_control;
			fsl_s_exists  = fsl7_s_exists;
			fsl_m_full    = fsl7_m_full;
			fsl7_m_control= fsl_m_control;
			fsl7_m_write  = fsl_m_write;
			fsl7_s_read   = fsl_s_read;
		end
		default : begin	// pointless b/c fsl_number only has 3 bits
			fsl_s_control = 0;
			fsl_s_exists  = 0;
			fsl_m_full    = 0;
		end
	endcase
end

`endif

// From REGFILE
input	[`D_WIDTH-1:0]	regA;
input	[`D_WIDTH-1:0]	regB;
input	[`D_WIDTH-1:0]	regD;

// From Data MEM
input	[31:0]		dmem_data_in;

output	[`D_WIDTH-1:0]	alu_result;
output	[`D_WIDTH-1:0]	pc_branch;
output			branch_taken;
output			we_regfile;	// delayed versions for we for loads & stores
output			we_store_dly;	// load/store is a 2-cycle operation
output	[31:0]		dmem_addr;
output	[31:0]		dmem_data_out;
output			instr_complete;	// status of execution, active high
output	[1:0]		byte_sel;

// register all outputs EXCEPT:
//	- branch_taken and pc_branch -- registered in FETCH
//	- alu_result -- REGFILE registers
//	- dmem_addr -- DMEM registers
//	- instr_complete -- needed before rise of clock by PIPLINE_CTRL
reg			we_load_dly;
reg			we_store_dly;
reg	[31:0]		dmem_data_out;
reg	[1:0]		byte_sel;

// internal registers
reg	[31:0]		MSR;		// not implemented yet EXCEPT for C bit
reg	[`D_WIDTH-1:0]	alu_a_input;
reg	[`D_WIDTH-1:0]	alu_b_input;
reg			alu_c_input;
reg			MSB_signed_compare;

wire			alu_multicycle_instr;
wire			alu_multicycle_instr_complete;
wire			multicycle_instr;
wire			multicycle_instr_complete;
wire			c_out;
wire			compare_out;
wire	[`D_WIDTH-1:0]	alu_out_internal;
wire	[`D_WIDTH-1:0]	extended_pc;	// PC with leading zeros addded

assign branch_taken = branch_instr ? compare_out : 0;
assign pc_branch = alu_out_internal;	// ALU calculates next instr address

// instr_complete is always high EXCEPT for load / store instructions and optional MUL (alu_multicycle_instr)
// all other instructions currently implemented are single-cycle execution

// instr_complete is low when we_load / we_store is asserted UNLESS the delayed version
//	is also high... this is because DECODE stalls during a load / store
//	and therefore cannot lower we_load / we_store
`ifdef	FSL_LINK
assign multicycle_instr = we_load | we_store | fsl_cmd_vld | alu_multicycle_instr;
assign multicycle_instr_complete = we_load_dly | we_store_dly | fsl_complete | alu_multicycle_instr_complete;
`else
assign multicycle_instr = we_load | we_store | alu_multicycle_instr;
assign multicycle_instr_complete = we_load_dly | we_store_dly | alu_multicycle_instr_complete;
`endif
assign instr_complete = ~multicycle_instr | multicycle_instr_complete;

assign we_regfile = we_load_dly | alu_multicycle_instr_complete;

// for CMP/CMPU
// use comparator output for CMPU
// use ALU output for CMP -- signed comparison result is a function of input signs and output sign
assign alu_result[`D_WIDTH-1] = (alu_fns_sel == `ALU_compare_uns) ? compare_out :
			(alu_fns_sel == `ALU_compare) ?  MSB_signed_compare :
			alu_out_internal[`D_WIDTH-1];
assign alu_result[`D_WIDTH-2:0] = alu_out_internal[`D_WIDTH-2:0];

always@(regA[`D_WIDTH-1] or regB[`D_WIDTH-1] or alu_out_internal[`D_WIDTH-1])
begin
	case ({regB[`D_WIDTH-1], regA[`D_WIDTH-1]})	// look at signs of input numbers
	2'b00: MSB_signed_compare <= alu_out_internal[`D_WIDTH-1];	// both inputs positive
	2'b01: MSB_signed_compare <= 0;			// A is negative, B is positive => B is greater
	2'b10: MSB_signed_compare <= 1;			// B is negative, A is positive => A is greater
	2'b11: MSB_signed_compare <= alu_out_internal[`D_WIDTH-1];	// both inputs negative
	endcase
end

// extend PC to datapath width to store in Reg File (extension no longer
// required - ARM).
assign extended_pc = pc_exe;


// Stateful logic to handle multi-cycle instructions
always@(posedge clock)
begin
	if(reset)
		begin
			byte_sel			<= 0;
			we_load_dly			<= 0;
			we_store_dly		<= 0;
			MSR					<= 0;
`ifdef	FSL_LINK
			fsl_complete		<= 0;
			fsl_m_write 		<= 0;
			fsl_s_read			<= 0;			
`endif
		end
	else if (~stall)
		begin
			byte_sel		<= dmem_addr[1:0];
			
			// Update Carry Bit in Status Register
			if ((alu_fns_sel == `ALU_add) & update_carry)
				MSR[2]		<= c_out;			
			if ((alu_fns_sel == `ALU_shiftR_arth) | (alu_fns_sel == `ALU_shiftR_log) | 
				(alu_fns_sel == `ALU_shiftR_c))
				MSR[2]		<= regA[0];
				
		// TBD - SHOULD THIS REALLY STILL BE 2 STATEMENTS?
		// WAS ONE STATEMENT ORIGINALLY!
			if (we_load & we_load_dly)
				we_load_dly <= 0;
			else
				we_load_dly <= we_load;

			if (we_store & we_store_dly)
				we_store_dly <= 0;
			else
				we_store_dly <= we_store;

			// We have completed a Load / Store Instruction and been issued another one
/*			if ((we_load & we_load_dly) | (we_store & we_store_dly))
				begin
					we_load_dly 	<= 0;
					we_store_dly 	<= 0;
				end
			else
				begin
					we_store_dly	<= we_store;
					we_load_dly	<= we_load;
				end*/
`ifdef FSL_LINK
			// FSL get & put commands
			// Reset control signals after write / read
			if ((fsl_cmd_vld & fsl_complete) | ~fsl_cmd_vld)
				begin
					fsl_s_read	<= 0;
					fsl_complete	<= 0;
					fsl_m_write	<= 0;
				end
			else if (fsl_cmd_vld & ~fsl_get & ~fsl_blocking) // nonblocking put
				begin
					fsl_complete 	<= 1;
					MSR[2] 		<= fsl_m_full;
					if (~fsl_m_full)
						begin
							fsl_m_write 	<= 1;
							fsl_m_control 	<= fsl_control;
						end
				end
			else if (fsl_cmd_vld & fsl_get & ~fsl_blocking) // nonblocking get
				begin
					fsl_complete 	<= 1;
					fsl_s_read 	<= 1;
					MSR[2] <= ~fsl_s_exists;
					if (fsl_s_exists)
						we_load_dly <= 1;
					if (fsl_s_control == fsl_control)
						MSR[4] 	<= 0;	// MSR[4] = FSL_Error bit
					else
						MSR[4] 	<= 1;
				end
			else if (fsl_cmd_vld & ~fsl_get & ~fsl_m_full & fsl_blocking) // blocking put
				begin
					fsl_complete 	<= 1;
					fsl_m_write 	<= 1;
					fsl_m_control 	<= fsl_control;
				end
			else if (fsl_cmd_vld & fsl_get & fsl_s_exists & fsl_blocking) // blocking get
				begin
					fsl_complete 	<= 1;
					we_load_dly 	<= 1;
					fsl_s_read	<= 1;
					if (fsl_s_control == fsl_control)
						MSR[4] 	<= 0;
					else
						MSR[4] 	<= 1;
				end
`endif // End FSL extensions
		end // end elseif (~stall)
end // always@

/**************************
 * Module input selectors *
 **************************/
always@(alu_inputA_sel or extended_pc or regA)
begin
	case(alu_inputA_sel)
	`aluA_ra:	alu_a_input <= regA;
	`aluA_ra_bar:	alu_a_input <= ~regA;
	`aluA_pc:	alu_a_input <= extended_pc;
	`aluA_zero:	alu_a_input <= 0;
	endcase
end // always @ ALU_input_A

always@(alu_inputB_sel or immediate or regB)
begin
	case(alu_inputB_sel)
	`aluB_rb:	alu_b_input <= regB;
	`aluB_imm:	alu_b_input <= immediate;
	`aluB_rb_bar:	alu_b_input <= ~regB;
	`aluB_imm_bar:	alu_b_input <= ~immediate;
	endcase
end // always @ ALU_input_B

always@(alu_inputC_sel or MSR)
begin
	case(alu_inputC_sel)
	`aluC_zero:	alu_c_input <= 1'b0;
	`aluC_one:	alu_c_input <= 1'b1;
	`aluC_carry:	alu_c_input <= MSR[2];
	default:	
		begin	// for simulation
			$display("ERROR! Illegal ALU Input Selection! PC %x", pc_exe);
			alu_c_input <= 1'b0;
		end
	endcase
end // always @ ALU_input_C

// Data MEM input selection
`ifdef DATAPATH_32
always@(dmem_data_in or dmem_input_sel or regD or dmem_addr[1:0] or we_store_dly)
begin
	case(dmem_input_sel)
	2'b00:	// Byte Store	
		case(dmem_addr[1:0])
		2'b00:	dmem_data_out <= {regD[7:0], dmem_data_in[23:0]};
		2'b01:  dmem_data_out <= {dmem_data_in[31:24], regD[7:0], dmem_data_in[15:0]};
		2'b10:  dmem_data_out <= {dmem_data_in[31:16], regD[7:0], dmem_data_in[7:0]};
		2'b11:  dmem_data_out <= {dmem_data_in[31:8], regD[7:0]};
		endcase
	2'b01:	// Halfword Store
		case(dmem_addr[1:0])
		2'b00:	dmem_data_out <= {regD[15:0], dmem_data_in[15:0]};
		2'b10:  dmem_data_out <= {dmem_data_in[31:16], regD[15:0]};
		default:
			begin
				dmem_data_out <= {regD[15:0], dmem_data_in[15:0]};
				if(we_store_dly) $display("ERROR! Unaligned Halfword Store at pc %x", pc_exe);
			end
		endcase	
	2'b10:	// Word Store
		case(dmem_addr[1:0])
		2'b00:	dmem_data_out <= regD;
		default:
			begin
				dmem_data_out <= regD;
				if(we_store_dly) $display("ERROR! Unaligned Word Store at pc %x", pc_exe);
			end
		endcase		
	default:	
		begin
			if(we_store_dly) $display("ERROR! Illegal Word Size Selection! PC %x", pc_exe);
			dmem_data_out <= 0;
		end
	endcase
end
`else // 16-bit datapath
// Currently 16-bit datapath interfaces with a 32-bit memory
always@(dmem_data_in or dmem_input_sel or regD or dmem_addr[1:0] or we_store_dly)
begin
	case(dmem_input_sel)
	2'b00:	// Byte Store	
		case(dmem_addr[1:0])
		2'b00:	dmem_data_out <= {regD[7:0], dmem_data_in[23:0]};
		2'b01:  dmem_data_out <= {dmem_data_in[31:24], regD[7:0], dmem_data_in[15:0]};
		2'b10:  dmem_data_out <= {dmem_data_in[31:16], regD[7:0], dmem_data_in[7:0]};
		2'b11:  dmem_data_out <= {dmem_data_in[31:8], regD[7:0]};
		endcase
	2'b01:	// Halfword Store
		case(dmem_addr[1:0])
		2'b00:	dmem_data_out <= {regD[15:0], dmem_data_in[15:0]};
		2'b10:  dmem_data_out <= {dmem_data_in[31:16], regD[15:0]};
		default:
			begin
				dmem_data_out <= {regD[15:0], dmem_data_in[15:0]};
				if(we_store_dly) $display("ERROR! Unaligned Halfword Store at pc %x", pc_exe);
			end
		endcase	
	2'b10:	// Word Store
		case(dmem_addr[1:0])
		2'b00:	dmem_data_out <= {16'b0, regD[15:0]};
		default:
			begin
				dmem_data_out <= regD;
				if(we_store_dly) $display("ERROR! Unaligned Word Store at pc %x", pc_exe);
			end
		endcase		
	default:	
		begin
			if(we_store_dly) $display("ERROR! Illegal Word Size Selection! PC %x", pc_exe);
			dmem_data_out <= 0;
		end
	endcase
end
`endif

// Instantiate ALU and comparator
openfire_alu	ALU0 (.clock(clock), .reset(reset), .stall(stall),
			.a(alu_a_input), .b(alu_b_input), .c_in(alu_c_input), .fns(alu_fns_sel),
			.alu_result(alu_out_internal), .c_out(c_out),
			.alu_multicycle_instr(alu_multicycle_instr), .dmem_addr(dmem_addr),
			.alu_multicycle_instr_complete(alu_multicycle_instr_complete));
// comparator used only for branches (and optional CMPU instruction)
// DECODE unit forces COMPARE output high for unconditional branchs by selecting a 1 output
//	with comparator_fns_sel
openfire_compare	CMP0 (.in0(regA), .in1(regB), .out(compare_out), .fns(comparator_fns_sel));

endmodule
