//
// Spartan-3E/Cyclone2 on-chip RAM interface.
//
// Author(s):
// - Serge Vakulenko, vak@cronyx.ru
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//

//----------------------
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.3  2006/12/22 17:16:26  vak
// Added comments and copyrights.
//
// Revision 1.2  2006/12/22 11:07:34  vak
// Amount of on-chip RAM increased to 16 kbytes.
// The generated bit file is successfully downloaded to the target board.
// Debug interface is functioning (jp1) via Xilinx parallel cable III.
// Hello-uart is running fine.
//
// Revision 1.1  2006/12/22 08:34:00  vak
// The design is successfully compiled using on-chip RAM.
//

// synopsys translate_off
`include "or1200_defines.v"
`include "timescale.v"
// synopsys translate_on

module onchip_ram (

	//
	// I/O Ports
	//
	input		wb_clk_i,
	input		wb_rst_i,

	//
	// WB slave i/f
	//
	input	[31:0]	wb_dat_i,
	output	[31:0]	wb_dat_o,
	input	[31:0]	wb_adr_i,
	input	[3:0]	wb_sel_i,
	input		wb_we_i,
	input		wb_cyc_i,
	input		wb_stb_i,
	output		wb_ack_o,
	output		wb_err_o
);

//
// Paraneters
//
parameter		AW = 11;	// RAM size = 2 kwords (8 kbytes)

//
// Internal wires and regs
//
wire			we;
wire	[3:0]		be_i;
reg			ack_we;
reg			ack_re;

//
// Aliases and simple assignments
//
assign wb_ack_o = ack_re | ack_we;

assign wb_err_o = wb_cyc_i & wb_stb_i & (| wb_adr_i[23:AW+2]);
	// If Access to > (8-bit leading prefix ignored)

assign we = wb_cyc_i & wb_stb_i & wb_we_i & (| wb_sel_i[3:0]);

assign be_i = (wb_cyc_i & wb_stb_i) * wb_sel_i;

//
// Write acknowledge
//
always @ (negedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_we <= 1'b0;
	else
	if (wb_cyc_i & wb_stb_i & wb_we_i & ~ack_we)
		ack_we <= #1 1'b1;
	else
		ack_we <= #1 1'b0;
end

//
// Read acknowledge
//
always @ (posedge wb_clk_i or posedge wb_rst_i)
begin
	if (wb_rst_i)
		ack_re <= 1'b0;
	else
	if (wb_cyc_i & wb_stb_i & ~wb_err_o & ~wb_we_i & ~ack_re)
		ack_re <= #1 1'b1;
	else
		ack_re <= #1 1'b0;
end

`ifdef OR1200_XILINX_RAMB16
//
// Generate 8 blocks of standard Xilinx library component:
// 16K-Bit Data and 2K-Bit Parity Single Port Block RAM
//
RAMB16_S4 block_ram_00 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [3 : 0]),
	.DO (wb_dat_o [3 : 0]),
	.EN (be_i [0]),
	.WE (we),
	.SSR (0));
RAMB16_S4 block_ram_01 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [7 : 4]),
	.DO (wb_dat_o [7 : 4]),
	.EN (be_i [0]),
	.WE (we),
	.SSR (0));

RAMB16_S4 block_ram_10 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [11 : 8]),
	.DO (wb_dat_o [11 : 8]),
	.EN (be_i [1]),
	.WE (we),
	.SSR (0));
RAMB16_S4 block_ram_11 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [15 : 12]),
	.DO (wb_dat_o [15 : 12]),
	.EN (be_i [1]),
	.WE (we),
	.SSR (0));

RAMB16_S4 block_ram_20 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [19 : 16]),
	.DO (wb_dat_o [19 : 16]),
	.EN (be_i [2]),
	.WE (we),
	.SSR (0));
RAMB16_S4 block_ram_21 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [23 : 20]),
	.DO (wb_dat_o [23 : 20]),
	.EN (be_i [2]),
	.WE (we),
	.SSR (0));

RAMB16_S4 block_ram_30 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [27 : 24]),
	.DO (wb_dat_o [27 : 24]),
	.EN (be_i [3]),
	.WE (we),
	.SSR (0));
RAMB16_S4 block_ram_31 (
	.ADDR (wb_adr_i [AW+1 : 2]),
	.CLK (wb_clk_i),
	.DI (wb_dat_i [31 : 28]),
	.DO (wb_dat_o [31 : 28]),
	.EN (be_i [3]),
	.WE (we),
	.SSR (0));

`else //OR1200_XILINX_RAMB16
`ifdef OR1200_ALTERA_LPM

altsyncram altsyncram_component (
  .wren_a (we),
  .clock0 (wb_clk_i),
  .byteena_a (be_i),
  .address_a (wb_adr_i[AW+1:2]),
  .data_a (wb_dat_i),
  .q_a (wb_dat_o));
defparam
  altsyncram_component.intended_device_family = "Cyclone",
  altsyncram_component.width_a = 32,
  altsyncram_component.widthad_a = AW,
  altsyncram_component.numwords_a = 2048,
  altsyncram_component.operation_mode = "SINGLE_PORT",
  altsyncram_component.outdata_reg_a = "UNREGISTERED",
  altsyncram_component.indata_aclr_a = "NONE",
  altsyncram_component.wrcontrol_aclr_a = "NONE",
  altsyncram_component.address_aclr_a = "NONE",
  altsyncram_component.outdata_aclr_a = "NONE",
  altsyncram_component.width_byteena_a = 4,
  altsyncram_component.byte_size = 8,
  altsyncram_component.byteena_aclr_a = "NONE",
  altsyncram_component.ram_block_type = "AUTO",
  altsyncram_component.lpm_type = "altsyncram";


`endif //OR1200_XILINX_RAMB16
`endif //OR1200_ALTERA_LPM

endmodule
