-----------------------------------------------------------------------------
-- Dual Port Block Ram (technology independent description)
-- (c) 2006 Joerg Bornschein (jb@capsec.org)
-- All files under GPLv2
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity bram_dp is
	generic (
		depth    : natural := 4096 );
	port (
		clk      : in  std_logic;
		reset    : in  std_logic;
		-- Port 1
		we1      : in  std_logic;
		addr1    : in  std_logic_vector(11 downto 0);
		wdata1   : in  std_logic_vector(31 downto 0);
		-- Port 2
		oe2      : in  std_logic;
		addr2    : in  std_logic_vector(11 downto 0);
		rdata2   : out std_logic_vector(31 downto 0) );
end bram_dp;

-----------------------------------------------------------------------------
-- Implementation -----------------------------------------------------------
architecture rtl of bram_dp is

type mem_type is array(0 to depth-1) of std_logic_vector(31 downto 0);
signal mem : mem_type := (others => x"00000000" );

begin

memproc: process (clk) is
variable a1 : integer;
variable a2 : integer;
begin
	if reset='1' then
		null;
	elsif clk'event and clk='1' then
		if we1='1' then                     -- Port 1
			a1 := to_integer(unsigned(addr1));
			mem(a1) <= wdata1;
		end if;

		if oe2='1' then                     -- Port 2
			a2 := to_integer(unsigned(addr2));
			rdata2 <= mem(a2);
		end if;
	end if;
end process;

end rtl;

