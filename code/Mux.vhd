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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Mux is
    Port ( in1 : in std_logic_vector(3 downto 0);
           in2 : in std_logic_vector(3 downto 0);
           in3 : in std_logic_vector(3 downto 0);
           in4 : in std_logic_vector(3 downto 0);
           sel : in std_logic_vector(1 downto 0);
           o_ut : out std_logic_vector(3 downto 0));
end Mux;

architecture Behavioral of Mux is

begin

o_ut <= 	in1 when sel = "00" else
		in2 when sel = "01" else
		in3 when sel = "10" else
		in4 when sel = "11" else
		"0000";

end Behavioral;
