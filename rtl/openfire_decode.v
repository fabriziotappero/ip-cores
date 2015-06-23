/*	MODULE: openfire_decode

	DESCRIPTION: The decode module received the instruction from the fetch module
and produces all control signals needed by the execute stage and the register
file.  In the case of IMM instructions, the decode module will stall the
execute module by issuing a NoOp instruction.

The COMPARE module is used for calculating if a branch is taken and CMPU
ops if support is selected.  The DECODE module commands the comparator to output 
a 1 for unconditional branchs and a 0 for all other non-branch instructions (other
than CMPU)..

While FSL instructions are optionally implemented (if FSL_LINK is defined),
only one link (FSL0) is currently supported.

MISSING INSTRUCTIONS:
- special register instruction: MSRCLR, MSRSET
- all instructions requiring extra hardware, except for optional multiply: IDIV, BS
- cache-related instruction: WDC, WIC

TO DO:
- Complete instruction set
- Simplify instruction extension

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

Revision 0.4, 15/03/2007 SDC
Fixed  CMP[U] with IMM bit 

Revision 0.5  27/03/2007 Antonio J. Anton
Handling of interrupts/exceptions
MSR opcodes (mfs, mts)

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
SOFTWARE. */

`include "openfire_define.v"

module openfire_decode(
`ifdef ENABLE_MSR_BIP
	update_msr_bip, value_msr_bip,
`endif
`ifdef ENABLE_INTERRUPTS
	int_ip, int_dc, set_msr_ie,
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
	opcode_exception,
`endif
`ifdef ENABLE_EXCEPTIONS
	reset_msr_eip, insert_exception,
`endif
`ifdef ENABLE_MSR_OPCODES
	rS_update,
`endif
`ifdef FSL_LINK
	fsl_get, fsl_control, fsl_blocking, fsl_cmd_vld,	// fsl signals
`endif
	clock, stall, reset,											// top level
	pc_decode, instruction, flush,							// inputs
	regA_addr, regB_addr, regD_addr, immediate, 			// outputs
	alu_inputA_sel, alu_inputB_sel, alu_inputC_sel, 
	alu_fns_sel, comparator_fns_sel, branch_instr,
	we_alu_branch, we_load, we_store, regfile_input_sel, 
	dmem_input_sel, delay_bit, update_carry, pc_exe
);

// From top level -- all active high unless otherwise noted
input		stall;
input		reset;
input		clock;

// From DECODE module
input	[`A_SPACE+1:0]	pc_decode;
input	[31:0]			instruction;

// From Pipeline Controller
input					flush;		// a branch was taken... flush the pipeline

output	[4:0]		regA_addr;
output	[4:0]		regB_addr;
output	[4:0]		regD_addr;
output	[31:0]	immediate;
output	[`A_SPACE+1:0]	pc_exe;			// pc for use by EXECUTE
output	[2:0]		alu_inputA_sel;
output	[1:0]		alu_inputB_sel;
output	[1:0]		alu_inputC_sel;
output	[3:0]		alu_fns_sel;
output	[2:0]		comparator_fns_sel;
output 				we_load;					// write_en for regfile on Load
output				we_store;				// write_en for DMEM
output				we_alu_branch;			// write_en for regfile on ALU / Branch instr
output	[3:0]		regfile_input_sel;	// selects input to regfile
output	[1:0]		dmem_input_sel;		// selects input to DMEM
output				delay_bit;
output				update_carry;			// tells EXECUTE to update carry bit in MSR
output				branch_instr;			// tells EXECUTE to use comparator for branching
`ifdef ENABLE_MSR_BIP
output				update_msr_bip;		// handle MSR[BIP]
output				value_msr_bip;
`endif
`ifdef ENABLE_INTERRUPTS
input					int_ip;
output				int_dc;
output				set_msr_ie;
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
output				opcode_exception;
input					insert_exception;
`endif
`ifdef ENABLE_EXCEPTIONS
output				reset_msr_eip;
`endif
`ifdef ENABLE_MSR_OPCODES
output				rS_update;
`endif
`ifdef FSL_LINK
output			fsl_get;
output			fsl_control;
output			fsl_blocking;
output			fsl_cmd_vld;
`endif

// Register All Outputs
reg	[31:0]	immediate;
reg	[`A_SPACE+1:0]	pc_exe;			// Prog Cnter of instr being executed
reg	[2:0]		alu_inputA_sel;
reg	[1:0]		alu_inputB_sel;
reg	[1:0]		alu_inputC_sel;
reg	[3:0]		alu_fns_sel;		// selects ALU function
reg	[2:0]		comparator_fns_sel;
reg 				we_load;				// reg file write enable for load operations
reg				we_store;
reg				we_alu_branch;		// reg file write enable for ALU or branch ops
reg	[3:0]		regfile_input_sel;
reg	[1:0]		dmem_input_sel;
reg	[4:0]		regA_addr;			// 5-bit addresses into Reg File
reg	[4:0]		regB_addr;
reg	[4:0]		regD_addr;
reg				update_carry;		// update the Carry bit in the status reg for ADDs
reg				delay_bit;			// Use delay slot in Branches
reg				branch_instr;
`ifdef ENABLE_MSR_BIP
reg				update_msr_bip;
reg 				value_msr_bip;
`endif
`ifdef ENABLE_INTERRUPTS
reg				int_dc;
reg				set_msr_ie;
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
reg				opcode_exception;
`endif
`ifdef ENABLE_EXCEPTIONS
reg				reset_msr_eip;
`endif
`ifdef ENABLE_MSR_OPCODES
reg				rS_update;
`endif
`ifdef FSL_LINK
reg			fsl_get;
reg			fsl_control;
reg			fsl_blocking;
reg			fsl_cmd_vld;
`endif

// Internal registers
reg [15:0]	imm;				// contains imm value from IMM instr
reg			imm_valid;		// indicates imm value is valid (aka previous instr was IMM)

always@(posedge clock)
begin
	if (reset | (flush & !stall))	// flush only if not stalled, if not we may miss the executing state
	begin
		if (reset)
			pc_exe <= 0;
		else
			pc_exe <= pc_decode;
		update_carry 		<= 0;
		regA_addr 			<= 0;
		regB_addr 			<= 0;
		regD_addr 			<= 0;
		immediate 			<= 0;
		alu_inputA_sel 	<= 0;
		alu_inputB_sel 	<= 0;
		alu_inputC_sel 	<= 0;
		delay_bit			<= 0;
		branch_instr 		<= 0;
		// EXECUTE NoOp on Reset / Flush. NoOp is OR r0, r0, r0
		alu_fns_sel 		<= `ALU_logic_or;
		comparator_fns_sel<= 0;
		we_load 				<= 0;
		we_store 			<= 0;
		we_alu_branch 		<= 0;
		regfile_input_sel <= `RF_zero;	// write zero to r0 on reset -- R0 always zero
		dmem_input_sel 	<= 0;
		imm 					<= 0;
		imm_valid 			<= 0;
`ifdef ENABLE_MSR_BIP
		update_msr_bip		<= 0;
		value_msr_bip		<= 0;
`endif
`ifdef ENABLE_INTERRUPTS
		int_dc				<= 0;
		set_msr_ie			<= 0;
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
		opcode_exception	<= 0;
`endif
`ifdef ENABLE_EXCEPTIONS
		reset_msr_eip 		<= 0;
`endif
`ifdef ENABLE_MSR_OPCODES
		rS_update			<= 0;
`endif
`ifdef FSL_LINK
		fsl_control			<= 0;
		fsl_get				<= 0;
		fsl_blocking		<= 0;
		fsl_cmd_vld			<= 0;
`endif
`ifdef DEBUG_DECODE
		$display("DECODE RESET/FLUSH: pc_exe=%x", pc_exe);
`endif
	end
	else if (!stall)
	begin
		// defaults for most instructions
		branch_instr 		<= 0;
		pc_exe				<= pc_decode;
		// Delay bit is tricky as each type of branch has a different location
		delay_bit 			<= `uncond_branch ? ((`opcode == `RETURN) ? 1 : `D_bit_uncond) : `cond_branch ? `D_bit_cond : 0;
		we_load 				<= 0;
		we_store 			<= 0;
		update_carry		<= 0;	
		regA_addr			<= `regA_sel;
		regB_addr			<= `regB_sel;
		regD_addr			<= `regD_sel;
		immediate			<= imm_valid ? {imm, `imm_value} : {{16{instruction[15]}}, `imm_value}; // 32-bit datapath
		we_alu_branch 		<= 1'b1; // most instrs write to reg file
		regfile_input_sel <= `RF_alu_result;
		alu_inputA_sel		<= `aluA_ra;
		alu_inputB_sel		<= `IMM_bit ? `aluB_imm : `aluB_rb;
		alu_inputC_sel		<= `aluC_zero;
		alu_fns_sel 		<= `ALU_add;
		comparator_fns_sel<= 0;	// Not using comparator
		imm_valid 			<= 0;
`ifdef ENABLE_MSR_BIP
		update_msr_bip		<= 0;
		value_msr_bip		<= 0;
`endif
`ifdef ENABLE_INTERRUPTS
		set_msr_ie			<= 0;
		int_dc				<= 0;
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
		opcode_exception	<= 0;
`endif
`ifdef ENABLE_EXCEPTIONS
		reset_msr_eip 		<= 0;
`endif
`ifdef ENABLE_MSR_OPCODES
		rS_update			<= 0;
`endif
`ifdef FSL_LINK
		fsl_control			<= 0;
		fsl_get				<= 0;
		fsl_blocking		<= 0;
		fsl_cmd_vld			<= 0;
`endif
`ifdef ENABLE_OPCODE_EXCEPTION
// CPU asks to insert exception break:  "brali r17,0x20"
		if(insert_exception)
		begin
				branch_instr 			<= 1;
				alu_inputA_sel			<= `aluA_zero;
				alu_inputB_sel			<= `aluB_imm;
				comparator_fns_sel	<= `CMP_one;	// force a branch
				regfile_input_sel 	<= `RF_pc;
				regD_addr				<= `REG_RET_FROM_EXCEPTION;
				immediate				<= `ADDRESS_EXCEPTION_VECTOR;
				$display("DECODE: Inserting OPCODE-EXCEPTION at pc_decode=0x%x, pc_exe=0x%x", pc_decode, pc_exe);
		end
		else
`endif
`ifdef ENABLE_INTERRUPTS
// when EXECUTE notifies "interrupt in progress", the DECODE module must insert "brali r14,0x10" when
// possible; this is not after a IMM opcode nor in a delay slot. When inserted the interrupt opcode,
// notify EXECUTE that the decode is completed
		if(int_ip && !imm_valid && !delay_bit)		
		begin	
			branch_instr 			<= 1;
			alu_inputA_sel			<= `aluA_zero;
			alu_inputB_sel			<= `aluB_imm;
			comparator_fns_sel	<= `CMP_one;	// force a branch
			regfile_input_sel 	<= `RF_pc;
			regD_addr				<= `REG_RET_FROM_INTERRUPT;
			immediate				<= `ADDRESS_INTERRUPT_VECTOR;
			int_dc 					<= 1;			// notify that DECODE is completed
			$display("DECODE: Inserting INTERRUPT at pc_decode=0x%x, pc_exe=0x%x", pc_decode, pc_exe);
	   end
		else
`endif
		// BIG Case statement here
		// see openfire_define.v for definitions
		casez (`opcode)
		`ADD:		
			begin
				alu_inputC_sel	<= `C_bit ? `aluC_carry : `aluC_zero;
				update_carry	<= ~`K_bit;
			end
		`SUBTRACT:
			begin
				update_carry		<= ~`K_bit;
				if (`U_bit & `CMP_bit & !`IMM_bit) // CMPU
					begin
						alu_fns_sel	<= `ALU_compare_uns;
						comparator_fns_sel <= `CMP_dual_inputs;
					end
				else if (`CMP_bit & !`IMM_bit) // CMP
					alu_fns_sel 	<= `ALU_compare;
				else
					alu_fns_sel	<= `ALU_add;
				alu_inputA_sel	<= `aluA_ra_bar;
				alu_inputC_sel	<= `C_bit ? `aluC_carry : `aluC_one;
			end
		`LOGIC_OR:	alu_fns_sel	<= `ALU_logic_or;
		`LOGIC_AND:	alu_fns_sel	<= `ALU_logic_and;
		`LOGIC_XOR:	alu_fns_sel	<= `ALU_logic_xor;
		`LOGIC_ANDN:	
			begin
				alu_fns_sel		<= `ALU_logic_and;
				alu_inputB_sel	<= `IMM_bit ? `aluB_imm_bar : `aluB_rb_bar;
			end
		`LOGIC_BIT:
			begin
				alu_inputC_sel		<= `aluC_carry;
				update_carry		<= 1;
				casez (`imm_value)
				16'b1:			alu_fns_sel	<= `ALU_shiftR_arth;
				16'b100001:		alu_fns_sel	<= `ALU_shiftR_c;
				16'b1000001:	alu_fns_sel	<= `ALU_shiftR_log;
				16'b1100000:	alu_fns_sel	<= `ALU_sex8;
				16'b1100001:	alu_fns_sel	<= `ALU_sex16;
				endcase
			end
		`BRANCH_UNCON:	// Handles BREAKs as well
			begin
				branch_instr 			<= 1;
				alu_inputA_sel			<= `A_bit ? `aluA_zero : `aluA_pc;
				alu_inputB_sel			<= `IMM_bit ? `aluB_imm : `aluB_rb;
				comparator_fns_sel	<= `CMP_one;	// force a branch
				regfile_input_sel 	<= `RF_pc;
`ifdef ENABLE_MSR_BIP
				update_msr_bip  	   <= ~`D_bit_uncond & `A_bit & `L_bit;	// is br[i]al --> break
				value_msr_bip		   <= 1;				// BREAK --> MSR[BIP] <= 1
`endif
			end
		`BRANCH_CON:
			begin
				branch_instr 		<= 1;
				alu_inputA_sel		<= `aluA_pc;
				comparator_fns_sel<= `branch_compare;
				we_alu_branch 		<= 1'b0;
			end
`ifdef ENABLE_MSR_OPCODES
		`SPECIAL_REG:		// Handle mfs, mts
			begin
			   if(`is_mfs)		// mfs rD,rS	--> move rS to ALU input A
				begin
					casez(`regS_sel_msr)	// select corresponding ALU input based on rS
					`rS_PC  : alu_inputA_sel <= `aluA_pc;
					`rS_MSR : alu_inputA_sel <= `aluA_msr;
					default: $display("mfs: invalid rS=%x", `regS_sel_msr);
			   	endcase
				end
				else if(`is_mts)	// mts rS,rD 	(rS is only MSR). Ask EXE to update MSR from rA
					rS_update 	<= 1;
			end
`endif
		`IMMEDIATE:
			begin
				we_alu_branch 		<= 1'b0; 	// have EXE do nothing
				imm_valid 			<= 1;
				imm					<= `imm_value;
			end
		`RETURN:	// ignores MSR, exceptions, and interrupts
			begin
				branch_instr 		<= 1;
				alu_inputB_sel		<= `aluB_imm;
				comparator_fns_sel<= `CMP_one;	// force a branch
				we_alu_branch 		<= 1'b0;
`ifdef ENABLE_MSR_BIP
				update_msr_bip		<= `BRK_bit;	// return from break?
				value_msr_bip		<= 0;				// rtbd?  MSR[BIP] <= 0
`endif
`ifdef ENABLE_INTERRUPTS
				set_msr_ie			<= `INT_bit;	// MSR[IE] <= 1 if return from interrupt
`ifdef DEBUG_DECODE
`ifdef ENABLE_EXCEPTIONS
				reset_msr_eip		<= `EXC_bit;	// MSR[EIP] <= 0 if return from exception
`endif
				$display("DECODE: RETURN FROM INTERRUPT -- pc_exe=%x", pc_exe);
`endif
`endif
			end
		`LOAD:
			begin
				we_alu_branch 		<= 1'b0;
				we_load				<= 1'b1;
				dmem_input_sel		<= `word_size;
				regfile_input_sel	<= `word_size;
			end
		`STORE:
			begin
				we_alu_branch 		<= 1'b0;
				we_store				<= 1'b1;
				dmem_input_sel		<= `word_size;
			end
`ifdef FSL_LINK
		`FSL:
			begin
				fsl_control			<= `FSL_control;
				fsl_get				<= ~`fsl_get_put;
				fsl_blocking		<= ~`FSL_nblock;
				fsl_cmd_vld			<= 1;
				we_alu_branch 		<= 0;
				regfile_input_sel	<= `RF_fsl;
			end
`endif
`ifdef MUL
		`MULTIPLY:	
			begin
				alu_fns_sel 		<= `ALU_multiply;
				// 32-bit mult takes several cycles -- do not write to Reg File until complete
				we_alu_branch 		<= 1'b0;
			end
`endif
		default:	
			begin
				$display("ERROR!  Malformed OpCode! 0x%x", `opcode);
`ifdef ENABLE_OPCODE_EXCEPTION
				opcode_exception		<= 1;		// notify EXECUTE that we are in "opcode exception"
`endif
			end
		endcase
`ifdef DEBUG_DECODE
		$display("DECODE: pc_exe=%x, instruction=%x", pc_exe, instruction);
`endif
	end

end // end of always@
	
endmodule
