----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Lazaridis Dimitris
-- 
-- Create Date:    00:18:51 04/23/2012 
-- Design Name: 
-- Module Name:    Shift - Behavioral 
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
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.Std_logic_arith.all;



-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Shift is
Port 
(
           rst : in  STD_LOGIC;
			  B : in  STD_LOGIC_VECTOR (31 downto 0);
           ALUop : in  STD_LOGIC_VECTOR (1 downto 0);
           Shamt_in : in  STD_LOGIC_VECTOR (4 downto 0);
           S : out  STD_LOGIC_VECTOR (31 downto 0)
);
end Shift;

architecture Behavioral of Shift is


begin


sht:process(rst,ALUop,B,Shamt_in)
variable to_int: integer; 
variable shift_temp : STD_LOGIC_VECTOR (31 downto 0);
begin
     
	  
	  if rst = '0' then
	     S <= x"00000000";
	  else	
     to_int := CONV_INTEGER(Shamt_in); 
	  case ALUop is
				    when "00" => shift_temp := std_logic_vector(unsigned(B) sll to_int); --shift_B sll 
					 when "01" => shift_temp := B;
					 when "10" => shift_temp := std_logic_vector(unsigned(B) srl to_int); --srl to_int; 
					 when "11" => shift_temp := to_stdlogicvector(to_bitvector(B) sra to_int);--sra to_int;  
					 when others => S <=(others=>'0');
	  end case;
	  end if;
 S <= shift_temp; 
end process sht;
end Behavioral;

