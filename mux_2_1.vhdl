library ieee;
use ieee.std_logic_1164.all;

entity mux_2_1 is port(
	a:	in std_logic_vector(15 downto 0);
	b:	in std_logic_vector(15 downto 0);
	sel:	in std_logic;
	o:	out std_logic_vector(15 downto 0)
);
end mux_2_1;

architecture mux_arch of mux_2_1 is
begin
	process(sel, a, b)
	begin
		if sel = '0' then
			o <= a;
		else
			o <= b;
		end if;
	end process;
end mux_arch;