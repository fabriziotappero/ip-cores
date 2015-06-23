-------------------------------------------------------------------------------
-- Project    : openFPU64 Add/Sub Component
-------------------------------------------------------------------------------
-- File       : fpu_add.vhd
-- Author     : Peter Huewe  <peterhuewe@gmx.de>
-- Created    : 2010-04-19
-- Last update: 2010-04-19
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: double precision floating point adder/subtractor component
--                     for openFPU64, includes rounding and normalization
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- License: gplv3, see licence.txt
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.fpu_package.all;

entity fpu_add is
  port (
    clk, reset_n           : in  std_logic;  -- reset = standard active low
    mode                   : in  std_logic;  --  mode: 0 = add , 1= sub
    cs                     : in  std_logic;  -- chip select active high
    -- in operands
    sign_a, sign_b         : in  std_logic;  -- sign bits
    exponent_a, exponent_b : in  std_logic_vector (11 downto 0);  -- exponents of the operands
    mantissa_a, mantissa_b : in  std_logic_vector (57 downto 0);  -- mantissa of operands
-- out result
    sign_res               : out std_logic;
    exponent_res           : out std_logic_vector(11 downto 0);
    mantissa_res           : out std_logic_vector (57 downto 0);

    rounding_needed : out std_logic;  -- FUTURE wether rounding is needed or not
    valid           : out std_logic
    );
end fpu_add;
architecture rtl of fpu_add is
  -- controller part



  type t_state is (
    s_reset,
    s_load_wait,
    s_a_is_nan,
    s_b_is_nan,
    s_swap_a_and_b,
    s_invalid_operation_inf_minus_inf,
    s_get_result,
    s_fix_sub_borrow,
    s_normalize_right,
    s_result_is_inf,
    s_normalize_left,
    s_prepare_round_ceiling,
    s_post_normalization,
    s_finished,
    s_zero,
    s_correction_and_round,
    s_prepare_operation,
    s_check_result,
    s_wait_on_normalize_right,
    s_align_b_to_a
    );
  signal state : t_state;

  signal a_s, b_s                       : std_logic             := '0';
  signal a_e, b_e                       : unsigned(11 downto 0) := (others => '0');
  signal a_m, b_m                       : unsigned(57 downto 0) := (others => '0');
  signal alu_result, alu_op_a, alu_op_b : unsigned(57 downto 0) := (others => '0');
  -- Switches adder between Addition and Subtraction, helps to infer 1 big addsub by synthesis tools
  signal alu_mode                       : std_logic             := '0';

  -- status bits generated automatically
  signal a_is_a_denormalized_number, a_is_lesser_than_b, a_is_inf_or_nan, a_is_inf : std_logic := '0';
  signal b_is_unaligned, addition_mode, rounding_case_is_to_ceiling                : std_logic := '0';
  signal b_is_inf, b_is_inf_or_nan, or_signal                                      : std_logic := '0';



  alias result_is_inf   : std_logic is a_is_inf_or_nan;  -- result is stored in a
  alias signs_are_equal : std_logic is addition_mode;
  alias a_e_all_ones    : std_logic is a_is_inf_or_nan;  -- if exponent 111...111 then a is either INF or NAN
  alias b_e_all_ones    : std_logic is b_is_inf_or_nan;  -- if exponent 111...111 then b is either INF or NAN
  alias a_e_all_zeros   : std_logic is a_is_a_denormalized_number;  -- if exponent of a, a is either zero or a denormalized number

begin
  -- FUTURE
  rounding_needed <= '0';


  -- generate internal status signals

  a_is_a_denormalized_number <= '1' when a_e = ZEROS(10 downto 0)               else '0';
  a_is_inf_or_nan            <= '1' when a_e = ONES (10 downto 0)               else '0';
  b_is_inf_or_nan            <= '1' when b_e = ONES(10 downto 0)                else '0';
  b_is_inf                   <= '1' when b_m (54 downto 1) = ZEROS(54 downto 1) else '0';  -- if mantissa is zero and exponent  is 11..111 b is inf
  a_is_inf                   <= '1' when a_m (54 downto 1) = ZEROS(54 downto 1) else '0';  -- if mantissa is zero and exponent is 11..111 a is inf
  a_is_lesser_than_b         <= '1' when a_e(10 downto 0) < b_e(10 downto 0)    else '0';  --  a should be >= b
  b_is_unaligned             <= '1' when a_e /= b_e                             else '0';  -- exponents of a and b have to be the same before addition
  addition_mode              <= '1' when a_s = b_s                              else '0';

  -- this line has this meaning
  -- case a_m (3 downto 0) 
  --  when "1100" => add 1 to a_m(57 downto 3)
  --  when "1101" => add 1 to a_m(57 downto 3)
  --  when "1110" => add 1 to a_m(57 downto 3)
  --  when "1111" => add 1 to a_m(57 downto 3)
  rounding_case_is_to_ceiling <= '1' when a_m(3 downto 0) = "1100" or (a_m(2) = '1' and (a_m(1) = '1' or a_m(0) = '1')) else '0';

  -- Big ADD/SUB, has to be preloaded for each result
  alu_result <= alu_op_a+alu_op_b when alu_mode = '1' else alu_op_a-alu_op_b;

  state_trans : process (clk, reset_n)  -- clock, reset_n, chipselect
  begin
    if reset_n = '0' then
      a_m   <= (others => '0');
      a_e   <= (others => '0');
      a_s   <= '0';
      b_m   <= (others => '0');
      b_e   <= (others => '0');
      b_s   <= '0';
      valid <= '0';

      sign_res     <= '0';
      exponent_res <= (others => '0');
      mantissa_res <= (others => '0');
      alu_op_a     <= (others => '0');
      alu_op_b     <= (others => '0');
      alu_mode     <= '0';
      state        <= s_reset;          -- reset hat vorrang
    elsif rising_edge(clk) then
      if cs = '0' then
        a_m   <= (others => '0');
        a_e   <= (others => '0');
        a_s   <= '0';
        b_m   <= (others => '0');
        b_e   <= (others => '0');
        b_s   <= '0';
        valid <= '0';

        sign_res     <= '0';
        exponent_res <= (others => '0');
        mantissa_res <= (others => '0');
        alu_op_a     <= (others => '0');
        alu_op_b     <= (others => '0');
        alu_mode     <= '0';
        state        <= s_reset;        -- reset hat vorrang
      else

        -- keep values
        a_m          <= a_m;
        a_e          <= a_e;
        a_s          <= a_s;
        b_m          <= b_m;
        b_e          <= b_e;
        b_s          <= b_s;
        valid        <= '0';
        sign_res     <= a_s;
        exponent_res <= std_logic_vector(a_e);
        mantissa_res <= std_logic_vector(a_m);
        alu_op_a     <= alu_op_a;
        alu_op_b     <= alu_op_b;
        alu_mode     <= alu_mode;
        state        <= state;  -- keep state if nothing else specified.


        case state is
          -- reset state, if chipselect is 1 load operands
          when s_reset =>
            if cs = '1' then
              a_s <= sign_a;
              b_s <= sign_b xor mode;   -- "sorts operations" 
              a_m <= unsigned(mantissa_a);
              b_m <= unsigned(mantissa_b);
              a_e <= unsigned(exponent_a);
              b_e <= unsigned(exponent_b);

              state <= s_load_wait;
            end if;

          -- check operands if they are valid (!= nan), if operation is allowed
          -- or if operands need to be swapped
          when s_load_wait =>
            if a_is_inf_or_nan = '1' and a_is_inf = '0' then state                                     <= s_a_is_nan;
            elsif b_is_inf_or_nan = '1' and b_is_inf = '0' then state                                  <= s_b_is_nan;
            --if a and b are infinity and signs are not equal this is an invalid operation
            elsif a_is_inf_or_nan = '1' and b_is_inf_or_nan = '1' and signs_are_equal = '0' then state <= s_invalid_operation_inf_minus_inf;
            -- if only a is infinity then nothing is left to be done
            elsif a_is_inf_or_nan = '1' and a_is_inf = '1' then state                                  <= s_finished;
            elsif a_is_lesser_than_b = '1' then state                                                  <= s_swap_a_and_b;
            else state                                                                                 <= s_prepare_operation;
            end if;

          --operand a is NaN, set sign and finish
          when s_a_is_nan =>
            a_s <= b_s or mode;

            state <= s_finished;

          --operand b is NaN set result=b and finish
          when s_b_is_nan =>
            a_e <= b_e;
            a_m <= b_m;
            a_s <= b_s or mode;

            state <= s_finished;

          -- operands a and b have to be swapped
          when s_swap_a_and_b =>
            a_s <= b_s;
            b_s <= a_s;
            a_e <= b_e;
            b_e <= a_e;
            a_m <= b_m;
            b_m <= a_m;

            state <= s_prepare_operation;

          -- load adder for add/sub
          -- check if b has to be aligned
          when s_prepare_operation =>
            alu_mode <= addition_mode;  -- load alu for s_get_result
            alu_op_a <= a_m;
            alu_op_b <= b_m;

            if b_is_unaligned = '1' then state <= s_align_b_to_a;
            else state                         <= s_get_result;
            end if;

          -- INF - INF or similar is an invalid operation
          when s_invalid_operation_inf_minus_inf =>
            a_m(54) <= '1'; a_s <= '1';

            state <= s_finished;

          -- align b to a so that a_e=b_e
          when s_align_b_to_a =>
            alu_mode <= addition_mode;  -- load alu for s_get_result
            alu_op_a <= a_m;
            alu_op_b <= b_m;

            state <= s_get_result;  -- if a_e=b_e or b_m = 0...00x start calculation
            if b_is_unaligned = '1' then  -- otherwise align b to a
              b_m(56 downto 0) <= '0' & b_m (56 downto 2) & (b_m(1) or b_m(0));
              alu_op_b         <= '0'&'0' & b_m (56 downto 2) & (b_m(1) or b_m(0));
              b_e              <= b_e +1;
              if b_m(56 downto 1) /= 0 then
                -- still not alligned
                state <= s_align_b_to_a;
              end if;
            end if;


          -- assign calculation result
          when s_get_result =>
            b_e <= a_e;  -- in case some steps were skipped due to b_m = 0...00x
            a_m <= alu_result;

            state <= s_check_result;

-- check result:
-- sub borrow occured?
          -- normalization needed?
          -- result is zero?
          -- result is in?
          -- rounding needed?
          when s_check_result =>
            alu_mode <= '1';            -- load alu for s_fix_sub_borrow 
            alu_op_a <= not(a_m);
            alu_op_b <= (57 downto 1 => '0')&'1';

            if a_m(57) = '1' then state                       <= s_fix_sub_borrow;
            elsif a_m(56) = '1' then state                    <= s_normalize_right;  -- a_m(56)='1' -> normalization to the right is needed
            elsif result_is_inf = '1' then state              <= s_result_is_inf;
            elsif a_m(55) = '0' and a_is_inf = '1' then state <= s_zero;
            else state                                        <= s_correction_and_round;
            end if;

          -- sub borrow occured, fix it by *-1 (adder loaded in previous state)
          when s_fix_sub_borrow =>
            a_s <= not a_s;
            a_m <= alu_result;

            if a_m(56) = '1' then state                       <= s_normalize_right;  -- a_m(56)='1' -> normalization to the right is needed
            elsif result_is_inf = '1' then state              <= s_result_is_inf;
            elsif a_m(55) = '0' and a_is_inf = '1' then state <= s_zero;
            else state                                        <= s_correction_and_round;
            end if;

          -- Normalize right 
          when s_normalize_right =>
            a_m(56 downto 0) <= '0' & a_m(56 downto 2)& (a_m(0) or a_m(1));
            a_e              <= a_e +1;

            state <= s_wait_on_normalize_right;

          -- check result of Normalization to the right
          when s_wait_on_normalize_right =>
            if a_is_inf_or_nan = '1' then state <= s_result_is_inf;
            else state                          <= s_correction_and_round;
            end if;

          -- result is infinity
          when s_result_is_inf =>
            a_m <= (others => '0');

            state <= s_finished;

          -- 
          when s_correction_and_round =>
            alu_mode                                            <= '1';  -- load alu for s_prepare_round_ceiling
            alu_op_a                                            <= a_m;
            alu_op_b                                            <= (57 downto 4 => '0')&"1000";
            if a_m(55) = '0' and a_e_all_zeros = '0' then state <= s_normalize_left;
            elsif rounding_case_is_to_ceiling = '1' then state  <= s_prepare_round_ceiling;
            elsif a_m(56) = '1' then state                      <= s_post_normalization;  -- a_m(56)='1' -> postnormalization is needed

            else state <= s_finished; end if;

          -- shift (possible) leading 1 to correct position
          when s_normalize_left=>
            a_m(55 downto 0) <= a_m(54 downto 0) & a_m(0);
            a_e              <= a_e -1;
            alu_mode         <= '1';    -- load alu for s_prepare_round_ceiling
            alu_op_a         <= a_m(57 downto 56) & a_m(54 downto 0) & a_m(0);
            alu_op_b         <= (57 downto 4 => '0')&"1000";


            if a_m(54) = '0' and a_e_all_zeros = '0' then state                         <= s_normalize_left;
            elsif a_m(2 downto 0) = "110" or (a_m(1) = '1' and a_m(0) = '1') then state <= s_prepare_round_ceiling;
            elsif a_m(56) = '1' then state                                              <= s_post_normalization;  -- a_m(56)='1' -> postnormalization is needed
            else state                                                                  <= s_finished; end if;

            
          when s_prepare_round_ceiling =>
            a_m                                <= alu_result;
            if alu_result(56) = '1' then state <= s_post_normalization;  -- a_m(56)='1' -> postnormalization is needed
            else state                         <= s_finished; end if;

          -- shift leading 1 to correct position
          when s_post_normalization =>
            a_m(56 downto 1) <= '0' & a_m(56 downto 2);
            a_e              <= a_e +1;
            state            <= s_finished;

          -- result is zero
          when s_zero =>
            a_s <= '0';  -- im add/sub fall bei allen rundungsmodi ausser round to -inf ist dies richtig!
            a_e <= (others => '0');
            a_m <= (others => '0');

            state <= s_finished;
          -- finished
          when s_finished =>
            valid <= '1';
            state <= s_finished;        -- done here.

        end case;
      end if;
    end if;
  end process;
end rtl;

