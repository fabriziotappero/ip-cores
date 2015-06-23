/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 to Shawn Tan Ser Ngiap.                  ////
////                       shawn.tan@aeste.net                   ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
// synopsys translate_off
`timescale 1ns / 10ps
// synopsys translate_on

//
// Check if things are already defined.. if not, please define..
//
`ifdef k68_defined
// Skip defines.. DO NOT REDEFINE as some synthesis tools will show
// hundreds of warnings..
`else
////////////////////////////////////////////////////////////////////
//                                                              ////
// K68 Core Defines                                             ////
// Modify these as appropriate.                                 ////
//                                                              ////
////////////////////////////////////////////////////////////////////

// Choose either active HI or LO external RESET for the k68_CPU.
// Either way, the rst_o of the k68_CPU will always be active HI.
//`define k68_RESET_HI

// Choose either active HI or LO memory access. This will affect the
// external program memory access only. The difference is in the strobe
// logic of the control lines. Default is active HI, comment to make it
// active LO.
`define k68_ACTIVE_HI

// Choose either to swap the byte orders of the long words. The default 
// is to swap the byte orders. It will only swap the data lines at the 
// memory interfaces for Program and Data Memory
// No Swap: [31..0]
// Swap   : [7..0,15..8,23..16,31..24]
`define k68_SWAP

// Implement MULU and MULS instructions. Comment out to save space.
// The hardware multiplier is not included by default. If you wish to include
// a multiplier, you'll need to make changes to the k68_execute.v
//`define k68_MULX

// Implement DIVU and DIVS instructions. Comment out to save space.
// The hardware divider is not included by default. If you wish to include
// a divider, you'll need to write the appropriate parts in the k68_execute.v
//`define k68_DIVX

// Implement the ASL and ASR instructions. Comment out to save space.
// If commented, ASL and ASR will work like ROL and ROR.
//`define k68_ASX

// Implement the LSL and LSR instructions. Comment out to save space.
// If commented, LSL and LSR will work like ROL and ROR.
//`define k68_LSX

// Implement the ROXL and ROXR instructions. Comment out to save space.
// If commented, ROXL and ROXR will work like ROL and ROR.
//`define k68_ROXX

// Implement both UARTS. Comment out to save space.
`define k68_UART

// Define UART Baud Rates. Follow instructions in sasc_brg.v unit to set it.
// The default values will give 9600 bps on a 20MHz clock
//`define k68_div0        8'd1
//`define k68_div1        8'd217
`define k68_div0        8'd1
`define k68_div1        8'd217

//
// K68 Widths
// Do not mess with these unless you know what you're doing.
//
`define k68_DATA_W	6'd32		// 68k Data Width
`define k68_ADDR_W	6'd32		// 68k Address Width
`define k68_GPR_W	6'd4		// 68k GPR Width
`define	k68_OP_W	6'd16		// 68k Opcode Width
`define k68_SCR_W	6'd8		// CCR & SSR WIDTH
`define k68_ALU_W       3'd6            // ALUOP WIDTH

//
// K68 Default Values
// Do not mess with these.
//
`define ZERO		32'd0
`define XXXX		32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
`define ESC             6'h3F

//
// 68K Register Resets
//
`define k68_RST_CCR 	8'h00
`define k68_RST_SSR	8'h00
`define k68_RST_VECTOR  32'h00000000

//
// K68 CCR Flags
// Do not change these. Similar to 68000 specs.
//
`define k68_X_FLAG	3'd4
`define k68_N_FLAG	3'd3
`define k68_Z_FLAG	3'd2
`define k68_V_FLAG	3'd1
`define k68_C_FLAG	3'd0

//
// K68 Internal ALU Ops
// Do not change these unless you know what you're doing.
//

// Logical
`define k68_ALU_OR	6'h04
`define k68_ALU_AND	6'h05
`define k68_ALU_EOR	6'h06
`define k68_ALU_NOT	6'h07

// Arithmetic
`define k68_ALU_SUB	6'h08
`define k68_ALU_SUBX    6'h09
`define k68_ALU_SBCD	6'h0A

`define k68_ALU_ADD	6'h0B
`define k68_ALU_ADDX    6'h0C
`define k68_ALU_ABCD	6'h0D

`define k68_ALU_MUL	6'h0E
`define k68_ALU_DIV	6'h0F

`define k68_ALU_NEG 	6'h10
`define k68_ALU_NBCD    6'h11
`define k68_ALU_NEGX    6'h12

// Compare
`define k68_ALU_CMP     6'h13

// CCR & SR
`define k68_ALU_ORSR    6'h01
`define k68_ALU_ANDSR   6'h02
`define k68_ALU_EORSR   6'h03
`define k68_ALU_MOVSR   6'h14

// BCC, DBCC, SCC
`define k68_ALU_BCC     6'h15
`define k68_ALU_DBCC    6'h16
`define k68_ALU_SCC     6'h17

// Bits
`define k68_ALU_BTST	6'h18
`define k68_ALU_BCHG	6'h19
`define k68_ALU_BCLR	6'h1A
`define k68_ALU_BSET	6'h1B

// Shifts
`define k68_ALU_ASX	6'h1C
`define k68_ALU_LSX	6'h1D
`define k68_ALU_ROXX	6'h1E
`define k68_ALU_ROX	6'h1F

// Moves
`define k68_ALU_NOP	6'h00
`define k68_ALU_MOV	6'h3F

// MISC
`define k68_ALU_SWAP    6'h20
`define k68_ALU_STOP    6'h21
`define k68_ALU_VECTOR  6'h22
`define k68_ALU_TAS     6'h23
`define k68_ALU_TST     6'h24
`define k68_ALU_EA     6'h25

//
// OPERAND CONSTS
//
`define k68_OP_NOP      16'b0100111001110001

// Define this so that we will not redefine the defines... (:
`define k68_defined

`endif