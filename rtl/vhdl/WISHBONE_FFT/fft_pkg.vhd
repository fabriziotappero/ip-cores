
library IEEE; 
USE ieee.std_logic_1164.ALL; 
USE ieee.std_logic_arith.ALL; 
 
package fft_pkg is 
  type ioarray is array (integer range <>) of               std_logic_vector(255 downto 0); 
  function log2(A: integer) return integer; 
end; 
 
package body fft_pkg is 
    function log2(A: integer) return integer is 
    begin 
       for I in 1 to 30 loop  -- Works for up to 32 bit integers 
          if            (2**I > A) then return(I-1); 
          end if; 
      end loop; 
    return(30); 
     end; 
end; 
