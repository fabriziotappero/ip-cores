----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 		 david
-- 
-- Create Date:    09:22:22 11/22/2007 
-- Design Name: 
-- Module Name:    barrel - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description:    shift a left by signed value b, result is s
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

entity barrel is
    Port ( 	--clk: IN std_logic;
				--reset: in std_logic;
				a : in  STD_LOGIC_VECTOR (31 downto 0);
				b : in  STD_LOGIC_VECTOR (5 downto 0);
				s : out  STD_LOGIC_VECTOR (31 downto 0));
end barrel;

architecture Behavioral of barrel is

signal l1   : std_logic_vector(31 downto 0);
signal l2   : std_logic_vector(31 downto 0);
signal lf   : std_logic_vector(31 downto 0);


signal r1   : std_logic_vector(31 downto 0);
signal r2   : std_logic_vector(31 downto 0);
signal rf   : std_logic_vector(31 downto 0);

begin	
	-- shift left
	l1 <= 	a 												 when b(1 downto 0) = "00" else
				a(30 downto 0)  & "0"    				 when b(1 downto 0) = "01" else
				a(29 downto 0)  & "00" 					 when b(1 downto 0) = "10" else
				a(28 downto 0)  & "000";
	
	l2 <= 	l1												 when b(3 downto 2) = "00" else
				l1(27 downto 0) & "0000"	 			 when b(3 downto 2) = "01" else
				l1(23 downto 0) & "00000000" 			 when b(3 downto 2) = "10" else
				l1(19 downto 0) & "000000000000";

	lf	 <= 	l2												 when b(4) 			  = '0'  else
				l2(15 downto 0) & "0000000000000000";


	-- shift right (logical shift) (shift at least 1 bit, 0bits only with shift left);
	r1 <= 	"0"					& a(31 downto 1)	 when b(1 downto 0) = "11" else
				"00"					& a(31 downto 2)	 when b(1 downto 0) = "10" else
				"000"					& a(31 downto 3)	 when b(1 downto 0) = "01" else
				"0000"				& a(31 downto 4);  
	
	r2 <= 	r1												 when b(3 downto 2) = "11" else
				"0000"				& r1(31 downto 4)  when b(3 downto 2) = "10" else
				"00000000" 			& r1(31 downto 8)	 when b(3 downto 2) = "01" else
				"000000000000"		& r1(31 downto 12);

	rf	 <= 	r2												 when b(4) 			  = '1'  else
				"0000000000000000"& r2(31 downto 16);
		
	--select left or right ?
	s <= rf when b(5) = '1' else lf;		
	--s <= "00000000000000000000000000000000";
	


end Behavioral;

