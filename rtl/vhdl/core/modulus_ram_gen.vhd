----------------------------------------------------------------------  
----  modulus_ram_gen                                             ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    BRAM memory and logic to store the modulus, due to the    ----
----    achitecture, a minimum depth of 2 is needed for this      ----
----    module to be inferred into blockram                       ----
----                                                              ---- 
----  Dependencies:                                               ----
----    - dpram_generic                                           ----
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

-- behavorial description of a RAM to hold the modulus, with 
-- adjustable width and depth(nr of moduluses)
entity modulus_ram_gen is
  generic(
    width : integer := 1536;  -- must be a multiple of 32
    depth : integer := 2      -- nr of moduluses
  );
  port(
      -- bus side
    bus_clk        : in std_logic;
    write_modulus  : in std_logic; -- write enable
    modulus_in_sel : in std_logic_vector(log2(depth)-1 downto 0); -- modulus operand to write to
    modulus_addr   : in std_logic_vector(log2((width)/32)-1 downto 0); -- modulus word(32-bit) address
    modulus_in     : in std_logic_vector(31 downto 0); -- modulus word data in
    modulus_sel    : in std_logic_vector(log2(depth)-1 downto 0); -- selects the modulus to use for multiplications
      -- multiplier side
    core_clk       : in std_logic;
    modulus_out    : out std_logic_vector(width-1 downto 0)
  );
end modulus_ram_gen;

architecture Behavioral of modulus_ram_gen is
  --- constants
  constant nrRAMs       : integer := width/32;
  constant RAMselect_aw : integer := log2(nrRAMs);
  constant RAMdepth_aw  : integer := log2(depth);
  constant total_aw     : integer := RAMdepth_aw+RAMselect_aw;

  -- interconnection signals
  signal modulus_rdaddr : std_logic_vector(RAMdepth_aw-1 downto 0);
  signal modulus_wraddr : std_logic_vector(total_aw-1 downto 0);
  signal we : std_logic_vector(nrRAMs-1 downto 0);
begin
	modulus_wraddr(RAMselect_aw-1 downto 0) <= modulus_addr;
	modulus_wraddr(total_aw-1 downto RAMselect_aw) <= modulus_in_sel;
	
	-- generate (width/32) blocks of 32-bit ram with a given depth
	-- these rams outputs are concatenated to a width-bit signal
  ramblocks : for i in 0 to nrRAMs-1 generate
    ramblock: dpram_generic
    generic map(
      depth => depth
    )
    port map(
      -- write port
      clkA   => bus_clk,
      waddrA => modulus_wraddr(total_aw-1 downto RAMselect_aw),
      weA    => we(i),
      dinA   => modulus_in,
      -- read port
      clkB   => core_clk,
      raddrB => modulus_rdaddr,
      doutB  => modulus_out(((i+1)*32)-1 downto i*32)
    );
    -- connect the w
    process (write_modulus, modulus_wraddr)
    begin
      if modulus_wraddr(RAMselect_aw-1 downto 0) = conv_std_logic_vector(i,RAMselect_aw) then
        we(i) <= write_modulus;
      else
        we(i) <= '0';
      end if;
    end process;
  end generate;
  modulus_rdaddr <= modulus_sel;
  
end Behavioral;
