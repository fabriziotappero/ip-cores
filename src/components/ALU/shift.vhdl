LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY shift IS
  
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);

  PORT (
    A  : IN  STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
    OP : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    Y  : OUT STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0));

END shift;

ARCHITECTURE Behavioral OF shift IS

  CONSTANT ZERO : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0)
    := (OTHERS => '0');
  CONSTANT ONE  : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0)
    := STD_LOGIC_VECTOR(to_unsigned(1, w_data));

BEGIN  -- Behavioral

  SH1: PROCESS (A,OP)
  BEGIN  -- PROCESS SH1
    CASE OP IS
      WHEN "00" =>
        Y <= A(14 DOWNTO 0) & '0';
      WHEN "01" =>
        Y <= '0' & A(15 DOWNTO 1);
      WHEN "10" =>
        Y <= ZERO;
      WHEN "11" =>
        Y <= ONE;
      WHEN OTHERS =>
        NULL;
    END CASE;
  END PROCESS SH1;

END Behavioral;
