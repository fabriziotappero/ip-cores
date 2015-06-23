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
*     (c) Copyright 1995-2009 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// The synthesis directives "translate_off/translate_on" specified below are
// supported by Xilinx, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

// You must compile the wrapper file itlb_tr_blk.v when simulating
// the core, itlb_tr_blk. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

`timescale 1ns/1ps

module itlb_tr_sub_cm3(
		clk_i_cml_1,
		clk_i_cml_2,
		cmls,
		
	clka,
	ena,
	wea,
	addra,
	dina,
	clkb,
	addrb,
	doutb);


input clk_i_cml_1;
input clk_i_cml_2;
input [1:0] cmls;




input clka;
input ena;
input [0 : 0] wea;
input [5 : 0] addra;
input [21 : 0] dina;
input clkb;
input [5 : 0] addrb;
output [21 : 0] doutb;

wire ena_wire;
wire [0 : 0] wea_wire;
wire [5 : 0] addra_wire;
wire [21 : 0] dina_wire;
wire [5 : 0] addrb_wire;

assign ena_wire = ena;
assign wea_wire = wea;
assign addra_wire = addra;
assign dina_wire = dina;
assign addrb_wire = addrb;

itlb_tr_blk_cm3 itlb_tr_blki(
	.clka(clka),
	.ena(ena_wire),
	.wea(wea_wire),
	.addra({cmls, addra_wire}),
	.dina(dina_wire),
	.clkb(clkb),
	.addrb({cmls, addrb_wire}),
	.doutb(doutb));

endmodule


