/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used             *
*     solely for design, simulation, implementation and creation of            *
*     design files limited to Xilinx devices or technologies. Use              *
*     with non-Xilinx devices or technologies is expressly prohibited          *
*     and immediately terminates your license.                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"            *
*     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                  *
*     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION          *
*     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION              *
*     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS                *
*     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                  *
*     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE         *
*     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY                 *
*     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                  *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS          *
*     FOR A PARTICULAR PURPOSE.                                                *
*                                                                              *
*     Xilinx products are not intended for use in life support                 *
*     appliances, devices, or systems. Use in such applications are            *
*     expressly prohibited.                                                    *
*                                                                              *
*     (c) Copyright 1995-2007 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// The synthesis directives "translate_off/translate_on" specified below are
// supported by Xilinx, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

// You must compile the wrapper file ram_8x512_hi.v when simulating
// the core, ram_8x512_hi. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

`timescale 1ns/1ps

module ram_8x512_hi(
	addr,
	clk,
	din,
	dout,
	en,
	we);


input [8 : 0] addr;
input clk;
input [7 : 0] din;
output [7 : 0] dout;
input en;
input we;

// synthesis translate_off

      BLKMEMSP_V6_2 #(
		.c_addr_width(9),
		.c_default_data("0"),
		.c_depth(512),
		.c_enable_rlocs(0),
		.c_has_default_data(1),
		.c_has_din(1),
		.c_has_en(1),
		.c_has_limit_data_pitch(0),
		.c_has_nd(0),
		.c_has_rdy(0),
		.c_has_rfd(0),
		.c_has_sinit(0),
		.c_has_we(1),
		.c_limit_data_pitch(18),
		.c_mem_init_file("mif_file_16_1"),
		.c_pipe_stages(0),
		.c_reg_inputs(0),
		.c_sinit_value("0"),
		.c_width(8),
		.c_write_mode(0),
		.c_ybottom_addr("0"),
		.c_yclk_is_rising(1),
		.c_yen_is_high(0),
		.c_yhierarchy("hierarchy1"),
		.c_ymake_bmm(0),
		.c_yprimitive_type("16kx1"),
		.c_ysinit_is_high(1),
		.c_ytop_addr("1024"),
		.c_yuse_single_primitive(0),
		.c_ywe_is_high(0),
		.c_yydisable_warnings(1))
	inst (
		.ADDR(addr),
		.CLK(clk),
		.DIN(din),
		.DOUT(dout),
		.EN(en),
		.WE(we),
		.ND(),
		.RFD(),
		.RDY(),
		.SINIT());


// synthesis translate_on

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of ram_8x512_hi is "black_box"

endmodule

