----------------------------------------------------------------------  
----  d_flip_flop                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    1-bit D flip-flop implemented with behavorial (generic)   ----
----    description. With asynchronous active high reset.         ----
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

-- 1-bit D flip-flop with asynchronous active high reset
entity d_flip_flop is
  port(
    core_clk : in  std_logic; -- clock signal
    reset    : in  std_logic; -- active high reset
    din      : in  std_logic; -- data in
    dout     : out std_logic  -- data out
  );
end d_flip_flop;


architecture Behavorial of d_flip_flop is
begin
  
  -- process for 1-bit D flip-flop
  d_FF : process (reset, core_clk, din)
  begin
    if reset='1' then -- asynchronous active high reset
      dout <= '0';
    else
      if rising_edge(core_clk) then -- clock in data on rising edge
        dout <= din;
      end if;
    end if;
  end process; 
  
end Behavorial;
