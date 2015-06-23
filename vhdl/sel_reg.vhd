library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sel_reg is
	port (
			clk 	: in std_logic;
			rst 	: in std_logic;
			En 	: in std_logic;
			sel_i : in std_logic_vector (3 downto 0);
			sel_o	: out std_logic_vector (3 downto 0)
			);
end sel_reg;

architecture Behavioral of sel_reg is

signal temp : std_logic_vector (3 downto 0);

begin
	process (clk, rst, En)
	begin
		if rst = '1' then
			temp <= (others => '0');
		elsif (clk'event and clk = '1') then
			if En = '1' then 
				temp <= sel_i;
			else
				temp <= temp;
			end if;
		end if;
	end process;
	
	sel_o <= temp;
end Behavioral;

