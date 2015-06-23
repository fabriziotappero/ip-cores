-- High load test project.
-- Alexey Fedorov, 2014
-- email: FPGA@nerudo.com
--
-- It implements a number of RAM bits depends on given parameters.

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;


ENTITY ram_buf IS
	generic (
		DATA_WIDTH: positive := 12;
		DEPTH_LOG2: positive := 10
		);
  port(
    clk    : in  std_logic;         -- input data clock
--    ena    : in  std_logic;         -- input data enable
    din    : in  std_logic_vector(DATA_WIDTH-1 downto 0);  
    delay  : in  std_logic_vector(DEPTH_LOG2-1 downto 0);	
    dout   : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
END ENTITY ram_buf;


ARCHITECTURE rtl OF ram_buf IS

type TDelayRam is array (0 to 2**DEPTH_LOG2-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal delayram : TDelayRam := (others => (others => '0'));

signal buf_waddr, buf_raddr : unsigned(DEPTH_LOG2-1 downto 0) := (others => '0');


begin

delay_p: process(clk) -- , reset
begin
if(rising_edge(clk)) then 
--	if(ena = '1') then
		delayram(to_integer(buf_waddr)) <= din;
		buf_waddr <= buf_waddr + 1; 
--	end if;
	-- On a read during a write to the same address, the read will
	-- return the OLD data at the address
	dout <= delayram(to_integer(buf_raddr));
	buf_raddr <= buf_waddr - unsigned(delay);
end if;
--if reset = '1' then
--	buf_waddr <= (others => '0');
--end if;
end process;



end rtl;
