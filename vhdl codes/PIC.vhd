----------------------------------------------------------------------------
---- Create Date:    00:12:45 10/23/2010  										
---- Design Name: pic																				
---- Project Name: PIC												
Description: 																		
----  A Programmable Interrupt Controller which can handle upto 8 	----
---- level triggered interrupts.The operating modes available are  	----
---- polling fixed priority modes.							----   																												----	
----------------------------------------------------------------------------
----                                                                    ----
---- This file is a part of the pic project at                 ----
---- http://www.opencores.org/						      ----
----                                                                    ----
---- Author(s):                                                         ----
----   Vipin Lal, lalnitt@gmail.com                                     ----
----                                                                    ----
----------------------------------------------------------------------------
----                                                                    ----
---- Copyright (C) 2010 Authors and OPENCORES.ORG                       ----
----                                                                    ----
---- This source file may be used and distributed without               ----
---- restriction provided that this copyright statement is not          ----
---- removed from the file and that any derivative work contains        ----
---- the original copyright notice and the associated disclaimer.       ----
----                                                                    ----
---- This source file is free software; you can redistribute it         ----
---- and/or modify it under the terms of the GNU Lesser General         ----
---- Public License as published by the Free Software Foundation;       ----
---- either version 2.1 of the License, or (at your option) any         ----
---- later version.                                                     ----
----                                                                    ----
---- This source is distributed in the hope that it will be             ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied         ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR            ----
---- PURPOSE. See the GNU Lesser General Public License for more        ----
---- details.                                                           ----
----                                                                    ----
---- You should have received a copy of the GNU Lesser General          ----
---- Public License along with this source; if not, download it         ----
---- from http://www.opencores.org/lgpl.shtml                           ----
----                                                                    ----
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PIC is
port(	CLK_I : in std_logic;   --Clock.
		RST_I : in std_logic;  --Reset
		IR : in unsigned(7 downto 0);   --Interrupt requests from peripherals.
		DataBus : inout unsigned(7 downto 0);   --Data bus between processor PIC.
		INTR_O : out std_logic;  --Interrupt Request pin of processor.
		INTA_I : in std_logic  --Interrupt ack.
		);
end PIC;

architecture Behavioral of PIC is

type state_type is (reset_s,get_commands,jump_int_method,start_polling,tx_int_info_polling,ack_ISR_done,
							ack_txinfo_rxd,start_priority_check,tx_int_info_priority,ack_txinfo_rxd_priority,ack_ISR_done_pt);
signal next_s : state_type :=reset_s;
signal int_type : unsigned(1 downto 0):="01";
signal int_index,count_cmd : integer := 0;
type prior_table is array (0 to 7) of unsigned(2 downto 0);
signal pt : prior_table := (others => (others => '0'));
signal int_pt : unsigned(2 downto 0):="000";
signal flag,flag1 : std_logic := '0';  --These flags are used for timing purposes.

begin

process(CLK_I,RST_I)
begin
if( RST_I = '1') then
	next_s <= reset_s;
elsif( rising_edge(CLK_I) ) then
	flag <= INTA_I;
	case next_s is
		when reset_s =>
			--initialze signals to zero.
			flag <= '0';
			flag1 <= '0';
			int_type <= "00";
			int_index <= 0;
			count_cmd <= 0;
			int_pt <= "000";
			pt <= (others => (others => '0'));
			if( RST_I = '0' ) then
				next_s <= get_commands;  
			else
				next_s <= reset_s;
			end if;
			DataBus <= (others => 'Z');
		when get_commands =>     --Get commands and operating mode from the processor.
			if( DataBus(1 downto 0) = "01" ) then
				int_type <= "01";
				next_s <= jump_int_method;
			elsif( DataBus(1 downto 0) = "10" and count_cmd = 0) then
				pt(0) <= DataBus(7 downto 5);
				pt(1) <= DataBus(4 downto 2);
				count_cmd <= count_cmd + 1;
				next_s <= get_commands;
			elsif( DataBus(1 downto 0) = "10" and count_cmd = 1) then
				pt(2) <= DataBus(7 downto 5);
				pt(3) <= DataBus(4 downto 2);
				count_cmd <= count_cmd + 1;
				next_s <= get_commands;
			elsif( DataBus(1 downto 0) = "10" and count_cmd = 2) then
				pt(4) <= DataBus(7 downto 5);
				pt(5) <= DataBus(4 downto 2);
				count_cmd <= count_cmd + 1;
				next_s <= get_commands;		
			elsif( DataBus(1 downto 0) = "10" and count_cmd = 3) then
				pt(6) <= DataBus(7 downto 5);
				pt(7) <= DataBus(4 downto 2);
				count_cmd <= 0;
				int_type <= "10";
				next_s <= jump_int_method;	
			else
				next_s <= get_commands;
			end if;
		when jump_int_method =>  --Check which method is used to determine the interrupts.
			flag <= '0';
			flag1 <= '0';
			int_index <= 0;
			count_cmd <= 0;
			int_pt <= "000";
			if( int_type = "01" ) then
				next_s <= start_polling;   --Polling method for checking the interrupts.
			elsif( int_type = "10" ) then
				next_s <= start_priority_check;  --Fixed priority scheme.
			else
				next_s <= reset_s;  --Error if no method is specified.
			end if;	
			DataBus <= (others => 'Z');
		when start_polling =>     --Check for interrupts(one by one) using polling method.
			if( IR(int_index) = '1' ) then
				INTR_O <= '1';
				next_s <= tx_int_info_polling;
			else
				INTR_O <= '0';
			end if;
			if( int_index = 7 ) then
				int_index <= 0;
			else	
				int_index <= int_index+1;				
			end if;	
			DataBus <= (others => 'Z');
		when tx_int_info_polling =>	 --Transmit interrupt information if an interrupt is found.
			if( INTA_I = '0' ) then
				INTR_O <= '0';
			end if;	
			if( flag = '0' ) then
				DataBus <= "01011" & to_unsigned( (int_index-1),3);  --MSB "01011" is for matching purpose.
				flag1 <= '1';
			else
				flag1 <= '0';
			end if;
			if ( flag1 = '1' ) then
				next_s <= ack_txinfo_rxd;
				if( INTA_I = '0' ) then
					DataBus <= (others => 'Z');
				end if;	
			end if;	
		when ack_txinfo_rxd =>   --ACK send by processor to tell PIC that interrupt info is received correctly.
			if( INTA_I <= '0' ) then
				next_s <= ack_ISR_done;
				DataBus <= (others => 'Z');
			end if;	
		when ack_ISR_done =>  --Wait for the ISR for the particular interrupt to get over.
			if( INTA_I = '0' and DataBus(7 downto 3) = "10100" and DataBus(2 downto 0) = to_unsigned(int_index-1,3) ) then
				next_s <= start_polling;
			else
				next_s <= ack_ISR_done;
			end if;	
		when start_priority_check =>   --Fixed priority method for interrupt handling.
		--Interrupts are checked based on their priority.
			if( IR(to_integer(pt(0))) = '1' ) then
				int_pt <= pt(0);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;
			elsif( IR(to_integer(pt(1))) = '1' ) then
				int_pt <= pt(1);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;
			elsif( IR(to_integer(pt(2))) = '1' ) then
				int_pt <= pt(2);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;
			elsif( IR(to_integer(pt(3))) = '1' ) then
				int_pt <= pt(3);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;
			elsif( IR(to_integer(pt(4))) = '1' ) then
				int_pt <= pt(4);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;
			elsif( IR(to_integer(pt(5))) = '1' ) then
				int_pt <= pt(5);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;
			elsif( IR(to_integer(pt(6))) = '1' ) then
				int_pt <= pt(6);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;
			elsif( IR(to_integer(pt(7))) = '1' ) then
				int_pt <= pt(7);
				INTR_O <= '1';
				next_s <= tx_int_info_priority;	
			else
				next_s <= start_priority_check;
			end if;	
			DataBus <= (others => 'Z');
		when tx_int_info_priority =>      --Transmit interrupt information if an interrupt is found.
			if( INTA_I = '0' ) then
				INTR_O <= '0';
			end if;	
			if( flag = '0' ) then
				DataBus <= "10011" & int_pt;  --MSB "10011" is for matching purpose.
				flag1 <= '1';
			else
				flag1 <= '0';
			end if;
			if ( flag1 = '1' ) then
				next_s <= ack_txinfo_rxd_priority;
				if( INTA_I = '0' ) then
					DataBus <= (others => 'Z');
				end if;	
			end if;	
		when ack_txinfo_rxd_priority =>   --ACK send by processor to tell PIC that interrupt info is received correctly.
			if( INTA_I <= '0' ) then
				next_s <= ack_ISR_done_pt;
				DataBus <= (others => 'Z');
			end if;
		when ack_ISR_done_pt =>   --Wait for the ISR for the particular interrupt to get over.
			if( INTA_I = '0' and DataBus(7 downto 3) = "01100" and DataBus(2 downto 0) = int_pt ) then
				next_s <= start_priority_check;
			elsif( DataBus(7 downto 3) /= "01100" or DataBus(2 downto 0) /= int_pt ) then
				next_s <= reset_s;   --Error.
			else
				next_s <= ack_ISR_done_pt;
			end if;	
		when others =>
			DataBus <= (others => 'Z');	
	end case;	
end if;	
end process;

end Behavioral;

