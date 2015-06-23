----------------------------------------------------------------------  
----  register_n                                                  ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    n bit register with active high asynchronious reset and ce----
----    used in montgommery multiplier systolic array stages      ----            
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- n-bit register with asynchronous reset and clock enable
entity register_n is
  generic(
    width : integer := 4
  );
  port(
    core_clk : in  std_logic; -- clock input
    ce       : in  std_logic; -- clock enable (active high)
    reset    : in  std_logic; -- reset (active high)
    din      : in  std_logic_vector((width-1) downto 0);  -- data in (width)-bit
    dout     : out std_logic_vector((width-1) downto 0)   -- data out (width)-bit
  );
end register_n;


architecture Behavorial of register_n is
begin
	 -- process for (width)-bit register
  reg_nb : process (reset, ce, core_clk, din)
  begin
    if reset='1' then -- asynchronous active high reset
      dout <= (others=>'0');
    else
      if rising_edge(core_clk) then -- clock in data on rising edge
        if ce='1' then  -- active high clock enable to clock in data
          dout <= din;
        end if;
      end if;
    end if;
  end process; 

end Behavorial;
