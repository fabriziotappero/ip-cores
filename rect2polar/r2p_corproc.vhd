--
-- file: r2p_corproc.vhd
--
-- XY to RA coordinate / rectangular to polar coordinates processor 
--
-- uses: r2p_pre.vhd, r2p_cordic.vhd, r2p_post.vhd
--
-- rev. 1.1 June 4th, 2001. Richard Herveille. Completely revised core.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity r2p_corproc is
	port(
		clk	: in std_logic;
		ena	: in std_logic;
		Xin	: in signed(15 downto 0);
		Yin : in signed(15 downto 0);
		
		Rout	: out unsigned(19 downto 0);
		Aout	: out signed(19 downto 0)
	);
end entity r2p_corproc;

architecture dataflow of r2p_corproc is
	constant PipeLength : natural := 15;

	component r2p_pre is
	port(
		clk	: in std_logic;
		ena	: in std_logic;
		Xi	: in signed(15 downto 0);
		Yi	: in signed(15 downto 0);

		Xo	: out unsigned(14 downto 0);
		Yo	: out unsigned(14 downto 0);
		Q	: out std_logic_vector(2 downto 0)
	);
	end component r2p_pre;

	component r2p_cordic is
	generic(
		PIPELINE      : integer;
		WIDTH         : integer;
		EXT_PRECISION	: integer
	);
	port(
		clk	: in std_logic;
		ena	: in std_logic;
		Xi	: in signed(WIDTH-1 downto 0);
		Yi	: in signed(WIDTH-1 downto 0);
		Zi : in signed(19 downto 0) := (others => '0');		

		Xo	: out signed(WIDTH + EXT_PRECISION -1 downto 0);
		Zo	: out signed(19 downto 0));
	end component r2p_cordic;

	component r2p_post is
	port(
		clk	: in std_logic;
		ena	: in std_logic;

		Ai	: in signed(19 downto 0);
		Ri	: in unsigned(19 downto 0);
		Q	: in std_logic_vector(2 downto 0);

		Ao	: out signed(19 downto 0);
		Ro	: out unsigned(19 downto 0));
	end component r2p_post;

	signal Xpre, Ypre : unsigned(15 downto 0);
	signal Acor, Rcor : signed(19 downto 0);
	signal Q, dQ : std_logic_vector(2 downto 0);

begin

	-- instantiate components
	u1:	r2p_pre port map(clk => clk, ena => ena, Xi => Xin, Yi => Yin, Xo => Xpre(14 downto 0), Yo => Ypre(14 downto 0), Q => Q);
	Xpre(15) <= '0';
	Ypre(15) <= '0';

	u2:	r2p_cordic	
			generic map(PIPELINE => PipeLength, WIDTH => 16, EXT_PRECISION => 4)
			port map(clk => clk, ena => ena, Xi => signed(Xpre), Yi => signed(Ypre), Xo => Rcor, Zo => Acor);

	delay: block
		type delay_type is array(PipeLength -1 downto 0) of std_logic_vector(2 downto 0);
		signal delay_pipe :delay_type;
	begin
		process(clk, Q)
		begin
			if (clk'event and clk = '1') then
				if (ena = '1') then
					delay_pipe(0) <= Q;
					for n in 1 to PipeLength -1 loop
						delay_pipe(n) <= delay_pipe(n -1);
					end loop;
				end if;
			end if;
		end process;
		dQ <= delay_pipe(PipeLength -1);
	end block delay;

	u3:	r2p_post port map(clk => clk,  ena => ena, Ri => unsigned(Rcor), Ai => Acor, Q => dQ, Ao => Aout, Ro => Rout);
end architecture dataflow;
