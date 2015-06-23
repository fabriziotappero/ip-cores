library ieee;
use ieee.std_logic_1164.all;

entity mux_8_1 is port(
	a:	in std_logic_vector(15 downto 0);
	b:	in std_logic_vector(15 downto 0);
	c:	in std_logic_vector(15 downto 0);
	d:	in std_logic_vector(15 downto 0);
	e:	in std_logic_vector(15 downto 0);
	f:	in std_logic_vector(15 downto 0);
	g:	in std_logic_vector(15 downto 0);
	h:	in std_logic_vector(15 downto 0);
	sel:	in std_logic_vector(2 downto 0);
	o:	out std_logic_vector(15 downto 0)
);
end mux_8_1;

architecture mux8_arch of mux_8_1 is
begin
	process(sel, a, b)
	begin
		if sel = "000" then
			o <= a;
		elsif sel = "001" then
			o <= b;
		elsif sel = "010" then
			o <= c;
		elsif sel = "011" then
			o <= d;
		elsif sel = "100" then
			o <= e;
		elsif sel = "101" then
			o <= f;
		elsif sel = "110" then
			o <= g;
		elsif sel = "111" then
			o <= h;
		end if;
	end process;
end mux8_arch;