`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:49:15 11/02/2011 
// Design Name: 
// Module Name:    spiwrap 
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
module spiwrap(
    input Reset,
    input SysClk,
    input spi_ss,
    input spi_mosi,
    input spi_clk,
    output spi_miso,
    output [7:0] leds
    );

wire [31:0] douta_dummy;

wire [11:0] spi_addr;
wire [ 7:0] spi_data;
wire [31:0] rcMem_douta;

reg        initMem;
reg [ 9:0] initMemAddr;
reg [31:0] initMemData;

always @(posedge SysClk) begin
  if (Reset) begin
    initMem <= 1'b1;
    initMemAddr <= 10'h000;
    initMemData <= 32'h5A6C_C6A5;
  end else begin
    if (initMem == 1'b1) begin
      // Turn off init mem mode if formatted memory 
      if (initMemAddr == 10'h3FF) begin
        initMem <= 1'b0;
      end
    
      // Increment init mem addr/data
      initMemAddr <= initMemAddr + 10'h001;
    end
  end
end

buffermem spiMemTx (
  .clka(SysClk), // input clkb
  .ena(1'b1), // input enb
  .wea(1'b0), // input [0 : 0] web
  .addra(spi_addr), // input [11 : 0] addrb
  .dina(8'h00), // input [7 : 0] dinb
  .douta(spi_data), // output [7 : 0] doutb
  .clkb(SysClk), // input clka 
  .enb(1'b1), // input ena
  .web(initMem), // input [0 : 0] wea
  .addrb(initMemAddr), // input [9 : 0] addra
  .dinb(initMemData), // input [31 : 0] dina
  .doutb(douta_dummy) // output [31 : 0] douta
);

wire        spi_rcMem_we;
wire [11:0] spi_rcMem_addr; 
wire [ 7:0] spi_rcMem_data;
wire [ 7:0] debug_out;
wire [ 7:0] spi_rcMem_doutb_dummy;
buffermem spiMemRc (
  .clka(SysClk),
  .ena(1'b1),
  .wea(spi_rcMem_we),
  .addra(spi_rcMem_addr),
  .dina(spi_rcMem_data),
  .douta(spi_rcMem_doutb_dummy),
  .clkb(SysClk),
  .enb(1'b1),
  .web(1'b0),
  .addrb(10'h001),
  .doutb(rcMem_douta)
);

spiifc mySpiIfc (
  .Reset(Reset),
  .SysClk(SysClk),
  .SPI_CLK(spi_clk),
  .SPI_MISO(spi_miso),
  .SPI_MOSI(spi_mosi),
  .SPI_SS(spi_ss),
  .txMemAddr(spi_addr),
  .txMemData(spi_data),
  .rcMemAddr(spi_rcMem_addr),
  .rcMemData(spi_rcMem_data),
  .rcMemWE(spi_rcMem_we),
  .debug_out(debug_out)
);

assign leds =  rcMem_douta[7:0] /* debug_out */;

endmodule
