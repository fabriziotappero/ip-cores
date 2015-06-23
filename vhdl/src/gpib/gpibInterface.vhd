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
-- Entity: 	gpibInterface
-- Date:	13:34 15/10/2011
-- Author: Andrzej Paluch
--------------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;

use work.gpibComponents.all;

entity gpibInterface is
	port (
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
end gpibInterface;

architecture Behavioral of gpibInterface is

	-- function states
	signal LACS, LADS, SPAS, TACS, CACS, CSBS, CPPS, CTRS, CSRS, SACS, ACDS,
		TPAS, APRS, LPAS, TADS, ANRS, STRS, SDYS, PPAS, LOCS, LWLS : std_logic;

	-- decoded remote commands
	signal ATN_dec, DAC_dec, DAV_dec, END_c_dec, IDY_dec, IFC_dec, REN_dec,
		RFD_dec, SRQ_dec : std_logic;
	signal ACG_dec, DAB_dec, DCL_dec, EOS_dec, GET_dec, GTL_dec, LAG_dec,
		LLO_dec, MLA_dec, MTA_dec, MSA_dec, NUL_dec, OSA_dec, OTA_dec, PCG_dec,
		PPC_dec, PPE_dec, PPD_dec, PPR_dec, PPU_dec, RQS_dec, SCG_dec, SDC_dec,
		SPD_dec, SPE_dec, STB_dec, TAG_dec, TCT_dec, UCG_dec, UNL_dec,
		UNT_dec : std_logic;
	
	-- encoded remote commands
	signal ATN_enc, DAC_enc, RFD_enc, DAV_enc, END_OF_enc, IFC_enc, IDY_enc,
		REN_enc, RQS_enc, DAB_enc, EOS_enc, STB_enc, TCT_enc, SRQ_enc,
		PPR_enc : std_logic;

	-- PPR command data
	signal ppBitValue : std_logic;
	signal ppLineNumber : std_logic_vector (2 downto 0);

	-- internal signals
	signal secAddrDetected : std_logic;

begin

	dvd <= ACDS;
	cwrc <= CACS;
	cwrd <= CSBS;
	atl <= LADS or LACS;
	lac <= LACS;
	att <= TACS or TADS or SPAS;
	mla <= MLA_dec;
	lsb <= ((eosUsed and EOS_dec) or END_c_dec) and ACDS; -- dvd = ACDS
	spa <= SPAS;
	ppr <= CPPS;
	sreq <= CSRS and SACS;
	isLocal <= LOCS or LWLS;


	-- acceptor handshake
	AH: if_func_AH port map(
		clk => clk,
		-----------------------------------------------------------------------
		pon => reset, rdy => rdy, tcs => tcs,
		-----------------------------------------------------------------------
		LACS => LACS, LADS => LADS,
		-----------------------------------------------------------------------
		ATN => ATN_dec, DAV => DAV_dec,
		-----------------------------------------------------------------------
		RFD => RFD_enc, DAC=> DAC_enc,
		-----------------------------------------------------------------------
		ANRS => ANRS, ACDS => ACDS
	);

	-- source handshake
	SH: if_func_SH port map(
		clk => clk,
		-----------------------------------------------------------------------
		T1 => T1,
		-----------------------------------------------------------------------
		pon => reset, nba => nba,
		-----------------------------------------------------------------------
		TACS => TACS, SPAS => SPAS, CACS => CACS, CTRS => CTRS,
		-----------------------------------------------------------------------
		ATN => ATN_dec, DAC => DAC_dec, RFD => RFD_dec,
		-----------------------------------------------------------------------
		DAV => DAV_enc,
		-----------------------------------------------------------------------
		wnc => wnc,
		-----------------------------------------------------------------------
		STRS => STRS, SDYS => SDYS
	);

	-- listener, extended listener
	L_LE: if_func_L_LE port map(
		clk => clk,
		-----------------------------------------------------------------------
		isLE => isLE,
		-----------------------------------------------------------------------
		pon => reset, ltn => ltn, lun => lun, lon => lon,
		-----------------------------------------------------------------------
		ACDS => ACDS, CACS => CACS, TPAS => TPAS,
		-----------------------------------------------------------------------
		ATN => ATN_dec, IFC => IFC_dec, MLA => MLA_dec, MTA => MTA_dec,
		UNL => UNL_dec, PCG => PCG_dec, MSA => MSA_dec,
		-----------------------------------------------------------------------
		LACS => LACS, LADS => LADS, LPAS => LPAS, debug1 => debug1
	);

	-- talker, extended talker
	T_TE: if_func_T_TE port map(
		clk => clk,
		-----------------------------------------------------------------------
		isTE => isTE,
		-----------------------------------------------------------------------
		pon => reset, ton => ton, endOf => endOf,
		-----------------------------------------------------------------------
		ACDS => ACDS, APRS => APRS, LPAS => LPAS,
		-----------------------------------------------------------------------
		ATN => ATN_dec, IFC => IFC_dec, SPE => SPE_dec, SPD => SPD_dec,
		MTA => MTA_dec, OTA => OTA_dec, MLA => MLA_dec, OSA => OSA_dec,
		MSA => MSA_dec, PCG => PCG_dec,
		-----------------------------------------------------------------------
		END_OF => END_OF_enc, RQS => RQS_enc, DAB => DAB_enc, EOS => EOS_enc,
		STB => STB_enc,
		-----------------------------------------------------------------------
		tac => tac,
		-----------------------------------------------------------------------
		SPAS => SPAS, TPAS => TPAS, TADS => TADS, TACS => TACS
	);

	-- controller
	C: if_func_C  port map(
		clk => clk,
		-----------------------------------------------------------------------
		pon => reset, gts => gts, rpp => rpp, tcs => tcs, tca => tca,
		sic => sic, rsc => rsc, sre => sre,
		-----------------------------------------------------------------------
		TADS => TADS, ACDS => ACDS, ANRS => ANRS, STRS => STRS, SDYS => SDYS,
		-----------------------------------------------------------------------
		ATN_in => ATN_dec, IFC_in => IFC_dec, TCT_in => TCT_dec,
		SRQ_in => SRQ_dec,
		-----------------------------------------------------------------------
		ATN_out => ATN_enc, IFC_out => IFC_enc, TCT_out => TCT_enc,
		IDY_out => IDY_enc, REN_out => REN_enc,
		-----------------------------------------------------------------------
		CACS => CACS, CTRS => CTRS, CSBS => CSBS, CPPS => CPPS, CSRS => CSRS,
		SACS => SACS
	);

	-- device clear
	DC: if_func_DC port map(
		clk => clk,
		-----------------------------------------------------------------------
		LADS => LADS, ACDS => ACDS,
		-----------------------------------------------------------------------
		DCL => DCL_dec, SDC => SDC_dec,
		-----------------------------------------------------------------------
		clr => clr
	);

	-- device trigger
	DT: if_func_DT port map(
		clk => clk,
		-----------------------------------------------------------------------
		LADS => LADS, ACDS => ACDS,
		-----------------------------------------------------------------------
		GET => GET_dec,
		-----------------------------------------------------------------------
		trg => trg
	);

	PP: if_func_PP port map(
		clk => clk,
		-----------------------------------------------------------------------
		lpeUsed => lpeUsed, fixedPpLine => fixedPpLine,
		-----------------------------------------------------------------------
		pon => reset, lpe => lpe, ist => ist,
		-----------------------------------------------------------------------
		ACDS => ACDS, LADS => LADS,
		-----------------------------------------------------------------------
		dio_data => DI(3 downto 0),
		-----------------------------------------------------------------------
		IDY => IDY_dec, PPE => PPE_dec, PPD => PPD_dec, PPC => PPC_dec,
		PPU => PPU_dec, PCG => PCG_dec,
		-----------------------------------------------------------------------
		PPR => PPR_enc, ppBitValue => ppBitValue, ppLineNumber => ppLineNumber,
		-----------------------------------------------------------------------
		PPAS => PPAS
	);

	RL: if_func_RL port map(
		clk => clk,
		-----------------------------------------------------------------------
		pon => reset, rtl => rtl,
		-----------------------------------------------------------------------
		ACDS => ACDS, LADS => LADS,
		-----------------------------------------------------------------------
		REN => REN_dec, LLO => LLO_dec, MLA => MLA_dec, GTL => GTL_dec,
		-----------------------------------------------------------------------
		LOCS => LOCS, LWLS => LWLS
	);

	SR: if_func_SR port map(
		clk => clk,
		-----------------------------------------------------------------------
		pon => reset, rsv => rsv,
		-----------------------------------------------------------------------
		SPAS => SPAS,
		-----------------------------------------------------------------------
		SRQ => SRQ_enc,
		-----------------------------------------------------------------------
		APRS => APRS
	);

	COMM_ENC: commandEcoder port map (
			data => data, status_byte => status_byte,
			-------------------------------------------------------------------
			ppBitValue => ppBitValue, ppLineNumber => ppLineNumber,
			-------------------------------------------------------------------
			APRS => APRS, CACS => CACS,
			-------------------------------------------------------------------
			ATN => ATN_enc, END_OF => END_OF_enc, IDY => IDY_enc,
			DAC => DAC_enc, RFD => RFD_enc, DAV => DAV_enc, IFC => IFC_enc,
			REN => REN_enc, SRQ => SRQ_enc, DAB => DAB_enc, EOS => EOS_enc,
			RQS => RQS_enc, STB => STB_enc, TCT => TCT_enc, PPR => PPR_enc,
			-------------------------------------------------------------------
			DO => DO, output_valid => output_valid,
			-------------------------------------------------------------------
			DAV_line => DAV_out, NRFD_line => NRFD_out, NDAC_line => NDAC_out,
			ATN_line => ATN_out, EOI_line => EOI_out, SRQ_line => SRQ_out,
			IFC_line => IFC_out, REN_line => REN_out
	);

	-- command decoder
	COMM_DEC: commandDecoder port map (
		DI => DI, DAV_line => DAV_in, NRFD_line => NRFD_in,
		NDAC_line => NDAC_in, ATN_line => ATN_in, EOI_line => EOI_in,
		SRQ_line => SRQ_in, IFC_line => IFC_in, REN_line => REN_in,
		-----------------------------------------------------------------------
		eosMark => eosMark, eosUsed =>eosUsed, myListAddr => myListAddr,
		myTalkAddr => myTalkAddr, secAddrDetected => secAddrDetected,
		-----------------------------------------------------------------------
		SPAS => SPAS,
		-----------------------------------------------------------------------
		ATN => ATN_dec, DAC => DAC_dec, DAV => DAV_dec, END_c => END_c_dec,
		IDY => IDY_dec, IFC => IFC_dec, REN => REN_dec, RFD => RFD_dec,
		SRQ => SRQ_dec,
		-----------------------------------------------------------------------
		ACG => ACG_dec, DAB => DAB_dec, DCL => DCL_dec, EOS => EOS_dec,
		GET => GET_dec, GTL => GTL_dec, LAG => LAG_dec, LLO => LLO_dec,
		MLA => MLA_dec, MTA => MTA_dec, MSA => MSA_dec, NUL => NUL_dec,
		OSA => OSA_dec, OTA => OTA_dec, PCG => PCG_dec, PPC => PPC_dec,
		PPE => PPE_dec, PPD => PPD_dec, PPR => PPR_dec, PPU => PPU_dec,
		RQS => RQS_dec, SCG => SCG_dec, SDC => SDC_dec, SPD => SPD_dec,
		SPE => SPE_dec, STB => STB_dec, TAG => TAG_dec, TCT => TCT_dec,
		UCG => UCG_dec, UNL => UNL_dec, UNT => UNT_dec
	);

	SECAD: SecondaryAddressDecoder port map (
		secAddrMask => secAddrMask, DI => DI(4 downto 0),
		secAddrDetected => secAddrDetected
	);

	SECADS: SecAddrSaver port map (
		reset => reset,
		TADS => TADS, TPAS => TPAS, LADS => LADS, LPAS => LPAS,
		MSA_Dec => MSA_Dec, DI => DI(4 downto 0),
		currentSecAddr => currentSecAddr
	);

end Behavioral;

