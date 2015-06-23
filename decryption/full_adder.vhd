----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:41:01 10/09/2007 
-- Design Name: 
-- Module Name:    full_adder - Behavioral 
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



entity full_adder is    

port (    a,b,c : in std_logic_vector (15 downto 0);
          sf,cf : out std_logic_vector (15 downto 0));
end full_adder;

architecture Behavioral of full_adder is
signal sig:std_logic_vector (15 downto 0);
begin
   sf <= a xor b xor c;
   sig <= (a and b)or (a and c) or (b and c);
   cf <= (sig(14 downto 0) & '0');
end Behavioral;

