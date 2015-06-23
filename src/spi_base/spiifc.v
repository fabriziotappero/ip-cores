`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:46:12 03/02/2012 
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
  regAddr,
  regReadData,
  regWriteEn,
  regWriteData,
  debug_out
);

//
// Parameters
//
parameter AddrBits = 12;
parameter RegAddrBits = 4;

//
// Defines
//
`define CMD_READ_START    8'd1
`define CMD_READ_MORE     8'd2
`define CMD_WRITE_START   8'd3
`define CMD_WRITE_MORE    8'd4
`define CMD_INTERRUPT     8'd5

`define CMD_REG_BASE      8'd128
`define CMD_REG_BIT       7
`define CMD_REG_WE_BIT    6
`define CMD_REG_ID_MASK   8'h3F

`define STATE_GET_CMD     8'd0
`define STATE_READING     8'd1
`define STATE_WRITING     8'd2
`define STATE_WRITE_INTR  8'd3
`define STATE_BUILD_WORD  8'd4
`define STATE_SEND_WORD   8'd5

//
// Input/Outputs
//
input                    Reset;
input                    SysClk;

input                    SPI_CLK;
output                   SPI_MISO;     // outgoing (from respect of this module)
input                    SPI_MOSI;     // incoming (from respect of this module)
input                    SPI_SS;

output [AddrBits-1:0]    txMemAddr;    // outgoing data
input           [7:0]    txMemData;
output [AddrBits-1:0]    rcMemAddr;    // incoming data
output          [7:0]    rcMemData;
output                   rcMemWE;

output [RegAddrBits-1:0] regAddr;       // Register read address (combinational)
input             [31:0] regReadData;   // Result of register read
output                   regWriteEn;    // Enable write to register, otherwise read
output            [31:0] regWriteData;  // Register write data


output          [7:0] debug_out;

//
// Registers
//
reg                   SPI_CLK_reg;    // Stabalized version of SPI_CLK
reg                   SPI_SS_reg;     // Stabalized version of SPI_SS
reg                   SPI_MOSI_reg;   // Stabalized version of SPI_MOSI

reg                   prev_spiClk;    // Value of SPI_CLK during last SysClk cycle
reg                   prev_spiSS;     // Value of SPI_SS during last SysClk cycle
reg             [7:0] state_reg;      // Register backing the 'state' wire
reg             [7:0] rcByte_reg;     // Register backing 'rcByte'
reg             [2:0] rcBitIndex_reg; // Register backing 'rcBitIndex'
reg    [AddrBits-1:0] rcMemAddr_reg;  // Byte addr to write MOSI data to
reg             [7:0] debug_reg;      // register backing debug_out signal
reg             [2:0] txBitIndex_reg; // Register backing txBitIndex
reg    [AddrBits-1:0] txMemAddr_reg;  // Register backing txAddr

reg             [7:0] command;        // Command being handled
reg            [31:0] rcWord;         // Incoming word being built
reg             [1:0] rcWordByteId;   // Which byte the in the rcWord to map to
reg [RegAddrBits-1:0] regAddr_reg;    // Address of register to read/write to

//
// Wires
//
wire                  risingSpiClk;       // Did the SPI_CLK rise since last SysClk cycle?
wire                  validSpiBit;        // Are the SPI MOSI/MISO bits new and valid?
reg             [7:0] state;              // Current state in the module's state machine (always @* effectively wire)
wire                  rcByteValid;        // rcByte is valid and new
wire            [7:0] rcByte;             // Byte received from master
wire            [2:0] rcBitIndex;         // Bit of rcByte to write to next
reg             [2:0] txBitIndex;         // bit of txByte to send to master next
reg    [AddrBits-1:0] txMemAddr_oreg;     // Wirereg piped to txMemAddr output
reg             [7:0] regReadByte_oreg;   // Which byte of the reg word we're reading out master

// Save buffered SPI inputs
always @(posedge SysClk) begin
  SPI_CLK_reg <= SPI_CLK;
  SPI_SS_reg <= SPI_SS;
  SPI_MOSI_reg <= SPI_MOSI;
end

// Detect new valid bit
always @(posedge SysClk) begin
  prev_spiClk <= SPI_CLK_reg;
end
assign risingSpiClk = SPI_CLK_reg & (~prev_spiClk);
assign validSpiBit = risingSpiClk & (~SPI_SS_reg);

// Detect new SPI packet (SS dropped low)
always @(posedge SysClk) begin
  prev_spiSS <= SPI_SS_reg;
end
assign packetStart = prev_spiSS & (~SPI_SS_reg);

// Build incoming byte
always @(posedge SysClk) begin
  if (validSpiBit) begin
    rcByte_reg[rcBitIndex] <= SPI_MOSI_reg;
    rcBitIndex_reg <= (rcBitIndex > 0 ? rcBitIndex - 1 : 7);
  end else begin
    rcBitIndex_reg <= rcBitIndex;
  end
end
assign rcBitIndex = (Reset || packetStart ? 7 : rcBitIndex_reg); 
assign rcByte = {rcByte_reg[7:1], SPI_MOSI_reg};
assign rcByteValid = (validSpiBit && rcBitIndex == 0 ? 1 : 0);

// Incoming MOSI data buffer management
assign rcMemAddr = rcMemAddr_reg;
assign rcMemData = rcByte;
assign rcMemWE = (state == `STATE_READING && rcByteValid ? 1 : 0);
always @(posedge SysClk) begin
  if (Reset || (`STATE_GET_CMD == state && rcByteValid)) begin
    rcMemAddr_reg <= 0;
  end else if (rcMemWE) begin
    rcMemAddr_reg <= rcMemAddr + 1;
  end else begin
    rcMemAddr_reg <= rcMemAddr;
  end
end

// Outgoing MISO data buffer management
always @(*) begin
  if (Reset || (state == `STATE_GET_CMD && rcByteValid && 
                  (rcByte == `CMD_WRITE_START || 
                   rcByte[`CMD_REG_BIT:`CMD_REG_WE_BIT] == 2'b11)
                )) begin
    txBitIndex <= 3'd7;
    txMemAddr_oreg <= 0;
  end else begin
    txBitIndex <= txBitIndex_reg;

    //txMemAddr_oreg <= txMemAddr_reg;
    if ((state == `STATE_WRITING || state == `STATE_SEND_WORD) && 
        validSpiBit && txBitIndex == 0) begin
      txMemAddr_oreg <= txMemAddr_reg + 1;
    end else begin
      txMemAddr_oreg <= txMemAddr_reg;
    end
    
  end
end
always @(posedge SysClk) begin
  if (validSpiBit && (state == `STATE_WRITING || state == `STATE_SEND_WORD)) begin
    txBitIndex_reg <= (txBitIndex == 0 ? 7 : txBitIndex - 1);
  end else begin
    txBitIndex_reg <= txBitIndex;
  end

  txMemAddr_reg <= txMemAddr;
//  if (state == `STATE_WRITING && validSpiBit && txBitIndex == 0) begin
//    txMemAddr_reg <= txMemAddr + 1;
//  end else begin
//    txMemAddr_reg <= txMemAddr;  
//  end
end
assign txMemAddr = txMemAddr_oreg;
assign SPI_MISO = (state == `STATE_SEND_WORD ? regReadByte_oreg[txBitIndex] : txMemData[txBitIndex]);

// State machine
always @(*) begin
  if (Reset || packetStart) begin
    state <= `STATE_GET_CMD;
// Handled in state_reg logic, should be latched, not immediate.
//  end else if (state_reg == `STATE_GET_CMD && rcByteValid) begin
//    state <= rcByte;
  end else begin
    state <= state_reg;
  end
end
always @(posedge SysClk) begin
  if (`STATE_GET_CMD == state && rcByteValid) begin
    if (`CMD_READ_START == rcByte) begin
      state_reg <= `STATE_READING;
    end else if (`CMD_READ_MORE == rcByte) begin
      state_reg <= `STATE_READING;
    end else if (`CMD_WRITE_START == rcByte) begin
      state_reg <= `STATE_WRITING;
    end else if (`CMD_WRITE_MORE == rcByte) begin
      state_reg <= `STATE_WRITING;
    end else if (rcByte[`CMD_REG_BIT] != 0) begin
      // Register access
      rcWordByteId <= 0;
      command <= `CMD_REG_BASE;               // Write reg           Read reg
      state_reg <= (rcByte[`CMD_REG_WE_BIT] ? `STATE_BUILD_WORD : `STATE_SEND_WORD);      
    end else if (`CMD_INTERRUPT == rcByte) begin
      // TODO: NYI
    end
  end else if (`STATE_BUILD_WORD == state && rcByteValid) begin
    if (0 == rcWordByteId) begin
      rcWord[31:24] <= rcByte;
      rcWordByteId <= 1;
    end else if (1 == rcWordByteId) begin
      rcWord[23:16] <= rcByte;
      rcWordByteId <= 2;
    end else if (2 == rcWordByteId) begin
      rcWord[15:8] <= rcByte;
      rcWordByteId <= 3;
    end else if (3 == rcWordByteId) begin
      rcWord[7:0] <= rcByte;
      state_reg <= `STATE_GET_CMD;
    end
  end else if (`STATE_SEND_WORD == state && rcByteValid) begin
    rcWordByteId <= rcWordByteId + 1;
    state_reg <= (rcWordByteId == 3 ? `STATE_GET_CMD : `STATE_SEND_WORD);
      
  end else begin
    state_reg <= state;
  end
end

// Register logic
assign regAddr = (`STATE_GET_CMD == state && rcByteValid && rcByte[`CMD_REG_BIT] ? (rcByte & `CMD_REG_ID_MASK) : regAddr_reg);
assign regWriteEn = (`STATE_BUILD_WORD == state && rcByteValid && 3 == rcWordByteId ? 1 : 0);
assign regWriteData = {rcWord[31:8], rcByte};
always @(posedge SysClk) begin
  regAddr_reg <= regAddr;
end
always @(*) begin
  case (rcWordByteId)
    0: regReadByte_oreg <= regReadData[31:24];
    1: regReadByte_oreg <= regReadData[23:16];
    2: regReadByte_oreg <= regReadData[15:8];
    3: regReadByte_oreg <= regReadData[7:0];
  endcase
end

// Debugging
always @(posedge SysClk) begin
  if (rcByteValid) begin
    debug_reg <= rcByte;
  end
end
assign debug_out = debug_reg;

endmodule
