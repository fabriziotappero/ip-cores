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
-- Entity: 	if_func_C
-- Date:	23:00:30 10/04/2011
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;

use work.utilPkg.all;


entity commandEcoder is
	port (
		-- data
		data : in std_logic_vector (7 downto 0);
		-- status byte
		status_byte : in std_logic_vector (7 downto 0);
		-- PPR command data
		ppBitValue : in std_logic;
		ppLineNumber : in std_logic_vector (2 downto 0);
		-- func states
		APRS : in std_logic; -- affirmative poll response state
		CACS : in std_logic; -- controller active state (C)
		-- commands
		ATN : in std_logic;
		END_OF : in std_logic;
		IDY : in std_logic;
		DAC : in std_logic;
		RFD : in std_logic;
		DAV : in std_logic;
		IFC : in std_logic;
		REN : in std_logic;
		SRQ : in std_logic; -- request for service
		DAB : in std_logic;
		EOS : in std_logic;
		RQS : in std_logic; -- part of STB
		STB : in std_logic;
		TCT : in std_logic;
		PPR : in std_logic;
		-------------------------------------------
		-- data lines -----------------------------
		-------------------------------------------
		DO : out std_logic_vector (7 downto 0);
		output_valid : out std_logic;
		-------------------------------------------
		-- control lines --------------------------
		-------------------------------------------
		-- DAV line
		DAV_line : out std_logic;
		-- NRFD line
		NRFD_line : out std_logic;
		-- NDAC line
		NDAC_line : out std_logic;
		-- ATN line
		ATN_line : out std_logic;
		-- EOI line
		EOI_line : out std_logic;
		-- SRQ line
		SRQ_line : out std_logic;
		-- IFC line
		IFC_line : out std_logic;
		-- REN line
		REN_line : out std_logic
	);
end commandEcoder;

architecture arch of commandEcoder is

	signal modified_status_byte : std_logic_vector (7 downto 0);
	signal PPR_resp : std_logic_vector (7 downto 0);
	
begin

	ATN_line <= (ATN or IDY) and not END_OF;
	EOI_line <= END_OF or IDY;
	DAV_line <= DAV;
	NRFD_line <= not RFD;
	NDAC_line <= not DAC;
	SRQ_line <= SRQ;
	IFC_line <= IFC;
	REN_line <= REN;

	output_valid <= STB or DAB or EOS or TCT or PPR or CACS;

	DO <=
		data when DAB='1' or EOS='1' or CACS='1' else
		"00001001" when TCT='1' else
		PPR_resp when PPR='1' else
		modified_status_byte when STB='1' else
		"00000000";

	-- modifies status byte
	process (status_byte, APRS) begin
		modified_status_byte <= status_byte;
		modified_status_byte(6) <= APRS;
	end process;

	-- sets PPR response
	process (ppBitValue, ppLineNumber) begin
		
		PPR_resp <= "00000000";
		
		case ppLineNumber is
			------------------
			when "000" =>
				PPR_resp(0) <= ppBitValue;
			------------------
			when "001" =>
				PPR_resp(1) <= ppBitValue;
			------------------
			when "010" =>
				PPR_resp(2) <= ppBitValue;
			------------------
			when "011" =>
				PPR_resp(3) <= ppBitValue;
			------------------
			when "100" =>
				PPR_resp(4) <= ppBitValue;
			------------------
			when "101" =>
				PPR_resp(5) <= ppBitValue;
			------------------
			when "110" =>
				PPR_resp(6) <= ppBitValue;
			------------------
			when others =>
				PPR_resp(7) <= ppBitValue;
		end case;
	end process;

end arch;

