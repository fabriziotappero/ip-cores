----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:38:55 03/02/2011 
-- Design Name: 
-- Module Name:    MODE_SEL_REGISTER - Behavioral 
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

entity MODE_SEL_REGISTER is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rx_sof : in  STD_LOGIC;
           rx_eof : in  STD_LOGIC;
           en : in  STD_LOGIC;
           sel : out  STD_LOGIC);
end MODE_SEL_REGISTER;

architecture Behavioral of MODE_SEL_REGISTER is

signal sel_t: std_logic;

begin

process(clk)
begin

if rst='1' or rx_sof='0' or rx_eof='0' then
	sel_t <= '0';
else
	if clk'event and clk='1' then
		if en='1' then
			sel_t <= '1';
		else
			sel_t <= sel_t;
		end if;
	end if;
end if;
end process;

sel <= (en or sel_t) and rx_eof;

end Behavioral;

