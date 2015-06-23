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
-- Entity: commandDecoder
-- Date:2011-10-07  
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;

use work.utilPkg.all;


entity commandDecoder is
	port (

		-------------------------------------------
		-- data lines -----------------------------
		-------------------------------------------
		DI : in std_logic_vector (7 downto 0);

		-------------------------------------------
		-- control lines --------------------------
		-------------------------------------------
		-- DAV line
		DAV_line : in std_logic;
		-- NRFD line
		NRFD_line : in std_logic;
		-- NDAC line
		NDAC_line : in std_logic;
		-- ATN line
		ATN_line : in std_logic;
		-- EOI line
		EOI_line : in std_logic;
		-- SRQ line
		SRQ_line : in std_logic;
		-- IFC line
		IFC_line : in std_logic;
		-- REN line
		REN_line : in std_logic;

		-------------------------------------------
		-- internal settiongs ---------------------
		-------------------------------------------
		-- eos mark
		eosMark : in std_logic_vector (7 downto 0);
		-- eos used
		eosUsed : in std_logic;
		-- my listen address
		myListAddr : in std_logic_vector (4 downto 0);
		-- my talk address
		myTalkAddr : in std_logic_vector (4 downto 0);
		-- secondary address detected
		secAddrDetected : in std_logic;

		-------------------------------------------
		-- internal states ------------------------
		-------------------------------------------
		-- serial poll active state (T or TE)
		SPAS : in std_logic;

		-------------------------------------------
		-- single line commands -------------------
		-------------------------------------------
		-- attention
		ATN : out std_logic;
		-- data accepted
		DAC : out std_logic;
		-- data valid
		DAV : out std_logic;
		-- end
		END_c : out std_logic;
		-- identify
		IDY : out std_logic;
		-- interface clear
		IFC : out std_logic;
		-- remote enable
		REN : out std_logic;
		-- ready for data
		RFD : out std_logic;
		-- service request
		SRQ : out std_logic;

		-------------------------------------------
		-- multi line commands --------------------
		-------------------------------------------
		-- addressed command group
		ACG : out std_logic;
		-- data byte
		DAB : out std_logic;
		-- device clear
		DCL : out std_logic;
		-- end of string
		EOS : out std_logic;
		-- group execute trigger
		GET : out std_logic;
		-- go to local
		GTL : out std_logic;
		-- listen address group
		LAG : out std_logic;
		-- local lockout
		LLO : out std_logic;
		-- my listen address
		MLA : out std_logic;
		-- my talk address
		MTA : out std_logic;
		-- my secondary address
		MSA : out std_logic;
		-- null byte
		NUL : out std_logic;
		-- other secondary address
		OSA : out std_logic;
		-- other talk address
		OTA : out std_logic;
		-- primary command group
		PCG : out std_logic;
		-- parallel poll configure
		PPC : out std_logic;
		-- parallel poll enable
		PPE : out std_logic;
		-- parallel poll disable
		PPD : out std_logic;
		-- parallel poll response
		PPR : out std_logic;
		-- parallel poll unconfigure
		PPU : out std_logic;
		-- request service
		RQS : out std_logic;
		-- secondary command group
		SCG : out std_logic;
		-- selected device clear
		SDC : out std_logic;
		-- serial poll disable
		SPD : out std_logic;
		-- serial poll enable
		SPE : out std_logic;
		-- status byte
		STB : out std_logic;
		-- talk address group
		TAG : out std_logic;
		-- take control
		TCT : out std_logic;
		-- universal command group
		UCG : out std_logic;
		-- unlisten
		UNL : out std_logic;
		-- untalk
		UNT : out std_logic
	);
end commandDecoder;

architecture arch of commandDecoder is

	signal ATN_int, IDY_int : std_logic;
	signal SCG_int, MSA_int, TAG_int, MTA_int, ACG_int, UCG_int,
		LAG_int, STB_int : std_logic;

begin

	--------------------------------------
	-- single line
	--------------------------------------
	ATN_int <= ATN_line;
	ATN <= ATN_int;
	----------------------
	DAC <= not NDAC_line;
	----------------------
	DAV <= DAV_line;
	----------------------
	END_c <= not ATN_line and EOI_line;
	----------------------
	IDY_int <= ATN_line and EOI_line;
	IDY <= IDY_int;
	----------------------
	IFC <= IFC_line;
	----------------------
	REN <= REN_line;
	----------------------
	RFD <= not NRFD_line;
	----------------------
	SRQ <= SRQ_line;

	---------------------------------------
	-- multiple line
	---------------------------------------
	ACG_int <= ATN_int and to_stdl(DI(6 downto 4) = "000");
	ACG <= ACG_int;
	---------------------------------------
	DAB <= not ATN_int and ((eosUsed and to_stdl(DI /= eosMark)) or not eosUsed);
	---------------------------------------
	DCL <= ATN_int and to_stdl(DI(6 downto 0) = "0010100");
	---------------------------------------
	EOS <= not ATN_int and eosUsed and to_stdl(DI = eosMark);
	---------------------------------------
	GET <= ATN_int and to_stdl(DI(6 downto 0) = "0001000");
	---------------------------------------
	GTL <= ATN_int and to_stdl(DI(6 downto 0) = "0000001");
	---------------------------------------
	LAG_int <= ATN_int and to_stdl(DI(6 downto 5) = "01");
	LAG <= LAG_int;
	---------------------------------------
	LLO <= ATN_int and to_stdl(DI(6 downto 0) = "0010001");
	---------------------------------------
	MLA <= LAG_int and to_stdl(DI(4 downto 0) = myListAddr);
	---------------------------------------
	MTA_int <= TAG_int and to_stdl(DI(4 downto 0) = myTalkAddr);
	MTA <= MTA_int;
	---------------------------------------
	MSA_int <= SCG_int and secAddrDetected;
	MSA <= MSA_int;
	---------------------------------------
	NUL <= ATN_int and to_stdl(DI = "00000000");
	---------------------------------------
	OSA <= SCG_int and not MSA_int;
	---------------------------------------
	OTA <= TAG_int and not MTA_int;
	---------------------------------------
	PCG <= ACG_int or UCG_int or LAG_int or TAG_int;
	---------------------------------------
	PPC <= ATN_int and to_stdl(DI(6 downto 0) = "0000101");
	---------------------------------------
	PPE <= ATN_int and to_stdl(DI(6 downto 4) = "110");
	---------------------------------------
	PPD <= ATN_int and to_stdl(DI(6 downto 4) = "111"); -- "-1110000" ?
	---------------------------------------
	PPR <= ATN_int and IDY_int;
	---------------------------------------
	PPU <= ATN_int and to_stdl(DI(6 downto 0) = "0010101");
	---------------------------------------
	RQS <= STB_int and to_stdl(DI(6) = '1');
	---------------------------------------
	SCG_int <= ATN_int and to_stdl(DI(6 downto 5) = "11");
	SCG <= SCG_int;
	---------------------------------------
	SDC <= ATN_int and to_stdl(DI(6 downto 0) = "0000100");
	---------------------------------------
	SPD <= ATN_int and to_stdl(DI(6 downto 0) = "0011001");
	---------------------------------------
	SPE <= ATN_int and to_stdl(DI(6 downto 0) = "0011000");
	---------------------------------------
	STB_int <= not ATN_int and SPAS;
	STB <= STB_int;
	---------------------------------------
	TAG_int <= ATN_int and to_stdl(DI(6 downto 5) = "10");
	TAG <= TAG_int;
	---------------------------------------
	TCT <= ATN_int and to_stdl(DI(6 downto 0) = "0001001");
	---------------------------------------
	UCG_int <= ATN_int and to_stdl(DI(6 downto 4) = "001");
	UCG <= UCG_int;
	---------------------------------------
	UNL <= ATN_int and to_stdl(DI(6 downto 0) = "0111111");
	---------------------------------------
	UNT <= ATN_int and to_stdl(DI(6 downto 0) = "1011111");

end arch;

