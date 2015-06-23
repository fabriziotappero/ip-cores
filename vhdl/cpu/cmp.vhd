----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:14:05 02/11/2007 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

use work.types.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cmp is
	port (
		clk: IN std_logic;
		reset: in std_logic;
		cmp_op : in std_logic_VECTOR(7 downto 0);
		a: IN slv_32;
		b: IN slv_32;
		s: OUT slv_32
	);
end cmp;


architecture Behavioral of cmp is

begin
	
	process (clk, reset)
	begin
	
		if(reset='0') then
			s <= (others => '0');
		elsif(rising_edge(clk)) then 
	
			case cmp_op(1 downto 0) is
				when "01" =>
					if unsigned(a) < unsigned(b) then
						s <= (0 => '1', others => '0');
					else 
						s <= (others => '0');						
					end if;
				when "00" =>
					if signed(a) < signed(b) then
						s <= (0 => '1', others => '0');
					else 
						s <= (others => '0');						
					end if;
				when others =>
					s <= (others => '0');
			end case;
		end if;
	end process;
end Behavioral;

