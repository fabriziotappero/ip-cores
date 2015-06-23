//////////////////////////////////////////////////////////////////
//                                                              //
//  Coprocessor0 for Edge core                                  //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Coprocessor0 in MIPS is the control unit mainly respobsible //
//  for handling interrupts.                                    //
//                                                              //
//  Author(s):                                                  //
//      - Hesham AL-Matary, heshamelmatary@gmail.com            //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2014 Authors and OPENCORES.ORG                 //
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

/* Coprocessor 0 instructions definitions */
`define EXCEPTION       1 /* Take exception, save EPC and Cause */
`define READ_REG        2 /* Read one of Coprocessor0 registers mfc0, lwc0 */
`define WRITE_REG       3 /* Write to Coprocessor0 Registers */

/* Clock definitions */
`define SYSCLK    50000000 //25MHz
`define MS_LIMIT  `SYSCLK / 1000 // 1MS counter limit

module Coprocessor0
#
(
  parameter N=32,
  parameter M=5
)
(
  input clk,
  input [N-1:0] EPC,
  input [N-1:0] Cause,
  input [1:0] instruction,
  input [M-1:0] ra, /* Read address */
  input [M-1:0] wa, /* Write address */
  input [N-1:0] WriteData,
  input IO_TimerIntReset, /* reset timer from software */
  
  output[N-1:0] ReadData,
  output TimerIntMatch
);

/********* Coprocessor0 currently supported registers *******
* 0   
* 1
* 2
* 3
* 4
* 5
* 6
* 7
* 8
* 9     Counter
* 10
* 11    Compare
* 12    Status
* 13    Cause
* 14    EPC
* 15
* 16
* 17
* 18
* 19
* 20
* 21
* 22
*************************************************************/
reg[N-1:0] rf [(2**M)-1:0];

reg TimerMatch = 0; /* Count = Compare */

assign TimerIntMatch = TimerMatch;

reg[31:0] ClockCycleCount = 0;
reg[63:0] Counter = 0;
integer i = 0;

initial
begin
  for(i=0; i<32; i=i+1)
    rf[i] = 0;
end

always @(posedge clk)
begin
  
    
	case (instruction)
    `EXCEPTION: 
    begin
      rf[13] = Cause;
      rf[14] = EPC;
    end
    `WRITE_REG:
      rf[wa] = WriteData;
   endcase
   
  /* Timer operations */
    Counter = Counter + 1;

    if(Counter == `MS_LIMIT) // 1MS passed
    begin
      rf[9] = rf[9] + 1;
      Counter = 0;
    end
    
    if(rf[9] == rf[11])
      TimerMatch = 1;
    
    if(IO_TimerIntReset)
    begin
      rf[9] = 0;
      TimerMatch = 0;
      Counter = 0;
    end
  /* Timer operation */
  
end

assign ReadData = rf[ra];

endmodule
