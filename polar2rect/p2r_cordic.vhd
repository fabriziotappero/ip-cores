--
--	VHDL implementation of cordic algorithm
--
-- File: p2r_cordic.vhd
-- author: Richard Herveille
-- rev. 1.0 initial release
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity p2r_cordic is 
	generic(
		PIPELINE : integer := 15;
		WIDTH    : integer := 16);
	port(
		clk	: in std_logic;
		ena : in std_logic;

		Xi	: in signed(WIDTH -1 downto 0);
		Yi : in signed(WIDTH -1 downto 0) := (others => '0');
		Zi	: in signed(WIDTH -1 downto 0);
		
		Xo	: out signed(WIDTH -1 downto 0);
		Yo	: out signed(WIDTH -1 downto 0)
	);
end entity p2r_Cordic;


architecture dataflow of p2r_cordic is

	--
	--	TYPE defenitions
	--
	type XYVector is array(PIPELINE downto 0) of signed(WIDTH -1 downto 0);
	type ZVector is array(PIPELINE downto 0) of signed(19 downto 0);

	--
	--	COMPONENT declarations
	--
	component p2r_CordicPipe
	generic(
		WIDTH 	: natural := 16;
		PIPEID	: natural := 1
	);
	port(
		clk		: in std_logic;
		ena		: in std_logic;

		Xi		: in signed(WIDTH -1 downto 0); 
		Yi		: in signed(WIDTH -1 downto 0);
		Zi		: in signed(19 downto 0);

		Xo		: out signed(WIDTH -1 downto 0);
		Yo		: out signed(WIDTH -1 downto 0);
		Zo		: out signed(19 downto 0)
	);
	end component p2r_CordicPipe;

	--
	--	SIGNALS
	--
	signal X, Y	: XYVector;
	signal Z	: ZVector;

	--
	--	ACHITECTURE BODY
	--
begin
	-- fill first nodes

	-- fill X
	X(0) <= Xi;

	-- fill Y
	Y(0) <= Yi;

	-- fill Z
	Z(0)(19 downto 4) <= Zi;
	Z(0)(3 downto 0) <= (others => '0');

	--
	-- generate pipeline
	--
	gen_pipe:
	for n in 1 to PIPELINE generate
		Pipe: p2r_CordicPipe 
			generic map(WIDTH => WIDTH, PIPEID => n -1)
			port map ( clk, ena, X(n-1), Y(n-1), Z(n-1), X(n), Y(n), Z(n) );
	end generate gen_pipe;

	--
	-- assign outputs
	--
	Xo <= X(PIPELINE);
	Yo <= Y(PIPELINE);
end dataflow;


