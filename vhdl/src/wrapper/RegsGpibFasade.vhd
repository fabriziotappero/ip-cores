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
-- Entity: RegsGpibFasade
-- Date:2011-11-17  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.gpibComponents.all;
use work.helperComponents.all;
use work.wrapperComponents.all;


entity RegsGpibFasade is
	port (
		reset : std_logic;
		clk : in std_logic;
		-----------------------------------------------------------------------
		------------ GPIB interface signals -----------------------------------
		-----------------------------------------------------------------------
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
		REN_out : out std_logic;
		-----------------------------------------------------------------------
		---------------- registers access -------------------------------------
		-----------------------------------------------------------------------
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0);
		reg_addr : in std_logic_vector(14 downto 0);
		strobe_read : in std_logic;
		strobe_write : in std_logic;
		-----------------------------------------------------------------------
		---------------- additional lines -------------------------------------
		-----------------------------------------------------------------------
		interrupt_line : out std_logic
		;debug1 : out std_logic
		;debug2 : out std_logic
	);
end RegsGpibFasade;

architecture arch of RegsGpibFasade is

	constant MEM_NATIVE_DATA_WIDTH : integer := 16;

	-- gpib
	signal g_isLE, g_isTE : std_logic;
	signal g_lpeUsed : std_logic;
	signal g_fixedPpLine : std_logic_vector (2 downto 0);
	signal g_eosUsed : std_logic;
	signal g_eosMark : std_logic_vector (7 downto 0);
	signal g_myListAddr, g_myTalkAddr : std_logic_vector (4 downto 0);
	signal g_secAddrMask : std_logic_vector (31 downto 0);
	signal g_data : std_logic_vector (7 downto 0);
	signal g_status_byte : std_logic_vector (7 downto 0);
	signal g_T1 : std_logic_vector (7 downto 0);
	signal g_rdy, g_nba, g_ltn, g_lun, g_lon, g_ton, g_endOf, g_gts, g_rpp,
		g_tcs, g_tca, g_sic, g_rsc, g_sre, g_rtl, g_rsv, g_ist, g_lpe, g_dvd,
		g_wnc, g_tac, g_lac, g_cwrc, g_cwrd, g_clr, g_trg, g_atl, g_att, g_mla,
		g_lsb, g_spa, g_ppr, g_sreq, g_isLocal : std_logic;
	signal g_currentSecAddr : std_logic_vector (4 downto 0);
	signal g_output_valid : std_logic;
	signal g_ATN_out : std_logic;

	-- reader
	signal r_isLE : std_logic;
	signal r_dataSecAddr : std_logic_vector (4 downto 0);
	signal r_buf_interrupt : std_logic;
	signal r_data_available : std_logic;
	signal r_end_of_stream : std_logic;
	signal r_reset_buffer : std_logic;
	signal r_strobe : std_logic;
	signal r_fifo_full : std_logic;
	signal r_fifo_ready_to_write : std_logic;
	signal r_at_least_one_byte_in_fifo : std_logic;

	-- writer
	signal w_isTE : std_logic;
	signal w_dataSecAddr : std_logic_vector (4 downto 0);
	signal w_end_of_stream : std_logic;
	signal w_data_available : std_logic;
	signal w_buf_interrupt : std_logic;
	signal w_reset_buffer : std_logic;

	-- serial poll coordinator
	signal s_rec_stb : std_logic;
	signal s_stb_received : std_logic;

	-- reader fifo
	signal rm_reset : std_logic;
	signal rm_byte_in : std_logic_vector(7 downto 0);
	signal rm_byte_out : std_logic_vector(15 downto 0);
	-------------- fifo --------------------
	signal rm_availableBytesCount : std_logic_vector(10 downto 0);
	signal rm_strobe_read : std_logic;

	-- writer fifo
	signal wm_reset : std_logic;
	signal wm_write_strobe : std_logic;
	signal wm_data_in : std_logic_vector(15 downto 0);
	signal wm_byte_in : std_logic_vector(7 downto 0);
	signal wm_ready_to_read : std_logic;
	signal wm_bytesAvailable : std_logic;
	signal wm_availableBytesCount : std_logic_vector(10 downto 0);
	signal wm_bufferFull : std_logic;
	signal wm_ready_to_write : std_logic;
	signal wm_strobe_read : std_logic;

	-- settings reg
	signal set0_strobe : std_logic;
	signal set0_data_in, set0_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);
	signal set1_strobe : std_logic;
	signal set1_data_in, set1_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);
	signal set0_isLE_TE : std_logic;
	signal set1_myAddr : std_logic_vector(4 downto 0);

	-- sec addr mask reg
	signal sec0_strobe : std_logic;
	signal sec0_data_in, sec0_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);
	signal sec0_secAddrMask :
		std_logic_vector ((MEM_NATIVE_DATA_WIDTH-1) downto 0);
	signal sec1_strobe : std_logic;
	signal sec1_data_in, sec1_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);
	signal sec1_secAddrMask :
		std_logic_vector ((MEM_NATIVE_DATA_WIDTH-1) downto 0);

	-- gpib bus reg
	signal gbs_data_out : std_logic_vector ((MEM_NATIVE_DATA_WIDTH-1) downto 0);

	-- event reg
	signal ev_strobe : std_logic;
	signal ev_data_in, ev_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);

	-- gpib status
	signal gs_data_out : std_logic_vector ((MEM_NATIVE_DATA_WIDTH-1) downto 0);

	-- gpib control reg
	signal gc_strobe : std_logic;
	signal gc_data_in, gc_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);

	-- reader control reg
	signal rc0_strobe : std_logic;
	signal rc0_data_in, rc0_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);
	signal rc1_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);

	-- writer control reg
	signal wc0_strobe : std_logic;
	signal wc0_data_in, wc0_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);
	signal wc0_status_byte : std_logic_vector (6 downto 0);
	signal wc1_strobe : std_logic;
	signal wc1_data_in, wc1_data_out :
		std_logic_vector((MEM_NATIVE_DATA_WIDTH-1) downto 0);

begin

	debug1 <= g_nba;
	debug2 <= g_wnc;

	-- settings reg
	g_isLE <= set0_isLE_TE;
	g_isTE <= set0_isLE_TE;
	r_isLE <= set0_isLE_TE;
	w_isTE <= set0_isLE_TE;
	g_myListAddr <= set1_myAddr;
	g_myTalkAddr <= set1_myAddr;
	-- sec addr reg
	g_secAddrMask (15 downto 0) <= sec0_secAddrMask;
	g_secAddrMask (31 downto 16) <= sec1_secAddrMask;
	
	g_status_byte(7) <= wc0_status_byte(6);
	g_status_byte(6) <= '0';
	g_status_byte(5 downto 0) <= wc0_status_byte(5 downto 0);

	-- writer fifo
	wm_reset <= w_reset_buffer;
	-- reader fifo
	rm_reset <= r_reset_buffer;

	gpib: gpibInterface port map (
		clk => clk, reset => reset,
		-- application interface
		isLE => g_isLE, isTE => g_isTE, lpeUsed => g_lpeUsed,
		fixedPpLine => g_fixedPpLine, eosUsed => g_eosUsed,
		eosMark => g_eosMark, myListAddr => g_myListAddr,
		myTalkAddr => g_myTalkAddr, secAddrMask => g_secAddrMask,
		data => g_data, status_byte => g_status_byte, T1 => g_T1,
		rdy => g_rdy, nba => g_nba, ltn => g_ltn, lun => g_lun, lon => g_lon,
		ton => g_ton, endOf => g_endOf, gts => g_gts, rpp => g_rpp,
		tcs => g_tcs, tca => g_tca, sic => g_sic, rsc => g_rsc, sre => g_sre,
		rtl => g_rtl, rsv => g_rsv, ist => g_ist, lpe => g_lpe,
		dvd => g_dvd, wnc => g_wnc, tac => g_tac, lac => g_lac, cwrc => g_cwrc,
		cwrd => g_cwrd, clr => g_clr, trg => g_trg, atl => g_atl, att => g_att,
		mla => g_mla, lsb => g_lsb, spa => g_spa, ppr => g_ppr, sreq => g_sreq,
		isLocal => g_isLocal, currentSecAddr => g_currentSecAddr,
		DI => DI, DO => DO, output_valid => g_output_valid,
		ATN_in => ATN_in, ATN_out => g_ATN_out, DAV_in => DAV_in,
		DAV_out => DAV_out, NRFD_in => NRFD_in, NRFD_out => NRFD_out,
		NDAC_in => NDAC_in, NDAC_out => NDAC_out, EOI_in => EOI_in,
		EOI_out => EOI_out, SRQ_in => SRQ_in, SRQ_out => SRQ_out,
		IFC_in => IFC_in, IFC_out => IFC_out, REN_in => REN_in,
		REN_out => REN_out, debug1 => open
	);

	reader: gpibReader port map (
		clk => clk, reset => reset,
		------------------------------------------------------------------------
		------ GPIB interface --------------------------------------------------
		------------------------------------------------------------------------
		data_in => DI, dvd => g_dvd, lac => g_lac, lsb => g_lsb,
		rdy => g_rdy,
		------------------------------------------------------------------------
		------ external interface ----------------------------------------------
		------------------------------------------------------------------------
		isLE => r_isLE, secAddr => g_currentSecAddr,
		dataSecAddr => r_dataSecAddr, buf_interrupt => r_buf_interrupt,
		end_of_stream => r_end_of_stream,
		reset_reader => r_reset_buffer,
		------------------ fifo --------------------------------------
		fifo_full => r_fifo_full, fifo_ready_to_write => r_fifo_ready_to_write,
		at_least_one_byte_in_fifo => r_at_least_one_byte_in_fifo,
		data_out => rm_byte_in, fifo_strobe => r_strobe
	);

	writer: gpibWriter port map (
		clk => clk, reset => reset,
		------------------------------------------------------------------------
		------ GPIB interface --------------------------------------------------
		------------------------------------------------------------------------
		data_out => g_data, wnc => g_wnc, spa => g_spa, nba => g_nba,
		endOf => g_endOf, tac => g_tac, cwrc => g_cwrc,
		------------------------------------------------------------------------
		------ external interface ----------------------------------------------
		------------------------------------------------------------------------
		isTE => w_isTE,
		secAddr => g_currentSecAddr, dataSecAddr => w_dataSecAddr,
		buf_interrupt => w_buf_interrupt, end_of_stream => w_end_of_stream,
		reset_writer => w_reset_buffer,
		writer_enable => w_data_available,
		---------------- fifo ---------------------------
		availableFifoBytesCount => wm_availableBytesCount,
		fifo_read_strobe => wm_strobe_read,
		fifo_ready_to_read => wm_ready_to_read,
		fifo_data_in => wm_byte_in
	);

	spc: SerialPollCoordinator port map (
		clk => clk, reset => reset,
		DAC => NDAC_in, rec_stb => s_rec_stb, ATN_in => g_ATN_out,
		ATN_out => ATN_out, output_valid_in => g_output_valid,
		output_valid_out => output_valid, stb_received => s_stb_received
	);

	readerFifo: Fifo8b port map (
		reset => reset, clk => clk,
		-------------- fifo --------------------
		bytesAvailable => r_at_least_one_byte_in_fifo,
		availableBytesCount => rm_availableBytesCount,
		bufferFull => r_fifo_full,
		resetFifo => rm_reset,
		----------------------------------------
		data_in => rm_byte_in, ready_to_write => r_fifo_ready_to_write,
		strobe_write => r_strobe,
		----------------------------------------
		data_out => rm_byte_out(7 downto 0), ready_to_read => r_data_available,
		strobe_read => rm_strobe_read
	);

	writerFifo: Fifo8b port map (
		reset => reset, clk => clk,
		-------------- fifo --------------------
		bytesAvailable => wm_bytesAvailable,
		availableBytesCount => wm_availableBytesCount,
		bufferFull => wm_bufferFull,
		resetFifo => wm_reset,
		----------------------------------------
		data_in => wm_data_in(7 downto 0),
		ready_to_write => wm_ready_to_write,
		strobe_write => wm_write_strobe,
		----------------------------------------
		data_out => wm_byte_in,
		ready_to_read => wm_ready_to_read,
		strobe_read => wm_strobe_read
	);

	--Clk2x_0: Clk2x port map (
	--	reset => reset,
	--	clk => clk,
	--	clk2x => clk2x
	--);

	set0: SettingsReg0 port map (
		reset => reset,
		strobe => set0_strobe, data_in => set0_data_in,
		data_out => set0_data_out,
		------------- gpib -----------------------------
		isLE_TE => set0_isLE_TE, lpeUsed => g_lpeUsed,
		fixedPpLine => g_fixedPpLine, eosUsed => g_eosUsed,
		eosMark => g_eosMark, lon => g_lon, ton => g_ton
	);

	set1: SettingsReg1 port map (
		reset => reset,
		strobe => set1_strobe, data_in => set1_data_in,
		data_out => set1_data_out,
		-- gpib
		myAddr => set1_myAddr, T1 => g_T1
	);

	sec0: SecAddrReg port map (
		reset => reset,
		strobe => sec0_strobe, data_in => sec0_data_in,
		data_out => sec0_data_out,
		-- gpib
		secAddrMask => sec0_secAddrMask
	);

	sec1: SecAddrReg port map (
		reset => reset,
		strobe => sec1_strobe, data_in => sec1_data_in,
		data_out => sec1_data_out,
		-- gpib
		secAddrMask => sec1_secAddrMask
	);

	gbs: gpibBusReg port map (
		data_out => gbs_data_out,
		----------- gpib ---------------------------------
		DIO => DI, ATN => ATN_in, DAV => DAV_in, NRFD => NRFD_in,
		NDAC => NDAC_in, EOI => EOI_in, SRQ => SRQ_in, IFC => IFC_in,
		REN => REN_in
	);

	ev: EventReg port map (
		reset => reset, clk => clk,
		strobe => ev_strobe, data_in => ev_data_in, data_out => ev_data_out,
		-------------------- gpib device ---------------------
		isLocal => g_isLocal, in_buf_ready => r_buf_interrupt,
		out_buf_ready => w_buf_interrupt, clr => g_clr, trg => g_trg,
		att => g_att, atl => g_atl, spa => g_spa,
		-------------------- gpib controller ---------------------
		cwrc => g_cwrc, cwrd => g_cwrd, srq => g_sreq, ppr => g_ppr,
		-- stb received
		stb_received => s_stb_received,
		REN => REN_in, ATN => ATN_in, IFC => IFC_in
	);

	gs: GpibStatusReg port map (
		data_out => gs_data_out,
		--------------------- gpib ---------------------
		currentSecAddr => g_currentSecAddr,
		att => g_att, tac => g_tac, atl => g_atl, lac => g_lac,
		cwrc => g_cwrc, cwrd => g_cwrd, spa => g_spa,
		isLocal => g_isLocal
	);

	gc: gpibControlReg port map (
			reset => reset,
			strobe => gc_strobe, data_in => gc_data_in,
			data_out => gc_data_out,
			------------------ gpib ------------------------
			ltn => g_ltn, lun => g_lun, rtl => g_rtl, rsv => g_rsv,
			ist => g_ist, lpe => g_lpe,
			------------------------------------------------
			rsc => g_rsc, sic => g_sic, sre => g_sre, gts => g_gts,
			tcs => g_tcs, tca => g_tca, rpp => g_rpp, rec_stb => s_rec_stb
		);

	rc0: ReaderControlReg0 port map (
		clk => clk, reset => reset,
		strobe => rc0_strobe, data_in => rc0_data_in, data_out => rc0_data_out,
		------------------- gpib -------------------------
		buf_interrupt => r_buf_interrupt, data_available => r_data_available,
		end_of_stream => r_end_of_stream, reset_buffer => r_reset_buffer,
		dataSecAddr => r_dataSecAddr
	);

	rc1: ReaderControlReg1 port map (
		data_out => rc1_data_out,
		------------------ gpib --------------------
		bytes_available_in_fifo => rm_availableBytesCount
	);

	wc0: WriterControlReg0 port map (
		clk => clk, reset => reset,
		strobe => wc0_strobe, data_in => wc0_data_in, data_out => wc0_data_out,
		------------------- gpib -------------------------
		buf_interrupt => w_buf_interrupt, data_available => w_data_available,
		end_of_stream => w_end_of_stream, reset_buffer => w_reset_buffer,
		dataSecAddr => w_dataSecAddr, status_byte => wc0_status_byte
	);

	wc1: WriterControlReg1 port map (
		reset => reset,
		strobe => wc1_strobe, data_in => wc1_data_in,
		data_out => wc1_data_out,
		------------------ gpib --------------------
		bytes_available_in_fifo => wm_availableBytesCount
	);

	ig: InterruptGenerator port map (
		reset => reset, clk => clk, interrupt => interrupt_line,
		-------------------- gpib device ---------------------
		isLocal => g_isLocal, in_buf_ready => r_buf_interrupt,
		out_buf_ready => w_buf_interrupt, clr => g_clr, trg => g_trg,
		att => g_att, atl => g_atl, spa => g_spa, cwrc => g_cwrc,
		cwrd => g_cwrd, srq => g_sreq, ppr => g_ppr,
		stb_received => s_stb_received, REN => REN_in, ATN => ATN_in,
		IFC => IFC_in
	);

	rml: RegMultiplexer generic map (ADDR_WIDTH => 15) port map (
			strobe_read => strobe_read, strobe_write => strobe_write,
			data_in => data_in, data_out => data_out,
			--------------------------------------------------------
			reg_addr => reg_addr,
			--------------------------------------------------------
			reg_strobe_0 => set0_strobe,
			reg_in_0 => set0_data_in, reg_out_0 => set0_data_out,
			
			reg_strobe_1 => set1_strobe,
			reg_in_1 => set1_data_in, reg_out_1 => set1_data_out,
			
			reg_strobe_2 => sec0_strobe,
			reg_in_2 => sec0_data_in, reg_out_2 => sec0_data_out,
			
			reg_strobe_3 => sec1_strobe,
			reg_in_3 => sec1_data_in, reg_out_3 => sec1_data_out,
			
			--reg_strobe_4 => 
			--reg_in_4 => 
			reg_out_4 => gbs_data_out,
			
			reg_strobe_5 => ev_strobe,
			reg_in_5 => ev_data_in, reg_out_5 => ev_data_out,
			
			--reg_strobe_6 => 
			--reg_in_6 => 
			reg_out_6 => gs_data_out,
			
			reg_strobe_7 => gc_strobe,
			reg_in_7 => gc_data_in, reg_out_7 => gc_data_out,
			
			reg_strobe_8 => rc0_strobe,
			reg_in_8 => rc0_data_in, reg_out_8 => rc0_data_out,
			
			--reg_strobe_9 => rc1_strobe,
			--reg_in_9 => rc1_data_in,
			reg_out_9 => rc1_data_out,
			
			reg_strobe_10 => wc0_strobe,
			reg_in_10 => wc0_data_in, reg_out_10 => wc0_data_out,
			
			reg_strobe_11 => wc1_strobe,
			reg_in_11 => wc1_data_in, reg_out_11 => wc1_data_out,
			
			reg_strobe_other0 => rm_strobe_read,
			--reg_in_other0 => ,
			reg_out_other0 => rm_byte_out,
			
			reg_strobe_other1 => wm_write_strobe,
			reg_in_other1 => wm_data_in,
			reg_out_other1 => "0000000000000000"
		);

end arch;

