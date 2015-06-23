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
-- Entity: wrapperComponents
-- Date:2011-11-17  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


package wrapperComponents is

	component RegsGpibFasade is
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
	end component;

	component InterruptGenerator is
		port (
			reset : std_logic;
			clk : in std_logic;
			interrupt : out std_logic;
			-------------------- gpib device ---------------------
			-- device is local controlled
			isLocal : in std_logic;
			-- input buffer ready
			in_buf_ready : in std_logic;
			-- output buffer ready
			out_buf_ready : in std_logic;
			-- clear device (DC)
			clr : in std_logic;
			-- trigger device (DT)
			trg : in std_logic;
			-- addressed to talk(L or LE)
			att : in std_logic;
			-- addressed to listen (T or TE)
			atl : in std_logic;
			-- seriall poll active
			spa : in std_logic;
			-------------------- gpib controller ---------------------
			-- controller write commands
			cwrc : in std_logic;
			-- controller write data
			cwrd : in std_logic;
			-- service requested
			srq : in std_logic;
			-- parallel poll ready
			ppr : in std_logic;
			-- stb received
			stb_received : in std_logic;
			REN : in std_logic;
			ATN : in std_logic;
			IFC : in std_logic
		);
	end component;

	component RegMultiplexer is
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
	end component;

	component EventReg is
		port (
			reset : in std_logic;
			clk : in std_logic;
			strobe : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			data_out : out std_logic_vector (15 downto 0);
			-------------------- gpib device ---------------------
			-- device is local controlled
			isLocal : in std_logic;
			-- input buffer ready
			in_buf_ready : in std_logic;
			-- output buffer ready
			out_buf_ready : in std_logic;
			-- clear device (DC)
			clr : in std_logic;
			-- trigger device (DT)
			trg : in std_logic;
			-- addressed to talk(L or LE)
			att : in std_logic;
			-- addressed to listen (T or TE)
			atl : in std_logic;
			-- seriall poll active
			spa : in std_logic;
			-------------------- gpib controller ---------------------
			-- controller write commands
			cwrc : in std_logic;
			-- controller write data
			cwrd : in std_logic;
			-- service requested
			srq : in std_logic;
			-- parallel poll ready
			ppr : in std_logic;
			-- stb received
			stb_received : in std_logic;
			REN : in std_logic;
			ATN : in std_logic;
			IFC : in std_logic
		);
	end component;

	component gpibBusReg is
		port (
			data_out : out std_logic_vector (15 downto 0);
			------------------------------------------------
			-- interface signals
			DIO : in std_logic_vector (7 downto 0);
			-- attention
			ATN : in std_logic;
			-- data valid
			DAV : in std_logic;
			-- not ready for data
			NRFD : in std_logic;
			-- no data accepted
			NDAC : in std_logic;
			-- end or identify
			EOI : in std_logic;
			-- service request
			SRQ : in std_logic;
			-- interface clear
			IFC : in std_logic;
			-- remote enable
			REN : in std_logic
		);
	end component;

	component gpibControlReg is
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
	end component;

	component GpibStatusReg is
		port (
			data_out : out std_logic_vector (15 downto 0);
			-- gpib
			currentSecAddr : in std_logic_vector (4 downto 0); -- current sec addr
			att : in std_logic; -- addressed to talk(L or LE)
			tac : in std_logic; -- talker active (T, TE)
			atl : in std_logic; -- addressed to listen (T or TE)
			lac : in std_logic; -- listener active (L, LE)
			cwrc : in std_logic; -- controller write commands
			cwrd : in std_logic; -- controller write data
			spa : in std_logic; -- seriall poll active
			isLocal : in std_logic -- device is local controlled
		);
	end component;

	component ReaderControlReg0 is
		port (
			clk : in std_logic;
			reset : in std_logic;
			strobe : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			data_out : out std_logic_vector (15 downto 0);
			------------------- gpib -------------------------
			-- buffer ready interrupt
			buf_interrupt : in std_logic;
			-- at least one byte available
			data_available : in std_logic;
			-- indicates end of stream
			end_of_stream : in std_logic;
			-- resets buffer
			reset_buffer : out std_logic;
			-- secondary address of data
			dataSecAddr : in std_logic_vector (4 downto 0)
		);
	end component;

	component ReaderControlReg1 is
		port (
			data_out : out std_logic_vector (15 downto 0);
			------------------ gpib --------------------
			-- num of bytes available in fifo
			bytes_available_in_fifo : in std_logic_vector (10 downto 0)
		);
	end component;

	component SecAddrReg is
		port (
			reset : in std_logic;
			strobe : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			data_out : out std_logic_vector (15 downto 0);
			-- gpib
			secAddrMask : out std_logic_vector (15 downto 0)
		);
	end component;

	component SettingsReg0 is
		port (
			reset : in std_logic;
			strobe : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			data_out : out std_logic_vector (15 downto 0);
			------------- gpib -----------------------------
			isLE_TE : out std_logic;
			lpeUsed : out std_logic;
			fixedPpLine : out std_logic_vector (2 downto 0);
			eosUsed : out std_logic;
			eosMark : out std_logic_vector (7 downto 0);
			lon : out std_logic;
			ton : out std_logic
		);
	end component;

	component SettingsReg1 is
		port (
			reset : in std_logic;
			strobe : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			data_out : out std_logic_vector (15 downto 0);
			-- gpib
			myAddr : out std_logic_vector (4 downto 0);
			T1 : out std_logic_vector (7 downto 0)
		);
	end component;

	component WriterControlReg0 is
		port (
			clk : in std_logic;
			reset : in std_logic;
			strobe : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			data_out : out std_logic_vector (15 downto 0);
			------------------- gpib -------------------------
			-- buffer consumed
			buf_interrupt : in std_logic;
			-- data avilable - at least one byte in buffer
			data_available : out std_logic;
			-- indicates end of stream
			end_of_stream : out std_logic;
			-- resets buffer
			reset_buffer : out std_logic;
			-- secondary address of data
			dataSecAddr : out std_logic_vector (4 downto 0);
			-- serial poll status byte
			status_byte : out std_logic_vector (6 downto 0)
		);
	end component;

	component WriterControlReg1 is
		port (
			reset : in std_logic;
			strobe : in std_logic;
			data_in : in std_logic_vector (15 downto 0);
			data_out : out std_logic_vector (15 downto 0);
			------------------ gpib --------------------
			-- num of bytes available in fifo
			bytes_available_in_fifo : in std_logic_vector (10 downto 0)
		);
	end component;

end wrapperComponents;

