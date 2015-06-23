-- Created by Ruben H. Mileca - May-16-2010


library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity serializer IS

		port (

-- Internal

		clk:	in std_logic;						-- External 24 MHz oscillator

-- FT245BM

		txe:	in std_logic;						-- From FT245BM TXE# pin
		rxf:	in std_logic;						-- From FT245BM RXF pin
		pwr:	in std_logic;						-- From FT245BM PWREN# pin
		rst:	in std_logic;						-- From FT245BM RSTOUT# pin
		wrk:	in std_logic;						-- From tap_sm working signal
		wr:		out std_logic := '1';				-- To FT245BM WR pin
		rd:		out std_logic := '1';				-- To FT245BM RD# pin
		siwu:	out std_logic := '1';				-- To FT245BM SI/WU pin
		db:		inout std_logic_vector(7 downto 0);	-- From/To FT245BM data bus

-- JTAG

		tdo:	in std_logic;						-- TDO Jtag pin
		tck:	out std_logic := '0';				-- TCK Jtag pin
		tms:	out std_logic := '0';				-- TMS Jtag pin
		tdi:	out std_logic := '0';				-- TDI Jtag pin
		trst:	out std_logic := '1';				-- TRST Jtag pin

-- Clock and SM setting

		new_state:	out std_logic_vector(3 downto 0);	-- tap_sm new state
		cks:		out std_logic_vector(2 downto 0)	-- Clock divider

	);

end serializer;

architecture rtl of serializer is

	signal count:		integer range 0 to 8 := 0;
	signal state:		integer range 0 to 15 := 0;
	signal rclk:		integer range 0 to 1 := 0;
	signal sclk:		integer range 0 to 1 := 0;

	signal instr:		integer range 0 to 1 := 0;		-- 0=Instruction, 1=Data, 2=Shift out, 3/4 shift in
	signal ssm:			integer range 0 to 15 := 0;		-- Shift and data state machine
	signal dir:			std_logic := '1';				-- '0' = MSB, '1' = LSB
	signal rtms:		std_logic := '0';				-- TMS state at last shift bit

	signal shift:		std_logic_vector(7 downto 0);
	signal rbyte:		std_logic_vector(7 downto 0);
	
begin

	
changestate: process(clk, rclk, rxf, txe, pwr, rst)
begin
	if (rising_edge(clk)) then
		if rclk = 1 then
			rclk <= 0;
		else
			rclk <= 1;
		end if;
--		st <= std_logic_vector(to_unsigned(state, st'length));

		if wrk = '0' then
			case ssm is
				when 0 =>
					tck <= '0';
					tms <= '0';
					tdi <= '0';
					if rxf = '0' then			-- Start byte read from FT245BM
						rd <= '0';				-- Send RD# to FT245BM
						ssm <= 1;				-- Change to next state
					end if;
				when 1 =>
					rbyte <= db;				-- Read byte from FT245BM
					db <= "ZZZZZZZZ";
					rd <= '1';					-- Select next byte from FT245BM
					ssm <= 2;					-- Change state;
				when 2 =>
					case instr is
						when 0 =>				-- Is an instruction byte
							case rbyte(3 downto 0) is
								when "0000" =>			-- rbyte(7 downto 4) have the new clock divisor
									cks <= rbyte(7 downto 5);	-- Set clock divisor
															
								when "0001" =>			-- rbyte(7 downto 4) have then new state
									new_state <= rbyte(7 downto 4);
									ssm <= 3;			-- Reset state machine
								when "0010" =>			-- Get current TAP state
									rbyte(3 downto 0) <= std_logic_vector(to_unsigned(state, rbyte(3 downto 0)'length));
									rbyte(4) <= dir;
									ssm <= 5;
								when "0011" =>			-- Software reset TAP
									count <= to_integer(unsigned(rbyte(7 downto 4)));
									ssm <= 9;
									tms <= '1';
								


								when "0100" =>			-- Hardware reset TAP
									count <= to_integer(unsigned(rbyte(7 downto 4)) - 1);
									ssm <= 8;
								when "0101" =>			-- Set MSB/LSB shift direction
									dir <= rbyte(4);	-- Set shift direction
									sclk <= 0;
									ssm <= 0;			-- Reset state machine
								when "0110" =>			-- Latch the next byte as shift data
									if state = 0 or state = 4 or state = 11 then
										count <= to_integer(unsigned(rbyte(7 downto 5)));
										rtms <= rbyte(4);	-- TMS state at last shifted bit
										instr <= 1;			-- Next is data to send
										sclk <= 0;
										ssm <= 0;			-- Reset state machine
									end if;

								when others =>
									ssm <= 0;			-- Error, reset state machine
							end case;
						when 1 =>				-- There is a count bits to shift in/out
--							st <= std_logic_vector(to_unsigned(count, st'length));
							if sclk = 0 then
								tck <= '0';
								if dir = '0' then
									tdi <= rbyte(7);
									rbyte(7 downto 1) <= rbyte(6 downto 0);
								else
									tdi <= rbyte(0);
									rbyte(6 downto 0) <= rbyte(7 downto 1);
								end if;
								sclk <= 1;
								if count = 0 then
									tms <= rtms;
								end if;
							else
								tck <= '1';

--	Read TDO

								if dir = '1' then
									shift(6 downto 0) <= shift(7 downto 1);
									shift(7) <= tdo;
								else
									shift(7 downto 1) <= shift(6 downto 0);
									shift(0) <= tdo;
								end if;
			
								if count > 0 then
									count <= count - 1;
								else
									ssm <= 5;
									instr <= 0;
								end if;
								sclk <= 0;
							end if;
						when others =>
					end case;

-- Delay for SM state start to work

				when 3 =>
					ssm <= 4;
				when 4 =>
					ssm <= 0;

-- Write rbyte to data bus

				when 5 =>
					tck <= '0';
					tms <= '0';
					tdi <= '0';
					if txe = '0' then
						ssm <= 6;
						db <= shift;
					end if;
				when 6 =>
					wr <= '0';
					ssm <= 7;
				when 7 =>
					wr <= '1';
					ssm <= 0;
					db <= "ZZZZZZZZ";

					if rtms = '1' then
						if state = 4 or state = 11 then
							state <= state + 1;
						end if;
					else
						if state = 0 then
							state <= state + 1;
						end if;
					end if;

				when 8 =>
					if count = 0 then
						trst <= '1';
						ssm <= 0;
					else
						trst <= '0';
						count <= count - 1;
					end if;
				when 9 =>
					if sclk = 0 then
						tck <= '1';
					else
						tck <= '0';
						if count > 0 then
							count <= count - 1;
						else
							tms <= '0';
							ssm <= 0;
						end if;
					end if;
				when others =>

			end case;
		end if;
	end if;

end process changestate;
end rtl;
