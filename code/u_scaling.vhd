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

-- A.10 
-- multiply by 0.0625
-- only simple shift logic is applied

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;


entity u_scaling is
    Port ( d_in : in std_logic_vector(15 downto 0);
           d_out : out std_logic_vector(15 downto 0);
		 clock : in std_logic);
end u_scaling;

architecture combinational of u_scaling is
signal sign_bit:std_logic_vector(4 downto 0);
begin
 p1:
 process(clock)
 begin
 
 	if(clock'event and clock = '1') then
		 d_out <= d_in(15) & d_in(15) & d_in(15) & d_in(15) & d_in(15) & d_in(14 downto 4);
 	end if;
 end process;
end combinational;
