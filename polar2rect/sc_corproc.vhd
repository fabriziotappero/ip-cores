--
-- sc_corproc.vhd
--
-- Calculates Sine and Cosine values
--
-- uses: p2r_codic.vhd and p2r_cordicpipe.vhd
--
--
--
-- system delay: 21 (data out delay: 20)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity sc_corproc is
	port(
		clk	: in std_logic;
		ena	: in std_logic;
		Ain	: in signed(15 downto 0);
		
		sin	: out signed(15 downto 0);
		cos	: out signed(15 downto 0));
end entity sc_corproc;

architecture dataflow of sc_corproc is
	constant PipeLength : natural := 15;
	constant P : signed(15 downto 0) := x"4dba";	-- define aggregate constant

	component p2r_cordic is
	generic(
		PIPELINE : integer := 15;
		WIDTH    : integer := 16);
	port(
		clk : in std_logic;
		ena : in std_logic;

		Xi : in signed(WIDTH -1 downto 0);
		Yi : in signed(WIDTH -1 downto 0) := (others => '0');
		Zi : in signed(WIDTH -1 downto 0);
		
		Xo : out signed(WIDTH -1 downto 0);
		Yo : out signed(WIDTH -1 downto 0)
	);
	end component p2r_cordic;

begin
	u1:	p2r_cordic	
			generic map(PIPELINE => PipeLength, WIDTH => 16)
			port map(clk => clk, ena => ena, Xi => P, Zi => Ain, Xo => cos, Yo => sin);
end architecture dataflow;
