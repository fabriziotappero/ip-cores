//////////////////////////////////////////////////////////////////
//                                                              //
//  Register Addresses                                          //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Parameters that define the 16 lower bits of the address     //
//  of every register in the system. The upper 16 bits is       //
//  defined by which module the register is in.                 //
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
//////////////////////////////////////////////////////////////////


// ======================================
// Register Addresses
// ======================================

// Test Module
localparam AMBER_TEST_STATUS   	    = 16'h0000;
localparam AMBER_TEST_FIRQ_TIMER    = 16'h0004;
localparam AMBER_TEST_IRQ_TIMER     = 16'h0008;
localparam AMBER_TEST_UART_CONTROL  = 16'h0010;
localparam AMBER_TEST_UART_STATUS   = 16'h0014;
localparam AMBER_TEST_UART_TXD      = 16'h0018;
localparam AMBER_TEST_SIM_CTRL      = 16'h001c;
localparam AMBER_TEST_MEM_CTRL      = 16'h0020;
localparam AMBER_TEST_CYCLES        = 16'h0024;
localparam AMBER_TEST_LED           = 16'h0028;
localparam AMBER_TEST_PHY_RST       = 16'h002c;

localparam AMBER_TEST_RANDOM_NUM    = 16'h0100;
localparam AMBER_TEST_RANDOM_NUM00  = 16'h0100;
localparam AMBER_TEST_RANDOM_NUM01  = 16'h0104;
localparam AMBER_TEST_RANDOM_NUM02  = 16'h0108;
localparam AMBER_TEST_RANDOM_NUM03  = 16'h010c;
localparam AMBER_TEST_RANDOM_NUM04  = 16'h0110;
localparam AMBER_TEST_RANDOM_NUM05  = 16'h0114;
localparam AMBER_TEST_RANDOM_NUM06  = 16'h0118;
localparam AMBER_TEST_RANDOM_NUM07  = 16'h011c;
localparam AMBER_TEST_RANDOM_NUM08  = 16'h0120;
localparam AMBER_TEST_RANDOM_NUM09  = 16'h0124;
localparam AMBER_TEST_RANDOM_NUM10  = 16'h0128;
localparam AMBER_TEST_RANDOM_NUM11  = 16'h012c;
localparam AMBER_TEST_RANDOM_NUM12  = 16'h0130;
localparam AMBER_TEST_RANDOM_NUM13  = 16'h0134;
localparam AMBER_TEST_RANDOM_NUM14  = 16'h0138;
localparam AMBER_TEST_RANDOM_NUM15  = 16'h013c;


// Interrupt Controller
localparam AMBER_IC_IRQ0_STATUS     = 16'h0000;
localparam AMBER_IC_IRQ0_RAWSTAT    = 16'h0004;
localparam AMBER_IC_IRQ0_ENABLESET  = 16'h0008;
localparam AMBER_IC_IRQ0_ENABLECLR  = 16'h000c;
localparam AMBER_IC_INT_SOFTSET_0   = 16'h0010;
localparam AMBER_IC_INT_SOFTCLEAR_0 = 16'h0014;
localparam AMBER_IC_FIRQ0_STATUS    = 16'h0020;
localparam AMBER_IC_FIRQ0_RAWSTAT   = 16'h0024;
localparam AMBER_IC_FIRQ0_ENABLESET = 16'h0028;
localparam AMBER_IC_FIRQ0_ENABLECLR = 16'h002c;
localparam AMBER_IC_IRQ1_STATUS     = 16'h0040;
localparam AMBER_IC_IRQ1_RAWSTAT    = 16'h0044;
localparam AMBER_IC_IRQ1_ENABLESET  = 16'h0048;
localparam AMBER_IC_IRQ1_ENABLECLR  = 16'h004c;
localparam AMBER_IC_INT_SOFTSET_1   = 16'h0050;
localparam AMBER_IC_INT_SOFTCLEAR_1 = 16'h0054;
localparam AMBER_IC_FIRQ1_STATUS    = 16'h0060;
localparam AMBER_IC_FIRQ1_RAWSTAT   = 16'h0064;
localparam AMBER_IC_FIRQ1_ENABLESET = 16'h0068;
localparam AMBER_IC_FIRQ1_ENABLECLR = 16'h006c;
localparam AMBER_IC_INT_SOFTSET_2   = 16'h0090;
localparam AMBER_IC_INT_SOFTCLEAR_2 = 16'h0094;
localparam AMBER_IC_INT_SOFTSET_3   = 16'h00d0;
localparam AMBER_IC_INT_SOFTCLEAR_3 = 16'h00d4;


// Timer Module
localparam AMBER_TM_TIMER0_LOAD    =  16'h0000;
localparam AMBER_TM_TIMER0_VALUE   =  16'h0004;
localparam AMBER_TM_TIMER0_CTRL    =  16'h0008;
localparam AMBER_TM_TIMER0_CLR     =  16'h000c;
localparam AMBER_TM_TIMER1_LOAD    =  16'h0100;
localparam AMBER_TM_TIMER1_VALUE   =  16'h0104;
localparam AMBER_TM_TIMER1_CTRL    =  16'h0108;
localparam AMBER_TM_TIMER1_CLR     =  16'h010c;
localparam AMBER_TM_TIMER2_LOAD    =  16'h0200;
localparam AMBER_TM_TIMER2_VALUE   =  16'h0204;
localparam AMBER_TM_TIMER2_CTRL    =  16'h0208;
localparam AMBER_TM_TIMER2_CLR     =  16'h020c;


// UART 0 and 1
localparam AMBER_UART_PID0         =  16'h0fe0;
localparam AMBER_UART_PID1         =  16'h0fe4;
localparam AMBER_UART_PID2         =  16'h0fe8;
localparam AMBER_UART_PID3         =  16'h0fec;
localparam AMBER_UART_CID0         =  16'h0ff0;
localparam AMBER_UART_CID1         =  16'h0ff4;
localparam AMBER_UART_CID2         =  16'h0ff8;
localparam AMBER_UART_CID3         =  16'h0ffc;
localparam AMBER_UART_DR           =  16'h0000;
localparam AMBER_UART_RSR          =  16'h0004;
localparam AMBER_UART_LCRH         =  16'h0008;
localparam AMBER_UART_LCRM         =  16'h000c;
localparam AMBER_UART_LCRL         =  16'h0010;
localparam AMBER_UART_CR           =  16'h0014;
localparam AMBER_UART_FR           =  16'h0018;
localparam AMBER_UART_IIR          =  16'h001c;
localparam AMBER_UART_ICR          =  16'h001c;

