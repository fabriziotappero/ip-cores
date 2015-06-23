----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:28:06 02/07/2013 
-- Design Name: 
-- Module Name:    sign_comp - Behavioral 
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

entity sign_comp is
	port (sign_a, sign_b : in std_logic;
			sign_c : in std_logic;
			comp_exp : in std_logic;
			eff_sub : in std_logic;
			sign_add : in std_logic;
			sign_res : out std_logic);
end sign_comp;

architecture Behavioral of sign_comp is

	signal sign_int : std_logic; 
	
begin

	process (sign_a, sign_b, sign_c, comp_exp, 
		eff_sub, sign_add)
	begin
		sign_int <= sign_c;
		
		if(eff_sub = '1') then
			if(comp_exp = '1') then 
				sign_int <= sign_a xor sign_b;
			elsif (comp_exp = '0' and sign_add = '0') then
				sign_int <= sign_c;
			else
				sign_int <= sign_a xor sign_b;
			end if;
		end if;
	end process;
	
	sign_res <= sign_int;
		
end Behavioral;

