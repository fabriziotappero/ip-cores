----------------------------------------------------------------------------------
-- Company: 
-- Engineer:   Lazaridis Dimitris
-- 
-- Create Date:    23:38:50 04/05/2012 
-- Design Name: 
-- Module Name:    Logic - Behavioral 
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
--USE ieee.std_logic_unsigned.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Logic is
Generic 
(
         busw : integer := 31
);
    Port 
( 
	        A : in  STD_LOGIC_VECTOR (busw downto 0);
           B : in  STD_LOGIC_VECTOR (busw downto 0);
           ALUop : in  STD_LOGIC_VECTOR (1 downto 0);
           S : out  STD_LOGIC_VECTOR  (busw downto 0)
);
end Logic;

architecture Behavioral of Logic is
--signal sel: STD_LOGIC_VECTOR(1 DOWNTO 0);
begin
--sel <=ALUop(1 downto 0);

log:process(ALUop,A,B) 
	 
	 begin
	 
	 
	 CASE ALUop IS
	      When  "00"  =>  S <= A and B;
			When  "01"  =>  S <= A or  B;
         When  "10"  =>  S <= A xor B;
         When  "11"  =>  S <= not(A or B);
 			When others =>  
			                S <= (others =>'0');
	 end Case;
	 


end process log;
end Behavioral;

