---------------------------------------------------------------------
-- TITLE: Multiplication and Division Unit
-- AUTHORS: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 1/31/01
-- FILENAME: mult.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the multiplication and division unit in 32 clocks.
--
--    To reduce space, compile your code using the flag "-mno-mul" which 
--    will use software base routines in math.c if USE_SW_MULT is defined.
--    Then remove references to the entity mult in mlite_cpu.vhd.
--
-- MULTIPLICATION
-- long64 answer = 0;
-- for(i = 0; i < 32; ++i)
-- {
--    answer = (answer >> 1) + (((b&1)?a:0) << 31);
--    b = b >> 1;
-- }
--
-- DIVISION
-- long upper=a, lower=0;
-- a = b << 31;
-- for(i = 0; i < 32; ++i)
-- {
--    lower = lower << 1;
--    if(upper >= a && a && b < 2)
--    {
--       upper = upper - a;
--       lower |= 1;
--    }
--    a = ((b&2) << 30) | (a >> 1);
--    b = b >> 1;
-- }
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.mlite_pack.all;

entity mult is
   generic(mult_type  : string := "DEFAULT");
   port(clk       : in std_logic;
        reset_in  : in std_logic;
        a, b      : in std_logic_vector(31 downto 0);
        mult_func : in mult_function_type;
        c_mult    : out std_logic_vector(31 downto 0);
        pause_out : out std_logic);
end; --entity mult

architecture logic of mult is

   constant MODE_MULT : std_logic := '1';
   constant MODE_DIV  : std_logic := '0';

   signal mode_reg    : std_logic;
   signal negate_reg  : std_logic;
   signal sign_reg    : std_logic;
   signal sign2_reg   : std_logic;
   signal count_reg   : std_logic_vector(5 downto 0);
   signal aa_reg      : std_logic_vector(31 downto 0);
   signal bb_reg      : std_logic_vector(31 downto 0);
   signal upper_reg   : std_logic_vector(31 downto 0);
   signal lower_reg   : std_logic_vector(31 downto 0);

   signal a_neg       : std_logic_vector(31 downto 0);
   signal b_neg       : std_logic_vector(31 downto 0);
   signal sum         : std_logic_vector(32 downto 0);
   
begin
 
   -- Result
   c_mult <= lower_reg when mult_func = MULT_READ_LO and negate_reg = '0' else 
             bv_negate(lower_reg) when mult_func = MULT_READ_LO 
                and negate_reg = '1' else
             upper_reg when mult_func = MULT_READ_HI and negate_reg = '0' else 
             bv_negate(upper_reg) when mult_func = MULT_READ_HI 
                and negate_reg = '1' else
             ZERO;
   pause_out <= '1' when (count_reg /= "000000") and 
             (mult_func = MULT_READ_LO or mult_func = MULT_READ_HI) else '0';

   -- ABS and remainder signals
   a_neg <= bv_negate(a);
   b_neg <= bv_negate(b);
   sum <= bv_adder(upper_reg, aa_reg, mode_reg);
    
   --multiplication/division unit
   mult_proc: process(clk, reset_in, a, b, mult_func,
      a_neg, b_neg, sum, sign_reg, mode_reg, negate_reg, 
      count_reg, aa_reg, bb_reg, upper_reg, lower_reg)
      variable count : std_logic_vector(2 downto 0);
   begin
      count := "001";
      if reset_in = '1' then
         mode_reg <= '0';
         negate_reg <= '0';
         sign_reg <= '0';
         sign2_reg <= '0';
         count_reg <= "000000";
         aa_reg <= ZERO;
         bb_reg <= ZERO;
         upper_reg <= ZERO;
         lower_reg <= ZERO;
      elsif rising_edge(clk) then
         case mult_func is
            when MULT_WRITE_LO =>
               lower_reg <= a;
               negate_reg <= '0';
            when MULT_WRITE_HI =>
               upper_reg <= a;
               negate_reg <= '0';
            when MULT_MULT =>
               mode_reg <= MODE_MULT;
               aa_reg <= a;
               bb_reg <= b;
               upper_reg <= ZERO;
               count_reg <= "100000";
               negate_reg <= '0';
               sign_reg <= '0';
               sign2_reg <= '0';
            when MULT_SIGNED_MULT =>
               mode_reg <= MODE_MULT;
               if b(31) = '0' then
                  aa_reg <= a;
                  bb_reg <= b;
               else
                  aa_reg <= a_neg;
                  bb_reg <= b_neg;
               end if;
               if a /= ZERO then
                  sign_reg <= a(31) xor b(31);
               else
                  sign_reg <= '0';
               end if;
               sign2_reg <= '0';
               upper_reg <= ZERO;
               count_reg <= "100000";
               negate_reg <= '0';
            when MULT_DIVIDE =>
               mode_reg <= MODE_DIV;
               aa_reg <= b(0) & ZERO(30 downto 0);
               bb_reg <= b;
               upper_reg <= a;
               count_reg <= "100000";
               negate_reg <= '0';
            when MULT_SIGNED_DIVIDE =>
               mode_reg <= MODE_DIV;
               if b(31) = '0' then
                  aa_reg(31) <= b(0);
                  bb_reg <= b;
               else
                  aa_reg(31) <= b_neg(0);
                  bb_reg <= b_neg;
               end if;
               if a(31) = '0' then
                  upper_reg <= a;
               else
                  upper_reg <= a_neg;
               end if;
               aa_reg(30 downto 0) <= ZERO(30 downto 0);
               count_reg <= "100000";
               negate_reg <= a(31) xor b(31);
            when others =>

               if count_reg /= "000000" then
                  if mode_reg = MODE_MULT then
                     -- Multiplication
                     if bb_reg(0) = '1' then
                        upper_reg <= (sign_reg xor sum(32)) & sum(31 downto 1);
                        lower_reg <= sum(0) & lower_reg(31 downto 1);
                        sign2_reg <= sign2_reg or sign_reg;
                        sign_reg <= '0';
                        bb_reg <= '0' & bb_reg(31 downto 1);
                     -- The following six lines are optional for speedup
                     --elsif bb_reg(3 downto 0) = "0000" and sign2_reg = '0' and 
                     --      count_reg(5 downto 2) /= "0000" then
                     --   upper_reg <= "0000" & upper_reg(31 downto 4);
                     --   lower_reg <=  upper_reg(3 downto 0) & lower_reg(31 downto 4);
                     --   count := "100";
                     --   bb_reg <= "0000" & bb_reg(31 downto 4);
                     else
                        upper_reg <= sign2_reg & upper_reg(31 downto 1);
                        lower_reg <= upper_reg(0) & lower_reg(31 downto 1);
                        bb_reg <= '0' & bb_reg(31 downto 1);
                     end if;
                  else   
                     -- Division
                     if sum(32) = '0' and aa_reg /= ZERO and 
                           bb_reg(31 downto 1) = ZERO(31 downto 1) then
                        upper_reg <= sum(31 downto 0);
                        lower_reg(0) <= '1';
                     else
                        lower_reg(0) <= '0';
                     end if;
                     aa_reg <= bb_reg(1) & aa_reg(31 downto 1);
                     lower_reg(31 downto 1) <= lower_reg(30 downto 0);
                     bb_reg <= '0' & bb_reg(31 downto 1);
                  end if;
                  count_reg <= count_reg - count;
               end if; --count

         end case;
         
      end if;

   end process;
    
end; --architecture logic
