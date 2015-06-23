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
-- Entity: helperComponents
-- Date:2011-11-10  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


package helperComponents is

	component gpibReader is
		port (
			-- clock
			clk : in std_logic;
			-- reset
			reset : std_logic;
			------------------------------------------------------------------------
			------ GPIB interface --------------------------------------------------
			------------------------------------------------------------------------
			-- input data
			data_in : in std_logic_vector (7 downto 0);
			-- data valid
			dvd : in std_logic;
			-- listener active
			lac : in std_logic;
			-- last byte
			lsb : in std_logic;
			-- ready to next byte
			rdy : out std_logic;
			------------------------------------------------------------------------
			------ external interface ----------------------------------------------
			------------------------------------------------------------------------
			-- is LE function active
			isLE : in std_logic;
			-- current secondary address
			secAddr : in std_logic_vector (4 downto 0);
			-- secondary address of data
			dataSecAddr : out std_logic_vector (4 downto 0);
			-- buffer ready interrupt
			buf_interrupt : out std_logic;
			-- indicates end of stream
			end_of_stream : out std_logic;
			-- resets reader
			reset_reader : in std_logic;
			------------------ fifo --------------------------------------
			-- indicates fifo full
			fifo_full : in std_logic;
			-- indicates fifo ready to write
			fifo_ready_to_write : in std_logic;
			-- indicates at least one byte in fifo
			at_least_one_byte_in_fifo : in std_logic;
			-- output data
			data_out : out std_logic_vector (7 downto 0);
			-- fifo strobe
			fifo_strobe : out std_logic
		);
	end component;

	component gpibWriter is
		port (
			-- clock
			clk : in std_logic;
			-- reset
			reset : std_logic;
			------------------------------------------------------------------------
			------ GPIB interface --------------------------------------------------
			------------------------------------------------------------------------
			-- output data
			data_out : out std_logic_vector (7 downto 0);
			-- wait for new cycle
			wnc : in std_logic;
			-- seriall poll active
			spa : in std_logic;
			-- new byte available
			nba : out std_logic;
			-- end of string
			endOf : out std_logic;
			-- talker active
			tac : in std_logic;
			-- controller write command
			cwrc : in std_logic;
			------------------------------------------------------------------------
			------ external interface ----------------------------------------------
			------------------------------------------------------------------------
			-- TE is extended
			isTE : in std_logic;
			-- current secondary address
			secAddr : in std_logic_vector (4 downto 0);
			-- secondary address of data
			dataSecAddr : in std_logic_vector (4 downto 0);
			-- buffer consumed
			buf_interrupt : out std_logic;
			-- indicates end of stream
			end_of_stream : in std_logic;
			-- resets writer
			reset_writer : in std_logic;
			-- enables writer
			writer_enable : in std_logic;
			---------------- fifo ---------------------------
			availableFifoBytesCount : in std_logic_vector(10 downto 0);
			-- fifo read strobe
			fifo_read_strobe : out std_logic;
			-- indicates fifo ready to read
			fifo_ready_to_read : in std_logic;
			-- input data
			fifo_data_in : in std_logic_vector (7 downto 0)
		);
	end component;

	component SerialPollCoordinator is
	port (
		-- clock
		clk : in std_logic;
		-- reset
		reset : in std_logic;
		-- data accepted
		DAC : in std_logic;
		-- receive status byte
		rec_stb : in std_logic;
		-- attention in
		ATN_in : in std_logic;
		-- attention out
		ATN_out : out std_logic;
		-- output valid in
		output_valid_in : in std_logic;
		-- output valid out
		output_valid_out : out std_logic;
		-- stb received
		stb_received : out std_logic
	);
	end component;

	component MemoryBlock is
		port (
			reset : in std_logic;
			clk : in std_logic;
			-------------------------------------------------
			p1_addr : in std_logic_vector(10 downto 0);
			p1_data_in : in std_logic_vector(7 downto 0);
			p1_strobe : in std_logic;
			p1_data_out : out std_logic_vector(7 downto 0);
			-------------------------------------------------
			p2_addr : in std_logic_vector(10 downto 0);
			p2_data_in : in std_logic_vector(7 downto 0);
			p2_strobe : in std_logic;
			p2_data_out : out std_logic_vector(7 downto 0)
		);
	end component;

	component Fifo8b is
		generic (
			MAX_ADDR_BIT_NUM : integer := 10
		);
		port (
			reset : in std_logic;
			clk : in std_logic;
			-------------- fifo --------------------
			bytesAvailable : out std_logic;
			availableBytesCount : out std_logic_vector(MAX_ADDR_BIT_NUM downto 0);
			bufferFull : out std_logic;
			resetFifo : in std_logic;
			----------------------------------------
			data_in : in std_logic_vector(7 downto 0);
			ready_to_write :out std_logic;
			strobe_write : in std_logic;
			----------------------------------------
			data_out : out std_logic_vector(7 downto 0);
			ready_to_read : out std_logic;
			strobe_read : in std_logic
		);
	end component;

	component Clk2x is
		port (
			reset: in std_logic;
			clk : in std_logic;
			clk2x : out std_logic
		);
	end component;

	component SinglePulseGenerator is
		generic (
			WIDTH : integer := 3
		);
		
		port (
			reset : in std_logic;
			clk : in std_logic;
			t_in: in std_logic;
			t_out : out std_logic;
			pulse : out std_logic
		);
	end component;

	component EdgeDetector is
		generic (
			RISING : std_logic := '1';
			FALLING : std_logic := '0';
			PULSE_WIDTH : integer := 10
		);
		
		port (
			reset : in std_logic;
			clk : in std_logic;
			in_data : in std_logic;
			pulse : out std_logic
		);
	end component;

	component EventMem is
		port (
			reset : std_logic;
			-- event occured
			occured : in std_logic;
			-- event approved
			approved : in std_logic;
			-- output
			output : out std_logic
		);
	end component;

	component GpibSynchronizer is
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
	end component;

end helperComponents;

