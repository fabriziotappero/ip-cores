----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:05:48 12/04/2009 
-- Design Name: 
-- Module Name:    ENABLE_USER_DATA_TRANSMISSION - Behavioral 
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

entity ENABLE_USER_DATA_TRANSMISSION is
    Port ( rst : in STD_LOGIC;
			  clk : in  STD_LOGIC;
           start_usr_data_trans : in  STD_LOGIC;
           stop_usr_data_trans : in  STD_LOGIC;
           usr_data_sel : out  STD_LOGIC);
end ENABLE_USER_DATA_TRANSMISSION;

architecture Behavioral of ENABLE_USER_DATA_TRANSMISSION is

signal usr_data_sel_prev : std_logic :='0';

begin

process(clk)
begin
if rst='1' then
	usr_data_sel<='0';
	usr_data_sel_prev<='0';
else
	if clk'event and clk='1' then
		if (start_usr_data_trans='1' and usr_data_sel_prev='0') then 
			usr_data_sel<='1';
			usr_data_sel_prev<='1';
		end if;
		if (stop_usr_data_trans='0' and usr_data_sel_prev='1') then -- stop_usr_data_trans is active low 
			usr_data_sel<='0';
			usr_data_sel_prev<='0';
		end if;
	end if;
end if;
end process;

end Behavioral;

