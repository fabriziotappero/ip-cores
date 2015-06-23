-------------------------------------------------------------------------------
--	MiniGA
--  Author: Thomas Pototschnig (thomas.pototschnig@gmx.de)
--
--  License: Creative Commons Attribution-NonCommercial-ShareAlike 2.0 License
--           http://creativecommons.org/licenses/by-nc-sa/2.0/de/
--
--  If you want to use MiniGA for commercial purposes please contact the author
-------------------------------------------------------------------------------
-- fir filter
-- uses even and symmetric number of coefficients
-- input format: s0,xxxxxxxxxx
-- input must be <1024!
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity myfir is
	generic (
		TAPS : integer := 16
	);
		
	port (
		clk : in std_logic;
		reset : in std_logic;
		input : in std_logic_vector(11 downto 0);
		output : out std_logic_vector(11 downto 0)
	);
end myfir;

architecture behaviour of myfir is
begin
	process (clk, reset)
	type tsr is array(0 to TAPS-1) of signed(11 downto 0);
	type tcoff is array(0 to (TAPS/2)-1) of signed(11 downto 0);
-- format: s0,xxxxxxxxxx; 
-- koeffizienten für 16tap 1,3MHz hamming-tiefpass bei 15MHz sampling frequenz
	variable coff : tcoff := (
		x"FFA", x"FFB", x"004", x"027", x"06E", x"0D0", x"132", x"170"       
	);
	variable sr : tsr;
	variable y : signed (63 downto 0);
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
-- jetzt berechnen
			y:=  (others => '0');
			for I in 0 to (TAPS/2)-1 loop
				y:=y+ (sr(I) + sr((TAPS-1)-I)) * coff(I);
			end loop;

			output <= conv_std_logic_vector(y(22 downto 11),12);
		end if;
	end process;

end architecture;
