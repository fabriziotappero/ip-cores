library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tran_reg is
	port (
			clk 	: in std_logic;
			rst 	: in std_logic;
			En 	: in std_logic;
			Num_i : in integer range 0 to 15;
			Num_o	: out integer range 0 to 15
			);
end tran_reg;

architecture Behavioral of tran_reg is

signal temp : integer range 0 to 15;

begin
	process (clk, rst, En, temp)
	begin
		if rst = '1' then
			temp <= 0;
		elsif (clk'event and clk = '1') then
			if En = '1' then 
				temp <= Num_i;
			else
				temp <= temp;
			end if;
		end if;
	end process;
	
	Num_o <= temp;

end Behavioral;

