----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:46:29 06/24/2012 
-- Design Name: 
-- Module Name:    NPC_mux - Behavioral 
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

entity NPC_mux is
port (
      clk   : in std_logic;
		Zero_in,EqNq : in std_logic;
		From_N: in std_logic_vector(31 downto 0);
		From_A: in std_logic_vector(31 downto 0);
		From_M: in std_logic_vector(31 downto 0);
		PCSource: in std_logic_vector(1 downto 0);
		NPC_out: out std_logic_vector(31 downto 0)  
		
		
		);
end NPC_mux;

architecture Behavioral of NPC_mux is

begin
      process(clk,PCSource,From_N,From_A,From_M,Zero_in)
		begin
		if (FALLING_EDGE(clk))then		
	   case PCSource is
		    when "00" => NPC_out <= From_N;
		    when "01" => 
			     case EqNq is
				  when '0' => 
				  if Zero_in = '1' then
				  NPC_out <= From_M;
				  else
				  NPC_out <= From_N;
				  end if;
				  when '1' => 
				  if Zero_in = '0' then
				  NPC_out <= From_M;
				  else
				  NPC_out <= From_N;
				  end if;
				  when others => NPC_out <= (others => '0');
				  end case;
			 when "10" => NPC_out <= From_A;
			 when others => NPC_out <= (others => '0');
		end case;
      end if;

      end process;

end Behavioral;

