--
-- File tgen.vhd, Video Horizontal and Vertical Timing Generator
-- Project: VGA
-- Author : Richard Herveille
-- rev.: 0.1 April 13th, 2001
--
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Tgen is
	port(
		clk : in std_logic;
		rst : in std_logic;

		-- horizontal timing settings
		HSyncL : in std_logic;              -- horizontal sync pulse polarization level (pos/neg)
		Thsync : in unsigned(7 downto 0);   -- horizontal sync pulse width (in pixels)
		Thgdel : in unsigned(7 downto 0);   -- horizontal gate delay (in pixels)
		Thgate : in unsigned(15 downto 0);  -- horizontal gate (number of visible pixels per line)
		Thlen  : in unsigned(15 downto 0);  -- horizontal length (number of pixels per line)

		-- vertical timing settings
		VSyncL : in std_logic;              -- vertical sync pulse polarization level (pos/neg)
		Tvsync : in unsigned(7 downto 0);   -- vertical sync width (in lines)
		Tvgdel : in unsigned(7 downto 0);   -- vertical gate delay (in lines)
		Tvgate : in unsigned(15 downto 0);  -- vertical gate (visible number of lines in frame)
		Tvlen  : in unsigned(15 downto 0);  -- vertical length (number of lines in frame)
		
		CSyncL : in std_logic;              -- composite sync pulse polarization level (pos/neg)
		BlankL : in std_logic;              -- blank signals polarizatio level

		eol,                                -- end of line
		eof,                                -- end of frame
		gate,                               -- vertical AND horizontal gate (logical and function)

		Hsync,                              -- horizontal sync pulse
		Vsync,                              -- vertical sync pulse
		Csync,                              -- composite sync
		Blank : out std_logic               -- blank signal
	);
end entity Tgen;

architecture dataflow of Tgen is
	--
	-- Component declarations
	--
	component vtim is
	port(
		clk : in std_logic;                -- master clock
		ena : in std_logic := '1';         -- count enable
		rst : in std_logic;                -- synchronous active high reset

		Tsync : in unsigned(7 downto 0);   -- sync duration
		Tgdel : in unsigned(7 downto 0);   -- gate delay
		Tgate : in unsigned(15 downto 0);  -- gate length
		Tlen  : in unsigned(15 downto 0);  -- line time / frame time

		Sync  : out std_logic;             -- synchronization pulse
		Gate  : out std_logic;             -- gate
		Done  : out std_logic              -- done with line/frame
	);
	end component vtim;

	--
	-- signals
	--
	signal Hgate, Vgate : std_logic;
	signal Hdone : std_logic;
	signal iHsync, iVsync, igate : std_logic;
begin
	-- hookup horizontal timing generator
	hor_gen: vtim port map (clk => clk, rst => rst, 
		Tsync => Thsync, Tgdel => Thgdel, Tgate => Thgate, Tlen => Thlen,
		Sync => iHsync, Gate => Hgate, Done => Hdone);

	-- hookup vertical timing generator
	ver_gen: vtim port map (clk => clk, ena => Hdone, rst => rst, 
		Tsync => Tvsync, Tgdel => Tvgdel, Tgate => Tvgate, Tlen => Tvlen,
		Sync => iVsync, Gate => Vgate, Done => eof);

	-- assign outputs
	eol   <= Hdone;
	igate <= Hgate and Vgate;
	gate  <= igate;

	Hsync <= iHsync xor HsyncL;
	Vsync <= iVsync xor VsyncL;
	Csync <= (iHsync or iVsync) xor CsyncL;
	Blank <= igate xnor BlankL;
end architecture dataflow;


