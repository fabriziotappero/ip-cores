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
-- You must compile the wrapper file dist_mem.vhd when simulating
-- the core, dist_mem. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
Library XilinxCoreLib;
-- synthesis translate_on
ENTITY dist_mem IS
	port (
	a: IN std_logic_VECTOR(4 downto 0);
	d: IN std_logic_VECTOR(31 downto 0);
	dpra: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	we: IN std_logic;
	spo: OUT std_logic_VECTOR(31 downto 0);
	dpo: OUT std_logic_VECTOR(31 downto 0));
END dist_mem;

ARCHITECTURE dist_mem_a OF dist_mem IS
-- synthesis translate_off
component wrapped_dist_mem
	port (
	a: IN std_logic_VECTOR(4 downto 0);
	d: IN std_logic_VECTOR(31 downto 0);
	dpra: IN std_logic_VECTOR(4 downto 0);
	clk: IN std_logic;
	we: IN std_logic;
	spo: OUT std_logic_VECTOR(31 downto 0);
	dpo: OUT std_logic_VECTOR(31 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_dist_mem use entity XilinxCoreLib.dist_mem_gen_v3_2(behavioral)
		generic map(
			c_has_clk => 1,
			c_has_qdpo_clk => 0,
			c_has_qdpo_ce => 0,
			c_has_d => 1,
			c_has_spo => 1,
			c_read_mif => 0,
			c_has_qspo => 0,
			c_width => 32,
			c_reg_a_d_inputs => 0,
			c_has_we => 1,
			c_pipeline_stages => 0,
			c_has_qdpo_rst => 0,
			c_reg_dpra_input => 0,
			c_qualify_we => 0,
			c_sync_enable => 1,
			c_depth => 32,
			c_has_qspo_srst => 0,
			c_has_qdpo_srst => 0,
			c_has_dpra => 1,
			c_qce_joined => 0,
			c_mem_type => 2,
			c_has_i_ce => 0,
			c_has_dpo => 1,
			c_mem_init_file => "no_coe_file_loaded",
			c_default_data => "0",
			c_has_spra => 0,
			c_has_qspo_ce => 0,
			c_addr_width => 5,
			c_has_qdpo => 0,
			c_has_qspo_rst => 0);
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_dist_mem
		port map (
			a => a,
			d => d,
			dpra => dpra,
			clk => clk,
			we => we,
			spo => spo,
			dpo => dpo);
-- synthesis translate_on

END dist_mem_a;

