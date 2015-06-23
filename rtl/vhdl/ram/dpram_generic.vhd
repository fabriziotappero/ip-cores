----------------------------------------------------------------------  
----  dpram_generic                                               ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    behavorial description of a dual port ram with one 32-bit ----
----    write port and one 32-bit read port                       ----            
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mod_sim_exp;
use mod_sim_exp.std_functions.all;

-- altera infers ramblocks from a depth of 9
-- xilinx infers ramblocks from a depth of 2
entity dpram_generic is
  generic (
    depth : integer := 2
  );
  port  (
    -- write port A
    clkA   : in std_logic;
    waddrA : in std_logic_vector(log2(depth)-1 downto 0);
    weA    : in std_logic;
    dinA   : in std_logic_vector(31 downto 0);
    -- read port B
    clkB   : in std_logic;
    raddrB : in std_logic_vector(log2(depth)-1 downto 0);
    doutB  : out std_logic_vector(31 downto 0)
  );
end dpram_generic;

architecture behavorial of dpram_generic is
  -- the memory
  type ram_type is array (depth-1 downto 0) of std_logic_vector (31 downto 0);
  shared variable RAM : ram_type := (others => (others => '0'));
  
  -- xilinx constraint to use blockram resources
  attribute ram_style : string;
  attribute ram_style of ram:variable is "block";
  -- altera constraints:
  -- for smal depths:
  --  if the synthesis option "allow any size of RAM to be inferred" is on, these lines 
  --  may be left commented.
  --  uncomment this attribute if that option is off and you know wich primitives should be used.
  --attribute ramstyle : string;
  --attribute ramstyle of RAM : variable is "M9K, no_rw_check";
begin
  process (clkA)
  begin
    if rising_edge(clkA) then
      if (weA = '1') then
        RAM(conv_integer(waddrA)) := dinA;
      end if;
    end if;
  end process;
  
  process (clkB)
  begin
    if rising_edge(clkB) then
      doutB <= RAM(conv_integer(raddrB));
    end if;
  end process;
  
end behavorial;

