----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Module Name: XILINX_RDIC_Bridge - Structural 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Description: Translates between Xilinx mem contoller and RDIC.
-- Revision: 1.0
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RDIC_Xilinx_bridge is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
			  fifo_empty_out : in std_Logic;
			  write_enable_out : in std_logic;
			  APP_AF_WREN   : out std_logic;
				APP_WDF_WREN : out std_logic;
				ack_access_in : out std_logic;
				command : out std_logic_vector(2 downto 0);
				mask : out std_logic_vector(7 downto 0));
end RDIC_Xilinx_bridge;

architecture Behavioral of RDIC_Xilinx_bridge is

type StateType_1 is (wait_arbitration,check_access_type,assert_write_enable,assert_read_enable,
						 acknowledge_access,wait_0, wait_1,wait_2,wait_3,wait_9,acknowledge_access_0,
						wait_10,wait_11,wait_12,wait_13,wait_14,wait_15, wait_16,
						check_W_A_fifo,check_A_fifo,assert_write_enable_1,assert_write_enable_2,wait_delay,
						wait_delay_1,wait_delay_2,wait_delay_3,wait_delay_4,assert_read_enable_0);		
						
signal currentstate_1,nextstate_1 : statetype_1;


begin


process(currentstate_1,fifo_empty_out,write_enable_out)
begin
	case currentstate_1 is
			when wait_arbitration =>
					if(fifo_empty_out = '0') then
						NextState_1 <= check_access_type;
					else
						NextState_1 <= wait_arbitration;
					end if;		
				
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "011111111";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
				
			when check_access_type =>
					if(write_enable_out = '1') then
						NextState_1 <= check_W_A_fifo;
					else
						NextState_1 <= check_A_fifo;
--					else
--						NextState <= check_A_fifo;
					end if;
				
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when check_W_A_fifo =>		
--				if(WDF_ALMOST_FULL = '1' OR AF_ALMOST_FULL = '1') then -- may not need to check condition
--						NextState <= check_W_A_fifo;
--				else
					NextState_1 <= assert_write_enable;
--				end if;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "100";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when assert_write_enable =>					
						NextState_1 <= assert_write_enable_1;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '1';
				APP_WDF_WREN       	<= '1';
				ack_access_in <= '0';
				command <= "100";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00001111";
				
			when assert_write_enable_1 =>					
						NextState_1 <= assert_write_enable_2;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '1';
				ack_access_in <= '0';
				command <= "100";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "11111111";
				
			when assert_write_enable_2 =>					
						NextState_1 <= acknowledge_access_0;
--						NextState_1 <= wait_9;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "100";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when check_A_fifo =>		
--				if(AF_ALMOST_FULL = '1') then -- may not need to check condition
--						NextState <= check_A_fifo;
--				else
					NextState_1 <= assert_read_enable;
--				end if;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "101";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when assert_read_enable =>
--					NextState_1 <= assert_read_enable_0;
--					NextState_1 <= wait_0;
					NextState_1 <= acknowledge_access;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '1';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "101";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
-------Added February 6, 2008
--		when assert_read_enable_0 =>
--					NextState_1 <= wait_0;
--					
--				
----				tx_pdata <= (others => '0');
----				load_uart_char <= '0';
----				read_uart_char <= '0';
----				next_banner_char <= '0';
----				load_banner_addres <= '0';
----				banner_address <= (others => '0');
----				cyc_o <= '0';
----				stb_o <= '0';
----				we_o <= '0';
----				lock_o <= '0';
----				leds <= "000011010";
--				APP_AF_WREN         	<= '1';
--				APP_WDF_WREN       	<= '0';
--				ack_access_in <= '0';
--				command <= "101";
----				next_mem_location <= '0';
----			   load_new_addr <= '0';
----			   new_addr <= (others => '0');
--				mask <= "00000000";
--------------------------------------------------
	
			
			when wait_0 =>
						NextState_1 <= wait_1;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_1 =>
					NextState_1 <= wait_2;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_2 =>
					NextState_1 <= wait_3;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when wait_3 =>
					NextState_1 <= acknowledge_access;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when acknowledge_access =>
					NextState_1 <= wait_delay;
					
--				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '1';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
		
		
			when wait_delay => 
					Nextstate_1 <= wait_delay_1;
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_delay_1 => 
					Nextstate_1 <= wait_delay_2;
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_delay_2 => 
					Nextstate_1 <= wait_delay_3;
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";

			when wait_delay_3 => 
					Nextstate_1 <= wait_delay_4;
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
				when wait_delay_4 => 
					Nextstate_1 <= wait_arbitration;
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when wait_9 =>
						NextState_1 <= wait_10;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_10 =>
					NextState_1 <= wait_11;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_11 =>
					NextState_1 <= wait_12;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when wait_12 =>
					NextState_1 <= acknowledge_access_0;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
			when acknowledge_access_0 =>
					NextState_1 <= wait_13;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '1';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
		
			when wait_13 =>
					NextState_1 <= wait_14;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_14 =>
					NextState_1 <= wait_15;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_15 =>
					NextState_1 <= wait_16;
					
				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
			when wait_16 =>
					
						NextState_1 <= wait_arbitration;

				
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
			
				when others =>
					Nextstate_1 <= wait_arbitration;
--				tx_pdata <= (others => '0');
--				load_uart_char <= '0';
--				read_uart_char <= '0';
--				next_banner_char <= '0';
--				load_banner_addres <= '0';
--				banner_address <= (others => '0');
--				cyc_o <= '0';
--				stb_o <= '0';
--				we_o <= '0';
--				lock_o <= '0';
--				leds <= "000011010";
				APP_AF_WREN         	<= '0';
				APP_WDF_WREN       	<= '0';
				ack_access_in <= '0';
				command <= "000";
--				next_mem_location <= '0';
--			   load_new_addr <= '0';
--			   new_addr <= (others => '0');
				mask <= "00000000";
				
		end case;
	end process;
	
currentstate_1logic: process
	begin
			wait until clock'EVENT and clock = '1'; --WAIT FOR RISING EDGE
			-- INITIALIZATION
			if (Reset = '1') then
				CurrentState_1 <= wait_arbitration;
			else
       				CurrentState_1 <= NextState_1;
			end if;
end process currentstate_1logic;	
	

end Behavioral;

