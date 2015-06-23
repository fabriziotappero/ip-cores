----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:10:53 10/09/2007 
-- Design Name: 
-- Module Name:    carrysave_adder - Behavioral 
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

      

entity carrysave_adder is
port (p1,p2,p3,p4,p5,p6,p7,p8,p9 :in std_logic_vector ( 15 downto 0);
       s1 : out std_logic_vector (15 downto 0);
       c1 :out std_logic_vector (15 downto 0));


end carrysave_adder;

architecture Behavioral of carrysave_adder is


 component full_adder 
  port (a,b,c :in std_logic_vector(15 downto 0) ;   
        sf,cf :out std_logic_vector(15 downto 0) );
  end component;
  
signal su1,ca1 :std_logic_vector (15 downto 0);
signal su2,ca2 :std_logic_vector (15 downto 0);
signal su3,ca3 :std_logic_vector (15 downto 0);
signal su4,ca4 :std_logic_vector (15 downto 0);
signal su5,ca5 :std_logic_vector (15 downto 0);
signal su6,ca6 :std_logic_vector (15 downto 0);


begin
 fa0 : full_adder port map(p1,p2,p3,su1,ca1);
 fa1 : full_adder port map(p4,p5,p6,su2,ca2);
 fa2 : full_adder port map(p7,p8,p9,su3,ca3);
 fa3 : full_adder port map(ca1,su1,su2,su4,ca4);
 fa4 : full_adder port map(ca3,su3,ca2,su5,ca5);
 fa5 : full_adder port map(ca4,su4,su5,su6,ca6);
 fa6 : full_adder port map(ca6,su6,ca5,s1,c1);
 
     



end Behavioral;

