--------------------------------------------------------------------------------
-- Project    : openFPU64 Constants
-------------------------------------------------------------------------------
-- File       : fpu_package.vhd
-- Author     : Peter Huewe  <peterhuewe@gmx.de>
-- Created    : 2010-04-19
-- Last update: 2010-04-19
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Some constants for openFPU64
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- License: gplv3, see licence.txt
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package fpu_package is

  constant ZEROS: unsigned (100 downto 0) := (others => '0');
  constant ONES: unsigned (100 downto 0) := (others => '1');
  constant ALL_ZEROS     : unsigned (10 downto 0) := (others => '0');
  constant ALL_ONES      : unsigned (10 downto 0) := (others => '1');
  constant ZERO_MANTISSA : unsigned (54 downto 0) := (others => '0');
  constant DOUBLE_BIAS   : unsigned (12 downto 0) := '0'&x"3ff";  -- 1023 - Bias for Exponent
  constant DOUBLE_BIAS_2COMPLEMENT  : unsigned (12 downto 0) := not(DOUBLE_BIAS)+1;  -- -1023 - Bias for Exponent
  
  constant SINGLE_BIAS   : unsigned (7 downto 0) := x"7f";  -- 127 - Bias for Exponent
  constant SINGLE_BIAS_2COMPLEMENT   : unsigned (7 downto 0) := not(x"7f"+1);  -- -127 - Bias for Exponent
  constant DOUBLE_PRECISION : std_logic := '0';
  constant SINGLE_PRECISION: std_logic := '1';

  constant addr_a_hi      : std_logic_vector(1 downto 0) := "00";  -- hi-word operand A    - writeonly
  constant addr_a_lo      : std_logic_vector(1 downto 0) := "01";  -- low-word operand A   - writeonly
  constant addr_b_hi      : std_logic_vector(1 downto 0) := "10";  -- hi-word operand B    - writeonly
  constant addr_b_lo      : std_logic_vector(1 downto 0) := "11";  -- low-word operand B   - writeonly
  constant addr_result_hi : std_logic_vector(1 downto 0) := "00";  -- hi-word result       - readonly
  constant addr_result_lo : std_logic_vector(1 downto 0) := "01";  -- low-word result      - readonly
  constant addr_flags     : std_logic_vector(1 downto 0) := "11";  -- exception flags      - readonly

  constant mode_add  : std_logic_vector (2 downto 0) := "000";  -- Addition Mode
  constant mode_sub  : std_logic_vector (2 downto 0) := "001";  -- Subtraction Mode
  constant mode_mul  : std_logic_vector (2 downto 0) := "010";  -- Multiply Mode
  constant mode_div  : std_logic_vector (2 downto 0) := "011";  -- Division Mode
  constant mode_test : std_logic_vector (2 downto 0) := "111";  -- Testing Mode  

  constant DEBUG_MODE : std_logic :='0';
end fpu_package;

