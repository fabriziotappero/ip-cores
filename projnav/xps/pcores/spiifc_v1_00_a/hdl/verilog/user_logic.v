//----------------------------------------------------------------------------
// user_logic.vhd - module
//----------------------------------------------------------------------------
//
// ***************************************************************************
// ** Copyright (c) 1995-2011 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** Xilinx, Inc.                                                          **
// ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
// ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
// ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
// ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
// ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
// ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
// ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
// ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
// ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
// ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
// ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
// ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
// ** FOR A PARTICULAR PURPOSE.                                             **
// **                                                                       **
// ***************************************************************************
//
//----------------------------------------------------------------------------
// Filename:          user_logic.vhd
// Version:           1.00.a
// Description:       User logic module.
// Date:              Tue Feb 28 11:11:15 2012 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

module user_logic
(
  // -- ADD USER PORTS BELOW THIS LINE ---------------
  // --USER ports added here 
  SPI_CLK,
  SPI_MOSI,
  SPI_MISO,
  SPI_SS,
  // -- ADD USER PORTS ABOVE THIS LINE ---------------

  // -- DO NOT EDIT BELOW THIS LINE ------------------
  // -- Bus protocol ports, do not add to or delete 
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Reset,                   // Bus to IP reset
  Bus2IP_Addr,                    // Bus to IP address bus
  Bus2IP_CS,                      // Bus to IP chip select for user logic memory selection
  Bus2IP_RNW,                     // Bus to IP read/not write
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_BE,                      // Bus to IP byte enables
  Bus2IP_RdCE,                    // Bus to IP read chip enable
  Bus2IP_WrCE,                    // Bus to IP write chip enable
  Bus2IP_Burst,                   // Bus to IP burst-mode qualifier
  Bus2IP_BurstLength,             // Bus to IP burst length
  Bus2IP_RdReq,                   // Bus to IP read request
  Bus2IP_WrReq,                   // Bus to IP write request
  IP2Bus_AddrAck,                 // IP to Bus address acknowledgement
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error,                   // IP to Bus error response
  IP2Bus_IntrEvent                // IP to Bus interrupt event
  // -- DO NOT EDIT ABOVE THIS LINE ------------------
); // user_logic

// -- ADD USER PARAMETERS BELOW THIS LINE ------------
// --USER parameters added here 
// -- ADD USER PARAMETERS ABOVE THIS LINE ------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol parameters, do not add to or delete
parameter C_SLV_AWIDTH                   = 32;
parameter C_SLV_DWIDTH                   = 32;
parameter C_NUM_REG                      = 16;
parameter C_NUM_MEM                      = 2;
parameter C_NUM_INTR                     = 1;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

// -- ADD USER PORTS BELOW THIS LINE -----------------
// --USER ports added here 
input                                     SPI_CLK;
input                                     SPI_MOSI;
output                                    SPI_MISO;
input                                     SPI_SS;
// -- ADD USER PORTS ABOVE THIS LINE -----------------

// -- DO NOT EDIT BELOW THIS LINE --------------------
// -- Bus protocol ports, do not add to or delete
input                                     Bus2IP_Clk;
input                                     Bus2IP_Reset;
input      [0 : C_SLV_AWIDTH-1]           Bus2IP_Addr;
input      [0 : C_NUM_MEM-1]              Bus2IP_CS;
input                                     Bus2IP_RNW;
input      [0 : C_SLV_DWIDTH-1]           Bus2IP_Data;
input      [0 : C_SLV_DWIDTH/8-1]         Bus2IP_BE;
input      [0 : C_NUM_REG-1]              Bus2IP_RdCE;
input      [0 : C_NUM_REG-1]              Bus2IP_WrCE;
input                                     Bus2IP_Burst;
input      [0 : 8]                        Bus2IP_BurstLength;
input                                     Bus2IP_RdReq;
input                                     Bus2IP_WrReq;
output                                    IP2Bus_AddrAck;
output     [0 : C_SLV_DWIDTH-1]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;
output     [0 : C_NUM_INTR-1]             IP2Bus_IntrEvent;
// -- DO NOT EDIT ABOVE THIS LINE --------------------

//----------------------------------------------------------------------------
// Implementation
//----------------------------------------------------------------------------

  // --USER nets declarations added here, as needed for user logic
  
  // Memmap memory logic lines
  wire       [0 : C_NUM_MEM-1 ]             mem_enb;      // Port B: sysbus/dma
  wire       [0 : C_NUM_MEM-1 ]             mem_web;
  wire       [0 : C_NUM_MEM-1]              mem_write;
  wire       [0 : C_NUM_MEM-1]              mem_read;
  reg        [0 : C_NUM_MEM-1 ]             mem_read_prev;

  //   mosiMem (mem0): data received from master
  wire                                      mosiMem_wea;
  wire       [0 : 11]                       mosiMem_addra;
  wire       [0 : 7 ]                       mosiMem_dina;
  wire       [0 : 9 ]                       mosiMem_addrb;
  wire       [0 : 31]                       mosiMem_dinb;
  wire       [0 : 31]                       mosiMem_doutb;           
  //   misoMem (mem1): data to send to master
  wire       [0 : 11]                       misoMem_addra;
  wire       [0 : 7 ]                       misoMem_douta;
  wire       [0 : 9 ]                       misoMem_addrb;
  wire       [0 : 31]                       misoMem_dinb;
  wire       [0 : 31]                       misoMem_doutb;
  
  // Nets for user logic slave model s/w accessible register example
  reg        [0 : C_SLV_DWIDTH-1]           slv_reg                   [0:15];
  wire       [0 : 15]                       slv_reg_write_sel;
  wire       [0 : 15]                       slv_reg_read_sel;
  reg        [0 : C_SLV_DWIDTH-1]           slv_ip2bus_data;
  wire                                      slv_read_ack;
  wire                                      slv_write_ack;
  integer                                   byte_index, bit_index;
  
  // SPI register access
  wire       [3 : 0]                        spiRegAddr;
  wire       [C_SLV_DWIDTH-1 : 0]           spiRegWriteData;
  wire                                      spiRegWE;
  reg        [C_SLV_DWIDTH-1 : 0]           spiRegReadData_wreg;

  // --USER logic implementation added here
  
  //   memory interface logic
  assign mem_enb       = mem_write | mem_read;
  assign mem_web       = mem_write;
  assign mosiMem_addrb = Bus2IP_Addr[20:29];
  assign mosiMem_dinb  = Bus2IP_Data;
  assign misoMem_addrb = Bus2IP_Addr[20:29];
  assign misoMem_dinb  = Bus2IP_Data;
  
  assign mem_write     = Bus2IP_CS & {C_NUM_MEM{Bus2IP_WrReq & (~Bus2IP_RNW)}};
  assign mem_read      = Bus2IP_CS & {C_NUM_MEM{Bus2IP_RdReq & Bus2IP_RNW}};
  
  always @(posedge Bus2IP_Clk) begin
    mem_read_prev <= mem_read;
  end
  
  // Mem0: Memory buffer storing data coming from master
  buffermem mosiMem (
    .clka(Bus2IP_Clk),        // input clka
    .ena(1'b1),         // input ena
    .wea(mosiMem_wea),               // Always writing, never reading
    .addra({mosiMem_addra}),  // input [11 : 0] addra
    .dina({mosiMem_dina}),    // input [7 : 0] dina
 // .douta(mosiMem_douta),    // NEVER USED: output [7 : 0] douta
    .clkb(Bus2IP_Clk),        // input clkb
    .enb(mem_enb[0]),         // input enb
    .web(mem_web[0]),         // input [0 : 0] web
    .addrb({mosiMem_addrb}),  // input [9 : 0] addrb
    .dinb({mosiMem_dinb}),    // input [31 : 0] dinb
    .doutb({mosiMem_doutb})   // output [31 : 0] doutb
  );

  // Mem1: Memory buffer storing data to send to master
  buffermem misoMem (
    .clka(Bus2IP_Clk),        // input clka
    .ena(1'b1),               // input ena
    .wea(1'b0),               // Always reading, never writing
    .addra({misoMem_addra}),  // input [11 : 0] addra
//  .dina(dina),              // input [7 : 0] dina
    .douta({misoMem_douta}),  // output [7 : 0] douta
    .clkb(Bus2IP_Clk),        // input clkb
    .enb(mem_enb[1]),         // input enb
    .web(mem_web[1]),         // input [0 : 0] web
    .addrb({misoMem_addrb}),  // input [9 : 0] addrb
    .dinb({misoMem_dinb}),    // input [31 : 0] dinb
    .doutb({misoMem_doutb})   // output [31 : 0] doutb
  );
  
  spiifc spi (
    .Reset(Bus2IP_Reset),
    .SysClk(Bus2IP_Clk),
    .SPI_CLK(SPI_CLK),
    .SPI_MISO(SPI_MISO),
    .SPI_MOSI(SPI_MOSI),
    .SPI_SS(SPI_SS),
    .txMemAddr(misoMem_addra),
    .txMemData(misoMem_douta),
    .rcMemAddr(mosiMem_addra),
    .rcMemData(mosiMem_dina),
    .rcMemWE(mosiMem_wea),
    .regAddr(spiRegAddr),
    .regReadData(spiRegReadData_wreg),
    .regWriteData(spiRegWriteData),
    .regWriteEn(spiRegWE)
  );

  // ------------------------------------------------------
  // Example code to read/write user logic slave model s/w accessible registers
  // 
  // Note:
  // The example code presented here is to show you one way of reading/writing
  // software accessible registers implemented in the user logic slave model.
  // Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  // to one software accessible register by the top level template. For example,
  // if you have four 32 bit software accessible registers in the user logic,
  // you are basically operating on the following memory mapped registers:
  // 
  //    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  //                     "1000"   C_BASEADDR + 0x0
  //                     "0100"   C_BASEADDR + 0x4
  //                     "0010"   C_BASEADDR + 0x8
  //                     "0001"   C_BASEADDR + 0xC
  // 
  // ------------------------------------------------------

  assign
    slv_reg_write_sel = Bus2IP_WrCE[0:15],
    slv_reg_read_sel  = Bus2IP_RdCE[0:15], 
    slv_write_ack     = Bus2IP_WrCE[0] || Bus2IP_WrCE[1] || Bus2IP_WrCE[2] || Bus2IP_WrCE[3] || Bus2IP_WrCE[4] || Bus2IP_WrCE[5] || Bus2IP_WrCE[6] || Bus2IP_WrCE[7] || Bus2IP_WrCE[8] || Bus2IP_WrCE[9] || Bus2IP_WrCE[10] || Bus2IP_WrCE[11] || Bus2IP_WrCE[12] || Bus2IP_WrCE[13] || Bus2IP_WrCE[14] || Bus2IP_WrCE[15],
    slv_read_ack      = Bus2IP_RdCE[0] || Bus2IP_RdCE[1] || Bus2IP_RdCE[2] || Bus2IP_RdCE[3] || Bus2IP_RdCE[4] || Bus2IP_RdCE[5] || Bus2IP_RdCE[6] || Bus2IP_RdCE[7] || Bus2IP_RdCE[8] || Bus2IP_RdCE[9] || Bus2IP_RdCE[10] || Bus2IP_RdCE[11] || Bus2IP_RdCE[12] || Bus2IP_RdCE[13] || Bus2IP_RdCE[14] || Bus2IP_RdCE[15];

  genvar regIndex;
  generate
    for (regIndex = 0; regIndex < 16; regIndex = regIndex + 1) begin : REG_LOGIC
      // Reg write logic
      always @(posedge Bus2IP_Clk) begin
        if (Bus2IP_Reset == 1) begin
          slv_reg[regIndex] <= 0;
        end else if (spiRegWE && regIndex == spiRegAddr) begin
          slv_reg[regIndex] <= spiRegWriteData;
        end else if (slv_reg_write_sel[regIndex]) begin
          for ( byte_index = 0; byte_index <= (C_SLV_DWIDTH/8)-1; byte_index = byte_index + 1 ) begin
            if ( Bus2IP_BE[byte_index] == 1) begin
              for ( bit_index = byte_index*8; bit_index <= byte_index*8+7; bit_index = bit_index+1) begin
                slv_reg[regIndex][bit_index] <= Bus2IP_Data[bit_index];
              end
            end
          end
        end
      end
    end
  endgenerate

  // implement slave model register read mux
  always @( slv_reg_read_sel or slv_reg[0] or slv_reg[1] or slv_reg[2] 
            or slv_reg[3] or slv_reg[4] or slv_reg[5] or slv_reg[6] or slv_reg[7] 
            or slv_reg[8] or slv_reg[9] or slv_reg[10] or slv_reg[11] or slv_reg[12] 
            or slv_reg[13] or slv_reg[14] or slv_reg[15] )
    begin: SLAVE_REG_READ_PROC

      case ( slv_reg_read_sel )
        16'b1000000000000000 : slv_ip2bus_data <= slv_reg[0];
        16'b0100000000000000 : slv_ip2bus_data <= slv_reg[1];
        16'b0010000000000000 : slv_ip2bus_data <= slv_reg[2];
        16'b0001000000000000 : slv_ip2bus_data <= slv_reg[3];
        16'b0000100000000000 : slv_ip2bus_data <= slv_reg[4];
        16'b0000010000000000 : slv_ip2bus_data <= slv_reg[5];
        16'b0000001000000000 : slv_ip2bus_data <= slv_reg[6];
        16'b0000000100000000 : slv_ip2bus_data <= slv_reg[7];
        16'b0000000010000000 : slv_ip2bus_data <= slv_reg[8];
        16'b0000000001000000 : slv_ip2bus_data <= slv_reg[9];
        16'b0000000000100000 : slv_ip2bus_data <= slv_reg[10];
        16'b0000000000010000 : slv_ip2bus_data <= slv_reg[11];
        16'b0000000000001000 : slv_ip2bus_data <= slv_reg[12];
        16'b0000000000000100 : slv_ip2bus_data <= slv_reg[13];
        16'b0000000000000010 : slv_ip2bus_data <= slv_reg[14];
        16'b0000000000000001 : slv_ip2bus_data <= slv_reg[15];
        default : slv_ip2bus_data <= 0;
      endcase

    end // SLAVE_REG_READ_PROC

  // implement spi register read mux
  always @( spiRegAddr or slv_reg[0] or slv_reg[1] or slv_reg[2] 
            or slv_reg[3] or slv_reg[4] or slv_reg[5] or slv_reg[6] or slv_reg[7] 
            or slv_reg[8] or slv_reg[9] or slv_reg[10] or slv_reg[11] or slv_reg[12] 
            or slv_reg[13] or slv_reg[14] or slv_reg[15] ) begin
    spiRegReadData_wreg <= slv_reg[spiRegAddr];
  end 

  // ------------------------------------------------------------
  // Example code to drive IP to Bus signals
  // ------------------------------------------------------------

  assign IP2Bus_AddrAck = slv_write_ack || slv_read_ack || (|mem_read) || (|mem_write);
  assign IP2Bus_Data    = (mem_read_prev[0] ? mosiMem_doutb : (
                           mem_read_prev[1] ? misoMem_doutb : 
                                              slv_ip2bus_data));
  assign IP2Bus_WrAck   = slv_write_ack || (|mem_write);
  assign IP2Bus_RdAck   = slv_read_ack || (|mem_read_prev);
  assign IP2Bus_Error   = 0;

endmodule
