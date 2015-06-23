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

// You must compile the wrapper file rf_dist_cm4.v when simulating
// the core, rf_dist_cm4. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

`include "or1200_defines.v"

module rf_dist_cm4(
	a,
	d,
	dpra,
	clk,
	we,
	spo,
	dpo);


input [6 : 0] a;
input [31 : 0] d;
input [6 : 0] dpra;
input clk;
input we;
output [31 : 0] spo;
output [31 : 0] dpo;

// synthesis translate_off

      DIST_MEM_GEN_V4_1 #(
		.C_ADDR_WIDTH(7),
		.C_DEFAULT_DATA("0"),
		.C_DEPTH(128),
		.C_HAS_CLK(1),
		.C_HAS_D(1),
		.C_HAS_DPO(1),
		.C_HAS_DPRA(1),
		.C_HAS_I_CE(0),
		.C_HAS_QDPO(0),
		.C_HAS_QDPO_CE(0),
		.C_HAS_QDPO_CLK(0),
		.C_HAS_QDPO_RST(0),
		.C_HAS_QDPO_SRST(0),
		.C_HAS_QSPO(0),
		.C_HAS_QSPO_CE(0),
		.C_HAS_QSPO_RST(0),
		.C_HAS_QSPO_SRST(0),
		.C_HAS_SPO(1),
		.C_HAS_SPRA(0),
		.C_HAS_WE(1),
		.C_MEM_INIT_FILE("rf_dist_cm4.mif"),
		.C_MEM_TYPE(2),
		.C_PARSER_TYPE(1),
		.C_PIPELINE_STAGES(0),
		.C_QCE_JOINED(0),
		.C_QUALIFY_WE(0),
		.C_READ_MIF(1),
		.C_REG_A_D_INPUTS(0),
		.C_REG_DPRA_INPUT(0),
		.C_SYNC_ENABLE(1),
		.C_WIDTH(32))
	inst (
		.A(a),
		.D(d),
		.DPRA(dpra),
		.CLK(clk),
		.WE(we),
		.SPO(spo),
		.DPO(dpo),
		.SPRA(),
		.I_CE(),
		.QSPO_CE(),
		.QDPO_CE(),
		.QDPO_CLK(),
		.QSPO_RST(),
		.QDPO_RST(),
		.QSPO_SRST(),
		.QDPO_SRST(),
		.QSPO(),
		.QDPO());


// synthesis translate_on


endmodule

