----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:46:33 12/04/2009 
-- Design Name: 
-- Module Name:    ALLOW_ZERO_UDP_CHECKSUM - Behavioral 
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

entity ALLOW_ZERO_UDP_CHECKSUM is
    Port ( clk : in  STD_LOGIC;
           input : in  STD_LOGIC;
			  output_to_readen  : out STD_LOGIC;
           output_to_datasel : out  STD_LOGIC);
end ALLOW_ZERO_UDP_CHECKSUM;

architecture Behavioral of ALLOW_ZERO_UDP_CHECKSUM is

signal input_reg : std_logic;

begin

process(clk)
begin
	if clk'event and clk='1' then
		input_reg<=input;
	end if;
end process;

output_to_readen<=input_reg;

process(clk)
begin
	if clk'event and clk='1' then
		output_to_datasel<=input_reg;
	end if;
end process;

end Behavioral;

