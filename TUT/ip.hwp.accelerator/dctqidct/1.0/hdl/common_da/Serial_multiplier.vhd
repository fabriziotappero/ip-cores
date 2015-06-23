------------------------------------------------------------------------------
-- Author               : Timo Alho
-- e-mail               : timo.a.alho@tut.fi
-- Date                 : 14.06.2004 15:03:07
-- File                 : Serial_multiplier.vhd
-- Design               : 
------------------------------------------------------------------------------
-- Description  : Serial multiplier (with signed numbers) using shift-and-add
-- topology.
--
-- Two's complement multiplication:
-- A sequence of two's complement additions of shifted multiplicands expect for
-- last step where the shifted multiplicand corresponfing to MSB must be
-- negated.
-- Before adding a shifted multiplicand to the partial product, an additional
-- bit is added to the left of the partial product using sign extension.
--
-- Usage: Multiplicand is fed into input accoring to the bits of the
-- multiplier (starting with multipliers LSB).
--
-- Example:
--      01011 = 11
--  *   01101 = 13
--  _________
--      01011
--     00000
--    01011
--   01011
--  00000
--  _________
--  010001111 = 143
--
-- The input sequence in this case should be 11, 0, 11, 11, 0.
-- Before the first input value, signal start should be held high during one
-- clock cycle. During the last input value, signal last_value should be held
-- high. 
--
------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;

ENTITY Serial_multiplier IS
   GENERIC( 
      coeffw_g    : integer := 14;
      i_dataw_g   : integer := 18;
      round_val_g : integer := 64
   );
   PORT( 
      clk        : IN     std_logic;
      --last_value must be '1', when last bit (MSB) of multiplier is
      --processed
      last_value : IN     std_logic;
      --multiplicand input
      mul_in     : IN     std_logic_vector (coeffw_g-1 DOWNTO 0);
      rst_n      : IN     std_logic;
      --start = '1' clears the partial result register
      start      : IN     std_logic;
      --result output
      mul_out    : OUT    std_logic_vector (i_dataw_g-1 DOWNTO 0)
   );

-- Declarations

END Serial_multiplier ;

--
ARCHITECTURE rtl OF Serial_multiplier IS
  SIGNAL partial_res_r : std_logic_vector(i_dataw_g DOWNTO 0);
                                        -- paritial result is stored here

  SIGNAL extended_input  : signed(coeffw_g DOWNTO 0);
  SIGNAL shifted_partres : signed(coeffw_g DOWNTO 0);
  SIGNAL sum_out         : signed(coeffw_g DOWNTO 0);

BEGIN

  -- purpose: adds one bit to the left of input using sign extension
  -- type   : combinational
  -- inputs : mul_in
  -- outputs: extended_input
  ext_in          : PROCESS (mul_in)
  BEGIN  -- PROCESS ext_in
    extended_input(coeffw_g)            <= mul_in(coeffw_g-1);  --MSB
    extended_input(coeffw_g-1 DOWNTO 0) <= signed(mul_in);
  END PROCESS ext_in;

  -- purpose: shifts partial result (arithmeticly) by one
  -- type   : combinational
  -- inputs : partial_res_r
  -- outputs: shifted_partres
  sh_partres      : PROCESS (partial_res_r)
    VARIABLE temp : signed(coeffw_g DOWNTO 0);
  BEGIN
    temp := shr(signed(partial_res_r(i_dataw_g DOWNTO i_dataw_g-coeffw_g)),
                conv_unsigned(1, 1));
    shifted_partres <= temp;
  END PROCESS sh_partres;

  -- purpose: adds or subtracts partial result and input
  -- type   : combinational
  -- inputs : shifted_input, shifted_sum, last_value
  -- outputs: sum_out
  sum : PROCESS (extended_input, shifted_partres, last_value)
  BEGIN  -- PROCESS sum
    IF (last_value = '1') THEN
      sum_out <= shifted_partres - extended_input;
    ELSE
      sum_out <= shifted_partres + extended_input;
    END IF;
  END PROCESS sum;


  clocked      : PROCESS (clk, rst_n)
    VARIABLE i : integer;
  BEGIN  -- PROCESS clocked
    IF rst_n = '0' THEN                 -- asynchronous reset (active low)
      partial_res_r <= (OTHERS => '0');  -- clear partial result register

    ELSIF clk'event AND clk = '1' THEN  -- rising clock edge
      IF (start = '1') THEN
        --put rounding value into partial result register
        partial_res_r <= conv_std_logic_vector(round_val_g, i_dataw_g+1);

      ELSE
        --save sum into partial result register
        partial_res_r(i_dataw_g DOWNTO i_dataw_g-coeffw_g) <=
          conv_std_logic_vector(sum_out, coeffw_g+1);

        FOR i IN i_dataw_g-coeffw_g DOWNTO 1 LOOP
          partial_res_r(i-1) <= partial_res_r(i);  --shift last bits
        END LOOP;  -- i

      END IF;
    END IF;
  END PROCESS clocked;

  --MSB of partial result register contains no information!
  mul_out <= partial_res_r(i_dataw_g-1 DOWNTO 0);

END rtl;


























