--
-- File dpm.vhd (dual ported memory)
-- Author : Richard Herveille
-- rev. 0.1 May 17th, 2001 : Initial release
-- 
--       fifo_dc uses this entity to implement the dual ported RAM of the fifo.
--       Change this file to implement target specific RAM blocks.
--
-- rev. 0.2 June 29th, 2001. Changed "std_logic_vector(23 downto 0)" into "std_logic_vector(DWIDTH -1 downto 0)" for 'dout'.
--                           Removed rreq input. Removed obsolete "dout" signal
--                           The design now correctly maps to Altera-EABs and Xilinx-BlockRAMs

--
-- dual ported memory, wrapper for target specific RAM blocks
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity dual_ported_memory is
	generic(
		AWIDTH : natural := 8;
		DWIDTH : natural := 24
	);
	port(
		rclk : in std_logic;                          -- read clock input
		wclk : in std_logic;                          -- write clock input

		D : in std_logic_vector(DWIDTH -1 downto 0);  -- Data input
		waddr : in unsigned(AWIDTH -1 downto 0);      -- write clock address input
		wreq : in std_logic;                          -- write request

		Q : out std_logic_vector(DWIDTH -1 downto 0); -- Data output
		raddr : in unsigned(AWIDTH -1 downto 0)       -- read clock address input
	);
end entity dual_ported_memory;

architecture structural of dual_ported_memory is
	-- example target specific RAM block, 256entries x 24bit
	component VSR256X24M2 is
	port(
		RCK    : in  std_logic;                       -- read clock
		REN    : in  std_logic;                       -- read enable, active low
		RADR   : in  std_logic_vector(7 downto 0);    -- read address

		WCK    : in  std_logic;                       -- write clock
		WEN    : in  std_logic;                       -- write enable, active low
		WADR   : in  std_logic_vector(7 downto 0);    -- write address

		DI     : in  std_logic_vector(23 downto 0);   -- data input, (synchronous to write clock)
		DOUT   : out std_logic_vector(23 downto 0)    -- data output (asynchronous)
	);
	end component VSR256X24M2;
--	signal nrreq, nwreq : std_logic;

	-- generate memory for generic description
	type mem_type is array (2**AWIDTH -1 downto 0) of std_logic_vector(DWIDTH -1 downto 0);
	signal mem : mem_type;

begin
	--
	-- Change the next section(s) for target specific RAM blocks.
	-- The functionality as described below must be maintained! Some target specific RAM blocks have an asychronous output. 
	-- Insert registers at the output if necessary
	--
	-- generic dual ported memory description
	--
	write_mem: process(wclk)
	begin
		if (wclk'event and wclk = '1') then
			if (wreq = '1') then
				mem(conv_integer(waddr)) <= D; -- store D in memory array
			end if;
		end if;
	end process write_mem;

	read_mem: process(rclk)
	begin
		if (rclk'event and rclk = '1') then
			Q <= mem(conv_integer(raddr));
		end if;
	end process read_mem;

	--
	-- target specific example
	--
--	nrreq <= not rreq;
--	nwreq <= not wreq;
--	u1: VSR256X24M2 port map(RCK => rclk, REN => nrreq, RADR => std_logic_vector(raddr),
--											WCK => wclk, WEN => nwreq, WADR => std_logic_vector(waddr),
--											DI => D, DOUT => Q);

end architecture structural;
