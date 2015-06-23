LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.NUMERIC_STD.ALL;

ENTITY adder IS
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);
  PORT (
    OP : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
    A  : IN  STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
    B  : IN  STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
    Ci : IN  STD_LOGIC;
    Y  : OUT STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
    Co : OUT STD_LOGIC);
END adder;

ARCHITECTURE Behavioral OF adder IS

  SIGNAL An : NATURAL RANGE 0 TO 2**w_data - 1;
  SIGNAL Bn : NATURAL RANGE 0 TO 2**w_data - 1;
  SIGNAL Yn : NATURAL RANGE 0 TO 2**(w_data + 1) - 1;

  SIGNAL Cv : STD_LOGIC_VECTOR(0 TO 0);
  SIGNAL Cn : NATURAL RANGE 0 TO 1;

  SIGNAL sum : STD_LOGIC_VECTOR(w_data DOWNTO 0);

BEGIN

  SUM1 : PROCESS (A, B, OP, Ci) IS
  BEGIN  -- PROCESS SUM1
    An <= 0;
    Bn <= 0;

    Cv(0) <= '0';
    Cn    <= 0;

    Yn <= 0;

    sum <= (OTHERS => '0');
    Co  <= '0';
    Y   <= (OTHERS => '0');

    CASE OP IS
      WHEN "00" =>
        An <= to_integer(UNSIGNED(A));
        Bn <= to_integer(UNSIGNED(B));

        Cv(0) <= Ci;
        Cn    <= to_integer(UNSIGNED(Cv));

        Yn <= An + Bn + Cn;

        sum <= STD_LOGIC_VECTOR(to_unsigned(Yn, w_data + 1));
        Co  <= sum(w_data);
        Y   <= sum(w_data - 1 DOWNTO 0);

      WHEN "01" =>
        Y <= '0' & A(15 DOWNTO 1);

      WHEN "10" =>
        Y <= A(14 DOWNTO 0) & '0';

      WHEN "11" =>
        Y <= (OTHERS => '0');

      WHEN OTHERS =>
        NULL;

    END CASE;
  END PROCESS SUM1;

END Behavioral;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY summation IS
  GENERIC (
    w_data : NATURAL RANGE 1 TO 32 := 16);
  PORT (A  : IN  STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
        B  : IN  STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
        OP : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        Y  : OUT STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0));
END summation;

-- Operations:
-- "000" A + B
-- "001" A - B
-- "010" A + 1
-- "011" A - 1
-- "100" SHIFT LEFT
-- "101" SHIFT RIGHT
-- "110" ZERO
-- "111" ONE

ARCHITECTURE Behavioral OF summation IS

  COMPONENT adder IS
    GENERIC (
      w_data : NATURAL RANGE 1 TO 32 := w_data);
    PORT (
      OP : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      A  : IN  STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
      B  : IN  STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
      Ci : IN  STD_LOGIC;
      Y  : OUT STD_LOGIC_VECTOR (w_data - 1 DOWNTO 0);
      Co : OUT STD_LOGIC);
  END COMPONENT adder;

  SIGNAL Ci : STD_LOGIC := '0';
  SIGNAL Bo : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);
  SIGNAL Yr : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0);

  SIGNAL add_op : STD_LOGIC_VECTOR(1 DOWNTO 0);

  CONSTANT ZERO : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0) := (OTHERS => '0');
  CONSTANT ONE : STD_LOGIC_VECTOR(w_data - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(1, w_data));
  
BEGIN

  ADD1 : adder PORT MAP (
    OP => add_op,
    A  => A,
    B  => Bo,
    Y  => Yr,
    Ci => Ci);

  WITH OP SELECT
    Ci <=
    '0' WHEN "000",                     -- Addition
    '1' WHEN "001",                     -- Subtraction
    '0' WHEN "010",                     -- Increment 1
    '1' WHEN "011",                     -- Decrement 1
    '0' WHEN OTHERS;

  WITH OP SELECT
    Bo <=
    B WHEN "000",
    NOT B                                    WHEN "001",
    STD_LOGIC_VECTOR(to_unsigned(1, w_data)) WHEN "010",
    STD_LOGIC_VECTOR(to_signed(-1, w_data))  WHEN "011",
    B WHEN OTHERS;

  WITH OP SELECT
    add_op <=
    "00" WHEN "000",
    "00" WHEN "001",
    "00" WHEN "010",
    "00" WHEN "011",
    "10" WHEN "100",
    "01" WHEN "101",
    "11" WHEN OTHERS;

  WITH OP SELECT
    Y <=
    ZERO WHEN "110",
    ONE  WHEN "111",
    Yr   WHEN OTHERS;

END Behavioral;

