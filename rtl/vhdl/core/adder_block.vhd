----------------------------------------------------------------------  
----  adder_block                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    Adder block with a flipflop for the carry out so result   ----
----    is available after 1 clock cycle                          ----
----    for use in the montgommery multiplier pre and post        ----
----    computation adders                                        ----
----                                                              ----
----  Dependencies:                                               ----
----    - cell_1b_adder                                           ----
----    - d_flip_flop                                             ----
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

-- (width)-bit full adder block using cell_1b_adders
-- with buffered carry out -> result after 1 clock cycle
entity adder_block is
  generic (
    width : integer := 32 --adder operand widths
  );
  port (
    -- clock input
    core_clk : in std_logic; 
    -- adder input operands a, b (width)-bit
    a : in std_logic_vector((width-1) downto 0);
    b : in std_logic_vector((width-1) downto 0);
    -- carry in, out
    cin   : in std_logic;
    cout  : out std_logic;
    -- adder result out (width)-bit
    r : out std_logic_vector((width-1) downto 0) 
  );
end adder_block;


architecture Structural of adder_block is
  -- vector for the carry bits
  signal carry : std_logic_vector(width downto 0);
begin
  -- carry in
  carry(0) <= cin;

  -- structure of (width) cell_1b_adders
  adder_chain : for i in 0 to (width-1) generate
    adders : cell_1b_adder
    port map(
      a    => a(i),
      b    => b(i),
      cin  => carry(i),
      cout => carry(i+1),
      r    => r(i)
    );
  end generate;
  
  -- buffer the carry every clock cycle
  carry_reg : d_flip_flop
  port map(
    core_clk => core_clk,
    reset    => '0',
    din      => carry(width),
    dout     => cout
  );

end Structural;
