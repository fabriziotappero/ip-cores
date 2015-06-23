/*	MODULE: openfire_define
	DESCRIPTION: Contains define statements used for readability.

AUTHOR: 
Stephen Douglas Craven
Configurable Computing Lab
Virginia Tech
scraven@vt.edu

REVISION HISTORY:
Revision 0.2, 8/10/2005 SDC
Initial release

Revision 0.3, 26/03/2007 Antonio J. Antón
New tags added for Core/SOC/Peripherals

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

`timescale 1ns/100ps

/************* USER MODIFIED SOC OPTIONS ****************/
`define CLK_25MHZ				// system clock
`define IO_SIZE		 4		// up to 16 IO addresses

// IO memory address (use <<2 at program level)
`define ADDR_SP3_IO	 0		// 7SEG + LEDS + SWITCHES + PUSHBUTTONS
`define ADDR_UARTS	 1		// uart1/2 status register
`define ADDR_UART1	 2		// uart 1 tx/rx
`define ADDR_UART2	 3		// uart 2 tx/rx
`define ADDR_PROM		 4		// prom control/status/data
`define ADDR_TIMER1	 5		// control / set / current
`define ADDR_INT		 6		// interrupt enable

`define BAUD_COUNT	13		// 26=115200@50mhz, 324=9600@50mhz, 13=115200@25mhz
`define PROM_SYNC_PATTERN 32'h8F9FAFBF		// bit pattern to detect start of file

`define SP3SK_IODEVICES	// enables peripherals on SP3SK
`ifdef SP3SK_IODEVICES
  `define SP3SK_USERIO		// enable GPIO in SP3SK board
  `define UART1_ENABLE		// enable UART #1
//`define UART2_ENABLE		// enable UART #2
  `define SP3SK_PROM_DATA	// enable user data at the end of FPGA PROM
  `define TIMER1_GENERATOR	// enable TIMER generator (31 bit + 1 restart/stop bit)
//`define IO_MULTICYCLE		// enable multicycle i/o operations
`endif
`define SP3SK_SRAM			// enable external 1Mx32 SRAM in SP3SK
`define SP3SK_VGA				// enable VGA in SP3SK

`define LOCATION_BRAM		2'b00			// boot ram			0x0000_0000->0x0000_1FFF (8 Kbytes)
`define LOCATION_SRAM		2'b01			// external SRAM	0x0400_0000->0x040F_FFFF (1 Mbyte)
`define LOCATION_BRAM_WRAP	2'b11			// temporary wrap end address space with bootram
`define LOCATION_IOSPACE	2'b10			// 0x08xx_xx<00yy><zz00> yyzz=i/o address
`define LOCATION_VRAM		18'h3_8800	//	video ram starts at 0x040E_2000 (end of SRAM)

`define SRAM_BASE_ADDRESS 	{ {32 - `A_SPACE{0}, `LOCATION_SRAM, {`A_SPACE-2{0}} }
`define IO_BASE_ADDRESS 	{ {32 - `A_SPACE{0}, `LOCATION_IOSPACE, {`A_SPACE-2{0}} }
`define VIDEO_BASE_ADDRESS { {32 - `A_SPACE{0}, `LOCATION_SRAM, `LOCATION_VRAM }

/***********************************
 * User-modified Processor Options *
 ***********************************/
// enable opcode dissasembler in simulador
`define OPCODE_DISSASEMBLER
`define DEBUG_SIMPLE_MEMORY_DUMP
//`define DEBUG_FETCH
//`define DEBUG_DECODE
//`define DEBUG_EXECUTE
`define DEBUG_FILE_SRAM "..\\sw\\test-int\\sample.rom"	// ROM file to be loaded at SRAM base
`define MAX_SIMULATION_SRAM	8096		// in 32 bit words
//`define SHOW_SRAM_DATA					// show sram write contents

// start address after a reset
//`define RESET_PC_ADDRESS	32'h0400_0000	// start at sram (only for simulation!!!)
`define RESET_PC_ADDRESS	32'h0000_0000	// default start PC

`define ENABLE_INTERRUPTS	// enable interrupt handling & MSR[IE] bit
//`define ENABLE_MSR_BIP		// enables MSR[BIP] processing
`define ENABLE_MSR_OPCODES	// opcodes to manage MS registers (mfs, msrclr, msrset, mts)

//`define ENABLE_EXCEPTIONS	// enable exception handling & MSR[EIP] bit
`ifdef ENABLE_EXCEPTIONS
//`define ENABLE_ALIGNMENT_EXCEPTION	// generates exception on memory read/write unalignment
//`define ENABLE_OPCODE_EXCEPTION		// generates exception on invalid opcode
`endif
//`define FSL_LINK				// enable FSL link opcodes (one port only)

// Optional CMPU instruction requires a 32-bit comparator
// To enable CMPU support, leave only one of the following two options uncommented
// To disable CMPU support (for faster, smaller core) comment out both options
//`define FAST_CMP			// use fast, but larger comparator for CMPU instr
`define	CMP				// include comparator for CMPU instr

// Specify address space size
// If using a unified memory (data and instr in same memory) both memory sizes must be the same
`define IM_SIZE	28		// width of instruction memory space; 12 => 2^12 words = 16kB
`define DM_SIZE 	28		// width of data memory space; 12 => 2^12 words = 16kB

// Specify addressible space -- easiest just to set to max of IM_SIZE and DM_SIZE
`define A_SPACE 28		// width of addressible space, used for PC (must be =< D_WIDTH)

// Optional HW multiplier uses 3 Xilinx Block MULTS for 32-bit multiply
`define MUL					// include HW multiplier
//`define DIV				// include HW divider **TODO**
//`define BS				// include HW barrel shift **TODO**

// End User-modified Processor Options
// Sets define statements for datapath -- DO NOT TOUCH ANYTHING BELOW THIS LINE (UNLESS ADDING INSTRUCTIONS)
`define NoOp			32'h8000_0000			// NoOp instruction
`define IntOp			32'hB9CC_0010			// Interrupt Opcode is:  brali r14,0x10
//`define ExcptOp		32'h						// Exception Opcode is:  brali r17,0x20
//`define BreakOp		32'h						// Break Opcode is:      brali r16,0x18

`define REG_RET_FROM_INTERRUPT	14			// return address from interrupt in r14
`define ADDRESS_INTERRUPT_VECTOR	32'h10	// interrupt vector is at 0x10
`define REG_RET_FROM_BREAK			16			// return address from break in r16
`define ADDRESS_BREAK_VECTOR		32'h18	// break vector is at 0x18
`define REG_RET_FROM_EXCEPTION	17			// return address from exception in r17
`define ADDRESS_EXCEPTION_VECTOR	32'h20	// exception vector is at 0x20

// Instruction Fields
`define opcode			instruction[31:26]
`define regD_sel 		instruction[25:21]
`define regA_sel		instruction[20:16]
`define regB_sel		instruction[15:11]
`define imm_value		instruction[15:0]
`define branch_compare	instruction[23:21]
`define word_size		instruction[27:26]
`define fsl_get_put	instruction[15]
//`define regS_sel_mfs	instruction[13:0]
//`define regS_sel_mts instruction[2:0]
`define regS_sel_msr instruction[3:0]

// Special opcode bits
`define CMP_bit		instruction[0]			// differentiate CMP/CMPU instr from SUBSTRACT
`define C_bit			instruction[27]		// Use Carry bit
`define K_bit			instruction[28]		// if 1, do not update Carry bit in MSR
`define D_bit_uncond	instruction[20]		// Delay bit for unconditional branchs
`define D_bit_cond	instruction[25]		// Delay bit for conditional branchs
`define A_bit			instruction[19]		// Absolute addressing for branch
`define L_bit			instruction[18]		// Link bit, stores PC in rD for branchs
`define U_bit			instruction[1]			// Unsigned bit for Compare instructions
`define IMM_bit		instruction[29]		// IMMediate
`define uncond_branch	(({instruction[31], instruction[30], instruction[28], instruction[27], instruction[26]} == 5'b10110 ) | ({instruction[31], instruction[30], instruction[28], instruction[27], instruction[26]} == 5'b10101 ))
`define cond_branch	({instruction[31], instruction[30], instruction[28], instruction[27], instruction[26]} == 5'b10111 )
`define FSL_nblock	instruction[14]
`define FSL_control	instruction[13]
`define BRK_bit		instruction[22]		// break bit for returns
`define INT_bit		instruction[21]		// interrupt bit
`define EXC_bit		instruction[23]		// exception bit
`define is_SEXT16		(instruction[6:0] == 7'b1100001)			// functions for LOGICAL_BIT opcode
`define is_SEXT8		(instruction[6:0] == 7'b1100000)
`define is_SRA			(instruction[6:0] == 7'b0000001)
`define is_SRC			(instruction[6:0] == 7'b0100001)
`define is_SRL			(instruction[6:0] == 7'b1000001)
`define is_mfs			(instruction[15:14] == 3'b10)
`define msr_clrset	instruction[16]		//1=clr, 0=set
`define is_mts			(instruction[15:14] == 2'b11)

// Instructions
`define ADD				6'b00???0	// 00ikc0						add[i][k][c]
`define LOGIC_AND		6'b10?001  	// 10i001						and[i]
`define LOGIC_ANDN	6'b10?011	// 10i011						andn[i]
`define BRANCH_CON	6'b10?111	// 10i111 d						b<cond>[i][d]
`define BRANCH_UNCON	6'b10?110	// 10i110 <rD> dal			br[a][i][l][d] 	Break is actually BRAL
`define BREAK			6'b10?110	// brk=bral
`define BARREL_SHIFT	6'b01?001	// 01i001 <rD><rA><rB> st	bs<l|r><l|a>[i] s=1/0=left/right, t=1/0=arithmetic/logical
`define COMPARE		6'b000101	// same as SUBSTRACT with opcode[0]=1
`define FSL				6'b011011	// 011011 <rd> 00000 <g|p>nc....<fslN 3bits> n=0 block, c=control	[n][c]get/[n][c]put
`define FP_OP			6'b010110	// floating point instructions
`define DIVIDE			6'b01?010	// 01i010 <rd> <rA> <rB> bit[30]=1=unsigned	idiv[u]
`define IMMEDIATE		6'b101100	// 101100						imm
`define LOAD			6'b11?0??	// 11i0wh						wh=00: lbu[i], wh=01: lhu[i], wh=10: lw[i]	
`define SPECIAL_REG	6'b100101	// **todo**
`define MULTIPLY		6'b01?000	// 01i000						mul[i]
`define LOGIC_OR		6'b10?000	// 10i000						or[i]
`define PATTERN_CMP	6'b100000	// **todo**
`define SUBTRACT		6'b00???1	// 00ikc1						rsub[i][k][c]
`define RETURN			6'b101101	// 101101 10ebi <rA>			rt<e|b|i|s>d (ebi=0 --> s)
`define STORE			6'b11?1??	// 11i1wh						wh=00: sb[i], wh=01: sh[i], wh=10: sl[i]
`define LOGIC_BIT		6'b100100	// 100100 and 7 lower bits	sext16,sext8,sra,src,srl,wdc, wic
`define LOGIC_XOR		6'b10?010	// 10i010						xor[i]

// ALU Functions
`define ALU_add			4'd0
`define ALU_compare_uns	4'd1	// CMPU (unsigned Compare)
`define ALU_logic_or		4'd2
`define ALU_logic_and	4'd3
`define ALU_logic_xor	4'd4
`define ALU_sex8			4'd5
`define ALU_sex16			4'd6
`define ALU_shiftR_arth	4'd7
`define ALU_shiftR_log	4'd8
`define ALU_shiftR_c		4'd9
`define ALU_compare		4'd10	// CMP
`define ALU_multiply		4'd11
`define ALU_divide		4'd12	// **TODO**
`define ALU_barrel		4'd13	// **TODO**

// ALU inputs
`define aluA_ra		3'd0	// size increased to acommodate further inputs
`define aluA_ra_bar	3'd1	// from special registers
`define aluA_pc		3'd2
`define aluA_zero		3'd3
`define aluA_msr		3'd4

`define aluB_rb		2'd0
`define aluB_imm		2'd1
`define aluB_rb_bar	2'd2
`define aluB_imm_bar	2'd3

`define aluC_zero		2'd0
`define aluC_one		2'd1
`define aluC_carry	2'd2

// Comparator Functions
`define CMP_equal			3'd0
`define CMP_not_equal	3'd1
`define CMP_lessthan		3'd2
`define CMP_lt_equal		3'd3
`define CMP_greaterthan	3'd4
`define CMP_gt_equal		3'd5
`define CMP_one			3'd6
`define CMP_dual_inputs	3'd7	// compare regA and regB for CMPU instr

// RegFile Input Select (width increased)
`define RF_dmem_byte			4'd0	// same as `word_size
`define RF_dmem_halfword	4'd1	// same as `word_size
`define RF_dmem_wholeword	4'd2	// same as `word_size
`define RF_alu_result		4'd3
`define RF_pc					4'd4
`define RF_zero				4'd5
`define RF_fsl					4'd6
`define RF_msr					4'd7
`define RF_ear					4'd8 	//todo
`define RF_esr					4'd9	//todo
`define RF_btr					4'd10 //todo

// DMEM Input Select
`define DM_byte		2'd0
`define DM_halfword	2'd1
`define DM_wholeword	2'd2

// MSR bits
`define MSR_BL_Ena	0		// bus lock enable
`define MSR_IE			1		// interrupt enable
`define MSR_C			2		// carry
`define MSR_BIP		3		// break in progress
`define MSR_FSL_Err	4		// FSL error
`define MSR_IC_Ena	5		// Instruction Cache
`define MSR_DZ			6		// Division by Zero
`define MSR_DC_Ena	7		// Data Cache
`define MSR_E_Ena		8		// Exception enable
`define MSR_EIP		9		// Exception in progress
`define MSR_PVR		10		// Procesor Version Register exists

// MSR registers
`define rS_PC			4'h0
`define rS_MSR			4'h1
`define rS_EAR			4'h3
`define rS_ESR			4'h5
`define rS_BTR			4'hB
