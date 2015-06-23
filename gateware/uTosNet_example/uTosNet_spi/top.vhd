----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	19/03/2010 
-- Design Name: 	uTosNet_spi Example
-- Module Name:    	top - Behavioral 
-- File Name:		top.vhd
-- Project Name: 	uTosNet
-- Target Devices: 	SDU XC3S50AN Board
-- Tool versions: 	Xilinx ISE 11.4
-- Description: 	This is a simple example showing the use of the uTosNet_spi
--					module.
--
-- Revision: 
-- Revision 0.10 - 	Initial release
--
-- Copyright 2010
--
-- This file is part of the uTosNet_spi Example
--
-- The uTosNet_spi Example is free software: you can redistribute it 
-- and/or modify it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of the License,
-- or (at your option) any later version.
--
-- The uTosNet_spi Example is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
-- General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with the uTosNet_spi Example. If not, see
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
		SPI_MISO_O			: out	STD_LOGIC;
		SPI_MOSI_I			: in	STD_LOGIC;
		SPI_EN_I			: in	STD_LOGIC;
		SPI_CLK_I			: in	STD_LOGIC);
end top;

architecture Behavioral of top is

	component uTosNet_spi is
	Port (	clk_50M						: in	STD_LOGIC;
			spi_miso					: out	STD_LOGIC;				
			spi_mosi					: in	STD_LOGIC;
			spi_clk						: in	STD_LOGIC;
			spi_en						: in	STD_LOGIC;
			dataReg_addr				: in	STD_LOGIC_VECTOR(5 downto 0);
			dataReg_dataIn				: in	STD_LOGIC_VECTOR(31 downto 0);
			dataReg_dataOut				: out	STD_LOGIC_VECTOR(31 downto 0);
			dataReg_clk					: in	STD_LOGIC;
			dataReg_writeEnable			: in	STD_LOGIC);
	end component;
	
	type STATES is (IDLE, SETUP, CLK, DONE);
	
	signal state		: STATES := IDLE;
	signal nextState	: STATES := IDLE;
	
	signal dataReg_addr		: STD_LOGIC_VECTOR(5 downto 0);
	signal dataReg_dataIn	: STD_LOGIC_VECTOR(31 downto 0);
	signal dataReg_dataOut	: STD_LOGIC_VECTOR(31 downto 0);
	signal dataReg_clk		: STD_LOGIC;
	signal dataReg_we		: STD_LOGIC;
begin

	uTosNet_spiInst : uTosNet_spi
	Port map (	clk_50M => CLK_50M_I,
				spi_miso => SPI_MISO_O,
				spi_mosi => SPI_MOSI_I,
				spi_en => SPI_EN_I,
				spi_clk => SPI_CLK_I,
				dataReg_addr => dataReg_addr,
				dataReg_dataIn => dataReg_dataIn,
				dataReg_dataOut => dataReg_dataOut,
				dataReg_clk => dataReg_clk,
				dataReg_writeEnable => dataReg_we);
	
	process(CLK_50M_I)
	begin
		if(CLK_50M_I = '1' and CLK_50M_I'event) then
			state <= nextState;
			
			case state is
				when IDLE =>
				when SETUP =>
					dataReg_addr <= "000000";
					dataReg_clk <= '0';
					dataReg_we <= '0';
				when CLK =>
					dataReg_clk <= '1';
				when DONE =>
					LEDS_O <= dataReg_dataOut(2 downto 0);
			end case;
		end if;
	end process;
	
	process(state)
	begin
		case state is
			when IDLE =>
				nextState <= SETUP;
			when SETUP =>
				nextState <= CLK;
			when CLK =>
				nextState <= DONE;
			when DONE =>
				nextState <= IDLE;
		end case;
	end process;


end Behavioral;

