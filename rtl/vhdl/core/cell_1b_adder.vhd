----------------------------------------------------------------------  
----  cell_1b_adder                                               ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    This file contains the implementation of a 1-bit full     ----
----    adder cell using combinatorial logic                      ----
----    used in adder_block                                       ----
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

-- 1-bit full adder cell
entity cell_1b_adder is
  port (
    -- input operands a, b
    a    : in  std_logic;
    b    : in  std_logic;
    -- carry in, out
    cin  : in  std_logic;
    cout : out  std_logic;
    -- result out
    r    : out  std_logic
  );
end cell_1b_adder;


architecture Behavioral of cell_1b_adder is
  signal a_xor_b : std_logic;
begin
  -- 1-bit full adder with combinatorial logic
  -- uses 2 XOR's, 2 AND's and 1 OR port
  a_xor_b <= a xor b;
  r <= a_xor_b xor cin;
  cout <= (a and b) or (cin and a_xor_b);
end Behavioral;
