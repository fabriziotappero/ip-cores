----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:18:01 03/12/2011 
-- Design Name: 
-- Module Name:    multiplier - Behavioral 
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
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



  
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplier is
	port (
				CLK                : in  std_logic;
				RST                : in  std_logic;
				-- 
				img_size_x         : in  std_logic_vector(15 downto 0);
				img_size_y         : in  std_logic_vector(15 downto 0);
				
				--
				result					: out std_logic_vector(31 downto 0);
				threshold 				: out std_logic_vector(31 downto 0)
			);
end multiplier;

architecture Behavioral of multiplier is

signal prev_x : std_logic_vector(15 downto 0);
signal prev_y : std_logic_vector(15 downto 0);

begin
	process(CLK, RST)
	begin
		if (RST = '1') then
			result <= x"00000000";
			threshold <= x"00000000";
			prev_x <= x"0000";
			prev_y <= x"0000";
		elsif (CLK'event and CLK = '1') then
		
			if (prev_x /= img_size_x or prev_y /= img_size_y) then
				result <= img_size_x * img_size_y;
				threshold <= img_size_x * x"0007";
			end if;
			
			prev_x <= img_size_x;
			prev_y <= img_size_y;
			
		end if;
		
	end process;

end Behavioral;

