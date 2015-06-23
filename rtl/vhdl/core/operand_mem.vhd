----------------------------------------------------------------------  
----  operand_mem                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    RAM memory and logic to the store operands and the        ----
----    modulus for the montgomery multiplier, the user has a     ----
----    choise between 3 memory styles, more detail in the        ----
----    documentation                                             ----
----                                                              ----            
----  Dependencies:                                               ----
----    - operand_ram                                             ----
----    - modulus_ram                                             ----
----    - operand_ram_gen                                         ----
----    - modulus_ram_gen                                         ----
----    - operand_ram_asym                                        ----
----    - modulus_ram_asym                                        ----
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library mod_sim_exp;
use mod_sim_exp.mod_sim_exp_pkg.all;
use mod_sim_exp.std_functions.all;

-- address structure:
-- bit: 8   ->  '1': modulus
--              '0': operands
-- bits: 7-6 -> operand_in_sel in case of highest bit = '0'
--              modulus_in_sel in case of highest bit = '1'
-- bits: (log2(width/32)-1)-0 -> modulus_addr / operand_addr resp.
-- 
entity operand_mem is
  generic(
    width     : integer := 1536; -- width of the operands
    nr_op     : integer := 4; -- nr of operand storages, has to be greater than nr_m
    nr_m      : integer := 2; -- nr of modulus storages
    mem_style : string  := "asym"; -- xil_prim, generic, asym are valid options
    device    : string  := "xilinx"   -- xilinx, altera are valid options
  );
  port(
    -- data interface (plb side)
    bus_clk      : in std_logic;
    data_in      : in std_logic_vector(31 downto 0);
    data_out     : out std_logic_vector(31 downto 0);
    rw_address   : in std_logic_vector(8 downto 0);
    write_enable : in std_logic;
    -- operand interface (multiplier side)
    core_clk  : in std_logic;
    op_sel    : in std_logic_vector(log2(nr_op)-1 downto 0);
    xy_out    : out std_logic_vector((width-1) downto 0);
    m         : out std_logic_vector((width-1) downto 0);
    result_in : in std_logic_vector((width-1) downto 0);
    -- control signals
    load_result    : in std_logic;
    result_dest_op : in std_logic_vector(log2(nr_op)-1 downto 0);
    collision      : out std_logic;
    modulus_sel    : in std_logic_vector(log2(nr_m)-1 downto 0)
  );
end operand_mem;

architecture structural of operand_mem is
  -- constants
  constant wordaddr_aw : integer := log2(width/32);
  constant opaddr_aw   : integer := log2(nr_op);
  constant maddr_aw    : integer := log2(nr_m);
  constant total_aw    : integer := 1+opaddr_aw+wordaddr_aw;

  -- internal signals
  signal xy_data_i        : std_logic_vector(31 downto 0);
  signal xy_addr_i        : std_logic_vector(wordaddr_aw-1 downto 0);
  signal operand_in_sel_i : std_logic_vector(opaddr_aw-1 downto 0);
  signal modulus_in_sel_i : std_logic_vector(maddr_aw-1 downto 0);

  signal load_op : std_logic;

  signal m_addr_i : std_logic_vector(wordaddr_aw-1 downto 0);
  signal load_m   : std_logic;
  signal m_data_i : std_logic_vector(31 downto 0);

begin

	-- map inputs
	xy_addr_i <= rw_address(wordaddr_aw-1 downto 0);
	m_addr_i <= rw_address(wordaddr_aw-1 downto 0);
	operand_in_sel_i <= rw_address(7 downto 6);
	modulus_in_sel_i <= rw_address(6 downto 6);
	xy_data_i <= data_in;
	m_data_i <= data_in;
  
  -- select right memory with highest address bit
	load_op <= write_enable when (rw_address(8) = '0') else '0';
  load_m <= write_enable when (rw_address(8) = '1') else '0';

  xil_prim_RAM : if mem_style="xil_prim" generate
    -- xy operand storage
    xy_ram_xil : operand_ram 
    port map(
      bus_clk         => bus_clk,
      core_clk        => core_clk,
      collision       => collision,
      operand_addr    => xy_addr_i,
      operand_in      => xy_data_i,
      operand_in_sel  => operand_in_sel_i,
      result_out      => data_out,
      write_operand   => load_op,
      operand_out     => xy_out,
      operand_out_sel => op_sel,
      result_dest_op  => result_dest_op,
      write_result    => load_result,
      result_in       => result_in
    );
  
    -- modulus storage
    m_ram_xil : modulus_ram
    port map(
      clk           => bus_clk,
      modulus_addr  => m_addr_i,
      write_modulus => load_m,
      modulus_in    => m_data_i,
      modulus_out   => m
    );
  end generate;

  gen_RAM : if mem_style="generic" generate
    -- xy operand storage
    xy_ram_gen : operand_ram_gen
    generic map(
      width => width,
      depth => nr_op
    ) 
    port map(
      collision       => collision,
      bus_clk         => bus_clk,
      operand_addr    => xy_addr_i,
      operand_in      => xy_data_i,
      operand_in_sel  => operand_in_sel_i,
      result_out      => data_out,
      write_operand   => load_op,
      operand_out     => xy_out,
      operand_out_sel => op_sel,
      result_dest_op  => result_dest_op,
      core_clk        => core_clk,
      write_result    => load_result,
      result_in       => result_in
    );
  
    -- modulus storage
    m_ram_gen : modulus_ram_gen
    generic map(
      width => width,
      depth => nr_m
    )
    port map(
      bus_clk         => bus_clk,
      modulus_in_sel => modulus_in_sel_i,
      modulus_addr   => m_addr_i,
      write_modulus  => load_m,
      modulus_in     => m_data_i,
      core_clk       => core_clk,
      modulus_out    => m,
      modulus_sel    => modulus_sel
    );
  end generate;

  asym_RAM : if mem_style="asym" generate
    -- xy operand storage
    xy_ram_asym : operand_ram_asym
    generic map(
      width => width,
      depth => nr_op,
      device => device
    ) 
    port map(
      collision       => collision,
      bus_clk         => bus_clk,
      operand_addr    => xy_addr_i,
      operand_in      => xy_data_i,
      operand_in_sel  => operand_in_sel_i,
      result_out      => data_out,
      write_operand   => load_op,
      operand_out     => xy_out,
      operand_out_sel => op_sel,
      result_dest_op  => result_dest_op,
      core_clk        => core_clk,
      write_result    => load_result,
      result_in       => result_in
    );
  
    -- modulus storage
    m_ram_asym : modulus_ram_asym
    generic map(
      width => width,
      depth => nr_m,
      device => device
    )
    port map(
      bus_clk        => bus_clk,
      modulus_in_sel => modulus_in_sel_i,
      modulus_addr   => m_addr_i,
      write_modulus  => load_m,
      modulus_in     => m_data_i,
      core_clk       => core_clk,
      modulus_out    => m,
      modulus_sel    => modulus_sel
    );
  end generate;
  
end structural;
