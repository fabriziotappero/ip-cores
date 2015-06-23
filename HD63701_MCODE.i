/***************************************************************************
       This file is part of "HD63701V0 Compatible Processor Core".
      ( DON'T ADD TO PROJECT, Because this file is include file. )
****************************************************************************/
`define MC_TRAP  {`mcINT,   `vaTRP  ,`mcrn,`mcpI,`amPC,`pcI}
`define MC_HALT  {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpH,`amPC,`pcN}

`define MC_NEXTI {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN}
`define MC_NEXTP {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI}

`define MC_LDBRO {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amPC,`pcI}	// Bxx NN
`define MC_LDIXO {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amPC,`pcI}	// ($NN+X)
`define MC_LDIXM {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcN}	// ($nn+X) => rE

`define MC_LDEXH {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amPC,`pcI}	// ($NNnn)
`define MC_LDEXL {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amPC,`pcI}	// ($nnNN)
`define MC_LDEXM {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amE0,`pcN}	// ($nnnn) => rT

function `mcwidth MCODE_S0;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h01: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpK,`amPC,`pcI};		// NOP
		8'h04: MCODE_S0 = {`mcLSR,`mcrD,`mcrn,`mcrD,`mcpK,`amPC,`pcI};		// LSRD
		8'h05: MCODE_S0 = {`mcASL,`mcrD,`mcrn,`mcrD,`mcpK,`amPC,`pcI};		// ASLD
		8'h06: MCODE_S0 = {`mcLDN,`mcrA,`mcrn,`mcrC,`mcpK,`amPC,`pcI};		// TAP
		8'h07: MCODE_S0 = {`mcLDN,`mcrC,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// TPA
		8'h08: MCODE_S0 = {`mcINC,`mcrX,`mcrn,`mcrX,`mcpK,`amPC,`pcI};		// INX
		8'h09: MCODE_S0 = {`mcDEC,`mcrX,`mcrn,`mcrX,`mcpK,`amPC,`pcI};		// DEX
		8'h0A: MCODE_S0 = {`mcCCB,  ~`bfV    ,`mcrC,`mcpK,`amPC,`pcI};		// CLV
		8'h0B: MCODE_S0 = {`mcSCB,   `bfV    ,`mcrC,`mcpK,`amPC,`pcI};		// SEV
		8'h0C: MCODE_S0 = {`mcCCB,  ~`bfC    ,`mcrC,`mcpK,`amPC,`pcI};		// CLC
		8'h0D: MCODE_S0 = {`mcSCB,   `bfC    ,`mcrC,`mcpK,`amPC,`pcI};		// SEC
		8'h0E: MCODE_S0 = {`mcCCB,  ~`bfI    ,`mcrC,`mcpK,`amPC,`pcI};		// CLI
		8'h0F: MCODE_S0 = {`mcSCB,   `bfI    ,`mcrC,`mcpK,`amPC,`pcI};		// SEI
//-----------------------------------------------------------------------------------------
		8'h10: MCODE_S0 = {`mcSUB,`mcrA,`mcrB,`mcrA,`mcpK,`amPC,`pcI};		// SBA
		8'h11: MCODE_S0 = {`mcSUB,`mcrA,`mcrB,`mcrn,`mcpK,`amPC,`pcI};		// CBA
		8'h12: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amS1,`pcI};		// (undoc1)
		8'h13: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amS1,`pcI};		// (undoc2)
		8'h16: MCODE_S0 = {`mcLDR,`mcrA,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// TAB
		8'h17: MCODE_S0 = {`mcLDR,`mcrB,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// TBA
		8'h18: MCODE_S0 = {`mcXTD,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// XGDX
		8'h19: MCODE_S0 = {`mcDAA,`mcrA,`mcrn,`mcrA,`mcp0,`amPC,`pcI};		// DAA
		8'h1A: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpS,`amPC,`pcI};		// SLP
		8'h1B: MCODE_S0 = {`mcADD,`mcrA,`mcrB,`mcrA,`mcpK,`amPC,`pcI};		// ABA
		8'h1F: MCODE_S0 = `MC_HALT;													// (DBGHLT)
//-----------------------------------------------------------------------------------------
		8'h20: MCODE_S0 = `MC_NEXTP;													// BRA
		8'h21: MCODE_S0 = `MC_NEXTP;													// BRN
		8'h22: MCODE_S0 = `MC_NEXTP;													// BHI
		8'h23: MCODE_S0 = `MC_NEXTP;													// BLS
		8'h24: MCODE_S0 = `MC_NEXTP;													// BCC
		8'h25: MCODE_S0 = `MC_NEXTP;													// BCS
		8'h26: MCODE_S0 = `MC_NEXTP;													// BNE
		8'h27: MCODE_S0 = `MC_NEXTP;													// BEQ
		8'h28: MCODE_S0 = `MC_NEXTP;													// BVC
		8'h29: MCODE_S0 = `MC_NEXTP;													// BVS
		8'h2A: MCODE_S0 = `MC_NEXTP;													// BPL
		8'h2B: MCODE_S0 = `MC_NEXTP;													// BMI
		8'h2C: MCODE_S0 = `MC_NEXTP;													// BGE
		8'h2D: MCODE_S0 = `MC_NEXTP;													// BLT
		8'h2E: MCODE_S0 = `MC_NEXTP;													// BGT
		8'h2F: MCODE_S0 = `MC_NEXTP;													// BLE
//-----------------------------------------------------------------------------------------
		8'h30: MCODE_S0 = {`mcINC,`mcrS,`mcrn,`mcrX,`mcpK,`amPC,`pcI};		// TSX
		8'h31: MCODE_S0 = {`mcINC,`mcrS,`mcrn,`mcrS,`mcpK,`amPC,`pcI};		// INS
		8'h32: MCODE_S0 = {`mcPUL,`mcrM,`mcrn,`mcrA,`mcpN,`amS1,`pcI};		// PULA
		8'h33: MCODE_S0 = {`mcPUL,`mcrM,`mcrn,`mcrB,`mcpN,`amS1,`pcI};		// PULB
		8'h34: MCODE_S0 = {`mcDEC,`mcrS,`mcrn,`mcrS,`mcpK,`amPC,`pcI};		// DES
		8'h35: MCODE_S0 = {`mcDEC,`mcrX,`mcrn,`mcrS,`mcpK,`amPC,`pcI};		// TXS
		8'h36: MCODE_S0 = {`mcPSH,`mcrA,`mcrn,`mcrM,`mcpN,`amSP,`pcI};		// PSHA
		8'h37: MCODE_S0 = {`mcPSH,`mcrB,`mcrn,`mcrM,`mcpN,`amSP,`pcI};		// PSHB
		8'h38: MCODE_S0 = {`mcINC,`mcrS,`mcrn,`mcrS,`mcpN,`amPC,`pcI};		// PULX
		8'h39: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// RTS
		8'h3A: MCODE_S0 = {`mcADD,`mcrX,`mcrB,`mcrX,`mcpK,`amPC,`pcI};		// ABX
		8'h3B: MCODE_S0 = {`mcPUL,`mcrM,`mcrn,`mcrT,`mcpN,`amS1,`pcN};		// RTI
		8'h3C: MCODE_S0 = {`mcDEC,`mcrS,`mcrn,`mcrS,`mcpN,`amPC,`pcI};		// PSHX
		8'h3D: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// MUL
		8'h3E: MCODE_S0 = {`mcINT,   `vaWAI  ,`mcrn,`mcpI,`amPC,`pcI};		// WAI
		8'h3F: MCODE_S0 = {`mcINT,   `vaSWI  ,`mcrn,`mcpI,`amPC,`pcI};		// SWI
//-----------------------------------------------------------------------------------------
		8'h40: MCODE_S0 = {`mcNEG,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// NEGA
		8'h43: MCODE_S0 = {`mcNOT,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// COMA
		8'h44: MCODE_S0 = {`mcLSR,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// LSRA
		8'h46: MCODE_S0 = {`mcROR,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// RORA
		8'h47: MCODE_S0 = {`mcASR,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// ASRA
		8'h48: MCODE_S0 = {`mcASL,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// ASLA
		8'h49: MCODE_S0 = {`mcROL,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// ROLA
		8'h4A: MCODE_S0 = {`mcDEC,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// DECA
		8'h4C: MCODE_S0 = {`mcINC,`mcrA,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// INCA
		8'h4D: MCODE_S0 = {`mcTST,`mcrA,`mcrn,`mcrn,`mcpK,`amPC,`pcI};		// TSTA
		8'h4F: MCODE_S0 = {`mcLDR,`mcrn,`mcrn,`mcrA,`mcpK,`amPC,`pcI};		// CLRA
//-----------------------------------------------------------------------------------------
		8'h50: MCODE_S0 = {`mcNEG,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// NEGB
		8'h53: MCODE_S0 = {`mcNOT,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// COMB
		8'h54: MCODE_S0 = {`mcLSR,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// LSRB
		8'h56: MCODE_S0 = {`mcROR,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// RORB
		8'h57: MCODE_S0 = {`mcASR,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// ASRB
		8'h58: MCODE_S0 = {`mcASL,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// ASLB
		8'h59: MCODE_S0 = {`mcROL,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// ROLB
		8'h5A: MCODE_S0 = {`mcDEC,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// DECB
		8'h5C: MCODE_S0 = {`mcINC,`mcrB,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// INCB
		8'h5D: MCODE_S0 = {`mcTST,`mcrB,`mcrn,`mcrn,`mcpK,`amPC,`pcI};		// TSTB
		8'h5F: MCODE_S0 = {`mcLDR,`mcrn,`mcrn,`mcrB,`mcpK,`amPC,`pcI};		// CLRB
//-----------------------------------------------------------------------------------------
		8'h60: MCODE_S0 = `MC_NEXTP;													// NEG($nn+X)
		8'h61: MCODE_S0 = `MC_NEXTP;													// AIM#,($nn+X)
		8'h62: MCODE_S0 = `MC_NEXTP;													// OIM#,($nn+X)
		8'h63: MCODE_S0 = `MC_NEXTP;													// COM($nn+X)
		8'h64: MCODE_S0 = `MC_NEXTP;													// LSR($nn+X)
		8'h65: MCODE_S0 = `MC_NEXTP;													// EIM#,($nn+X)
		8'h66: MCODE_S0 = `MC_NEXTP;													// ROR($nn+X)
		8'h67: MCODE_S0 = `MC_NEXTP;													// ASR($nn+X)
		8'h68: MCODE_S0 = `MC_NEXTP;													// ASL($nn+X)
		8'h69: MCODE_S0 = `MC_NEXTP;													// ROL($nn+X)
		8'h6A: MCODE_S0 = `MC_NEXTP;													// DEC($nn+X)
		8'h6B: MCODE_S0 = `MC_NEXTP;													// TIM#,($nn+X)
		8'h6C: MCODE_S0 = `MC_NEXTP;													// INC($nn+X)
		8'h6D: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// TST($nn+X)
		8'h6E: MCODE_S0 = `MC_NEXTP;													// JMP.$nn+X
		8'h6F: MCODE_S0 = `MC_NEXTP;													// CLR($nn+X)
//-----------------------------------------------------------------------------------------
		8'h70: MCODE_S0 = `MC_NEXTP;													// NEG($nnnn)
		8'h71: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// AIM#,($nn)
		8'h72: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// OIM#,($nn)
		8'h73: MCODE_S0 = `MC_NEXTP;													// COM($nnnn)
		8'h74: MCODE_S0 = `MC_NEXTP;													// LSR($nnnn)
		8'h75: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// EIM#,($nnnn)
		8'h76: MCODE_S0 = `MC_NEXTP;													// ROR($nnnn)
		8'h77: MCODE_S0 = `MC_NEXTP;													// ASR($nnnn)
		8'h78: MCODE_S0 = `MC_NEXTP;													// ASL($nnnn)
		8'h79: MCODE_S0 = `MC_NEXTP;													// ROL($nnnn)
		8'h7A: MCODE_S0 = `MC_NEXTP;													// DEC($nnnn)
		8'h7B: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// TIM#,($nn)
		8'h7C: MCODE_S0 = `MC_NEXTP;													// INC($nnnn)
		8'h7D: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// TST($nnnn)
		8'h7E: MCODE_S0 = `MC_NEXTP;													// JMP.$nnnn
		8'h7F: MCODE_S0 = `MC_NEXTP;													// CLR($nnnn)
//-----------------------------------------------------------------------------------------
		8'h80: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// SUBA#
		8'h81: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// CMPA#
		8'h82: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// SBCA#
		8'h83: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amP1,`pcI};		// SUBD#
		8'h84: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ANDA#
		8'h85: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// BITA#
		8'h86: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// LDA#
		8'h88: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// EORA#
		8'h89: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ADCA#
		8'h8A: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ORA#
		8'h8B: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ADDA#
		8'h8C: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amP1,`pcI};		// CMPX#
		8'h8D: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// BSR
		8'h8E: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amP1,`pcI};		// LDS#
//-----------------------------------------------------------------------------------------
		8'h90: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SUBA($nn)
		8'h91: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// CMPA($nn)
		8'h92: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SBCA($nn)
		8'h93: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SUBD($nn)
		8'h94: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ANDA($nn)
		8'h95: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// BITA($nn)
		8'h96: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDA($nn)
		8'h97: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STA($nn)
		8'h98: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// EORA($nn)
		8'h99: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADCA($nn)
		8'h9A: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ORA($nn)
		8'h9B: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADDA($nn)
		8'h9C: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// CMPX($nn)
		8'h9D: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// JSR($nn)
		8'h9E: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDS($nn)
		8'h9F: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STS($nn)
//-----------------------------------------------------------------------------------------
		8'hA0: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// SUBA($nn+X)
		8'hA1: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// CMPA($nn+X)
		8'hA2: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// SBCA($nn+X)
		8'hA3: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// SUBD($nn+X)
		8'hA4: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ANDA($nn+X)
		8'hA5: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// BITA($nn+X)
		8'hA6: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// LDA($nn+X)
		8'hA7: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// STA($nn+X)
		8'hA8: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// EORA($nn+X)
		8'hA9: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ADCA($nn+X)
		8'hAA: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ORA($nn+X)
		8'hAB: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ADDA($nn+X)
		8'hAC: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// CMPX($nn+X)
		8'hAD: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// JSR.$nn+X
		8'hAE: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// LDS($nn+X)
		8'hAF: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// STS($nn+X)
//-----------------------------------------------------------------------------------------
		8'hB0: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SUBA($nnnn)
		8'hB1: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// CMPA($nnnn)
		8'hB2: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SBCA($nnnn)
		8'hB3: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SUBD($nnnn)
		8'hB4: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ANDA($nnnn)
		8'hB5: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// BITA($nnnn)
		8'hB6: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDA($nnnn)
		8'hB7: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STA($nnnn)
		8'hB8: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// EORA($nnnn)
		8'hB9: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADCA($nnnn)
		8'hBA: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ORA($nnnn)
		8'hBB: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADDA($nnnn)
		8'hBC: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// CMPX($nnnn)
		8'hBD: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// JSR.$nnnn
		8'hBE: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDS($nnnn)
		8'hBF: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STS($nnnn)
//-----------------------------------------------------------------------------------------
		8'hC0: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// SUBB#
		8'hC1: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// CMPB#
		8'hC2: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// SBCB#
		8'hC3: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amP1,`pcI};		// ADDD#
		8'hC4: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ANDB#
		8'hC5: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// BITB#
		8'hC6: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// LDB#
		8'hC8: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// EORB#
		8'hC9: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ADCB#
		8'hCA: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ORB#
		8'hCB: MCODE_S0 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// ADDB#
		8'hCC: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amP1,`pcI};		// LDD#
		8'hCE: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amP1,`pcI};		// LDX#
//-----------------------------------------------------------------------------------------
		8'hD0: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SUBB($nn)
		8'hD1: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// CMPB($nn)
		8'hD2: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SBCB($nn)
		8'hD3: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADDD($nn)
		8'hD4: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ANDB($nn)
		8'hD5: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// BITB($nn)
		8'hD6: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDB($nn)
		8'hD7: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STB($nn)
		8'hD8: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// EORB($nn)
		8'hD9: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADCB($nn)
		8'hDA: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ORB($nn)
		8'hDB: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADDB($nn)
		8'hDC: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDD($nn)
		8'hDD: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STD($nn)
		8'hDE: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDX($nn)
		8'hDF: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STX($nn)
//-----------------------------------------------------------------------------------------
		8'hE0: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// SUBB($nn+X)
		8'hE1: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// CMPB($nn+X)
		8'hE2: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// SBCB($nn+X)
		8'hE3: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ADDD($nn+X)
		8'hE4: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ANDB($nn+X)
		8'hE5: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// BITB($nn+X)
		8'hE6: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// LDB($nn+X)
		8'hE7: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// STB($nn+X)
		8'hE8: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// EORB($nn+X)
		8'hE9: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ADCB($nn+X)
		8'hEA: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ORB($nn+X)
		8'hEB: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// ADDB($nn+X)
		8'hEC: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// LDD($nn+X)
		8'hED: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// STD($nn+X)
		8'hEE: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// LDX($nn+X)
		8'hEF: MCODE_S0 = {`mcLDN,`mcrM,`mcrn,`mcrT,`mcpN,`amP1,`pcI};		// STX($nn+X)
//-----------------------------------------------------------------------------------------
		8'hF0: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SUBB($nnnn)
		8'hF1: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// CMPB($nnnn)
		8'hF2: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// SBCB($nnnn)
		8'hF3: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADDD($nnnn)
		8'hF4: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ANDB($nnnn)
		8'hF5: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// BITB($nnnn)
		8'hF6: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDB($nnnn)
		8'hF7: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STB($nnnn)
		8'hF8: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// EORB($nnnn)
		8'hF9: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADCB($nnnn)
		8'hFA: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ORB($nnnn)
		8'hFB: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// ADDB($nnnn)
		8'hFC: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDD($nnnn)
		8'hFD: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STD($nnnn)
		8'hFE: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// LDX($nnnn)
		8'hFF: MCODE_S0 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// STX($nnnn)
//-----------------------------------------------------------------------------------------
	 default: MCODE_S0 = `MC_TRAP;
	endcase
end
endfunction


function `mcwidth MCODE_S1;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h12: MCODE_S1 = {`mcADD,`mcrX,`mcrT,`mcrX,`mcp0,`amPC,`pcN};		// (undoc1)
		8'h13: MCODE_S1 = {`mcADD,`mcrX,`mcrT,`mcrX,`mcp0,`amPC,`pcN};		// (undoc2)
		8'h18: MCODE_S1 = {`mcLDN,`mcrT,`mcrn,`mcrD,`mcp0,`amPC,`pcN};		// XGDX
//-----------------------------------------------------------------------------------------
		8'h20: MCODE_S1 = `MC_LDBRO;													// BRA
		8'h21: MCODE_S1 = `MC_LDBRO;													// BRN
		8'h22: MCODE_S1 = `MC_LDBRO;													// BHI
		8'h23: MCODE_S1 = `MC_LDBRO;													// BLS
		8'h24: MCODE_S1 = `MC_LDBRO;													// BCC
		8'h25: MCODE_S1 = `MC_LDBRO;													// BCS
		8'h26: MCODE_S1 = `MC_LDBRO;													// BNE
		8'h27: MCODE_S1 = `MC_LDBRO;													// BEQ
		8'h28: MCODE_S1 = `MC_LDBRO;													// BVC
		8'h29: MCODE_S1 = `MC_LDBRO;													// BVS
		8'h2A: MCODE_S1 = `MC_LDBRO;													// BPL
		8'h2B: MCODE_S1 = `MC_LDBRO;													// BMI
		8'h2C: MCODE_S1 = `MC_LDBRO;													// BGE
		8'h2D: MCODE_S1 = `MC_LDBRO;													// BLT
		8'h2E: MCODE_S1 = `MC_LDBRO;													// BGT
		8'h2F: MCODE_S1 = `MC_LDBRO;													// BLE
//-----------------------------------------------------------------------------------------
		8'h32: MCODE_S1 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// PULA
		8'h33: MCODE_S1 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// PULB
		8'h36: MCODE_S1 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// PSHA
		8'h37: MCODE_S1 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// PSHB
		8'h38: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrX,`mcpN,`amSP,`pcN};		// PULX
		8'h39: MCODE_S1 = {`mcINC,`mcrS,`mcrn,`mcrS,`mcpN,`amPC,`pcN};		// RTS
		8'h3B: MCODE_S1 = {`mcPUL,`mcrM,`mcrn,`mcrB,`mcpN,`amS1,`pcN};		// RTI
		8'h3C: MCODE_S1 = {`mcLDN,`mcrX,`mcrn,`mcrM,`mcpN,`amS1,`pcN};		// PSHX
		8'h3D: MCODE_S1 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// MUL
//-----------------------------------------------------------------------------------------
		8'h60: MCODE_S1 = `MC_LDIXO;													// NEG($nn+X)
		8'h61: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amPC,`pcI};		// AIM#,($nn+X)
		8'h62: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amPC,`pcI};		// OIM#,($nn+X)
		8'h63: MCODE_S1 = `MC_LDIXO;													// COM($nn+X)
		8'h64: MCODE_S1 = `MC_LDIXO;													// LSR($nn+X)
		8'h65: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amPC,`pcI};		// EIM#,($nn+X)
		8'h66: MCODE_S1 = `MC_LDIXO;													// ROR($nn+X)
		8'h67: MCODE_S1 = `MC_LDIXO;													// ASR($nn+X)
		8'h68: MCODE_S1 = `MC_LDIXO;													// ASL($nn+X)
		8'h69: MCODE_S1 = `MC_LDIXO;													// ROL($nn+X)
		8'h6A: MCODE_S1 = `MC_LDIXO;													// DEC($nn+X)
		8'h6B: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amPC,`pcI};		// TIM#,($nn+X)
		8'h6C: MCODE_S1 = `MC_LDIXO;													// INC($nn+X)
		8'h6D: MCODE_S1 = {`mcTST,`mcrM,`mcrn,`mcrn,`mcpN,`amXT,`pcI};		// TST($nn+X)
		8'h6E: MCODE_S1 = `MC_LDIXO;													// JMP.$nn+X
		8'h6F: MCODE_S1 = `MC_LDIXO;													// CLR($nn+X)
//-----------------------------------------------------------------------------------------
		8'h70: MCODE_S1 = `MC_LDEXH;													// NEG($nnnn)
		8'h71: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// AIM#,($nn)
		8'h72: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// OIM#,($nn)
		8'h73: MCODE_S1 = `MC_LDEXH;													// COM($nnnn)
		8'h74: MCODE_S1 = `MC_LDEXH;													// LSR($nnnn)
		8'h75: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// EIM#,($nnnn)
		8'h76: MCODE_S1 = `MC_LDEXH;													// ROR($nnnn)
		8'h77: MCODE_S1 = `MC_LDEXH;													// ASR($nnnn)
		8'h78: MCODE_S1 = `MC_LDEXH;													// ASL($nnnn)
		8'h79: MCODE_S1 = `MC_LDEXH;													// ROL($nnnn)
		8'h7A: MCODE_S1 = `MC_LDEXH;													// DEC($nnnn)
		8'h7B: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amP1,`pcI};		// TIM#,($nn)
		8'h7C: MCODE_S1 = `MC_LDEXH;													// INC($nnnn)
		8'h7D: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// TST($nnnn)
		8'h7E: MCODE_S1 = `MC_LDEXH;													// JMP.$nnnn
		8'h7F: MCODE_S1 = `MC_LDEXH;													// CLR($nnnn)
//-----------------------------------------------------------------------------------------
		8'h80: MCODE_S1 = {`mcSUB,`mcrA,`mcrM,`mcrA,`mcp0,`amPC,`pcI};		// SUBA#
		8'h81: MCODE_S1 = {`mcSUB,`mcrA,`mcrM,`mcrn,`mcp0,`amPC,`pcI};		// CMPA#
		8'h82: MCODE_S1 = {`mcSBC,`mcrA,`mcrM,`mcrA,`mcp0,`amPC,`pcI};		// SBCA#
		8'h83: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amP1,`pcI};		// SUBD#
		8'h84: MCODE_S1 = {`mcAND,`mcrA,`mcrM,`mcrA,`mcp0,`amPC,`pcI};		// ANDA#
		8'h85: MCODE_S1 = {`mcAND,`mcrA,`mcrM,`mcrn,`mcp0,`amPC,`pcI};		// BITA#
		8'h86: MCODE_S1 = {`mcLDR,`mcrM,`mcrn,`mcrA,`mcp0,`amPC,`pcI};		// LDA#
		8'h88: MCODE_S1 = {`mcEOR,`mcrA,`mcrM,`mcrA,`mcp0,`amPC,`pcI};		// EORA#
		8'h89: MCODE_S1 = {`mcADC,`mcrA,`mcrM,`mcrA,`mcp0,`amPC,`pcI};		// ADCA#
		8'h8A: MCODE_S1 = {`mcLOR,`mcrA,`mcrM,`mcrA,`mcp0,`amPC,`pcI};		// ORA#
		8'h8B: MCODE_S1 = {`mcADD,`mcrA,`mcrM,`mcrA,`mcp0,`amPC,`pcI};		// ADDA#
		8'h8C: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amP1,`pcI};		// CMPX#
		8'h8D: MCODE_S1 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// BSR
		8'h8E: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amP1,`pcI};		// LDS#
//-----------------------------------------------------------------------------------------
		8'h90: MCODE_S1 = {`mcSUB,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// SUBA($nn)
		8'h91: MCODE_S1 = {`mcSUB,`mcrA,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// CMPA($nn)
		8'h92: MCODE_S1 = {`mcSBC,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// SBCA($nn)
		8'h93: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amE0,`pcI};		// SUBD($nn)
		8'h94: MCODE_S1 = {`mcAND,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ANDA($nn)
		8'h95: MCODE_S1 = {`mcAND,`mcrA,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// BITA($nn)
		8'h96: MCODE_S1 = {`mcLDR,`mcrM,`mcrn,`mcrA,`mcpN,`amE0,`pcI};		// LDA($nn)
		8'h97: MCODE_S1 = {`mcLDR,`mcrA,`mcrn,`mcrM,`mcpN,`amE0,`pcI};		// STA($nn)
		8'h98: MCODE_S1 = {`mcEOR,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// EORA($nn)
		8'h99: MCODE_S1 = {`mcADC,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ADCA($nn)
		8'h9A: MCODE_S1 = {`mcLOR,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ORA($nn)
		8'h9B: MCODE_S1 = {`mcADD,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ADDA($nn)
		8'h9C: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrT,`mcpN,`amE0,`pcI};		// CMPX($nn)
		8'h9D: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amPC,`pcI};		// JSR($nn)
		8'h9E: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amE0,`pcI};		// LDS($nn)
		8'h9F: MCODE_S1 = {`mcLDN,`mcrS,`mcrn,`mcrN,`mcpN,`amE0,`pcI};		// STS($nn)
//-----------------------------------------------------------------------------------------
		8'hA0: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// SUBA($nn+X)
		8'hA1: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// CMPA($nn+X)
		8'hA2: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// SBCA($nn+X)
		8'hA3: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// SUBD($nn+X)
		8'hA4: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ANDA($nn+X)
		8'hA5: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// BITA($nn+X)
		8'hA6: MCODE_S1 = {`mcLDR,`mcrM,`mcrn,`mcrA,`mcpN,`amXT,`pcI};		// LDA($nn+X)
		8'hA7: MCODE_S1 = {`mcLDR,`mcrA,`mcrn,`mcrM,`mcpN,`amXT,`pcI};		// STA($nn+X)
		8'hA8: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// EORA($nn+X)
		8'hA9: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ADCA($nn+X)
		8'hAA: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ORA($nn+X)
		8'hAB: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ADDA($nn+X)
		8'hAC: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// CMPX($nn+X)
		8'hAD: MCODE_S1 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcI};		// JSR.$nn+X
		8'hAE: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// LDS($nn+X)
		8'hAF: MCODE_S1 = {`mcLDN,`mcrS,`mcrn,`mcrN,`mcpN,`amXT,`pcI};		// STS($nn+X)
//-----------------------------------------------------------------------------------------
		8'hB0: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// SUBA($nnnn)
		8'hB1: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// CMPA($nnnn)
		8'hB2: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// SBCA($nnnn)
		8'hB3: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// SUBD($nnnn)
		8'hB4: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ANDA($nnnn)
		8'hB5: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// BITA($nnnn)
		8'hB6: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// LDA($nnnn)
		8'hB7: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// STA($nnnn)
		8'hB8: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// EORA($nnnn)
		8'hB9: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ADCA($nnnn)
		8'hBA: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ORA($nnnn)
		8'hBB: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ADDA($nnnn)
		8'hBC: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// CMPX($nnnn)
		8'hBD: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amPC,`pcI};		// JSR.$nnnn
		8'hBE: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// LDS($nnnn)
		8'hBF: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// STS($nnnn)
//-----------------------------------------------------------------------------------------
		8'hC0: MCODE_S1 = {`mcSUB,`mcrB,`mcrM,`mcrB,`mcp0,`amPC,`pcI};		// SUBB#
		8'hC1: MCODE_S1 = {`mcSUB,`mcrB,`mcrM,`mcrn,`mcp0,`amPC,`pcI};		// CMPB#
		8'hC2: MCODE_S1 = {`mcSBC,`mcrB,`mcrM,`mcrB,`mcp0,`amPC,`pcI};		// SBCB#
		8'hC3: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amP1,`pcI};		// ADDD#
		8'hC4: MCODE_S1 = {`mcAND,`mcrB,`mcrM,`mcrB,`mcp0,`amPC,`pcI};		// ANDB#
		8'hC5: MCODE_S1 = {`mcAND,`mcrB,`mcrM,`mcrn,`mcp0,`amPC,`pcI};		// BITB#
		8'hC6: MCODE_S1 = {`mcLDR,`mcrM,`mcrn,`mcrB,`mcp0,`amPC,`pcI};		// LDB#
		8'hC8: MCODE_S1 = {`mcEOR,`mcrB,`mcrM,`mcrB,`mcp0,`amPC,`pcI};		// EORB#
		8'hC9: MCODE_S1 = {`mcADC,`mcrB,`mcrM,`mcrB,`mcp0,`amPC,`pcI};		// ADCB#
		8'hCA: MCODE_S1 = {`mcLOR,`mcrB,`mcrM,`mcrB,`mcp0,`amPC,`pcI};		// ORB#
		8'hCB: MCODE_S1 = {`mcADD,`mcrB,`mcrM,`mcrB,`mcp0,`amPC,`pcI};		// ADDB#
		8'hCC: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amP1,`pcI};		// LDD#
		8'hCE: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amP1,`pcI};		// LDX#
//-----------------------------------------------------------------------------------------
		8'hD0: MCODE_S1 = {`mcSUB,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// SUBB($nn)
		8'hD1: MCODE_S1 = {`mcSUB,`mcrB,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// CMPB($nn)
		8'hD2: MCODE_S1 = {`mcSBC,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// SBCB($nn)
		8'hD3: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amE0,`pcI};		// ADDD($nn)
		8'hD4: MCODE_S1 = {`mcAND,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ANDB($nn)
		8'hD5: MCODE_S1 = {`mcAND,`mcrB,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// BITB($nn)
		8'hD6: MCODE_S1 = {`mcLDR,`mcrM,`mcrn,`mcrB,`mcpN,`amE0,`pcI};		// LDB($nn)
		8'hD7: MCODE_S1 = {`mcLDR,`mcrB,`mcrn,`mcrM,`mcpN,`amE0,`pcI};		// STB($nn)
		8'hD8: MCODE_S1 = {`mcEOR,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// EORB($nn)
		8'hD9: MCODE_S1 = {`mcADC,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ADCB($nn)
		8'hDA: MCODE_S1 = {`mcLOR,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ORB($nn)
		8'hDB: MCODE_S1 = {`mcADD,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ADDB($nn)
		8'hDC: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrD,`mcpN,`amE0,`pcI};		// LDD($nn)
		8'hDD: MCODE_S1 = {`mcLDN,`mcrD,`mcrn,`mcrN,`mcpN,`amE0,`pcI};		// STD($nn)
		8'hDE: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrX,`mcpN,`amE0,`pcI};		// LDX($nn)
		8'hDF: MCODE_S1 = {`mcLDN,`mcrX,`mcrn,`mcrN,`mcpN,`amE0,`pcI};		// STX($nn)
//-----------------------------------------------------------------------------------------
		8'hE0: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// SUBB($nn+X)
		8'hE1: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// CMPB($nn+X)
		8'hE2: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// SBCB($nn+X)
		8'hE3: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ADDD($nn+X)
		8'hE4: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ANDB($nn+X)
		8'hE5: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// BITB($nn+X)
		8'hE6: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// LDB($nn+X)
		8'hE7: MCODE_S1 = {`mcLDN,`mcrB,`mcrn,`mcrM,`mcpN,`amXT,`pcI};		// STB($nn+X)
		8'hE8: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// EORB($nn+X)
		8'hE9: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ADCB($nn+X)
		8'hEA: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ORB($nn+X)
		8'hEB: MCODE_S1 = {`mcLDN,`mcrM,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// ADDB($nn+X)
		8'hEC: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// LDD($nn+X)
		8'hED: MCODE_S1 = {`mcLDN,`mcrD,`mcrn,`mcrN,`mcpN,`amXT,`pcI};		// STD($nn+X)
		8'hEE: MCODE_S1 = {`mcLDN,`mcrN,`mcrn,`mcrE,`mcpN,`amXT,`pcI};		// LDX($nn+X)
		8'hEF: MCODE_S1 = {`mcLDN,`mcrX,`mcrn,`mcrN,`mcpN,`amXT,`pcI};		// STX($nn+X)
//-----------------------------------------------------------------------------------------
		8'hF0: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// SUBB($nnnn)
		8'hF1: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// CMPB($nnnn)
		8'hF2: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// SBCB($nnnn)
		8'hF3: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ADDD($nnnn)
		8'hF4: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ANDB($nnnn)
		8'hF5: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// BITB($nnnn)
		8'hF6: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// LDB($nnnn)
		8'hF7: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// STB($nnnn)
		8'hF8: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// EORB($nnnn)
		8'hF9: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ADCB($nnnn)
		8'hFA: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ORB($nnnn)
		8'hFB: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// ADDB($nnnn)
		8'hFC: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// LDD($nnnn)
		8'hFD: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// STD($nnnn)
		8'hFE: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// LDX($nnnn)
		8'hFF: MCODE_S1 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// STX($nnnn)
//-----------------------------------------------------------------------------------------
	 default: MCODE_S1 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S2;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h20: MCODE_S2 = {`mcAPC,   `bfRA   ,`mcrn,`mcp0,`amPC,`pcN};		// BRA
		8'h21: MCODE_S2 = {`mcAPC,   `bfRN   ,`mcrn,`mcp0,`amPC,`pcN};		// BRN
		8'h22: MCODE_S2 = {`mcAPC,   `bfHI   ,`mcrn,`mcp0,`amPC,`pcN};		// BHI
		8'h23: MCODE_S2 = {`mcAPC,   `bfLS   ,`mcrn,`mcp0,`amPC,`pcN};		// BLS
		8'h24: MCODE_S2 = {`mcAPC,   `bfCC   ,`mcrn,`mcp0,`amPC,`pcN};		// BCC
		8'h25: MCODE_S2 = {`mcAPC,   `bfCS   ,`mcrn,`mcp0,`amPC,`pcN};		// BCS
		8'h26: MCODE_S2 = {`mcAPC,   `bfNE   ,`mcrn,`mcp0,`amPC,`pcN};		// BNE
		8'h27: MCODE_S2 = {`mcAPC,   `bfEQ   ,`mcrn,`mcp0,`amPC,`pcN};		// BEQ
		8'h28: MCODE_S2 = {`mcAPC,   `bfVC   ,`mcrn,`mcp0,`amPC,`pcN};		// BVC
		8'h29: MCODE_S2 = {`mcAPC,   `bfVS   ,`mcrn,`mcp0,`amPC,`pcN};		// BVS
		8'h2A: MCODE_S2 = {`mcAPC,   `bfPL   ,`mcrn,`mcp0,`amPC,`pcN};		// BPL
		8'h2B: MCODE_S2 = {`mcAPC,   `bfMI   ,`mcrn,`mcp0,`amPC,`pcN};		// BMI
		8'h2C: MCODE_S2 = {`mcAPC,   `bfGE   ,`mcrn,`mcp0,`amPC,`pcN};		// BGE
		8'h2D: MCODE_S2 = {`mcAPC,   `bfLT   ,`mcrn,`mcp0,`amPC,`pcN};		// BLT
		8'h2E: MCODE_S2 = {`mcAPC,   `bfGT   ,`mcrn,`mcp0,`amPC,`pcN};		// BGT
		8'h2F: MCODE_S2 = {`mcAPC,   `bfLE   ,`mcrn,`mcp0,`amPC,`pcN};		// BLE
//-----------------------------------------------------------------------------------------
		8'h32: MCODE_S2 = `MC_NEXTI;													// PULA
		8'h33: MCODE_S2 = `MC_NEXTI;													// PULB
		8'h36: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// PSHA
		8'h37: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// PSHB
		8'h38: MCODE_S2 = {`mcLOR,`mcrX,`mcrM,`mcrX,`mcpN,`amS1,`pcN};		// PULX
		8'h39: MCODE_S2 = {`mcLDN,`mcrN,`mcrn,`mcrP,`mcpN,`amSP,`pcN};		// RTS
		8'h3B: MCODE_S2 = {`mcPUL,`mcrM,`mcrn,`mcrA,`mcpN,`amS1,`pcN};		// RTI
		8'h3C: MCODE_S2 = {`mcLDN,`mcrX,`mcrn,`mcrN,`mcpN,`amSP,`pcN};		// PSHX
		8'h3D: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// MUL
//-----------------------------------------------------------------------------------------
		8'h60: MCODE_S2 = `MC_LDIXM;													// NEG($nn+X)
		8'h61: MCODE_S2 = `MC_LDIXO;													// AIM#,($nn+X)
		8'h62: MCODE_S2 = `MC_LDIXO;													// OIM#,($nn+X)
		8'h63: MCODE_S2 = `MC_LDIXM;													// COM($nn+X)
		8'h64: MCODE_S2 = `MC_LDIXM;													// LSR($nn+X)
		8'h65: MCODE_S2 = `MC_LDIXO;													// EIM#,($nn+X)
		8'h66: MCODE_S2 = `MC_LDIXM;													// ROR($nn+X)
		8'h67: MCODE_S2 = `MC_LDIXM;													// ASR($nn+X)
		8'h68: MCODE_S2 = `MC_LDIXM;													// ASL($nn+X)
		8'h69: MCODE_S2 = `MC_LDIXM;													// ROL($nn+X)
		8'h6A: MCODE_S2 = `MC_LDIXM;													// DEC($nn+X)
		8'h6B: MCODE_S2 = `MC_LDIXO;													// TIM#,($nn+X)
		8'h6C: MCODE_S2 = `MC_LDIXM;													// INC($nn+X)
		8'h6D: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// TST($nn+X)
		8'h6E: MCODE_S2 = {`mcADD,`mcrX,`mcrT,`mcrP,`mcp0,`amPC,`pcN};		// JMP.$nn+X
		8'h6F: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amXT,`pcN};		// CLR($nn+X)
//-----------------------------------------------------------------------------------------
		8'h70: MCODE_S2 = `MC_LDEXL;													// NEG($nnnn)
		8'h71: MCODE_S2 = {`mcAND,`mcrT,`mcrM,`mcrT,`mcpN,`amE0,`pcI};		// AIM#,($nn)
		8'h72: MCODE_S2 = {`mcLOR,`mcrT,`mcrM,`mcrT,`mcpN,`amE0,`pcI};		// OIM#,($nn)
		8'h73: MCODE_S2 = `MC_LDEXL;													// COM($nnnn)
		8'h74: MCODE_S2 = `MC_LDEXL;													// LSR($nnnn)
		8'h75: MCODE_S2 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amP1,`pcI};		// EIM#,($nnnn)
		8'h76: MCODE_S2 = `MC_LDEXL;													// ROR($nnnn)
		8'h77: MCODE_S2 = `MC_LDEXL;													// ASR($nnnn)
		8'h78: MCODE_S2 = `MC_LDEXL;													// ASL($nnnn)
		8'h79: MCODE_S2 = `MC_LDEXL;													// ROL($nnnn)
		8'h7A: MCODE_S2 = `MC_LDEXL;													// DEC($nnnn)
		8'h7B: MCODE_S2 = {`mcAND,`mcrT,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// TIM#,($nn)
		8'h7C: MCODE_S2 = `MC_LDEXL;													// INC($nnnn)
		8'h7D: MCODE_S2 = {`mcTST,`mcrM,`mcrn,`mcrn,`mcpN,`amE0,`pcI};		// TST($nnnn)
		8'h7E: MCODE_S2 = {`mcLOR,`mcrM,`mcrE,`mcrP,`mcp0,`amPC,`pcN};		// JMP.$nnnn
		8'h7F: MCODE_S2 = `MC_LDEXL;													// CLR($nnnn)
//-----------------------------------------------------------------------------------------
		8'h83: MCODE_S2 = {`mcSUB,`mcrD,`mcrT,`mcrD,`mcp0,`amPC,`pcI};		// SUBD#
		8'h8C: MCODE_S2 = {`mcSUB,`mcrX,`mcrT,`mcrn,`mcp0,`amPC,`pcI};		// CMPX#
		8'h8D: MCODE_S2 = {`mcPSH,`mcrP,`mcrn,`mcrM,`mcpN,`amSP,`pcN};		// BSR
		8'h8E: MCODE_S2 = {`mcLDR,`mcrT,`mcrn,`mcrS,`mcp0,`amPC,`pcI};		// LDS#
//-----------------------------------------------------------------------------------------
		8'h90: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SUBA($nn)
		8'h91: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// CMPA($nn)
		8'h92: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SBCA($nn)
		8'h93: MCODE_S2 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amE1,`pcN};		// SUBD($nn)
		8'h94: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ANDA($nn)
		8'h95: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// BITA($nn)
		8'h96: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// LDA($nn)
		8'h97: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// STA($nn)
		8'h98: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// EORA($nn)
		8'h99: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADCA($nn)
		8'h9A: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ORA($nn)
		8'h9B: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADDA($nn)
		8'h9C: MCODE_S2 = {`mcLOR,`mcrM,`mcrT,`mcrT,`mcpN,`amE1,`pcN};		// CMPX($nn)
		8'h9D: MCODE_S2 = {`mcPSH,`mcrP,`mcrn,`mcrM,`mcpN,`amSP,`pcN};		// JSR($nn)
		8'h9E: MCODE_S2 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amE1,`pcN};		// LDS($nn)
		8'h9F: MCODE_S2 = {`mcLDN,`mcrS,`mcrn,`mcrM,`mcpN,`amE1,`pcN};		// STS($nn)
//-----------------------------------------------------------------------------------------
		8'hA0: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// SUBA($nn+X)
		8'hA1: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// CMPA($nn+X)
		8'hA2: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// SBCA($nn+X)
		8'hA3: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// SUBD($nn+X)
		8'hA4: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ANDA($nn+X)
		8'hA5: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// BITA($nn+X)
		8'hA6: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// LDA($nn+X)
		8'hA7: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// STA($nn+X)
		8'hA8: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// EORA($nn+X)
		8'hA9: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ADCA($nn+X)
		8'hAA: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ORA($nn+X)
		8'hAB: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ADDA($nn+X)
		8'hAC: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// CMPX($nn+X)
		8'hAD: MCODE_S2 = {`mcPSH,`mcrP,`mcrn,`mcrM,`mcpN,`amSP,`pcN};		// JSR.$nn+X
		8'hAE: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// LDS($nn+X)
		8'hAF: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// STS($nn+X)
//-----------------------------------------------------------------------------------------
		8'hB0: MCODE_S2 = {`mcSUB,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// SUBA($nnnn)
		8'hB1: MCODE_S2 = {`mcSUB,`mcrA,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// CMPA($nnnn)
		8'hB2: MCODE_S2 = {`mcSBC,`mcrA,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// SBCA($nnnn)
		8'hB3: MCODE_S2 = {`mcLDN,`mcrN,`mcrn,`mcrT,`mcpN,`amE0,`pcI};		// SUBD($nnnn)
		8'hB4: MCODE_S2 = {`mcAND,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ANDA($nnnn)
		8'hB5: MCODE_S2 = {`mcAND,`mcrA,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// BITA($nnnn)
		8'hB6: MCODE_S2 = {`mcLDR,`mcrM,`mcrn,`mcrA,`mcpN,`amE0,`pcI};		// LDA($nnnn)
		8'hB7: MCODE_S2 = {`mcLDR,`mcrA,`mcrn,`mcrM,`mcpN,`amE0,`pcI};		// STA($nnnn)
		8'hB8: MCODE_S2 = {`mcEOR,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// EORA($nnnn)
		8'hB9: MCODE_S2 = {`mcADC,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ADCA($nnnn)
		8'hBA: MCODE_S2 = {`mcLOR,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ORA($nnnn)
		8'hBB: MCODE_S2 = {`mcADD,`mcrA,`mcrM,`mcrA,`mcpN,`amE0,`pcI};		// ADDA($nnnn)
		8'hBC: MCODE_S2 = {`mcLDN,`mcrN,`mcrn,`mcrT,`mcpN,`amE0,`pcI};		// CMPX($nnnn)
		8'hBD: MCODE_S2 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amPC,`pcI};		// JSR.$nnnn
		8'hBE: MCODE_S2 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amE0,`pcI};		// LDS($nnnn)
		8'hBF: MCODE_S2 = {`mcLDN,`mcrS,`mcrn,`mcrN,`mcpN,`amE0,`pcI};		// STS($nnnn)
//-----------------------------------------------------------------------------------------
		8'hC3: MCODE_S2 = {`mcADD,`mcrD,`mcrT,`mcrD,`mcp0,`amPC,`pcI};		// ADDD#
		8'hCC: MCODE_S2 = {`mcLDR,`mcrT,`mcrn,`mcrD,`mcp0,`amPC,`pcI};		// LDD#
		8'hCE: MCODE_S2 = {`mcLDR,`mcrT,`mcrn,`mcrX,`mcp0,`amPC,`pcI};		// LDX#
//-----------------------------------------------------------------------------------------
		8'hD0: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SUBB($nn)
		8'hD1: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// CMPB($nn)
		8'hD2: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SBCB($nn)
		8'hD3: MCODE_S2 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amE1,`pcN};		// ADDD($nn)
		8'hD4: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ANDB($nn)
		8'hD5: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// BITB($nn)
		8'hD6: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// LDB($nn)
		8'hD7: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// STB($nn)
		8'hD8: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// EORB($nn)
		8'hD9: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADCB($nn)
		8'hDA: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ORB($nn)
		8'hDB: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADDB($nn)
		8'hDC: MCODE_S2 = {`mcLOR,`mcrM,`mcrD,`mcrD,`mcpN,`amE1,`pcN};		// LDD($nn)
		8'hDD: MCODE_S2 = {`mcLDN,`mcrD,`mcrn,`mcrM,`mcpN,`amE1,`pcN};		// STD($nn)
		8'hDE: MCODE_S2 = {`mcLOR,`mcrM,`mcrX,`mcrX,`mcpN,`amE1,`pcN};		// LDX($nn)
		8'hDF: MCODE_S2 = {`mcLDN,`mcrX,`mcrn,`mcrM,`mcpN,`amE1,`pcN};		// STX($nn)
//-----------------------------------------------------------------------------------------
		8'hE0: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// SUBB($nn+X)
		8'hE1: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// CMPB($nn+X)
		8'hE2: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// SBCB($nn+X)
		8'hE3: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// ADDD($nn+X)
		8'hE4: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ANDB($nn+X)
		8'hE5: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// BITB($nn+X)
		8'hE6: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// LDB($nn+X)
		8'hE7: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// STB($nn+X)
		8'hE8: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// EORB($nn+X)
		8'hE9: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ADCB($nn+X)
		8'hEA: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ORB($nn+X)
		8'hEB: MCODE_S2 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ADDB($nn+X)
		8'hEC: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// LDD($nn+X)
		8'hED: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// STD($nn+X)
		8'hEE: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// LDX($nn+X)
		8'hEF: MCODE_S2 = {`mcINC,`mcrT,`mcrn,`mcrT,`mcpN,`amXT,`pcN};		// STX($nn+X)
//-----------------------------------------------------------------------------------------
		8'hF0: MCODE_S2 = {`mcSUB,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// SUBB($nnnn)
		8'hF1: MCODE_S2 = {`mcSUB,`mcrB,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// CMPB($nnnn)
		8'hF2: MCODE_S2 = {`mcSBC,`mcrB,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// SBCB($nnnn)
		8'hF3: MCODE_S2 = {`mcLDN,`mcrN,`mcrn,`mcrT,`mcpN,`amE0,`pcI};		// ADDD($nnnn)
		8'hF4: MCODE_S2 = {`mcAND,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ANDB($nnnn)
		8'hF5: MCODE_S2 = {`mcAND,`mcrB,`mcrM,`mcrn,`mcpN,`amE0,`pcI};		// BITB($nnnn)
		8'hF6: MCODE_S2 = {`mcLDR,`mcrM,`mcrn,`mcrB,`mcpN,`amE0,`pcI};		// LDB($nnnn)
		8'hF7: MCODE_S2 = {`mcLDR,`mcrB,`mcrn,`mcrM,`mcpN,`amE0,`pcI};		// STB($nnnn)
		8'hF8: MCODE_S2 = {`mcEOR,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// EORB($nnnn)
		8'hF9: MCODE_S2 = {`mcADC,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ADCB($nnnn)
		8'hFA: MCODE_S2 = {`mcLOR,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ORB($nnnn)
		8'hFB: MCODE_S2 = {`mcADD,`mcrB,`mcrM,`mcrB,`mcpN,`amE0,`pcI};		// ADDB($nnnn)
		8'hFC: MCODE_S2 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amE0,`pcI};		// LDD($nnnn)
		8'hFD: MCODE_S2 = {`mcLDN,`mcrD,`mcrn,`mcrN,`mcpN,`amE0,`pcI};		// STD($nnnn)
		8'hFE: MCODE_S2 = {`mcLDN,`mcrM,`mcrn,`mcrU,`mcpN,`amE0,`pcI};		// LDX($nnnn)
		8'hFF: MCODE_S2 = {`mcLDN,`mcrX,`mcrn,`mcrN,`mcpN,`amE0,`pcI};		// STX($nnnn)
//-----------------------------------------------------------------------------------------
	 default: MCODE_S2 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S3;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h36: MCODE_S3 = `MC_NEXTI;													// PSHA
		8'h37: MCODE_S3 = `MC_NEXTI;													// PSHB
		8'h38: MCODE_S3 = {`mcINC,`mcrS,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// PULX
		8'h39: MCODE_S3 = {`mcLOR,`mcrP,`mcrM,`mcrP,`mcpN,`amS1,`pcN};		// RTS
		8'h3B: MCODE_S3 = {`mcPUL,`mcrN,`mcrn,`mcrX,`mcpN,`amS1,`pcN};		// RTI
		8'h3C: MCODE_S3 = {`mcDEC,`mcrS,`mcrn,`mcrS,`mcpN,`amPC,`pcN};		// PSHX
		8'h3D: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// MUL
//-----------------------------------------------------------------------------------------
		8'h60: MCODE_S3 = {`mcNEG,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// NEG($nn+X)
		8'h61: MCODE_S3 = {`mcAND,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// AIM#,($nn+X)
		8'h62: MCODE_S3 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// OIM#,($nn+X)
		8'h63: MCODE_S3 = {`mcNOT,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// COM($nn+X)
		8'h64: MCODE_S3 = {`mcLSR,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// LSR($nn+X)
		8'h65: MCODE_S3 = {`mcEOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// EIM#,($nn+X)
		8'h66: MCODE_S3 = {`mcROR,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// ROR($nn+X)
		8'h67: MCODE_S3 = {`mcASR,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// ASR($nn+X)
		8'h68: MCODE_S3 = {`mcASL,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// ASL($nn+X)
		8'h69: MCODE_S3 = {`mcROL,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// ROL($nn+X)
		8'h6A: MCODE_S3 = {`mcDEC,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// DEC($nn+X)
		8'h6B: MCODE_S3 = {`mcAND,`mcrM,`mcrE,`mcrn,`mcpN,`amXT,`pcN};		// TIM#,($nn+X)
		8'h6C: MCODE_S3 = {`mcINC,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// INC($nn+X)
		8'h6D: MCODE_S3 = `MC_NEXTI;													// TST($nn+X)
		8'h6F: MCODE_S3 = {`mcLDN,`mcrn,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// CLR($nn+X)
//-----------------------------------------------------------------------------------------
		8'h70: MCODE_S3 = `MC_LDEXM;													// NEG($nnnn)
		8'h71: MCODE_S3 = {`mcLDN,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// AIM#,($nn)
		8'h72: MCODE_S3 = {`mcLDN,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// OIM#,($nn)
		8'h73: MCODE_S3 = `MC_LDEXM;													// COM($nnnn)
		8'h74: MCODE_S3 = `MC_LDEXM;													// LSR($nnnn)
		8'h75: MCODE_S3 = {`mcEOR,`mcrT,`mcrM,`mcrT,`mcpN,`amE0,`pcI};		// EIM#,($nnnn)
		8'h76: MCODE_S3 = `MC_LDEXM;													// ROR($nnnn)
		8'h77: MCODE_S3 = `MC_LDEXM;													// ASR($nnnn)
		8'h78: MCODE_S3 = `MC_LDEXM;													// ASL($nnnn)
		8'h79: MCODE_S3 = `MC_LDEXM;													// ROL($nnnn)
		8'h7A: MCODE_S3 = `MC_LDEXM;													// DEC($nnnn)
		8'h7B: MCODE_S3 = `MC_NEXTI;													// TIM#,($nn)
		8'h7C: MCODE_S3 = `MC_LDEXM;													// INC($nnnn)
		8'h7D: MCODE_S3 = `MC_NEXTI;													// TST($nnnn)
		8'h7F: MCODE_S3 = {`mcLDR,`mcrn,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// CLR($nnnn)
//-----------------------------------------------------------------------------------------
		8'h8D: MCODE_S3 = {`mcPSH,`mcrP,`mcrn,`mcrN,`mcpN,`amSP,`pcN};		// BSR
//-----------------------------------------------------------------------------------------
		8'h93: MCODE_S3 = {`mcSUB,`mcrD,`mcrT,`mcrD,`mcp0,`amPC,`pcN};		// SUBD($nn)
		8'h9C: MCODE_S3 = {`mcSUB,`mcrX,`mcrT,`mcrn,`mcp0,`amPC,`pcN};		// CMPX($nn)
		8'h9D: MCODE_S3 = {`mcPSH,`mcrP,`mcrn,`mcrN,`mcpN,`amSP,`pcN};		// JSR($nn)
		8'h9E: MCODE_S3 = {`mcLDR,`mcrT,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// LDS($nn)
		8'h9F: MCODE_S3 = {`mcLDR,`mcrS,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// STS($nn)
//-----------------------------------------------------------------------------------------
		8'hA0: MCODE_S3 = {`mcSUB,`mcrA,`mcrE,`mcrA,`mcp0,`amPC,`pcN};		// SUBA($nn+X)
		8'hA1: MCODE_S3 = {`mcSUB,`mcrA,`mcrE,`mcrn,`mcp0,`amPC,`pcN};		// CMPA($nn+X)
		8'hA2: MCODE_S3 = {`mcSBC,`mcrA,`mcrE,`mcrn,`mcp0,`amPC,`pcN};		// SBCA($nn+X)
		8'hA3: MCODE_S3 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// SUBD($nn+X)
		8'hA4: MCODE_S3 = {`mcAND,`mcrA,`mcrE,`mcrA,`mcp0,`amPC,`pcN};		// ANDA($nn+X)
		8'hA5: MCODE_S3 = {`mcAND,`mcrA,`mcrE,`mcrn,`mcp0,`amPC,`pcN};		// BITA($nn+X)
		8'hA6: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// LDA($nn+X)
		8'hA7: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// STA($nn+X)
		8'hA8: MCODE_S3 = {`mcEOR,`mcrA,`mcrE,`mcrA,`mcp0,`amPC,`pcN};		// EORA($nn+X)
		8'hA9: MCODE_S3 = {`mcADC,`mcrA,`mcrE,`mcrA,`mcp0,`amPC,`pcN};		// ADCA($nn+X)
		8'hAA: MCODE_S3 = {`mcLOR,`mcrA,`mcrE,`mcrA,`mcp0,`amPC,`pcN};		// ORA($nn+X)
		8'hAB: MCODE_S3 = {`mcADD,`mcrA,`mcrE,`mcrA,`mcp0,`amPC,`pcN};		// ADDA($nn+X)
		8'hAC: MCODE_S3 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// CMPX($nn+X)
		8'hAD: MCODE_S3 = {`mcPSH,`mcrP,`mcrn,`mcrN,`mcpN,`amSP,`pcN};		// JSR.$nn+X
		8'hAE: MCODE_S3 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// LDS($nn+X)
		8'hAF: MCODE_S3 = {`mcLDN,`mcrS,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// STS($nn+X)
//-----------------------------------------------------------------------------------------
		8'hB0: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SUBA($nnnn)
		8'hB1: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// CMPA($nnnn)
		8'hB2: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SBCA($nnnn)
		8'hB3: MCODE_S3 = {`mcLOR,`mcrM,`mcrT,`mcrT,`mcpN,`amE1,`pcN};		// SUBD($nnnn)
		8'hB4: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ANDA($nnnn)
		8'hB5: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// BITA($nnnn)
		8'hB6: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// LDA($nnnn)
		8'hB7: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// STA($nnnn)
		8'hB8: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// EORA($nnnn)
		8'hB9: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADCA($nnnn)
		8'hBA: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ORA($nnnn)
		8'hBB: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADDA($nnnn)
		8'hBC: MCODE_S3 = {`mcLOR,`mcrM,`mcrT,`mcrT,`mcpN,`amE1,`pcN};		// CMPX($nnnn)
		8'hBD: MCODE_S3 = {`mcPSH,`mcrP,`mcrn,`mcrM,`mcpN,`amSP,`pcN};		// JSR.$nnnn
		8'hBE: MCODE_S3 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amE1,`pcN};		// LDS($nnnn)
		8'hBF: MCODE_S3 = {`mcLDN,`mcrS,`mcrn,`mcrM,`mcpN,`amE1,`pcN};		// STS($nnnn)
//-----------------------------------------------------------------------------------------
		8'hD3: MCODE_S3 = {`mcADD,`mcrD,`mcrT,`mcrD,`mcp0,`amPC,`pcN};		// ADDD($nn)
		8'hDC: MCODE_S3 = {`mcLDR,`mcrD,`mcrn,`mcrD,`mcp0,`amPC,`pcN};		// LDD($nn)
		8'hDD: MCODE_S3 = {`mcLDR,`mcrD,`mcrn,`mcrD,`mcp0,`amPC,`pcN};		// STD($nn)
		8'hDE: MCODE_S3 = {`mcLDR,`mcrX,`mcrn,`mcrX,`mcp0,`amPC,`pcN};		// LDX($nn)
		8'hDF: MCODE_S3 = {`mcLDR,`mcrX,`mcrn,`mcrX,`mcp0,`amPC,`pcN};		// STX($nn)
//-----------------------------------------------------------------------------------------
		8'hE0: MCODE_S3 = {`mcSUB,`mcrB,`mcrE,`mcrB,`mcp0,`amPC,`pcN};		// SUBB($nn+X)
		8'hE1: MCODE_S3 = {`mcSUB,`mcrB,`mcrE,`mcrn,`mcp0,`amPC,`pcN};		// CMPB($nn+X)
		8'hE2: MCODE_S3 = {`mcSBC,`mcrB,`mcrE,`mcrB,`mcp0,`amPC,`pcN};		// SBCB($nn+X)
		8'hE3: MCODE_S3 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// ADDD($nn+X)
		8'hE4: MCODE_S3 = {`mcAND,`mcrB,`mcrE,`mcrB,`mcp0,`amPC,`pcN};		// ANDB($nn+X)
		8'hE5: MCODE_S3 = {`mcAND,`mcrB,`mcrE,`mcrn,`mcp0,`amPC,`pcN};		// BITB($nn+X)
		8'hE6: MCODE_S3 = {`mcLDR,`mcrE,`mcrn,`mcrB,`mcp0,`amPC,`pcN};		// LDB($nn+X)
		8'hE7: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// STB($nn+X)
		8'hE8: MCODE_S3 = {`mcEOR,`mcrB,`mcrE,`mcrB,`mcp0,`amPC,`pcN};		// EORB($nn+X)
		8'hE9: MCODE_S3 = {`mcADC,`mcrB,`mcrE,`mcrB,`mcp0,`amPC,`pcN};		// ADCB($nn+X)
		8'hEA: MCODE_S3 = {`mcLOR,`mcrB,`mcrE,`mcrB,`mcp0,`amPC,`pcN};		// ORB($nn+X)
		8'hEB: MCODE_S3 = {`mcADD,`mcrB,`mcrE,`mcrB,`mcp0,`amPC,`pcN};		// ADDB($nn+X)
		8'hEC: MCODE_S3 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// LDD($nn+X)
		8'hED: MCODE_S3 = {`mcLDN,`mcrD,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// STD($nn+X)
		8'hEE: MCODE_S3 = {`mcLOR,`mcrM,`mcrE,`mcrE,`mcpN,`amXT,`pcN};		// LDX($nn+X)
		8'hEF: MCODE_S3 = {`mcLDN,`mcrX,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// STX($nn+X)
//-----------------------------------------------------------------------------------------
		8'hF0: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SUBB($nnnn)
		8'hF1: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// CMPB($nnnn)
		8'hF2: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// SBCB($nnnn)
		8'hF3: MCODE_S3 = {`mcLOR,`mcrM,`mcrT,`mcrT,`mcpN,`amE1,`pcN};		// ADDD($nnnn)
		8'hF4: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ANDB($nnnn)
		8'hF5: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// BITB($nnnn)
		8'hF6: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// LDB($nnnn)
		8'hF7: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// STB($nnnn)
		8'hF8: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// EORB($nnnn)
		8'hF9: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADCB($nnnn)
		8'hFA: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ORB($nnnn)
		8'hFB: MCODE_S3 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// ADDB($nnnn)
		8'hFC: MCODE_S3 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amE1,`pcN};		// LDD($nnnn)
		8'hFD: MCODE_S3 = {`mcLDN,`mcrD,`mcrn,`mcrM,`mcpN,`amE1,`pcN};		// STD($nnnn)
		8'hFE: MCODE_S3 = {`mcLDN,`mcrM,`mcrn,`mcrV,`mcpN,`amE1,`pcN};		// LDX($nnnn)
		8'hFF: MCODE_S3 = {`mcLDN,`mcrX,`mcrn,`mcrM,`mcpN,`amE1,`pcN};		// STX($nnnn)
//-----------------------------------------------------------------------------------------
	 default: MCODE_S3 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S4;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h39: MCODE_S4 = {`mcINC,`mcrS,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// RTS
		8'h3B: MCODE_S4 = {`mcLOR,`mcrM,`mcrX,`mcrX,`mcpN,`amS1,`pcN};		// RTI
		8'h3C: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcp0,`amPC,`pcN};		// PSHX
		8'h3D: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// MUL
//-----------------------------------------------------------------------------------------
		8'h60: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// NEG($nn+X)
		8'h61: MCODE_S4 = {`mcLDN,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// AIM#,($nn+X)
		8'h62: MCODE_S4 = {`mcLDN,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// OIM#,($nn+X)
		8'h63: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// COM($nn+X)
		8'h64: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// LSR($nn+X)
		8'h65: MCODE_S4 = {`mcLDN,`mcrE,`mcrn,`mcrM,`mcpN,`amXT,`pcN};		// EIM#,($nn+X)
		8'h66: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ROR($nn+X)
		8'h67: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ASR($nn+X)
		8'h68: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ASL($nn+X)
		8'h69: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// ROL($nn+X)
		8'h6A: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// DEC($nn+X)
		8'h6B: MCODE_S4 = `MC_NEXTI;													// TIM#,($nn+X)
		8'h6C: MCODE_S4 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// INC($nn+X)
		8'h6F: MCODE_S4 = `MC_NEXTI;													// CLR($nn+X)
//-----------------------------------------------------------------------------------------
		8'h70: MCODE_S4 = {`mcNEG,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// NEG($nnnn)
		8'h71: MCODE_S4 = `MC_NEXTI;													// AIM#,($nn)
		8'h72: MCODE_S4 = `MC_NEXTI;													// OIM#,($nn)
		8'h73: MCODE_S4 = {`mcNOT,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// COM($nnnn)
		8'h74: MCODE_S4 = {`mcLSR,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// LSR($nnnn)
		8'h75: MCODE_S4 = {`mcLDN,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// EIM#,($nnnn)
		8'h76: MCODE_S4 = {`mcROR,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// ROR($nnnn)
		8'h77: MCODE_S4 = {`mcASR,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// ASR($nnnn)
		8'h78: MCODE_S4 = {`mcASL,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// ASL($nnnn)
		8'h79: MCODE_S4 = {`mcROL,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// ROL($nnnn)
		8'h7A: MCODE_S4 = {`mcDEC,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// DEC($nnnn)
		8'h7C: MCODE_S4 = {`mcINC,`mcrT,`mcrn,`mcrM,`mcpN,`amE0,`pcN};		// INC($nnnn)
		8'h7F: MCODE_S4 = `MC_NEXTI;													// CLR($nnnn)
//-----------------------------------------------------------------------------------------
		8'h8D: MCODE_S4 = {`mcAPC,   `bfRA   ,`mcrn,`mcp0,`amPC,`pcN};		// BSR
//-----------------------------------------------------------------------------------------
		8'h9D: MCODE_S4 = {`mcLDN,`mcrE,`mcrn,`mcrP,`mcp0,`amPC,`pcN};		// JSR($nn)
//-----------------------------------------------------------------------------------------
		8'hA3: MCODE_S4 = {`mcSUB,`mcrD,`mcrE,`mcrD,`mcp0,`amPC,`pcN};		// SUBD($nn+X)
		8'hAC: MCODE_S4 = {`mcSUB,`mcrX,`mcrE,`mcrn,`mcp0,`amPC,`pcN};		// CMPX($nn+X)
		8'hAD: MCODE_S4 = {`mcADD,`mcrX,`mcrT,`mcrP,`mcp0,`amPC,`pcN};		// JSR.$nn+X
		8'hAE: MCODE_S4 = {`mcLDR,`mcrE,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// LDS($nn+X)
		8'hAF: MCODE_S4 = {`mcLDR,`mcrS,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// STS($nn+X)
//-----------------------------------------------------------------------------------------
		8'hB3: MCODE_S4 = {`mcSUB,`mcrD,`mcrT,`mcrD,`mcp0,`amPC,`pcN};		// SUBD($nnnn)
		8'hBC: MCODE_S4 = {`mcSUB,`mcrX,`mcrT,`mcrn,`mcp0,`amPC,`pcN};		// CMPX($nnnn)
		8'hBD: MCODE_S4 = {`mcPSH,`mcrP,`mcrn,`mcrN,`mcpN,`amSP,`pcN};		// JSR.$nnnn
		8'hBE: MCODE_S4 = {`mcLDR,`mcrT,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// LDS($nnnn)
		8'hBF: MCODE_S4 = {`mcLDR,`mcrS,`mcrn,`mcrS,`mcp0,`amPC,`pcN};		// STS($nnnn)
//-----------------------------------------------------------------------------------------
		8'hE3: MCODE_S4 = {`mcADD,`mcrD,`mcrE,`mcrD,`mcp0,`amPC,`pcN};		// ADDD($nn+X)
		8'hEC: MCODE_S4 = {`mcLDR,`mcrE,`mcrn,`mcrD,`mcp0,`amPC,`pcN};		// LDD($nn+X)
		8'hED: MCODE_S4 = {`mcLDR,`mcrD,`mcrn,`mcrD,`mcp0,`amPC,`pcN};		// STD($nn+X)
		8'hEE: MCODE_S4 = {`mcLDN,`mcrE,`mcrn,`mcrX,`mcp0,`amPC,`pcN};		// LDX($nn+X)
		8'hEF: MCODE_S4 = {`mcLDR,`mcrX,`mcrn,`mcrX,`mcp0,`amPC,`pcN};		// STX($nn+X)
//-----------------------------------------------------------------------------------------
		8'hF3: MCODE_S4 = {`mcADD,`mcrD,`mcrT,`mcrD,`mcp0,`amPC,`pcN};		// ADDD($nnnn)
		8'hFC: MCODE_S4 = {`mcLDR,`mcrT,`mcrn,`mcrD,`mcp0,`amPC,`pcN};		// LDD($nnnn)
		8'hFD: MCODE_S4 = {`mcLDR,`mcrD,`mcrn,`mcrD,`mcp0,`amPC,`pcN};		// STD($nnnn)
		8'hFE: MCODE_S4 = {`mcLDR,`mcrT,`mcrn,`mcrX,`mcp0,`amPC,`pcN};		// LDX($nnnn)
		8'hFF: MCODE_S4 = {`mcLDR,`mcrX,`mcrn,`mcrX,`mcp0,`amPC,`pcN};		// STX($nnnn)
//-----------------------------------------------------------------------------------------
	 default: MCODE_S4 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S5;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h3B: MCODE_S5 = {`mcINC,`mcrS,`mcrn,`mcrS,`mcpN,`amS1,`pcN};		// RTI
		8'h3D: MCODE_S5 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// MUL
//-----------------------------------------------------------------------------------------
		8'h60: MCODE_S5 = `MC_NEXTI;													// NEG($nn+X)
		8'h61: MCODE_S5 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// AIM#,($nn+X)
		8'h62: MCODE_S5 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// OIM#,($nn+X)
		8'h63: MCODE_S5 = `MC_NEXTI;													// COM($nn+X)
		8'h64: MCODE_S5 = `MC_NEXTI;													// LSR($nn+X)
		8'h65: MCODE_S5 = {`mcNOP,`mcrn,`mcrn,`mcrn,`mcpN,`amPC,`pcN};		// EIM#,($nn+X)
		8'h66: MCODE_S5 = `MC_NEXTI;													// ROR($nn+X)
		8'h67: MCODE_S5 = `MC_NEXTI;													// ASR($nn+X)
		8'h68: MCODE_S5 = `MC_NEXTI;													// ASL($nn+X)
		8'h69: MCODE_S5 = `MC_NEXTI;													// ROL($nn+X)
		8'h6A: MCODE_S5 = `MC_NEXTI;													// DEC($nn+X)
		8'h6C: MCODE_S5 = `MC_NEXTI;													// INC($nn+X)
//-----------------------------------------------------------------------------------------
		8'h70: MCODE_S5 = `MC_NEXTI;													// NEG($nnnn)
		8'h73: MCODE_S5 = `MC_NEXTI;													// COM($nnnn)
		8'h74: MCODE_S5 = `MC_NEXTI;													// LSR($nnnn)
		8'h75: MCODE_S5 = `MC_NEXTI;													// EIM#,($nnnn)
		8'h76: MCODE_S5 = `MC_NEXTI;													// ROR($nnnn)
		8'h77: MCODE_S5 = `MC_NEXTI;													// ASR($nnnn)
		8'h78: MCODE_S5 = `MC_NEXTI;													// ASL($nnnn)
		8'h79: MCODE_S5 = `MC_NEXTI;													// ROL($nnnn)
		8'h7A: MCODE_S5 = `MC_NEXTI;													// DEC($nnnn)
		8'h7C: MCODE_S5 = `MC_NEXTI;													// INC($nnnn)
//-----------------------------------------------------------------------------------------
		8'hBD: MCODE_S5 = {`mcLDN,`mcrE,`mcrn,`mcrP,`mcp0,`amPC,`pcN};		// JSR.$nnnn
//-----------------------------------------------------------------------------------------
	 default: MCODE_S5 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S6;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h3B: MCODE_S6 = {`mcPUL,`mcrN,`mcrn,`mcrP,`mcpN,`amS1,`pcN};		// RTI
		8'h3D: MCODE_S6 = {`mcMUL,`mcrA,`mcrB,`mcrD,`mcp0,`amPC,`pcI};		// MUL
//-----------------------------------------------------------------------------------------
		8'h61: MCODE_S6 = `MC_NEXTI;													// AIM#,($nn+X)
		8'h62: MCODE_S6 = `MC_NEXTI;													// OIM#,($nn+X)
		8'h65: MCODE_S6 = `MC_NEXTI;													// EIM#,($nn+X)
//-----------------------------------------------------------------------------------------
	 default: MCODE_S6 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S7;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h3B: MCODE_S7 = {`mcLOR,`mcrM,`mcrP,`mcrP,`mcpN,`amS1,`pcN};		// RTI
//-----------------------------------------------------------------------------------------
	 default: MCODE_S7 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S8;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h3B: MCODE_S8 = {`mcINC,`mcrS,`mcrn,`mcrS,`mcpN,`amPC,`pcN};		// RTI
//-----------------------------------------------------------------------------------------
	 default: MCODE_S8 = `MC_HALT;
	endcase
end
endfunction


function `mcwidth MCODE_S9;
input [7:0] opc;
begin
	case (opc)
//-----------------------------------------------------------------------------------------
		8'h3B: MCODE_S9 = {`mcLDN,`mcrT,`mcrn,`mcrC,`mcp0,`amPC,`pcN};		// RTI
//-----------------------------------------------------------------------------------------
	 default: MCODE_S9 = `MC_HALT;
	endcase
end
endfunction


