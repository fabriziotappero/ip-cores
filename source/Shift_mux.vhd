----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Lazaridis Dimitris
-- 
-- Create Date:    22:19:25 04/25/2012 
-- Design Name: 
-- Module Name:    Shift_mux - Behavioral 
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

entity Shift_mux is

Port
(
	        A : in  STD_LOGIC_VECTOR (4 downto 0);
           Shamt : in  STD_LOGIC_VECTOR (4 downto 0);
           sv : in  STD_LOGIC;
			  lui : in  STD_LOGIC;
           Shamt_out : out  STD_LOGIC_VECTOR (4 downto 0)
);
end Shift_mux;

architecture Behavioral of Shift_mux is
begin
        
           
         Shamt_out <= "10000" when lui = '1' else
			               Shamt when sv = '0'  else
			                   A when sv = '1'  else
							  "00000";

end Behavioral;

