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
-- Entity: 	components
-- Date:	23:15 10/12/2011
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package gpibComponents is

	component if_func_AH is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			pon : in std_logic; -- power on
			rdy : in std_logic; -- ready for next message
			tcs : in std_logic; -- take control synchronously
			-- state inputs
			LACS : in std_logic; -- listener active state
			LADS : in std_logic; -- listener addressed state
			-- interface inputs
			ATN : in std_logic; -- attention
			DAV : in std_logic; -- data accepted
			-- interface outputs
			RFD : out std_logic; -- ready for data
			DAC : out std_logic; -- data accepted
			-- reported state
			ANRS : out std_logic; -- acceptor not ready state
			ACDS : out std_logic -- accept data state
		);
	end component;

	component if_func_SH is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			-- settingd
			T1 : in std_logic_vector (7 downto 0);
			-- local commands
			pon : in std_logic; -- power on
			nba : in std_logic; -- new byte available
			-- state inputs
			TACS : in std_logic; -- talker active state
			SPAS : in std_logic; -- seriall poll active state
			CACS : in std_logic; -- controller active state
			CTRS : in std_logic; -- controller transfer state
			-- interface inputs
			ATN : in std_logic; -- attention
			DAC : in std_logic; -- data accepted
			RFD : in std_logic; -- ready for data
			-- remote instructions
			DAV : out std_logic; -- data address valid
			-- device outputs
			wnc : out std_logic; -- wait for new cycle
			-- reported states
			STRS : out std_logic; -- source transfer state
			SDYS : out std_logic -- source delay state
		);
	end component;
	
	component if_func_L_LE is
		port(
			-- clock
			clk : in std_logic; -- clock
			-- function settings
			isLE : in std_logic;
			-- local commands
			pon : in std_logic; -- power on
			ltn : in std_logic; -- listen
			lun : in std_logic; -- local unlisten
			lon : in std_logic; -- listen only
			-- state inputs
			ACDS : in std_logic; -- accept data state (AH)
			CACS : in std_logic; -- controller active state (C)
			TPAS : in std_logic; -- talker primary address state (T)
			-- remote commands
			ATN : in std_logic; -- attention
			IFC : in std_logic; -- interface clear
			MLA : in std_logic; -- my listen address
			MTA : in std_logic; -- my talk address
			UNL : in std_logic; -- unlisten
			PCG : in std_logic; -- primary command group
			MSA : in std_logic; -- my secondary address
			-- reported states
			LACS : out std_logic; -- listener active state
			LADS : out std_logic; -- listener addressed state
			LPAS : out std_logic -- listener primary addressed state
			;debug1 : out std_logic
		);
	end component;

	component if_func_T_TE is
		port(
			-- clock
			clk : in std_logic; -- clock
			-- function settings
			isTE : in std_logic;
			-- local instruction inputs
			pon : in std_logic; -- power on
			ton : in std_logic; -- talk only
			endOf : in std_logic; -- end of byte string
			-- state inputs
			ACDS : in std_logic; -- accept data state (AH)
			APRS : in std_logic; -- affirmative poll response
			LPAS : in std_logic; -- listener primary state (LE)
			-- remote instruction inputs
			ATN : in std_logic; -- attention
			IFC : in std_logic; -- interface clear
			SPE : in std_logic; -- serial poll enable
			SPD : in std_logic; -- serial poll disable
			MTA : in std_logic; -- my talk address
			OTA : in std_logic; -- other talk address
			MLA : in std_logic; -- my listen address
			OSA : in std_logic; -- other secondary address
			MSA : in std_logic; -- my secondary address
			PCG : in std_logic; -- primary command group
			-- remote instruction outputs
			END_OF : out std_logic; -- end of data
			RQS : out std_logic; -- data accepted
			DAB : out std_logic; -- data byte
			EOS : out std_logic; -- end of string
			STB : out std_logic; -- status byte
			-- local instruction outputs
			tac : out std_logic; -- talker active
			-- reported states
			SPAS : out std_logic; -- serial poll active state
			TPAS : out std_logic; -- transmitter active state
			TADS : out std_logic; -- talker addressed state
			TACS : out std_logic -- talker active state
		);
	end component;

	component if_func_C is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			pon : in std_logic; -- power on
			gts : in std_logic; -- go to standby
			rpp : in std_logic; -- request parallel poll
			tcs : in std_logic; -- take control synchronously
			tca : in std_logic; -- take control asynchronously
			sic : in std_logic; -- send interface clear
			rsc : in std_logic; -- request system control
			sre : in std_logic; -- send remote enable
			-- state inputs
			TADS : in std_logic; -- talker addressed state (T or TE)
			ACDS : in std_logic; -- accept data state (AH)
			ANRS : in std_logic; -- acceptor not ready state (AH)
			STRS : in std_logic; -- source transfer state (SH)
			SDYS : in std_logic; -- source delay state (SH)
			-- command inputs
			ATN_in : in std_logic; -- attention
			IFC_in : in std_logic; -- interface clear
			TCT_in : in std_logic; -- take control
			SRQ_in : in std_logic; -- service request
			-- command outputs
			ATN_out : out std_logic; -- attention
			IFC_out : out std_logic; -- interface clear
			TCT_out : out std_logic; -- take control
			IDY_out : out std_logic; -- identify
			REN_out : out std_logic; -- remote enable
			-- reported states
			CACS : out std_logic; -- controller active state
			CTRS : out std_logic; -- controller transfer state
			CSBS : out std_logic; -- controller standby state
			CPPS : out std_logic; -- controller parallel poll state
			CSRS : out std_logic; -- controller service requested state
			SACS : out std_logic -- system control active state
		);
	end component;

	component if_func_DC is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			-- state inputs
			LADS : in std_logic; -- listener addressed state (L or LE)
			ACDS : in std_logic; -- accept data state (AH)
			-- instructions
			DCL : in std_logic; -- my listen address
			SDC : in std_logic; -- unlisten
			-- local instructions
			clr : out std_logic -- clear device
		);
	end component;

	component if_func_DT is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			-- state inputs
			LADS : in std_logic; -- listener addressed state (L or LE)
			ACDS : in std_logic; -- accept data state (AH)
			-- instructions
			GET : in std_logic; -- group execute trigger
			-- local instructions
			trg : out std_logic -- trigger
		);
	end component;

	component if_func_PP is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			-- settings
			lpeUsed : std_logic;
			fixedPpLine : in std_logic_vector (2 downto 0);
			-- local commands
			pon : in std_logic; -- power on
			lpe : in std_logic; -- local poll enable
			ist : in std_logic; -- individual status
			-- state inputs
			ACDS : in std_logic; -- accept data state
			LADS : in std_logic; -- listener address state (L or LE)
			-- data input
			dio_data : in std_logic_vector(3 downto 0); -- byte from data lines
			-- remote command inputs
			IDY : in std_logic; -- identify
			PPE : in std_logic; -- parallel poll enable
			PPD : in std_logic; -- parallel poll disable
			PPC : in std_logic; -- parallel poll configure
			PPU : in std_logic; -- parallel poll unconfigure
			PCG : in std_logic; -- primary command group
			-- remote command outputs
			PPR : out std_logic; -- paralel poll response
			-- PPR command data
			ppBitValue : out std_logic; -- bit value
			ppLineNumber : out std_logic_vector (2 downto 0);
			-- reported states
			PPAS : out std_logic -- parallel poll active state
		);
	end component;

	component if_func_RL is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			pon : in std_logic; -- power on
			rtl : in std_logic; -- return to local
			-- state inputs
			ACDS : in std_logic; -- listener active state (AH)
			LADS : in std_logic; -- listener addressed state (L or LE)
			-- instructions
			REN : in std_logic; -- remote enable
			LLO : in std_logic; -- local lockout
			MLA : in std_logic; -- my listen address
			GTL : in std_logic; -- go to local
			-- reported state
			LOCS : out std_logic; -- local state
			LWLS : out std_logic -- local with lockout state
		);
	end component;

	component if_func_SR is
		port(
			-- device inputs
			clk : in std_logic; -- clock
			pon : in std_logic; -- power on
			rsv : in std_logic; -- service request
			-- state inputs
			SPAS : in std_logic; -- serial poll active state (T or TE)
			-- output instructions
			SRQ : out std_logic; -- service request
			-- reported states
			APRS : out std_logic -- affirmative poll response state
		);
	end component;

	component commandEcoder is
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
	end component;

	component commandDecoder is
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
	end component;

	component SecondaryAddressDecoder is
		port (
			-- secondary address mask
			secAddrMask : in std_logic_vector (31 downto 0);
			-- data input
			DI : in std_logic_vector (4 downto 0);
			-- secondary address detected
			secAddrDetected : out std_logic
		);
	end component;

	component SecAddrSaver is
		port (
			reset : in std_logic;
			------------------- gpib ----------------------
			TADS : in std_logic;
			TPAS : in std_logic;
			LADS : in std_logic;
			LPAS : in std_logic;
			MSA_Dec : in std_logic;
			DI : in std_logic_vector(4 downto 0);
			currentSecAddr : out std_logic_vector(4 downto 0)
		);
	end component;

	component gpibInterface is port (
		clk : in std_logic;
		reset : std_logic;
		-- application interface
		isLE : in std_logic;
		isTE : in std_logic;
		lpeUsed : in std_logic;
		fixedPpLine : in std_logic_vector (2 downto 0);
		eosUsed : in std_logic;
		eosMark : in std_logic_vector (7 downto 0);
		myListAddr : in std_logic_vector (4 downto 0);
		myTalkAddr : in std_logic_vector (4 downto 0);
		secAddrMask : in std_logic_vector (31 downto 0);
		data : in std_logic_vector (7 downto 0);
		status_byte : in std_logic_vector (7 downto 0);
		T1 : in std_logic_vector (7 downto 0);
		-- local commands to interface
		rdy : in std_logic; -- ready for next message (AH)
		nba : in std_logic; -- new byte available (SH)
		ltn : in std_logic; -- listen (L, LE)
		lun : in std_logic; -- local unlisten (L, LE)
		lon : in std_logic; -- listen only (L, LE)
		ton : in std_logic; -- talk only (T, TE)
		endOf : in std_logic; -- end of byte string (T, TE)
		gts : in std_logic; -- go to standby (C)
		rpp : in std_logic; -- request parallel poll (C)
		tcs : in std_logic; -- take control synchronously (C, AH)
		tca : in std_logic; -- take control asynchronously (C)
		sic : in std_logic; -- send interface clear (C)
		rsc : in std_logic; -- request system control (C)
		sre : in std_logic; -- send remote enable (C)
		rtl : in std_logic; -- return to local (RL)
		rsv : in std_logic; -- request service (SR)
		ist : in std_logic; -- individual status (PP)
		lpe : in std_logic; -- local poll enable (PP)
		
		-- local commands from interface
		dvd : out std_logic; -- data valid (AH)
		wnc : out std_logic; -- wait for new cycle (SH)
		tac : out std_logic; -- talker active (T, TE)
		lac : out std_logic; -- listener active (L, LE)
		cwrc : out std_logic; -- controller write commands
		cwrd : out std_logic; -- controller write data
		clr : out std_logic; -- clear device (DC)
		trg : out std_logic; -- trigger device (DT)
		atl : out std_logic; -- addressed to listen (T or TE)
		att : out std_logic; -- addressed to talk(L or LE)
		mla : out std_logic; -- my listen addres decoded (L or LE)
		lsb : out std_logic; -- last byte
		spa : out std_logic; -- seriall poll active
		ppr : out std_logic; -- parallel poll ready
		sreq : out std_logic; -- service requested
		isLocal : out std_logic; -- device is local controlled
		currentSecAddr : out std_logic_vector (4 downto 0); -- current sec addr
		-- interface signals
		DI : in std_logic_vector (7 downto 0);
		DO : out std_logic_vector (7 downto 0);
		output_valid : out std_logic;
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
		;debug1 : out std_logic
	);
	end component;

end gpibComponents;