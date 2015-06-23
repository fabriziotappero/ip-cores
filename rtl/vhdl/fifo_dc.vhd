--
-- File fifo.vhd (universal FIFO)
-- Author : Richard Herveille
-- rev. 0.1 May 04th, 2001 : Initial release
-- rev. 1.0 May 17th, 2001 : Changed core to use dual_ported_memory entity => wrapper around target specific dual ported RAM.
--          
--          WARNING: DO NOT CHANGE THIS FILE
--                   CHANGE "DPM.VHD" FOR TARGET SPECIFIC MEMORY BLOCKS
--
-- rev. 1.1: June 23nd, 2001. Removed unused "drptr" and "fifo_cnt" signals
-- rev. 1.2: June 29th, 2001. Changed core to reflect changes in "dpm.vhd".

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity FIFO_DC is
	generic(
		DEPTH : natural := 128;
		DWIDTH : natural := 32
	);
	port(
		rclk : in std_logic;                          -- read clock input
		wclk : in std_logic;                          -- write clock input
		aclr : in std_logic := '1';                   -- active low asynchronous clear

		D : in std_logic_vector(DWIDTH -1 downto 0);  -- Data input
		wreq : in std_logic;                          -- write request

		Q : out std_logic_vector(DWIDTH -1 downto 0); -- Data output
		rreq : in std_logic;                          -- read request
		
		rd_empty,                                     -- FIFO is empty, synchronous to read clock
		rd_full,                                      -- FIFO is full, synchronous to read clock
		wr_empty,                                     -- FIFO is empty, synchronous to write clock
		wr_full : out std_logic                       -- FIFO is full, synchronous to write clock
	);
end entity FIFO_DC;

architecture structural of FIFO_DC is
	-- dual ported memory wrapper
	component dual_ported_memory is
	generic(
		AWIDTH : natural := 8;
		DWIDTH : natural := 32
	);
	port(
		wclk : in std_logic;                          -- write clock input
		D : in std_logic_vector(DWIDTH -1 downto 0);  -- Data input
		waddr : in unsigned(AWIDTH -1 downto 0);      -- write clock address input
		wreq : in std_logic;                          -- write request

		rclk : in std_logic;                          -- read clock input
		Q : out std_logic_vector(DWIDTH -1 downto 0); -- Data output
		raddr : in unsigned(AWIDTH -1 downto 0)       -- read clock address input
	);
	end component dual_ported_memory;

	-- bitcount, return no.of bits required for 'n'
	function bitcount(n : in natural) return natural is
		variable tmp : unsigned(32 downto 1);
		variable cnt : integer;
	begin
		tmp := conv_unsigned(n, 32);
		cnt := 32;

		while ( (tmp(cnt) = '0') and (cnt > 0) ) loop
			cnt := cnt -1;
		end loop;

		return natural(cnt);
	end function bitcount;

	constant AWIDTH : natural := bitcount(DEPTH -1); -- 256 entries: range 255 downto 0

	signal rptr, wptr : unsigned(AWIDTH -1 downto 0);
	signal ifull, iempty, wempty, wfull, rempty, rfull : std_logic;
begin
	--
	-- Pointers
	--
	-- read pointer
	gen_rd_ptr: process(rclk, aclr)
	begin
		if (aclr = '0') then
			rptr  <= (others => '0');
		elsif (rclk'event and rclk = '1') then
			if (rreq = '1') then
				rptr  <= rptr +1;
			end if;
		end if;
	end process gen_rd_ptr;

	-- write pointer
	gen_wr_ptr: process(wclk, aclr)
	begin
		if (aclr = '0') then
			wptr <= (others => '0');
		elsif (wclk'event and wclk = '1') then
			if (wreq = '1') then
				wptr <= wptr +1;
			end if;
		end if;
	end process gen_wr_ptr;

	-- insert memory block. dual_ported_memory is a wrapper around a target specific dual ported RAM
	mem: dual_ported_memory generic map(AWIDTH => AWIDTH, DWIDTH => DWIDTH)
		port map(wclk => wclk, D => D, waddr => wptr, wreq => wreq, rclk => rclk, Q => Q, raddr => rptr);

	--
	-- status flags
	--
	iempty <= '1' when (rptr = wptr) else '0';
	ifull  <= '1' when ( (wptr - rptr) >= (DEPTH -2) ) else '0';

	rd_flags: process(rclk, aclr)
	begin
		if (aclr = '0') then
			rempty   <= '1';
			rfull    <=  '0';
			rd_empty <= '1';
			rd_full  <=  '0';
		elsif (rclk'event and rclk = '1') then
			rempty   <= iempty;
			rfull    <= ifull;
			rd_empty <= rempty;
			rd_full  <= rfull;
		end if;
	end process rd_flags;

	wr_flags: process(wclk, aclr)
	begin
		if (aclr = '0') then
			wempty   <= '1';
			wfull    <=  '0';
			wr_empty <= '1';
			wr_full  <=  '0';
		elsif (wclk'event and wclk = '1') then
			wempty   <= iempty;
			wfull    <= ifull;
			wr_empty <= wempty;
			wr_full  <= wfull;
		end if;
	end process wr_flags;
end architecture structural;
