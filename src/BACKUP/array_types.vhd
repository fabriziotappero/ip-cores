library ieee;
use ieee.std_logic_1164.all;

package array_types is
--  type vector_array is array(natural range <>) of std_logic_vector(7 downto 0);    
  type vector_array is array(natural range <>, natural range <>) of std_logic;
end array_types;
  
  