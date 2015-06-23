----------------------------------------------------------------------  
----  cell_1b                                                      ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    1-bit cell for use in the montgommery multiplier systolic ----
----    array                                                     ----
----                                                              ---- 
----  Dependencies:                                               ---- 
----    - cell_1bit_adder                                         ---- 
----    - cell_1bit_mux                                           ----
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

-- 1-bit cell for the systolic array
entity cell_1b is
  port (
    -- operand input bits (m+y, y and m)
    my   : in  std_logic;
    y    : in  std_logic;
    m    : in  std_logic;
    -- operand x input bit and q
    x    : in  std_logic;
    q    : in  std_logic;
    -- previous result input bit
    a    : in  std_logic;
    -- carry's
    cin  : in  std_logic;
    cout : out std_logic;
    -- cell result out
    r    : out std_logic
  );
end cell_1b;


architecture Structural of cell_1b is
  -- mux to adder connection
  signal mux2adder : std_logic;
begin
  
  -- mux for my, y and m input bits
  cell_mux : cell_1b_mux
  port map(
    my     => my,
    y      => y,
    m      => m,
    x      => x,
    q      => q,
    result => mux2adder
  );
  
  -- full adder for a+mux2adder
  cell_adder : cell_1b_adder
  port map(
    a    => a,
    b    => mux2adder,
    cin  => cin,
    cout => cout,
    r    => r
  );

end Structural;
