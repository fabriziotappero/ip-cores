----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:38:44 04/26/2012 
-- Design Name: 
-- Module Name:    SLT - Behavioral 
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

entity SLT is
Generic (
         busw : integer := 31
);
    Port ( Adder_out : in  STD_LOGIC_VECTOR (0 downto 0);
           Slt_out : out  STD_LOGIC_VECTOR (busw downto 0));
end SLT;

architecture Behavioral of SLT is
begin
sin:process(Adder_out) 
    begin
     if Adder_out(0) = '1' then
        Slt_out <= "00000000000000000000000000000001";
		  else
		  Slt_out <= "00000000000000000000000000000000";
     end if;
	 end process sin; 
end Behavioral;

