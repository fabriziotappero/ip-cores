/*

MODULE: openfire_define

DESCRIPTION: Contains define statements used for readability.

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

/***********************************
 * User-modified Processor Options *
 ***********************************/

// Choose polarity of reset signal.  Comment next line to make reset active high.
`define RESET_ACTIVE_LOW

// Enable FSL link & FSL debug port (currently only outputs PC)
// Comment out following line to disable FSL support
`define FSL_LINK

// Optional CMPU instruction requires a 32-bit comparator
// To enable CMPU support, leave only one of the following two options uncommented
// To disable CMPU support (for faster, smaller core) comment out both options
`define FAST_CMP			// use fast, but larger comparator for CMPU instr
//`define	CMP			// include comparator for CMPU instr

// Specify address space size
// If using a unified memory (data and instr in same memory) both memory sizes must be the same
`define IM_SIZE	30		// width of instruction memory space; 12 => 2^12 words = 16kB
`define DM_SIZE 30		// width of data memory space; 12 => 2^12 words = 16kB
`define BRAM_SIZE 12	// size of the BRAM (if using unified memory)

// Specify datapath width
// Currently only 32-bit and 16-bit datapath widths are supported
// NOTE: datapath width affects maximum program size as the Prog Counter uses datapath
//	max program length of 16-bit datapath = 16,384 instructions
// To enable 16-bit datapath, uncomment following line
//`define DATAPATH_16		// default datapath width is 32 bits

// Specify addressible space -- easiest just to set to max of IM_SIZE and DM_SIZE
`define A_SPACE 32		// width of addressible space, used for PC (must be =< D_WIDTH)
						// Note: this controls max program size.  It also may
						// conflict with D_WIDTH when A_SPACE is set to 30.

// Optional HW multiplier uses 3 Xilinx Block MULTS for 32-bit multiply
`define MUL			// include HW multiplier

// End User-modified Processor Options


// Sets define statements for datapath -- DO NOT TOUCH ANYTHING BELOW THIS LINE (UNLESS ADDING INSTRUCTIONS)
`ifdef DATAPATH_16
	`define D_WIDTH	16		// width of datapath -- ONLY 32 & 16 supported
`else
	`define D_WIDTH 32
	`define DATAPATH_32
`endif

// Instruction Fields
`define opcode		instruction[31:26]
`define regD_sel 	instruction[25:21]
`define regA_sel	instruction[20:16]
`define regB_sel	instruction[15:11]
`define imm_value	instruction[15:0]
`define branch_compare	instruction[23:21]
`define word_size	instruction[27:26]
`define fsl_get_put	instruction[15]
// Special opcode bits
`define CMP_bit		instruction[0]		// CMP/CMPU instr
`define C_bit		instruction[27]		// Use Carry bit
`define K_bit		instruction[28]		// if 1, do not update Carry bit in MSR
`define	D_bit_uncond	instruction[20]		// Delay bit for unconditional branchs
`define	D_bit_cond	instruction[25]		// Delay bit for conditional branchs
`define	A_bit		instruction[19]		// Absolute addressing for branch
`define	L_bit		instruction[18]		// Link bit, stores PC in rD for branchs
`define U_bit		instruction[1]		// Unsigned bit for Compare instructions
`define IMM_bit		instruction[29]		// IMMediate
`define uncond_branch	(({instruction[31], instruction[30], instruction[28], instruction[27], instruction[26]} == 5'b10110 ) | ({instruction[31], instruction[30], instruction[28], instruction[27], instruction[26]} == 5'b10101 ))
`define cond_branch	({instruction[31], instruction[30], instruction[28], instruction[27], instruction[26]} == 5'b10111 )
`define FSL_nblock	instruction[14]
`define FSL_control	instruction[13]
`define FSL_number  instruction[2:0]

// Instructions
`define ADD		6'b00???0
`define	SUBTRACT	6'b00???1
`define LOGIC_OR	6'b10?000
`define LOGIC_AND	6'b10?001
`define LOGIC_XOR	6'b10?010
`define LOGIC_ANDN	6'b10?011
`define LOGIC_BIT	6'b100100
`define BRANCH_UNCON	6'b10?110	// Break is actually BRAL
`define BRANCH_CON	6'b10?111
`define IMMEDIATE	6'b101100
`define RETURN		6'b101101
`define BREAK		6'b10?110	// Not needed, same opcode as BRAL
`define LOAD		6'b11?0??
`define STORE		6'b11?1??
`define FSL		6'b011011
`define MULTIPLY	6'b01?000

// ALU Functions
`define ALU_add		4'd0
`define ALU_compare_uns	4'd1	// CMPU (unsigned Compare)
`define ALU_logic_or	4'd2
`define ALU_logic_and	4'd3
`define ALU_logic_xor	4'd4
`define ALU_sex8	4'd5
`define ALU_sex16	4'd6
`define ALU_shiftR_arth	4'd7
`define ALU_shiftR_log	4'd8
`define ALU_shiftR_c	4'd9
`define ALU_compare	4'd10	// CMP
`define ALU_multiply	4'd11

// ALU inputs
`define aluA_ra		2'd0
`define aluA_ra_bar	2'd1
`define aluA_pc		2'd2
`define aluA_zero	2'd3
`define aluB_rb		2'd0
`define aluB_imm	2'd1
`define aluB_rb_bar	2'd2
`define aluB_imm_bar	2'd3
`define aluC_zero	2'd0
`define aluC_one	2'd1
`define aluC_carry	2'd2

// Comparator Functions
`define CMP_equal	3'd0
`define CMP_not_equal	3'd1
`define CMP_lessthan	3'd2
`define CMP_lt_equal	3'd3
`define CMP_greaterthan	3'd4
`define CMP_gt_equal	3'd5
`define CMP_one		3'd6
`define CMP_dual_inputs	3'd7	// compare regA and regB for CMPU instr

// RegFile Input Select
`define RF_dmem_byte		3'd0
`define RF_dmem_halfword	3'd1
`define RF_dmem_wholeword	3'd2
`define RF_alu_result		3'd3
`define RF_pc			3'd4
`define	RF_zero			3'd5
`define RF_fsl			3'd6

// DMEM Input Select
`define DM_byte		2'd0
`define DM_halfword	2'd1
`define DM_wholeword	2'd2

