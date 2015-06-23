----------------------------------------------------------------------------------
-- Company: 		University of Southern Denmark
-- Engineer: 		Anders Sørensen
-- 
-- Create Date:    	30/11/2009 
-- Design Name: 	uTosNet
-- Module Name:    	uTosNet_top - Behavioral 
-- File Name:		uTosNet_top.vhd
-- Project Name: 	uTosNet
-- Target Devices: 	SDU XC3S50AN Board
-- Tool versions: 	Xilinx ISE 11.4
-- Description: 	SDU/TEK/Embedix Spartan-3 50AN experimentation board +
--					Expansion board with: USB + Ethernet + VGA.
--					Example uTosNet application (over USB UART)
--					Use serial port setting: 115200 bps 8N1
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

-- Here we define the I/O connections from the example
-- Since this is the top level, the connections all go to the outside world
entity UTNX_top is
	Port (	CLK_50M_I		: in	STD_LOGIC;						-- 50 MHz from onboard oscillator
			LEDS_O			: out	STD_LOGIC_VECTOR(1 downto 0);	-- Two onboard LED's
			XB_SERIAL_O		: out	STD_LOGIC;						-- Serial stream to PC
			XB_SERIAL_I		: in	STD_LOGIC;						-- Serial stream from PC
			XB_LEDS_O		: out	STD_LOGIC_VECTOR(2 downto 0);	-- 3 LED's on expansion board
			XB_DIPSW_I		: in	STD_LOGIC_VECTOR(3 downto 0);	-- 4 dip switches
			BB_OUT_O		: out	STD_LOGIC_VECTOR(2 downto 0);	-- 3 outputs on breadboard
			BB_LEDS_O		: out	STD_LOGIC_VECTOR(7 downto 0));	-- 8 LED's on breadboard
end UTNX_top;

architecture Behavioral of UTNX_top is

-- Here we define the components we want to include in our design (there is only one)
-- The Port description is just copied from the components own source file
	COMPONENT uTosNet_ctrl is
	Port (	T_clk_50M						: in	STD_LOGIC;
			T_serial_out					: out	STD_LOGIC;
			T_serial_in						: in	STD_LOGIC;
			T_reg_ptr						: out	std_logic_vector(2 downto 0);
			T_word_ptr						: out	std_logic_vector(1 downto 0);
			T_data_to_mem					: in	std_logic_vector(31 downto 0);
			T_data_from_mem					: out	std_logic_vector(31 downto 0);
			T_data_from_mem_latch			: out	std_logic);
	END COMPONENT;

-- Here we define the signals used by the top level design
	signal clk_50M					: std_logic;
	signal sys_cnt					: std_logic_vector(31 downto 0) := (others => '0');
	signal freq_gen					: std_logic_vector(31 downto 0) := (others => '0');
	signal freq_out					: std_logic := '0';
	signal bb_leds					: std_logic_vector(7 downto 0);  -- register for 8 leds
	signal dipsw					: std_logic_vector(3 downto 0);
	signal frq,flsh,pwm				: std_logic;

-- The signals below is used to hold data for our I/O application
	signal pwm_value				: std_logic_vector(15 downto 0); -- 16 bit register for pwm value
	signal period					: std_logic_vector(31 downto 0); -- 32 bit register for freq generator
	signal flash					: std_logic_vector(7 downto 0); -- 8 bit register for flash duration
	signal v_leds					: std_logic_vector(31 downto 0); -- 32 bit register to hold status for variable leds 

-- Signals below is used to connect to the uTosNet Controller component  
	signal T_reg_ptr				: std_logic_vector(2 downto 0);
	signal T_word_ptr				: std_logic_vector(1 downto 0);
	signal T_data_to_mem			: std_logic_vector(31 downto 0);
	signal T_data_from_mem			: std_logic_vector(31 downto 0);
	signal T_data_from_mem_latch	: std_logic;
	

begin

-- Here we instantiate the uTosNet Controller component, and connect its ports to signals	
	uTosNet_ctrlInst : uTosNet_ctrl
	Port map (	T_clk_50M => clk_50M,
				T_serial_out => XB_SERIAL_O,
				T_serial_in => XB_SERIAL_I,
				T_reg_ptr => T_reg_ptr,					
				T_word_ptr => T_word_ptr,									
				T_data_to_mem => T_data_to_mem,					
				T_data_from_mem => T_data_from_mem,						
				T_data_from_mem_latch => T_data_from_mem_latch);

-- It's not necessary to transfer these ports to signals, we just think it makes the syntax nicer
-- to avoid referring to ports in the body of the code. The compiler will optimize identical signals away
	clk_50M <= CLK_50M_I;
	BB_LEDS_O <= bb_leds;
	dipsw <= XB_DIPSW_I;
	
-- here we define 3 signals used for output
	frq  <= freq_out;
	pwm  <= '1' when pwm_value > sys_cnt(15 downto 0) else '0';
	flsh <= '1' when (sys_cnt(25 downto 24) = 0) and (sys_cnt(23 downto 16) < flash) else '0';
	
-- here we map the above 3 sigals to both breadboard outputs, and expansion board LED's	
	BB_OUT_O(0) <= frq;
	BB_OUT_O(1) <= pwm;
	BB_OUT_O(2) <= flsh;
	
	XB_LEDS_O(0) <= frq;
	XB_LEDS_O(1) <= pwm;
	XB_LEDS_O(2) <= flsh;

-- Here we map some bits from the system counter to onboard LED's, as an 'alive' marker
	LEDS_O <= sys_cnt(25 downto 24); 	
	
---------------------------------------------------------
-- Clocked process, to take data off the controller bus	
----------------------------------------------------------
	DatFromTosNet: 	
	process(clk_50M)
	begin -- process
		if (clk_50M'event and clk_50M='1' and T_data_from_mem_latch='1') then
			case (T_reg_ptr & T_word_ptr) is                        -- The addresses are concatenated for compact code
				when "00000" => period		<= T_data_from_mem;               -- Register 0, word 0 - all 32 bits
				when "00001" => pwm_value	<= T_data_from_mem(15 downto 0);  -- Register 0, word 1 - low 16 bits
								flash		<= T_data_from_mem(31 downto 24); --                      high 8 bits
				when "00100" => v_leds 		<= T_data_from_mem;               -- Register 1, word 0 - all 32 bits
				when others =>
			end case;
		end if;
	end process;

----------------------------------------------------------
-- Unclocked process, to place data on the controller bus
----------------------------------------------------------
	DatToTosNet:
	process(T_reg_ptr,T_word_ptr)
	begin
		T_data_to_mem<="00000000000000000000000000000000";	-- default data
		case (T_reg_ptr & T_word_ptr) is                   -- The addresses are concatenated for compact code
			-- Register 0, word 0-3 are hard coded to these values for test/demo purposes
			when "00000" =>	T_data_to_mem <= "00000000000000000000000000000001"; -- 1
			when "00001" =>	T_data_to_mem <= "00000000000000000000000000000010"; -- 2
			when "00010" => T_data_to_mem <= "00000000000000000000000000000100"; -- 3
			when "00011" => T_data_to_mem <= "00000000000000000000000000001000"; -- 4
			-- Register 1
			when "00100" =>	T_data_to_mem <= sys_cnt;  -- Word 0 gives the value of the system counter
			when "00101" =>	T_data_to_mem <= freq_gen; -- Word 1 gives the value of the frequency generator
			-- register 2
			when "01000" => T_data_to_mem <= "0000000000000000000000000000" & dipsw;
			--       Etc. etc. etc.
			when others =>
		end case;		
	end process;

---------------------------------------------------------------------
-- Clocked process, that counts clk_50M edges
---------------------------------------------------------------------
	SystemCounter:
	process(clk_50M)
	begin -- process
		if(clk_50M'event and clk_50M='1') then
			sys_cnt<=sys_cnt+1;
	end if;
	end process;

-----------------------------------------------------------------
-- Clocked process to generate a square wave with variable period
-----------------------------------------------------------------
	FreqGen:
	process(clk_50M)
	begin -- process
		if (clk_50M'event and clk_50M='1') then
			if period = 0 then
				freq_gen <= (others => '0');
				freq_out <= '0';
			elsif freq_gen > period then
				freq_gen <= (others => '0');
				freq_out <= not freq_out;
			else
				freq_gen <= freq_gen +1;
			end if;
		end if;
	end process;

-------------------------------------------------------
-- Unclocked proces to generate 8 pwm outputs for LEDS
-------------------------------------------------------
	process(sys_cnt)
		variable i : integer range 1 to 8;
	begin -- process
		for i in 1 to 8 loop
			if(v_leds((i*4)-1 downto (i-1)*4) > sys_cnt(13 downto 10)) then
				bb_leds(i-1) <= '1';
			else
				bb_leds(i-1) <='0';
			end if;		  
		end loop;
	end process;
  

end Behavioral;

