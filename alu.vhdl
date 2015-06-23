-- 10/24/2005
-- alu

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity alu is port(
	a:	in std_logic_vector(15 downto 0);
	b:	in std_logic_vector(15 downto 0);
	a_or_l:	in std_logic;
	op:	in std_logic_vector(2 downto 0);
	o:	out std_logic_vector(15 downto 0)
);
end alu;

architecture alu_arch of alu is

component arithmetic port(
	a:	in signed(15 downto 0);
	b:	in signed(15 downto 0);
	fcn:	in std_logic_vector(2 downto 0);
	o:	out signed(15 downto 0);
	m_o:	out signed(31 downto 0)
);
end component;

component logical port(
	a:	in std_logic_vector(15 downto 0);
	b:	in std_logic_vector(15 downto 0);
	fcn:	in std_logic_vector(2 downto 0);
	o:	out std_logic_vector(15 downto 0)
);
end component;

component mux_2_1 port(
	a:	in std_logic_vector(15 downto 0);
	b:	in std_logic_vector(15 downto 0);
	sel:	in std_logic;
	o:	out std_logic_vector(15 downto 0)
);
end component;

signal s_a, s_b, s_o:	signed(15 downto 0);
signal l_o: std_logic_vector(15 downto 0);

begin
	s_a <= signed(a);
	s_b <= signed(b);
	
	arith: arithmetic
		port map(s_a, s_b, op, s_o);
	logic: logical
		port map(a, b, op, l_o);
	mux: mux_2_1
		port map(std_logic_vector(s_o), l_o, a_or_l, o);
end alu_arch;