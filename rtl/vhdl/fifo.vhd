--
-- File fifo.vhd (universal FIFO)
-- Author : Richard Herveille
-- rev.: 0.1 May 04th, 2001
-- rev.: 0.2 June 16th, 2001. Changed "function bitcount" until it compiled under Xilinx Webpack
-- rev.: 0.3 June 23nd, 2001. Removed unused "dummy" variable from function bitcount.
-- rev.: 1.0 June 29th, 2001. Synchronized Q output. Design now correctly maps to Xilinx-BlockRAMs
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity FIFO is
	generic(
		DEPTH : natural := 128;
		WIDTH : natural := 32
	);
	port(
		clk : in std_logic;                           -- clock input
		aclr : in std_logic := '1';                   -- active low asynchronous clear
		sclr : in std_logic := '0';                   -- active high synchronous clear

		D : in std_logic_vector(WIDTH -1 downto 0);   -- Data input
		wreq : in std_logic;                          -- write request

		Q : out std_logic_vector(WIDTH -1 downto 0);  -- Data output
		rreq : in std_logic;                          -- read request
		
		empty,                                        -- FIFO is empty
		hfull,                                        -- FIFO is half full
		full : out std_logic                          -- FIFO is full
	);
end entity FIFO;

architecture structural of FIFO is
	-- bitcount, return no.of bits required for 'n'
	function bitcount(n : in natural) return natural is
		variable tmp : unsigned(32 downto 1);
		variable cnt : natural;
	begin
		tmp := conv_unsigned(n, 32);

-- "while..loop" is not supported by xilinx webpack yet
--		cnt := 32;
--		while ( (tmp(cnt) = '0') and (cnt > 0) ) loop
--			cnt := cnt -1;
--		end loop;

	-- replaced "while..loop" with "loop..exit" for xilinx web-pack
-- "loop" is not supported by xilinx webpack yet
--		cnt := 32;
--		loop
--			exit when ( (tmp(cnt) /= '0') or (cnt = 0) );
--			cnt := cnt -1;
--		end loop;

		-- same construction as above, now using for..loop
-- "exit" statement not supported by xilinx webpack yet (what IS supported ?????)
--		for cnt in 32 downto 1 loop
--			exit when ( (tmp(cnt) /= '0') or (cnt = 0) );
--		end loop;

		-- yet another try
		cnt := 32;
		for dummy in 32 downto 1 loop
			if (tmp(cnt) = '0') then
				cnt := cnt -1;
			end if;
		end loop;

		return cnt;
	end function bitcount;

	constant ADEPTH : natural := bitcount(DEPTH -1); -- 256 entries: range 255 downto 0

	type mem_type is array (DEPTH -1 downto 0) of std_logic_vector(WIDTH -1 downto 0);
	signal mem : mem_type; -- VHDL '87 syntax

	signal rptr, wptr : unsigned(ADEPTH -1 downto 0);
	signal fifo_cnt : unsigned(ADEPTH downto 0);
begin
	-- read pointer
	gen_rd_ptr: process(clk, aclr)
	begin
		if (aclr = '0') then
			rptr <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (sclr = '1') then
				rptr <= (others => '0');
			elsif (rreq = '1') then
				rptr <= rptr +1;
			end if;
		end if;
	end process gen_rd_ptr;

	-- write pointer
	gen_wr_ptr: process(clk, aclr)
	begin
		if (aclr = '0') then
			wptr <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (sclr = '1') then
				wptr <= (others => '0');
			elsif (wreq = '1') then
				wptr <= wptr +1;
			end if;
		end if;
	end process gen_wr_ptr;

	-- memory array operations
	gen_mem: process(clk)
	begin
		if (clk'event and clk = '1') then
			if (wreq = '1') then
				mem(conv_integer(wptr)) <= D; -- store D in memory array
			end if;
			Q <= mem(conv_integer(rptr));    -- assign output
		end if;
	end process gen_mem;

	-- number of words in fifo
	gen_fifo_cnt: process(clk, aclr, fifo_cnt, wreq, rreq)
		variable count : unsigned(ADEPTH downto 0);
	begin
		count := fifo_cnt;

		if (wreq = '1') then
			count := count +1;
		end if;
		if (rreq = '1') then
			count := count -1;
		end if;

		if (aclr = '0') then
			fifo_cnt <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (sclr = '1') then
				fifo_cnt <= (others => '0');
			else
				fifo_cnt <= count;
			end if;
		end if;
	end process gen_fifo_cnt;

	-- status flags
	empty <= '1' when (fifo_cnt = 0) else '0';
	hfull <= fifo_cnt(ADEPTH -1);
	full  <= fifo_cnt(ADEPTH);
end architecture structural;
