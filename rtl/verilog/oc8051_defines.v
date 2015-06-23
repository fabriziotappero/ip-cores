//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores Definitions              		          ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 definitions.                                           ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////      - Jaka Simsic, jakas@opencores.org                      ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// ver: 1
//

//
// oc8051 pherypherals
//
`define OC8051_UART
`define OC8051_TC01
`define OC8051_TC2
`define OC8051_PORTS  //ports global enable
`define OC8051_PORT0
`define OC8051_PORT1
`define OC8051_PORT2
`define OC8051_PORT3


//
// oc8051 ITERNAL ROM
//
//`define OC8051_ROM


//
// oc8051 memory
//
//`define OC8051_CACHE
//`define OC8051_WB

//`define OC8051_RAM_XILINX
//`define OC8051_RAM_VIRTUALSILICON
`define OC8051_RAM_GENERIC


`define OC8051_XILINX_ROM

//
// oc8051 simulation defines
//
//`define OC8051_SIMULATION
//`define OC8051_SERIAL

//
// oc8051 bist
//
//`define OC8051_BIST


//
// operation codes for alu
//


`define OC8051_ALU_NOP 4'b0000
`define OC8051_ALU_ADD 4'b0001
`define OC8051_ALU_SUB 4'b0010
`define OC8051_ALU_MUL 4'b0011
`define OC8051_ALU_DIV 4'b0100
`define OC8051_ALU_DA 4'b0101
`define OC8051_ALU_NOT 4'b0110
`define OC8051_ALU_AND 4'b0111
`define OC8051_ALU_XOR 4'b1000
`define OC8051_ALU_OR 4'b1001
`define OC8051_ALU_RL 4'b1010
`define OC8051_ALU_RLC 4'b1011
`define OC8051_ALU_RR 4'b1100
`define OC8051_ALU_RRC 4'b1101
`define OC8051_ALU_INC 4'b1110
`define OC8051_ALU_XCH 4'b1111

//
// sfr addresses
//

`define OC8051_SFR_ACC 8'he0 //accumulator
`define OC8051_SFR_B 8'hf0 //b register
`define OC8051_SFR_PSW 8'hd0 //program status word
`define OC8051_SFR_P0 8'h80 //port 0
`define OC8051_SFR_P1 8'h90 //port 1
`define OC8051_SFR_P2 8'ha0 //port 2
`define OC8051_SFR_P3 8'hb0 //port 3
`define OC8051_SFR_DPTR_LO 8'h82 // data pointer high bits
`define OC8051_SFR_DPTR_HI 8'h83 // data pointer low bits
`define OC8051_SFR_IP0 8'hb8 // interrupt priority
`define OC8051_SFR_IEN0 8'ha8 // interrupt enable 0
`define OC8051_SFR_TMOD 8'h89 // timer/counter mode
`define OC8051_SFR_TCON 8'h88 // timer/counter control
`define OC8051_SFR_TH0 8'h8c // timer/counter 0 high bits
`define OC8051_SFR_TL0 8'h8a // timer/counter 0 low bits
`define OC8051_SFR_TH1 8'h8d // timer/counter 1 high bits
`define OC8051_SFR_TL1 8'h8b // timer/counter 1 low bits

`define OC8051_SFR_SCON 8'h98 // serial control 0
`define OC8051_SFR_SBUF 8'h99 // serial data buffer 0
`define OC8051_SFR_SADDR 8'ha9 // serila address register 0
`define OC8051_SFR_SADEN 8'hb9 // serila address enable 0

`define OC8051_SFR_PCON 8'h87 // power control
`define OC8051_SFR_SP 8'h81 // stack pointer



`define OC8051_SFR_IE 8'ha8 // interrupt enable
`define OC8051_SFR_IP 8'hb7 // interrupt priority

`define OC8051_SFR_RCAP2H 8'hcb // timer 2 capture high
`define OC8051_SFR_RCAP2L 8'hca // timer 2 capture low

`define OC8051_SFR_T2CON 8'hc8 // timer 2 control register
`define OC8051_SFR_TH2 8'hcd // timer 2 high
`define OC8051_SFR_TL2 8'hcc // timer 2 low



//
// sfr bit addresses
//
`define OC8051_SFR_B_ACC 5'b11100 //accumulator
`define OC8051_SFR_B_PSW 5'b11010 //program status word
`define OC8051_SFR_B_P0  5'b10000 //port 0
`define OC8051_SFR_B_P1  5'b10010 //port 1
`define OC8051_SFR_B_P2  5'b10100 //port 2
`define OC8051_SFR_B_P3  5'b10110 //port 3
`define OC8051_SFR_B_B   5'b11110 // b register
`define OC8051_SFR_B_IP  5'b10111 // interrupt priority control 0
`define OC8051_SFR_B_IE  5'b10101 // interrupt enable control 0
`define OC8051_SFR_B_SCON 5'b10011 // serial control
`define OC8051_SFR_B_TCON  5'b10001 // timer/counter control
`define OC8051_SFR_B_T2CON 5'b11001 // timer/counter2 control


//
//carry input in alu
//
`define OC8051_CY_0 2'b00 // 1'b0;
`define OC8051_CY_PSW 2'b01 // carry from psw
`define OC8051_CY_RAM 2'b10 // carry from ram
`define OC8051_CY_1 2'b11 // 1'b1;
`define OC8051_CY_DC 2'b00 // carry from psw

//
// instruction set
//

//op_code [4:0]
`define OC8051_ACALL 8'bxxx1_0001 // absolute call
`define OC8051_AJMP 8'bxxx0_0001 // absolute jump

//op_code [7:3]
`define OC8051_ADD_R 8'b0010_1xxx // add A=A+Rx
`define OC8051_ADDC_R 8'b0011_1xxx // add A=A+Rx+c
`define OC8051_ANL_R 8'b0101_1xxx // and A=A^Rx
`define OC8051_CJNE_R 8'b1011_1xxx // compare and jump if not equal; Rx<>constant
`define OC8051_DEC_R 8'b0001_1xxx // decrement reg Rn=Rn-1
`define OC8051_DJNZ_R 8'b1101_1xxx // decrement and jump if not zero
`define OC8051_INC_R 8'b0000_1xxx // increment Rn
`define OC8051_MOV_R 8'b1110_1xxx // move A=Rn
`define OC8051_MOV_AR 8'b1111_1xxx // move Rn=A
`define OC8051_MOV_DR 8'b1010_1xxx // move Rn=(direct)
`define OC8051_MOV_CR 8'b0111_1xxx // move Rn=constant
`define OC8051_MOV_RD 8'b1000_1xxx // move (direct)=Rn
`define OC8051_ORL_R 8'b0100_1xxx // or A=A or Rn
`define OC8051_SUBB_R 8'b1001_1xxx // substract with borrow  A=A-c-Rn
`define OC8051_XCH_R 8'b1100_1xxx // exchange A<->Rn
`define OC8051_XRL_R 8'b0110_1xxx // XOR A=A XOR Rn

//op_code [7:1]
`define OC8051_ADD_I 8'b0010_011x // add A=A+@Ri
`define OC8051_ADDC_I 8'b0011_011x // add A=A+@Ri+c
`define OC8051_ANL_I 8'b0101_011x // and A=A^@Ri
`define OC8051_CJNE_I 8'b1011_011x // compare and jump if not equal; @Ri<>constant
`define OC8051_DEC_I 8'b0001_011x // decrement indirect @Ri=@Ri-1
`define OC8051_INC_I 8'b0000_011x // increment @Ri
`define OC8051_MOV_I 8'b1110_011x // move A=@Ri
`define OC8051_MOV_ID 8'b1000_011x // move (direct)=@Ri
`define OC8051_MOV_AI 8'b1111_011x // move @Ri=A
`define OC8051_MOV_DI 8'b1010_011x // move @Ri=(direct)
`define OC8051_MOV_CI 8'b0111_011x // move @Ri=constant
`define OC8051_MOVX_IA 8'b1110_001x // move A=(@Ri)
`define OC8051_MOVX_AI 8'b1111_001x // move (@Ri)=A
`define OC8051_ORL_I 8'b0100_011x // or A=A or @Ri
`define OC8051_SUBB_I 8'b1001_011x // substract with borrow  A=A-c-@Ri
`define OC8051_XCH_I 8'b1100_011x // exchange A<->@Ri
`define OC8051_XCHD 8'b1101_011x // exchange digit A<->Ri
`define OC8051_XRL_I 8'b0110_011x // XOR A=A XOR @Ri

//op_code [7:0]
`define OC8051_ADD_D 8'b0010_0101 // add A=A+(direct)
`define OC8051_ADD_C 8'b0010_0100 // add A=A+constant
`define OC8051_ADDC_D 8'b0011_0101 // add A=A+(direct)+c
`define OC8051_ADDC_C 8'b0011_0100 // add A=A+constant+c
`define OC8051_ANL_D 8'b0101_0101 // and A=A^(direct)
`define OC8051_ANL_C 8'b0101_0100 // and A=A^constant
`define OC8051_ANL_DD 8'b0101_0010 // and (direct)=(direct)^A
`define OC8051_ANL_DC 8'b0101_0011 // and (direct)=(direct)^constant
`define OC8051_ANL_B 8'b1000_0010 // and c=c^bit
`define OC8051_ANL_NB 8'b1011_0000 // and c=c^!bit
`define OC8051_CJNE_D 8'b1011_0101 // compare and jump if not equal; a<>(direct)
`define OC8051_CJNE_C 8'b1011_0100 // compare and jump if not equal; a<>constant
`define OC8051_CLR_A 8'b1110_0100 // clear accumulator
`define OC8051_CLR_C 8'b1100_0011 // clear carry
`define OC8051_CLR_B 8'b1100_0010 // clear bit
`define OC8051_CPL_A 8'b1111_0100 // complement accumulator
`define OC8051_CPL_C 8'b1011_0011 // complement carry
`define OC8051_CPL_B 8'b1011_0010 // complement bit
`define OC8051_DA 8'b1101_0100 // decimal adjust (A)
`define OC8051_DEC_A 8'b0001_0100 // decrement accumulator a=a-1
`define OC8051_DEC_D 8'b0001_0101 // decrement direct (direct)=(direct)-1
`define OC8051_DIV 8'b1000_0100 // divide
`define OC8051_DJNZ_D 8'b1101_0101 // decrement and jump if not zero (direct)
`define OC8051_INC_A 8'b0000_0100 // increment accumulator
`define OC8051_INC_D 8'b0000_0101 // increment (direct)
`define OC8051_INC_DP 8'b1010_0011 // increment data pointer
`define OC8051_JB 8'b0010_0000 // jump if bit set
`define OC8051_JBC 8'b0001_0000 // jump if bit set and clear bit
`define OC8051_JC 8'b0100_0000 // jump if carry is set
`define OC8051_JMP_D 8'b0111_0011 // jump indirect
`define OC8051_JNB 8'b0011_0000 // jump if bit not set
`define OC8051_JNC 8'b0101_0000 // jump if carry not set
`define OC8051_JNZ 8'b0111_0000 // jump if accumulator not zero
`define OC8051_JZ 8'b0110_0000 // jump if accumulator zero
`define OC8051_LCALL 8'b0001_0010 // long call
`define OC8051_LJMP 8'b0000_0010 // long jump
`define OC8051_MOV_D 8'b1110_0101 // move A=(direct)
`define OC8051_MOV_C 8'b0111_0100 // move A=constant
`define OC8051_MOV_DA 8'b1111_0101 // move (direct)=A
`define OC8051_MOV_DD 8'b1000_0101 // move (direct)=(direct)
`define OC8051_MOV_CD 8'b0111_0101 // move (direct)=constant
`define OC8051_MOV_BC 8'b1010_0010 // move c=bit
`define OC8051_MOV_CB 8'b1001_0010 // move bit=c
`define OC8051_MOV_DP 8'b1001_0000 // move dptr=constant(16 bit)
`define OC8051_MOVC_DP 8'b1001_0011 // move A=dptr+A
`define OC8051_MOVC_PC 8'b1000_0011 // move A=pc+A
`define OC8051_MOVX_PA 8'b1110_0000 // move A=(dptr)
`define OC8051_MOVX_AP 8'b1111_0000 // move (dptr)=A
`define OC8051_MUL 8'b1010_0100 // multiply a*b
`define OC8051_NOP 8'b0000_0000 // no operation
`define OC8051_ORL_D 8'b0100_0101 // or A=A or (direct)
`define OC8051_ORL_C 8'b0100_0100 // or A=A or constant
`define OC8051_ORL_AD 8'b0100_0010 // or (direct)=(direct) or A
`define OC8051_ORL_CD 8'b0100_0011 // or (direct)=(direct) or constant
`define OC8051_ORL_B 8'b0111_0010 // or c = c or bit
`define OC8051_ORL_NB 8'b1010_0000 // or c = c or !bit
`define OC8051_POP 8'b1101_0000 // stack pop
`define OC8051_PUSH 8'b1100_0000 // stack push
`define OC8051_RET 8'b0010_0010 // return from subrutine
`define OC8051_RETI 8'b0011_0010 // return from interrupt
`define OC8051_RL 8'b0010_0011 // rotate left
`define OC8051_RLC 8'b0011_0011 // rotate left thrugh carry
`define OC8051_RR 8'b0000_0011 // rotate right
`define OC8051_RRC 8'b0001_0011 // rotate right thrugh carry
`define OC8051_SETB_C 8'b1101_0011 // set carry
`define OC8051_SETB_B 8'b1101_0010 // set bit
`define OC8051_SJMP 8'b1000_0000 // short jump
`define OC8051_SUBB_D 8'b1001_0101 // substract with borrow  A=A-c-(direct)
`define OC8051_SUBB_C 8'b1001_0100 // substract with borrow  A=A-c-constant
`define OC8051_SWAP 8'b1100_0100 // swap A(0-3) <-> A(4-7)
`define OC8051_XCH_D 8'b1100_0101 // exchange A<->(direct)
`define OC8051_XRL_D 8'b0110_0101 // XOR A=A XOR (direct)
`define OC8051_XRL_C 8'b0110_0100 // XOR A=A XOR constant
`define OC8051_XRL_AD 8'b0110_0010 // XOR (direct)=(direct) XOR A
`define OC8051_XRL_CD 8'b0110_0011 // XOR (direct)=(direct) XOR constant


//
// default values (used after reset)
//
`define OC8051_RST_PC 23'h0 // program counter
`define OC8051_RST_ACC 8'h00 // accumulator
`define OC8051_RST_B 8'h00 // b register
`define OC8051_RST_PSW 8'h00 // program status word
`define OC8051_RST_SP 8'b0000_0111 // stack pointer
`define OC8051_RST_DPH 8'h00 // data pointer (high)
`define OC8051_RST_DPL 8'h00 // data pointer (low)
`define OC8051_RST_P0 8'b1111_1111 // port 0
`define OC8051_RST_P1 8'b1111_1111 // port 1
`define OC8051_RST_P2 8'b1111_1111 // port 2
`define OC8051_RST_P3 8'b1111_1111 // port 3
`define OC8051_RST_IP 8'b0000_0000 // interrupt priority
`define OC8051_RST_IE 8'b0000_0000 // interrupt enable
`define OC8051_RST_TMOD 8'b0000_0000 // timer/counter mode control
`define OC8051_RST_TCON 8'b0000_0000 // timer/counter control
`define OC8051_RST_TH0 8'b0000_0000 // timer/counter 0 high bits
`define OC8051_RST_TL0 8'b0000_0000 // timer/counter 0 low bits
`define OC8051_RST_TH1 8'b0000_0000 // timer/counter 1 high bits
`define OC8051_RST_TL1 8'b0000_0000 // timer/counter 1 low bits
`define OC8051_RST_SCON 8'b0000_0000 // serial control
`define OC8051_RST_SBUF 8'b0000_0000 // serial data buffer
`define OC8051_RST_PCON 8'b0000_0000 // power control register



`define OC8051_RST_RCAP2H 8'h00 // timer 2 capture high
`define OC8051_RST_RCAP2L 8'h00 // timer 2 capture low

`define OC8051_RST_T2CON 8'h00 // timer 2 control register
`define OC8051_RST_T2MOD 8'h00 // timer 2 mode control
`define OC8051_RST_TH2 8'h00 // timer 2 high
`define OC8051_RST_TL2 8'h00 // timer 2 low


//
// alu source 1 select
//
`define OC8051_AS1_RAM  3'b000 // RAM
`define OC8051_AS1_OP1  3'b111 //
`define OC8051_AS1_OP2  3'b001 //
`define OC8051_AS1_OP3  3'b010 //
`define OC8051_AS1_ACC  3'b011 // accumulator
`define OC8051_AS1_PCH  3'b100 //
`define OC8051_AS1_PCL  3'b101 //
`define OC8051_AS1_DC   3'b000 //

//
// alu source 2 select
//
`define OC8051_AS2_RAM   3'b00 // RAM
`define OC8051_AS2_ACC   3'b01 // accumulator
`define OC8051_AS2_ZERO  3'b10 // 8'h00
`define OC8051_AS2_OP2   3'b11 //

`define OC8051_AS2_DC    3'b00 //

//
// alu source 3 select
//
`define OC8051_AS3_DP   1'b0 // data pointer
`define OC8051_AS3_PC   1'b1 // program clunter
//`define OC8051_AS3_PCU  3'b101 // program clunter not registered
`define OC8051_AS3_DC   1'b0  //


//
//write sfr
//
`define OC8051_WRS_N    2'b00  //no
`define OC8051_WRS_ACC1 2'b01  // acc destination 1
`define OC8051_WRS_ACC2 2'b10  // acc destination 2
`define OC8051_WRS_DPTR 2'b11  // data pointer


//
// ram read select
//

`define OC8051_RRS_RN   3'b000 // registers
`define OC8051_RRS_I    3'b001 // indirect addressing (op2)
`define OC8051_RRS_D    3'b010 // direct addressing
`define OC8051_RRS_SP   3'b011 // stack pointer

`define OC8051_RRS_B    3'b100 // b register
`define OC8051_RRS_DPTR 3'b101 // data pointer
`define OC8051_RRS_PSW  3'b110 // program status word
`define OC8051_RRS_ACC  3'b111 // acc

`define OC8051_RRS_DC 3'b000 // don't c

//
// ram write select
//

`define OC8051_RWS_RN 3'b000 // registers
`define OC8051_RWS_D  3'b001 // direct addressing
`define OC8051_RWS_I  3'b010 // indirect addressing
`define OC8051_RWS_SP 3'b011 // stack pointer
`define OC8051_RWS_D3 3'b101 // direct address (op3)
`define OC8051_RWS_D1 3'b110 // direct address (op1)
`define OC8051_RWS_B  3'b111 // b register
`define OC8051_RWS_DC 3'b000 //

//
// pc in select
//
`define OC8051_PIS_DC  3'b000 // dont c
`define OC8051_PIS_AL  3'b000 // alu low
`define OC8051_PIS_AH  3'b001 // alu high
`define OC8051_PIS_SO1 3'b010 // relative address, op1
`define OC8051_PIS_SO2 3'b011 // relative address, op2
`define OC8051_PIS_I11 3'b100 // 11 bit immediate
`define OC8051_PIS_I16 3'b101 // 16 bit immediate
`define OC8051_PIS_ALU 3'b110 // alu destination {des2, des1}

//
// compare source select
//
`define OC8051_CSS_AZ  2'b00 // eq = accumulator == zero
`define OC8051_CSS_DES 2'b01 // eq = destination == zero
`define OC8051_CSS_CY  2'b10 // eq = cy
`define OC8051_CSS_BIT 2'b11 // eq = b_in
`define OC8051_CSS_DC  2'b01 // don't care


//
// pc Write
//
`define OC8051_PCW_N 1'b0 // not
`define OC8051_PCW_Y 1'b1 // yes

//
//psw set
//
`define OC8051_PS_NOT 2'b00 // DONT
`define OC8051_PS_CY 2'b01 // only carry
`define OC8051_PS_OV 2'b10 // carry and overflov
`define OC8051_PS_AC 2'b11 // carry, overflov an ac...

//
// rom address select
//
`define OC8051_RAS_PC 1'b0 // program counter
`define OC8051_RAS_DES 1'b1 // alu destination

////
//// write accumulator
////
//`define OC8051_WA_N 1'b0 // not
//`define OC8051_WA_Y 1'b1 // yes


//
//memory action select
//
`define OC8051_MAS_DPTR_R 3'b000 // read from external rom: acc=(dptr)
`define OC8051_MAS_DPTR_W 3'b001 // write to external rom: (dptr)=acc
`define OC8051_MAS_RI_R   3'b010 // read from external rom: acc=(Ri)
`define OC8051_MAS_RI_W   3'b011 // write to external rom: (Ri)=acc
`define OC8051_MAS_CODE   3'b100 // read from program memory
`define OC8051_MAS_NO     3'b111 // no action


////////////////////////////////////////////////////

//
// Timer/Counter modes
//

`define OC8051_MODE0 2'b00  // mode 0
`define OC8051_MODE1 2'b01  // mode 0
`define OC8051_MODE2 2'b10  // mode 0
`define OC8051_MODE3 2'b11  // mode 0


//
// Interrupt numbers (vectors)
//

`define OC8051_INT_X0   8'h03  // external interrupt 0
`define OC8051_INT_T0   8'h0b  // T/C 0 owerflow interrupt
`define OC8051_INT_X1   8'h13  // external interrupt 1
`define OC8051_INT_T1   8'h1b  // T/C 1 owerflow interrupt
`define OC8051_INT_UART 8'h23  // uart interrupt
`define OC8051_INT_T2   8'h2b  // T/C 2 owerflow interrupt


//
// interrupt levels
//

`define OC8051_ILEV_L0 1'b0  // interrupt on level 0
`define OC8051_ILEV_L1 1'b1  // interrupt on level 1

//
// interrupt sources
//
`define OC8051_ISRC_NO   3'b000  // no interrupts
`define OC8051_ISRC_IE0  3'b001  // EXTERNAL INTERRUPT 0
`define OC8051_ISRC_TF0  3'b010  // t/c owerflov 0
`define OC8051_ISRC_IE1  3'b011  // EXTERNAL INTERRUPT 1
`define OC8051_ISRC_TF1  3'b100  // t/c owerflov 1
`define OC8051_ISRC_UART 3'b101  // UART  Interrupt
`define OC8051_ISRC_T2   3'b110  // t/c owerflov 2



//
// miscellaneus
//

`define OC8051_RW0 1'b1
`define OC8051_RW1 1'b0


//
// read modify write instruction
//

`define OC8051_RMW_Y 1'b1  // yes
`define OC8051_RMW_N 1'b0  // no

