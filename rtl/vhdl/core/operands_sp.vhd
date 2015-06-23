----------------------------------------------------------------------  
----  operands_sp                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    512 bit single port ram for the modulus                   ----
----    32 write for bus side and 512 bit read for multplier side ----
----                                                              ---- 
----  Dependencies: none                                          ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
----                                                              ---- 
---- This source file may be used and distributed without         ---- 
---- restriction provided that this copyright statement is not    ---- 
---- removed from the file and that any derivative work contains  ---- 
---- the original copyright notice and the associated disclaimer. ---- 
----                                                              ---- 
---- This source file is free software; you can redistribute it   ---- 
---- and/or modify it under the terms of the GNU Lesser General   ---- 
---- Public License as published by the Free Software Foundation; ---- 
---- either version 2.1 of the License, or (at your option) any   ---- 
---- later version.                                               ---- 
----                                                              ---- 
---- This source is distributed in the hope that it will be       ---- 
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ---- 
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ---- 
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------
----------------------------------------------------------------------
-- This file is owned and controlled by Xilinx and must be used     --
-- solely for design, simulation, implementation and creation of    --
-- design files limited to Xilinx devices or technologies. Use      --
-- with non-Xilinx devices or technologies is expressly prohibited  --
-- and immediately terminates your license.                         --
--                                                                  --
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"    --
-- SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR          --
-- XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION  --
-- AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION      --
-- OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS        --
-- IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,          --
-- AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE --
-- FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY         --
-- WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE          --
-- IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR   --
-- REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF  --
-- INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS  --
-- FOR A PARTICULAR PURPOSE.                                        --
--                                                                  --
-- Xilinx products are not intended for use in life support         --
-- appliances, devices, or systems. Use in such applications are    --
-- expressly prohibited.                                            --
--                                                                  --
-- (c) Copyright 1995-2009 Xilinx, Inc.                             --
-- All rights reserved.                                             --
----------------------------------------------------------------------
-- You must compile the wrapper file operand_dp.vhd when simulating
-- the core, operand_dp. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).


library ieee;
use ieee.std_logic_1164.all;
-- synthesis translate_off
library XilinxCoreLib;
-- synthesis translate_on


entity operands_sp is
  port (
    clka  : in std_logic;
    wea   : in std_logic_vector(0 downto 0);
    addra : in std_logic_vector(4 downto 0);
    dina  : in std_logic_vector(31 downto 0);
    douta : out std_logic_vector(511 downto 0)
  );
end operands_sp;


architecture operands_sp_a of operands_sp is
-- synthesis translate_off
  component wrapped_operands_sp
    port (
      clka  : in std_logic;
      wea   : in std_logic_vector(0 downto 0);
      addra : in std_logic_vector(4 downto 0);
      dina  : in std_logic_vector(31 downto 0);
      douta : out std_logic_vector(511 downto 0)
    );
  end component;

-- Configuration specification 
	for all : wrapped_operands_sp use entity XilinxCoreLib.blk_mem_gen_v3_3(behavioral)
		generic map(
			c_has_regceb => 0,
			c_has_regcea => 0,
			c_mem_type => 0,
			c_rstram_b => 0,
			c_rstram_a => 0,
			c_has_injecterr => 0,
			c_rst_type => "SYNC",
			c_prim_type => 1,
			c_read_width_b => 32,
			c_initb_val => "0",
			c_family => "virtex6",
			c_read_width_a => 512,
			c_disable_warn_bhv_coll => 0,
			c_write_mode_b => "WRITE_FIRST",
			c_init_file_name => "no_coe_file_loaded",
			c_write_mode_a => "WRITE_FIRST",
			c_mux_pipeline_stages => 0,
			c_has_mem_output_regs_b => 0,
			c_has_mem_output_regs_a => 0,
			c_load_init_file => 0,
			c_xdevicefamily => "virtex6",
			c_write_depth_b => 32,
			c_write_depth_a => 32,
			c_has_rstb => 0,
			c_has_rsta => 0,
			c_has_mux_output_regs_b => 0,
			c_inita_val => "0",
			c_has_mux_output_regs_a => 0,
			c_addra_width => 5,
			c_addrb_width => 5,
			c_default_data => "0",
			c_use_ecc => 0,
			c_algorithm => 1,
			c_disable_warn_bhv_range => 0,
			c_write_width_b => 32,
			c_write_width_a => 32,
			c_read_depth_b => 32,
			c_read_depth_a => 2,
			c_byte_size => 9,
			c_sim_collision_check => "ALL",
			c_common_clk => 0,
			c_wea_width => 1,
			c_has_enb => 0,
			c_web_width => 1,
			c_has_ena => 0,
			c_use_byte_web => 0,
			c_use_byte_wea => 0,
			c_rst_priority_b => "CE",
			c_rst_priority_a => "CE",
			c_use_default_data => 0
		);
-- synthesis translate_on

begin
-- synthesis translate_off
  u0 : wrapped_operands_sp
  port map (
    clka  => clka,
    wea   => wea,
    addra => addra,
    dina  => dina,
    douta => douta
  );
-- synthesis translate_on

end operands_sp_a;
