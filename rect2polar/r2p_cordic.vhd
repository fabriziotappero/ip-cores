--
--	VHDL implementation of cordic algorithm
--
-- File: cordic.vhd
-- author: Richard Herveille
-- rev. 1.0 initial release
-- rev. 1.1 changed CordicPipe component declaration, Xilinx WebPack issue
-- rev. 1.2 Revised entire core. Made is simpler and easier to understand.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity r2p_cordic is 
	generic(
		PIPELINE      : integer := 15;
		WIDTH         : integer := 16;
		EXT_PRECISION : integer := 4
	);
	port(
		clk	: in std_logic;
		ena : in std_logic;

		Xi : in signed(WIDTH-1 downto 0);
		Yi : in signed(WIDTH-1 downto 0);
		Zi : in signed(19 downto 0) := (others => '0');
		
		Xo : out signed(WIDTH + EXT_PRECISION -1 downto 0);
		Zo : out signed(19 downto 0)
	);
end r2p_cordic;


architecture dataflow of r2p_cordic is

	--
	--	TYPE defenitions
	--
	type XYVector is array(PIPELINE downto 0) of signed(WIDTH + EXT_PRECISION -1 downto 0);
	type ZVector is array(PIPELINE downto 0) of signed(19 downto 0);

	--
	--	COMPONENT declarations
	--
	component r2p_CordicPipe
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
	end component r2p_CordicPipe;

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

	X(0)(WIDTH + EXT_PRECISION -1 downto EXT_PRECISION) <= Xi;   -- fill MSBs with input data
	X(0)(EXT_PRECISION -1 downto 0) <= (others => '0');          -- fill LSBs with '0'

	Y(0)(WIDTH + EXT_PRECISION -1 downto EXT_PRECISION) <= Yi;   -- fill MSBs with input data
	Y(0)(EXT_PRECISION -1 downto 0) <= (others => '0');          -- fill LSBs with '0'

	Z(0) <= Zi;

	--
	-- generate pipeline
	--
	gen_pipe:
	for n in 1 to PIPELINE generate
		Pipe: r2p_CordicPipe 
			generic map(WIDTH => WIDTH+EXT_PRECISION, PIPEID => n -1)
			port map ( clk, ena, X(n-1), Y(n-1), Z(n-1), X(n), Y(n), Z(n) );
	end generate gen_pipe;

	--
	-- assign outputs
	--
	Xo <= X(PIPELINE);
	Zo <= Z(PIPELINE);
end dataflow;

