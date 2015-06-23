-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity clk is
	port (
		clkin : in std_logic;
		reset : in std_logic;
		clk60M : out std_logic;
		clk45M : out std_logic;
		clk15M : out std_logic;
		pixclk : out std_logic;
		sync : out std_logic
	);
end clk;

architecture behaviour of clk is

	COMPONENT dcm1
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
	END COMPONENT;

signal locked: std_logic;
signal pllreset : std_logic;
signal pllclk180M : std_logic;

begin
	Inst_dcm1: dcm1 PORT MAP(
		CLKIN_IN => clkin,
		RST_IN => pllreset,
		CLKFX_OUT => pllclk180M,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		LOCKED_OUT => locked
	);

pllreset <= not reset;

-- statemachine, weil counter zu langsam sind ...
process (pllclk180M, reset, locked)
variable state : integer := 0;
begin
	if reset='0' or locked='0' then
		state := 0;
		clk60M <= '0';
		clk15M <= '0';
		clk45M <= '0';
		sync <= '0';
		pixclk <= '0';
	elsif pllclk180M'event and pllclk180M='1' then
		case state is
			when 0 =>
				clk15M <= '1';
				clk45M <= '1';
				clk60M <= '1';
				state := 1;
			when 1 =>
				clk60M <= '0';
				state := 2;
			when 2 =>
				clk45M <= '0';
				pixclk <= '1';
				state := 3;
			when 3 =>
				clk60M <= '1';
				pixclk <= '0';
				state := 4;
			when 4 =>
				clk60M <= '0';
				clk45M <= '1';
				state := 5;
			when 5 =>
				state := 6;
			when 6 =>
				pixclk <= '1';
				clk60M <= '1';
				clk45M <= '0';
				clk15M <= '0';
				state := 7;
			when 7 =>
				pixclk <= '0';
				clk60M <= '0';
				state := 8;
			when 8 =>
				sync <= '1';
				clk45M <= '1';
				state := 9;
			when 9 =>
				clk60M <= '1';
				state := 10;
			when 10 =>
				pixclk <= '1';
				clk60M <= '0';
				clk45M <= '0';
				state := 11;
			when 11 =>
				pixclk <= '0';
				sync <= '0';
				state := 0;
			when others => 
				state := 0;
		
		end case;
	end if;
end process;



end architecture;
