library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockDivider is
    Port ( 
		  CLK_Divider_CLR 	 : in  std_logic;
        CLK_Divider_CLK	 	 : in  std_logic;
        CLK_Divider_Out		 : out std_logic
        );
end ClockDivider;

architecture Behavioral of ClockDivider is
	signal tmp_clk  	: std_logic;
	signal count 		: integer range 0 to 2500000;
begin
process (CLK_Divider_CLR, CLK_Divider_CLK)
begin
	if CLK_Divider_CLR = '1' then
		count <= 0;
		tmp_clk <= '1';
	elsif rising_edge(CLK_Divider_CLK) then
		if tmp_clk = '1' then
			if count < 2500000 then
				count <= count + 1;
			else
				tmp_clk <= '0';
		 		count <= 0;
			end if;
		end if;

		if tmp_clk = '0' then
			if count < 2500000 then
				count <= count + 1;
			else
				tmp_clk <= '1';
				count <= 0;
			end if;
	   	end if;
	
	end if;
end process;

CLK_Divider_Out <= tmp_clk;

end Behavioral;
