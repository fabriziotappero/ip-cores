--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    16:07:18 01/02/06
-- Design Name:    
-- Module Name:    dip_dec - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity disp_dec is
port	(
		disp_dec_in		: in std_logic_vector(3 downto 0);
		disp_dec_out	: out std_logic_vector(6 downto 0)
		);
end disp_dec;


architecture disp_dec_behave of disp_dec is

begin


process (disp_dec_in)
begin
	case disp_dec_in is
		when "0000" =>
			disp_dec_out <= "1000000";
		when "0001" =>
			disp_dec_out <= "1111001";
		when "0010" =>
			disp_dec_out <= "0100100";
		when "0011" =>
			disp_dec_out <= "0110000";
		when "0100" =>
			disp_dec_out <= "0011001";
		when "0101" =>
			disp_dec_out <= "0010010";
		when "0110" =>
			disp_dec_out <= "0000010";
		when "0111" =>
			disp_dec_out <= "1111000";
		when "1000" =>
			disp_dec_out <= "0000000";
		when "1001" =>
			disp_dec_out <= "0010000";
		when "1010" =>
			disp_dec_out <= "0001000";
		when "1011" =>
			disp_dec_out <= "0000011";
		when "1100" =>
			disp_dec_out <= "1000110";
		when "1101" =>
			disp_dec_out <= "0100001";
		when "1110" =>
			disp_dec_out <= "0000110";
		when "1111" =>
			disp_dec_out <= "0001110";		
		when others	=>
			 disp_dec_out <= "1111111";
	end case;
end process;
			
end disp_dec_behave;