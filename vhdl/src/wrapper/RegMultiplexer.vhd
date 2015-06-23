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
-- Entity: RegMultiplexer
-- Date:2011-11-14  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


entity RegMultiplexer is
	generic (
		ADDR_WIDTH : integer := 15
	);
	port (
		strobe_read : in std_logic;
		strobe_write : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		data_out : out std_logic_vector (15 downto 0);
		--------------------------------------------------------
		reg_addr : in std_logic_vector((ADDR_WIDTH-1) downto 0);
		--------------------------------------------------------
		reg_strobe_0 : out std_logic;
		reg_in_0 : out std_logic_vector (15 downto 0);
		reg_out_0 : in std_logic_vector (15 downto 0);
		
		reg_strobe_1 : out std_logic;
		reg_in_1 : out std_logic_vector (15 downto 0);
		reg_out_1 : in std_logic_vector (15 downto 0);
		
		reg_strobe_2 : out std_logic;
		reg_in_2 : out std_logic_vector (15 downto 0);
		reg_out_2 : in std_logic_vector (15 downto 0);
		
		reg_strobe_3 : out std_logic;
		reg_in_3 : out std_logic_vector (15 downto 0);
		reg_out_3 : in std_logic_vector (15 downto 0);
		
		reg_strobe_4 : out std_logic;
		reg_in_4 : out std_logic_vector (15 downto 0);
		reg_out_4 : in std_logic_vector (15 downto 0);
		
		reg_strobe_5 : out std_logic;
		reg_in_5 : out std_logic_vector (15 downto 0);
		reg_out_5 : in std_logic_vector (15 downto 0);
		
		reg_strobe_6 : out std_logic;
		reg_in_6 : out std_logic_vector (15 downto 0);
		reg_out_6 : in std_logic_vector (15 downto 0);
		
		reg_strobe_7 : out std_logic;
		reg_in_7 : out std_logic_vector (15 downto 0);
		reg_out_7 : in std_logic_vector (15 downto 0);
		
		reg_strobe_8 : out std_logic;
		reg_in_8 : out std_logic_vector (15 downto 0);
		reg_out_8 : in std_logic_vector (15 downto 0);
		
		reg_strobe_9 : out std_logic;
		reg_in_9 : out std_logic_vector (15 downto 0);
		reg_out_9 : in std_logic_vector (15 downto 0);
		
		reg_strobe_10 : out std_logic;
		reg_in_10 : out std_logic_vector (15 downto 0);
		reg_out_10 : in std_logic_vector (15 downto 0);
		
		reg_strobe_11 : out std_logic;
		reg_in_11 : out std_logic_vector (15 downto 0);
		reg_out_11 : in std_logic_vector (15 downto 0);
		
		reg_strobe_other0 : out std_logic;
		reg_in_other0 : out std_logic_vector (15 downto 0);
		reg_out_other0 : in std_logic_vector (15 downto 0);
		
		reg_strobe_other1 : out std_logic;
		reg_in_other1 : out std_logic_vector (15 downto 0);
		reg_out_other1 : in std_logic_vector (15 downto 0)
	);
end RegMultiplexer;

architecture arch of RegMultiplexer is

	constant REG_COUNT : integer := 14;
	constant MAX_ADDR : integer := (2**ADDR_WIDTH - 1);

	type SIGNAL_VECTOR is array ((REG_COUNT-1) downto 0) of std_logic;
	type BUS_VECTOR is array ((REG_COUNT-1) downto 0) of
		std_logic_vector (15 downto 0);

	signal cur_reg_num : integer range 0 to 13;
	signal dec_addr : integer range MAX_ADDR downto 0;

	signal inputs : BUS_VECTOR;
	signal outputs : BUS_VECTOR;
	signal strobes : SIGNAL_VECTOR;

begin

	(reg_strobe_other1, reg_strobe_other0, reg_strobe_11, reg_strobe_10,
	reg_strobe_9, reg_strobe_8, reg_strobe_7, reg_strobe_6, reg_strobe_5,
	reg_strobe_4, reg_strobe_3, reg_strobe_2, reg_strobe_1,
	reg_strobe_0) <= strobes;

	(reg_in_other1, reg_in_other0, reg_in_11, reg_in_10, reg_in_9, reg_in_8,
	reg_in_7, reg_in_6, reg_in_5, reg_in_4, reg_in_3, reg_in_2, reg_in_1,
	reg_in_0) <= inputs;

	outputs <= (reg_out_other1, reg_out_other0, reg_out_11, reg_out_10,
		reg_out_9, reg_out_8, reg_out_7, reg_out_6, reg_out_5, reg_out_4,
		reg_out_3, reg_out_2, reg_out_1, reg_out_0);

	dec_addr <= conv_integer(reg_addr);

	process (dec_addr) begin
		if dec_addr >= 0 and dec_addr < (REG_COUNT-2) then
			cur_reg_num <= dec_addr;
		elsif dec_addr = (REG_COUNT-2) then
			cur_reg_num <= 12;
		else
			cur_reg_num <= 13;
		end if;
	end process;

	process (strobe_read, strobe_write, data_in, outputs, cur_reg_num) begin
		
		strobes <= (others => '0');
		inputs <= (others => (others => '0'));
		data_out <= (others => '0');
		
		if cur_reg_num < REG_COUNT then
			if cur_reg_num = 12 then
				strobes(cur_reg_num) <= strobe_read;
			else
				strobes(cur_reg_num) <= strobe_write;
			end if;
			
			inputs(cur_reg_num) <= data_in;
			data_out <= outputs(cur_reg_num);
		end if;
	end process;

end arch;

