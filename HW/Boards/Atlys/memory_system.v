//////////////////////////////////////////////////////////////////
//                                                              //
//  Main memory system                                          // 
//                                                              //
//  This file is part of the Edge project                       //
//  http://www.opencores.org/project,edge                       //
//                                                              //
//  Description                                                 //
//   Main memory system is not only a wrapper to data memory    //
//   core, but also handling IO memory mapped operations.       //
//   The contents of this file are target dependent.            //
//   IO mapped regios, handles UART, Data memory stalling, timer//
//   and LEDs.                                                  //
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

`define BYTE_REF  2'b01
`define HW_REF    2'b10
`define W_REF     2'b11

`define NO_REF    2'b01
`define LOADING   2'b10
`define STORING   2'b11

module Memory_System
#
(
  parameter N=32, H=16
)
(
  input clk,
  
  /* Processor Related */
  input[N-1:0] ProcessorAddress, /* Address coming from processor */
  input[N-1:0] WriteData,
  input[1:0] MemRefSize, /* Size of data to reference (01->byte, 10->hw, 
11->word) */
  input WE,
  output[N-1:0] RD,
  
  output[N-1:0] UART_TX,
  output UART_VALID, /* There is valid data to send */
  input[7:0] UART_CTRL,
  input CP0_TimerIntMatch,
  output StallBusy,
  output[7:0] BRAM_dataOut,
  output[7:0] LEDs,
  output IO_TimerIntReset
);

wire[31:0] addr;
wire[31:0] ReadValue;
reg[31:0] ReadData;
wire IODev;
wire RODATA_MEM;
wire[31:0] IOReadData;
wire IO_LED;
wire IO_TimerInt;
wire IO_TimerIntReset;

reg[31:0] storeWord = 0;
wire[31:0] ClockCycleMax;
reg[31:0] ClockCycleLimit = 0;
wire BRAM_CLK;
wire[31:0] BRAM_ADDR;
wire[7:0] BRAM_DIN;
wire BRAM_WEA;

wire[7:0] BRAM_DOUT;
wire[7:0] BRAM_RODATA_DOUT;
reg[31:0] BRAM_LOADADDR = 32'h800;
reg       BRAM_LOAD_WEA = 0;
reg[7:0]  BRAM_LOAD_DIN = 0;

reg[31:0] BRAM_ProcessorADDR = 0;
reg       BRAM_PROC_WEA = 0;
reg[7:0]  BRAM_PROC_DIN = 0;

reg GetByte = 0;
wire Stall;
reg fire;
reg[2:0] i = 0;
reg[2:0] loadCounter = 0;
reg[7:0] LED = 0;

assign RD = (IODev)? IOReadData : ReadData;

assign LEDs = LED;

assign UART_VALID = ((ProcessorAddress == 32'hFFFF0100) && WE == 1)?
    1'b1
  : 
    1'b0;

assign IO_TimerIntReset = ((ProcessorAddress == 32'hFFFF010C) && WE == 1)?
    1'b1 
  :
    1'b0;

assign UART_TX = WriteData[7:0];

assign IODev = (ProcessorAddress >= 32'hFFFF0100)? 1'b1 : 1'b0;

assign IO_LED = (ProcessorAddress == 32'hFFFF0108 && WE == 1)? 1'b1 : 1'b0;

assign IO_TimerInt = (ProcessorAddress == 32'hFFFF010C)? 1'b1 : 1'b0;

assign IOReadData = (ProcessorAddress == 32'hFFFF0104)? UART_CTRL :
                    (ProcessorAddress == 32'hFFFF010C)? CP0_TimerIntMatch :
                     32'd0;

assign StallBusy = ((i > 0 && i<=ClockCycleMax) )? 1'b1 : 1'b0;

assign BRAM_CLK =  clk;

assign BRAM_ADDR = BRAM_ProcessorADDR;

assign BRAM_DIN = BRAM_PROC_DIN;

assign BRAM_WEA = BRAM_PROC_WEA;

assign GetByte_out = GetByte;

assign BRAM_dataOut = BRAM_DOUT;

assign RODATA_MEM = 
  (ProcessorAddress >= 32'h00000800 &&
   ProcessorAddress <= 32'h00000BFF)?
   1'b1 : 1'b0;

assign ClockCycleMax = (MemRefSize != 2'b00)?
                        //Loads
                        (WE == 0)?
                          (MemRefSize == `BYTE_REF)? 32'd2 :
                          (MemRefSize == `HW_REF)? 32'd4   :
                          (MemRefSize == `W_REF)? 32'd5   :
                          32'd0
                         : //Stores
                          (MemRefSize == `BYTE_REF)? 32'd1 :
                          (MemRefSize == `HW_REF)? 32'd2   :
                          (MemRefSize == `W_REF)? 32'd4    :
                          32'd0
                         :
                         32'd0;
                         ;

always @(posedge clk)
  if(IO_LED)
    LED = WriteData[7:0];
    
always @(negedge clk)
begin

  //RD = 0;
  BRAM_PROC_WEA = 0;
  //BRAM_ADDR = 0;
  BRAM_PROC_DIN =0;
  if(i == 0)
  begin
    storeWord = WriteData;
    //ReadData = 0;
  end
    
  if(MemRefSize != 2'b00)
  begin
        
    if(i < ClockCycleMax)
    begin
      //StallBusy = 1;
      i = i + 1;
      
      /* Loads */
      if(IODev != 1'b1)
      begin
      BRAM_ProcessorADDR = ProcessorAddress + i - 1;
      //BRAM_DOUT = memory[BRAM_ADDR];
      ReadData =
        (RODATA_MEM)?
          (MemRefSize == `BYTE_REF)?
            {24'd0, BRAM_RODATA_DOUT} 
          :
            (MemRefSize == `HW_REF)?
              {16'd0, BRAM_RODATA_DOUT, ReadData[15:8]} 
            :
              (MemRefSize == `W_REF)? 
                {BRAM_RODATA_DOUT, ReadData[31:8]} 
              :
                32'd0
                  
      :  /* Data memory */
        (MemRefSize == `BYTE_REF)? 
          {24'd0, BRAM_DOUT}
        :
          (MemRefSize == `HW_REF)?
            {16'd0, BRAM_DOUT, ReadData[15:8]} 
          :
            (MemRefSize == `W_REF)?
              {BRAM_DOUT, ReadData[31:8]}
            : 
              32'd0;      
      end
      
      /* Stores to data memory */
      if(WE && IODev != 1'b1)
      begin 
        BRAM_ProcessorADDR = ProcessorAddress + i - 1;
        BRAM_PROC_DIN = storeWord[7:0];
        storeWord = {8'd0, storeWord[31:8]}; 
        BRAM_PROC_WEA = WE;
      end    
        
   end
   
   /* i >= ClockCycleMax */
   else
   begin
     i = 0;
   end
      

  end
end

BRAM8x1024 data_memory 
(
  .clka(BRAM_CLK), // input clka
  .wea(BRAM_WEA), // input [0 : 0] wea
  .addra(BRAM_ADDR), // input [9 : 0] addra
  .dina(BRAM_DIN), // input [7 : 0] dina
  .douta(BRAM_DOUT) // output [7 : 0] douta
);

ROM8x1024 rodata 
(
  .clka(BRAM_CLK), // input clka
  .addra(BRAM_ADDR - 32'h00000800), // input [9 : 0] addra
  .douta(BRAM_RODATA_DOUT) // output [7 : 0] douta
);

endmodule
