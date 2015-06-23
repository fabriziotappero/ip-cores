
-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: mux4to1.vhd
-- 
-- Description: simple mux
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity mux4to1 is
generic (
	DWIDTH : integer := 16;
	REG_OUTPUT : integer := 0
	);
	port (
		din0 : in std_logic_vector( DWIDTH-1 downto 0);
		din1 : in std_logic_vector( DWIDTH-1 downto 0);
		din2 : in std_logic_vector( DWIDTH-1 downto 0);
		din3 : in std_logic_vector( DWIDTH-1 downto 0);
		sel  : in std_logic_vector( 3 downto 0);
		dout : out std_logic_vector( DWIDTH-1 downto 0);

		clk : in std_logic;
		rst : in std_logic
	);
end mux4to1;

architecture Behavioral of mux4to1 is

begin

g_uregd: if REG_OUTPUT=0 generate
	muxit_uregd : process (din0,din1,din2,din3,sel)
	begin 
	case sel is
		when "0001" =>
			dout <= din0;
		when "0010" =>
			dout <= din1;
		when "0100" =>
			dout <= din2;
		when "1000" =>
			dout <= din3;
		when others => 
			dout <= (others => '0');
	end case;

	end process;

end generate;


g_regd: if REG_OUTPUT=1 generate
	muxit_regd : process (rst,clk)
	begin
	
		if rst = '1' then
			dout <= (others => '0');
		elsif clk='1' and clk'event then 
			case sel is
				when "0001" =>
					dout <= din0;
				when "0010" =>
					dout <= din1;
				when "0100" =>
					dout <= din2;
				when "1000" =>
					dout <= din3;
				when others => 
					dout <= (others => '0');
			end case;

		end if;

	end process;

end generate;





end Behavioral;
