----------------------------------------------------------------------  
----  sys_first_cell_logic                                        ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    first cell logic for use int the montogommery mulitplier  ----
----    pipelined systolic array                                  ----
----                                                              ----
----  Dependencies:                                               ----
----    - register_n                                              ----
----    - cell_1b_adder                                           ----
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
use mod_sim_exp.mod_sim_exp_pkg.all;

-- logic needed as the first piece in the systolic array pipeline
-- calculates the first my_cout and generates q signal
entity sys_first_cell_logic is
  port  (
    m0       : in std_logic;    -- lsb from m operand
    y0       : in std_logic;    -- lsb from y operand
    my_cout  : out std_logic;   -- my_cin for first stage
    xi       : in std_logic;    -- xi operand input
    xout     : out std_logic;   -- xin for first stage
    qout     : out std_logic;   -- qin for first stage
    cout     : out std_logic;   -- cin for first stage
    a_0      : in std_logic;    -- a_0 from first stage
    red_cout : out std_logic    -- red_cin for first stage
  );
end sys_first_cell_logic;

architecture Behavorial of sys_first_cell_logic is
  -- first cell signals
  signal my0_mux_result : std_logic;
  signal my0 : std_logic;
  signal qout_i : std_logic;
begin
  -- half adder for m0 +y0
  my0 <= m0 xor y0;
  my_cout <= m0 and y0; -- carry
  
  xout <= xi;
  qout_i <= (xi and y0) xor a_0;
  cout <= my0_mux_result and a_0;
  red_cout <= '1'; -- add 1 for 2s complement
  
  my0_mux : cell_1b_mux
  port map(
    my     => my0,
    m      => m0,
    y      => y0,
    x      => xi,
    q      => qout_i,
    result => my0_mux_result
  );
  
  qout <= qout_i;
  
end Behavorial;
