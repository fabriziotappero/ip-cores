----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:40:03 02/07/2010 
-- Design Name: 
-- Module Name:    REG_8b_wren - Behavioral 
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

entity REG_8b_wren is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           wren : in  STD_LOGIC;
           input_val : in  STD_LOGIC_VECTOR (7 downto 0);
			  output_val : inout STD_LOGIC_VECTOR(7 downto 0));
end REG_8b_wren;

architecture Behavioral of REG_8b_wren is

begin

process(clk)
begin
if rst='1' then
	output_val<="00000000";
else
	if clk'event and clk='1' then
		if wren='1' then
			output_val<=input_val;
		end if;
	end if;
end if;
end process;

end Behavioral;

