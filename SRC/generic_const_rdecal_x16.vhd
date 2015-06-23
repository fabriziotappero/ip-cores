----------------------------------------------------------------------------------
-- Company: 
-- Engineer:  Léo Germond
-- 
-- Create Date:    14:34:40 11/05/2009 
-- Design Name: 
-- Module Name:    generic_const_rdecal_x16 - Behavioral 
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

entity generic_const_rdecal_x16 is
	 generic
	 (
		BIT_DECAL : natural range 0 to 15
	 );
    Port ( data : in  STD_LOGIC_VECTOR (15 downto 0);
           en : in  STD_LOGIC;
           decal : out  STD_LOGIC_VECTOR (15 downto 0));
end generic_const_rdecal_x16;

architecture Behavioral of generic_const_rdecal_x16 is
	constant PADDING: STD_LOGIC_VECTOR(0 to BIT_DECAL-1) := (others => '0');
begin
	process(data, en)
	begin
		if en = '1' then
			decal <= PADDING & data(15 downto BIT_DECAL);
		else 
			decal <= data;
		end if;
	end process;
end Behavioral;

