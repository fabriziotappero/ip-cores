----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:30:12 11/30/2009 
-- Design Name: 
-- Module Name:    COUNTER_6B_LUT_FIFO_MODE - Behavioral 
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

entity COUNTER_6B_LUT_FIFO_MODE is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           funct_sel : in  STD_LOGIC; -- 0 for lut addressing, 1 for fifo addressing
           count_en : in  STD_LOGIC;
           value_O : inout  STD_LOGIC_VECTOR (5 downto 0));
end COUNTER_6B_LUT_FIFO_MODE;

architecture Behavioral of COUNTER_6B_LUT_FIFO_MODE is

begin

process(clk)
begin
if rst='1' then
	if funct_sel='0' then
		value_O<=(others=>'0');
	else
		value_O<="100111";
	end if;
else
	if clk'event and clk='1' then
		if count_en='1' then
			value_O<=value_O+"000001";
		else
			value_O<=value_O;
		end if;
	end if;
end if;
end process;


end Behavioral;

