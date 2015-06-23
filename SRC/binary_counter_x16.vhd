----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Léo Germond
-- 
-- Create Date:    16:51:22 11/08/2009 
-- Design Name: 
-- Module Name:    binary_counter_x16 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity binary_counter_x16 is
	Port ( 	clk : in  STD_LOGIC;
				reset: in STD_LOGIC;
				set : in  STD_LOGIC;
				inc : in  STD_LOGIC;
				set_value : in  STD_LOGIC_VECTOR (15 downto 0);
				count : out  STD_LOGIC_VECTOR (15 downto 0));
end binary_counter_x16;

architecture Behavioral of binary_counter_x16 is
	signal cnt: unsigned(15 downto 0);
begin
	doCountOrSet: process(clk, inc, set, set_value)
	begin
		if reset = '0' then
			cnt <= to_unsigned(0,16);
		else
			if clk'event and clk = '1' then
				if set = '1' then
					cnt <= unsigned(set_value);
				else
					if inc = '1' then
						cnt <= to_unsigned(to_integer(cnt) + 1, 16) ;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	count <= std_logic_vector(cnt);
end Behavioral;

