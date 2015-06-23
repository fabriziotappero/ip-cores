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

// You must compile the wrapper file instruction_cache_way0.v when simulating
// the core, instruction_cache_way0. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "Coregen Users Guide".

module instruction_cache_way0 (
	A,
	CLK,
	D,
	WE,
	SPO);    // synthesis black_box

input [4 : 0] A;
input CLK;
input [52 : 0] D;
input WE;
output [52 : 0] SPO;

// synopsys translate_off

	C_DIST_MEM_V4_1 #(
		5,	// c_addr_width
		"0",	// c_default_data
		1,	// c_default_data_radix
		32,	// c_depth
		0,	// c_family
		1,	// c_generate_mif
		1,	// c_has_clk
		1,	// c_has_d
		0,	// c_has_dpo
		0,	// c_has_dpra
		0,	// c_has_i_ce
		0,	// c_has_qdpo
		0,	// c_has_qdpo_ce
		0,	// c_has_qdpo_clk
		0,	// c_has_qdpo_rst
		0,	// c_has_qdpo_srst
		0,	// c_has_qspo
		0,	// c_has_qspo_ce
		0,	// c_has_qspo_rst
		0,	// c_has_qspo_srst
		0,	// c_has_rd_en
		1,	// c_has_spo
		0,	// c_has_spra
		1,	// c_has_we
		0,	// c_latency
		"instruction_cache_way0.mif",	// c_mem_init_file
		1,	// c_mem_type
		0,	// c_mux_type
		0,	// c_qce_joined
		0,	// c_qualify_we
		0,	// c_read_mif
		0,	// c_reg_a_d_inputs
		0,	// c_reg_dpra_input
		0,	// c_sync_enable
		53)	// c_width
	inst (
		.A(A),
		.CLK(CLK),
		.D(D),
		.WE(WE),
		.SPO(SPO));


// synopsys translate_on

// FPGA Express black box declaration
// synopsys attribute fpga_dont_touch "true"
// synthesis attribute fpga_dont_touch of instruction_cache_way0 is "true"

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of instruction_cache_way0 is "black_box"

endmodule

