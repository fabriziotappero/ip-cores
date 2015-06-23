----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:30:09 11/08/2009 
-- Design Name: 
-- Module Name:    bus_register_x16 - Behavioral 
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

entity bus_register_x16 is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           re : in  STD_LOGIC;
           we : in  STD_LOGIC;
           dataIn : in  STD_LOGIC_VECTOR (15 downto 0);
           dataOut : out STD_LOGIC_VECTOR (15 downto 0));
end bus_register_x16;

architecture Behavioral of bus_register_x16 is
	signal data: std_logic_vector(15 downto 0);
begin

	tristate: process(we, data) is
	begin
		if we = '1' then
			dataOut <= data;
		else
			dataOut <= (others=>'Z');
		end if;
	end process;
	
	readData: process(clk) is
	begin
		if clk'event and clk = '1' then
			if re = '1' then
				data <= dataIn;
			end if;
		end if;
	end process;
	
end Behavioral;

