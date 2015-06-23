-----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity carrylook_ahead2 is
port(a1,b1 : in std_logic_vector(15 downto 0);
      s1   :out std_logic_vector(15 downto 0);
      cin   :in std_logic);		

end carrylook_ahead2;

architecture Behavioral of carrylook_ahead2 is
signal  p ,g : std_logic_vector( 15 downto 0);
signal  c: std_logic_vector( 16 downto 0);
 
begin   
c(0)<= cin;
l1: for i in 0 to 15 generate
p(i)<= a1(i) xor b1(i);

g(i)<=a1(i) and b1(i);

s1(i)<=p(i) xor c(i);
c(i+1)<=g(i) or (p(i) and c(i));

end generate;

end Behavioral;

