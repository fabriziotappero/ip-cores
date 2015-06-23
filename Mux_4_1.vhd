----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:45:11 04/22/2012 
-- Design Name: 
-- Module Name:    Mux_4_1 - Behavioral 
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

entity Mux_4_1 is
Generic (
         busw : integer := 31
);
    Port ( 
	        Logic_out : in  std_logic_vector(busw downto 0);
           Adder_out : in  std_logic_vector(busw downto 0);
			  Shift_out : in  std_logic_vector(busw downto 0);
			  Slt_out : in  std_logic_vector(busw downto 0);
           ALUmux : in  std_logic_vector(1 downto 0);
           Mux_out : out std_logic_vector(busw downto 0));
end Mux_4_1;

architecture Behavioral of Mux_4_1 is
begin
mux_4_1:process(ALUmux,Logic_out,Adder_out,Shift_out,Slt_out)

begin
        
		
		  case ALUmux is
		       when "10"   => Mux_out <=  Adder_out;
				 when "01"   => Mux_out <=  Slt_out; 
				 when "00"   => Mux_out <=  Shift_out;
				 when "11"   => Mux_out <=  Logic_out;
				 when others => Mux_out <= (others =>'0');
			end case;	              
				           
end process mux_4_1;

end Behavioral;

