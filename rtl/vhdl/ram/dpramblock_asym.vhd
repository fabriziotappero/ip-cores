----------------------------------------------------------------------  
----  dpramblock_asym                                             ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    structural description of an asymmetric dual port ram     ----
----    with one 32-bit write port and one (width)-bit read       ----
----    port.                                                     ----            
----                                                              ---- 
----  Dependencies: dpram_asym                                    ----
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library mod_sim_exp;
use mod_sim_exp.std_functions.all;
use mod_sim_exp.mod_sim_exp_pkg.all;

-- altera infers ramblocks from a depth of 9 (or 2 with any ram size recognition option on) 
--		and width 64,128,256,512,1024
-- xilinx infers ramblocks from a depth of 2 and width 32,64,128,256,512,1024
entity dpramblock_asym is
  generic (
    width  : integer := 256;  -- read width
    depth  : integer := 2;    -- nr of (width)-bit words
    device : string  := "xilinx"
  );
  port (
    -- write port A
    clkA   : in std_logic;
    waddrA : in std_logic_vector(log2((width*depth)/32)-1 downto 0);
    weA    : in std_logic;
    dinA   : in std_logic_vector(31 downto 0);
    -- read port B
    clkB   : in std_logic;
    raddrB : in std_logic_vector(log2(depth)-1 downto 0);
    doutB  : out std_logic_vector(width-1 downto 0)
  );
end dpramblock_asym;

architecture structural of dpramblock_asym is
  -- constants
  constant nrRAMs       : integer := width/32;
  constant RAMwrwidth   : integer := 32/nrRAMs;
  
  -- interconnection signals
  type word_array is array (nrRAMs-1 downto 0) of std_logic_vector(31 downto 0);
  signal dout_RAM : word_array;
begin
  -- generate (width/32) blocks of 32-bit ram with a given depth
  -- these rams outputs are concatenated to a width-bit signal
  ramblocks : for i in 0 to nrRAMs-1 generate
    ramblock: dpram_asym
    generic map(
      rddepth => depth,
      wrwidth => RAMwrwidth,
      device  => device
    )
    port map(
      
      -- write port
      clkA   => clkA,
      waddrA => waddrA,
      weA    => weA,
      dinA   => dinA((i+1)*RAMwrwidth-1 downto RAMwrwidth*i),
      -- read port
      clkB   => clkB,
      raddrB => raddrB,
      doutB  => dout_RAM(i)
    );
    
    map_output : for j in 0 to nrRAMs-1 generate
      doutB(j*32+(i+1)*RAMwrwidth-1 downto j*32+i*RAMwrwidth)
          <= dout_RAM(i)((j+1)*RAMwrwidth-1 downto j*RAMwrwidth);
    end generate;
  end generate;
end structural;
