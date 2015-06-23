----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:39:58 02/04/2013 
-- Design Name: 
-- Module Name:    d_ff - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity d_ff is
	generic(N : integer := 8);
	port ( clk, rst : in std_logic;
			d: in std_logic_vector( N - 1 downto 0);
			q : out std_logic_vector( N - 1 downto 0));
end d_ff;

architecture Behavioral of d_ff is

begin
	
	
	process (clk, rst)
	begin
		if(rst = '1') then
			q <= (others => '0');
		elsif (clk'event and clk = '1') then
			q<= d;
		end if;
	end process;

end Behavioral;

