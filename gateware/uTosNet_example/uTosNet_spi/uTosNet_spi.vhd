----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	19/3/2010 
-- Design Name: 	uTosNet
-- Module Name:    	uTosNet_spi - Behavioral 
-- File Name:		utosnet_spi.vhd
-- Project Name:	uTosNet
-- Target Devices:	SDU XC3S50AN Board
-- Tool versions:	Xilinx ISE 11.4
-- Description: 	PseudoTosNet is designed to provide an interface similar to 
--					the full-blown TosNet core, but usable on the SDU XC3S50AN 
--					Board. It features a SPI module which is made for use in 
--					conjunction with a Digi Connect ME 9210 with the Generic 
--					TosNet Masternode application. By using this combination, it 
--					is possible to access the blockram from any Ethernet-enabled 
--					device.
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uTosNet_spi is
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
end uTosNet_spi;

architecture Behavioral of uTosNet_spi is
	
	component dataRegister
	Port (	clka					: in 	STD_LOGIC;
			wea						: in	STD_LOGIC_VECTOR(0 downto 0);
			addra					: in 	STD_LOGIC_VECTOR(5 downto 0);
			dina					: in 	STD_LOGIC_VECTOR(31 downto 0);
			douta					: out 	STD_LOGIC_VECTOR(31 downto 0);
			clkb					: in	STD_LOGIC;
			web						: in	STD_LOGIC_VECTOR(0 downto 0);
			addrb					: in	STD_LOGIC_VECTOR(5 downto 0);
			dinb					: in	STD_LOGIC_VECTOR(31 downto 0);
			doutb					: out	STD_LOGIC_VECTOR(31 downto 0));
	end component;
	
	signal int_dataReg_dataIn		: STD_LOGIC_VECTOR(31 downto 0);
	signal int_dataReg_addr			: STD_LOGIC_VECTOR(5 downto 0);
	signal int_dataReg_dataOut		: STD_LOGIC_VECTOR(31 downto 0);
	signal int_dataReg_we			: STD_LOGIC_VECTOR(0 downto 0);
	signal int_dataReg_clk			: STD_LOGIC;
	
	signal dataReg_writeEnable_V	: STD_LOGIC_VECTOR(0 downto 0);
	
	signal readData					: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal writeAddress				: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal readAddress				: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal doWrite					: STD_LOGIC := '0';
	signal doRead					: STD_LOGIC := '0';
	
	signal int_spi_mosi				: STD_LOGIC;
	signal int_spi_clk				: STD_LOGIC;
	signal int_spi_en				: STD_LOGIC;
	signal last_spi_clk				: STD_LOGIC;
	
	signal dataInBuffer				: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal dataOutBuffer			: STD_LOGIC_VECTOR(31 downto 0) := (others => '1');
	
	signal bitCounter				: STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	
begin

	dataReg_writeEnable_V(0) <= dataReg_writeEnable;							--Conversion from std_logic to std_logic_vector(0 downto 0) - to allow for dataReg_writeEnable to be a std_logic, which is nicer...:)

	dataRegisterInst : dataRegister												--Instantation of the dual-port blockram used for the dataregister
	Port map (	clka => dataReg_clk,											--PortA is used for the user application
				wea => dataReg_writeEnable_V,									--
				addra => dataReg_addr,											--
				dina => dataReg_dataIn,											--
				douta => dataReg_dataOut,										--
				clkb => int_dataReg_clk,										--PortB is used for the SPI interface
				web => int_dataReg_we,											--
				addrb => int_dataReg_addr,										--
				dinb => int_dataReg_dataIn,										--
				doutb => int_dataReg_dataOut);									--

	--Synchronize inputs
	process(clk_50M)
	begin
		if(clk_50M = '0' and clk_50M'event) then
			int_spi_mosi <= spi_mosi;
			int_spi_clk <= spi_clk;
			int_spi_en <= spi_en;
		end if;
	end process;
	
	--SPI Process
	process(clk_50M)
	begin
		if(clk_50M = '1' and clk_50M'event) then
			last_spi_clk <= int_spi_clk;										--Save current value to use for manual edge triggering

			if(int_spi_en = '1') then											--SPI is not enabled (spi_en is active low)
				bitCounter <= (others => '0');									--Reset the bitcounter
				
				if((doWrite = '1') and (int_dataReg_we = "0")) then				--If a write was requested in the previously received command,
					int_dataReg_addr <= writeAddress;							-- then prepare it,
					int_dataReg_dataIn <= dataInBuffer;							-- the data to write are those left in the input buffer,
					int_dataReg_we <= "1";										--
					int_dataReg_clk <= '0';										--
				elsif((doWrite = '1') and (int_dataReg_clk = '0')) then			--
					int_dataReg_clk <= '1';										-- and perform it by pulling the dataReg clock high
					doWrite <= '0';												--Write is done
				else															--If there aren't any writes to perform,
					int_dataReg_clk <= '0';										-- just clear the various signals
					int_dataReg_we <= "0";										--
					doRead <= '0';												--
					doWrite <= '0';												--
				end if;
			else																--SPI is enabled
				if(int_spi_clk = '0' and last_spi_clk = '1') then 				--Falling edge on spi_clk
					dataInBuffer <= dataInBuffer(30 downto 0) & int_spi_mosi;	--Read next received bit into the input buffer,
					bitCounter <= bitCounter + 1;								-- and increment the bitcounter
				elsif(int_spi_clk = '1' and last_spi_clk = '0') then			--Rising edge on spi_clk
					spi_miso <= dataOutBuffer(31);								--Write out the next bit from the output buffer,
					dataOutBuffer <= dataOutBuffer(30 downto 0) & '0';			-- and left-shift the buffer
				end if;
				
				case bitCounter is												--Parse the command
					when "0000101" =>											--Bit 27 (the 5th read bit),
						doRead <= dataInBuffer(0);								-- contains the 'doRead' flag
					when "0010000" =>											--Bits 16-25 (available when 16 bits have been read),
						readAddress <= dataInBuffer(5 downto 0);				-- contain the address to read from
					when "0010001" =>											--Bit 15 (the 17th read bit),
						int_dataReg_addr <= readAddress;						-- doesn't contain anything useful, but we can easily use the timeslot for reading from the dataregister
						int_dataReg_we <= "0";									--
						int_dataReg_clk <= '0';									--
					when "0010010" =>											--Bit 14 (the 18th read bit),
						int_dataReg_clk <= '1';									-- still nothing, now performing the read by pulling the dataregister clock high
					when "0010011" =>											--Bit 13 (the 19th read bit),
						int_dataReg_clk <= '0';									-- the read is finished,
						readData <= int_dataReg_dataOut;						-- and the read value is stored
					when "0010101" =>											--Bit 11 (the 21st read bit),
						doWrite <= dataInBuffer(0);								-- contains the 'doWrite' flag
					when "0011111" =>											--Bit 1 (the 31st read bit),
						if(doRead = '1') then									-- we're not using this bit for anything right now, but we need to put the previously read data value into the output buffer now
							dataOutBuffer <= readData;							--
						else													--If a read was not requested,
							dataOutBuffer <= (others => '0');					-- the output buffer is just filled with zeros instead
						end if;
					when "0100000" =>											--Bits 9-0 (available when 32 bits have been read),
						writeAddress <= dataInBuffer(5 downto 0);				-- contain the address to write to
					when others =>												--Other bit positions are ignored
				end case;
			end if;
		
		end if;
	end process;
	
end Behavioral;
