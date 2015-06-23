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
-- Entity: Uart
-- Date:2011-11-26  
-- Author: Andrzej Paluch
--
-- Description ${cursor}
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity Uart is
	port (
		reset : in std_logic;
		clk : in std_logic;
		---------- UART ---------------
		RX : in std_logic;
		TX : out std_logic;
		---------- gpib ---------------
		data_out : out std_logic_vector(7 downto 0);
		data_out_ready : out std_logic;
		data_in : in std_logic_vector(7 downto 0);
		data_in_ready : in std_logic;
		ready_to_send : out std_logic
	);
end Uart;

architecture arch of Uart is

	constant BIT_TIME : integer :=
		-- 115200
		--572
		-- 921600
		72
		;
	constant HALF_BIT_TIME : integer := BIT_TIME / 2;

	type RX_STATES is (
		ST_RX_IDLE,
		ST_RX_HALF_START,
		ST_RX_RECEIVE_BITS,
		ST_RX_RECEIVE_STOP_BIT
	);
	
	type TX_STATES is (
		ST_TX_IDLE,
		ST_TX_SEND_BITS,
		ST_TX_SEND_STOP_BIT
	);

	signal syncRX : std_logic;

	signal rxState : RX_STATES;
	signal lastRx : std_logic;
	signal rxTimeCounter : integer range 0 to BIT_TIME;
	signal rxBitCounter : integer range 0 to 7;
	signal innerBuf : std_logic_vector(6 downto 0);
	
	signal txState : TX_STATES;
	signal lastData_in_ready : std_logic;
	signal txTimeCounter : integer range 0 to BIT_TIME;
	signal txBitCounter : integer range 0 to 8;

begin
	
	-- RX synchronizer
	process(clk, RX) begin
		if rising_edge(clk) then
			syncRX <= RX;
		end if;
	end process;
	
	-- RX
	process(reset, clk, syncRX) begin
		if reset = '1' then
			rxState <= ST_RX_IDLE;
			lastRx <= syncRX;
			data_out_ready <= '0';
		elsif rising_edge(clk) then
		
			lastRx <= syncRX;
		
			if rxTimeCounter < BIT_TIME then
				rxTimeCounter <= rxTimeCounter + 1;
			end if;

			case rxState is
				when ST_RX_IDLE =>
					if lastRx /= syncRX and syncRX = '0' then
						rxTimeCounter <= 1;
						rxState <= ST_RX_HALF_START;
					end if;
				
				when ST_RX_HALF_START =>
					if rxTimeCounter >= HALF_BIT_TIME then
						rxBitCounter <= 0;
						rxTimeCounter <= 1;
						rxState <= ST_RX_RECEIVE_BITS;
					end if;
				
				when ST_RX_RECEIVE_BITS =>
					if rxTimeCounter >= BIT_TIME then
						
						if rxBitCounter < 7 then
							innerBuf(rxBitCounter) <= syncRX;
							rxBitCounter <= rxBitCounter + 1;
							rxTimeCounter <= 1;
						elsif rxBitCounter = 7 then
							data_out(7) <= syncRX;
							data_out(6 downto 0) <= innerBuf;
							data_out_ready <= '0';
							rxTimeCounter <= 1;
							
							rxState <= ST_RX_RECEIVE_STOP_BIT;
						end if;
					end if;
				
				when ST_RX_RECEIVE_STOP_BIT =>
					if rxTimeCounter >= BIT_TIME then
						data_out_ready <= '1';
						
						rxState <= ST_RX_IDLE;
					end if;
				
				when others =>
					rxState <= ST_RX_IDLE;
			end case;
		end if;
	end process;

	-- TX
	process(reset, clk, data_in_ready) begin
		if reset = '1' then
			TX <= '1';
			ready_to_send <= '1';
			txState <= ST_TX_IDLE;
		elsif rising_edge(clk) then
			
			lastData_in_ready <= data_in_ready;
			
			if txTimeCounter < BIT_TIME then
				txTimeCounter <= txTimeCounter + 1;
			end if;
			
			case txState is
				when ST_TX_IDLE =>
					if lastData_in_ready /= data_in_ready and
							data_in_ready = '1' then
						TX <= '0';
						txTimeCounter <= 1;
						txBitCounter <= 0;
						ready_to_send <= '0';
						
						txState <= ST_TX_SEND_BITS;
					end if;
				when ST_TX_SEND_BITS =>
					if txTimeCounter >= BIT_TIME then
						
						if txBitCounter < 8 then
							TX <= data_in(txBitCounter);
							txBitCounter <= txBitCounter + 1;
							txTimeCounter <= 1;
						elsif txBitCounter = 8 then
							TX <= '1';
							txTimeCounter <= 1;
							
							txState <= ST_TX_SEND_STOP_BIT;
						end if;
					end if;
				when ST_TX_SEND_STOP_BIT =>
					if txTimeCounter >= BIT_TIME then
						ready_to_send <= '1';
						
						txState <= ST_TX_IDLE;
					end if;
				when others =>
					txState <= ST_TX_IDLE;
			end case;
		end if;
	end process;

end arch;

