----------------------------------------------------------------------  
----  tdpramblock_asym                                            ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    structural description of an asymmetric true dual port    ----
----    ram with one 32-bit read/write port and one (width)-bit   ----
----    read/write port.                                          ----
----                                                              ---- 
----  Dependencies: tdpram_asym                                   ----
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
--    and width 64,128,256,512
-- xilinx infers ramblocks from a depth of 2 and width 32,64,128,256,512
entity tdpramblock_asym is
  generic (
    depth  : integer := 4;    -- nr of (width)-bit words
    width  : integer := 512;  -- width of portB
    device : string  := "xilinx"
  );
  port (
    -- port A 32-bit
    clkA  : in std_logic;
    addrA : in std_logic_vector(log2((width*depth)/32)-1 downto 0);
    weA   : in std_logic;
    dinA  : in std_logic_vector(31 downto 0);
    doutA : out std_logic_vector(31 downto 0);
    -- port B (width)-bit
    clkB  : in std_logic;
    addrB : in std_logic_vector(log2(depth)-1 downto 0);
    weB   : in std_logic;
    dinB  : in std_logic_vector(width-1 downto 0);
    doutB : out std_logic_vector(width-1 downto 0)
  );
end tdpramblock_asym;

architecture structural of tdpramblock_asym is
   -- constants
   constant nrRAMs    : integer := width/32;
   constant RAMwidthA : integer := 32/nrRAMs;

   -- interconnection signals
   type word_array is array (nrRAMs-1 downto 0) of std_logic_vector(31 downto 0);
   signal doutB_RAM : word_array;
   signal dinB_RAM  : word_array;
 begin

  ramblocks : for i in 0 to nrRAMs-1 generate
    ramblock : tdpram_asym
    generic map(
      widthA => RAMwidthA,
      depthB => depth,
      device => device
    )
    port map(
      -- port A (widthA)-bit
      clkA  => clkA,
      addrA => addrA,
      weA   => weA,
      dinA  => dinA((i+1)*RAMwidthA-1 downto RAMwidthA*i),
      doutA => doutA((i+1)*RAMwidthA-1 downto RAMwidthA*i),
      -- port B 32-bit
      clkB  => clkB,
      addrB => addrB,
      weB   => weB,
      dinB  => dinB_RAM(i),
      doutB => doutB_RAM(i)
    );
    
    map_ioB : for j in 0 to nrRAMs-1 generate
      -- output
      doutB(j*32+(i+1)*RAMwidthA-1 downto j*32+i*RAMwidthA)
          <= doutB_RAM(i)((j+1)*RAMwidthA-1 downto j*RAMwidthA);
      -- input
      dinB_RAM(i)((j+1)*RAMwidthA-1 downto j*RAMwidthA)
          <= dinB(j*32+(i+1)*RAMwidthA-1 downto j*32+i*RAMwidthA);
    end generate;
  end generate;
  
end structural;

