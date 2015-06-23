----------------------------------------------------------------------  
----  x_shift_reg                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    n bit shift register for the x operand of the multiplier  ----
----    with bit output                                           ----
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

-- shift register for the x operand of the multiplier
-- outputs the lsb of the register or bit at offset according to the
-- selected pipeline part 
entity x_shift_reg is
  generic(
    n  : integer := 1536; -- width of the operands (# bits)
    t  : integer := 48;   -- total number of stages
    tl : integer := 16    -- lower number of stages
  );
  port(
    -- clock input
    clk    : in  std_logic;
    -- x operand in (n-bit)
    x_in   : in  std_logic_vector((n-1) downto 0);
    -- control signals
    reset  : in  std_logic; -- reset, clears register
    load_x : in  std_logic; -- load operand into shift register   
    next_x : in  std_logic; -- next bit of x
    p_sel  : in  std_logic_vector(1 downto 0);  -- pipeline selection
    -- x operand bit out (serial)
    xi     : out std_logic  
  );
end x_shift_reg;


architecture Behavioral of x_shift_reg is
  signal x_reg  : std_logic_vector((n-1) downto 0); -- register
  constant s      : integer := n/t;   -- stage width
  constant offset : integer := s*tl;  -- calculate startbit pos of higher part of pipeline
begin

	REG_PROC: process(reset, clk)
	begin
		if reset = '1' then -- Reset, clear the register
			x_reg <= (others => '0');
		elsif rising_edge(clk) then
			if load_x = '1' then -- Load_x, load the register with x_in
				x_reg <= x_in;
			elsif next_x = '1' then  -- next_x, shift to right. LSbit gets lost and zero's are shifted in
				x_reg((n-2) downto 0) <= x_reg((n-1) downto 1);
			else -- else remember state
				x_reg <= x_reg;
			end if;
		end if;
	end process;

	with p_sel select  -- pipeline select
		xi <= x_reg(offset) when "10", -- use bit at offset for high part of pipeline
				  x_reg(0) when others;    -- use LS bit for lower part of pipeline

end Behavioral;
