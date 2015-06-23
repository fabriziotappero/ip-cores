----------------------------------------------------------------------  
----  tdpram_asym                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    behavorial description of an asymmetric true dual port    ----
----    ram with one (widthA)-bit read/write port and one 32-bit  ----
----    read/write port. Made using the templates of xilinx and   ----
----    altera for asymmetric ram.                                ----
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
-- option on or contstraint below on) and widthA 1,2,4,8,16
-- xilinx infers ramblocks from a depth of 2 and widthA 1,2,4,8,16,32
entity tdpram_asym is
  generic (
    depthB : integer := 4; -- nr of 32-bit words
    widthA : integer := 2;  -- port A width, must be smaller than or equal to 32
    device : string  := "xilinx"
  );
  port  (
    -- port A (widthA)-bit
    clkA  : in std_logic;
    addrA : in std_logic_vector(log2((depthB*32)/widthA)-1 downto 0);
    weA   : in std_logic;
    dinA  : in std_logic_vector(widthA-1 downto 0);
    doutA : out std_logic_vector(widthA-1 downto 0);
    -- port B 32-bit
    clkB  : in std_logic;
    addrB : in std_logic_vector(log2(depthB)-1 downto 0);
    weB   : in std_logic;
    dinB  : in std_logic_vector(31 downto 0);
    doutB : out std_logic_vector(31 downto 0)
  );
end tdpram_asym;

architecture behavorial of tdpram_asym is
  -- constants
  constant R : natural := 32/widthA; -- ratio
begin

  xilinx_device : if device="xilinx" generate
    -- An asymmetric RAM is modelled in a similar way as a symmetric RAM, with an
    -- array of array object. Its aspect ratio corresponds to the port with the
    -- lower data width (larger depth)
    type ramType is array (0 to ((depthB*32)/widthA)-1) of std_logic_vector(widthA-1 downto 0);
  
    -- You need to declare ram as a shared variable when :
    --   - the RAM has two write ports,
    --   - the RAM has only one write port whose data width is maxWIDTH
    -- In all other cases, ram can be a signal.
    shared variable ram : ramType := (others => (others => '0'));
	 
  begin
    process (clkA)
    begin
      if rising_edge(clkA) then
        if weA = '1' then
          ram(conv_integer(addrA)) := dinA;
        end if;
        doutA <= ram(conv_integer(addrA));
      end if;
    end process;
	 
    process (clkB)
    begin
      if rising_edge(clkB) then     
        for i in 0 to R-1 loop
          if weB = '1' then
            ram(conv_integer(addrB & conv_std_logic_vector(i,log2(R))))
              := dinB((i+1)*widthA-1 downto i*widthA);
          end if;
          doutB((i+1)*widthA-1 downto i*widthA)
            <= ram(conv_integer(addrB & conv_std_logic_vector(i,log2(R))));
        end loop;
      end if;
    end process;
  end generate;
  
  altera_device : if device="altera" generate
    -- Use a multidimensional array to model mixed-width 
    type word_t is array(R-1 downto 0) of std_logic_vector(widthA-1 downto 0);
    type ram_t is array (0 to depthB-1) of word_t;
  
    -- altera constraints:
    -- for smal depths:
    --  if the synthesis option "allow any size of RAM to be inferred" is on, these lines 
    --  may be left commented.
    --  uncomment this attribute if that option is off and you know wich primitives should be used.
    --attribute ramstyle : string;
    --attribute ramstyle of RAM : signal is "M9K, no_rw_check";
  
    -- delcare the RAM
    signal ram : ram_t;
    signal wB_local : word_t;
    signal qB_local : word_t;
  
  begin  -- rtl
    -- Re-organize the write data to match the RAM word type
    unpack: for i in 0 to R-1 generate    
      wB_local(i) <= dinB(widthA*(i+1)-1 downto widthA*i);
      doutB(widthA*(i+1)-1 downto widthA*i) <= qB_local(i);
    end generate unpack;
  
    --port B
    process(clkB)
    begin
      if(rising_edge(clkB)) then 
        if(weB = '1') then
          ram(conv_integer(addrB)) <= wB_local;
        end if;
        qB_local <= ram(conv_integer(addrB));
      end if;
    end process;
  
    -- port A
    process(clkA)
    begin
      if(rising_edge(clkA)) then 
        doutA <= ram(conv_integer(addrA) / R )(conv_integer(addrA) mod R);
        if(weA ='1') then
          ram(conv_integer(addrA) / R)(conv_integer(addrA) mod R) <= dinA;
        end if;
      end if;
    end process;  
  end generate;
  
end behavorial;

