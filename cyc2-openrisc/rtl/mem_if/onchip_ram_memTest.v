//
// on-chip RAM initilization file.
//
// Author(s):
// - Steve Fielding sfielding@base2designs
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


// synopsys translate_off
`include "or1200_defines.v"
`include "timescale.v"
// synopsys translate_on

module onchip_ram_top (

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



onchip_ram u_onchip_ram (
	.wb_clk_i	( wb_clk_i ),
	.wb_rst_i	( wb_rst_i ),
	.wb_dat_i	( wb_dat_i ),
	.wb_dat_o	( wb_dat_o ),
	.wb_adr_i	( wb_adr_i ),
	.wb_sel_i	( wb_sel_i ),
	.wb_we_i	( wb_we_i  ),
	.wb_cyc_i	( wb_cyc_i ),
	.wb_stb_i	( wb_stb_i ),
	.wb_ack_o	( wb_ack_o ),
	.wb_err_o	( wb_err_o )
);

`ifdef OR1200_ALTERA_LPM
defparam
  // Initialize internal RAM with DRAM memory test application.
  // You can replace the file with your own application, or copy this file, rename, modify, 
  // and then replace onchip_ram_memTest.v in syn/cyc_or12_mini_top.v
  u_onchip_ram.altsyncram_component.init_file =  "../sw/memTest/memTest.intel.hex";
`endif 

endmodule
