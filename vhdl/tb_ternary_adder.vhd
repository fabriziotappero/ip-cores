---------------------------------------------------------------------------------------------
-- Author:          Martin Kumm
-- Contact:         kumm@uni-kassel.de
-- License:         LGPL
-- Date:            04.04.2013
--
-- Description:
-- Testbench for testing a single ternary adder component
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all; -- for uniform, trunc functions

entity tb_ternary_adder is
  generic(
    input_word_size  : integer := 15;
    subtract_y       : boolean := false;
    subtract_z       : boolean := true;
    use_output_ff    : boolean := false
  );
end tb_ternary_adder;

architecture tb_ternary_adder_arch of tb_ternary_adder is

signal clk, rst : std_logic := '0';
signal x,y,z : std_logic_vector(input_word_size-1 downto 0) := (others => '0');
signal sum : std_logic_vector(input_word_size+1 downto 0) := (others => '0');

signal sum_ref,sum_dut: integer := 0;

begin
  dut: entity work.ternary_adder
    generic map (
      input_word_size  => input_word_size,
      subtract_y       => subtract_y,
      subtract_z       => subtract_z,
      use_output_ff    => use_output_ff
    )
    port map (
      clk_i => clk,
      rst_i => rst,
      x_i   => x,
      y_i   => y,
      z_i   => z,
      sum_o => sum
    );

  clk <= not clk after 5 ns;  -- 100 MHz
  rst <= '1', '0' after 5 ns;
  
  process
    variable seed1,seed2: positive;
    variable rand : real;
    variable x_int,y_int,z_int : integer;
  begin
      uniform(seed1, seed2, rand);
      x_int := integer(trunc(rand*real(2**(input_word_size-2)-1)));
      uniform(seed1, seed2, rand);
      y_int := integer(trunc(rand*real(2**(input_word_size-2)-1)));
      uniform(seed1, seed2, rand);
      z_int := integer(trunc(rand*real(2**(input_word_size-2)-1)));
      x <= std_logic_vector(to_signed(x_int, x'length)); -- rescale, quantize and convert
      y <= std_logic_vector(to_signed(y_int, y'length)); -- rescale, quantize and convert
      z <= std_logic_vector(to_signed(z_int, z'length)); -- rescale, quantize and convert
      wait until clk'event and clk='1'; 
  end process;

  process(clk,rst,x,y,z)
    variable y_sgn,z_sgn,sum_ref_unsync : integer;
  begin
    if subtract_y = true then
      y_sgn := -1*to_integer(signed(y));
    else
      y_sgn := to_integer(signed(y));
    end if;
    if subtract_z = true then
      z_sgn := -1*to_integer(signed(z));
    else
      z_sgn := to_integer(signed(z));
    end if;
    sum_ref_unsync := to_integer(signed(x)) + y_sgn + z_sgn;

    if use_output_ff = false then
      sum_ref <= sum_ref_unsync;
    else
      if clk'event and clk='1' then
        sum_ref <= sum_ref_unsync;
      end if;
    end if;

	end process;

  process(clk,rst,sum_ref)
  begin
  end process;

  sum_dut <= to_integer(signed(sum));
    
  process
    begin
      wait for 50 ns;
      loop
        wait until clk'event and clk='0';
        assert (sum_dut = sum_ref) report "Test failure" severity failure;
        wait until clk'event and clk='1'; 
      end loop;
  end process;
  
end architecture;