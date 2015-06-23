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
-- You must compile the wrapper file ctrl_multiplier_v1_0.vhd when simulating
-- the core, ctrl_multiplier_v1_0. When compiling the wrapper file, be sure to
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
ENTITY ctrl_multiplier_v1_0 IS
	port (
	clk: IN std_logic;
	a: IN std_logic_VECTOR(15 downto 0);
	b: IN std_logic_VECTOR(10 downto 0);
	p: OUT std_logic_VECTOR(26 downto 0));
END ctrl_multiplier_v1_0;

ARCHITECTURE ctrl_multiplier_v1_0_a OF ctrl_multiplier_v1_0 IS
-- synopsys translate_off
component wrapped_ctrl_multiplier_v1_0
	port (
	clk: IN std_logic;
	a: IN std_logic_VECTOR(15 downto 0);
	b: IN std_logic_VECTOR(10 downto 0);
	p: OUT std_logic_VECTOR(26 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_ctrl_multiplier_v1_0 use entity XilinxCoreLib.mult_gen_v9_0(behavioral)
		generic map(
			c_a_width => 16,
			c_b_type => 1,
			c_ce_overrides_sclr => 0,
			c_opt_goal => 1,
			c_has_sclr => 0,
			c_round_pt => 0,
			c_out_high => 26,
			c_mult_type => 0,
			c_ccm_imp => 0,
			c_has_load_done => 0,
			c_pipe_stages => 1,
			c_has_ce => 0,
			c_has_zero_detect => 0,
			c_round_output => 0,
			c_mem_init_prefix => "mgv9",
			c_xdevicefamily => "virtex4",
			c_a_type => 1,
			c_out_low => 0,
			c_b_width => 11,
			c_b_value => "10000001");
-- synopsys translate_on
BEGIN
-- synopsys translate_off
U0 : wrapped_ctrl_multiplier_v1_0
		port map (
			clk => clk,
			a => a,
			b => b,
			p => p);
-- synopsys translate_on

END ctrl_multiplier_v1_0_a;

