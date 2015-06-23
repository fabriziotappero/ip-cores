----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:31:18 05/30/2012 
-- Design Name: 
-- Module Name:    In_mux - Behavioral 
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

entity In_mux is
Generic (
         busw : integer := 31
);
    Port ( 
	        A_in : in  STD_LOGIC_VECTOR (busw downto 0);
			  B_in : in  STD_LOGIC_VECTOR (busw downto 0);
           I : in  STD_LOGIC_VECTOR (busw downto 0);
			  ALUSrcA : in  STD_LOGIC;
           ALUSrcB : in  STD_LOGIC_VECTOR(1 downto 0);
           A : out  STD_LOGIC_VECTOR (busw downto 0);
			  B : out  STD_LOGIC_VECTOR (busw downto 0)
			  );
end In_mux;

architecture Behavioral of In_mux is

begin
          A <= A_in when ALUSrcA = '1' else
			      x"00000000";

			 B <= B_in when ALUSrcB = "00" else
			       "00000000000000000000000000000100" when ALUSrcB = "01" else
					 I when ALUSrcB = "10" else
					 I when ALUSrcB = "11" else -- i have to make shit left 2
					 x"00000000";


end Behavioral;

