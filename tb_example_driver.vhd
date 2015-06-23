-- Filename:     tb_example_driver.vhd
-- Filetype:     VHDL Testbench
-- Date:         26 oct 2012
-- Update:       -
-- Description:  VHDL testbench for example driver
-- Author:       J. op den Brouw
-- State:        Demo
-- Error:        -
-- Version:      1.0alpha
-- Copyright:    (c)2012, De Haagse Hogeschool

-- This file contains a very simple VHDL testbench for a User Side
-- driver for the LCD driver.
-- 

-- Libraries et al.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The entity of a testbench for the example driver
entity tb_example_driver is
end entity tb_example_driver;

-- The architecture!
architecture sim of tb_example_driver is
-- Component declaration of the example driver
component example_driver is
	port (CLOCK_50 : in std_logic;
			BUTTON   : in std_logic_vector(2 downto 0);
			SW       : in std_logic_vector(9 downto 0);
			LEDG     : out std_logic_vector(9 downto 0);
			HEX3_D   : out std_logic_vector(6 downto 0);
			HEX2_D   : out std_logic_vector(6 downto 0);
			HEX1_D   : out std_logic_vector(6 downto 0);
			HEX0_D   : out std_logic_vector(6 downto 0);
			HEX0_DP  : out std_logic;
			HEX1_DP  : out std_logic;
			HEX2_DP  : out std_logic;
			HEX3_DP  : out std_logic;
			-- LCD of the DE0 board
			LCD_EN   : out std_logic;
			LCD_RS   : out std_logic;
			LCD_RW   : out std_logic;
			LCD_DATA : inout std_logic_vector(7 downto 0);
			LCD_BLON : out std_logic
	);
end component example_driver;

signal CLOCK_50 : std_logic;
signal BUTTON   : std_logic_vector(2 downto 0);
signal SW       : std_logic_vector(9 downto 0);
signal LEDG     : std_logic_vector(9 downto 0);
signal HEX3_D   : std_logic_vector(6 downto 0);
signal HEX2_D   : std_logic_vector(6 downto 0);
signal HEX1_D   : std_logic_vector(6 downto 0);
signal HEX0_D   : std_logic_vector(6 downto 0);
signal HEX0_DP  : std_logic;
signal HEX1_DP  : std_logic;
signal HEX2_DP  : std_logic;
signal HEX3_DP  : std_logic;
-- LCD of the DE0 board
signal LCD_EN   : std_logic;
signal LCD_RS   : std_logic;
signal LCD_RW   : std_logic;
signal LCD_DATA : std_logic_vector(7 downto 0);
signal LCD_BLON : std_logic;

--constant freq_in : integer := 10000; -- 10 kHz
constant freq_in : integer := 50000000; -- 50 MHz
constant clock_period : time := (1.0/real(freq_in)) * (1 sec);

-- Internal tracer
signal trace : integer;

begin

	-- The driver's driver...
	de0: example_driver
	port map (CLOCK_50 => CLOCK_50, BUTTON => BUTTON, SW => SW, LEDG => LEDG,
	          HEX3_D => HEX3_D, HEX2_D => HEX2_D, HEX1_D => HEX1_D, HEX0_D => HEX0_D,
				 HEX0_DP => HEX0_DP, HEX1_DP => HEX1_DP, HEX2_DP => HEX2_DP, HEX3_DP => HEX3_DP,
				 LCD_EN => LCD_EN, LCD_RS => LCD_RS, LCD_RW => LCD_RW, LCD_DATA => LCD_DATA,
				 LCD_BLON => LCD_BLON);

	-- The clock signal generation process
	clockgen: process is
	begin
		-- give time for reset, buttons active low!
		CLOCK_50 <= '0';
		BUTTON <= "110";
		wait for 15 ns;
		BUTTON <= "111";
		wait for 5 ns;
		-- forever: generate clock cycle for 20 ns and 50% d.c.
		loop
			CLOCK_50 <= '1';
			wait for clock_period/2;
			CLOCK_50 <= '0';
			wait for clock_period/2;
		end loop;
	end process;
	
	-- Simple simulation description of the LCD itself...
	-- (probably too simple)
	lcd_module_sim: process is
	begin
		trace <= 0;
		LCD_DATA <= (others => 'Z');
		-- Wait for reset clear
		wait until BUTTON(0) = '0';
		trace <= 1;
		-- Three writes to the LCD, no busy flag testing possible
		wait until LCD_EN = '1';
		wait until LCD_EN = '1';
		wait until LCD_EN = '1';
		trace <= 2;
		
		loop
			-- command/data written to
			trace <= 3;
			wait until LCD_EN = '1';
			trace <= 4;
			wait until LCD_EN = '0';
			
			-- busy flag reading
			trace <= 5;
			wait until LCD_EN = '1';
			trace <= 6;
			if LCD_RW = '1' then
				trace <= 61;
				-- Signal LCD is busy
				LCD_DATA <= "1ZZZZZZZ";
				-- Internal delay of the LCD for some commands
				wait for 40 us; 
				-- Signal LCD is ready
				LCD_DATA <= "0ZZZZZZZ";
			end if;
			wait until LCD_EN = '0';
			trace <= 7;
			if LCD_RW = '1' then
				trace <= 1;
				LCD_DATA <= "ZZZZZZZZ";
			end if;
			
		end loop;
		wait;
	end process;

end architecture sim;