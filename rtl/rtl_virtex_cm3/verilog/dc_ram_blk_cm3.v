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

// You must compile the wrapper file dc_ram_blk_cm3.v when simulating
// the core, dc_ram_blk_cm3. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

`include "or1200_defines.v"

module dc_ram_blk_cm3(
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
input [3 : 0] wea;
input [12 : 0] addra;
input [31 : 0] dina;
input clkb;
input [12 : 0] addrb;
output [31 : 0] doutb;

`ifdef BLK_MEM_GEN

// synthesis translate_off

      BLK_MEM_GEN_V3_1 #(
		.C_ADDRA_WIDTH(13),
		.C_ADDRB_WIDTH(13),
		.C_ALGORITHM(1),
		.C_BYTE_SIZE(8),
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
		.C_READ_DEPTH_A(6144),
		.C_READ_DEPTH_B(6144),
		.C_READ_WIDTH_A(32),
		.C_READ_WIDTH_B(32),
		.C_RSTRAM_A(0),
		.C_RSTRAM_B(0),
		.C_RST_PRIORITY_A("CE"),
		.C_RST_PRIORITY_B("CE"),
		.C_RST_TYPE("SYNC"),
		.C_SIM_COLLISION_CHECK("ALL"),
		.C_USE_BYTE_WEA(1),
		.C_USE_BYTE_WEB(1),
		.C_USE_DEFAULT_DATA(0),
		.C_USE_ECC(0),
		.C_WEA_WIDTH(4),
		.C_WEB_WIDTH(4),
		.C_WRITE_DEPTH_A(6144),
		.C_WRITE_DEPTH_B(6144),
		.C_WRITE_MODE_A("READ_FIRST"),
		.C_WRITE_MODE_B("READ_FIRST"),
		.C_WRITE_WIDTH_A(32),
		.C_WRITE_WIDTH_B(32),
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

//
// Generic RAM's registers and wires
//
reg     [31:0]        mem [(1<<13)-1:0];              // RAM content

reg	[12:0]	addrb_reg;		// RAM address register


always @(posedge clkb)
	addrb_reg <= #1 addrb;
                                                                                                                                                                                                    
//
// Data output drivers
//
assign doutb = mem[addrb_reg];
                                                                                                                                                                                                     
                                                                                                                                                                                                 

always @(posedge clka)
	begin
        if (ena && wea[0])
                mem[addra][7:0] <= #1 dina[7:0];
        if (ena && wea[1])
                mem[addra][15:8] <= #1 dina[15:8];
        if (ena && wea[2])
                mem[addra][23:16] <= #1 dina[23:16];
       if (ena && wea[3])
                mem[addra][31:24] <= #1 dina[31:24];
	end

`endif

endmodule

