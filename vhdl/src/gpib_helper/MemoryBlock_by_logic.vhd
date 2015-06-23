--------------------------------------------------------------------------------
--This file is part of fpga_gpib_controller.
--
-- Fpga_gpib_controller is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Fpga_gpib_controller is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with Fpga_gpib_controller.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------
-- Entity: MemoryBlock
-- Date:2011-11-14  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library UNISIM;
use UNISIM.vcomponents.all;

use work.utilPkg.all;
use work.helperComponents.all;


entity MemoryBlock is
	port (
		reset : in std_logic;
		clk : in std_logic;
		-------------------------------------------------
		p1_addr : in std_logic_vector(10 downto 0);
		p1_data_in : in std_logic_vector(7 downto 0);
		p1_strobe : in std_logic;
		p1_data_out : out std_logic_vector(7 downto 0);
		-------------------------------------------------
		p2_addr : in std_logic_vector(10 downto 0);
		p2_data_in : in std_logic_vector(7 downto 0);
		p2_strobe : in std_logic;
		p2_data_out : out std_logic_vector(7 downto 0)
	);
end MemoryBlock;

architecture arch of MemoryBlock is

	type mem is array(0 to 31) of std_logic_vector(7 downto 0);
	
	signal memory : mem;
	signal addrP1, addrP2 : integer range 0 to 31;
	
begin

	addrP1 <= conv_integer(UNSIGNED(p1_addr));
	addrP2 <= conv_integer(UNSIGNED(p2_addr));

	process(reset, clk) begin
		if reset = '1' then
			
		elsif rising_edge(clk) then
			p1_data_out <= memory(addrP1);
			p2_data_out <= memory(addrP2);
			
			if p1_strobe = '1' then
				memory(addrP1) <= p1_data_in;
			end if;
			
			if p2_strobe = '1' then
				memory(addrP2) <= p2_data_in;
			end if;
		end if;
	end process;

end arch;

