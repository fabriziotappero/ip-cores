----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond 
-- 
-- Create Date:    19:50:24 11/04/2009 
-- Design Name: 
-- Module Name:    inverser_x16 - Behavioral 
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

entity inverser_x16 is
    Port ( data : in  STD_LOGIC_VECTOR (15 downto 0);
           inverse : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (15 downto 0));
end inverser_x16;

architecture Behavioral of inverser_x16 is

begin
	process(data, inverse) 
	begin
		if inverse = '1' then
			data_out(15) <= data(0);
			data_out(14) <= data(1);
			data_out(13) <= data(2);
			data_out(12) <= data(3);
			data_out(11) <= data(4);
			data_out(10) <= data(5);
			data_out(9) <= data(6);
			data_out(8) <= data(7);
			data_out(7) <= data(8);
			data_out(6) <= data(9);
			data_out(5) <= data(10);
			data_out(4) <= data(11);
			data_out(3) <= data(12);
			data_out(2) <= data(13);
			data_out(1) <= data(14);
			data_out(0) <= data(15);
		else
			data_out <= data;
		end if;
	end process;

end Behavioral;

