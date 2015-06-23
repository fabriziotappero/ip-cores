----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	19/03/2010 
-- Design Name: 	uTosNet_uart Example
-- Module Name:    	top - Behavioral 
-- File Name:		top.vhd
-- Project Name: 	uTosNet
-- Target Devices: 	SDU XC3S50AN Board
-- Tool versions: 	Xilinx ISE 11.4
-- Description: 	This is a simple example showing the use of the uTosNet_uart
--					module.
--
-- Revision: 
-- Revision 0.10 - 	Initial release
--
-- Copyright 2010
--
-- This file is part of the uTosNet_spi Example
--
-- The uTosNet_uart Example is free software: you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of the License,
-- or (at your option) any later version.
--
-- The uTosNet_uart Example is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with the uTosNet_uart Example. If not, see
-- <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
Port (	CLK_50M_I			: in	STD_LOGIC;
		LEDS_O				: out	STD_LOGIC_VECTOR(2 downto 0);
		SERIAL_O			: out	STD_LOGIC;
		SERIAL_I			: in	STD_LOGIC);
end top;

architecture Behavioral of top is

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
	signal dataReg_dataIn	: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal dataReg_dataOut	: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal dataReg_clk		: STD_LOGIC;
	signal dataReg_we		: STD_LOGIC;

begin

	uTosNet_uartInst : uTosNet_uart
	Port map (	clk_50M => CLK_50M_I,
				serial_out => SERIAL_O,
				serial_in => SERIAL_I,
				dataReg_addr => dataReg_addr,
				dataReg_dataIn => "00000000000000000000000000000000",
				dataReg_dataOut => dataReg_dataOut,
				dataReg_clk => dataReg_clk,
				dataReg_writeEnable => dataReg_we);

	process(CLK_50M_I)
	begin
		if(CLK_50M_I = '1' and CLK_50M_I'event) then
			state <= nextState;
			
			case state is
				when IDLE =>
				when SETUP_1 =>
					dataReg_addr <= "000000";
					dataReg_clk <= '0';
					dataReg_we <= '0';
				when CLK_1 =>
					dataReg_clk <= '1';
				when DONE_1 =>
					LEDS_O <= dataReg_dataOut(2 downto 0);
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


end Behavioral;

