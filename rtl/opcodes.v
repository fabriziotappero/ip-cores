///////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               //
//  file name:   opcodes.v                                                                       //
//  description: opcode parameters for z80                                                       //
//  project:     wb_z80                                                                          //
//                                                                                               //
//  Author: B.J. Porcella                                                                        //
//  e-mail: bporcella@sbcglobal.net                                                              //
//                                                                                               //
//                                                                                               //
//                                                                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                               //
// Copyright (C) 2000-2002 B.J. Porcella                                                         //
//                         Real Time Solutions                                                   //
//                                                                                               //
//                                                                                               //
// This source file may be used and distributed without                                          //
// restriction provided that this copyright statement is not                                     //
// removed from the file and that any derivative work contains                                   //
// the original copyright notice and the associated disclaimer.                                  //
//                                                                                               //
//     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY                                       //
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED                                     //
// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS                                     //
// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR                                        //
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,                                           //
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES                                      //
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE                                     //
// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR                                          //
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF                                    //
// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT                                    //
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT                                    //
// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE                                           //
// POSSIBILITY OF SUCH DAMAGE.                                                                   //
//                                                                                               //
//-------1---------2---------3--------Comments on file  -------------7---------8---------9--------0
// This file is fundamentally a hack of an opcode file found on:
//     http://www.z80.info/  (perhaps written by Thomas Scherrer)
//
// The purpose of the origiional file was to aid in low level z80 software debug.
// Here, we are trying to make the parameters we use for instruction decoding
// as easy to understand as possible.
//
//
// Note how assembler syntax is transformed 
// into verilog symbols.    
// 
//
// I'm going to define all parameters as standard integer length as they will be used
// in comparisons of various lengths..............   
// generally 8 bits, but there is 3 bit extension that may apply to any parameter...
//    0
//    1  CBgrp   (shifts and Bit banging)
//    2  DDgrp   (mostly indexed addressing)
//    3  DDCBgrp  (indexed bit banging)
//    3  EDgrp   (a wild mix of stuff )
//    4  FDgrp    (more indexed stuff )
//    5  FDCBgrp   (indexed bit banging)
//
//
//-------1---------2---------3--------CVS Log -----------------------7---------8---------9--------0
//
//  $Id: opcodes.v,v 1.5 2007-10-02 20:25:12 bporcella Exp $
//
//  $Date: 2007-10-02 20:25:12 $
//  $Revision: 1.5 $
//  $Author: bporcella $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//      $Log: not supported by cvs2svn $
//      Revision 1.4  2004/05/27 14:23:36  bporcella
//      Instruction test (with interrupts) runs!!!
//
//      Revision 1.3  2004/05/21 02:51:25  bporcella
//      inst test  got to the worked macro
//
//      Revision 1.2  2004/05/18 22:31:20  bporcella
//      instruction test getting to final stages
//
//      Revision 1.1  2004/04/17 18:26:06  bporcella
//      put this here to try an end-run around lint mikefile problem
//
//      Revision 1.1.1.1  2004/04/13 23:47:56  bporcella
//      import first files
//
//
//
//-------1---------2---------3--------Comments on file  -------------7---------8---------9--------0
//
parameter  NOP          = 10'h00,//      NOP         ; 00
           LDsBC_NN     = 10'h01,//      LD BC,NN    ; 01 XX XX
           LDs6BC7_A    = 10'h02,//      LD (BC),A   ; 02 
           INCsBC       = 10'h03,//      INC BC      ; 03
           INCsB        = 10'h04,//      INC B       ; 04
           DECsB        = 10'h05,//      DEC B       ; 05
           LDsB_N       = 10'h06,//      LD B,N      ; 06 XX
           RLCA         = 10'h07,//      RLCA        ; 07
           EXsAF_AFp    = 10'h08,//      EX AF,AF'   ; 08
           ADDsHL_BC    = 10'h09,//      ADD HL,BC   ; 09
           LDsA_6BC7    = 10'h0A,//      LD A,(BC)   ; 0A
           DECsBC       = 10'h0B,//      DEC BC      ; 0B
           INCsC        = 10'h0C,//      INC C       ; 0C
           DECsC        = 10'h0D,//      DEC C       ; 0D
           LDsC_N       = 10'h0E,//      LD C,N      ; 0E XX
           RRCA         = 10'h0F,//      RRCA        ; 0F
           DJNZs$t2     = 10'h10,//      DJNZ $+2     ; 10 XX
           LDsDE_NN     = 10'h11,//      LD DE,NN     ; 11 XX XX
           LDs6DE7_A    = 10'h12,//      LD (DE),A    ; 12
           INCsDE       = 10'h13,//      INC DE       ; 13
           INCsD        = 10'h14,//      INC D        ; 14
           DECsD        = 10'h15,//      DEC D        ; 15
           LDsD_N       = 10'h16,//      LD D,N       ; 16 XX
           RLA          = 10'h17,//      RLA          ; 17
           JRs$t2       = 10'h18,//      JR $+2       ; 18 XX
           ADDsHL_DE    = 10'h19,//      ADD HL,DE    ; 19
           LDsA_6DE7    = 10'h1A,//      LD A,(DE)    ; 1A
           DECsDE       = 10'h1B,//      DEC DE       ; 1B
           INCsE        = 10'h1C,//      INC E        ; 1C
           DECsE        = 10'h1D,//      DEC E        ; 1D
           LDsE_N       = 10'h1E,//      LD E,N       ; 1E XX
           RRA          = 10'h1F,//      RRA          ; 1F
           JRsNZ_$t2    = 10'h20,//      JR NZ,$+2    ; 20
           LDsHL_NN     = 10'h21,//      LD HL,NN     ; 21 XX XX
           LDs6NN7_HL   = 10'h22,//      LD (NN),HL   ; 22 XX XX
           INCsHL       = 10'h23,//      INC HL       ; 23
           INCsH        = 10'h24,//      INC H        ; 24
           DECsH        = 10'h25,//      DEC H        ; 25
           LDsH_N       = 10'h26,//      LD H,N       ; 26 XX
           DAA          = 10'h27,//      DAA          ; 27
           JRsZ_$t2     = 10'h28,//      JR Z,$+2     ; 28 XX
           ADDsHL_HL    = 10'h29,//      ADD HL,HL    ; 29
           LDsHL_6NN7   = 10'h2A,//      LD HL,(NN)   ; 2A XX XX
           DECsHL       = 10'h2B,//      DEC HL       ; 2B
           INCsL        = 10'h2C,//      INC L        ; 2C
           DECsL        = 10'h2D,//      DEC L        ; 2D
           LDsL_N       = 10'h2E,//      LD L,N       ; 2E XX
           CPL          = 10'h2F,//      CPL          ; 2F
           JRsNC_$t2    = 10'h30,//      JR NC,$+2    ; 30 XX
           LDsSP_NN     = 10'h31,//      LD SP,NN     ; 31 XX XX
           LDs6NN7_A    = 10'h32,//      LD (NN),A    ; 32 XX XX
           INCsSP       = 10'h33,//      INC SP       ; 33
           INCs6HL7     = 10'h34,//      INC (HL)     ; 34
           DECs6HL7     = 10'h35,//      DEC (HL)     ; 35
           LDs6HL7_N    = 10'h36,//      LD (HL),N    ; 36 XX
           SCF          = 10'h37,//      SCF          ; 37
           JRsC_$t2     = 10'h38,//      JR C,$+2     ; 38 XX
           ADDsHL_SP    = 10'h39,//      ADD HL,SP    ; 39
           LDsA_6NN7    = 10'h3A,//      LD A,(NN)    ; 3A XX XX
           DECsSP       = 10'h3B,//      DEC SP       ; 3B
           INCsA        = 10'h3C,//      INC A        ; 3C
           DECsA        = 10'h3D,//      DEC A        ; 3D
           LDsA_N       = 10'h3E,//      LD A,N       ; 3E XX
           CCF          = 10'h3F,//      CCF          ; 3F
           LDsB_B       = 10'h40,//      LD B,B       ; 40
           LDsB_C       = 10'h41,//      LD B,C       ; 41
           LDsB_D       = 10'h42,//      LD B,D       ; 42
           LDsB_E       = 10'h43,//      LD B,E       ; 43
           LDsB_H       = 10'h44,//      LD B,H       ; 44
           LDsB_L       = 10'h45,//      LD B,L       ; 45
           LDsB_6HL7    = 10'h46,//      LD B,(HL)    ; 46
           LDsB_A       = 10'h47,//      LD B,A       ; 47
           LDsC_B       = 10'h48,//      LD C,B       ; 48
           LDsC_C       = 10'h49,//      LD C,C       ; 49
           LDsC_D       = 10'h4A,//      LD C,D       ; 4A
           LDsC_E       = 10'h4B,//      LD C,E       ; 4B
           LDsC_H       = 10'h4C,//      LD C,H       ; 4C
           LDsC_L       = 10'h4D,//      LD C,L       ; 4D
           LDsC_6HL7    = 10'h4E,//      LD C,(HL)    ; 4E
           LDsC_A       = 10'h4F,//      LD C,A       ; 4F
           LDsD_B       = 10'h50,//      LD D,B       ; 50
           LDsD_C       = 10'h51,//      LD D,C       ; 51
           LDsD_D       = 10'h52,//      LD D,D       ; 52
           LDsD_E       = 10'h53,//      LD D,E       ; 53
           LDsD_H       = 10'h54,//      LD D,H       ; 54
           LDsD_L       = 10'h55,//      LD D,L       ; 55
           LDsD_6HL7    = 10'h56,//      LD D,(HL)    ; 56
           LDsD_A       = 10'h57,//      LD D,A       ; 57
           LDsE_B       = 10'h58,//      LD E,B       ; 58
           LDsE_C       = 10'h59,//      LD E,C       ; 59
           LDsE_D       = 10'h5A,//      LD E,D       ; 5A
           LDsE_E       = 10'h5B,//      LD E,E       ; 5B
           LDsE_H       = 10'h5C,//      LD E,H       ; 5C
           LDsE_L       = 10'h5D,//      LD E,L       ; 5D
           LDsE_6HL7    = 10'h5E,//      LD E,(HL)    ; 5E
           LDsE_A       = 10'h5F,//      LD E,A       ; 5F
           LDsH_B       = 10'h60,//      LD H,B       ; 60
           LDsH_C       = 10'h61,//      LD H,C       ; 61
           LDsH_D       = 10'h62,//      LD H,D       ; 62
           LDsH_E       = 10'h63,//      LD H,E       ; 63
           LDsH_H       = 10'h64,//      LD H,H       ; 64
           LDsH_L       = 10'h65,//      LD H,L       ; 65
           LDsH_6HL7    = 10'h66,//      LD H,(HL)    ; 66
           LDsH_A       = 10'h67,//      LD H,A       ; 67
           LDsL_B       = 10'h68,//      LD L,B       ; 68
           LDsL_C       = 10'h69,//      LD L,C       ; 69
           LDsL_D       = 10'h6A,//      LD L,D       ; 6A
           LDsL_E       = 10'h6B,//      LD L,E       ; 6B
           LDsL_H       = 10'h6C,//      LD L,H       ; 6C
           LDsL_L       = 10'h6D,//      LD L,L       ; 6D
           LDsL_6HL7    = 10'h6E,//      LD L,(HL)    ; 6E
           LDsL_A       = 10'h6F,//      LD L,A       ; 6F
           LDs6HL7_B    = 10'h70,//      LD (HL),B    ; 70
           LDs6HL7_C    = 10'h71,//      LD (HL),C    ; 71
           LDs6HL7_D    = 10'h72,//      LD (HL),D    ; 72
           LDs6HL7_E    = 10'h73,//      LD (HL),E    ; 73
           LDs6HL7_H    = 10'h74,//      LD (HL),H    ; 74
           LDs6HL7_L    = 10'h75,//      LD (HL),L    ; 75
           HALT         = 10'h76,//      HALT         ; 76
           LDs6HL7_A    = 10'h77,//      LD (HL),A    ; 77
           LDsA_B       = 10'h78,//      LD A,B       ; 78
           LDsA_C       = 10'h79,//      LD A,C       ; 79
           LDsA_D       = 10'h7A,//      LD A,D       ; 7A
           LDsA_E       = 10'h7B,//      LD A,E       ; 7B
           LDsA_H       = 10'h7C,//      LD A,H       ; 7C
           LDsA_L       = 10'h7D,//      LD A,L       ; 7D
           LDsA_6HL7    = 10'h7E,//      LD A,(HL)    ; 7E
           LDsA_A       = 10'h7F,//      LD A,A       ; 7F
           ADDsA_B      = 10'h80,//      ADD A,B      ; 80
           ADDsA_C      = 10'h81,//      ADD A,C      ; 81
           ADDsA_D      = 10'h82,//      ADD A,D      ; 82
           ADDsA_E      = 10'h83,//      ADD A,E      ; 83
           ADDsA_H      = 10'h84,//      ADD A,H      ; 84
           ADDsA_L      = 10'h85,//      ADD A,L      ; 85
           ADDsA_6HL7   = 10'h86,//      ADD A,(HL)   ; 86
           ADDsA_A      = 10'h87,//      ADD A,A      ; 87
           ADCsA_B      = 10'h88,//      ADC A,B      ; 88
           ADCsA_C      = 10'h89,//      ADC A,C      ; 89
           ADCsA_D      = 10'h8A,//      ADC A,D      ; 8A
           ADCsA_E      = 10'h8B,//      ADC A,E      ; 8B
           ADCsA_H      = 10'h8C,//      ADC A,H      ; 8C
           ADCsA_L      = 10'h8D,//      ADC A,L      ; 8D
           ADCsA_6HL7   = 10'h8E,//      ADC A,(HL)   ; 8E
           ADCsA_A      = 10'h8F,//      ADC A,A      ; 8F
           SUBsB        = 10'h90,//      SUB B        ; 90
           SUBsC        = 10'h91,//      SUB C        ; 91
           SUBsD        = 10'h92,//      SUB D        ; 92
           SUBsE        = 10'h93,//      SUB E        ; 93
           SUBsH        = 10'h94,//      SUB H        ; 94
           SUBsL        = 10'h95,//      SUB L        ; 95
           SUBs6HL7     = 10'h96,//      SUB (HL)     ; 96
           SUBsA        = 10'h97,//      SUB A        ; 97
           SBCsB        = 10'h98,//      SBC B        ; 98
           SBCsC        = 10'h99,//      SBC C        ; 99
           SBCsD        = 10'h9A,//      SBC D        ; 9A
           SBCsE        = 10'h9B,//      SBC E        ; 9B
           SBCsH        = 10'h9C,//      SBC H        ; 9C
           SBCsL        = 10'h9D,//      SBC L        ; 9D
           SBCs6HL7     = 10'h9E,//      SBC (HL)     ; 9E
           SBCsA        = 10'h9F,//      SBC A        ; 9F
           ANDsB        = 10'hA0,//      AND B        ; A0
           ANDsC        = 10'hA1,//      AND C        ; A1
           ANDsD        = 10'hA2,//      AND D        ; A2
           ANDsE        = 10'hA3,//      AND E        ; A3
           ANDsH        = 10'hA4,//      AND H        ; A4
           ANDsL        = 10'hA5,//      AND L        ; A5
           ANDs6HL7     = 10'hA6,//      AND (HL)     ; A6
           ANDsA        = 10'hA7,//      AND A        ; A7
           XORsB        = 10'hA8,//      XOR B        ; A8
           XORsC        = 10'hA9,//      XOR C        ; A9
           XORsD        = 10'hAA,//      XOR D        ; AA
           XORsE        = 10'hAB,//      XOR E        ; AB
           XORsH        = 10'hAC,//      XOR H        ; AC
           XORsL        = 10'hAD,//      XOR L        ; AD
           XORs6HL7     = 10'hAE,//      XOR (HL)     ; AE
           XORsA        = 10'hAF,//      XOR A        ; AF
           ORsB         = 10'hB0,//      OR B         ; B0
           ORsC         = 10'hB1,//      OR C         ; B1
           ORsD         = 10'hB2,//      OR D         ; B2
           ORsE         = 10'hB3,//      OR E         ; B3
           ORsH         = 10'hB4,//      OR H         ; B4
           ORsL         = 10'hB5,//      OR L         ; B5
           ORs6HL7      = 10'hB6,//      OR (HL)      ; B6
           ORsA         = 10'hB7,//      OR A         ; B7
           CPsB         = 10'hB8,//      CP B         ; B8
           CPsC         = 10'hB9,//      CP C         ; B9
           CPsD         = 10'hBA,//      CP D         ; BA
           CPsE         = 10'hBB,//      CP E         ; BB
           CPsH         = 10'hBC,//      CP H         ; BC
           CPsL         = 10'hBD,//      CP L         ; BD
           CPs6HL7      = 10'hBE,//      CP (HL)      ; BE
           CPsA         = 10'hBF,//      CP A         ; BF
           RETsNZ       = 10'hC0,//      RET NZ       ; C0
           POPsBC       = 10'hC1,//      POP BC       ; C1
           JPsNZ        = 10'hC2,//      JP NZ        ; C2 XX XX
           JP           = 10'hC3,//      JP           ; C3 XX XX
           CALLsNZ_NN   = 10'hC4,//      CALL NZ,NN   ; C4 XX XX
           PUSHsBC      = 10'hC5,//      PUSH BC      ; C5
           ADDsA_N      = 10'hC6,//      ADD A,N      ; C6 XX
           RSTs0        = 10'hC7,//      RST 0        ; C7
           RETsZ        = 10'hC8,//      RET Z        ; C8
           RET          = 10'hC9,//      RET          ; C9
           JPsZ         = 10'hCA,//      JP Z         ; CA XX XX
           CALLsZ_NN    = 10'hCC,//      CALL Z,NN    ; CC XX XX
           CBgrp        = 10'hCB,//       CBgrp is rotates and bit munging below
           CALLsNN      = 10'hCD,//      CALL NN      ; CD XX XX
           ADCsA_N      = 10'hCE,//      ADC A,N      ; CE XX
           RSTs8H       = 10'hCF,//      RST 8H       ; CF 
           RETsNC       = 10'hD0,//      RET NC       ; D0
           POPsDE       = 10'hD1,//      POP DE       ; D1
           JPsNC        = 10'hD2,//      JP NC,       ; D2 XX XX
           OUTs6N7_A    = 10'hD3,//      OUT (N),A    ; D3 XX
           CALLsNC_NN   = 10'hD4,//      CALL NC,NN   ; D4 XX XX
           PUSHsDE      = 10'hD5,//      PUSH DE      ; D5
           SUBsN        = 10'hD6,//      SUB N        ; D6 XX
           RSTs10H      = 10'hD7,//      RST 10H      ; D7
           RETsC        = 10'hD8,//      RET C        ; D8
           EXX          = 10'hD9,//      EXX          ; D9
           JPsC         = 10'hDA,//      JP C         ; DA XX XX
           INsA_6N7     = 10'hDB,//      IN A,(N)     ; DB XX
           CALLsC_NN    = 10'hDC,//      CALL C,NN    ; DC XX XX
           DDgrp        = 10'hDD,//      DDgrp   
           SBCsA_N      = 10'hDE,//      SBC A,N      ; DE XX
           RSTs18H      = 10'hDF,//      RST 18H      ; DF
           RETsPO       = 10'hE0,//      RET PO       ; E0
           POPsHL       = 10'hE1,//      POP HL       ; E1
           JPsPO        = 10'hE2,//      JP PO        ; E2 XX XX
           EXs6SP7_HL   = 10'hE3,//      EX (SP),HL   ; E3
           CALLsPO_NN   = 10'hE4,//      CALL PO,NN   ; E4 XX XX
           PUSHsHL      = 10'hE5,//      PUSH HL      ; E5
           ANDsN        = 10'hE6,//      AND N        ; E6 XX
           RSTs20H      = 10'hE7,//      RST 20H      ; E7
           RETsPE       = 10'hE8,//      RET PE       ; E8
           JPsHL        = 10'hE9,//      JP HL        ; E9 // documented as indirect IS NOT
           JPsPE        = 10'hEA,//      JP PE,       ; EA XX XX
           EXsDE_HL     = 10'hEB,//      EX DE,HL     ; EB
           CALLsPE_NN   = 10'hEC,//      CALL PE,NN   ; EC XX XX
           EDgrp        = 10'hED,//      EDgrp          ED
           XORsN        = 10'hEE,//      XOR N        ; EE XX
           RSTs28H      = 10'hEF,//      RST 28H      ; EF        
           RETsP        = 10'hF0,//      RET P        ; F0
           POPsAF       = 10'hF1,//      POP AF       ; F1
           JPsP         = 10'hF2,//      JP P         ; F2 XX XX
           DI           = 10'hF3,//      DI           ; F3
           CALLsP_NN    = 10'hF4,//      CALL P,NN    ; F4 XX XX
           PUSHsAF      = 10'hF5,//      PUSH AF      ; F5
           ORsN         = 10'hF6,//      OR N         ; F6 XX
           RSTs30H      = 10'hF7,//      RST 30H      ; F7
           RETsM        = 10'hF8,//      RET M        ; F8
           LDsSP_HL     = 10'hF9,//      LD SP,HL     ; F9
           JPsM         = 10'hFA,//      JP M,        ; FA XX XX
           EI           = 10'hFB,//      EI           ; FB
           CALLsM_NN    = 10'hFC,//      CALL M,NN    ; FC XX XX
           FDgrp        = 10'hFD,//      FDgrp          FD
           CPsN         = 10'hFE,//      CP N         ; FE XX
           RSTs38H      = 10'hFF,//      RST 38H      ; FF

//  the CB set
//  These have enough structure that I don't believe I will define a parameter for each
//  First cut below
           CB_RLC   = 7'b01_00_000,  // these must be compaired with ir[9:3]
           CB_RRC   = 7'b01_00_001,  // these must be compaired with ir[9:3]
           CB_RL    = 7'b01_00_010,  // these must be compaired with ir[9:3]
           CB_RR    = 7'b01_00_011,  // these must be compaired with ir[9:3]
           CB_SLA   = 7'b01_00_100,  // these must be compaired with ir[9:3]
           CB_SRA   = 7'b01_00_101,  // these must be compaired with ir[9:3]
           CB_SLL   = 7'b01_00_110,  // these must be compaired with ir[9:3]
           CB_SRL   = 7'b01_00_111,  // these must be compaired with ir[9:3]
           
           CB_BIT   = 4'b01_01,    // these must be compaired with ir[9:6]
           CB_RES   = 4'b01_10,    // these must be compaired with ir[9:6]
           CB_SET   = 4'b01_11,    // these must be compaired with ir[9:6]
           
           CB_MEM   = 3'b110,   // this must be compaired with ir[2:0] 
                             // note these are all read-modify-writ except CB_BIT
                        
//  The ED Group
// These are the "unique instructions in the 46, 47 rows that NEED? to be implemented
// Not sure I want to worry about all undocumented stuff in these rows - hard to believe
// It will matter.(IM modes are very system dependent  - hard to believe even a programmer
// would use undocumented instructions to muck with this stuff)
           ED_IMs0      =  10'h246,  //      IM 0       ; ED 46   set IM0
           ED_LDsI_A    =  10'h247,  //      LD I,A     ; ED 47   move a to I
           ED_IMs1      =  10'h256,  //      IM 1       ; ED 56   set IM1
           ED_LDsA_I    =  10'h257,  //      LD A,I     ; ED 57   move I to A
           ED_IMs2      =  10'h25E,  //      IM 2       ; ED 5E   set IM2
           ED_RRD       =  10'h267,  //      RRD        ; ED 67   nibble roates A (HL)
           ED_RLD       =  10'h26F,  //      RLD        ; ED 6F   nibble roates A (HL)
                                    
           
           ED_LDI       =  10'h2A0,  //      LDI        ; ED A0    These are block move 
           ED_CPI       =  10'h2A1,  //      CPI        ; ED A1    type insts that don't repeat
           ED_INI       =  10'h2A2,  //      INI        ; ED A2
           ED_OUTI      =  10'h2A3,  //      OUTI       ; ED A3
           ED_LDD       =  10'h2A8,  //      LDD        ; ED A8
           ED_CPD       =  10'h2A9,  //      CPD        ; ED A9
           ED_IND       =  10'h2AA,  //      IND        ; ED AA
           ED_OUTD      =  10'h2AB,  //      OUTD       ; ED AB
           ED_LDIR      =  10'h2B0,  //      LDIR       ; ED B0    These are block move 
           ED_CPIR      =  10'h2B1,  //      CPIR       ; ED B1    type insts that DO repeat
           ED_INIR      =  10'h2B2,  //      INIR       ; ED B2
           ED_OTIR      =  10'h2B3,  //      OTIR       ; ED B3
           ED_LDDR      =  10'h2B8,  //      LDDR       ; ED B8
           ED_CPDR      =  10'h2B9,  //      CPDR       ; ED B9
           ED_INDR      =  10'h2BA,  //      INDR       ; ED BA
           ED_OTDR      =  10'h2BB,  //      OTDR       ; ED BB

//    the ED  gropu definitions from 40 to 7f from document on undocumented insts..... 
//
//  ED40 IN B,(C)     ED50 IN D,(C)        ED60 IN H,(C)     ED70 IN (C) / IN F,(C)
//  ED41 OUT (C),B    ED51 OUT (C),D       ED61 OUT (C),H    ED71 OUT (C),0*
//  ED42 SBC HL,BC    ED52 SBC HL,DE       ED62 SBC HL,HL    ED72 SBC HL,SP
//  ED43 LD (nn),BC   ED53 LD (nn),DE      ED63 LD (nn),HL   ED73 LD (nn),SP
//  ED44 NEG          ED54 NEG*            ED64 NEG*         ED74 NEG*
//  ED45 RETN         ED55 RETN*           ED65 RETN*        ED75 RETN*
//  ED46 IM 0         ED56 IM 1            ED66 IM 0*        ED76 IM 1*
//  ED47 LD I,A       ED57 LD A,I          ED67 RRD          ED77 NOP*

//  ED48 IN C,(C)     ED58 IN E,(C)        ED68 IN L,(C)     ED78 IN A,(C)
//  ED49 OUT (C),C    ED59 OUT (C),E       ED69 OUT (C),L    ED79 OUT (C),A
//  ED4A ADC HL,BC    ED5A ADC HL,DE       ED6A ADC HL,HL    ED7A ADC HL,SP
//  ED4B LD BC,(nn)   ED5B LD DE,(nn)      ED6B LD HL,(nn)   ED7B LD SP,(nn)
//  ED4C NEG*         ED5C NEG*            ED6C NEG*         ED7C NEG*
//  ED4D RETI         ED5D RETN*           ED6D RETN*        ED7D RETN*
//  ED4E IM 0*        ED5E IM 2            ED6E IM 0*        ED7E IM 2*
//  ED4F LD R,A       ED5F LD A,R          ED6F RLD          ED7F NOP*


//The ED70 instruction reads from I/O port C, 
//but does not store the result.
//It just affects the flags.  like the other IN x,(C) instruction. 
//
//ED71 simply outs the value 0 to I/O port C.
//  This suggests that we should decode as follows:
//  I hope if I don't get all the IM duplicates right it won't be a tragedy
        ED_INsREG_6C7  =    7'b1001___000, // compair with {ir[9:6],ir[2:0]}
        ED_OUTs6C7_REG =    7'b1001___001, // compair with {ir[9:6],ir[2:0]}
        ED_SBCsHL_REG  =    8'b1001__0010, // compair with {ir[9:6],ir[3:0]}
        ED_ADCsHL_REG  =    8'b1001__1010, // compair with {ir[9:6],ir[3:0]}
        ED_LDs6NN7_REG =    8'b1001__0011, // compair with {ir[9:6],ir[3:0]}  REG = BC,DE,HL,SP                   
        ED_LDsREG_6NN7 =    8'b1001__1011, // compair with {ir[9:6],ir[3:0]}  REG = BC,DE,HL,SP
        ED_NEG         =    7'b1001___100, // compair with {ir[9:6],ir[2:0]}  all A<= -A                  
        ED_RETN        =    7'b1001___101, // compair with {ir[9:6],ir[2:0]} and !reti
        ED_RETI        =  10'h24D, 
        
        DBL_REG_BC   = 2'b00,  // compair with ir[5:4]
        DBL_REG_DE   = 2'b01,  // compair with ir[5:4]
        DBL_REG_HL   = 2'b10,  // compair with ir[5:4]
        DBL_REG_SP   = 2'b11,  // compair with ir[5:4]

        REG8_B = 3'b000,
        REG8_C = 3'b001,
        REG8_D = 3'b010,
        REG8_E = 3'b011,
        REG8_H = 3'b100,
        REG8_L = 3'b101,
        REG8_MEM = 3'b110,
        REG8_A = 3'b111;

































 







 







          
          