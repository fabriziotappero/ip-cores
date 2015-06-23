`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:33 10/18/2011 
// Design Name: 
// Module Name:    spiifc 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spiifc(
  Reset,
  SysClk,
  SPI_CLK,
  SPI_MISO,
  SPI_MOSI,
  SPI_SS,
  txMemAddr,
  txMemData,
  rcMemAddr,
  rcMemData,
  rcMemWE,
  debug_out
  );
  
  //
  // Parameters
  //
  parameter AddrBits = 12;
  
  // Defines
  `define  CMD_READ_START   8'd1
  `define  CMD_READ_MORE    8'd2
  `define  CMD_WRITE_START  8'd3
  
  `define  STATE_GET_CMD    8'd0
  `define  STATE_READING    8'd1
  `define  STATE_WRITING    8'd2
  
  //
  // Input/Output defs
  //
  input  Reset;
  input  SysClk;
  
  input  SPI_CLK;
  output SPI_MISO;
  input  SPI_MOSI;
  input  SPI_SS;
  
  output [AddrBits-1:0] txMemAddr;
  input  [7:0]          txMemData;
  
  output  [AddrBits-1:0] rcMemAddr;
  output  [7:0]          rcMemData;
  output                 rcMemWE;
  
  output  [7:0]          debug_out;
  
  //
  // Registers
  // 
  
  reg  [ 7: 0] debug_reg;
  
  reg  [ 7: 0] rcByteReg;
  reg          rcStarted;
  reg  [ 2: 0] rcBitIndexReg;
  reg  [11: 0] rcMemAddrReg;
  reg  [11: 0] rcMemAddrNext;
  reg  [ 7: 0] rcMemDataReg;
  reg          rcMemWEReg;
  
  reg          ssPrev;
  
  reg          ssFastToggleReg;
  reg          ssSlowToggle;
  
  reg          ssTurnOnReg;
  reg          ssTurnOnHandled;
  
  reg  [ 7: 0] cmd;
  reg  [ 7: 0] stateReg;
  
  reg  [11: 0] txMemAddrReg;
  reg  [ 2: 0] txBitAddr;
  
  //
  // Wires
  //
  wire         rcByteValid; 
  wire [ 7: 0] rcByte;
  wire         rcStarting;
  wire [ 2: 0] rcBitIndex;
  
  wire         ssTurnOn;
  
  wire         ssFastToggle;
  
  wire [ 7: 0] state;
  
  wire         txMemAddrReset;
  
  //
  // Output assigns
  //
  assign debug_out = debug_reg;
  
  assign rcMemAddr = rcMemAddrReg;
  assign rcMemData = rcMemDataReg;
  assign rcMemWE = rcMemWEReg;
  
  assign txMemAddrReset = (rcByteValid && rcByte == `CMD_WRITE_START ? 1 : 0);
  assign txMemAddr = (txMemAddrReset ? 0 : txMemAddrReg);
  assign SPI_MISO = txMemData[txBitAddr];
  
  assign ssFastToggle = 
      (ssPrev == 1 && SPI_SS == 0 ? ~ssFastToggleReg : ssFastToggleReg);
  
  //
  // Wire assigns
  //
  assign rcByteValid = rcStarted && rcBitIndex == 0;
  assign rcByte = {rcByteReg[7:1], SPI_MOSI};
  assign rcStarting = ssTurnOn;
  assign rcBitIndex = (rcStarting ? 3'd7 : rcBitIndexReg);
  
  assign ssTurnOn = ssSlowToggle ^ ssFastToggle;
  assign state = (rcStarting ? `STATE_GET_CMD : stateReg);
  
  initial begin
    ssSlowToggle <= 0;
  end
  
  always @(posedge SysClk) begin
    ssPrev <= SPI_SS;
    
    if (Reset) begin
      ssTurnOnReg <= 0;
      ssFastToggleReg <= 0;

    end else begin
      if (ssPrev & (~SPI_SS)) begin
        ssTurnOnReg <= 1;
        ssFastToggleReg <= ~ssFastToggleReg;
        
      end else if (ssTurnOnHandled) begin
        ssTurnOnReg <= 0;
      end
    end
    
  end
  
  always @(posedge SPI_CLK) begin
    ssSlowToggle <= ssFastToggle;
  
    if (Reset) begin
      // Resetting
      rcByteReg <= 8'h00;
      rcStarted <= 0;
      rcBitIndexReg <= 3'd7;
      ssTurnOnHandled <= 0;
      debug_reg <= 8'hFF;
      
    end else begin
      // Not resetting
      
      ssTurnOnHandled <= ssTurnOn;
      stateReg <= state;
      rcMemAddrReg <= rcMemAddrNext;
          
      if (~SPI_SS) begin
        rcByteReg[rcBitIndex] <= SPI_MOSI;
        rcBitIndexReg <= rcBitIndex - 3'd1;
        rcStarted <= 1;
        
        // Update txBitAddr if writing out
        if (`STATE_WRITING == state) begin
          if (txBitAddr == 3'd1) begin
            txMemAddrReg <= txMemAddr + 1;
          end 
          txBitAddr <= txBitAddr - 1;
        end
      end
      
      // We've just received a byte (well, currently receiving the last bit)
      
      if (rcByteValid) begin
        // For now, just display on LEDs
        debug_reg <= rcByte;
      
        if (`STATE_GET_CMD == state) begin
          cmd <= rcByte;    // Will take effect next cycle
          
          if (`CMD_READ_START == rcByte) begin
            rcMemAddrNext <= 0;
            stateReg <= `STATE_READING;
          end else if (`CMD_READ_MORE == rcByte) begin
            stateReg <= `STATE_READING;
          end else if (`CMD_WRITE_START == rcByte) begin
            txBitAddr <= 3'd7;
            stateReg <= `STATE_WRITING;
            txMemAddrReg <= txMemAddr;  // Keep at 0
          end
         
        end else if (`STATE_READING == state) begin
          rcMemDataReg <= rcByte;
          rcMemAddrNext <= rcMemAddr + 1;
          rcMemWEReg <= 1;
        
        end else if (`STATE_WRITING == state) begin
          txBitAddr <= 3'd7;
          stateReg <= `STATE_WRITING;
        end
      
      end else begin
        // Not a valid byte
        rcMemWEReg <= 0;
        
      end // valid/valid' byte
      
    end // Reset/Reset'
  end
  
endmodule
