`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: R.A. Paz Schmidt
// 
// Create Date:    11:12:42 12/23/2013 
// Design Name: 
// Module Name:    CC3_top_x 
// Project Name:   MC6809/HD6309 compatible core
// Target Devices: 
// Tool versions: Xilinx WebPack v 10.1 (for Spartan II)
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: Distributed under the terms of the Lesser GPL, see LICENSE.TXT
//
//////////////////////////////////////////////////////////////////////////////////
module CC3_top_x(
    input clk32_i,
    output mem_we_n,
    output mem_oe_n,
    output [15:0] mem_addr_o,
    inout [7:0] mem_data_io
    );

wire cpu_clk;
wire	cpu_reset_n;
wire	cpu_nmi_n;
wire	cpu_irq_n;
wire	cpu_firq_n;
wire cpu_state_o;
wire	cpu_we_o;
wire	cpu_oe_o;
wire [15:0] cpu_addr_o;
wire [7:0]	cpu_data_i;
wire [7:0] 	cpu_data_o;
	

assign mem_we_n = cpu_we_o;
assign mem_oe_n = cpu_oe_o;
assign mem_addr_o = cpu_addr_o;
assign mem_data_io = cpu_we_o ? cpu_data_o:cpu_data_i;

wire cpu_reset;
reg [3:0] reset_cnt;

assign cpu_reset = reset_cnt == 4'd14;
always @(posedge clk32_i)
	begin
		if (reset_cnt != 4'd14)
			reset_cnt <= reset_cnt + 4'h1;
	end
	

MC6809_cpu cpu(
	.cpu_clk(clk32_i),
	.cpu_reset_n(cpu_reset),
	.cpu_nmi_n(0),
	.cpu_irq_n(0),
	.cpu_firq_n(0),
	.cpu_state_o(),
	.cpu_we_o(cpu_we_o),
	.cpu_oe_o(cpu_oe_o),
	.cpu_addr_o(cpu_addr_o),
	.cpu_data_i(cpu_data_i),
	.cpu_data_o(cpu_data_o)
	);


`ifdef SPARTAN3	
RAMB16_S9_S9 bios2k(.DOA(cpu_data_i), .DOPA(), .ADDRA(cpu_addr_o), .CLKA(clk32_i),
						  .DIA(cpu_data_o), .DIPA(), .ENA(cpu_oe_o | cpu_we_o), .SSRA(1), .WEA(cpu_we_o), 
						  .DOPB(), .DOB(), .ADDRB(0), .CLKB(clk32_i), .DIB(0), .DIPB(), .ENB(0), 
						  .SSRB(0), .WEB(0));
`else
RAMB4_S8 #(
      // The following INIT_xx declarations specify the initial contents of the RAM
      .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000001086),
      .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h00FF000000000000000000000000000000000000000000000000000000000000)
   ) RAMB4_S8_inst (
      .DO(cpu_data_i),     // 8-bit data output
      .ADDR(cpu_addr_o), // 9-bit address input
      .CLK(clk32_i),   // Clock input
      .DI(cpu_data_o),     // 8-bit data input
      .EN(cpu_oe_o | cpu_we_o),     // RAM enable input
      .RST(1'b0),   // Synchronous reset input
      .WE(cpu_we_o)      // RAM write enable input
   );
`endif
endmodule
