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
*     (c) Copyright 1995-2004 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// The synopsys directives "translate_off/translate_on" specified below are
// supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity synthesis
// tools. Ensure they are correct for your synthesis tool(s).

// You must compile the wrapper file ram32x32.v when simulating
// the core, ram32x32. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Guide".

module ram32x32 (
	addra,
	addrb,
	clka,
	clkb,
	dina,
	dinb,
	douta,
	doutb,
	wea,
	web);    // synthesis black_box

input [4 : 0] addra;
input [4 : 0] addrb;
input clka;
input clkb;
input [31 : 0] dina;
input [31 : 0] dinb;
output [31 : 0] douta;
output [31 : 0] doutb;
input wea;
input web;

// synopsys translate_off

	BLKMEMDP_V6_1 #(
		5,	// c_addra_width
		5,	// c_addrb_width
		"0",	// c_default_data
		32,	// c_depth_a
		32,	// c_depth_b
		0,	// c_enable_rlocs
		1,	// c_has_default_data
		1,	// c_has_dina
		1,	// c_has_dinb
		1,	// c_has_douta
		1,	// c_has_doutb
		0,	// c_has_ena
		0,	// c_has_enb
		0,	// c_has_limit_data_pitch
		0,	// c_has_nda
		0,	// c_has_ndb
		0,	// c_has_rdya
		0,	// c_has_rdyb
		0,	// c_has_rfda
		0,	// c_has_rfdb
		0,	// c_has_sinita
		0,	// c_has_sinitb
		1,	// c_has_wea
		1,	// c_has_web
		18,	// c_limit_data_pitch
		"mif_file_16_1",	// c_mem_init_file
		0,	// c_pipe_stages_a
		0,	// c_pipe_stages_b
		0,	// c_reg_inputsa
		0,	// c_reg_inputsb
		"0",	// c_sinita_value
		"0",	// c_sinitb_value
		32,	// c_width_a
		32,	// c_width_b
		0,	// c_write_modea
		0,	// c_write_modeb
		"0",	// c_ybottom_addr
		1,	// c_yclka_is_rising
		1,	// c_yclkb_is_rising
		1,	// c_yena_is_high
		1,	// c_yenb_is_high
		"hierarchy1",	// c_yhierarchy
		0,	// c_ymake_bmm
		"16kx1",	// c_yprimitive_type
		1,	// c_ysinita_is_high
		1,	// c_ysinitb_is_high
		"1024",	// c_ytop_addr
		0,	// c_yuse_single_primitive
		1,	// c_ywea_is_high
		1,	// c_yweb_is_high
		1)	// c_yydisable_warnings
	inst (
		.ADDRA(addra),
		.ADDRB(addrb),
		.CLKA(clka),
		.CLKB(clkb),
		.DINA(dina),
		.DINB(dinb),
		.DOUTA(douta),
		.DOUTB(doutb),
		.WEA(wea),
		.WEB(web),
		.ENA(),
		.ENB(),
		.NDA(),
		.NDB(),
		.RFDA(),
		.RFDB(),
		.RDYA(),
		.RDYB(),
		.SINITA(),
		.SINITB());


// synopsys translate_on

// FPGA Express black box declaration
// synopsys attribute fpga_dont_touch "true"
// synthesis attribute fpga_dont_touch of ram32x32 is "true"

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of ram32x32 is "black_box"

endmodule

