library IEEE;
USE ieee.std_logic_1164.ALL;
--USE IEEE.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY mult_32x32 is
  PORT
    (
     X :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     Y :IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     P :OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
     );
END mult_32x32;

architecture Behavioral of mult_32x32 is

 

begin
  process(X,Y)
  variable Xuns : unsigned(31 downto 0);  -- unsigned
  variable Yuns : unsigned(31 downto 0);  -- unsigned
  variable Puns : unsigned(63 downto 0);  -- unsigned
  begin
  -- type conversion: std_logic_vector -> unsigned
    
  Xuns := unsigned(X);
  Yuns := unsigned(Y);
   
  -- multiplication
  Puns := Xuns * Yuns;
  
  -- type conversion: unsigned -> std_logic_vector
  P <= std_logic_vector(Puns);
  end process;
end behavioral;

