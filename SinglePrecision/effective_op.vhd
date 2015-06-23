----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:30:56 02/06/2013 
-- Design Name: 
-- Module Name:    effective_op - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity effective_op is
	port (sign_a, sign_b, sign_c : in std_logic;
			sub: in std_logic;
			eff_sub : out std_logic);
end effective_op;

architecture Behavioral of effective_op is

	signal sign_a_x_b : std_logic;
	signal sub_string : std_logic_vector (2 downto 0);

begin
	sign_a_x_b <= sign_a xor sign_b;
	
	sub_string (0) <= sign_c;
	sub_string (1) <= sign_a_x_b;
	sub_string (2) <= sub;
	
	with (sub_string) select eff_sub <=
		'0' when "000",
		'1' when "001",
		'1' when "010",
		'0' when "011",
		'1' when "100",
		'0' when "101",
		'0' when "110",
		'1' when "111",
		'0' when others;

end Behavioral;

