----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Simon Falsig
-- 
-- Create Date:    	19/03/2010 
-- Design Name: 	uTosNet
-- Module Name:    	uTosNet_usb - Behavioral 
-- File Name:		uTosNet_uart.vhd
-- Project Name: 	uTosNet
-- Target Devices: 	SDU XC3S50AN Board
-- Tool versions: 	Xilinx ISE 11.4
-- Description: 	This module implements a very simple ASCII based protocol over
--					a uart. Data can be read and written from and to one port of a
--					dual-port blockRAM, where the other blockRAM port is available
--					to the user application. Communication takes place at the fol-
--					lowing settings:
--						Baudrate: 115200 kbps
--						Parity: none
--						Bits: 8 data bits, 1 stop bit
--						Flowcontrol: none
--					The protocol format can be seen in the documentation files.
--
--					Focus has mostly been on a simple implementation, as the 
--					module is to be used during courses at the university.
--
-- Dependencies: 	The module uses the uart implementation from Ken Chapmans
--					PicoBlaze. More specifically the following files:
--						uart_rx.vhd
--						kcuart_rx.vhd
--						bbfifo_16x8.vhd
--						uart_tx.vhd
--						kcuart_tx.vhd
--					These files can be downloaded from Xilinx:
--					https://secure.xilinx.com/webreg/register.do?group=picoblaze
--
--					It should not be hard to implement the module using another
--					uart implementation though.
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

entity uTosNet_uart is
Port (	clk_50M						: in	STD_LOGIC;
		serial_out					: out	STD_LOGIC;				
		serial_in					: in	STD_LOGIC;
		dataReg_addr				: in	STD_LOGIC_VECTOR(5 downto 0);
		dataReg_dataIn				: in	STD_LOGIC_VECTOR(31 downto 0);
		dataReg_dataOut				: out	STD_LOGIC_VECTOR(31 downto 0);
		dataReg_clk					: in	STD_LOGIC;
		dataReg_writeEnable			: in	STD_LOGIC);
end uTosNet_uart;

architecture Behavioral of uTosNet_uart is

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

	component uart_rx
	Port (	serial_in				: in	STD_LOGIC;
			data_out				: out	STD_LOGIC_VECTOR(7 downto 0);
			read_buffer				: in	STD_LOGIC;
			reset_buffer			: in	STD_LOGIC;
			en_16_x_baud			: in	STD_LOGIC;
			buffer_data_present		: out	STD_LOGIC;
			buffer_full				: out	STD_LOGIC;
			buffer_half_full		: out	STD_LOGIC;
			clk						: in	STD_LOGIC);
	end component;

	component uart_tx
	Port (	serial_out				: out	STD_LOGIC;
			data_in					: in	STD_LOGIC_VECTOR(7 downto 0);
			write_buffer			: in	STD_LOGIC;
			reset_buffer			: in	STD_LOGIC;
			en_16_x_baud			: in	STD_LOGIC;
			buffer_full				: out	STD_LOGIC;
			buffer_half_full		: out	STD_LOGIC;
			clk						: in	STD_LOGIC);
	end component;
  
	signal baudCount				: integer range 0 to 36 :=0;
	signal en_16_x_baud				: STD_LOGIC;
	signal readFromUart				: STD_LOGIC;
	signal rxData					: STD_LOGIC_VECTOR(7 downto 0);
	signal rxDataPresent			: STD_LOGIC;
	signal rxFull					: STD_LOGIC;
	signal rxHalfFull				: STD_LOGIC; 

	signal txData					: STD_LOGIC_VECTOR(7 downto 0);
	signal writeToUart				: STD_LOGIC;
	signal txFull					: STD_LOGIC;
	signal txHalfFull				: STD_LOGIC;

	constant UARTDIV				: STD_LOGIC_VECTOR(5 downto 0) := "011010";

	type STATES is (IDLE, COMMAND_IN, WAIT1, REG_IN, WAIT2, INDEX_IN, WAIT3, SPACE_IN, WAIT4, DATA_IN, WAIT_DATA_IN, DATA_OUT, PERFORM_READ_SETUP, PERFORM_READ_CLK, PERFORM_READ_DONE, PERFORM_WRITE_SETUP, PERFORM_WRITE_CLK, PERFORM_WRITE_DONE);
	
	signal state					: STATES := IDLE;
	signal nextState				: STATES := IDLE;

	type COMMANDS is (CMD_NONE, CMD_READ, CMD_WRITE, CMD_COMMIT_READ, CMD_COMMIT_WRITE);

	signal currentCommand			: COMMANDS := CMD_NONE;

	signal int_dataReg_dataIn		: STD_LOGIC_VECTOR(31 downto 0);
	signal int_dataReg_addr			: STD_LOGIC_VECTOR(5 downto 0);
	signal int_dataReg_dataOut		: STD_LOGIC_VECTOR(31 downto 0);
	signal int_dataReg_we			: STD_LOGIC_VECTOR(0 downto 0);
	signal int_dataReg_clk			: STD_LOGIC;
	
	signal dataReg_writeEnable_V	: STD_LOGIC_VECTOR(0 downto 0);
	
	signal inputBuffer				: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal outputBuffer				: STD_LOGIC_VECTOR(31 downto 0) := (others => '1');
	
	signal readCounter				: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	signal writeCounter				: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	
	signal currentReg				: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal currentIndex				: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	
	signal commitRead				: STD_LOGIC := '0';
	signal commitWrite				: STD_LOGIC := '0';

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

	rx_inst: uart_rx
	Port map (	serial_in => serial_in,
				data_out => rxData,
				read_buffer => readFromUart,
				reset_buffer => '0',
				en_16_x_baud => en_16_x_baud,
				buffer_data_present => rxDataPresent,
				buffer_full => rxFull,
				buffer_half_full => rxHalfFull,
				clk => clk_50M );  

	tx_inst : uart_tx
	Port map (	serial_out => serial_out,
				data_in => txData,
				write_buffer => writeToUart,
				reset_buffer => '0',
				en_16_x_baud => en_16_x_baud,
				buffer_full => txFull,
				buffer_half_full => txHalfFull,
				clk => clk_50M);

	baudTimer_inst: process(clk_50M)
	begin
		if(clk_50M'event and clk_50M='1')then
			if(baudCount = UARTDIV)then
				baudCount <= 0;
				en_16_x_baud <= '1';
			else
				baudCount <= baudCount + 1;
				en_16_x_baud <= '0';
			end if;
		end if;
	end process baudTimer_inst;

 
	process(clk_50M)
	begin
		if(clk_50M = '1' and clk_50M'event) then
			state <= nextState;
			
			readFromUart <= '0';
			writeToUart <= '0';
			
			case state is
				when IDLE =>
					currentCommand <= CMD_NONE;
					readCounter <= (others => '0');
					writeCounter <= (others => '0');
					commitRead <= '0';
					commitWrite <= '0';
				when COMMAND_IN =>
					commitRead <= '0';
					commitWrite <= '0';
					if(rxDataPresent = '1') then
						case rxData is
							when "01110010" => --'r'
								currentCommand <= CMD_READ;
							when "01110111" => --'w'
								currentCommand <= CMD_WRITE;
							when "01110100" => --'t'
								commitRead <= '1';					--Might need to switch with write
								currentCommand <= CMD_NONE;
							when "01100011" => --'c'
								commitWrite <= '1';					--Might need to switch with read
								currentCommand <= CMD_NONE;
							when others => 
								currentCommand <= CMD_NONE;
						end case;
						readFromUart <= '1';
					end if;
				when WAIT1 =>
				when REG_IN =>
					if(rxDataPresent = '1') then
						case rxData is
							when "00110000" =>
								currentReg <= "000";
							when "00110001" =>
								currentReg <= "001";
							when "00110010" =>
								currentReg <= "010";
							when "00110011" =>
								currentReg <= "011";
							when "00110100" =>
								currentReg <= "100";
							when "00110101" =>
								currentReg <= "101";
							when "00110110" =>
								currentReg <= "110";
							when "00110111" =>
								currentReg <= "111";
							when others =>
								currentCommand <= CMD_NONE;
						end case;
						readFromUart <= '1';
					end if;
				when WAIT2 =>
				when INDEX_IN =>
					if(rxDataPresent = '1') then
						case rxData is
							when "00110000" =>
								currentIndex <= "000";
							when "00110001" =>
								currentIndex <= "001";
							when "00110010" =>
								currentIndex <= "010";
							when "00110011" =>
								currentIndex <= "011";
							when "00110100" =>
								currentIndex <= "100";
							when "00110101" =>
								currentIndex <= "101";
							when "00110110" =>
								currentIndex <= "110";
							when "00110111" =>
								currentIndex <= "111";
							when others =>
								currentCommand <= CMD_NONE;
						end case;
						readFromUart <= '1';
					end if;
				when WAIT3 =>
				when SPACE_IN =>
					if(rxDataPresent = '1') then
						if(not(rxData = "00100000")) then
							currentCommand <= CMD_NONE;
						end if;
						readFromUart <= '1';
					end if;
				when WAIT4 =>
				when DATA_IN =>
					if(rxDataPresent = '1') then
						case rxData is
							when "00110000" =>	--'0'
								inputBuffer <= inputBuffer(27 downto 0) & "0000";
							when "00110001" =>	--'1'
								inputBuffer <= inputBuffer(27 downto 0) & "0001";
							when "00110010" =>	--'2'
								inputBuffer <= inputBuffer(27 downto 0) & "0010";
							when "00110011" =>	--'3'
								inputBuffer <= inputBuffer(27 downto 0) & "0011";
							when "00110100" =>	--'4'
								inputBuffer <= inputBuffer(27 downto 0) & "0100";
							when "00110101" =>	--'5'
								inputBuffer <= inputBuffer(27 downto 0) & "0101";
							when "00110110" =>	--'6'
								inputBuffer <= inputBuffer(27 downto 0) & "0110";
							when "00110111" =>	--'7'
								inputBuffer <= inputBuffer(27 downto 0) & "0111";
							when "00111000" =>	--'8'
								inputBuffer <= inputBuffer(27 downto 0) & "1000";
							when "00111001" =>	--'9'
								inputBuffer <= inputBuffer(27 downto 0) & "1001";
							when "01100001" =>	--'a'
								inputBuffer <= inputBuffer(27 downto 0) & "1010";
							when "01100010" =>	--'b'
								inputBuffer <= inputBuffer(27 downto 0) & "1011";
							when "01100011" =>	--'c'
								inputBuffer <= inputBuffer(27 downto 0) & "1100";
							when "01100100" =>	--'d'
								inputBuffer <= inputBuffer(27 downto 0) & "1101";
							when "01100101" =>	--'e'
								inputBuffer <= inputBuffer(27 downto 0) & "1110";
							when "01100110" =>	--'f'
								inputBuffer <= inputBuffer(27 downto 0) & "1111";
							when others =>
								currentCommand <= CMD_NONE;
						end case;
						readFromUart <= '1';
						readCounter <= readCounter + 1;
					end if;
				when WAIT_DATA_IN =>
				when DATA_OUT =>
					writeToUart <= '1';
					if(writeCounter = 8) then
						txData <= "00100000";	--Transmit a space to make thinks look nicer...:)
					else
						case outputBuffer(31 downto 28) is
							when "0000" =>	--'0'
								txData <= "00110000";
							when "0001" =>	--'1'
								txData <= "00110001";
							when "0010" =>	--'2'
								txData <= "00110010";
							when "0011" =>	--'3'
								txData <= "00110011";
							when "0100" =>	--'4'
								txData <= "00110100";
							when "0101" =>	--'5'
								txData <= "00110101";
							when "0110" =>	--'6'
								txData <= "00110110";
							when "0111" =>	--'7'
								txData <= "00110111";
							when "1000" =>	--'8'
								txData <= "00111000";
							when "1001" =>	--'9'
								txData <= "00111001";
							when "1010" =>	--'a'
								txData <= "01100001";
							when "1011" =>	--'b'
								txData <= "01100010";
							when "1100" =>	--'c'
								txData <= "01100011";
							when "1101" =>	--'d'
								txData <= "01100100";
							when "1110" =>	--'e'
								txData <= "01100101";
							when "1111" =>	--'f'
								txData <= "01100110";
							when others =>
						end case;
					end if;
					outputBuffer <= outputBuffer(27 downto 0) & "0000";
					writeCounter <= writeCounter + 1;
				when PERFORM_READ_SETUP =>
					int_dataReg_addr <= currentReg & currentIndex;
					int_dataReg_we <= "0";
					int_dataReg_clk <= '0';
				when PERFORM_READ_CLK =>
					int_dataReg_clk <= '1';
				when PERFORM_READ_DONE =>
					outputBuffer <= int_dataReg_dataOut;
					int_dataReg_clk <= '0';
				when PERFORM_WRITE_SETUP =>
					int_dataReg_addr <= currentReg & currentIndex;
					int_dataReg_dataIn <= inputBuffer;
					int_dataReg_we <= "1";
					int_dataReg_clk <= '0';
				when PERFORM_WRITE_CLK =>
					int_dataReg_clk <= '1';
				when PERFORM_WRITE_DONE =>
					int_dataReg_we <= "0";
					int_dataReg_clk <= '0';
			end case;
		end if;
	end process;
	
	process(state, rxDataPresent, currentCommand, readCounter, writeCounter)
	begin
		if((currentCommand = CMD_NONE) and not ((state = COMMAND_IN) or (state = IDLE))) then
			nextState <= IDLE;
		else
			case state is
				when IDLE =>
					nextState <= COMMAND_IN;
				when COMMAND_IN =>
					if(rxDataPresent = '1') then
						nextState <= WAIT1;
					else
						nextState <= COMMAND_IN;
					end if;
				when WAIT1 =>
					if(rxDataPresent = '0') then
						nextState <= REG_IN;
					else
						nextState <= WAIT1;
					end if;
				when REG_IN =>
					if(rxDataPresent = '1') then
						nextState <= WAIT2;
					else
						nextState <= REG_IN;
					end if;
				when WAIT2 =>
					if(rxDataPresent = '0') then
						nextState <= INDEX_IN;
					else
						nextState <= WAIT2;
					end if;
				when INDEX_IN =>
					if(rxDataPresent = '1') then
						nextState <= WAIT3;
					else
						nextState <= INDEX_IN;
					end if;
				when WAIT3 =>
					if(rxDataPresent = '0') then
						if(currentCommand = CMD_READ) then
							nextState <= PERFORM_READ_SETUP;
						else
							nextState <= SPACE_IN;
						end if;
					else
						nextState <= WAIT3;
					end if;
				when SPACE_IN =>
					if(rxDataPresent = '1') then
						nextState <= WAIT4;
					else
						nextState <= SPACE_IN;
					end if;
				when WAIT4 => 
					if(rxDataPresent = '0') then
						nextState <= DATA_IN;
					else
						nextState <= WAIT4;
					end if;
				when DATA_IN =>
					if(rxDataPresent = '1') then
						nextState <= WAIT_DATA_IN;
					else
						nextState <= DATA_IN;
					end if;
				when WAIT_DATA_IN =>
					if(rxDataPresent = '0') then
						if(readCounter = 8) then
							nextState <= PERFORM_WRITE_SETUP;
						else
							nextState <= DATA_IN;
						end if;
					else
						nextState <= WAIT_DATA_IN;
					end if;
				when DATA_OUT =>
					if(writeCounter = 8) then
						nextState <= IDLE;
					else
						nextState <= DATA_OUT;
					end if;
				when PERFORM_READ_SETUP =>
					nextState <= PERFORM_READ_CLK;
				when PERFORM_READ_CLK =>
					nextState <= PERFORM_READ_DONE;
				when PERFORM_READ_DONE =>
					nextState <= DATA_OUT;
				when PERFORM_WRITE_SETUP =>
					nextState <= PERFORM_WRITE_CLK;
				when PERFORM_WRITE_CLK =>
					nextState <= PERFORM_WRITE_DONE;
				when PERFORM_WRITE_DONE =>
					nextState <= IDLE;
			end case;
		end if;
	end process;
	
end Behavioral;

