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


-- A.5
-- simple logic for filter tap operation optimized for the fact that 
-- that there are only two possible data at input
 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;



entity ch_filt_tap is
    Port ( din : in std_logic_vector(7 downto 0);
           dout : out std_logic_vector(7 downto 0);
           c1_in : in std_logic_vector(7 downto 0);
           c2_in : in std_logic_vector(7 downto 0);
           add_in : in std_logic_vector(7 downto 0);
           add_out : out std_logic_vector(7 downto 0);
           clock : in std_logic);
end ch_filt_tap;

architecture Behavioral of ch_filt_tap is
	
signal mul_res:std_logic_vector(7 downto 0);

begin
	shift_process:
	process (clock)
	begin
		if(clock'event and clock = '1') then
			dout <= din;
		end if;
	end process;


	with din select
	mul_res <= c1_in when "11000000",	 -- -1
			 c2_in when others;		 -- +1
	
	add_out <= add_in + mul_res;

end Behavioral;
