----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Anders Sørensen
-- 
-- Create Date:    	30/11/2009 
-- Design Name: 	uTosNet
-- Module Name:    	uTosNet_ctrl - Behavioral 
-- File Name:		uTosNet_ctrl.vhd
-- Project Name: 	uTosNet
-- Target Devices: 	SDU XC3S50AN Board
-- Tool versions: 	Xilinx ISE 11.4
-- Description: 	This module implements a state machine for accessing the 
--					uTosNet BlockRAM.
--
-- Revision: 
-- Revision 0.10 - 	Initial release
--
-- Copyright 2010
--
-- This module is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This module is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this module.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uTosNet_ctrl is
	Port (	T_clk_50M								: in	STD_LOGIC;
			T_serial_out							: out STD_LOGIC;
			T_serial_in                     		: in  STD_LOGIC;
			T_reg_ptr								: out std_logic_vector(2 downto 0);
			T_word_ptr								: out std_logic_vector(1 downto 0);
			T_data_to_mem							: in  std_logic_vector(31 downto 0);
			T_data_from_mem							: out std_logic_vector(31 downto 0);
			T_data_from_mem_latch					: out std_logic);
end uTosNet_ctrl;

-------------------------------------------------

architecture Behavioral of uTosNet_ctrl is

	component uTosNet_uart is
	Port (	clk_50M						: in	STD_LOGIC;
			serial_out					: out	STD_LOGIC;				
			serial_in					: in	STD_LOGIC;
			dataReg_addr				: in	STD_LOGIC_VECTOR(5 downto 0);
			dataReg_dataIn				: in	STD_LOGIC_VECTOR(31 downto 0);
			dataReg_dataOut				: out	STD_LOGIC_VECTOR(31 downto 0);
			dataReg_clk					: in	STD_LOGIC;
			dataReg_writeEnable			: in	STD_LOGIC);
	end component;

	type STATES is (IDLE, SETUP_1, CLK_1, DONE_1);
	
	signal state		: STATES := IDLE;
	signal nextState	: STATES := IDLE;
	
	signal dataReg_addr		: STD_LOGIC_VECTOR(5 downto 0);
	signal dataReg_dataIn	: STD_LOGIC_VECTOR(31 downto 0);
	signal dataReg_dataOut	: STD_LOGIC_VECTOR(31 downto 0);
	signal dataReg_clk		: STD_LOGIC;
	signal dataReg_we		: STD_LOGIC;
	
	signal word_cnt         : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');

begin
	
	uTosNet_uartInst : uTosNet_uart
	Port map (	clk_50M => T_clk_50M,
				serial_out => T_serial_out,
				serial_in => T_serial_in,
				dataReg_addr => dataReg_addr,
				dataReg_dataIn =>  dataReg_dataIn,
				dataReg_dataOut => dataReg_dataOut,
				dataReg_clk => dataReg_clk,
				dataReg_writeEnable => dataReg_we);


	T_data_from_mem <= dataReg_dataOut;
	dataReg_dataIn <= T_data_to_mem;
	T_reg_ptr <= dataReg_addr(5 downto 3);
	T_word_ptr <= dataReg_addr(1 downto 0);

	process(T_clk_50M)
	begin
		if(T_clk_50M = '1' and T_clk_50M'event) then
			state <= nextState;
			
			case state is
				when IDLE =>
				when SETUP_1 =>
					dataReg_addr <= word_cnt(5 downto 3) & word_cnt(0) & word_cnt(2 downto 1);
					--             < register >          | in/out area | word index
					dataReg_clk <= '0';
					T_data_from_mem_latch <= '0';
					word_cnt <= word_cnt;
					if word_cnt(0) = '0' then		-- If we are looking at a slave output register
						dataReg_we <= '1';			-- Prepare to copy data from bus to RAM block
					else
						dataReg_we <= '0';
					end if;
				when CLK_1 =>
					dataReg_clk <= '1';
					if word_cnt(0) = '1' then  				-- If we are looking at a slave_input register 
						T_data_from_mem_latch <= '1';		-- Signal bus-slave, that data can be copied from the bus
						dataReg_we <= '0';
					else 
						dataReg_we <= '1';
						T_data_from_mem_latch <= '0';
					end if;
					word_cnt <= word_cnt;
				when DONE_1 =>
					dataReg_we <='0';
					T_data_from_mem_latch <= '0';
					word_cnt <= word_cnt + 1;
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when IDLE =>
				nextState <= SETUP_1;
			when SETUP_1 =>
				nextState <= CLK_1;
			when CLK_1 =>
				nextState <= DONE_1;
			when DONE_1 =>
				nextState <= IDLE;
		end case;
	end process;


end architecture;
