---------------------------------------------------------------------
-- TITLE: Shifter Unit
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
--         Matthias Gruenewald
-- DATE CREATED: 2/2/01
-- FILENAME: shifter.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the 32-bit shifter unit.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.mlite_pack.all;

entity shifter is
   generic(shifter_type : string := "DEFAULT");
   port(value        : in  std_logic_vector(31 downto 0);
        shift_amount : in  std_logic_vector(4 downto 0);
        shift_func   : in  shift_function_type;
        c_shift      : out std_logic_vector(31 downto 0));
end; --entity shifter

architecture logic of shifter is
--   type shift_function_type is (
--      shift_nothing, shift_left_unsigned, 
--      shift_right_signed, shift_right_unsigned);

signal shift1L, shift2L, shift4L, shift8L, shift16L : std_logic_vector(31 downto 0);
signal shift1R, shift2R, shift4R, shift8R, shift16R : std_logic_vector(31 downto 0);
signal fills : std_logic_vector(31 downto 16);

begin
   fills <= "1111111111111111" when shift_func = SHIFT_RIGHT_SIGNED 
	                            and value(31) = '1' 
										 else "0000000000000000";
   shift1L  <= value(30 downto 0) & '0' when shift_amount(0) = '1' else value;
   shift2L  <= shift1L(29 downto 0) & "00" when shift_amount(1) = '1' else shift1L;
   shift4L  <= shift2L(27 downto 0) & "0000" when shift_amount(2) = '1' else shift2L;
   shift8L  <= shift4L(23 downto 0) & "00000000" when shift_amount(3) = '1' else shift4L;
   shift16L <= shift8L(15 downto 0) & ZERO(15 downto 0) when shift_amount(4) = '1' else shift8L;

   shift1R  <= fills(31) & value(31 downto 1) when shift_amount(0) = '1' else value;
   shift2R  <= fills(31 downto 30) & shift1R(31 downto 2) when shift_amount(1) = '1' else shift1R;
   shift4R  <= fills(31 downto 28) & shift2R(31 downto 4) when shift_amount(2) = '1' else shift2R;
   shift8R  <= fills(31 downto 24) & shift4R(31 downto 8)  when shift_amount(3) = '1' else shift4R;
   shift16R <= fills(31 downto 16) & shift8R(31 downto 16) when shift_amount(4) = '1' else shift8R;

GENERIC_SHIFTER: if shifter_type = "DEFAULT" generate
   c_shift <= shift16L when shift_func = SHIFT_LEFT_UNSIGNED else 
              shift16R when shift_func = SHIFT_RIGHT_UNSIGNED or 
				                shift_func = SHIFT_RIGHT_SIGNED else
              ZERO;
end generate;
                 
AREA_OPTIMIZED_SHIFTER: if shifter_type /= "DEFAULT" generate
   c_shift <= shift16L when shift_func = SHIFT_LEFT_UNSIGNED else (others => 'Z');
   c_shift <= shift16R when shift_func = SHIFT_RIGHT_UNSIGNED or 
                            shift_func = SHIFT_RIGHT_SIGNED else (others => 'Z');
   c_shift <= ZERO     when shift_func = SHIFT_NOTHING else (others => 'Z');
end generate;

end; --architecture logic

