--
--
--	S S R A M  i n t e r f a c e
--
-- various components for ssrams
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package SSRAM is
	component ssram_conn is
	generic(
		DWIDTH	: positive := 16;
		AWIDTH : positive := 18
	);
	port (
		clk : in std_logic;
		A : in unsigned(AWIDTH -1 downto 0);
		Din : in std_logic_vector(DWIDTH -1 downto 0);
		Dout : out std_logic_vector(DWIDTH -1 downto 0);
		rw : in std_logic;
		bw : in std_logic_vector((DWIDTH/8) downto 0) := (others => '0');

		ssramA : out unsigned(AWIDTH -1 downto 0);
		ssramD : inout std_logic_vector(DWIDTH -1 downto 0);
		ssramRW : out std_logic;
		ssramBW : out std_logic_vector((DWIDTH/8) downto 0)
	);
	end component ssram_conn;

	component cs_ssram is
	generic(
		DWIDTH : positive := 16;
		AWIDTH : positive := 18
	);
	port (
		clk : in std_logic;
		clk_div2 : in std_logic;		-- clk divided by 2

		p0_A : in unsigned(AWIDTH -1 downto 0);
		p0_Din : in std_logic_vector(DWIDTH -1 downto 0);
		p0_Dout : out std_logic_vector(DWIDTH -1 downto 0);
		p0_rw : in std_logic;
		p0_bw : in std_logic_vector((DWIDTH/8) downto 0) := (others => '0');

		p1_A : in unsigned(AWIDTH -1 downto 0);
		p1_Din : in std_logic_vector(DWIDTH -1 downto 0);
		p1_Dout : out std_logic_vector(DWIDTH -1 downto 0);
		p1_rw : in std_logic;
		p1_bw : in std_logic_vector((DWIDTH/8) downto 0) := (others => '0');

		ssramA : out unsigned(AWIDTH -1 downto 0);
		ssramD : inout std_logic_vector(DWIDTH -1 downto 0);
		ssramRW : out std_logic;
		ssramBW : out std_logic_vector((DWIDTH/8) downto 0)
	);
	end component cs_ssram;

end package SSRAM;

--
--
-- SSRAM cycle shared memory implementation
--
-- ssram can be accessed by 2 ports at clk_div2 frequency. SSRAM operates at clk frequency
-- clk_div2 is actually a clk_en signal (no extra clock-domain)
--
-- read command: data valid after 3 clk_div2 cycles
-- 1) set address, RW = '1' (read command)
-- 2) present address/RW to ssram
-- 3) ssram presents data
-- 4) data (p0_dout/p1_dout) valid
-- 5) take/use data
--
-- note: p0_dout Tsu = 1 clk_div2 cycle
--       p1_dout Tsu = 1 clk cycle (so half of p0_dout Tsu)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity cs_ssram is
	generic(
		DWIDTH : positive := 16;
		AWIDTH : positive := 18
	);
	port (
		clk : in std_logic;
		clk_div2 : in std_logic;		-- clk divided by 2

		p0_A : in unsigned(AWIDTH -1 downto 0);
		p0_Din : in std_logic_vector(DWIDTH -1 downto 0);
		p0_Dout : out std_logic_vector(DWIDTH -1 downto 0);
		p0_rw : in std_logic;
		p0_bw : in std_logic_vector((DWIDTH/8) downto 0) := (others => '0');

		p1_A : in unsigned(AWIDTH -1 downto 0);
		p1_Din : in std_logic_vector(DWIDTH -1 downto 0);
		p1_Dout : out std_logic_vector(DWIDTH -1 downto 0);
		p1_rw : in std_logic;
		p1_bw : in std_logic_vector((DWIDTH/8) downto 0) := (others => '0');

		ssramA : out unsigned(AWIDTH -1 downto 0);
		ssramD : inout std_logic_vector(DWIDTH -1 downto 0);
		ssramRW : out std_logic;
		ssramBW : out std_logic_vector((DWIDTH/8) downto 0)
	);
end entity cs_ssram;

architecture structural of cs_ssram is
	component ssram_conn is
	generic(
		DWIDTH	: positive;
		AWIDTH : positive
	);
	port (
		clk : in std_logic;
		A : in unsigned(AWIDTH -1 downto 0);
		Din : in std_logic_vector(DWIDTH -1 downto 0);
		Dout : out std_logic_vector(DWIDTH -1 downto 0);
		rw : in std_logic;
		bw : in std_logic_vector((DWIDTH/8) downto 0) := (others => '0');

		ssramA : out unsigned(AWIDTH -1 downto 0);
		ssramD : inout std_logic_vector(DWIDTH -1 downto 0);
		ssramRW : out std_logic;
		ssramBW : out std_logic_vector((DWIDTH/8) downto 0)
	);
	end component ssram_conn;

	signal A : unsigned(AWIDTH -1 downto 0);
	signal Din : std_logic_vector(DWIDTH -1 downto 0);	-- from SSRAMs
	signal Dout : std_logic_vector(DWIDTH -1 downto 0);	-- towards SSRAMs
	signal BW : std_logic_vector((DWIDTH/8) downto 0);
	signal RW : std_logic;
begin

	-- mux address / data-in / rw / bw
	gen_muxs: process (clk)
		variable iA : unsigned(AWIDTH -1 downto 0);
		variable iDout : std_logic_vector(DWIDTH -1 downto 0);
		variable iRW : std_logic;
		variable iBW : std_logic_vector((DWIDTH/8) downto 0);
	begin
		if (clk_div2 = '0') then
			iA := p0_A;
			iDout := p0_Din;
			iRW := p0_rw;
			for n in 0 to (DWIDTH/8) loop
				iBW(n) := p0_bw(n);
			end loop;
		else -- clk_div2 = '1'
			iA := p1_A;
			iDout := p1_Din;
			iRW := p1_rw;
			for n in 0 to (DWIDTH/8) loop
				iBW(n) := p1_bw(n);
			end loop;
		end if;

		if (clk'event and clk = '1') then
			A <= iA;
			Dout <= iDout;
			RW <= iRW;
			BW <= iBW;	
		end if;
	end process gen_muxs;

	-- instert ssram IO controller
	ssram_io_ctrl: ssram_conn generic map (DWIDTH => DWIDTH, AWIDTH => AWIDTH)
			port map (clk, A, Dout, Din, RW, bw, ssramA, ssramD, ssramRW, ssramBW);

	-- demux data from ssram
	demux_din: process(clk)
	begin
		if (clk'event and clk = '1') then
			if (clk_div2 = '1') then	-- switched
				p0_Dout <= Din;
			else
				p1_Dout <= Din;
			end if;
		end if;
	end process demux_din;

end architecture structural; -- of cs_ssram

--
--
--	SSRAM physical connection (IO) controller
--
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity ssram_conn is
	generic(
		DWIDTH	: positive := 16;
		AWIDTH : positive := 18
	);
	port (
		clk : in std_logic;
		A : in unsigned(AWIDTH -1 downto 0);
		Din : in std_logic_vector(DWIDTH -1 downto 0);
		Dout : out std_logic_vector(DWIDTH -1 downto 0);
		rw : in std_logic;
		bw : in std_logic_vector((DWIDTH/8) downto 0) := (others => '0');

		ssramA : out unsigned(AWIDTH -1 downto 0);
		ssramD : inout std_logic_vector(DWIDTH -1 downto 0);
		ssramRW : out std_logic;
		ssramBW : out std_logic_vector((DWIDTH/8) downto 0)
	);
end entity ssram_conn;

architecture structural of ssram_conn is
	signal dD, ddD, dddD : std_logic_vector(DWIDTH -1 downto 0);
	signal dsel, ddsel : std_logic;
	signal dddSel : std_logic_vector(DWIDTH -1 downto 0);
	attribute preserve_signal : boolean;
	attribute preserve_signal of dddSel: signal is true;	-- instruct compiler to leave these signals
	attribute preserve_signal of dddD: signal is true;
begin
	process(clk, dddD, dddSel)
	begin
		if(clk'event and clk = '1') then
			-- compensate ssram pipeline delay
			dD <= Din;						-- present address / rw
			ddD <= dD;						-- ssram takes address / rw over
			dddD <= ddD;					-- present data
			dsel <= not RW;
			ddsel <= dsel;

			for n in 0 to (DWIDTH -1) loop
				dddsel(n) <= ddsel;
			end loop;

			Dout <= ssramD;
			ssramA <= A;
			ssramRW <= RW;
			ssramBW <= BW;
		end if;

		for n in 0 to (DWIDTH -1) loop
			if (dddSel(n) = '1') then
				ssramD(n) <= dddD(n);
			else
				ssramD(n) <= 'Z';
			end if;
		end loop;

	end process;
end architecture structural; -- of ssram_conn
