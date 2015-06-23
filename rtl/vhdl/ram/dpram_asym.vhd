----------------------------------------------------------------------  
----  dpram_asym                                                  ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    behavorial description of an asymmetric dual port ram     ----
----    with one (wrwidth)-bit write port and one 32-bit read     ----
----    port. Made using the templates of xilinx and altera for   ----
----    asymmetric ram.                                           ----            
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
use ieee.std_logic_arith.all;

library mod_sim_exp;
use mod_sim_exp.std_functions.all;

-- altera infers ramblocks from a depth of 9 (or 2 with any ram size recognition 
-- option on or contstraint below on) and wrwidth 1,2,4,8,16
-- xilinx infers ramblocks from a depth of 2 and wrwidth 1,2,4,8,16,32
entity dpram_asym is
  generic (
    rddepth : integer := 4; -- nr of 32-bit words
    wrwidth : integer := 2; -- write width, must be smaller than or equal to 32
    device  : string  := "xilinx"  -- device template to use
  );
  port (
    -- write port
    clkA   : in std_logic;
    waddrA : in std_logic_vector(log2((rddepth*32)/wrwidth)-1 downto 0);
    weA    : in std_logic;
    dinA   : in std_logic_vector(wrwidth-1 downto 0);
    -- read port
    clkB   : in std_logic;
    raddrB : in std_logic_vector(log2(rddepth)-1 downto 0);
    doutB  : out std_logic_vector(31 downto 0)
  );
end dpram_asym;

architecture behavorial of dpram_asym is
  -- constants
  constant R       : natural := 32/wrwidth; -- ratio
  constant wrdepth : integer := (rddepth*32)/wrwidth;
begin

  xilinx_device : if device="xilinx" generate
    -- the memory
    type ram_type is array (wrdepth-1 downto 0) of std_logic_vector (wrwidth-1 downto 0);
    shared variable RAM : ram_type := (others => (others => '0'));
    
    -- xilinx constraint to use blockram resources
    attribute ram_style : string;
    attribute ram_style of RAM:variable is "block";
  begin
    -- Write port A
    process (clkA)
    begin
      if rising_edge(clkA) then
        if (weA = '1') then
          RAM(conv_integer(waddrA)) := dinA;
        end if;
      end if;
    end process;
    
    -- Read port B
    process (clkB)
    begin
      if rising_edge(clkB) then
        for i in 0 to R-1 loop
          doutB((i+1)*wrwidth-1 downto i*wrwidth)
                <= RAM(conv_integer(raddrB & conv_std_logic_vector(i,log2(R))));
        end loop;
      end if;
    end process;
  end generate;
  
  altera_device : if device="altera" generate
    -- Use a multidimensional array to model mixed-width 
    type word_t is array(R-1 downto 0) of std_logic_vector(wrwidth-1 downto 0);
    type ram_t is array (0 to rddepth-1) of word_t;
  
    shared variable ram : ram_t;
    signal q_local : word_t;
    -- altera constraints:
    -- for smal depths:
    --  if the synthesis option "allow any size of RAM to be inferred" is on, these lines 
    --  may be left commented.
    --  uncomment this attribute if that option is off and you know wich primitives should be used.
    --attribute ramstyle : string;
    --attribute ramstyle of RAM : signal is "M9K, no_rw_check";
  begin
    unpack: for i in 0 to R - 1 generate    
      doutB(wrwidth*(i+1) - 1 downto wrwidth*i) <= q_local(i);
    end generate unpack;
  
    process(clkA)
    begin
      if(rising_edge(clkA)) then 
        if(weA = '1') then
          ram(conv_integer(waddrA)/R)(conv_integer(waddrA) mod R) := dinA;
        end if;
      end if;
    end process;
    
    process(clkB)
    begin
      if(rising_edge(clkB)) then 
        q_local <= ram(conv_integer(raddrB));
      end if;
    end process;
  end generate;
  
end behavorial;
