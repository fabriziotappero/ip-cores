-- Filename:     example_driver.vhd
-- Filetype:     VHDL Source Code
-- Date:         26 oct 2012
-- Update:       -
-- Description:  VHDL Description of example driver
-- Author:       J. op den Brouw
-- State:        Demo
-- Error:        -
-- Version:      1.1alpha
-- Copyright:    (c)2012, De Haagse Hogeschool

-- This VHDL code is a example description on how to use the
-- HD44780 LCD display driver module. It writes 4x16 characters
-- to the display, presuming that the display has four lines.
--
-- This code is tested on a Terasic DE0-board with an optional
-- LCD display. See the weblinks
-- http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=56&No=364
-- http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=78&No=396
-- for more info. The display used has only two lines.

-- After a line has written completely, the cursor is moved to
-- the beginning of the next line. After the last line is written,
-- this code goes into hold mode.
--

-- Libraries et al.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- The entity of a Terasic DE0-board.
entity example_driver is
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
	
end entity example_driver;

-- The architecture!
architecture hardware of example_driver is
-- Component declaration of the LCD module
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

-- The system's frequency
constant sys_freq : integer := 50000000;

signal areset   : std_logic;
signal clk      : std_logic;
signal init     : std_logic;
signal data     : std_logic_vector(7 downto 0);
signal wr       : std_logic;
signal cls      : std_logic;
signal home     : std_logic;
signal goto10   : std_logic;
signal goto20   : std_logic;
signal goto30   : std_logic;
signal busy		 : std_logic;

type state_type is (reset, write_char, write_char_wait, update, update_linecount,
						  update_linecount_wait, write_char_1, write_char_1_wait,
						  write_char_2, write_char_2_wait, write_char_3, write_char_4, hold,
						  hold2);
signal state : state_type;

-- A string of 16 characters
subtype string16_type is string(1 to 16);
-- An array of 4 strings of 16 characters.
type message4x16_type is array (1 to 4) of string16_type;

-- The four-line message
constant message : message4x16_type :=
							( 1 => "1Elektrotechniek",
							  2 => "2  LCD HD44780  ",
							  3 => "3Driver in VHDL!",
							  4 => "4J. op den Brouw");

-- Counts the characters on a line.
signal character_counter : integer range 1 to 16;
-- Counts the lines.
signal line_counter : integer range 1 to 4;

begin

	-- Push buttons are active low.
	areset <= not BUTTON(0);

	-- The clock
	clk <= CLOCK_50;
	
	-- Use LCD module.
	lcdm : lcd_driver_hd44780_module
	generic map (freq => sys_freq, areset_pol => '1', time_cycle_e => 2000 ns, time_pweh => 500 ns,
					 cursor_on => false, blink_on => false, use_bf => false)
	port map (clk => clk, areset => areset, init => init, data => data, wr => wr, cls => cls,
				 home => home, goto10 => goto10, goto20 => goto20, goto30 => goto30, busy => busy,
				 LCD_E => LCD_EN, LCD_RS => LCD_RS, LCD_RW => LCD_RW, LCD_DB => LCD_DATA);
				 
	-- The client side
	drive: process (clk, areset) is
	variable aline : string16_type;
	begin
		if areset = '1' then
			wr <= '0';
			init <= '0';
			cls <= '0';
			home <= '0';
			goto10 <= '0';
			goto20 <= '0';
			goto30 <= '0';
			LEDG(0) <= '0';
			data <= "00000000";
			character_counter <= 1;
			state <= reset;
		elsif rising_edge(clk) then
			wr <= '0';
			init <= '0';
			cls <= '0';
			home <= '0';
			goto10 <= '0';
			goto20 <= '0';
			goto30 <= '0';
			LEDG(0) <= '0';
			data <= "00000000";
			case state is

				when reset =>
					-- Wait for the LCD module ready
					if busy = '0' then
						state <= write_char;
					end if;
					-- Setup message counter, start at 1.
					character_counter <= 1;
					line_counter <= 1;
					
				when write_char =>
					LEDG(0) <= '1';
					-- Set up WRITE!
					-- Use the data from the string
					aline := message(line_counter);
					data <= std_logic_vector( to_unsigned( character'pos(aline(character_counter)),8));
 					wr <= '1';
					state <= write_char_wait;

				when write_char_wait =>
					-- This state is needed so that the LCD driver
					-- can process the write command. Note that data
					-- and wr are registered outputs and get their
					-- respective values while in *this* state. If you don't
					-- want this behaviour, please make your outputs
					-- non-registered.
					state <= update;
					
				when update =>
					LEDG(0) <= '1';
					-- Wait for the write complete
					if busy = '0' then
						-- If end of string, goto hold mode...
						if line_counter = 4 and character_counter = 16 then
							state <= hold;
						-- If end of line...	
						elsif character_counter = 16 then
							case line_counter is
								when 1 => goto10 <= '1';
								when 2 => goto20 <= '1';
								when 3 => goto30 <= '1';
								-- Never reached, but nice anyway...
								when 4 => home <= '1';
								when others => null;
							end case;
							-- Set new values of the counters
							line_counter <= line_counter+1;
							character_counter <= 1;
							-- Goto the update state
							state <= update_linecount;
						else
						   -- Not the end of a lines, update the character counter.
							character_counter <= character_counter+1;
							state <= write_char;
						end if;
					end if;
				
				when update_linecount =>
					-- This state is needed so that the LCD driver
					-- can process the gotoXX command. Note that the gotoXX
					-- signals are registered outputs and get their
					-- respective values while in *this* state. If you don't
					-- want this behaviour, please make your outputs
					-- non-registered.
					state <= update_linecount_wait;
					
				when update_linecount_wait =>
					-- Wait for the LCD module ready
					if busy = '0' then
						state <= write_char;
					end if;
				
				-- The "hohouwer"
				when hold =>
					--state <= hold;
					state <= hold2;
					home <= '1';
				when hold2 =>
					state <= reset;
					
				when others =>
					null;

			end case;
		end if;
	end process;
				 
		-- The unused outputs...
	HEX3_D <= (others => '1');
	HEX2_D <= (others => '1');
	HEX1_D <= (others => '1');
	HEX0_D <= (others => '1');
	
	HEX3_DP <= '1';
	HEX2_DP <= '1';
	HEX1_DP <= '1';
	HEX0_DP <= '1';
	
	LEDG(9 downto 1) <= (others => '0');
	
	-- Sadly, the LCD doesn't have a backlight...
	LCD_BLON <= '0';

end architecture hardware;