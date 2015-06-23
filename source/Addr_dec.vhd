----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:56:35 06/05/2012 
-- Design Name: 
-- Module Name:    Addr_dec - Behavioral 
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

entity Addr_dec is
      port  (    
              addr : in std_logic_vector(1 downto 0);
			     dec_out: out std_logic_vector(3 downto 0)
			    );
end Addr_dec;

architecture Behavioral of Addr_dec is

begin

     process (addr)
	
	   begin
	   case  addr (1 downto 0) is
            when "00" => dec_out <= "1110";
            when "01" => dec_out <= "1101";
            when "10" => dec_out <= "1011";
            when "11" => dec_out <= "0111";
            when others => dec_out <= "1111";
      end case;
	 end process;
end Behavioral;

