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
-- You must compile the wrapper file jpeg_qt_sr.vhd when simulating
-- the core, jpeg_qt_sr. When compiling the wrapper file, be sure to
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
ENTITY jpeg_qt_sr IS
	port (
	d: IN std_logic_VECTOR(7 downto 0);
	clk: IN std_logic;
	ce: IN std_logic;
	q: OUT std_logic_VECTOR(7 downto 0));
END jpeg_qt_sr;

ARCHITECTURE jpeg_qt_sr_a OF jpeg_qt_sr IS
-- synopsys translate_off
component wrapped_jpeg_qt_sr
	port (
	d: IN std_logic_VECTOR(7 downto 0);
	clk: IN std_logic;
	ce: IN std_logic;
	q: OUT std_logic_VECTOR(7 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_jpeg_qt_sr use entity XilinxCoreLib.c_shift_ram_v8_0(behavioral)
		generic map(
			c_has_aset => 0,
			c_read_mif => 0,
			c_has_a => 0,
			c_sync_priority => 1,
			c_opt_goal => 0,
			c_has_sclr => 0,
			c_width => 8,
			c_enable_rlocs => 0,
			c_default_data_radix => 1,
			c_generate_mif => 0,
			c_ainit_val => "0000000000000000",
			c_has_ce => 1,
			c_has_aclr => 0,
			c_mem_init_radix => 1,
			c_sync_enable => 0,
			c_depth => 64,
			c_has_ainit => 0,
			c_sinit_val => "0000000000000000",
			c_has_sset => 0,
			c_has_sinit => 0,
			c_mem_init_file => "no_coe_file_loaded",
			c_shift_type => 0,
			c_default_data => "00000000",
			c_reg_last_bit => 0,
			c_elaboration_dir => "./",
			c_addr_width => 4);
-- synopsys translate_on
BEGIN
-- synopsys translate_off
U0 : wrapped_jpeg_qt_sr
		port map (
			d => d,
			clk => clk,
			ce => ce,
			q => q);
-- synopsys translate_on

END jpeg_qt_sr_a;

