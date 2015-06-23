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
-- Entity: gpibControlReg
-- Date:2011-11-12  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity gpibControlReg is
	port (
		reset : in std_logic;
		strobe : in std_logic;
		data_in : in std_logic_vector (15 downto 0);
		data_out : out std_logic_vector (15 downto 0);
		------------------ gpib ------------------------
		ltn : out std_logic; -- listen (L, LE)
		lun : out std_logic; -- local unlisten (L, LE)
		rtl : out std_logic; -- return to local (RL)
		rsv : out std_logic; -- request service (SR)
		ist : out std_logic; -- individual status (PP)
		lpe : out std_logic; -- local poll enable (PP)
		------------------------------------------------
		rsc : out std_logic; -- request system control (C)
		sic : out std_logic; -- send interface clear (C)
		sre : out std_logic; -- send remote enable (C)
		gts : out std_logic; -- go to standby (C)
		tcs : out std_logic; -- take control synchronously (C, AH)
		tca : out std_logic; -- take control asynchronously (C)
		rpp : out std_logic; -- request parallel poll (C)
		rec_stb : out std_logic -- receives status byte (C)
	);
end gpibControlReg;

architecture arch of gpibControlReg is

	signal inner_buf : std_logic_vector (15 downto 0);

begin

	ltn <= inner_buf(0);
	lun <= inner_buf(1);
	rtl <= inner_buf(2);
	rsv <= inner_buf(3);
	ist <= inner_buf(4);
	lpe <= inner_buf(5);
	------------------------------------------------
	rsc <= inner_buf(6);
	sic <= inner_buf(7);
	sre <= inner_buf(8);
	gts <= inner_buf(9);
	tcs <= inner_buf(10);
	tca <= inner_buf(11);
	rpp <= inner_buf(12);
	rec_stb <= inner_buf(13);

	data_out <= inner_buf;

	process (reset, strobe) begin
		if reset = '1' then
			inner_buf <= "0000000000000000";
		elsif rising_edge(strobe) then
			inner_buf <= data_in;
		end if;
	end process;

end arch;

