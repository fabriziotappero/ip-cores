----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond 
-- 
-- Create Date:    21:11:24 11/05/2009 
-- Design Name: 
-- Module Name:    add_sub_x16 - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity add_sub_x16 is
    Port ( dataA : in  STD_LOGIC_VECTOR (15 downto 0);
           dataB : in  STD_LOGIC_VECTOR (15 downto 0);
           sum : out  STD_LOGIC_VECTOR (15 downto 0);
           is_signed : in  STD_LOGIC;
			  is_sub : IN std_logic;
           overflow : out  STD_LOGIC);
end add_sub_x16;

architecture Behavioral of add_sub_x16 is
		signal sresult	: SIGNED (16 downto 0);
		signal uresult	: UNSIGNED (16 downto 0);
		signal tRes: std_logic_vector (16 downto 0); -- somme sur 17 bits 
begin
	
	doAddSub: process (is_sub, is_signed, dataA, dataB)
	begin
		uresult <=(others => '-');
		sresult <=(others => '-');
		
		if is_signed = '0' then
			if is_sub = '0' then
				uresult <= unsigned('0' & dataA) + unsigned('0' & dataB);
			else
				uresult <= unsigned('0' & dataA) - unsigned('0' & dataB);
			end if;
		else
			if is_sub = '0' then
				sresult <= signed(dataA(15) & dataA) + signed(dataB(15) & dataB);
			else
				sresult <= signed(dataA(15) & dataA) - signed(dataB(15) & dataB);
			end if;
		end if;
	end process;
	
	
	setTRes: process (is_signed, uresult, sresult)
	begin
		if is_signed = '1' then
			tRes <= std_logic_vector(sresult);
		else
			tRes <= std_logic_vector(uresult);
		end if;
	end process;
	sum <= tRes(15 downto 0);
	
	set_overflow_bit: process(is_signed, is_sub, tRes)
	begin
		if is_signed = '1' then
			overflow <= tRes(16) xor tRes(15);
		else
			overflow <= tRes(16);
		end if;
	end process;

end Behavioral;
