-------------------------------------------------------------------------------
-- Project    : openFPU64 Multiplier Component
-------------------------------------------------------------------------------
-- File       : fpu_mul.vhd
-- Author     : Peter Huewe  <peterhuewe@gmx.de>
-- Created    : 2010-04-19
-- Last update: 2010-04-19
-- Standard   : VHDL'87
-- Status     : ALPHA! - Bugs exists!
-------------------------------------------------------------------------------
-- Description: double precision floating point multiplier component
--                     for openFPU64, includes rounding and normalization
--              Uses only one embedded 18x18 multiplier
-- Note       : Last few bits are wrong, perhaps related to stickybit /rounding
--                      issues
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- License: gplv3, see licence.txt
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.helpers.all;
use work.fpu_package.all;
-------------------------------------------------------------------------------

entity fpu_mul is
  port (
    clk, reset_n           : in  std_logic;  -- reset = standard active low
    cs                     : in  std_logic;  --  mode: 0 = add , 1= sub
    sign_a, sign_b         : in  std_logic;  -- sign bits
    exponent_a, exponent_b : in  std_logic_vector (11 downto 0);  -- exponents of the operands
    mantissa_a, mantissa_b : in  std_logic_vector (57 downto 0);  -- mantissa of operands
    --enable       : in  std_logic;       -- enable this submodule
    sign_res               : out std_logic;
    exponent_res           : out std_logic_vector(11 downto 0);
    mantissa_res           : out std_logic_vector (57 downto 0);
    rounding_needed        : out std_logic;
    -- result                 : out std_logic_vector (63 downto 0);
    -- ready        : out std_logic;       -- entspricht waitrequest_n
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
  --signal mul_a, mul_b         : std_logic_vector(53 downto 0);  -- inputs for multiplier
--signal mul_result: std_logic_vector(57 downto 0);  -- result of multiplier
  signal add_result, add_op_a : unsigned (39 downto 0);
  signal add_op_b             : unsigned (35 downto 0);
  signal mul_result           : unsigned(35 downto 0);
  signal mul_op_a, mul_op_b   : unsigned(17 downto 0);
  type t_state is (s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s12a, s12b,s12c,s12d);  -- possible states
  signal state                : t_state;  -- current state

  signal exponent_out : std_logic_vector(11 downto 0);
  signal tmp_result   : std_logic_vector (57 downto 0);


  alias a : std_logic_vector(17 downto 0) is mantissa_a(56 downto 39);
  alias b : std_logic_vector(17 downto 0) is mantissa_a(38 downto 21);
  alias c : std_logic_vector(17 downto 0) is mantissa_a(20 downto 3);
  alias d : std_logic_vector(17 downto 0) is mantissa_b(56 downto 39);
  alias e : std_logic_vector(17 downto 0) is mantissa_b(38 downto 21);
  alias f : std_logic_vector(17 downto 0) is mantissa_b(20 downto 3);


  signal a_is_normal, b_is_normal : std_logic;
  signal sticky_bit               : std_logic;
  signal sticky_bit_enabled       : std_logic;
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
  mul_result  <= unsigned(mul_op_a) * unsigned(mul_op_b);
  a_is_normal <= '0'                when unsigned(exponent_a(10 downto 0)) = ALL_ZEROS else '1';
  b_is_normal <= '0'                when unsigned(exponent_b(10 downto 0)) = ALL_ZEROS else '1';
  sticky_bit  <= sticky_bit_enabled when add_result(18 downto 0) /= ZEROS(18 downto 0) else '0';

  state_trans : process (clk, reset_n, cs)
    variable tmp : unsigned(57 downto 0);
  begin  -- process state_trans
    rounding_needed <= '1';
    if reset_n = '0' or cs = '0' then
      state              <= s1;
      sign_res           <= '0';
      valid              <= '0';
      sticky_bit_enabled <= '0';
      --     result       <= (others => '0');
      exponent_res       <= (others => '0');
      mantissa_res       <= (others => '0');
      -- tmp          := (others => '0');
      tmp_result         <= (others => '0');
    elsif rising_edge(clk) then
      sign_res           <= sign_a xor sign_b;
      valid              <= '0';
      --    result       <= (others => '0');
      exponent_res       <= exponent_out;
      mantissa_res       <= (others => '0');
      mantissa_res       <= tmp_result;
      tmp_result         <= tmp_result;
      add_op_a           <= (others => '0');
      add_op_b           <= (others => '0');
      mul_op_a           <= (others => '0');
      mul_op_b           <= (others => '0');
      sticky_bit_enabled <= sticky_bit_enabled;

      case state is
        when s1 =>
          add_op_a              <= (others => '0');
          add_op_b              <= (others => '0');
          add_op_a(10 downto 0) <= unsigned(exponent_a(10 downto 0));
          add_op_b(10 downto 0) <= unsigned(exponent_b(10 downto 0));

          mul_op_a <= unsigned(c);
          mul_op_b <= unsigned(f);
          state    <= s2;
        when s2 =>
          --assert false report "Test" & to_string(std_logic_vector(add_result(13 downto 0))) severity warning;
          add_op_a (11 downto 0)  <= add_result(11 downto 0);
          add_op_b (11 downto 0)  <= DOUBLE_BIAS_2COMPLEMENT(11 downto 0);
          tmp_result(35 downto 0) <= std_logic_vector(mul_result);

          mul_op_a <= unsigned(b);
          mul_op_b <= unsigned(f);


          state <= s3;
        when s3 =>
          --  assert false report "Test" & to_string(std_logic_vector(add_result(13 downto 0))) severity warning;
          --  assert false report "ea" & to_string(exponent_a) & "eb" & to_string(exponent_b) &"xx"& to_string(std_logic_vector(DOUBLE_BIAS_2COMPLEMENT)) severity warning;
          -- if either the result is a subnormal/zero or both operands are zero
          -- set exponent to zero
          if (add_result(12) = '1' and (a_is_normal = '0' or b_is_normal = '0'))
            or (a_is_normal = '0' and b_is_normal = '0')
          then
            exponent_out <= (others => '0');
          else
            exponent_out <= std_logic_vector(add_result(11 downto 0));
          end if;
          sticky_bit_enabled <= '1';    -- since we start adding up values,
                                        -- sticky bit has to be calculated
          assert sticky_bit = '0' report "sticky3"&to_string(std_logic_vector(add_result))severity note;

          if unsigned(tmp_result(18 downto 0)) = (ZEROS(18 downto 0))then
            add_op_a <= unsigned(tmp_result(57 downto 19))&'0';

          else
            add_op_a <= unsigned(tmp_result(57 downto 18));
          end if;

          add_op_b <= mul_result;

          mul_op_a <= unsigned(c);
          mul_op_b <= unsigned(e);

          state <= s4;
        when s4 =>
          assert sticky_bit = '0' report "sticky4"&to_string(std_logic_vector(add_result))severity note;
          add_op_a <= add_result;
          add_op_b <= mul_result;

          mul_op_a <= unsigned(a);
          mul_op_b <= unsigned(f);

          state <= s5;
        when s5 =>
          assert sticky_bit = '0' report "sticky5"&to_string(std_logic_vector(add_result))severity note;
          add_op_a <= "00"&x"0000"& add_result(39 downto 19)&sticky_bit;
          add_op_b <= mul_result;

          mul_op_a <= unsigned(b);
          mul_op_b <= unsigned(e);

          state <= s6;
        when s6 =>
          assert sticky_bit = '0' report "sticky6"&to_string(std_logic_vector(add_result))severity note;
          add_op_a <= add_result;
          add_op_b <= mul_result;

          mul_op_a <= unsigned(c);
          mul_op_b <= unsigned(d);



          state <= s7;
        when s7 =>
          assert sticky_bit = '0' report "sticky7"&to_string(std_logic_vector(add_result))severity note;
          add_op_a <= add_result;
          add_op_b <= mul_result;
          mul_op_a <= unsigned(a);
          mul_op_b <= unsigned(e);

          state <= s8;
        when s8 =>
          assert sticky_bit = '0' report "sticky8"&to_string(std_logic_vector(add_result))severity note;
          add_op_a <= "00"&x"0000"& add_result(39 downto 18);--&sticky_bit;
          add_op_b <= mul_result;

          mul_op_a <= unsigned(b);
          mul_op_b <= unsigned(d);


          state <= s9;
        when s9 =>
          assert sticky_bit = '0' report "sticky9"&to_string(std_logic_vector(add_result))severity note;
          add_op_a                <= add_result;
          add_op_b                <= mul_result;
          mul_op_a                <= unsigned(a);
          mul_op_b                <= unsigned(d);
          tmp_result              <= (others => '0');
          assert false report "bla" & to_string(std_logic_vector(add_result)) severity warning;
          assert false report "bla" & to_string(std_logic_vector(add_result(39 downto 30))) severity warning;
          tmp_result (4 downto 0) <= std_logic_vector(add_result(39 downto 36))&sticky_bit;  --
          -- driving me crazy!

          state <= s10;
        when s10 =>
          assert sticky_bit = '0' report "sticky10"&to_string(std_logic_vector(add_result))severity note;
          assert false report "bla1" & to_string(std_logic_vector(add_result)) severity warning;
          add_op_a <= "00"&x"0000"& add_result(39 downto 18);
          add_op_b <= mul_result;

          tmp_result(22 downto 5) <= std_logic_vector(add_result(17 downto 0));


          state <= s11;
        when s11 =>
          assert false report "bla2" & to_string(std_logic_vector(add_result)) severity warning;
          tmp_result (57 downto 23) <= std_logic_vector(add_result(34 downto 0));
          state                     <= s12b;
          if add_result (33) = '1' then
            state <= s12a;
          end if;
          --     VALID                     <= '1';

        when s12a=>
          assert false report "shift"&to_string(tmp_result) severity note;
          assert false report "ungleich" severity note;
          tmp_result(57 downto 1) <= '0'&tmp_result(57 downto 2);
          tmp_result(0)           <= tmp_result(1) or tmp_result(0);
          exponent_out            <= std_logic_vector(unsigned(exponent_out)+"1");
          state                   <= s12b;

        when s12b=>
          assert false report "vorrund"&to_string(tmp_result) severity note;
          case tmp_result(3 downto 0) is
            when "0101" => tmp_result(3) <= '1';
            when "0110" => tmp_result(3) <= '1';
            when "0111" => tmp_result(3) <= '1';

            when "1100" => tmp_result(57 downto 3) <= std_logic_vector(unsigned(tmp_result(57 downto 3))+"1");
            when "1101" => tmp_result(57 downto 3) <= std_logic_vector(unsigned(tmp_result(57 downto 3))+"1");
            when "1110" => tmp_result(57 downto 3) <= std_logic_vector(unsigned(tmp_result(57 downto 3))+"1");
            when "1111" => tmp_result(57 downto 3) <= std_logic_vector(unsigned(tmp_result (57 downto 3))+"1");


            when others => null;        -- others remain unchanged
          end case; 
		 
		  state <= s12c;
        when s12c=>
                  state <= s12;
                  if tmp_result(56) ='1' then
                    state <= s12d;
                    
                  end if;

        when s12d=>
          assert false report "ungleich" severity note;
          tmp_result(57 downto 1) <= '0'&tmp_result(57 downto 2);
          tmp_result(0)           <= tmp_result(1) or tmp_result(0);
          exponent_out            <= std_logic_vector(unsigned(exponent_out)+"1");
          state                   <= s12;


        when s12 =>
          assert false report "ttt"&to_string(tmp_result) severity note;
          state <= s12;
          valid <= '1';

        when others => null;
      end case;
    end if;
    
  end process state_trans;
  
end rtl;

-------------------------------------------------------------------------------
