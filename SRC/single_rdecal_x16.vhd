----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Léo Germond
-- 
-- Create Date:    19:34:28 11/04/2009 
-- Design Name: 
-- Module Name:    single_rdecal_x16 - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity single_rdecal_x16 is
    Port ( data : in  STD_LOGIC_VECTOR (15 downto 0);
           op : in  STD_LOGIC ;
           decal : out  STD_LOGIC_VECTOR (15 downto 0));
end single_rdecal_x16;

architecture Behavioral of single_rdecal_x16 is

begin
	process(data, op)
	begin
		if op = '1' then
			decal <= "0" & data(15 downto 1);
		else 
			decal <= data;
		end if;
	end process;

end Behavioral;

