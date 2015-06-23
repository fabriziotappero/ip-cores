--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2006 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file jpeg_idct_core_12.vhd when simulating
-- the core, jpeg_idct_core_12. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synopsys directives "translate_off/translate_on" specified
-- below are supported by XST, FPGA Compiler II, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synopsys translate_off
Library XilinxCoreLib;
-- synopsys translate_on
ENTITY jpeg_idct_core_12 IS
	port (
	ND: IN std_logic;
	RDY: OUT std_logic;
	RFD: OUT std_logic;
	CLK: IN std_logic;
	RST: IN std_logic;
	DIN: IN std_logic_VECTOR(11 downto 0);
	DOUT: OUT std_logic_VECTOR(8 downto 0));
END jpeg_idct_core_12;

ARCHITECTURE jpeg_idct_core_12_a OF jpeg_idct_core_12 IS
-- synopsys translate_off
component wrapped_jpeg_idct_core_12
	port (
	ND: IN std_logic;
	RDY: OUT std_logic;
	RFD: OUT std_logic;
	CLK: IN std_logic;
	RST: IN std_logic;
	DIN: IN std_logic_VECTOR(11 downto 0);
	DOUT: OUT std_logic_VECTOR(8 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_jpeg_idct_core_12 use entity XilinxCoreLib.C_DA_2D_DCT_V2_0(behavioral)
		generic map(
			c_clks_per_sample => 12,
			c_result_width => 9,
			c_internal_width => 15,
			c_data_type => 0,
			c_precision_control => 2,
			c_data_width => 12,
			c_operation => 2,
			c_enable_rlocs => 0,
			c_latency => 99,
			c_enable_symmetry => 0,
			c_coeff_width => 15,
			c_shape => 0,
			c_mem_type => 0,
			c_col_latency => 15,
			c_row_latency => 18,
			c_has_reset => 1);
-- synopsys translate_on
BEGIN
-- synopsys translate_off
U0 : wrapped_jpeg_idct_core_12
		port map (
			ND => ND,
			RDY => RDY,
			RFD => RFD,
			CLK => CLK,
			RST => RST,
			DIN => DIN,
			DOUT => DOUT);
-- synopsys translate_on

END jpeg_idct_core_12_a;

