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
--     (c) Copyright 1995-2009 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file spartan3adsp_dmem.vhd when simulating
-- the core, spartan3adsp_dmem. When compiling the wrapper file, be sure to
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
ENTITY spartan3adsp_dmem IS
	port (
	clka: IN std_logic;
	ena: IN std_logic;
	wea: IN std_logic_VECTOR(1 downto 0);
	addra: IN std_logic_VECTOR(9 downto 0);
	dina: IN std_logic_VECTOR(15 downto 0);
	douta: OUT std_logic_VECTOR(15 downto 0));
END spartan3adsp_dmem;

ARCHITECTURE spartan3adsp_dmem_a OF spartan3adsp_dmem IS
-- synthesis translate_off
component wrapped_spartan3adsp_dmem
	port (
	clka: IN std_logic;
	ena: IN std_logic;
	wea: IN std_logic_VECTOR(1 downto 0);
	addra: IN std_logic_VECTOR(9 downto 0);
	dina: IN std_logic_VECTOR(15 downto 0);
	douta: OUT std_logic_VECTOR(15 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_spartan3adsp_dmem use entity XilinxCoreLib.blk_mem_gen_v3_3(behavioral)
		generic map(
			c_has_regceb => 0,
			c_has_regcea => 0,
			c_mem_type => 0,
			c_rstram_b => 0,
			c_rstram_a => 0,
			c_has_injecterr => 0,
			c_rst_type => "SYNC",
			c_prim_type => 1,
			c_read_width_b => 16,
			c_initb_val => "0",
			c_family => "spartan3",
			c_read_width_a => 16,
			c_disable_warn_bhv_coll => 0,
			c_write_mode_b => "WRITE_FIRST",
			c_init_file_name => "no_coe_file_loaded",
			c_write_mode_a => "WRITE_FIRST",
			c_mux_pipeline_stages => 0,
			c_has_mem_output_regs_b => 0,
			c_has_mem_output_regs_a => 0,
			c_load_init_file => 0,
			c_xdevicefamily => "spartan3adsp",
			c_write_depth_b => 1024,
			c_write_depth_a => 1024,
			c_has_rstb => 0,
			c_has_rsta => 0,
			c_has_mux_output_regs_b => 0,
			c_inita_val => "0",
			c_has_mux_output_regs_a => 0,
			c_addra_width => 10,
			c_addrb_width => 10,
			c_default_data => "0",
			c_use_ecc => 0,
			c_algorithm => 1,
			c_disable_warn_bhv_range => 0,
			c_write_width_b => 16,
			c_write_width_a => 16,
			c_read_depth_b => 1024,
			c_read_depth_a => 1024,
			c_byte_size => 8,
			c_sim_collision_check => "ALL",
			c_common_clk => 0,
			c_wea_width => 2,
			c_has_enb => 0,
			c_web_width => 2,
			c_has_ena => 1,
			c_use_byte_web => 1,
			c_use_byte_wea => 1,
			c_rst_priority_b => "CE",
			c_rst_priority_a => "CE",
			c_use_default_data => 0);
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_spartan3adsp_dmem
		port map (
			clka => clka,
			ena => ena,
			wea => wea,
			addra => addra,
			dina => dina,
			douta => douta);
-- synthesis translate_on

END spartan3adsp_dmem_a;

