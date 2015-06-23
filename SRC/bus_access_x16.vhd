----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Léo Germond
-- 
-- Create Date:    16:48:27 11/08/2009 
-- Design Name: 
-- Module Name:    bus_access_x16 - Behavioral 
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

entity bus_access_x16 is
    Port ( en : in  STD_LOGIC;
           dataRead : in  STD_LOGIC_VECTOR (15 downto 0);
           dataWrite : out  STD_LOGIC_VECTOR (15 downto 0));
end bus_access_x16;

architecture Behavioral of bus_access_x16 is
begin
	
	process(en, dataRead)
	begin
			if en = '1' then
				dataWrite <= dataRead;
			else
				dataWrite <= (others => 'Z');
			end if;
	end process;
end Behavioral;

