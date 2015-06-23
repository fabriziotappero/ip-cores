---------------------------------------------------------------------------------------------
-- Author:          Martin Kumm
-- Contact:         kumm@uni-kassel.de
-- License:         LGPL
-- Date:            03.04.2013
-- Compatibility:   Altera Arria I,II,V and Stratix II-V FPGAs
--
-- Description:
-- Implementation of a ternary adder including subtraction of up to two inputs.
-- The output coresponds to sum_o = x_i + y_i + z_i, where the inputs have a word size of 
-- 'input_word_size' while the output has a word size of input_word_size+2.
--
-- Flipflops at the outputs can be activated by setting 'use_output_ff' to true.
-- Signed operation is activated by using the 'is_signed' generic.
-- The inputs y_i and z_i can be negated by setting 'subtract_y' or 'subtract_z'
-- to realize sum_o = x_i +/- y_i +/- z_i. The negation requires no extra resources.
---------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ternary_adder is
  generic(
    input_word_size  : integer := 10;
    subtract_y       : boolean := false;
    subtract_z       : boolean := false;
    use_output_ff    : boolean := true
  );
  port(
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    x_i   : in  std_logic_vector((input_word_size - 1) downto 0);
    y_i   : in  std_logic_vector((input_word_size - 1) downto 0);
    z_i   : in  std_logic_vector((input_word_size - 1) downto 0);
    sum_o : out std_logic_vector((input_word_size + 1) downto 0)
  );
end entity;


architecture behavior of ternary_adder is

  signal sum : std_logic_vector(input_word_size + 1 downto 0); 
  signal sum_tmp : std_logic_vector(input_word_size+3 downto 0); 
  signal x_i_ext : std_logic_vector(input_word_size+1 downto 0); 
  signal y_i_ext : std_logic_vector(input_word_size+1 downto 0); 
  signal z_i_ext : std_logic_vector(input_word_size+1 downto 0); 

begin

	add_sub_case1_gen: if subtract_y = false and subtract_z = false generate
    sum <= std_logic_vector(resize(signed(x_i),input_word_size+2) + resize(signed(y_i),input_word_size+2) + resize(signed(z_i),input_word_size+2));
  end generate;
  
	add_sub_case2_gen: if subtract_y = false and subtract_z = true generate
    x_i_ext <= x_i & "00";
    y_i_ext <= y_i & "10";
    z_i_ext <= (not z_i) & "10";
    sum_tmp <= std_logic_vector(resize(signed(x_i_ext),input_word_size+4) + resize(signed(y_i_ext),input_word_size+4) + resize(signed(z_i_ext),input_word_size+4));
    sum <= sum_tmp(input_word_size+3 downto 2);
  end generate;
  
	add_sub_case3_gen: if subtract_y = true and subtract_z = false generate
    x_i_ext <= x_i & "00";
    y_i_ext <= (not y_i) & "10";
    z_i_ext <= z_i & "10";
    sum_tmp <= std_logic_vector(resize(signed(x_i_ext),input_word_size+4) + resize(signed(y_i_ext),input_word_size+4) + resize(signed(z_i_ext),input_word_size+4));
    sum <= sum_tmp(input_word_size+3 downto 2);
  end generate;
  
	add_sub_case4_gen: if subtract_y = true and subtract_z = true generate
    x_i_ext <= x_i & "11";
    y_i_ext <= (not y_i) & "11";
    z_i_ext <= (not z_i) & "11";
    sum_tmp <= std_logic_vector(resize(signed(x_i_ext),input_word_size+4) + resize(signed(y_i_ext),input_word_size+4) + resize(signed(z_i_ext),input_word_size+4));
    sum <= sum_tmp(input_word_size+3 downto 2);
  end generate;
  
	use_output_ff_gen: if use_output_ff = true generate
	  process(clk_i,rst_i)
	  begin
	    if rst_i = '1' then
		    sum_o <= (others => '0');
	    elsif clk_i'event and clk_i='1' then
		    sum_o <= sum;
		  end if;
		end process;
	end generate;

	dont_use_output_ff_gen: if use_output_ff = false generate
		sum_o <= sum;
	end generate;
  
    
end architecture;
