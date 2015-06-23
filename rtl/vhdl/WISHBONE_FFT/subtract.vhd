
library IEEE; 
use IEEE.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
 
entity subtract is 
      generic ( 
            inst_width : INTEGER := 32 
            ); 
      port ( 
            inst_A : in std_logic_vector(inst_width-1 downto 0); 
            inst_B : in std_logic_vector(inst_width-1 downto 0); 
             DIFF :  out std_logic_vector(inst_width downto 0) 
           
             ); 
     end subtract; 
 
architecture oper of subtract is 
 signal a_signed, b_signed, diff_signed: SIGNED(inst_width downto 0);   
 
begin 
   a_signed <= SIGNED(inst_A(inst_width-1) & inst_A); 
   b_signed <= SIGNED(inst_B(inst_width-1) & inst_B); 
        diff_signed <= a_signed - b_signed; 
     DIFF <= std_logic_vector(diff_signed); 
end oper; 
 
