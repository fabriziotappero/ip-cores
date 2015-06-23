/*	MODULE: openfire_execute

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

Revision 0.4  27/03/2007 Antonio J. Anton
Memory handshaking protocol
Removed memory read/write alignment code
Interrupt handling
Exception handling
MSR register handling

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

module openfire_execute (
`ifdef ENABLE_MSR_BIP
	update_msr_bip, value_msr_bip,
`endif
`ifdef ENABLE_INTERRUPTS
	interrupt, int_ip, int_dc, set_msr_ie,
`endif
`ifdef ENABLE_MSR_OPCODES
	rS_update,
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
	opcode_exception,
`endif
`ifdef ENABLE_EXCEPTIONS
	reset_msr_eip,
`endif
`ifdef ENABLE_ALIGNMENT_EXCEPTION
	dmem_alignment_exception,
`endif
`ifdef FSL_LINK
	fsl_m_control, fsl_m_write, fsl_s_read,
	fsl_cmd_vld, fsl_get, fsl_blocking, fsl_control,	//FSL
	fsl_m_full, fsl_s_control, fsl_s_exists,
`endif
	clock, reset, stall,											// top level
	immediate, pc_exe, alu_inputA_sel, alu_inputB_sel, // inputs
	alu_inputC_sel, alu_fns_sel, comparator_fns_sel,	
	we_load, we_store, regA,
	regB, regD, update_carry, branch_instr,
	alu_result, pc_branch, branch_taken, 					// outputs
	we_regfile, dmem_addr, 
	dmem_data_out, instr_complete, dmem_done,
	dmem_we, dmem_re
);
	
// From top level -- all active high unless otherwise noted
input		stall;
input		reset;
input		clock;

// From DECODE module
input	[31:0]	immediate;
input	[`A_SPACE+1:0]	pc_exe;			// pc for use by EXECUTE
input	[2:0]		alu_inputA_sel;
input	[1:0]		alu_inputB_sel;
input	[1:0]		alu_inputC_sel;
input	[3:0]		alu_fns_sel;
input	[2:0]		comparator_fns_sel;
input 			we_load;					// write_en for regfile on Load
input				we_store;				// we on DMEM on Store
input				update_carry;
input				branch_instr;
input				dmem_done;
output			dmem_re;
output			dmem_we;
`ifdef ENABLE_MSR_BIP
input				update_msr_bip;
input				value_msr_bip;
`endif
`ifdef ENABLE_INTERRUPTS
input				interrupt;
output			int_ip;
input			   int_dc;
input			   set_msr_ie;
`endif
`ifdef ENABLE_MSR_OPCODES
input				rS_update;
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
input			  	opcode_exception;
`endif
`ifdef ENABLE_EXCEPTIONS
input				reset_msr_eip;
output			insert_exception;
`endif
`ifdef ENABLE_ALIGNMENT_EXCEPTION
input				dmem_alignment_exception;
`endif
`ifdef FSL_LINK
input			fsl_get;
input			fsl_control;
input			fsl_blocking;
input			fsl_cmd_vld;
input			fsl_s_control;		//From FSL
input			fsl_s_exists;
input			fsl_m_full;
output		fsl_m_control;
output		fsl_m_write;
output		fsl_s_read;
`endif

// From REGFILE
input	[31:0]	regA;
input	[31:0]	regB;
input	[31:0]	regD;

output	[31:0]	alu_result;
output	[`A_SPACE+1:0]	pc_branch;
output				branch_taken;
output				we_regfile;			// we for load and alu
output	[31:0]	dmem_addr;
output	[31:0]	dmem_data_out;
output				instr_complete;	// status of execution, active high

// register all outputs EXCEPT:
//	- branch_taken and pc_branch -- registered in FETCH
//	- alu_result -- REGFILE registers
//	- dmem_addr -- DMEM registers
//	- instr_complete -- needed before rise of clock by PIPLINE_CTRL
assign dmem_data_out = regD;

// internal registers
reg	[31:0]	MSR;				// **TODO** Working: C, BIP, IE
reg	[31:0]	alu_a_input;
reg	[31:0]	alu_b_input;
reg				alu_c_input;
reg				MSB_signed_compare;

`ifdef FSL_LINK
reg			fsl_complete;
reg			fsl_m_write;
reg			fsl_s_read;
reg			fsl_m_control;
`endif

wire			alu_multicycle_instr;
wire			alu_multicycle_instr_complete;
wire			multicycle_instr;
wire			multicycle_instr_complete;
wire			c_out;
wire			compare_out;
wire [31:0]	alu_out_internal;
wire [31:0]	extended_pc;	// PC with leading zeros addded

`ifdef ENABLE_EXCEPTIONS
reg			insert_exception;			// to ask DECODE to insert "brali r17,0x20"
wire			exception = 				// 1 if any exception happened
`ifdef ENABLE_ALIGNMENT_EXCEPTION
								dmem_alignment_exception |
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
								opcode_exception |
`endif
								0;
`endif

`ifdef ENABLE_INTERRUPTS
// this code is to signal an interrupt when interrupts are enabled (MSR[IE]=1)
reg	int_requested;
always @(interrupt or MSR[`MSR_IE])				// if interrupt == 1, then raise a request for
begin														// clear the request based on clear_interrupt
  if(interrupt && MSR[`MSR_IE])	int_requested <= 1;
  else if(!MSR[`MSR_IE]) 			int_requested <= 0;
end

reg	 int_ip;											// interrupt in progress
wire	 can_interrupt  = 							// cpu can be interrupted if...
`ifdef ENABLE_EXCEPTION
						   ~MSR[`MSR_EIP] &			// no Exception in Progress
`endif
`ifdef ENABLE_MSR_BIP
							~MSR[`MSR_BIP] & 			// no Break in Progress
`endif
							(~int_ip | set_msr_ie);	// not interrupt in progress 
`endif													// and interrupts are enabled

assign branch_taken  = branch_instr ? compare_out : 0;
assign pc_branch     = alu_out_internal[`A_SPACE+1:0];	// ALU calculates next instr address

// instr_complete is always high EXCEPT for optional MUL (alu_multicycle_instr)
// all other instructions currently implemented are single-cycle execution except
// load / store that are multicycle (controlled by dmem_done)
// also re/we enable are only valid if EXECUTE is not stalled
assign dmem_we							= we_store & ~stall;
assign dmem_re							= we_load  & ~stall;

assign memory_instr					= we_load | we_store;
assign memory_instr_complete		= memory_instr & dmem_done;

assign multicycle_instr 			= 
`ifdef FSL_LINK
												fsl_cmd_vld |
`endif
												memory_instr | alu_multicycle_instr;
assign multicycle_instr_complete = 
`ifdef FSL_LINK
												fsl_complete |
`endif
												memory_instr_complete | alu_multicycle_instr_complete;

assign instr_complete 				= ~multicycle_instr | multicycle_instr_complete;
assign we_regfile 					= (we_load & dmem_done) | alu_multicycle_instr_complete;

// for CMP/CMPU
// use comparator output for CMPU
// use ALU output for CMP -- signed comparison result is a function of input signs and output sign
assign alu_result[31] = (alu_fns_sel == `ALU_compare_uns) ? compare_out :
			(alu_fns_sel == `ALU_compare) ?  MSB_signed_compare :
			alu_out_internal[31];
assign alu_result[30:0] = alu_out_internal[30:0];

always@(regA[31] or regB[31] or alu_out_internal[31])
begin
	case ({regB[31], regA[31]})	// look at signs of input numbers
	2'b00: MSB_signed_compare <= alu_out_internal[31];	// both inputs positive
	2'b01: MSB_signed_compare <= 0;			// A is negative, B is positive => B is greater
	2'b10: MSB_signed_compare <= 1;			// B is negative, A is positive => A is greater
	2'b11: MSB_signed_compare <= alu_out_internal[31];	// both inputs negative
	endcase
end

// extend PC to datapath width to store in Reg File
assign extended_pc[31:`A_SPACE+2] = 0;
assign extended_pc[`A_SPACE+1:0]  = pc_exe;

// Stateful logic to handle multi-cycle instructions
always@(posedge clock)
begin
	if(reset)
		begin
			MSR[`MSR_C]		<= 0;		// Carry
`ifdef ENABLE_INTERRUPTS
		   int_ip			<= 0;
			MSR[`MSR_IE]	<= 1;		// Interrupt Enable
`endif
`ifdef ENABLE_EXCEPTIONS
			insert_exception <= 0;
			MSR[`MSR_E_Ena]  <= 1;	// Enable Exceptions
			MSR[`MSR_EIP]	  <= 0;	// Exception in Progress
`endif
`ifdef ENABLE_MSR_BIP
		   MSR[`MSR_BIP`]	  <= 0;	// Break In Progress
`endif
`ifdef	FSL_LINK
			fsl_complete	<= 0;
			fsl_m_write 	<= 0;
			fsl_s_read		<= 0;			
`endif
		end
	else if (~stall)
		begin
			// Update MSR[BIP] due to BREAK / RTBD
`ifdef ENABLE_MSR_BIP
			if(update_msr_bip) MSR[`MSR_BIP] 	<= value_msr_bip;
`endif
`ifdef ENABLE_INTERRUPTS
			if(int_requested & can_interrupt)	// interrupt requested and cpu can be interrupted?
			begin
			   MSR[`MSR_IE] <= 0;			// disable further interrupts
				int_ip		 <= 1;			// ask DECODE to insert "brali r14,0x10" asap
			end
			else if(int_ip & int_dc)		// if DECODE completed the instruction insert
			   int_ip 		 <= 0;			// finish interrupt in progress
			if(set_msr_ie) MSR[`MSR_IE] <= 1;		// decode asks to enable interrupts again
`endif
`ifdef ENABLE_EXCEPTIONS
			/* TODO: exceptions handling ---
					r17 		<- PC
					PC			<- 0x20
					MSR[EE] 	<- 0
					MSR[EIP] <- 1
					ESR[DS]	<- exception in delay slot
					ESR[EC]  <- exception specific value
					ESR[ESS] <- exception specific value
					EAR 		<- exception specific value
					FSR 		<- exception specific value
			*/
			if(reset_msr_eip)			// return from an exception handler
			begin
			 MSR[`MSR_EIP] 	<= 0;	// disable EIP flag due to rted opcode
			 MSR[`MSR_E_Ena] 	<= 1;	// enable exceptions agains
			 // ESR <- 0				// reset exception cause
			end
`endif
			`ifdef ENABLE_MSR_OPCODES
			if(rS_update) MSR <= regA;	// mts instruction
			`endif
			// Update Carry Bit in Status Register
			if ((alu_fns_sel == `ALU_add) & update_carry)
				MSR[`MSR_C]	<= c_out;			
			if ((alu_fns_sel == `ALU_shiftR_arth) | (alu_fns_sel == `ALU_shiftR_log) | 
				(alu_fns_sel == `ALU_shiftR_c))
				MSR[`MSR_C]	<= regA[0];
`ifdef FSL_LINK
			// FSL get & put commands
			// Reset control signals after write / read
			if ((fsl_cmd_vld & fsl_complete) | ~fsl_cmd_vld)
				begin
					fsl_s_read		<= 0;
					fsl_complete	<= 0;
					fsl_m_write		<= 0;
				end
			else if (fsl_cmd_vld & ~fsl_get & ~fsl_blocking) // nonblocking put
				begin
					fsl_complete 	<= 1;
					MSR[`MSR_C]		<= fsl_m_full;		//**CHECK**
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
					MSR[`MSR_C] <= ~fsl_s_exists;		//**CHECK**
					if (fsl_s_exists)
						we_load_dly <= 1;
					if (fsl_s_control == fsl_control)
						MSR[`MSR_FSL_Err]	<= 0;	// MSR[4] = FSL_Error bit
					else
						MSR[`MSR_FSL_Err]	<= 1;
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
						MSR[`MSR_FSL_Err]	<= 0;
					else
						MSR[`MSR_FSL_Err]	<= 1;
				end
`endif // End FSL extensions				
`ifdef DEBUG_EXECUTE
		$display("EXECUTE: pc_exe=%x", pc_exe);
`endif
		end // end elseif (~stall)
end // always@

/**************************
 * Module input selectors *
 **************************/
always@(
`ifdef ENABLE_MSR_OPCODES
	MSR or
`endif
	alu_inputA_sel or extended_pc or regA
)
begin
	case(alu_inputA_sel)
	`aluA_ra:		alu_a_input <= regA;
	`aluA_ra_bar:	alu_a_input <= ~regA;
	`aluA_pc:		alu_a_input <= extended_pc;
	`aluA_zero:		alu_a_input <= 0;
`ifdef ENABLE_MSR_OPCODES
	`aluA_msr:		alu_a_input	<= MSR;	// msr instruction feed to regfile via ALU
`endif
	endcase
end // always @ ALU_input_A

always@(alu_inputB_sel or immediate or regB)
begin
	case(alu_inputB_sel)
	`aluB_rb:		alu_b_input <= regB;
	`aluB_imm:		alu_b_input <= immediate;
	`aluB_rb_bar:	alu_b_input <= ~regB;
	`aluB_imm_bar:	alu_b_input <= ~immediate;
	endcase
end // always @ ALU_input_B

always@(alu_inputC_sel or MSR)
begin
	case(alu_inputC_sel)
	`aluC_zero:		alu_c_input <= 1'b0;
	`aluC_one:		alu_c_input <= 1'b1;
	`aluC_carry:	alu_c_input <= MSR[`MSR_C];
	default:	
		begin	// for simulation
			$display("ERROR! Illegal ALU Input Selection! PC %x", pc_exe);
			alu_c_input <= 1'b0;
		end
	endcase
end // always @ ALU_input_C

// Instantiate ALU and comparator
openfire_alu	ALU0 (
	.clock(clock), 
	.reset(reset), 
	.stall(stall),
	.a(alu_a_input), 
	.b(alu_b_input), 
	.c_in(alu_c_input), 
	.fns(alu_fns_sel),
	.alu_result(alu_out_internal), 
	.c_out(c_out),
	.alu_multicycle_instr(alu_multicycle_instr), 
	.dmem_addr(dmem_addr),
	.alu_multicycle_instr_complete(alu_multicycle_instr_complete)
);
// comparator used only for branches (and optional CMPU instruction)
// DECODE unit forces COMPARE output high for unconditional branchs by selecting a 1 output
//	with comparator_fns_sel
openfire_compare	CMP0 (
	.in0(regA), 
	.in1(regB), 
	.out(compare_out), 
	.fns(comparator_fns_sel)
);

endmodule
