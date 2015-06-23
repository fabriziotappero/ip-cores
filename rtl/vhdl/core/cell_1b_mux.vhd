----------------------------------------------------------------------  
----  cel_1b_mux                                                  ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    1-bit mux for a standard cell in the montgommery          ----
----    multiplier systolic array                                 ----
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

-- 1-bit mux for a standard cell in the montgommery multiplier systolic array
entity cell_1b_mux is
  port (
    -- input bits
    my     : in  std_logic; 
    y      : in  std_logic;
    m      : in  std_logic;
    -- selection bits
    x      : in  std_logic;
    q      : in  std_logic;
    -- mux out
    result : out std_logic
  );
end cell_1b_mux;


architecture Behavioral of cell_1b_mux is
  signal sel : std_logic_vector(1 downto 0);
begin
  -- selection bits
  sel <= x & q;
  -- multipexer
  with sel select
    result <=  my when "11",
                y when "10",
                m when "01",
              '0' when others;

end Behavioral;
