
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
-- Filename: fifo_reg.vhd
-- 
-- Description: a single register FIFO
-- 



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.pkg_nocem.all;



entity fifo_reg is
	generic (
		WIDTH : integer := 16
	);
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(WIDTH-1 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(WIDTH-1 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);


end fifo_reg;

architecture Behavioral of fifo_reg is

signal empty_i : std_logic;




begin



	full <= not empty_i;
	empty <= empty_i;

	delay_gen : process (clk,rst)
	begin
		if rst='1' then
			dout <= (others => '0');
			empty_i <= '1';

		elsif clk'event and clk='1' then



			-- manage empty signal
			if empty_i = '0' and rd_en ='1' and wr_en = '0'  then
				empty_i <= '1';
			elsif empty_i = '1' and rd_en='0' and  wr_en='1' then
				empty_i <= '0';
			end if;

			--manage dout
			if rd_en='1' and wr_en='0' then
				dout <= (others => '0');
			elsif wr_en='1' then
				dout <= din;
			end if;



		end if;


	end process;



end Behavioral;
