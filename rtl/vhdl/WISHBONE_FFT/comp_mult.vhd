--Since both the real and imaginary values       have the same number of  fractio nal bits, 
--  there is no need to   truncate. 
 
library  IEEE; 
use IEEE.std_logic_1164.all;                            
use ieee.std_logic_arith.all; 
 
entity comp_mult is 
 
generic (   inst_width1 : INTEGER := 14; 
      inst_width2 : INTEGER := 14   
        ); 
 
port  ( Re1  : in std_logic_vector(inst_width1-1 downto 0); 
        Im1  : in std_logic_vector(inst_width1-1 downto 0);  
        Re2  : in std_logic_vector(inst_width2-1 downto 0);  
        Im2  : in std_logic_vector(inst_width2-1 downto 0); 
        Re   : out std_logic_vector(inst_width1 + inst_width2 downto 0); 
         Im    : out std_logic_vector(inst_width1 + inst_width2 downto 0)  
 
);  
end comp_mult; 
 
architecture behavior of  comp_mult is 
--multiplier outputs 
signal product1 :std_logic_vector(inst_width1+inst_width2-1 downto 0);--re1*re2 
signal product2 :std_logic_vector(inst_width1+inst_width2-1 downto 0);--i m1*im2 
signal product3 :std_logic_vector(inst_width1+inst_width2-1 downto 0); 
signal product4 :std_logic_vector(inst_width1+inst_width2-1 downto 0); 
 
 
 
component adder 
 generic (inst_width:integer); 
        port ( 
              inst_A : in std_logic_vector(inst_width-1 downto 0); 
               inst_B : in std_logic_vector(inst_width-1 downto 0); 
                SUM : out std_logic_vector(inst_width downto 0)    
              ); 
 
end component; 
 
 
component subtract 
 generic (inst_width:integer); 
         port ( 
             inst_A : in std_logic_vector(inst_width-1 downto 0); 
              inst_B : in std_logic_vector(inst_width-1 downto 0); 
         DIFF : out std_logic_vector(inst_width downto 0)   
             ); 
end component; 
 
component multiplier  
 generic (inst_width1:integer ; 
  inst_width2:integer 
  ); 
         port ( 
              inst_A : in std_logic_vector(inst_width1-1 downto 0); 
              inst_B : in  std_logic_vector(inst_width2-1 downto 0); 
              PRODUCT_inst  : out 
std_logic_vector(inst_width1+inst_width2-1 downto 0) 
             );  
end component; 
 
 
begin 
 
        U1 : multiplier 
       generic map( inst_width1=>           inst_width1, 
inst_width2=>inst_width2) 
             port map ( inst_A => Re1, inst_B => Re2, PRODUCT_inst => 
product1 ); 
           
        U2 : multiplier 
         generic map( inst_width1=>inst_width1, 
inst_width2=>inst_width2) 
            port map ( inst_A => Im1, inst_B => Im2, PRODUCT_inst => 
product2 ); 
 
        U3 : multiplier 
      generic map( inst_width1=>inst_width1, 
inst_width2=>inst_width2) 
        port map( inst_A => Re1, inst_B => Im2, PRODUCT_inst =>product3 ); 
  
         U4 : multiplier 
      generic map( inst_width1=>inst_width2, inst_width2=>inst_width1) 
              port map ( inst_A => Re2, inst_B => Im1, PRODUCT_inst =>product4); 
 
     U5 : subtract       
       generic map (               inst_width=>inst_width1+inst_width2) 
             port  map(inst_A => product1, inst_B => product2, DIFF => Re ); 
 
        U6 : adder 
                  generic map ( inst_width=>inst_width1+inst_width2)  
              port map ( inst_A => product3, inst_B => product4, SUM =>Im ); 
 
end; 
