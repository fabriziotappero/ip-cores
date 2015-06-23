//////////////////////////////////////////////////////////////////
//                                                              //
//  Hazard unit for Edge Core                                   //
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//  Hazard unit is responsible for detecting different pipline  //
//  hazards, and solving these hazards either by forwarding or  //
//  stalling the pipeline.                                      //
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

module hazard_unit
#(
  parameter N=32, M=5
)
(
  input CLK,
  input[M-1:0] rsE, rtE, /* Source registers to ALU at EX stage */
  input[M-1:0] rsD, rtD, /* Source registers to ALU at EX stage */
  input[M-1:0] DestRegE, DestRegM, DestRegW, /* Destination registers at mem 
  and   wb stages */
  input RegWriteE, RegWriteM, RegWriteW, /* Whether instruction writes to RF or 
  not */
  input loadE, /* load instruction */
  input MemWriteD, MemWriteE, /* Store */
  input[2:0] PCSrcM, /* PCplus4 or not */
  output reg[1:0] ForwardAE, ForwardBE, /* Forward signals to muxes at ALU 
stages   */
  output reg StallF, StallD, StallE, StallM, FlushE, StallW, /* Stall control 
  signals */
  output reg FlushD, FlushM, FlushF,
  input StallDataMemory
);

reg lwStall;
reg FlushControl;
reg stStall; /* Store stall right after load */
reg RWHazard; /* Read and Write at the same clock cycle */
reg[1:0] FetchCounter = 0;
reg FetchStall = 0; /* Two clock cycles for fetch to handle BRAM Read latency */
reg[31:0] ClockCycleCount = 0;
wire FetchStallwire = (FetchStall == 1)? 1'b1 : 1'b0;
reg StoresInRowStall = 0;

always @*
begin
  lwStall = 1'b0;
  stStall = 1'b0;
  RWHazard = 1'b0;
  ForwardAE = 2'b00;
  ForwardBE = 2'b00;
  StallF = 1'b0;
  StallD = 1'b0;
  FlushM = 1'b0;
  FlushD = 1'b0;
  FlushE = 1'b0;
  FlushControl = 1'b0;
  StoresInRowStall = 1'b0;

  if(rsE != 5'd0 && rsE == DestRegM && RegWriteM)
    ForwardAE = 2'b10;
  else if(rsE != 5'd0 && rsE == DestRegW && RegWriteW)
    ForwardAE = 2'b01;
  else 
    ForwardAE = 2'b00;
    
  if(rtE != 5'd0 && rtE == DestRegM && RegWriteM)
    ForwardBE = 2'b10;
  else if(rtE != 5'd0 && rtE == DestRegW && RegWriteW)
    ForwardBE = 2'b01;
  else 
    ForwardBE = 2'b00;
    
  /* load stall */
  if(loadE && (rsD == rtE || rtD == rtE))
    lwStall = 1'b1;
  else
    lwStall = 1'b0;
    
  /* Store stall */
  if
  (
    (RegWriteM && MemWriteD && DestRegM == rtD) ||
    (RegWriteE
    && MemWriteD && DestRegE == rtD)
  )
    stStall = 1'b1;
    
  /* Stall for one clock cycle if there is two stores in row */
  if(MemWriteD && MemWriteE)
  begin
    StoresInRowStall = 1;
  end
  
  /* Branch detected */
  if(PCSrcM != 3'b000)
      FlushControl = 1'b1;

  /* Stall one clock cycle if there is w/r to a register in the same time */
  if(
     (DestRegW == rsD || DestRegW == rtD) &&
     DestRegW !=0 &&
     StallDataMemory !=1
    )
      RWHazard = 1'b1;
    
  if(
      (DestRegM == rsD || DestRegM == rtD)
      && DestRegM !=0 &&
      MemWriteE && 
      StallDataMemory != 1
    )
      RWHazard = 1'b1;
    
  StallF = (lwStall == 1'b1 || stStall || RWHazard ||
  StoresInRowStall)? 1'b1:1'b0;
  
  StallD = (lwStall == 1'b1 || stStall || RWHazard ||
  StoresInRowStall)? 1'b1:1'b0;
  
  StallE = (lwStall == 1'b1)? 1'b1:1'b0;
  StallM = (lwStall == 1'b1)? 1'b1:1'b0;
  StallW = 0;
  FlushF = (FlushControl);
  FlushE = 
  (lwStall || stStall || FlushControl || StoresInRowStall || 
   RWHazard)  ? 1'b1:1'b0;
  FlushD = ((FlushControl == 1'b1))? 1'b1:1'b0;
  FlushM = (FlushControl == 1'b1)? 1'b1:1'b0;

end

endmodule
