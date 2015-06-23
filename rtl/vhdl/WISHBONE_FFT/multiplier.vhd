
library IEEE; 
use IEEE.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
 
entity multiplier is 
      generic ( 
            inst_width1 : INTEGER := 16; 
            inst_width2 : INTEGER := 16 
             ); 
       port ( 
             inst_A : in std_logic_vector(inst_width1-1 downto 0); 
              inst_B : in std_logic_vector(inst_width2-1 downto 0); 
            PRODUCT_inst  : out std_logic_vector(inst_width1 + inst_width2 - 1 downto 0) 
           
            ); 
    end multiplier; 
 
architecture oper of multiplier is 
  signal mult_sig : SIGNED(inst_width1+inst_width2-1 downto 0) ;  
 
begin 
  mult_sig <= SIGNED(inst_A) * SIGNED(inst_B);  
        PRODUCT_inst <= std_logic_vector(mult_sig); 
end oper; 
