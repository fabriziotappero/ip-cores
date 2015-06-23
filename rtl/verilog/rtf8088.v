// ============================================================================
//  8088 Compatible CPU.
//
//
//  (C) 2009,2010  Robert Finch, Stratford
//  robfinch[remove]@opencores.org
//
//
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//
//
//  Verilog 
//  Webpack 9.2i xc3s1000 4-ft256
//  2550 slices / 4900 LUTs / 61 MHz
//  650 ff's / 2 MULTs
//
//  Webpack 14.3  xc6slx45 3-csg324
//  884 ff's 5064 LUTs / 79.788 MHz
// ============================================================================

//`define BYTES_ONLY	1'b1

//`define BIG_SEGS
`ifdef BIG_SEGS
`define SEG_SHIFT		8'b0
`define AMSB			23
`define CS_RESET		16'hFF00
`else
`define SEG_SHIFT		4'b0
`define AMSB			19
`define CS_RESET		16'hF000
`endif

// Opcodes
//
`define MOV_RR	8'b1000100x
`define MOV_MR	8'b1000101x
`define MOV_IM	8'b1100011x
`define MOV_MA	8'b1010000x
`define MOV_AM	8'b0101001x

`define ADD			8'b000000xx
`define ADD_ALI8	8'h04
`define ADD_AXI16	8'h05
`define PUSH_ES		8'h06
`define POP_ES		8'h07
`define OR          8'b000010xx
`define AAD			8'h0A
`define AAM			8'h0A
`define OR_ALI8		8'h0C
`define OR_AXI16	8'h0D
`define PUSH_CS     8'h0E
`define EXTOP		8'h0F	// extended opcode

`define ADC			8'b000100xx
`define ADC_ALI8	8'h14
`define ADC_AXI16	8'h15
`define PUSH_SS     8'h16
`define POP_SS		8'h17
`define SBB         8'b000110xx
`define SBB_ALI8	8'h1C
`define SBB_AXI16	8'h1D
`define PUSH_DS     8'h1E
`define POP_DS		8'h1F

`define AND			8'b001000xx
`define AND_ALI8	8'h24
`define AND_AXI16	8'h25
`define ES			8'h26
`define DAA			8'h27
`define SUB     	8'b001010xx
`define SUB_ALI8	8'h2C
`define SUB_AXI16	8'h2D
`define CS			8'h2E
`define DAS			8'h2F

`define XOR     	8'b001100xx
`define XOR_ALI8	8'h34
`define XOR_AXI16	8'h35
`define SS			8'h36
`define AAA			8'h37
`define CMP			8'b001110xx
`define CMP_ALI8	8'h3C
`define CMP_AXI16	8'h3D
`define DS			8'h3E
`define AAS			8'h3F

`define INC_REG 8'b01000xxx
`define INC_AX	8'h40
`define INC_CX	8'h41
`define INC_DX	8'h42
`define INC_BX	8'h43
`define INC_SP	8'h44
`define INC_BP	8'h45
`define INC_SI	8'h46
`define INC_DI	8'h47
`define DEC_REG	8'b01001xxx
`define DEC_AX	8'h48
`define DEC_CX	8'h49
`define DEC_DX	8'h4A
`define DEC_BX	8'h4B
`define DEC_SP	8'h4C
`define DEC_BP	8'h4D
`define DEC_SI	8'h4E
`define DEC_DI	8'h4F

`define PUSH_REG	8'b01010xxx
`define PUSH_AX 8'h50
`define PUSH_CX	8'h51
`define PUSH_DX	8'h52
`define PUSH_BX	8'h53
`define PUSH_SP 8'h54
`define PUSH_BP 8'h55
`define PUSH_SI 8'h56
`define PUSH_DI 8'h57
`define POP_REG		8'b01011xxx
`define POP_AX	8'h58
`define POP_CX	8'h59
`define POP_DX	8'h5A
`define POP_BX	8'h5B
`define POP_SP  8'h5C
`define POP_BP  8'h5D
`define POP_SI  8'h5E
`define POP_DI  8'h5F

`define PUSHA	8'h60
`define POPA	8'h61
`define BOUND	8'h62
`define ARPL	8'h63
`define FS		8'h64
`define GS		8'h65
`define INSB	8'h6C
`define INSW	8'h6D
`define OUTSB	8'h6E
`define OUTSW	8'h6F

`define Jcc		8'b0111xxxx
`define JO		8'h70
`define JNO		8'h71
`define JB		8'h72
`define JAE		8'h73
`define JE		8'h74
`define JNE		8'h75
`define JBE		8'h76
`define JA		8'h77
`define JS		8'h78
`define JNS		8'h79
`define JP		8'h7A
`define JNP		8'h7B
`define JL		8'h7C
`define JNL		8'h7D
`define JLE		8'h7E
`define JNLE	8'h7F

`define JNA		8'h76
`define JNAE	8'h72
`define JNB     8'h73
`define JNBE    8'h77
`define JC      8'h72
`define JNC     8'h73
`define JG		8'h7F
`define JNG		8'h7E
`define JGE		8'h7D
`define JNGE	8'h7C
`define JPE     8'h7A
`define JPO     8'h7B

`define ALU_I2R8	8'h80
`define ALU_I2R16	8'h81
`define TEST        8'b1000010x
`define XCHG_MEM	8'h86
`define MOV_RR8		8'h88
`define MOV_RR16	8'h89
`define MOV_MR8		8'h8A
`define MOV_MR16	8'h8B
`define MOV_S2R		8'h8C
`define LEA			8'h8D
`define MOV_R2S		8'h8E
`define POP_MEM		8'h8F

`define XCHG_AXR	8'b10010xxx
`define NOP			8'h90
`define CBW			8'h98
`define CWD			8'h99
`define CALLF		8'h9A
`define WAI         8'h9B
`define PUSHF		8'h9C
`define POPF		8'h9D
`define SAHF		8'h9E
`define LAHF		8'h9F

`define MOV_M2AL	8'hA0
`define MOV_M2AX	8'hA1
`define MOV_AL2M	8'hA2
`define MOV_AX2M	8'hA3

`define MOVSB		8'hA4
`define MOVSW		8'hA5
`define CMPSB		8'hA6
`define CMPSW		8'hA7
`define TEST_ALI8	8'hA8
`define TEST_AXI16	8'hA9
`define STOSB		8'hAA
`define STOSW		8'hAB
`define LODSB		8'hAC
`define LODSW		8'hAD
`define SCASB		8'hAE
`define SCASW		8'hAF

`define MOV_I2BYTREG	8'h1011_0xxx
`define MOV_I2AL	8'hB0
`define MOV_I2CL	8'hB1
`define MOV_I2DL	8'hB2
`define MOV_I2BL	8'hB3
`define MOV_I2AH	8'hB4
`define MOV_I2CH	8'hB5
`define MOV_I2DH	8'hB6
`define MOV_I2BH	8'hB7
`define MOV_I2AX	8'hB8
`define MOV_I2CX	8'hB9
`define MOV_I2DX	8'hBA
`define MOV_I2BX	8'hBB
`define MOV_I2SP	8'hBC
`define MOV_I2BP	8'hBD
`define MOV_I2SI	8'hBE
`define MOV_I2DI	8'hBF

`define RETPOP		8'hC2
`define RET			8'hC3
`define LES			8'hC4
`define LDS			8'hC5
`define MOV_I8M		8'hC6
`define MOV_I16M	8'hC7
`define LEAVE		8'hC9
`define RETFPOP		8'hCA
`define RETF		8'hCB
`define INT3		8'hCC
`define INT     	8'hCD
`define INTO		8'hCE
`define IRET		8'hCF

`define RCL_81	8'hD0
`define RCL_161	8'hD1
`define MORE1	8'hD4
`define MORE2	8'hD5
`define XLAT    8'hD7

`define LOOPNZ	8'hE0
`define LOOPZ	8'hE1
`define LOOP	8'hE2
`define JCXZ	8'hE3
`define INB		8'hE4
`define INW		8'hE5
`define OUTB	8'hE6
`define OUTW	8'hE7
`define CALL	8'hE8
`define JMP 	8'hE9
`define JMPF	8'hEA
`define JMPS	8'hEB
`define INB_DX	8'hEC
`define INW_DX	8'hED
`define OUTB_DX	8'hEE
`define OUTW_DX	8'hEF

`define LOCK	8'hF0
`define REPNZ	8'hF2
`define REPZ	8'hF3
`define HLT		8'hF4
`define CMC		8'hF5
//`define IMUL	8'b1111011x
`define CLC		8'hF8
`define STC		8'hF9
`define CLI		8'hFA
`define STI		8'hFB
`define CLD		8'hFC
`define STD		8'hFD
`define GRPFF	8'b1111111x

// extended opcodes
// "OF"
`define LLDT	8'h00
`define LxDT	8'h01
`define LAR		8'h02
`define LSL		8'h03
`define CLTS	8'h06

`define LSS		8'hB2
`define LFS		8'hB4
`define LGS		8'hB5

`define INITIATE_CODE_READ		cyc_type <= `CT_CODE; cyc_o <= 1'b1; stb_o <= 1'b1; we_o <= 1'b0; adr_o <= csip;
`define TERMINATE_CYCLE			cyc_type <= `CT_PASSIVE; cyc_o <= 1'b0; stb_o <= 1'b0; we_o <= 1'b0;
`define TERMINATE_CODE_READ		cyc_type <= `CT_PASSIVE; cyc_o <= 1'b0; stb_o <= 1'b0; we_o <= 1'b0; ip <= ip_inc;
`define PAUSE_CODE_READ			cyc_type <= `CT_PASSIVE; stb_o <= 1'b0; ip <= ip_inc;
`define CONTINUE_CODE_READ		cyc_type <= `CT_CODE; stb_o <= 1'b1; adr_o <= csip;
`define INITIATE_STACK_WRITE	cyc_type <= `CT_WRMEM; cyc_o <= 1'b1; stb_o <= 1'b1; we_o <= 1'b1; adr_o <= sssp;
`define PAUSE_STACK_WRITE		cyc_type <= `CT_PASSIVE; sp <= sp_dec; stb_o <= 1'b0; we_o <= 1'b0;

`define INITIATE_STACK_POP		cyc_type <= `CT_RDMEM; lock_o <= 1'b1; cyc_o <= 1'b1; stb_o <= 1'b1; adr_o <= sssp;
`define COMPLETE_STACK_POP		cyc_type <= `CT_PASSIVE; lock_o <= bus_locked; cyc_o <= 1'b0; stb_o <= 1'b0; sp <= sp_inc;
`define PAUSE_STACK_POP			cyc_type <= `CT_PASSIVE; stb_o <= 1'b0; sp <= sp_inc;
`define CONTINUE_STACK_POP		cyc_type <= `CT_RDMEM; stb_o <= 1'b1; adr_o <= sssp;


/*
Some modrm codes specify register-immediate or memory-immediate operations.
The operation to be performed is coded in the rrr field as only one register
spec (rm) is required.

80/81/83
	rrr   Operation
	---------------
	000 = ADD
	001 = OR
	010 = ADC
	011 = SBB
	100 = AND
	101 = SUB
	110 = XOR
	111 = CMP
FE/FF	
	000 = INC
	001 = DEC
	010 = CALL
	011 =
	100 =
	101 =
	110 =
	111 = 
F6/F7:
	000 = TEST
	001 = 
	010 = NOT
	011 = NEG
	100 = MUL
	101 = IMUL
	110 = DIV
	111 = IDIV
*/
`define ADDRESS_INACTIVE	20'hFFFFF
`define DATA_INACTIVE		8'hFF

`include "cycle_types.v"

module rtf8088(rst_i, clk_i, nmi_i, irq_i, busy_i, inta_o, lock_o, mio_o, cyc_o, stb_o, ack_i, we_o, adr_o, dat_i, dat_o);
// States
parameter IFETCH=8'd1;
parameter IFETCH_ACK = 8'd2;
parameter XI_FETCH = 8'd3;
parameter XI_FETCH_ACK = 8'd4;
parameter REGFETCHA = 8'd5;
parameter DECODE = 8'd7;
parameter DECODER2 = 8'd8;
parameter DECODER3 = 8'd9;

parameter FETCH_VECTOR = 8'd10;
parameter FETCH_IMM8 = 8'd11;
parameter FETCH_IMM8_ACK = 8'd12;
parameter FETCH_IMM16 = 8'd13;
parameter FETCH_IMM16_ACK = 8'd14;
parameter FETCH_IMM16a = 8'd15;
parameter FETCH_IMM16a_ACK = 8'd16;

parameter MOV_I2BYTREG = 8'd17;

parameter FETCH_DISP8 = 8'd18;
parameter FETCH_DISP16 = 8'd19;
parameter FETCH_DISP16_ACK = 8'd20;
parameter FETCH_DISP16a = 8'd21;
parameter FETCH_DISP16a_ACK = 8'd22;
parameter FETCH_DISP16b = 8'd23;

parameter FETCH_OFFSET = 8'd24;
parameter FETCH_OFFSET1 = 8'd25;
parameter FETCH_OFFSET2 = 8'd26;
parameter FETCH_OFFSET3 = 8'd27;
parameter FETCH_SEGMENT = 8'd28;
parameter FETCH_SEGMENT1 = 8'd29;
parameter FETCH_SEGMENT2 = 8'd30;
parameter FETCH_SEGMENT3 = 8'd31;
parameter FETCH_STK_ADJ1 = 8'd32;
parameter FETCH_STK_ADJ1_ACK = 8'd33;
parameter FETCH_STK_ADJ2 = 8'd34;
parameter FETCH_STK_ADJ2_ACK = 8'd35;
parameter FETCH_DATA = 8'd36;
parameter FETCH_DATA1 = 8'd37;

parameter BRANCH1 = 8'd40;
parameter BRANCH2 = 8'd41;
parameter BRANCH3 = 8'd42;

parameter PUSHA = 8'd43;
parameter PUSHA1= 8'd44;
parameter POPA = 8'd45;
parameter POPA1 = 8'd46;
parameter RET = 8'd47;
parameter RETF = 8'd48;
parameter RETF1 = 8'd49;
parameter JMPF = 8'd50;

parameter CALLF = 8'd51;
parameter CALLF1 = 8'd52;
parameter CALLF2 = 8'd53;
parameter CALLF3 = 8'd54;
parameter CALLF4 = 8'd55;
parameter CALLF5 = 8'd56;
parameter CALLF6 = 8'd57;
parameter CALLF7 = 8'd58;

parameter CALL = 8'd59;
parameter CALL1 = 8'd60;
parameter CALL2 = 8'd61;
parameter CALL3 = 8'd62;

parameter PUSH = 8'd63;
parameter PUSH1 = 8'd64;
parameter PUSH2 = 8'd65;
parameter PUSH3 = 8'd66;

parameter IRET = 8'd70;
parameter IRET1 = 8'd71;
parameter IRET2 = 8'd72;

parameter POP = 8'd73;
parameter POP1 = 8'd74;
parameter POP2 = 8'd75;
parameter POP3 = 8'd76;

parameter CALL_IN = 8'd77;
parameter CALL_IN1 = 8'd78;
parameter CALL_IN2 = 8'd79;
parameter CALL_IN3 = 8'd80;
parameter CALL_IN4 = 8'd81;

parameter STOS = 8'd83;
parameter STOS1 = 8'd84;
parameter STOS2 = 8'd85;
parameter MOVS = 8'd86;
parameter MOVS1 = 8'd87;
parameter MOVS2 = 8'd88;
parameter MOVS3 = 8'd89;
parameter MOVS4 = 8'd90;
parameter MOVS5 = 8'd91;

parameter WRITE_REG = 8'd92;

parameter EACALC = 8'd93;
parameter EACALC1 = 8'd94;
parameter EACALC_DISP8 = 8'd95;
parameter EACALC_DISP8_ACK = 8'd96;
parameter EACALC_DISP16 =  8'd97;
parameter EACALC_DISP16_ACK =  8'd98;
parameter EACALC_DISP16a =  8'd99;
parameter EACALC_DISP16a_ACK =  8'd100;
parameter EXECUTE = 8'd101;

parameter INB = 8'd102;
parameter INB1 = 8'd103;
parameter INB2 = 8'd104;
parameter INB3 = 8'd105;
parameter INW = 8'd106;
parameter INW1 = 8'd107;
parameter INW2 = 8'd108;
parameter INW3 = 8'd109;
parameter INW4 = 8'd110;
parameter INW5 = 8'd111;

parameter OUTB = 8'd112;
parameter OUTB_NACK = 8'd113;
parameter OUTB1 = 8'd114;
parameter OUTB1_NACK = 8'd115;
parameter OUTW = 8'd116;
parameter OUTW_NACK = 8'd117;
parameter OUTW1 = 8'd118;
parameter OUTW1_NACK = 8'd119;
parameter OUTW2 = 8'd120;
parameter OUTW2_NACK = 8'd121;
parameter FETCH_PORTNUMBER = 8'd122;

parameter INVALID_OPCODE = 8'd123;
parameter IRQ1 = 8'd126;

parameter JUMP_VECTOR1 = 8'd127;
parameter JUMP_VECTOR2 = 8'd128;
parameter JUMP_VECTOR3 = 8'd129;
parameter JUMP_VECTOR4 = 8'd130;
parameter JUMP_VECTOR5 = 8'd131;
parameter JUMP_VECTOR6 = 8'd132;
parameter JUMP_VECTOR7 = 8'd133;
parameter JUMP_VECTOR8 = 8'd134;
parameter JUMP_VECTOR9 = 8'd135;

parameter STORE_DATA = 8'd136;
parameter STORE_DATA1 = 8'd137;
parameter STORE_DATA2 = 8'd138;
parameter STORE_DATA3 = 8'd139;

parameter INTO = 8'd140;
parameter FIRST = 8'd141;

parameter INTA0 = 8'd142;
parameter INTA1 = 8'd143;
parameter INTA2 = 8'd144;
parameter INTA3 = 8'd145;

parameter RETPOP = 8'd150;
parameter RETPOP_NACK = 8'd151;
parameter RETPOP1 = 8'd152;
parameter RETPOP1_NACK = 8'd153;

parameter RETFPOP = 8'd154;
parameter RETFPOP1 = 8'd155;
parameter RETFPOP2 = 8'd156;
parameter RETFPOP3 = 8'd157;
parameter RETFPOP4 = 8'd158;
parameter RETFPOP5 = 8'd159;
parameter RETFPOP6 = 8'd160;
parameter RETFPOP7 = 8'd161;
parameter RETFPOP8 = 8'd162;

parameter XLAT_ACK = 8'd166;

parameter FETCH_DESC = 8'd170;
parameter FETCH_DESC1 = 8'd171;
parameter FETCH_DESC2 = 8'd172;
parameter FETCH_DESC3 = 8'd173;
parameter FETCH_DESC4 = 8'd174;
parameter FETCH_DESC5 = 8'd175;

parameter INSB = 8'd180;
parameter INSB1 = 8'd181;
parameter OUTSB = 8'd182;
parameter OUTSB1 = 8'd183;

parameter SCASB = 8'd185;
parameter SCASB1 = 8'd186;
parameter SCASW = 8'd187;
parameter SCASW1 = 8'd188;
parameter SCASW2 = 8'd189;

parameter CMPSW = 8'd190;
parameter CMPSW1 = 8'd191;
parameter CMPSW2 = 8'd192;
parameter CMPSW3 = 8'd193;
parameter CMPSW4 = 8'd194;
parameter CMPSW5 = 8'd195;

parameter LODS = 8'd196;
parameter LODS_NACK = 8'd197;
parameter LODS1 = 8'd198;
parameter LODS1_NACK = 8'd199;

parameter INSW = 8'd200;
parameter INSW1 = 8'd201;
parameter INSW2 = 8'd202;
parameter INSW3 = 8'd203;

parameter OUTSW = 8'd205;
parameter OUTSW1 = 8'd206;
parameter OUTSW2 = 8'd207;
parameter OUTSW3 = 8'd208;

parameter CALL_FIN = 8'd210;
parameter CALL_FIN1 = 8'd211;
parameter CALL_FIN2 = 8'd212;
parameter CALL_FIN3 = 8'd213;
parameter CALL_FIN4 = 8'd214;

parameter DIVIDE1 = 8'd215;
parameter DIVIDE1a = 8'd216;
parameter DIVIDE2 = 8'd217;
parameter DIVIDE2a = 8'd218;
parameter DIVIDE3 = 8'd219;

parameter INT = 8'd220;
parameter INT1 = 8'd221;
parameter INT2 = 8'd222;
parameter INT3 = 8'd223;
parameter INT4 = 8'd224;
parameter INT5 = 8'd225;
parameter INT6 = 8'd226;
parameter INT7 = 8'd227;
parameter INT8 = 8'd228;
parameter INT9 = 8'd229;
parameter INT10 = 8'd230;
parameter INT11 = 8'd231;
parameter INT12 = 8'd232;
parameter INT13 = 8'd233;
parameter INT14 = 8'd234;

parameter IRET3 = 8'd235;
parameter IRET4 = 8'd236;
parameter IRET5 = 8'd237;
parameter IRET6 = 8'd238;
parameter IRET7 = 8'd239;
parameter IRET8 = 8'd240;
parameter IRET9 = 8'd241;
parameter IRET10 = 8'd242;
parameter IRET11 = 8'd243;
parameter IRET12 = 8'd244;

parameter INSB2 = 8'd246;
parameter OUTSB2 = 8'd247;
parameter XCHG_MEM = 8'd248;

parameter CMPSB = 8'd250;
parameter CMPSB1 = 8'd251;
parameter CMPSB2 = 8'd252;
parameter CMPSB3 = 8'd253;
parameter CMPSB4 = 8'd254;


input rst_i;
input clk_i;
input nmi_i;	
input irq_i;
input busy_i;
output inta_o;
output lock_o;
output mio_o;
output cyc_o;
output stb_o;
input  ack_i;
output we_o;
output [`AMSB:0] adr_o;
input  [ 7:0] dat_i;
output [ 7:0] dat_o;

reg inta_o;
reg lock_o;
reg cyc_o;
reg stb_o;
reg we_o;
reg [`AMSB:0] adr_o;
reg [ 7:0] dat_o;

reg    mio_o;
wire   busy_i;

reg [1:0] seg_sel;			// segment selection	0=ES,1=SS,2=CS (or none), 3=DS

reg [7:0] state;			// machine state
reg [7:0] substate;
reg hasFetchedModrm;
reg hasFetchedDisp8;
reg hasFetchedDisp16;
reg hasFetchedData;
reg hasStoredData;
reg hasFetchedVector;

reg [15:0] res;				// result bus
wire pres;					// parity result
wire reszw;					// zero word
wire reszb;					// zero byte
wire resnb;					// negative byte
wire resnw;					// negative word
wire resn;
wire resz;

reg [2:0] cyc_type;			// type of bus sycle
reg w;						// 0=8 bit, 1=16 bit
reg d;
reg v;						// 1=count in cl, 0 = count is one
reg [1:0] mod;
reg [2:0] rrr;
reg [2:0] rm;
reg sxi;
reg [2:0] sreg;
reg [1:0] sreg2;
reg [2:0] sreg3;
reg [2:0] TTT;
reg [7:0] lock_insn;
reg [7:0] prefix1;
reg [7:0] prefix2;
reg [7:0] int_num;			// interrupt number to execute
reg [15:0] seg_reg;			// segment register value for memory access
reg [15:0] data16;			// caches data
reg [15:0] disp16;			// caches displacement
reg [15:0] offset;			// caches offset
reg [15:0] selector;		// caches selector
reg [`AMSB:0] ea;				// effective address
reg [39:0] desc;			// buffer for sescriptor
reg [6:0] cnt;				// counter
reg [1:0] S43;
reg wrregs;
reg wrsregs;
wire take_br;
reg [3:0] shftamt;
reg ld_div16,ld_div32;		// load divider
reg div_sign;

reg nmi_armed;
reg rst_nmi;				// reset the nmi flag
wire pe_nmi;				// indicates positive edge on nmi signal

wire RESET = rst_i;
wire CLK = clk_i;
wire NMI = nmi_i;

`include "REGFILE.v"	
`include "CONTROL_LOGIC.v"
`include "which_seg.v"
evaluate_branch u4 (ir,cx,zf,cf,sf,vf,pf,take_br);
`include "c:\cores\bcxa6\rtl\verilog\eight_bit\ALU.v"
nmi_detector u6 (RESET, CLK, NMI, rst_nmi, pe_nmi);

always @(posedge CLK)
	if (RESET) begin
		pf <= 1'b0;
		cf <= 1'b0;
		df <= 1'b0;
		vf <= 1'b0;
		zf <= 1'b0;
		ie <= 1'b0;
		hasFetchedModrm <= 1'b0;
		cs <= `CS_RESET;
		ip <= 16'hFFF0;
		inta_o <= 1'b0;
		mio_o <= 1'b1;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		cyc_type <= `CT_PASSIVE;
		ir <= `NOP;
		prefix1 <= 8'h00;
		prefix2 <= 8'h00;
		rst_nmi <= 1'b1;
		wrregs <= 1'b0;
		wrsregs <= 1'b0;
		ld_div16 <= 1'b0;
		ld_div32 <= 1'b0;
		state <= IFETCH;
	end
	else begin
		rst_nmi <= 1'b0;
		wrregs <= 1'b0;
		wrsregs <= 1'b0;
		ld_div16 <= 1'b0;
		ld_div32 <= 1'b0;

`include "WRITE_BACK.v"

		case(state)

`include "IFETCH.v"
`include "DECODE.v"
`include "DECODER2.v"
`include "REGFETCHA.v"
`include "EACALC.v"
`include "CMPSB.v"
`include "CMPSW.v"
`include "MOVS.v"
`include "LODS.v"
`include "STOS.v"
`include "SCASB.v"
`include "SCASW.v"
`include "EXECUTE.v"
`include "FETCH_DATA.v"
`include "FETCH_DISP8.v"
`include "FETCH_DISP16.v"
`include "FETCH_IMMEDIATE.v"
`include "FETCH_OFFSET_AND_SEGMENT.v"
`include "MOV_I2BYTREG.v"
`include "STORE_DATA.v"
`include "BRANCH.v"
`include "CALL.v"
`include "CALLF.v"
`include "CALL_IN.v"
`include "INTA.v"
`include "INT.v"
`include "FETCH_STK_ADJ.v"
`include "RETPOP.v"
`include "RETFPOP.v"
`include "IRET.v"
`include "JUMP_VECTOR.v"
`include "PUSH.v"
`include "POP.v"
`include "INB.v"
`include "INW.v"
`include "OUTB.v"
`include "OUTW.v"
`include "INSB.v"
`include "OUTSB.v"
`include "XCHG_MEM.v"
`include "DIVIDE.v"

			default:
				state <= IFETCH;
			endcase
		end

`include "wb_task.v"

endmodule
