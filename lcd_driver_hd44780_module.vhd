-- Filename:     lcd_driver_hd44780_module.vhd
-- Filetype:     VHDL Source Code
-- Date:         26 oct 2012
-- Update:       -
-- Description:  VHDL Description for driving an HD44780 based LCD driver
-- Author:       J. op den Brouw
-- State:        Demo
-- Error:        -
-- Version:      1.2alpha
-- Copyright:    (c)2012, De Haagse Hogeschool

-- This file contains a VHDL description for driving an HD44780 based LCD
-- driver, see for a standard information of such a display:
-- https://decibel.ni.com/content/servlet/JiveServlet/download/2741-3-3217/hd44780.pdf
--
-- Currently, this driver uses the 8-bit databus mode. This is not a big problem
-- for most FPGA's because of the numerous pins.
--
-- Please note that there are a lot of almost-the-same displays available, so
-- it's not guaranteed to work with all displays available. Also, timing may differ.
--
-- This code is tested on a Terasic DE0-board with an optional
-- LCD display. See the weblinks
-- http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=56&No=364
-- http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=78&No=396
-- for more info. The display used has only two lines.
--
-- This VHDL description can both be simulated and synthesized.
--
-- This driver has a User Side and a LCD Side. The user is to interface at the User Side
-- and has a number of "routines" at her disposal. The User Side implements the following
-- inputs/routines in order of priority:
--
-- Command inputs:
--     init:   a logic 1 initializes the display
--     cls:    a logic 1 clears the display (and goes to home)
--     home:   a logic 1 sets the cursor to row 0, column 0
--     goto10: a logic 1 sets the cursor to row 1, column 0
--     goto20: a logic 1 sets the cursor to row 2, column 0
--     goto30: a logic 1 sets the cursor to row 3, column 0
--     wr:     a logic 1 writes a character to the display
--
-- Data inputs:
--
--     data:   an 8-bit data to be written to the display
--
-- The user has one observable output:
--
--     busy:   a logic 1 indicates that the driver is currently
--             busy driving the display, a logic 0 indicates that
--             the driver waits for the next command.
--
-- The user can supply the next generics, which are processed at
-- instantiation of the module:
--
--	    freq:   the clock frequency at which the hardware has to run.
--             this frequency is mandatory because of internal delays
--             calculated, defaults to 50 MHz.
--     areset_pol:
--             the polarity of the reset signal, defaults to High (1)
--     time_init1:
--             the time to wait after Vcc > 4.5 V 
--     time_init2:
--             the time to wait after first "contact"
--     time_init3:
--             the time to wait after the second contact
--     time_tas:
--             the RW and RS signal setup time with respect to the positive
--             edge of the E pulse
--     time_cycle_e:
--             the complete cycle time
--     time_pweh:
--             the E pulse width high time
--     time_no_bf:
--             time to wait before command completion if no Busy Flag reading is done,
--             some designs connect RW to logic 0, so reading from the LCD is not
--             possible, saves a pin.
--     cursor_on:
--             true to set the cursor on at the display, false for no cursor--     blink_on:
--             true to let the cursor blink, false for no blink (just a underscore)
--     use_bf: true if Busy Flag reading is to be used, false for no BF reading
--
-- Note: it's not possible to write command codes to the display.
--
-- Changes to v1.0:  LCD_E is renamed to LCD_EN
--                   LCD_DB is renamed to LCD_DATA
--                   busy is now registered
--                   removed hardware simulation architecture
--
-- Changes to v1.1:  added timing generics for better steering of the E pulse cycle
--                   implemented cursor on/off/blink with generic parameters
--
-- Changes to v1.2:  added Busy Flag reading mode, selectable at instantiation time
--                   LCD_EN changes back to LCD_E
--                   LCD_DATA changed back to LCD_DB
--
-- To do:            use 4-bit mode or 8-bit mode at instantiation time
--

-- The libraries to use.
library ieee;
use ieee.std_logic_1164.all;

-- The entity of the LCD Driver Module.
entity lcd_driver_hd44780_module is
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
end entity lcd_driver_hd44780_module;

-- This architecture drives the LCD.
architecture hardware_driver of lcd_driver_hd44780_module is

-- Delays... Please note that if the frequency is (too) low,
-- some of the delays will 0. The code will take care of that.
-- Converting time to integer is problematic. Please note the use of
-- the simulator time step in the calculations.
-- The simulator timestep
constant simulator_timestep : time := 1 ns;
-- Number of simulator timesteps per second.
constant sim_steps_per_sec : real := real(1 sec/simulator_timestep);

constant delay_init1   : integer := integer( real(freq) * real(time_init1/simulator_timestep) / sim_steps_per_sec);
constant delay_init2   : integer := integer( real(freq) * real(time_init2/simulator_timestep) / sim_steps_per_sec);
constant delay_init3   : integer := integer( real(freq) * real(time_init3/simulator_timestep) / sim_steps_per_sec);
constant delay_tas     : integer := integer( real(freq) * real(time_tas/simulator_timestep) / sim_steps_per_sec);
constant delay_cycle_e : integer := integer( real(freq) * real(time_cycle_e/simulator_timestep) / sim_steps_per_sec);
constant delay_pweh    : integer := integer( real(freq) * real(time_pweh/simulator_timestep) / sim_steps_per_sec);
constant delay_no_bf   : integer := integer( real(freq) * real(time_no_bf/simulator_timestep) / sim_steps_per_sec);

-- The next statements do work in Quartus but not in (32 bit) ModelSim...
--constant delay_init1   : integer := integer(real(freq)*real(time'pos(time_init1)) / real(time'pos(1 sec)));
--constant delay_init2   : integer := integer(real(freq)*real(time'pos(time_init2)) / real(time'pos(1 sec)));
--constant delay_init3   : integer := integer(real(freq)*real(time'pos(time_init3)) / real(time'pos(1 sec)));
--constant delay_tas     : integer := integer(real(freq)*real(time'pos(time_tas)) / real(time'pos(1 sec)));
--constant delay_cycle_e : integer := integer(real(freq)*real(time'pos(time_cycle_e)) / real(time'pos(1 sec)));
--constant delay_pweh    : integer := integer(real(freq)*real(time'pos(time_pweh)) / real(time'pos(1 sec)));
--constant delay_no_bf   : integer := integer(real(freq)*real(time'pos(time_no_bf)) / real(time'pos(1 sec)));

-- Time the E signal must be low following E high
constant delay_pwel    : integer := delay_cycle_e-delay_pweh;

-- Counter for the delays. Timer would be a better choice.
-- Range should be to the longest delay.
signal delay_counter : integer range 0 to delay_init1;

-- Should we use Busy Flag reading?
signal use_bf_int : std_logic;

-- The states of the state machine.
type state_type is (reset, command_init, command_init_1, command_init_2, command_init_3,
						  command_init_4, command_init_5, command_init_6, command_init_7, command_init_8,
						  command_init_9, command_init_10, command_init_11, command_init12,
						  wait_for_command,
						  command_cls, command_home,
						  command_goto10, command_goto20, command_goto30, command_wr,						  
						  pulse_e, pulse_e_1, pulse_e_2, pulse_e_3, pulse_e_4,
						  pulse_busy_flag, pulse_busy_flag_1, pulse_busy_flag_2, pulse_busy_flag_3,
						  pulse_busy_flag_4, pulse_busy_flag_5);
						  

-- The current state and one for the return state (to facilitate return to the caller).
signal current_state, return_state : state_type;
begin

	-- The state machine ;-)
	nsl_state: process (clk, areset) is
		-- Function to translate a boolean to std_logic
		function bool_to_stdlogic(l: boolean) return std_logic is 
		begin 
        if l then 
				return('1'); 
			else 
				return('0'); 
			end if; 
		end function bool_to_stdlogic; 
	begin
		if (areset = '1' and areset_pol = '1') or (areset = '0' and areset_pol = '0') then
			current_state <= reset;
			delay_counter <= 0;
			busy <= '1';
			LCD_DB <= (others => 'Z');
			LCD_E  <= '0';
			LCD_RS <= '0';
			LCD_RW <= '0';
			use_bf_int <= '0';
		elsif rising_edge(clk) then
			-- Default is busy
			busy <= '1';
			-- Default values of the LCD side
			LCD_E  <= '0';
			LCD_RW <= '0';
			case current_state is
				when reset|command_init =>
					-- The logic is reset. Start initialization routine.
					LCD_DB <= (others => 'Z');
					LCD_RS <= '0';
					use_bf_int <= '0';
					delay_counter <= delay_init1;
					current_state <= command_init_1;
				when command_init_1 =>
					-- Wait until Vcc > 4.5 V...
					LCD_DB <= (others => 'Z');
					LCD_RS <= '0';
					use_bf_int <= '0';
					-- If done write 0x30 to the LCD
					if delay_counter = 0 or delay_counter = 1 then
						LCD_DB <= "00110000";  -- 0x30
						current_state <= pulse_e;
						return_state <= command_init_2;
					else
						delay_counter <= delay_counter-1;
					end if;
				when command_init_2 =>
					-- Next, set up wait for 4.1 ms
					LCD_DB <= (others => 'Z');
					LCD_RS <= '0';
					use_bf_int <= '0';
					delay_counter <= delay_init2;
					current_state <= command_init_3;
				when command_init_3 =>
					-- Wait...
					LCD_DB <= (others => 'Z');
					LCD_RS <= '0';
					use_bf_int <= '0';
					-- If done write 0x30 to the LCD
					if delay_counter = 0 or delay_counter = 1 then
						LCD_DB <= "00110000";  -- 0x30
						current_state <= pulse_e;
						return_state <= command_init_4;
					else
						delay_counter <= delay_counter-1;
					end if;
				when command_init_4 =>
					-- Next, set up wait for 100 us
					LCD_DB <= (others => 'Z');
					LCD_RS <= '0';
					use_bf_int <= '0';
					delay_counter <= delay_init3;
					current_state <= command_init_5;
				when command_init_5 =>
					-- Wait...
					LCD_DB <= (others => 'Z');
					LCD_RS <= '0';
					use_bf_int <= '0';
					-- If done write 0x30 to the LCD
					if delay_counter = 0 or delay_counter = 1 then
						LCD_DB <= "00110000";  -- 0x30
						current_state <= pulse_e;
						return_state <= command_init_6;
					else
						delay_counter <= delay_counter-1;
					end if;
				when command_init_6 =>
					-- Power up is now done, so let's enter some reasonable values...
					LCD_DB <= "00110000";
					LCD_RS <= '0';
					use_bf_int <= bool_to_stdlogic(use_bf);
					current_state <= pulse_e;
					return_state <= command_init_7;
				when command_init_7 =>
					-- 8-bit bus, 2(?) lines, 5x7 characters
					LCD_DB <= "00111100";  -- 0x3C
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= command_init_8;
				when command_init_8 =>
					-- Display off
					LCD_DB <= "00001000";  -- 0x08
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= command_init_9;
				when command_init_9 =>
					-- Display clear
					LCD_DB <= "00000001";  -- 0x01
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= command_init_10;
				when command_init_10 =>
					-- Display on, cursor and blink...
					LCD_DB <= "000011" & bool_to_stdlogic(cursor_on) & bool_to_stdlogic(blink_on);  -- 0x0C + ...
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= command_init_11;
				when command_init_11 =>
					-- Mode set, increment cursor address, cursor shift
					LCD_DB <= "00000110";  -- 0x06
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= wait_for_command;

				-- The command dispatcher! This state waits for one of
				-- the command inputs to be logic '1' and 'starts' the
				-- accompanying routine. Note the priority encoding!
				when wait_for_command =>
					LCD_DB <= (others => 'Z');
					LCD_RS <= '0';
					busy <= '0';
					if init = '1' then
						busy <= '1';
						current_state <= command_init;
					elsif cls = '1' then
						busy <= '1';
						current_state <= command_cls;
					elsif home = '1' then
						busy <= '1';
						current_state <= command_home;
					elsif goto10 = '1' then
						busy <= '1';
						current_state <= command_goto10;
					elsif goto20 = '1' then
						busy <= '1';
						current_state <= command_goto20;
					elsif goto30 = '1' then
						busy <= '1';
						current_state <= command_goto30;
					elsif wr = '1' then
						-- Read in data! Do NOT forget that here!
						LCD_DB <= data;
						busy <= '1';
						current_state <= command_wr;
					end if;
					
				when command_cls =>
					-- Display clear
					LCD_DB <= "00000001";
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= wait_for_command;

				when command_home =>
					-- Cursor home
					LCD_DB <= "00000010";
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= wait_for_command;
					
				when command_goto10 =>
					-- Cursor to beginning of line 2nd line...
					LCD_DB <= "11000000";   --0x80+0x40;
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= wait_for_command;

				when command_goto20 =>
					-- Cursor to beginning of line 3rd line...
					LCD_DB <= "10010000";   --0x80+0x10;
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= wait_for_command;

				when command_goto30 =>
					-- Cursor to beginning of line 4th line...
					LCD_DB <= "11010000";   --0x80+0x50;
					LCD_RS <= '0';
					current_state <= pulse_e;
					return_state <= wait_for_command;

				when command_wr =>
					-- Start character write cycle
					-- Do NOT set data here!
					LCD_RS <= '1';
					current_state <= pulse_e;
					return_state <= wait_for_command;

				-- --	
				-- Provide E strobing for data transfer.
				-- Writes data byte to the LCD.
				-- Please note, DATA and RS are set by the caller!
				when pulse_e =>
					-- wait 60 ns before E -> 1 (tAS)
					delay_counter <= delay_tas;
					current_state <= pulse_e_1;
				when pulse_e_1 =>
					if delay_counter = 0 or delay_counter = 1 then
						-- timer set: E = 1 for 500 ns (PWeh)
						delay_counter <= delay_pweh;
						current_state <= pulse_e_2;
					else
						delay_counter <= delay_counter-1;
					end if;
				when pulse_e_2 =>
					LCD_E <= '1';
					if delay_counter = 0 or delay_counter = 1 then
						-- timer set: E = 0 for 500 ns (tCycleE-PWeh)
						delay_counter <= delay_pwel;
						current_state <= pulse_e_3;
					else
						delay_counter <= delay_counter-1;
					end if;
				when pulse_e_3 =>
					LCD_E <= '0';
					-- Command completion, check for use busy flag
					if delay_counter = 0 or delay_counter = 1 then
						-- If no busy flag used, wait for a amount of time.
						if use_bf_int = '0' then
							delay_counter <= delay_no_bf;
							current_state <= pulse_e_4;
						else -- BF used
							current_state <= pulse_busy_flag;
						end if;
					else
						delay_counter <= delay_counter-1;
					end if;
				when pulse_e_4 =>
					-- Wait for the delay to finsh and then return to the caller.
					if delay_counter = 0 or delay_counter = 1 then
						current_state <= return_state;
					else
						delay_counter <= delay_counter-1;
					end if;

				-- Let's read the busy flag, see if the module is busy...
				when pulse_busy_flag =>
					LCD_DB <= (others => 'Z');
					LCD_RW <= '1';
					LCD_RS <= '0';
					-- wait 60 ns before E -> 1 (tAS)
					delay_counter <= delay_tas;
					current_state <= pulse_busy_flag_1;
				when pulse_busy_flag_1 =>
					LCD_RW <= '1';
					if delay_counter = 0 or delay_counter = 1 then
						-- timer set: E = 1 for 500 ns (tPWeh)
						delay_counter <= delay_pweh;
						current_state <= pulse_busy_flag_2;
					else
						delay_counter <= delay_counter-1;
					end if;
				when pulse_busy_flag_2 =>
					LCD_E <= '1';
					LCD_RW <= '1';
					if delay_counter = 0 or delay_counter = 1 then
						-- timer set: E = 0 for 500 ns (tPWel)
						delay_counter <= delay_pwel;
						current_state <= pulse_busy_flag_3;
					else
						delay_counter <= delay_counter-1;
					end if;
				when pulse_busy_flag_3 =>
					LCD_E <= '0';
					LCD_RW <= '1';
					if LCD_DB(7) = '0' then
						-- operation ended
						current_state <= pulse_busy_flag_4;
					else
						-- operation in progress
						current_state <= pulse_busy_flag_5;
					end if;
				when pulse_busy_flag_4 =>
					if delay_counter = 0 or delay_counter = 1 then
						-- Operation ended, return caller
						current_state <= return_state;
					else
						delay_counter <= delay_counter-1;
					end if;
				when pulse_busy_flag_5 =>
					if delay_counter = 0 or delay_counter = 1 then
						-- Operation in progress, read BF again
						current_state <= pulse_busy_flag;
					else
						delay_counter <= delay_counter-1;
					end if;

				when others => null;
			end case;
		end if;
		
	end process;

end architecture hardware_driver;
