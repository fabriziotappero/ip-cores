--------------------------------------------------------------------------------
-- Project    : openFPU64 Multiplier Component
-------------------------------------------------------------------------------
-- File       : fpu_mul.vhd
-- Author     : Peter Huewe  <peterhuewe@gmx.de>
-- Created    : 2010-04-19
-- Last update: 2010-04-19
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: double precision floating point multiplier component
--                     for openFPU64, includes rounding and normalization
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- License: gplv3, see licence.txt
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fpu_package.all;
-------------------------------------------------------------------------------

entity fpu_mul is
  port (
    clk, reset_n           : in  std_logic;  -- reset = standard active low
    cs                     : in  std_logic;  --  mode: 0 = add , 1= sub
    sign_a, sign_b         : in  std_logic;  -- sign bits
    exponent_a, exponent_b : in  std_logic_vector (11 downto 0);  -- exponents of the operands
    mantissa_a, mantissa_b : in  std_logic_vector (57 downto 0);  -- mantissa of operands
    sign_res               : out std_logic;
    exponent_res           : out std_logic_vector(11 downto 0);
    mantissa_res           : out std_logic_vector (57 downto 0);
    rounding_needed        : out std_logic;
    valid                  : out std_logic
    );

end fpu_mul;

-------------------------------------------------------------------------------

architecture rtl of fpu_mul is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
  signal add_result, add_op_a : unsigned (54 downto 0);
  signal add_op_b             : unsigned (12 downto 0);
--  signal mul_result           : unsigned(35 downto 0);
--  signal mul_op_a, mul_op_b   : unsigned(17 downto 0);
  type t_state is (s_calc1, s_calc2, s_calc3, s_finished, s_normalize_right_1, s_load_for_round, s_round, s_load_normalizer_right_2, s_normalize_right_2, s_normalize_left);  -- possible states
  signal state                : t_state;  -- current state

  signal exponent_out : std_logic_vector(11 downto 0);
  signal tmp_result   : std_logic_vector (57 downto 0);
  signal tmp_result2  : std_logic_vector (107 downto 0);

  signal a_is_normal, b_is_normal : std_logic;
-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
begin
----------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  -- purpose: calculates the result of a multiplication
  -- type   : combinational
  -- inputs : sign_a, sign_b, exponent_a, exponent_b, mantissa_a, mantissa_b
  -- outputs: result

  add_result  <= add_op_a + add_op_b;
  a_is_normal <= '0' when unsigned(exponent_a(10 downto 0)) = ALL_ZEROS else '1';
  b_is_normal <= '0' when unsigned(exponent_b(10 downto 0)) = ALL_ZEROS else '1';

  state_trans : process (clk, reset_n, cs)
    variable tmp : unsigned(57 downto 0);
  begin  -- process state_trans
    rounding_needed <= '1';
    if reset_n = '0' then
      state        <= s_calc1;
      sign_res     <= '0';
      valid        <= '0';
      exponent_res <= (others => '0');
      mantissa_res <= (others => '0');
      tmp_result   <= (others => '0');
      tmp_result2  <= (others => '0');
      add_op_a     <= (others => '0');
      add_op_b     <= (others => '0');
    elsif rising_edge(clk) then
      if cs = '0' then
        state        <= s_calc1;
        sign_res     <= '0';
        valid        <= '0';
        exponent_res <= (others => '0');
        mantissa_res <= (others => '0');
        tmp_result   <= (others => '0');
        tmp_result2  <= (others => '0');
        add_op_a     <= (others => '0');
        add_op_b     <= (others => '0');

      else
        sign_res     <= sign_a xor sign_b;
        valid        <= '0';
        --    result       <= (others => '0');
        exponent_res <= exponent_out(11 downto 0);
        mantissa_res <= (others => '0');
        mantissa_res <= tmp_result;
        tmp_result   <= tmp_result;
        tmp_result2  <= tmp_result2;
        case state is

          -- calculate new exponent and load multiplier
          when s_calc1 =>
            add_op_a              <= (others => '0');
            add_op_b              <= (others => '0');
            add_op_a(10 downto 0) <= unsigned(exponent_a(10 downto 0));
            add_op_b(10 downto 0) <= unsigned(exponent_b(10 downto 0));
            tmp_result2           <= std_logic_vector(unsigned(mantissa_a(56 downto 3)) * unsigned(mantissa_b(56 downto 3)));

            state <= s_calc2;
            -- check if one of the operands is zero
            if (unsigned(exponent_a (10 downto 0)) = ZEROS(10 downto 0) and unsigned(mantissa_a (56 downto 3)) = ZEROS(56 downto 3))
              or (unsigned(exponent_b (10 downto 0)) = ZEROS(10 downto 0) and unsigned(mantissa_b (56 downto 3)) = ZEROS(56 downto 3))
            then
              exponent_out <= (others => '0');
              tmp_result   <= (others => '0');
              state        <= s_finished;
            end if;

            -- Nan bu Nan :) is A NotANumber
            if (unsigned(exponent_a (10 downto 0)) = ONES(10 downto 0) and unsigned(mantissa_a (56 downto 3)) /= ZEROS(56 downto 3))
            then
              exponent_out <= (others => '1');
              tmp_result   <= mantissa_a;
              state        <= s_finished;
            end if;
            -- is B NotANumber
            if (unsigned(exponent_b (10 downto 0)) = ONES(10 downto 0) and unsigned(mantissa_b (56 downto 3)) /= ZEROS(56 downto 3))
            then
              exponent_out <= (others => '1');
              tmp_result   <= mantissa_b;
              state        <= s_finished;
            end if;


          -- calculate new exponent, part II, subtract bias
          when s_calc2 =>
            add_op_a (12 downto 0) <= '0'&add_result(11 downto 0);
            add_op_b (12 downto 0) <= DOUBLE_BIAS_2COMPLEMENT(12 downto 0);

            state <= s_calc3;

          -- check if new exponent has to be zero, this happens if result is zero or subnormal
          -- also select upper 57 bits of multiplication and generate stickybit of lower result
          when s_calc3 =>
            state <= s_load_for_round;
            -- if lower bits != zero, sticky bit is 1
            if (unsigned(tmp_result2(49 downto 0)) /= ZEROS(49 downto 0))
            then
              tmp_result <= std_logic_vector(tmp_result2(106 downto 50)) &'1';
            else
              tmp_result <= std_logic_vector(tmp_result2(106 downto 50)) &'0';
            end if;

            -- Is normalization needed?
            if tmp_result2 (105) = '1' then
              state <= s_normalize_right_1;
            end if;


            -- check if exponent is out of range
            -- if it is in preload adder, maybe we need exponent +1 in next state
            exponent_out <= std_logic_vector(add_result(11 downto 0));
            add_op_a     <= (others => '0');
            add_op_b     <= (others => '0');

            add_op_a(11 downto 0) <= add_result(11 downto 0);
            add_op_b(0)           <= '1';
            -- overflow
            if (add_result(12) = '0' and add_result(11) = '1')
            then
              exponent_out <= (others => '1');
              tmp_result   <= (others => '0');
              state        <= s_finished;
            end if;
            -- lower than subnormal - underflow to zero
            if (add_result(12) = '1')
              --and (a_is_normal = '0' or b_is_normal = '0'))
              or (a_is_normal = '0' and b_is_normal = '0')
            then
              exponent_out <= (others => '0');
              add_op_a     <= (others => '0');
              add_op_b     <= (others => '0');
              add_op_b(0)  <= '1';
              tmp_result   <= (others => '0');
              state        <= s_finished;
            else
            end if;



          --Normalization is necessary
          when s_normalize_right_1=>
            tmp_result(57 downto 1) <= '0'&tmp_result(57 downto 2);
            tmp_result(0)           <= tmp_result(1) or tmp_result(0);
            exponent_out            <= std_logic_vector(add_result(11 downto 0));

            state <= s_load_for_round;

          -- preload adder with mantissa and 1, maybe we need this for rounding next step
          when s_load_for_round =>
            add_op_a    <= unsigned(tmp_result(57 downto 3));
            add_op_b    <= (others => '0');
            add_op_b(0) <= '1';
            state       <= s_normalize_left;

          -- shift leading one to correct position
          when s_normalize_left=>
            state <= s_round;
            if tmp_result(55) = '0' and unsigned(exponent_out(11 downto 0)) /= ZEROS(11 downto 0)
            then
              tmp_result(55 downto 0) <= tmp_result(54 downto 0) & tmp_result(0);
              exponent_out            <= std_logic_vector(unsigned(exponent_out) - "1");
              state                   <= s_normalize_left;
            end if;

          --round if necessary
          when s_round=>
            case tmp_result(3 downto 0) is
              when "0101" => tmp_result(3) <= '1';
              when "0110" => tmp_result(3) <= '1';
              when "0111" => tmp_result(3) <= '1';

              when "1100" => tmp_result(57 downto 3) <= std_logic_vector(add_result);
              when "1101" => tmp_result(57 downto 3) <= std_logic_vector(add_result);
              when "1110" => tmp_result(57 downto 3) <= std_logic_vector(add_result);
              when "1111" => tmp_result(57 downto 3) <= std_logic_vector(add_result);

              when others => null;      -- others remain unchanged
            end case;


            state <= s_load_normalizer_right_2;


          -- Check again if Normalization needed, preload adder
          when s_load_normalizer_right_2=>
            add_op_a              <= (others => '0');
            add_op_b              <= (others => '0');
            add_op_a(11 downto 0) <= unsigned(exponent_out(11 downto 0));
            add_op_b(0)           <= '1';

            state <= s_finished;
            if tmp_result(56) = '1' then
              state <= s_normalize_right_2;
            end if;


          -- .Normalize
          when s_normalize_right_2=>
            tmp_result(57 downto 1) <= '0'&tmp_result(57 downto 2);
            tmp_result(0)           <= tmp_result(1) or tmp_result(0);
            exponent_out            <= std_logic_vector(add_result(11 downto 0));
            state                   <= s_finished;


          -- finished  
          when s_finished =>
            state <= s_finished;
            valid <= '1';

          when others => null;
        end case;
      end if;
    end if;
  end process state_trans;
end rtl;

-------------------------------------------------------------------------------
