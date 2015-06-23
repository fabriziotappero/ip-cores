/*******************************************************************
* This file is owned and controlled by Xilinx and must be used     *
* solely for design, simulation, implementation and creation of    *
* design files limited to Xilinx devices or technologies. Use      *
* with non-Xilinx devices or technologies is expressly prohibited  *
* and immediately terminates your license.                         *
*                                                                  *
* Xilinx products are not intended for use in life support         *
* appliances, devices, or systems. Use in such applications are    *
* expressly prohibited.                                            *
*                                                                  *
* Copyright (C) 2001, Xilinx, Inc.  All Rights Reserved.           *
*******************************************************************/ 

// The synopsys directives "translate_off/translate_on" specified
// below are supported by XST, FPGA Express, Exemplar and Synplicity
// synthesis tools. Ensure they are correct for your synthesis tool(s).

// You must compile the wrapper file dma_fifo.v when simulating
// the core, dma_fifo. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "Coregen Users Guide".

module dma_fifo (
	clk,
	sinit,
	din,
	wr_en,
	rd_en,
	dout,
	full,
	empty);    // synthesis black_box

input clk;
input sinit;
input [7 : 0] din;
input wr_en;
input rd_en;
output [7 : 0] dout;
output full;
output empty;

// synopsys translate_off

	SYNC_FIFO_V2_0 #(
		1,	// c_dcount_width
		0,	// c_enable_rlocs
		0,	// c_has_dcount
		0,	// c_has_rd_ack
		0,	// c_has_rd_err
		0,	// c_has_wr_ack
		0,	// c_has_wr_err
		1,	// c_memory_type
		0,	// c_ports_differ
		1,	// c_rd_ack_low
		1,	// c_rd_err_low
		8,	// c_read_data_width
		512,	// c_read_depth
		8,	// c_write_data_width
		512,	// c_write_depth
		1,	// c_wr_ack_low
		1)	// c_wr_err_low
	inst (
		.CLK(clk),
		.SINIT(sinit),
		.DIN(din),
		.WR_EN(wr_en),
		.RD_EN(rd_en),
		.DOUT(dout),
		.FULL(full),
		.EMPTY(empty));


// synopsys translate_on

// FPGA Express black box declaration
// synopsys attribute fpga_dont_touch "true"
// synthesis attribute fpga_dont_touch of dma_fifo is "true"

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of dma_fifo is "black_box"

endmodule

