-- Created by Ruben H. Mileca - May-16-2010


library ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity clock_mux IS

		port (

-- Internal

		clk:	in std_logic;						-- External 48 MHz oscillator
		cks:	in std_logic_vector(2 downto 0) := "000";	-- Clock divider
		wcks:	out std_logic						-- Clock output
	);

end clock_mux;

architecture rtl of clock_mux is

	signal count:		integer range 0 to 127 := 0;
	signal cclk:		std_logic_vector(6 downto 0);
begin

	
clock_gen: process(clk, cks)

begin

	if cks = "000" then
		wcks <= clk;
	else
		if (rising_edge(clk)) then
			cclk <= std_logic_vector(to_unsigned(count, cclk'length));
			wcks <= cclk(to_integer(unsigned(cks)) - 1);
			count <= count + 1;
		end if;
	end if;

end process clock_gen;
end rtl;
