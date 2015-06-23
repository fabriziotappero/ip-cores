library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fullregister is

	generic
	(
		N: integer
	);

	port
	(
		clk		  : in std_logic;
		reset_n	  : in std_logic;
		enable	  : in std_logic;
		clear		  : in std_logic;
		d		  : in std_logic_vector(N-1 downto 0);
		q		  : out std_logic_vector(N-1 downto 0)
		
	);

end entity;

architecture rtl of fullregister is
begin

	process (clk,reset_n,d,clear,enable)
		
	begin
	if reset_n = '0' then				
				q <= (others=>'0');
		elsif (rising_edge(clk)) then

			if enable = '1' then
				if clear='1' then
				
				   q <= (others=>'0');
					
				else 
				   
					q<=d;
				
				end if;
			
				
		end if;
		
	end if;

		
	end process;

end rtl;