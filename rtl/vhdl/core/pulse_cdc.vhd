----------------------------------------------------------------------  
----  pulse_cdc                                                   ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    transfers a pulse (1clk wide) from clock domain A to      ----
----    clock domain B by using a toggling signal. This design    ----
----    avoids metastable states                                  ----
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

entity pulse_cdc is
	port (
	  reset  : in std_logic;
		clkA   : in std_logic;
		pulseA : in std_logic;
		clkB   : in std_logic;
    pulseB : out std_logic
	);
end pulse_cdc;


architecture arch of pulse_cdc is
  signal pulseA_d : std_logic;
  signal toggle : std_logic := '0';
  signal toggle_d, toggle_d2, toggle_d3 : std_logic;
begin
  
  -- Convert pulse from clock domain A to a toggling signal
  PulseAtoToggle : process (clkA, reset)
  begin
    if reset='1' then
      toggle <= '0';
    else 
      if rising_edge(clkA) then
        pulseA_d <= pulseA;
        toggle <= toggle xor (pulseA and not pulseA_d);
      end if;
    end if;
  end process;
  
  -- Convert toggling signal to a pulse of 1clk wide to clock domain B
  ToggletoPulseB : process (clkB, reset)
  begin
    if reset='1' then
      toggle_d <= '0';
      toggle_d2 <= '0';
      toggle_d3 <= '0';
    else
      if rising_edge(clkB) then
        toggle_d <= toggle; -- this signal may have metastability isues
        toggle_d2 <= toggle_d; -- stable now
        toggle_d3 <= toggle_d2;
      end if;
    end if;
  end process;
  
  pulseB <= toggle_d2 xor toggle_d3;
end arch;
