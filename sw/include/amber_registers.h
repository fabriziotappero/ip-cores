/*----------------------------------------------------------------
//                                                              //
//  amber_registers.h                                           //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Defines the address of all registers in the Amber system.   //
//  Must be kept synchronized with the equivalent Verilog       //
//  file, $AMBER_BASE/hw/vlog/system/register_addresses.v       //
//  which is considered the master.                             //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

#define ADR_AMBER_TEST_STATUS          0xf0000000
#define ADR_AMBER_TEST_FIRQ_TIMER      0xf0000004
#define ADR_AMBER_TEST_IRQ_TIMER       0xf0000008
#define ADR_AMBER_TEST_UART_CONTROL    0xf0000010
#define ADR_AMBER_TEST_UART_STATUS     0xf0000014
#define ADR_AMBER_TEST_UART_TXD        0xf0000018
#define ADR_AMBER_TEST_SIM_CTRL        0xf000001c
#define ADR_AMBER_TEST_MEM_CTRL        0xf0000020
#define ADR_AMBER_TEST_CYCLES          0xf0000024
#define ADR_AMBER_TEST_LED             0xf0000028
#define ADR_AMBER_TEST_PHY_RST         0xf000002c


/* Allow access to the random register over
   a 16-word address range to load a series
   of random numbers using lmd instruction. */
#define ADR_AMBER_TEST_RANDOM_NUM      0xf0000100
#define ADR_AMBER_TEST_RANDOM_NUM00    0xf0000100
#define ADR_AMBER_TEST_RANDOM_NUM01    0xf0000104
#define ADR_AMBER_TEST_RANDOM_NUM02    0xf0000108
#define ADR_AMBER_TEST_RANDOM_NUM03    0xf000010c
#define ADR_AMBER_TEST_RANDOM_NUM04    0xf0000110
#define ADR_AMBER_TEST_RANDOM_NUM05    0xf0000114
#define ADR_AMBER_TEST_RANDOM_NUM06    0xf0000118
#define ADR_AMBER_TEST_RANDOM_NUM07    0xf000011c
#define ADR_AMBER_TEST_RANDOM_NUM08    0xf0000120
#define ADR_AMBER_TEST_RANDOM_NUM09    0xf0000124
#define ADR_AMBER_TEST_RANDOM_NUM10    0xf0000128
#define ADR_AMBER_TEST_RANDOM_NUM11    0xf000012c
#define ADR_AMBER_TEST_RANDOM_NUM12    0xf0000130
#define ADR_AMBER_TEST_RANDOM_NUM13    0xf0000134
#define ADR_AMBER_TEST_RANDOM_NUM14    0xf0000138
#define ADR_AMBER_TEST_RANDOM_NUM15    0xf000013c

#define ADR_AMBER_IC_IRQ0_STATUS       0x14000000
#define ADR_AMBER_IC_IRQ0_RAWSTAT      0x14000004
#define ADR_AMBER_IC_IRQ0_ENABLESET    0x14000008
#define ADR_AMBER_IC_IRQ0_ENABLECLR    0x1400000c
#define ADR_AMBER_IC_INT_SOFTSET_0     0x14000010
#define ADR_AMBER_IC_INT_SOFTCLEAR_0   0x14000014
#define ADR_AMBER_IC_FIRQ0_STATUS      0x14000020
#define ADR_AMBER_IC_FIRQ0_RAWSTAT     0x14000024
#define ADR_AMBER_IC_FIRQ0_ENABLESET   0x14000028
#define ADR_AMBER_IC_FIRQ0_ENABLECLR   0x1400002c
#define ADR_AMBER_IC_IRQ1_STATUS       0x14000040
#define ADR_AMBER_IC_IRQ1_RAWSTAT      0x14000044
#define ADR_AMBER_IC_IRQ1_ENABLESET    0x14000048
#define ADR_AMBER_IC_IRQ1_ENABLECLR    0x1400004c
#define ADR_AMBER_IC_INT_SOFTSET_1     0x14000050
#define ADR_AMBER_IC_INT_SOFTCLEAR_1   0x14000054
#define ADR_AMBER_IC_FIRQ1_STATUS      0x14000060
#define ADR_AMBER_IC_FIRQ1_RAWSTAT     0x14000064
#define ADR_AMBER_IC_FIRQ1_ENABLESET   0x14000068
#define ADR_AMBER_IC_FIRQ1_ENABLECLR   0x1400006c
#define ADR_AMBER_IC_INT_SOFTSET_2     0x14000090
#define ADR_AMBER_IC_INT_SOFTCLEAR_2   0x14000094
#define ADR_AMBER_IC_INT_SOFTSET_3     0x140000d0
#define ADR_AMBER_IC_INT_SOFTCLEAR_3   0x140000d4


#define ADR_AMBER_CT_TIMER0_LOAD       0x13000000
#define ADR_AMBER_TM_TIMER0_LOAD       0x13000000
#define ADR_AMBER_TM_TIMER0_VALUE      0x13000004
#define ADR_AMBER_TM_TIMER0_CTRL       0x13000008
#define ADR_AMBER_TM_TIMER0_CLR        0x1300000c
#define ADR_AMBER_CT_TIMER1_LOAD       0x13000100
#define ADR_AMBER_TM_TIMER1_LOAD       0x13000100
#define ADR_AMBER_TM_TIMER1_VALUE      0x13000104
#define ADR_AMBER_TM_TIMER1_CTRL       0x13000108
#define ADR_AMBER_TM_TIMER1_CLR        0x1300010c
#define ADR_AMBER_CT_TIMER2_LOAD       0x13000200
#define ADR_AMBER_TM_TIMER2_LOAD       0x13000200
#define ADR_AMBER_TM_TIMER2_VALUE      0x13000204
#define ADR_AMBER_TM_TIMER2_CTRL       0x13000208
#define ADR_AMBER_TM_TIMER2_CLR        0x1300020c

#define ADR_AMBER_UART0_DR             0x16000000
#define ADR_AMBER_UART0_RSR            0x16000004
#define ADR_AMBER_UART0_LCRH           0x16000008
#define ADR_AMBER_UART0_LCRM           0x1600000c
#define ADR_AMBER_UART0_LCRL           0x16000010
#define ADR_AMBER_UART0_CR             0x16000014
#define ADR_AMBER_UART0_FR             0x16000018
#define ADR_AMBER_UART0_IIR            0x1600001c
#define ADR_AMBER_UART0_ICR            0x1600001c

#define ADR_AMBER_UART1_DR             0x17000000
#define ADR_AMBER_UART1_RSR            0x17000004
#define ADR_AMBER_UART1_LCRH           0x17000008
#define ADR_AMBER_UART1_LCRM           0x1700000c
#define ADR_AMBER_UART1_LCRL           0x17000010
#define ADR_AMBER_UART1_CR             0x17000014
#define ADR_AMBER_UART1_FR             0x17000018
#define ADR_AMBER_UART1_IIR            0x1700001c
#define ADR_AMBER_UART1_ICR            0x1700001c

#define ADR_AMBER_CORE_CTRL            0x1300031c

#define ADR_ETHMAC_MODER               0x20000000
#define ADR_ETHMAC_INT_SOURCE          0x20000004
#define ADR_ETHMAC_INT_MASK            0x20000008
#define ADR_ETHMAC_MIIMODER            0x20000028
#define ADR_ETHMAC_MIICOMMAND          0x2000002C
#define ADR_ETHMAC_MIIADDRESS          0x20000030
#define ADR_ETHMAC_MIITXDATA           0x20000034
#define ADR_ETHMAC_MIIRXDATA           0x20000038
#define ADR_ETHMAC_MIISTATUS           0x2000003C
#define ADR_ETHMAC_MAC_ADDR0           0x20000040
#define ADR_ETHMAC_MAC_ADDR1           0x20000044

#define ADR_ETHMAC_BDBASE              0x20000400

#define ADR_HIBOOT_BASE                0x28000000
