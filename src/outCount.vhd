library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.shaPkg.all;

entity outCount is
	port (												 
		cnt		: out integer range 0 to WOUT-1;
		clk		: in std_logic;
		en 		: in std_logic				
	);
end outCount;

architecture phy of outCount is
begin
	process (clk)
		variable c : integer range 0 to WOUT-1;
	begin
		if (rising_edge(clk)) then
			if en = '0' or c = WOUT-1 then
				c := 0;
			else												
				c := c + 1;
			end if;
		end if;
		
		-- Output the current count
		cnt <= c;
	end process;

end phy;
		 