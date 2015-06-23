-- Filename:     tb_lcd_driver_hd44780_module.do
-- Filetype:     VHDL Testbench
-- Date:         26 oct 2012
-- Update:       -
-- Description:  VHDL Testbench for simulation
-- Author:       J. op den Brouw
-- State:        Demo
-- Error:        -
-- Version:      1.1alpha
-- Copyright:    (c)2012, De Haagse Hogeschool

-- This file contains a very simple VHDL testbench for a HD44780 LCD
-- display, see more specs at
-- 
-- This VHDL code implements a simple testbench for testing
-- the LCD Module Driver. More scripting should be done here.

-- The libraries et al.
library ieee;
use ieee.std_logic_1164.all;

-- Empty entity
entity tb_lcd_driver_hd44780_module is
end entity tb_lcd_driver_hd44780_module;

-- The testbench
architecture sim of tb_lcd_driver_hd44780_module is
-- The LCD driver
component lcd_driver_hd44780_module is
	generic (freq         : integer := 50000000;
				areset_pol   : std_logic := '1';
				time_init1   : time := 40 ms;
				time_init2   : time := 4100 us;
				time_init3   : time := 100 us;
				time_tas     : time := 60 ns;
				time_cycle_e : time := 1000 ns;
				time_pweh    : time := 500 ns;
				time_no_bf   : time := 2 ms;
				cursor_on    : boolean := false;
				blink_on     : boolean := false;
				use_bf       : boolean := true
			  );
	port	  (clk      : in std_logic;
			   areset   : in std_logic;
			   -- User site
			   init     : in std_logic;
  			   data     : in std_logic_vector(7 downto 0);
			   wr       : in std_logic;
			   cls      : in std_logic;
			   home     : in std_logic;
			   goto10   : in std_logic;
			   goto20   : in std_logic;
			   goto30   : in std_logic;
			   busy     : out std_logic;
			   -- LCD side
			   LCD_E    : out std_logic;
			   LCD_RS   : out std_logic;
			   LCD_RW   : out std_logic;
			   LCD_DB   : inout std_logic_vector(7 downto 0)
			  );
end component lcd_driver_hd44780_module;

-- Glue signals
signal clk     : std_logic;
signal areset  : std_logic;
-- User site
signal init    : std_logic;
signal data    : std_logic_vector(7 downto 0);
signal wr      : std_logic;
signal cls     : std_logic;
signal home    : std_logic;
signal goto10  : std_logic;
signal goto20  : std_logic;
signal goto30  : std_logic;
signal busy    : std_logic;
-- LCD side
signal LCD_DB  : std_logic_vector(7 downto 0);
signal LCD_E   : std_logic;
signal LCD_RW  : std_logic;
signal LCD_RS  : std_logic;

--constant freq_in : integer := 10000; -- 10 kHz
constant freq_in : integer := 50000000; -- 50 MHz
constant clock_period : time := (1.0/real(freq_in)) * (1 sec);

-- Internal tracer
signal trace : integer;

-- Now let's begin...
begin

	-- Instantiation of the LCD Driver, some generics are used
	lcdm : lcd_driver_hd44780_module
	generic map (freq => freq_in, areset_pol => '1', time_cycle_e => 2000 ns, time_pweh => 500 ns,
					 cursor_on => true, blink_on => true, use_bf => false)
	port map (clk => clk, areset => areset, init => init, data => data, wr => wr, cls => cls,
				 home => home, goto10 => goto10, goto20 => goto20, goto30 => goto30, busy => busy,
				 LCD_DB => LCD_DB, LCD_E => LCD_E, LCD_RW => LCD_RW, LCD_RS => LCD_RS);

	-- The clock signal generation process
	clockgen: process is
	begin
		-- give time for reset
		clk <= '0';
		areset <= '1';
		wait for 15 ns;
		areset <= '0';
		wait for 5 ns;
		-- forever: generate clock cycle for 20 ns and 50% d.c.
		loop
			clk <= '1';
			wait for clock_period/2;
			clk <= '0';
			wait for clock_period/2;
		end loop;
	end process;

	-- Simulating the user side of the driver
	user_side: process is
	begin
		-- All at zero
		init <= '0';
		cls <= '0';
		home <= '0';
		goto10 <= '0';
		goto20 <= '0';
		goto30 <= '0';
		wr <= '0';
		data <= (others => '0');
		wait until clk = '1';
		
		-- wait for initialization to complete
		wait until busy = '0';
		
		-- Write data to LCD
		wait until clk = '1';
		data <= "01000011";
		wr <= '1';
		wait until clk = '1';
		wr <= '0';
		wait until busy = '0';
		wait until clk = '1';
		-- Write data to LCD
		data <= "01000011";
		wr <= '1';
		wait until clk = '1';
		wr <= '0';
		wait until busy = '0';
		wait until clk = '1';
		
		-- Clear the screen
		wait until clk = '1';
		cls <= '1';
		wait until clk = '1';
		cls <= '0';
		wait until busy = '0';

		-- Home the screen
		wait until clk = '1';
		home <= '1';
		wait until clk = '1';
		home <= '0';
		wait until busy = '0';

		-- Goto line
		wait until clk = '1';
		goto10 <= '1';
		wait until clk = '1';
		goto10 <= '0';
		wait until busy = '0';
		wait until clk = '1';
		goto20 <= '1';
		wait until clk = '1';
		goto20 <= '0';
		wait until busy = '0';
		wait until clk = '1';
		goto30 <= '1';
		wait until clk = '1';
		goto30 <= '0';
		wait until busy = '0';

		-- Write data to LCD
		wait until clk = '1';
		wr <= '1';
		wait until clk = '1';
		wr <= '0';
		wait until busy = '0';
		wait until clk = '1';

		-- Initialize the LCD
		wait until clk = '1';
		init <= '1';
		wait until clk = '1';
		init <= '0';
		wait until busy = '0';
		wait until clk = '1';
		
		wait;
	end process;
	
	-- Simple simulation description of the LCD itself...
	-- (probably too simple)
	lcd_module_sim: process is
	begin
		trace <= 0;
		LCD_DB <= (others => 'Z');
		-- Wait for reset clear
		wait until areset = '0';
		trace <= 1;
		-- Three writes to the LCD, no busy flag testing possible
		wait until LCD_E = '1';
		wait until LCD_E = '1';
		wait until LCD_E = '1';
		trace <= 2;
		
		loop
			-- command/data written to
			trace <= 3;
			wait until LCD_E = '1';
			trace <= 4;
			wait until LCD_E = '0';
			
			-- busy flag reading
			trace <= 5;
			wait until LCD_E = '1';
			trace <= 6;
			if LCD_RW = '1' then
				trace <= 61;
				-- Signal LCD is busy
				LCD_DB <= "1ZZZZZZZ";
				-- Internal delay of the LCD for some commands
				wait for 40 us; 
				-- Signal LCD is ready
				LCD_DB <= "0ZZZZZZZ";
			end if;
			wait until LCD_E = '0';
			trace <= 7;
			if LCD_RW = '1' then
				trace <= 1;
				LCD_DB <= "ZZZZZZZZ";
			end if;
			
		end loop;
		wait;
	end process;
				 
end architecture;