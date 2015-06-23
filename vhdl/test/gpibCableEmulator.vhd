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
----------------------------------------------------------------------------------
-- Author: Andrzej Paluch
-- 
-- Create Date:    17:07:00 10/22/2011 
-- Design Name: 
-- Module Name:    gpibCableEmulator - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gpibCableEmulator is port (
	-- interface signals
	DIO_1 : in std_logic_vector (7 downto 0);
	output_valid_1 : in std_logic;
	DIO_2 : in std_logic_vector (7 downto 0);
	output_valid_2 : in std_logic;
	DIO : out std_logic_vector (7 downto 0);
	-- attention
	ATN_1 : in std_logic;
	ATN_2 : in std_logic;
	ATN : out std_logic;
	-- data valid
	DAV_1 : in std_logic;
	DAV_2 : in std_logic;
	DAV : out std_logic;
	-- not ready for data
	NRFD_1 : in std_logic;
	NRFD_2 : in std_logic;
	NRFD : out std_logic;
	-- no data accepted
	NDAC_1 : in std_logic;
	NDAC_2 : in std_logic;
	NDAC : out std_logic;
	-- end or identify
	EOI_1 : in std_logic;
	EOI_2 : in std_logic;
	EOI : out std_logic;
	-- service request
	SRQ_1 : in std_logic;
	SRQ_2 : in std_logic;
	SRQ : out std_logic;
	-- interface clear
	IFC_1 : in std_logic;
	IFC_2 : in std_logic;
	IFC : out std_logic;
	-- remote enable
	REN_1 : in std_logic;
	REN_2 : in std_logic;
	REN : out std_logic
);
end gpibCableEmulator;

architecture Behavioral of gpibCableEmulator is

	signal DIO_1_mid, DIO_2_mid : std_logic_vector (7 downto 0);

begin

	with output_valid_1 select DIO_1_mid <=
		DIO_1 when '1',
		"00000000" when others;

	with output_valid_2 select DIO_2_mid <=
		DIO_2 when '1',
		"00000000" when others;

	DIO <= not (not DIO_1_mid and not DIO_2_mid);

	ATN <= not(not ATN_1 and not ATN_2);
	DAV <= not(not DAV_1 and not DAV_2);
	NRFD <= not(not NRFD_1 and not NRFD_2);
	NDAC <= not(not NDAC_1 and not NDAC_2);
	EOI <= not(not EOI_1 and not EOI_2);
	SRQ <= not(not SRQ_1 and not SRQ_2);
	IFC <= not(not IFC_1 and not IFC_2);
	REN <= not(not REN_1 and not REN_2);

end Behavioral;

