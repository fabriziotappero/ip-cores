----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:30:57 05/23/2012 
-- Design Name: 
-- Module Name:    Mult - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mult is
    Port ( 
	  
	        A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
			  Hi_to_out : out STD_LOGIC_VECTOR (31 downto 0);
			  Lo_to_out : out STD_LOGIC_VECTOR (31 downto 0)
          );			  
end Mult;

architecture Behavioral of Mult is
begin
       process(A,B)  
		 variable ov : std_logic := '0';
		 variable HiLo : signed(65 downto 0);
		 variable Hi,Lo :signed(31 downto 0);
		 variable A_in,B_in : signed(31 downto 0);
		 begin
		---------------------------------
		-- A_in := signed((A(31)) & A);
		-- B_in := signed(B(31) & B);
		-- HiLo := A_in * B_in;
		-----------------------------------
		-- alternative method
		--HiLo :=  signed((A(31)) & A) * signed(B(31) & B);
		--ov := (not HiLo(63)) and  A_in(31) and B_in(31) or (HiLo(63)) and (not A_in(31)) and (not B_in(31));
		-----------------------------------
		
		 A_in := signed(A);
		 B_in := signed(B);
		 HiLo := (A_in(31) & A_in) * (B_in(31) & B_in);
		 ov := A_in(31) xor B_in(31) xor HiLo(63) xor HiLo(64) xor HiLo(65);		 
		 Hi :=   HiLo(63 downto 32);
		 Lo :=  HiLo(31 downto 0);
		 Lo_to_out <= std_logic_vector(Lo);
		 Hi_to_out <= std_logic_vector(Hi);
				
		 end process; 
		 
end Behavioral;

