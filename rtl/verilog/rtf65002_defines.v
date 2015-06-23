`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
// rtf65002.v
//  - 32 bit CPU
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
// ============================================================================
//
`ifndef RTF65002_DEFINES
`define RTF65002_DEFINES	1'b1

`define TRUE		1'b1
`define FALSE		1'b0

`define DEBUG		1'b1

`define SUPPORT_ICACHE	1'b1
`define ICACHE_4K		1'b1
//`define ICACHE_16K		1'b1
//`define ICACHE_2WAY		1'b1
//`define SUPPORT_DCACHE	1'b1
`define SUPPORT_BCD		1'b1
`define SUPPORT_DIVMOD		1'b1
`define SUPPORT_EM8		1'b1
`define SUPPORT_816		1'b1
//`define SUPPORT_EXEC	1'b1
`define SUPPORT_BERR	1'b1
`define SUPPORT_STRING	1'b1
`define SUPPORT_SHIFT	1'b1

`define RST_VECT	34'h3FFFFFFF8
`define NMI_VECT	34'h3FFFFFFF4
`define IRQ_VECT	34'h3FFFFFFF0
`define BRK_VECTNO	9'd0
`define SLP_VECTNO	9'd1
`define BYTE_RST_VECT	34'h00000FFFC
`define BYTE_NMI_VECT	34'h00000FFFA
`define BYTE_IRQ_VECT	34'h00000FFFE
`define RST_VECT_816	34'h00000FFFC
`define IRQ_VECT_816	34'h00000FFEE
`define NMI_VECT_816	34'h00000FFEA
`define ABT_VECT_816	34'h00000FFE8
`define BRK_VECT_816	34'h00000FFE6
`define COP_VECT_816	34'h00000FFE4

`define BRK			9'h00
`define RTI			9'h40
`define RTS			9'h60
`define PHP			9'h08
`define CLC			9'h18
`define PLP			9'h28
`define SEC			9'h38
`define PHA			9'h48
`define CLI			9'h58
`define PLA			9'h68
`define SEI			9'h78
`define DEY			9'h88
`define TYA			9'h98
`define TAY			9'hA8
`define CLV			9'hB8
`define INY			9'hC8
`define CLD			9'hD8
`define INX			9'hE8
`define SED			9'hF8
`define ROR_ACC		9'h6A
`define TXA			9'h8A
`define TXS			9'h9A
`define TAX			9'hAA
`define TSX			9'hBA
`define DEX			9'hCA
`define NOP			9'hEA
`define TXY			9'h9B
`define TYX			9'hBB
`define TAS			9'h1B
`define TSA			9'h3B
`define TRS			9'h8B
`define TSR			9'hAB
`define TCD			9'h5B
`define TDC			9'h7B
`define STP			9'hDB
`define NAT			9'hFB
`define EMM			9'hFB
`define XCE			9'hFB
`define INA			9'h1A
`define DEA			9'h3A
`define SEP			9'hE2
`define REP			9'hC2
`define PEA			9'hF4
`define PEI			9'hD4
`define PER			9'h62
`define WDM			9'h42

`define RR			9'h02
`define ADD_RR			4'd0
`define SUB_RR			4'd1
`define CMP_RR			4'd2
`define AND_RR			4'd3
`define EOR_RR			4'd4
`define OR_RR			4'd5
`define MUL_RR			4'd8
`define MULS_RR			4'd9
`define DIV_RR			4'd10
`define DIVS_RR			4'd11
`define MOD_RR			4'd12
`define MODS_RR			4'd13
`define ASL_RRR			4'd14
`define LSR_RRR			4'd15
`define LD_RR		9'h7B

`define ADD_R		9'h77
`define ADD_IMM4	9'h67
`define ADD_IMM8	9'h65		// 8 bit operand
`define ADD_IMM16	9'h79		// 16 bit operand
`define ADD_IMM32	9'h69		// 32 bit operand
`define ADD_ZPX		9'h75		// there is no ZP mode, use R0 to syntheisze
`define ADD_IX		9'h61
`define ADD_IY		9'h71
`define ADD_ABS		9'h6D
`define ADD_ABSX	9'h7D
`define ADD_RIND	9'h72
`define ADD_DSP		9'h63

`define SUB_R		9'hF7
`define SUB_IMM4	9'hE7
`define SUB_IMM8	9'hE5
`define SUB_IMM16	9'hF9
`define SUB_IMM32	9'hE9
`define SUB_ZPX		9'hF5
`define SUB_IX		9'hE1
`define SUB_IY		9'hF1
`define SUB_ABS		9'hED
`define SUB_ABSX	9'hFD
`define SUB_RIND	9'hF2
`define SUB_DSP		9'hE3

// CMP = SUB r0,....

`define ADC_IMM		9'h69
`define ADC_ZP		9'h65
`define ADC_ZPX		9'h75
`define ADC_IX		9'h61
`define ADC_IY		9'h71
`define ADC_IYL		9'h77
`define ADC_ABS		9'h6D
`define ADC_ABSX	9'h7D
`define ADC_ABSY	9'h79
`define ADC_I		9'h72
`define ADC_IL		9'h67
`define ADC_AL		9'h6F
`define ADC_ALX		9'h7F
`define ADC_DSP		9'h63
`define ADC_DSPIY	9'h73

`define SBC_IMM		9'hE9
`define SBC_ZP		9'hE5
`define SBC_ZPX		9'hF5
`define SBC_IX		9'hE1
`define SBC_IY		9'hF1
`define SBC_IYL		9'hF7
`define SBC_ABS		9'hED
`define SBC_ABSX	9'hFD
`define SBC_ABSY	9'hF9
`define SBC_I		9'hF2
`define SBC_IL		9'hE7
`define SBC_AL		9'hEF
`define SBC_ALX		9'hFF
`define SBC_DSP		9'hE3
`define SBC_DSPIY	9'hF3

`define CMP_IMM8	9'hC5
`define CMP_IMM32	9'hC9
`define CMP_IMM		9'hC9
`define CMP_ZP		9'hC5
`define CMP_ZPX		9'hD5
`define CMP_IX		9'hC1
`define CMP_IY		9'hD1
`define CMP_IYL		8'hD7
`define CMP_ABS		9'hCD
`define CMP_ABSX	9'hDD
`define CMP_ABSY	9'hD9
`define CMP_I		9'hD2
`define CMP_IL		9'hC7
`define CMP_AL		9'hCF
`define CMP_ALX		9'hDF
`define CMP_DSP		9'hC3
`define CMP_DSPIY	9'hD3

`define LDA_IMM8	9'hA5
`define LDA_IMM16	9'hB9
`define LDA_IMM32	9'hA9

`define AND_R		9'h37
`define AND_IMM4	9'h27
`define AND_IMM8	9'h25
`define AND_IMM16	9'h39
`define AND_IMM32	9'h29
`define AND_IMM		9'h29
`define AND_ZP		9'h25
`define AND_ZPX		9'h35
`define AND_IX		9'h21
`define AND_IY		9'h31
`define AND_IYL		9'h37
`define AND_ABS		9'h2D
`define AND_ABSX	9'h3D
`define AND_ABSY	9'h39
`define AND_RIND	9'h32
`define AND_I		9'h32
`define AND_IL		9'h27
`define AND_DSP		9'h23
`define AND_DSPIY	9'h33
`define AND_AL		9'h2F
`define AND_ALX		9'h3F

`define OR_R		9'h17
`define OR_IMM4		9'h07
`define OR_IMM8		9'h05
`define OR_IMM16	9'h19
`define OR_IMM32	9'h09
`define OR_ZPX		9'h15
`define OR_IX		9'h01
`define OR_IY		9'h11
`define OR_ABS		9'h0D
`define OR_ABSX		9'h1D
`define OR_RIND		9'h12
`define OR_DSP		9'h03

`define ORA_IMM		9'h09
`define ORA_ZP		9'h05
`define ORA_ZPX		9'h15
`define ORA_IX		9'h01
`define ORA_IY		9'h11
`define ORA_IYL		9'h17
`define ORA_ABS		9'h0D
`define ORA_ABSX	9'h1D
`define ORA_ABSY	9'h19
`define ORA_I		9'h12
`define ORA_IL		9'h07
`define ORA_AL		9'h0F
`define ORA_ALX		9'h1F
`define ORA_DSP		9'h03
`define ORA_DSPIY	9'h13

`define EOR_R		9'h57
`define EOR_IMM4	9'h47
`define EOR_IMM		9'h49
`define EOR_IMM8	9'h45
`define EOR_IMM16	9'h59
`define EOR_IMM32	9'h49
`define EOR_ZP		9'h45
`define EOR_ZPX		9'h55
`define EOR_IX		9'h41
`define EOR_IY		9'h51
`define EOR_IYL		9'h57
`define EOR_ABS		9'h4D
`define EOR_ABSX	9'h5D
`define EOR_ABSY	9'h59
`define EOR_RIND	9'h52
`define EOR_I		9'h52
`define EOR_IL		9'h47
`define EOR_DSP		9'h43
`define EOR_DSPIY	9'h53
`define EOR_AL		9'h4F
`define EOR_ALX		9'h5F

// LD is OR rt,r0,....

`define ST_ZPX		9'h95
`define ST_IX		9'h81
`define ST_IY		9'h91
`define ST_ABS		9'h8D
`define ST_ABSX		9'h9D
`define ST_RIND		9'h92
`define ST_DSP		9'h83

`define ORB_ZPX		9'hB5
`define ORB_IX		9'hA1
`define ORB_IY		9'hB1
`define ORB_ABS		9'hAD
`define ORB_ABSX	9'hBD

`define STB_ZPX		9'h74
`define STB_ABS		9'h9C
`define STB_ABSX	9'h9E


//`define LDB_RIND	9'hB2	// Conflict with LDX #imm16

`define LDA_IMM		9'hA9
`define LDA_ZP		9'hA5
`define LDA_ZPX		9'hB5
`define LDA_IX		9'hA1
`define LDA_IY		9'hB1
`define LDA_IYL		9'hB7
`define LDA_ABS		9'hAD
`define LDA_ABSX	9'hBD
`define LDA_ABSY	9'hB9
`define LDA_I		9'hB2
`define LDA_IL		9'hA7
`define LDA_AL		9'hAF
`define LDA_ALX		9'hBF
`define LDA_DSP		9'hA3
`define LDA_DSPIY	9'hB3

`define STA_ZP		9'h85
`define STA_ZPX		9'h95
`define STA_IX		9'h81
`define STA_IY		9'h91
`define STA_IYL		9'h97
`define STA_ABS		9'h8D
`define STA_ABSX	9'h9D
`define STA_ABSY	9'h99
`define STA_I		9'h92
`define STA_IL		9'h87
`define STA_AL		9'h8F
`define STA_ALX		9'h9F
`define STA_DSP		9'h83
`define STA_DSPIY	9'h93

`define ASL_IMM8	9'h24
`define ASL_ACC		9'h0A
`define ASL_ZP		9'h06
`define ASL_RR		9'h06
`define ASL_ZPX		9'h16
`define ASL_ABS		9'h0E
`define ASL_ABSX	9'h1E

`define ROL_ACC		9'h2A
`define ROL_ZP		9'h26
`define ROL_RR		9'h26
`define ROL_ZPX		9'h36
`define ROL_ABS		9'h2E
`define ROL_ABSX	9'h3E

`define LSR_IMM8	9'h34
`define LSR_ACC		9'h4A
`define LSR_ZP		9'h46
`define LSR_RR		9'h46
`define LSR_ZPX		9'h56
`define LSR_ABS		9'h4E
`define LSR_ABSX	9'h5E

`define ROR_RR		9'h66
`define ROR_ZP		9'h66
`define ROR_ZPX		9'h76
`define ROR_ABS		9'h6E
`define ROR_ABSX	9'h7E

`define DEC_RR		9'hC6
`define DEC_ZP		9'hC6
`define DEC_ZPX		9'hD6
`define DEC_ABS		9'hCE
`define DEC_ABSX	9'hDE
`define INC_RR		9'hE6
`define INC_ZP		9'hE6
`define INC_ZPX		9'hF6
`define INC_ABS		9'hEE
`define INC_ABSX	9'hFE

`define BIT_IMM		9'h89
`define BIT_ZP		9'h24
`define BIT_ZPX		9'h34
`define BIT_ABS		9'h2C
`define BIT_ABSX	9'h3C

// CMP = SUB r0,...
// BIT = AND r0,...
`define BPL			9'h10
`define BVC			9'h50
`define BCC			9'h90
`define BNE			9'hD0
`define BMI			9'h30
`define BVS			9'h70
`define BCS			9'hB0
`define BEQ			9'hF0
`define BRL			9'h82
`define BRA			9'h80
`define BHI			9'h13
`define BLS			9'h33
`define BGE			9'h93
`define BLT			9'hB3
`define BGT			9'hD3
`define BLE			9'hF3

`define JML			9'h5C
`define JMP			9'h4C
`define JMP_IND		9'h6C
`define JMP_INDX	9'h7C
`define JMP_RIND	9'hD2
`define JSR			9'h20
`define JSL			9'h22
`define JSR_IND		9'h2C
`define JSR_INDX	9'hFC
`define JSR_RIND	9'hC2
`define RTS			9'h60
`define RTL			9'h6B
`define BSR			9'h62
`define NOP			9'hEA

`define BRK			9'h00
`define PLX			9'hFA
`define PLY			9'h7A
`define PHX			9'hDA
`define PHY			9'h5A
`define WAI			9'hCB
`define PUSH		9'h0B
`define POP			9'h2B
`define PHB			9'h8B
`define PHD			9'h0B
`define PHK			9'h4B
`define XBA			9'hEB
`define COP			9'h02
`define PLB			9'hAB
`define PLD			9'h2B

`define LDX_IMM		9'hA2
`define LDX_ZP		9'hA6
`define LDX_ZPX		9'hB6
`define LDX_ZPY		9'hB6
`define LDX_ABS		9'hAE
`define LDX_ABSY	9'hBE

`define LDX_IMM32	9'hA2
`define LDX_IMM16	9'hB2
`define LDX_IMM8	9'hA6

`define LDY_IMM		9'hA0
`define LDY_ZP		9'hA4
`define LDY_ZPX		9'hB4
`define LDY_IMM32	9'hA0
`define LDY_ABS		9'hAC
`define LDY_ABSX	9'hBC

`define STX_ZP		9'h86
`define STX_ZPX		9'h96
`define STX_ZPY		9'h96
`define STX_ABS		9'h8E

`define STY_ZP		9'h84
`define STY_ZPX		9'h94
`define STY_ABS		9'h8C

`define STZ_ZP		9'h64
`define STZ_ZPX		9'h74
`define STZ_ABS		9'h9C
`define STZ_ABSX	9'h9E

`define CPX_IMM		9'hE0
`define CPX_IMM32	9'hE0
`define CPX_ZP		9'hE4
`define CPX_ZPX		9'hE4
`define CPX_ABS		9'hEC
`define CPY_IMM		9'hC0
`define CPY_IMM32	9'hC0
`define CPY_ZP		9'hC4
`define CPY_ZPX		9'hC4
`define CPY_ABS		9'hCC

`define TRB_ZP		9'h14
`define TRB_ZPX		9'h14
`define TRB_ABS		9'h1C
`define TSB_ZP		9'h04
`define TSB_ZPX		9'h04
`define TSB_ABS		9'h0C

`define BAZ			9'hC1
`define BXZ			9'hD1
`define BEQ_RR		9'hE2
`define INT0		9'hDC
`define INT1		9'hDD
`define SUB_SP8		9'h85
`define SUB_SP16	9'h99
`define SUB_SP32	9'h89
`define MVP			9'h44
`define MVN			9'h54
`define STS			9'h64
`define EXEC		9'hEB
`define ATNI		9'h4B
`define MDR			9'h3C

// Page Two Opcodes
`define PG2			9'h42

`define TOFF		9'h118
`define TON			9'h138
`define MUL_IMM8	9'h105
`define MUL_IMM16	9'h119
`define MUL_IMM32	9'h109
`define DIV_IMM8	9'h145
`define DIV_IMM16	9'h159
`define DIV_IMM32	9'h149
`define MOD_IMM8	9'h185
`define MOD_IMM16	9'h199
`define MOD_IMM32	9'h189
`define PUSHA		9'h10B
`define POPA		9'h12B
`define BMS_ZPX		9'h106
`define BMS_ABS		9'h10E
`define BMS_ABSX	9'h11E
`define BMC_ZPX		9'h126
`define BMC_ABS		9'h12E
`define BMC_ABSX	9'h13E
`define BMF_ZPX		9'h146
`define BMF_ABS		9'h14E
`define BMF_ABSX	9'h15E
`define BMT_ZPX		9'h166
`define BMT_ABS		9'h16E
`define BMT_ABSX	9'h17E
`define HOFF		9'h158
`define CMPS		9'h144
`define SPL_ABS		9'h18E
`define SPL_ABSX	9'h19E

`define LEA_ZPX		9'h1D5
`define LEA_IX		9'h1C1
`define LEA_IY		9'h1D1
`define LEA_ABS		9'h1CD
`define LEA_ABSX	9'h1DD
`define LEA_RIND	9'h1D2
`define LEA_I		9'h1D2
`define LEA_DSP		9'h1C3

`define NOTHING		5'd0
`define SR_70		5'd1
`define SR_310		5'd2
`define BYTE_70		5'd3
`define WORD_310	5'd4
`define PC_70		5'd5
`define PC_158		5'd6
`define PC_2316		5'd7
`define PC_3124		5'd8
`define PC_310		5'd9
`define WORD_311	5'd10
`define IA_310		5'd11
`define IA_70		5'd12
`define IA_158		5'd13
`define BYTE_71		5'd14
`define WORD_312	5'd15
`define WORD_313	5'd16
`define WORD_314	5'd17
`define IA_2316		5'd18
`define HALF_70		5'd19
`define HALF_158	5'd20
`define HALF_71		5'd21
`define HALF_159	5'd22
`define HALF_71S	5'd23
`define HALF_159S	5'd24
`define BYTE_72		5'd25

`define STW_DEF		6'h0
`define STW_ACC		6'd1
`define STW_X		6'd2
`define STW_Y		6'd3
`define STW_PC		6'd4
`define STW_PC2		6'd5
`define STW_PCHWI	6'd6
`define STW_SR		6'd7
`define STW_RFA		6'd8
`define STW_RFA8	6'd9
`define STW_A		6'd10
`define STW_B		6'd11
`define STW_CALC	6'd12
`define STW_OPC		6'd13
`define STW_RES8	6'd14

`define STW_ACC8	6'd16
`define STW_X8		6'd17
`define STW_Y8		6'd18
`define STW_PC3124	6'd19
`define STW_PC2316	6'd20
`define STW_PC158	6'd21
`define STW_PC70	6'd22
`define STW_SR70	6'd23
`define STW_Z8		6'd24
`define STW_DEF8	6'd25
`define STW_DEF70	6'd26
`define STW_DEF158	6'd27

`define STW_ACC70	6'd32
`define STW_ACC158	6'd33
`define STW_X70		6'd34
`define STW_X158	6'd35
`define STW_Y70		6'd36
`define STW_Y158	6'd37
`define STW_Z70		6'd38
`define STW_Z158	6'd39
`define STW_DBR		6'd40
`define STW_DPR158	6'd41
`define STW_DPR70	6'd42
`define STW_TMP158	6'd43
`define STW_TMP70	6'd44
`define STW_IA158	6'd45
`define STW_IA70	6'd46

`endif
