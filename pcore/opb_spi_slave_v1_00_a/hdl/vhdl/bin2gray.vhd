-------------------------------------------------------------------------------
--* 
--* @short convert binary input vector to gray
--* 
--* @generic width              with of input vector
--*
--*    @author: Daniel Köthe
--*   @version: 1.0
--* @date:      2007-11-11
--/
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity bin2gray is
  generic (
    width : integer := 4);
  port (
    in_bin   : in  std_logic_vector(width-1 downto 0);
    out_gray : out std_logic_vector(width-1 downto 0));
end bin2gray;

architecture behavior of bin2gray is

begin  -- behavior

  -- Sequence: 0,1,3,2,6,7,5,4,C,D,F,E,A,B,9,8
  --* convert binary input vector to gray
  bin2gray_proc : process(in_bin)
  begin
    out_gray(width-1) <= in_bin(width-1);
    -- out_gray(3) <= in_bin(3);

    for i in 1 to width-1 loop
      out_gray(width-1-i) <= in_bin(width-i) xor in_bin(width-1-i);
    end loop;  -- i
  end process bin2gray_proc;

  -- i=1 out_gray(2) <= in_bin(3) xor in_bin(2);
  -- i=2 out_gray(1) <= in_bin(2) xor in_bin(1);
  -- i=3 out_gray(0) <= in_bin(1) xor in_bin(0);  
  
end behavior;
