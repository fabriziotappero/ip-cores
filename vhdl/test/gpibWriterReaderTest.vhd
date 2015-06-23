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
-- Author: Andrzej Paluch
--
-- Create Date:   23:21:05 10/21/2011
-- Design Name:   
-- Module Name:   /windows/h/projekty/elektronika/USB_to_HPIB/usbToHpib/test_scr//gpibInterfaceTest.vhd
-- Project Name:  usbToHpib
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gpibInterface
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

use work.gpibComponents.all;
use work.helperComponents.all;


ENTITY gpibWriterReaderTest IS
END gpibWriterReaderTest;

ARCHITECTURE behavior OF gpibWriterReaderTest IS 

	-- Component Declaration for the Unit Under Test (UUT)

	component gpibCableEmulator is port (
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
	end component;
	
	-- inputs common
	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal T1 : std_logic_vector(7 downto 0) := "00000100";
	
	-- inputs 1
	signal data_1 : std_logic_vector(7 downto 0) := (others => '0');
	signal status_byte_1 : std_logic_vector(7 downto 0) := (others => '0');
	signal rdy_1 : std_logic := '0';
	signal nba_1 : std_logic := '0';
	signal ltn_1 : std_logic := '0';
	signal lun_1 : std_logic := '0';
	signal lon_1 : std_logic := '0';
	signal ton_1 : std_logic := '0';
	signal endOf_1 : std_logic := '0';
	signal gts_1 : std_logic := '0';
	signal rpp_1 : std_logic := '0';
	signal tcs_1 : std_logic := '0';
	signal tca_1 : std_logic := '0';
	signal sic_1 : std_logic := '0';
	signal rsc_1 : std_logic := '0';
	signal sre_1 : std_logic := '0';
	signal rtl_1 : std_logic := '0';
	signal rsv_1 : std_logic := '0';
	signal ist_1 : std_logic := '0';
	signal lpe_1 : std_logic := '0';

	-- inputs 2
	signal data_2 : std_logic_vector(7 downto 0) := (others => '0');
	signal status_byte_2 : std_logic_vector(7 downto 0) := (others => '0');
	signal rdy_2 : std_logic := '0';
	signal nba_2 : std_logic := '0';
	signal ltn_2 : std_logic := '0';
	signal lun_2 : std_logic := '0';
	signal lon_2 : std_logic := '0';
	signal ton_2 : std_logic := '0';
	signal endOf_2 : std_logic := '0';
	signal gts_2 : std_logic := '0';
	signal rpp_2 : std_logic := '0';
	signal tcs_2 : std_logic := '0';
	signal tca_2 : std_logic := '0';
	signal sic_2 : std_logic := '0';
	signal rsc_2 : std_logic := '0';
	signal sre_2 : std_logic := '0';
	signal rtl_2 : std_logic := '0';
	signal rsv_2 : std_logic := '0';
	signal ist_2 : std_logic := '0';
	signal lpe_2 : std_logic := '0';

	-- outputs 1
	signal dvd_1 : std_logic;
	signal wnc_1 : std_logic;
	signal tac_1 : std_logic;
	signal lac_1 : std_logic;
	signal cwrc_1 : std_logic;
	signal cwrd_1 : std_logic;
	signal clr_1 : std_logic;
	signal trg_1 : std_logic;
	signal atl_1 : std_logic;
	signal att_1 : std_logic;
	signal mla_1 : std_logic;
	signal lsb_1 : std_logic;
	signal spa_1 : std_logic;
	signal ppr_1 : std_logic;
	signal sreq_1 : std_logic;
	signal isLocal_1 : std_logic;
	signal currentSecAddr_1 : std_logic_vector (4 downto 0);

	-- outputs 2
	signal dvd_2 : std_logic;
	signal wnc_2 : std_logic;
	signal tac_2 : std_logic;
	signal lac_2 : std_logic;
	signal cwrc_2 : std_logic;
	signal cwrd_2 : std_logic;
	signal clr_2 : std_logic;
	signal trg_2 : std_logic;
	signal atl_2 : std_logic;
	signal att_2 : std_logic;
	signal mla_2 : std_logic;
	signal lsb_2 : std_logic;
	signal spa_2 : std_logic;
	signal ppr_2 : std_logic;
	signal sreq_2 : std_logic;
	signal isLocal_2 : std_logic;
	signal currentSecAddr_2 : std_logic_vector (4 downto 0);

	-- common
	signal DO : std_logic_vector (7 downto 0);
	signal DI_1 : std_logic_vector (7 downto 0);
	signal output_valid_1 : std_logic;
	signal DI_2 : std_logic_vector (7 downto 0);
	signal output_valid_2 : std_logic;
	signal ATN_1, ATN_2, ATN : std_logic;
	signal DAV_1, DAV_2, DAV : std_logic;
	signal NRFD_1, NRFD_2, NRFD : std_logic;
	signal NDAC_1, NDAC_2, NDAC : std_logic;
	signal EOI_1, EOI_2, EOI : std_logic;
	signal SRQ_1, SRQ_2, SRQ : std_logic;
	signal IFC_1, IFC_2, IFC : std_logic;
	signal REN_1, REN_2, REN : std_logic;

	type WR_BUF_TYPE is
		array (0 to 15) of std_logic_vector (7 downto 0);

	-- gpib reader
	signal buf_interrupt : std_logic;
	signal data_available : std_logic;
	signal last_byte_addr : std_logic_vector (3 downto 0);
	signal end_of_stream : std_logic;
	signal byte_addr : std_logic_vector (3 downto 0);
	signal data_out : std_logic_vector (7 downto 0);
	signal reset_buffer : std_logic := '0';
	signal dataSecAddr : std_logic_vector (4 downto 0);
	signal buf_strobe : std_logic;
	signal buffer_byte_mode : std_logic;
	signal read_buffer : WR_BUF_TYPE;

	-- gpib writer
	signal w_last_byte_addr : std_logic_vector (3 downto 0)
		:= (others => '0');
	signal w_end_of_stream : std_logic := '0';
	signal w_data_available : std_logic := '0';
	signal w_buf_interrupt : std_logic;
	signal w_data_in : std_logic_vector (7 downto 0);
	signal w_byte_addr : std_logic_vector (3 downto 0);
	signal w_reset_buffer : std_logic := '0';
	signal w_buffer_byte_mode : std_logic;
	signal w_write_buffer : WR_BUF_TYPE;

	-- Clock period definitions
	constant clk_period : time := 2ps;
 
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	gpib1: gpibInterface PORT MAP (
		clk => clk,
		reset => reset,
		isLE => '0',
		isTE => '0',
		lpeUsed => '0',
		fixedPpLine => "000",
		eosUsed => '0',
		eosMark => "00000000",
		myListAddr => "00001",
		myTalkAddr => "00001",
		secAddrMask => (others => '0'),
		data => data_1,
		status_byte => status_byte_1,
		T1 => T1,
		rdy => rdy_1,
		nba => nba_1,
		ltn => ltn_1,
		lun => lun_1,
		lon => lon_1,
		ton => ton_1,
		endOf => endOf_1,
		gts => gts_1,
		rpp => rpp_1,
		tcs => tcs_1,
		tca => tca_1,
		sic => sic_1,
		rsc => rsc_1,
		sre => sre_1,
		rtl => rtl_1,
		rsv => rsv_1,
		ist => ist_1,
		lpe => lpe_1,
		dvd => dvd_1,
		wnc => wnc_1,
		tac => tac_1,
		lac => lac_1,
		cwrc => cwrc_1,
		cwrd => cwrd_1,
		clr => clr_1,
		trg => trg_1,
		atl => atl_1,
		att => att_1,
		mla => mla_1,
		lsb => lsb_1,
		spa => spa_1,
		ppr => ppr_1,
		sreq => sreq_1,
		isLocal => isLocal_1,
		currentSecAddr => currentSecAddr_1,
		DI => DO,
		DO => DI_1,
		output_valid => output_valid_1,
		ATN_in => ATN,
		ATN_out => ATN_1,
		DAV_in => DAV,
		DAV_out => DAV_1,
		NRFD_in => NRFD,
		NRFD_out => NRFD_1,
		NDAC_in => NDAC,
		NDAC_out => NDAC_1,
		EOI_in => EOI,
		EOI_out => EOI_1,
		SRQ_in => SRQ,
		SRQ_out => SRQ_1,
		IFC_in => IFC,
		IFC_out => IFC_1,
		REN_in => REN,
		REN_out => REN_1
		);

	-- Instantiate the Unit Under Test (UUT)
	gpib2: gpibInterface PORT MAP (
		clk => clk,
		reset => reset,
		isLE => '0',
		isTE => '0',
		lpeUsed => '0',
		fixedPpLine => "000",
		eosUsed => '0',
		eosMark => "00000000",
		myListAddr => "00010",
		myTalkAddr => "00010",
		secAddrMask => (others => '0'),
		data => data_2,
		status_byte => status_byte_2,
		T1 => T1,
		rdy => rdy_2,
		nba => nba_2,
		ltn => ltn_2,
		lun => lun_2,
		lon => lon_2,
		ton => ton_2,
		endOf => endOf_2,
		gts => gts_2,
		rpp => rpp_2,
		tcs => tcs_2,
		tca => tca_2,
		sic => sic_2,
		rsc => rsc_2,
		sre => sre_2,
		rtl => rtl_2,
		rsv => rsv_2,
		ist => ist_2,
		lpe => lpe_2,
		dvd => dvd_2,
		wnc => wnc_2,
		tac => tac_2,
		lac => lac_2,
		cwrc => cwrc_2,
		cwrd => cwrd_2,
		clr => clr_2,
		trg => trg_2,
		atl => atl_2,
		att => att_2,
		mla => mla_2,
		lsb => lsb_2,
		spa => spa_2,
		ppr => ppr_2,
		sreq => sreq_2,
		isLocal => isLocal_2,
		currentSecAddr => currentSecAddr_2,
		DI => DO,
		DO => DI_2,
		output_valid => output_valid_2,
		ATN_in => ATN,
		ATN_out => ATN_2,
		DAV_in => DAV,
		DAV_out => DAV_2,
		NRFD_in => NRFD,
		NRFD_out => NRFD_2,
		NDAC_in => NDAC,
		NDAC_out => NDAC_2,
		EOI_in => EOI,
		EOI_out => EOI_2,
		SRQ_in => SRQ,
		SRQ_out => SRQ_2,
		IFC_in => IFC,
		IFC_out => IFC_2,
		REN_in => REN,
		REN_out => REN_2
		);

	ce: gpibCableEmulator port map (
		-- interface signals
		DIO_1 => DI_1,
		output_valid_1 => output_valid_1,
		DIO_2 => DI_2,
		output_valid_2 => output_valid_2,
		DIO => DO,
		-- attention
		ATN_1 => ATN_1, ATN_2 => ATN_2, ATN => ATN,
		DAV_1 => DAV_1, DAV_2 => DAV_2, DAV => DAV,
		NRFD_1 => NRFD_1, NRFD_2 => NRFD_2, NRFD => NRFD,
		NDAC_1 => NDAC_1, NDAC_2 => NDAC_2, NDAC => NDAC,
		EOI_1 => EOI_1, EOI_2 => EOI_2, EOI => EOI,
		SRQ_1 => SRQ_1, SRQ_2 => SRQ_2, SRQ => SRQ,
		IFC_1 => IFC_1, IFC_2 => IFC_2, IFC => IFC,
		REN_1 => REN_1, REN_2 => REN_2, REN => REN
	);

	process (buf_strobe) begin
		if rising_edge(buf_strobe) then
			read_buffer(conv_integer(w_byte_addr)) <= data_out;
		end if;
	end process;

	gr: gpibReader generic map (ADDR_WIDTH => 4) port map (
		clk => clk, reset => reset,
		------------------------------------------------------------------------
		------ GPIB interface --------------------------------------------------
		------------------------------------------------------------------------
		data_in => DO, dvd => dvd_2, lac => lac_2, lsb => lsb_2, rdy => rdy_2,
		------------------------------------------------------------------------
		------ external interface ----------------------------------------------
		------------------------------------------------------------------------
		isLE => '0', secAddr => (others => '0'), dataSecAddr => dataSecAddr,
		buf_interrupt => buf_interrupt, data_available => data_available,
		last_byte_addr => last_byte_addr, end_of_stream => end_of_stream,
		byte_addr => byte_addr, data_out => data_out,
		buf_strobe => buf_strobe, buffer_byte_mode => buffer_byte_mode,
		reset_buffer => reset_buffer
	);

	w_data_in <= w_write_buffer(conv_integer(w_byte_addr));

	gw: gpibWriter generic map (ADDR_WIDTH => 4) port map (
			clk => clk, reset => reset,
			------------------------------------------------------------------------
			------ GPIB interface --------------------------------------------------
			------------------------------------------------------------------------
			data_out => data_1, wnc => wnc_1, spa => spa_1, nba => nba_1,
			endOf => endOf_1, tac => tac_1, cwrc => cwrc_1,
			------------------------------------------------------------------------
			------ external interface ----------------------------------------------
			------------------------------------------------------------------------
			isTE => '0', secAddr => (others => '0'), dataSecAddr => (others => '0'),
			last_byte_addr => w_last_byte_addr, end_of_stream => w_end_of_stream,
			data_available => w_data_available, buf_interrupt => w_buf_interrupt,
			data_in => w_data_in, byte_addr => w_byte_addr,
			buffer_byte_mode => w_buffer_byte_mode,
			reset_buffer => w_reset_buffer
		);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;
 

	-- Stimulus process
	stim_proc: process
	begin
		-- hold reset state for 10 clock periods.
		reset <= '1';
		wait for clk_period*10;	
		reset <= '0';
		wait for clk_period*10;

		-- requests system control
		rsc_1 <= '1';
		
		-- interface clear
		sic_1 <= '1';
		wait until IFC_1 = '1';
		sic_1 <= '0';
		wait until IFC_1 = '0';
		
		-- gpib2 to listen
		w_write_buffer(0) <= "00100010";
		-- gpib1 to talk
		w_write_buffer(1) <= "01000001";
		w_last_byte_addr <= "0001";
		w_end_of_stream <= '1';
		w_data_available <= '1';
		
		wait until w_buf_interrupt='1';
		
		gts_1 <= '1';
		wait until ATN='0';
		
		w_reset_buffer <= '1';
		wait for clk_period*2;
		w_reset_buffer <= '0';
		
		wait for clk_period*1;
		
		w_write_buffer(0) <= "10101010";
		w_write_buffer(1) <= "01010101";
		w_write_buffer(2) <= "11111111";
		w_last_byte_addr <= "0010";
		w_data_available <= '1';
		
		wait until buf_interrupt='1';
		
		wait for clk_period*1;
		assert read_buffer(0) = "10101010";
		
		wait for clk_period*1;
		assert read_buffer(1) = "01010101";
		
		wait for clk_period*1;
		assert read_buffer(2) = "11111111";
		
		report "$$$ END OF TEST - write read $$$";
		
		wait;
	end process;

END;
