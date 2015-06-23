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

// You must compile the wrapper file itlb_tr_blk_cm2.v when simulating
// the core, itlb_tr_blk_cm2. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

`include "or1200_defines.v"

module itlb_tr_blk_cm2(
	clka,
	ena,
	wea,
	addra,
	dina,
	clkb,
	addrb,
	doutb);


input clka;
input ena;
input [0 : 0] wea;
input [6 : 0] addra;
input [21 : 0] dina;
input clkb;
input [6 : 0] addrb;
output [21 : 0] doutb;

`ifdef BLK_MEM_GEN

// synthesis translate_off

      BLK_MEM_GEN_V3_1 #(
		.C_ADDRA_WIDTH(7),
		.C_ADDRB_WIDTH(7),
		.C_ALGORITHM(1),
		.C_BYTE_SIZE(9),
		.C_COMMON_CLK(0),
		.C_DEFAULT_DATA("0"),
		.C_DISABLE_WARN_BHV_COLL(0),
		.C_DISABLE_WARN_BHV_RANGE(0),
		.C_FAMILY("virtex5"),
		.C_HAS_ENA(1),
		.C_HAS_ENB(0),
		.C_HAS_INJECTERR(0),
		.C_HAS_MEM_OUTPUT_REGS_A(0),
		.C_HAS_MEM_OUTPUT_REGS_B(0),
		.C_HAS_MUX_OUTPUT_REGS_A(0),
		.C_HAS_MUX_OUTPUT_REGS_B(0),
		.C_HAS_REGCEA(0),
		.C_HAS_REGCEB(0),
		.C_HAS_RSTA(0),
		.C_HAS_RSTB(0),
		.C_INITA_VAL("0"),
		.C_INITB_VAL("0"),
		.C_INIT_FILE_NAME("no_coe_file_loaded"),
		.C_LOAD_INIT_FILE(0),
		.C_MEM_TYPE(1),
		.C_MUX_PIPELINE_STAGES(0),
		.C_PRIM_TYPE(1),
		.C_READ_DEPTH_A(128),
		.C_READ_DEPTH_B(128),
		.C_READ_WIDTH_A(22),
		.C_READ_WIDTH_B(22),
		.C_RSTRAM_A(0),
		.C_RSTRAM_B(0),
		.C_RST_PRIORITY_A("CE"),
		.C_RST_PRIORITY_B("CE"),
		.C_RST_TYPE("SYNC"),
		.C_SIM_COLLISION_CHECK("ALL"),
		.C_USE_BYTE_WEA(0),
		.C_USE_BYTE_WEB(0),
		.C_USE_DEFAULT_DATA(0),
		.C_USE_ECC(0),
		.C_WEA_WIDTH(1),
		.C_WEB_WIDTH(1),
		.C_WRITE_DEPTH_A(128),
		.C_WRITE_DEPTH_B(128),
		.C_WRITE_MODE_A("READ_FIRST"),
		.C_WRITE_MODE_B("READ_FIRST"),
		.C_WRITE_WIDTH_A(22),
		.C_WRITE_WIDTH_B(22),
		.C_XDEVICEFAMILY("virtex5"))
	inst (
		.CLKA(clka),
		.ENA(ena),
		.WEA(wea),
		.ADDRA(addra),
		.DINA(dina),
		.CLKB(clkb),
		.ADDRB(addrb),
		.DOUTB(doutb),
		.RSTA(),
		.REGCEA(),
		.DOUTA(),
		.RSTB(),
		.ENB(),
		.REGCEB(),
		.WEB(),
		.DINB(),
		.INJECTSBITERR(),
		.INJECTDBITERR(),
		.SBITERR(),
		.DBITERR(),
		.RDADDRECC());


// synthesis translate_on

`else

reg	[6:0]	addrb_reg;		// RAM address register

always @(posedge clka)
		addrb_reg <= #1 addrb;

//
// Generic RAM's registers and wires
//
reg	[21:0]	mem [(1<<7)-1:0];	// RAM content

//
// Data output drivers
//
assign doutb = mem[addrb_reg];

//
// RAM write
//
always @(posedge clka)
	if (ena && wea)
		mem[addra] <= #1 dina;

`endif


endmodule

