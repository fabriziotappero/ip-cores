----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:15:16 11/27/2009 
-- Design Name: 
-- Module Name:    REG_16B_WREN - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 16bit wide Register with write enable option. 
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

entity REG_16B_WREN is
    Port ( rst : in  STD_LOGIC;
			  clk : in  STD_LOGIC;
           wren : in  STD_LOGIC;
           input : in  STD_LOGIC_VECTOR (15 downto 0);
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end REG_16B_WREN;

architecture Behavioral of REG_16B_WREN is

begin

process(clk)
begin
if rst='1' then
	output<="0000000000000000";
else
if clk'event and clk='1' then
	if wren='1' then
		output<=input;
	end if;
end if;
end if;
end process;

end Behavioral;

