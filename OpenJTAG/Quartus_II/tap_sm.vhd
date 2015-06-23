-- Created by Ruben H. Mileca - May-16-2010


library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity tap_sm IS

--	generic (
--		new_state: integer range 0 to 15 := 1
--	);

		port (

		clk:		in std_logic;						-- External 48 MHz oscillator
		rst:		in std_logic;						-- External reset, active high
		new_state:	in std_logic_vector(3 downto 0);	-- New state
		tck:		out std_logic := '0';				-- TCK Jtag pin
		tms:		out std_logic := '0';				-- TMS Jtag pin
		wrk:		out std_logic := '0';				-- SM working

		sm:			out std_logic_vector(3 downto 0)	-- Test output

	);

end tap_sm;

architecture rtl of tap_sm is

	signal state:		integer range 0 to 15 := 0;
	signal astate:		integer range 0 to 15 := 0;
	signal rclk:		integer range 0 to 1 := 0;

begin

	
changestate: process(clk, rst, state)

begin

	if (rising_edge(clk)) then
		if rclk = 1 then
			rclk <= 0;
		else
			rclk <= 1;
		end if;

		astate <= to_integer(unsigned(new_state));
		sm <= std_logic_vector(to_unsigned(state, sm'length));

--	TAP Change state machine

		if state /= astate then
			wrk <= '1';
			if rclk = 1 then 
				tms <= '0';
			end if;
			case state is
				when 0 =>					-- Is in Test Logic Reset
					if rclk = 1 then
						tms <= '0';
						tck <= '0';
					else
						tck <= '1';
						state <= 1;
					end if;
				when 1 =>					-- Is in Run Test Idle
					if rclk = 1 then
						tms <= '1';
						tck <= '0';
					else
						tck <= '1';
						state <= 2;
					end if;
--
-- DR way
--
				when 2 =>					-- Is in Select DR Scan
					if rclk = 1 then
						if astate > 8 then	-- See if go to Select IR Scan
							tms <= '1';
						else
							tms <= '0';
						end if;
						tck <= '0';
					else
						if astate > 8 then	-- See if go to Select IR Scan
							state <= 9;		-- Go to Select IR Scan
						else
							state <= 3;		-- Go to Capture DR
						end if;
						tck <= '1';
					end if;
				when 3 =>					-- Is in Capture DR
					if rclk = 1 then
						if astate > 4 then	-- See if go to Exit-1 DR
							tms <= '1';
						else
							tms <= '0';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate > 4 then	-- See if go to Exit-1 DR
							state <= 5;		-- Go to Exit-1 DR
						else
							state <= 4;		-- Go to Capture DR
						end if;
					end if;
				when 4 =>					-- Is in Capture DR
					if rclk = 1 then
						tms <= '1';
						tck <= '0';
					else
						tck <= '1';
						state <= 5;
					end if;
				when 5 =>					-- Is in Exit-1 DR
					if rclk = 1 then
						if astate = 6 then	-- See if go to Pause DR
							tms <= '0';
						else
							tms <= '1';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate = 6 then	-- See if go to Pause DR
							state <= 6;		-- Go to Exit-1 DR
						else
							state <= 8;		-- Go to Capture DR
						end if;
					end if;
				when 6 =>					-- Is in Pause DR
					if rclk = 1 then
						tms <= '1';
						tck <= '0';
					else
						tck <= '1';
						state <= 7;
					end if;
				when 7 =>					-- Is in Exit-2 DR
					if rclk = 1 then
						if astate = 4 then	-- See if go to Shift DR
							tms <= '0';
						else
							tms <= '1';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate = 4 then	-- See if go to Pause DR
							state <= 4;		-- Go to Pause DR
						else
							state <= 8;		-- Go to Update DR
						end if;
					end if;
				when 8 =>					-- Is in Exit-2 DR
					if rclk = 1 then
						if astate > 1 then	-- See if go to Select DR Scan
							tms <= '1';
						else
							tms <= '0';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate > 1 then	-- See if go to Select DR Scan
							state <= 2;		-- Go to Select DR Scan
						else
							state <= 1;		-- Go to Run Test Idle
						end if;
					end if;
--
--	IR way
--
				when 9 =>					-- Is in Select IR Scan
					if rclk = 1 then
						if astate = 1 then	-- See if go to Test Logic Reset
							tms <= '1';
						else
							tms <= '0';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate = 1 then	-- See if go to Test Logic Reset
							state <= 1;		-- Go to Test Logic Reset
						else
							state <= 10;	-- Go to Capture IR
						end if;
					end if;
				when 10 =>					-- Is in Capture IR
					if rclk = 1 then
						if astate = 11 then	-- See if go to Shift-IR
							tms <= '0';
						else
							tms <= '1';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate = 11 then	-- See if go to Shift-IR
							state <= 11;		-- Go to Shift-IR
						else
							state <= 12;	-- Go to Exit 1-IR
						end if;
					end if;
				when 11 =>					-- Is in Shift-IR
					if rclk = 1 then
						tms <= '1';
						tck <= '0';
					else
						tck <= '1';
						state <= 12;
					end if;
				when 12 =>					-- Is in Exit 1-IR
					if rclk = 1 then
						if astate > 13 then	-- See if go to Update-IR
							tms <= '1';
						else
							tms <= '0';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate > 13 then	-- See if go to Update-IR
							state <= 15;		-- Go to Update-IR
						else
							state <= 13;	-- Go to Pause-IR
						end if;
					end if;
				when 13 =>					-- Is in Pause-IR
					if rclk = 1 then
						tms <= '1';
						tck <= '0';
					else
						tck <= '1';
						state <= 14;
					end if;
				when 14 =>					-- Is in Exit 2-IR
					if rclk = 1 then
						if astate = 11 then	-- See if go to Shift-IR
							tms <= '0';
						else
							tms <= '0';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate = 11 then	-- See if go to Shift-IR
							state <= 11;		-- Go to Shift-IR
						else
							state <= 15;		-- Go to Update-IR
						end if;
					end if;
				when 15 =>					-- Is in Update-IR
					if rclk = 1 then
						if astate > 1 then	-- See if go to Select DR-Scan
							tms <= '1';
						else
							tms <= '0';
						end if;
						tck <= '0';
					else
						tck <= '1';
						if astate > 1 then	-- See if go to Select DR-Scan
							state <= 2;		-- Go to Update-IR
						else
							state <= 1;		-- Go to Run Test-Idle
						end if;
					end if;
				when others =>
						tck <= '0';
						tms <= '0';
			end case;
		else
			astate <= to_integer(unsigned(new_state));
			tck <= '0';
			tms <= '0';
			wrk <= '0';
		end if;
	end if;
end process changestate;
end rtl;
