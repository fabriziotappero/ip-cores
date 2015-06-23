library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.shaPkg.all;

entity stepCount is
	port (												 
		cnt		: out integer range 0 to STMAX-1;
		clk		: in std_logic;
		rst		: in std_logic				
	);
end stepCount;

architecture phy of stepCount is
begin
	process (clk)
		variable c : integer range 0 to STMAX-1;
	begin
		if (rising_edge(clk)) then
			if rst = '1' or c = STMAX-1 then
				c := 0;
			else												
				c := c + 1;
			end if;
		end if;
		
		-- Output the current count
		cnt <= c;
	end process;

end phy;
		 