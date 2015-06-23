----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:03:30 10/09/2007 
-- Design Name: 
-- Module Name:    wallace_structure - Behavioral 
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



entity wallace_structure is

port(P1,P2,P3,P4,P5,P6,P7,P8,P9 :in std_logic_vector( 15 downto 0);
       product                  :out std_logic_vector( 15 downto 0));
		 


end wallace_structure;

architecture Behavioral of wallace_structure is
signal s1,s2 :std_logic_vector ( 15 downto 0);
signal c_out :std_logic;
component carrysave_adder is
port (p1,p2,p3,p4,p5,p6,p7,p8,p9 :in std_logic_vector ( 15 downto 0);
       s1 : out std_logic_vector (15 downto 0);
       c1 :out std_logic_vector (15 downto 0));
end component;

component carrylook_ahead2 is
port(a1,b1 : in std_logic_vector(15 downto 0);
      s1   :out std_logic_vector(15 downto 0);
      cin   :in std_logic);		

end component;
     
     


begin

ca1:carrysave_adder port map(P1,P2,P3,P4,P5,P6,P7,P8,P9,s1,s2 );
ca2:carrylook_ahead2 port map(s1,s2,product,'0');
      



end Behavioral;

