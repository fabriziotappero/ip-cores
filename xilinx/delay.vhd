-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
-- delay
-- for synchronizing u,v,y after FIR filter
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity delay is
	generic (
		TAPS : integer := 8 -- group-delay der FIR-Filter ist 500ns
	);
		
	port (
		clk : in std_logic;
		reset : in std_logic;
		input : in std_logic_vector(11 downto 0);
		output : out std_logic_vector(11 downto 0)
	);
end delay;

architecture behaviour of delay is
begin
	process (clk, reset)
	type tsr is array(0 to TAPS-1) of signed(11 downto 0);
	variable sr : tsr;
	begin
		if reset='0' then
			for I in 0 to TAPS-1 loop
				sr(I) := (others => '0');
			end loop;
			output <= (others => '0');
		elsif clk'event and clk='1' then
-- Schieberegister
			for I in (TAPS-1) downto 1 loop
				sr(I):=sr(I-1);
			end loop;
			sr(0) := signed(input);

			output <= conv_std_logic_vector(sr(TAPS-1),12);
		end if;
	end process;

end architecture;
