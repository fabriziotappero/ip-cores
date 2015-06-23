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
--     (c) Copyright 1995-2007 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file pmem.vhd when simulating
-- the core, pmem. When compiling the wrapper file, be sure to
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
ENTITY pmem IS
	port (
	addra: IN std_logic_VECTOR(9 downto 0);
	addrb: IN std_logic_VECTOR(9 downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(15 downto 0);
	douta: OUT std_logic_VECTOR(15 downto 0);
	web: IN std_logic);
END pmem;

ARCHITECTURE pmem_a OF pmem IS
-- synthesis translate_off
component wrapped_pmem
	port (
	addra: IN std_logic_VECTOR(9 downto 0);
	addrb: IN std_logic_VECTOR(9 downto 0);
	clka: IN std_logic;
	clkb: IN std_logic;
	dinb: IN std_logic_VECTOR(15 downto 0);
	douta: OUT std_logic_VECTOR(15 downto 0);
	web: IN std_logic);
end component;

-- Configuration specification 
	for all : wrapped_pmem use entity XilinxCoreLib.blkmemdp_v6_3(behavioral)
		generic map(
			c_reg_inputsb => 0,
			c_reg_inputsa => 0,
			c_has_ndb => 0,
			c_has_nda => 0,
			c_ytop_addr => "1024",
			c_has_rfdb => 0,
			c_has_rfda => 0,
			c_ywea_is_high => 1,
			c_yena_is_high => 1,
			c_yclka_is_rising => 1,
			c_yhierarchy => "hierarchy1",
			c_ysinita_is_high => 1,
			c_ybottom_addr => "0",
			c_width_b => 16,
			c_width_a => 16,
			c_sinita_value => "0",
			c_sinitb_value => "0",
			c_limit_data_pitch => 18,
			c_write_modeb => 0,
			c_write_modea => 0,
			c_has_rdyb => 0,
			c_yuse_single_primitive => 0,
			c_has_rdya => 0,
			c_addra_width => 10,
			c_addrb_width => 10,
			c_has_limit_data_pitch => 0,
			c_default_data => "0",
			c_pipe_stages_b => 0,
			c_yweb_is_high => 1,
			c_yenb_is_high => 1,
			c_pipe_stages_a => 0,
			c_yclkb_is_rising => 1,
			c_yydisable_warnings => 1,
			c_enable_rlocs => 0,
			c_ysinitb_is_high => 1,
			c_has_web => 1,
			c_has_default_data => 0,
			c_has_sinitb => 0,
			c_has_wea => 0,
			c_has_sinita => 0,
			c_has_dinb => 1,
			c_has_dina => 0,
			c_ymake_bmm => 0,
			c_sim_collision_check => "NONE",
			c_has_enb => 0,
			c_has_ena => 0,
			c_mem_init_file => "pmem.mif",
			c_depth_b => 1024,
			c_depth_a => 1024,
			c_has_doutb => 0,
			c_has_douta => 1,
			c_yprimitive_type => "16kx1");
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_pmem
		port map (
			addra => addra,
			addrb => addrb,
			clka => clka,
			clkb => clkb,
			dinb => dinb,
			douta => douta,
			web => web);
-- synthesis translate_on

END pmem_a;

