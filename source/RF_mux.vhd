----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:02:24 06/24/2012 
-- Design Name: 
-- Module Name:    RF_mux - Behavioral 
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

entity RF_mux is
port (
      clk   : in std_logic;
		RFmux : in std_logic_vector(2 downto 0);
      Hi_in : in std_logic_vector(31 downto 0);
      Lo_in : in std_logic_vector(31 downto 0);
      Alu_in: in std_logic_vector(31 downto 0);
      From_N : in std_logic_vector(31 downto 0);		
      Mdr_fr_out : in std_logic_vector(31 downto 0);
      RF_out: out std_logic_vector(31 downto 0)
      );

end RF_mux;

architecture Behavioral of RF_mux is

begin
      process(clk,RFmux)
		begin
		if (FALLING_EDGE(clk))then
		case RFmux is
		           when "000" => RF_out <= Hi_in;
					  when "010" => RF_out <= Lo_in;
					  when "100" => RF_out <= Alu_in;
					  when "110" => RF_out <= Mdr_fr_out;
					  when "001" => RF_out <= From_N;
		           when others => RF_out <= (others => '0');
		end case;
		end if;
      end process;
end Behavioral;

