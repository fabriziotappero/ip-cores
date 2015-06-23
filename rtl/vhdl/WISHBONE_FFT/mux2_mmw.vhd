
--Special 2 to 1 mux (mismatched width) 
--7/17/02 
-- First input is data_width bits 
--Second input is data_width+1     bits 
--Ign ores highest bit of second  input 
LIBRARY ieee; 
USE ieee.std_logic_1164.ALL; 
USE ieee.std_logic_arith.ALL; 
 
 
ENTITY mux2_mmw IS 
   GENERIC( data_width : integer := 35   
          ); 
   PORT  (  s :           in std_logic; 
                     in0 : in std_logic_vector(data_width-1 downto 0); 
      in1: in std_logic_vector(data_width downto 0);  
       data: out std_logic_vector(data_width-1 downto 0) 
         ); 
END mux2_mmw ; 
 
-- hds interface_end 
ARCHITECTURE behavior OF mux2_mmw IS 
BEGIN 
process(in0,in1,s) 
begin 
  if s='0' then 
   data<=in0; 
 else 
   data<=in1(data_width-1 downto 0); 
 end if; 
end process; 
END behavior; 
 
