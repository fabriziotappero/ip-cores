library IEEE; 
use IEEE.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
 
entity adder is 
      generic ( 
        inst_width : INTEGER := 32        
             ); 
       port (  
            inst_A : in std_logic_vector(inst_width-1 downto            0); 
            inst_B : in std_logic_vector(inst_width-1 downto 0          ); 
            SUM : out std_logic_vector(inst_width downto 0) 
           
            ); 
    end adder; 
 
architecture oper of adder is 
 signal a_signed, b_signed, sum_signed: SIGNED(inst_width downto 0);   
begin 
   a_signed <= SIGNED(inst_A(inst_width-1) & inst_A); 
   b_signed <= SIGNED(inst_B(inst_width-1) & inst_B); 
        sum_signed <= a_signed + b_signed; 
  SUM <= std_logic_vector(sum_signed); 
end oper; 
