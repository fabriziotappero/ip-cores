LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY logic IS
  
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);

  PORT (
    A  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    B  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    OP : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
    Y  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END logic;

ARCHITECTURE Behavioral OF logic IS

  CONSTANT zero : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN  -- Behavioral

  WITH OP SELECT
    Y <=
    A       WHEN "000",
    NOT A   WHEN "001",
    A AND B WHEN "010",
    A OR B  WHEN "011",
    A XOR B WHEN "100",
    B       WHEN "101",
    zero    WHEN "110",
    zero    WHEN "111",
    zero    WHEN OTHERS;

END Behavioral;
