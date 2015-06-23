--  Copyright (C) 2004-2005 Digish Pandya <digish.pandya@gmail.com>

--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

-- delay of 21 and 1 unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity shift_21d is
    Port ( xin : in std_logic_vector(7 downto 0);
           x_N_out : out std_logic_vector(7 downto 0);
		 x_1_out : out std_logic_vector(7 downto 0);
           clock : in std_logic);
end shift_21d;

architecture Behavioral of shift_21d is
signal shift_reg: std_logic_vector (167 downto 0);
--signal shift_reg: std_logic_vector (127 downto 0);
begin

   shift:
   process(clock)
   begin
	if(clock'event and clock = '1') then
	   	
		shift_reg <= xin & shift_reg(167 downto 8);

	end if;
  end process;	
  x_N_out <= shift_reg(7 downto 0);
  x_1_out <= shift_reg(167 downto 160);
end Behavioral;
