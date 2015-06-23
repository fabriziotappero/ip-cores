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
-- Entity: GpibSynchronizer
-- Date:2012-02-06  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity GpibSynchronizer is
	port (
		-- clk
		clk : std_logic;
		-- DIO
		DI : in std_logic_vector (7 downto 0);
		DO : out std_logic_vector (7 downto 0);
		-- attention
		ATN_in : in std_logic;
		ATN_out : out std_logic;
		-- data valid
		DAV_in : in std_logic;
		DAV_out : out std_logic;
		-- not ready for data
		NRFD_in : in std_logic;
		NRFD_out : out std_logic;
		-- no data accepted
		NDAC_in : in std_logic;
		NDAC_out : out std_logic;
		-- end or identify
		EOI_in : in std_logic;
		EOI_out : out std_logic;
		-- service request
		SRQ_in : in std_logic;
		SRQ_out : out std_logic;
		-- interface clear
		IFC_in : in std_logic;
		IFC_out : out std_logic;
		-- remote enable
		REN_in : in std_logic;
		REN_out : out std_logic
	);
end GpibSynchronizer;

architecture arch of GpibSynchronizer is

begin

	process(clk) begin
		if rising_edge(clk) then
			
			DO <= DI;
			
			ATN_out <= ATN_in;
			
			DAV_out <= DAV_in;
			
			NRFD_out <= NRFD_in;
			
			NDAC_out <= NDAC_in;
			
			EOI_out <= EOI_in;
			
			SRQ_out <= SRQ_in;
			
			IFC_out <= IFC_in;
			
			REN_out <= REN_in;
		end if;
	end process;

end arch;

