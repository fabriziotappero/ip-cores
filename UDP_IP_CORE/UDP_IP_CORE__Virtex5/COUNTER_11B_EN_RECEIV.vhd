----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:57 11/30/2009 
-- Design Name: 
-- Module Name:    COUNTER_11B_EN_RECEIV - Behavioral 
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

entity COUNTER_11B_EN_RECEIV is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           count_en : in  STD_LOGIC;
           value_O : inout  STD_LOGIC_VECTOR (10 downto 0));
end COUNTER_11B_EN_RECEIV;

architecture Behavioral of COUNTER_11B_EN_RECEIV is

begin

process(clk)
begin
if rst='1' then
		value_O<="00000000000";
else
	if clk'event and clk='1' then
		if count_en='1' then
			value_O<=value_O+"00000000001";
		else
			value_O<=value_O;
		end if;
	end if;
end if;
end process;


end Behavioral;

