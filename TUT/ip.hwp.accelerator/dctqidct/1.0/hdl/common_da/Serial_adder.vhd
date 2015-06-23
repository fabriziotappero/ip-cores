------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 14.06.2004 14:08:22
-- File                 : Serial_adder.vhd
-- Design               : 
------------------------------------------------------------------------------
-- Description  : Serial adder. Consist of one full adder and register for
-- carrybit.
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Serial_adder IS
   PORT( 
      clk     : IN     std_logic;
      in0     : IN     std_logic;   --serial data input 0
      in1     : IN     std_logic;   --serial data input 1
      rst_n   : IN     std_logic;
      start   : IN     std_logic;   --start (ignores carrybit)
      sum_out : OUT    std_logic    --serial data outuput
   );

-- Declarations

END Serial_adder ;

--
ARCHITECTURE rtl OF Serial_adder IS

  SIGNAL carry_bit_r : std_logic;       --register, where carry bit is stored
  SIGNAL carry_bit   : std_logic;       --internal signal for carry bit
  SIGNAL sum         : std_logic;       --internal signal for sum
BEGIN

  clocked : PROCESS (clk, rst_n)
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      carry_bit_r <= '0';

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      carry_bit_r <= carry_bit;
    END IF;
  END PROCESS clocked;

  calc : PROCESS (start, carry_bit_r, in0, in1)

    VARIABLE temp1 : std_logic_vector(1 DOWNTO 0);
    VARIABLE temp2 : std_logic_vector(2 DOWNTO 0);

  BEGIN  -- PROCESS calc
    IF (start = '1') THEN
      temp1 := in0 & in1;
      CASE temp1 IS
        WHEN "00"   =>
          sum       <= '0';
          carry_bit <= '0';
        WHEN "01"   =>
          sum       <= '1';
          carry_bit <= '0';
        WHEN "10"   =>
          sum       <= '1';
          carry_bit <= '0';
        WHEN OTHERS =>
          sum       <= '0';
          carry_bit <= '1';
      END CASE;

    ELSE
      temp2 := carry_bit_r & in0 & in1;
      CASE temp2 IS
        WHEN "000"  =>
          sum       <= '0';
          carry_bit <= '0';
        WHEN "001"  =>
          sum       <= '1';
          carry_bit <= '0';
        WHEN "010"  =>
          sum       <= '1';
          carry_bit <= '0';
        WHEN "011"  =>
          sum       <= '0';
          carry_bit <= '1';
        WHEN "100"  =>
          sum       <= '1';
          carry_bit <= '0';
        WHEN "101"  =>
          sum       <= '0';
          carry_bit <= '1';
        WHEN "110"  =>
          sum       <= '0';
          carry_bit <= '1';
        WHEN OTHERS =>
          sum       <= '1';
          carry_bit <= '1';
      END CASE;
    END IF;

  END PROCESS calc;

  sum_out <= sum;


END rtl;

