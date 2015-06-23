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
-- You must compile the wrapper file jpeg_dequant_multiplier.vhd when simulating
-- the core, jpeg_dequant_multiplier. When compiling the wrapper file, be sure to
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
ENTITY jpeg_dequant_multiplier IS
	port (
	a: IN std_logic_VECTOR(11 downto 0);
	b: IN std_logic_VECTOR(7 downto 0);
	o: OUT std_logic_VECTOR(19 downto 0));
END jpeg_dequant_multiplier;

ARCHITECTURE jpeg_dequant_multiplier_a OF jpeg_dequant_multiplier IS
-- synopsys translate_off
component wrapped_jpeg_dequant_multiplier
	port (
	a: IN std_logic_VECTOR(11 downto 0);
	b: IN std_logic_VECTOR(7 downto 0);
	o: OUT std_logic_VECTOR(19 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_jpeg_dequant_multiplier use entity XilinxCoreLib.mult_gen_v8_0(behavioral)
		generic map(
			c_a_type => 0,
			c_mem_type => 0,
			c_has_sclr => 0,
			c_has_q => 0,
			c_reg_a_b_inputs => 0,
			c_has_o => 1,
			c_family => "virtex2p",
			bram_addr_width => 0,
			c_v2_speed => 0,
			c_baat => 0,
			c_output_hold => 0,
			c_b_constant => 0,
			c_has_loadb => 0,
			c_has_b => 0,
			c_use_luts => 0,
			c_has_rdy => 0,
			c_has_nd => 0,
			c_pipeline => 0,
			c_has_a_signed => 0,
			c_b_type => 1,
			c_standalone => 0,
			c_sqm_type => 0,
			c_b_value => "1010",
			c_enable_rlocs => 0,
			c_mult_type => 6,
			c_has_aclr => 0,
			c_mem_init_prefix => "mgv8",
			c_has_load_done => 0,
			c_has_swapb => 0,
			c_out_width => 20,
			c_b_width => 8,
			c_a_width => 12,
			c_has_rfd => 0,
			c_sync_enable => 0,
			c_has_ce => 0,
			c_stack_adders => 0,
 -- manually added:
			c_elaboration_dir => "./",
			c_xdevicefamily => "virtex2p"
);
-- synopsys translate_on
BEGIN
-- synopsys translate_off
U0 : wrapped_jpeg_dequant_multiplier
		port map (
			a => a,
			b => b,
			o => o);
-- synopsys translate_on

END jpeg_dequant_multiplier_a;

