-------------------------------------------------------------------------------
--  File: mult_pyramid.vhd                                                   --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--   pyramid multiplication algorithm                                        --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
--  Synthesis results for 0.35u library:                                     --
-- -----------------------------------------                                 --
-- |  operands  |   delay   | combinational |                                --
-- | dimension  |   (ns)    |  area (gates) |                                --
-- |------------|-----------|---------------|                                --
-- |    8x8     |    9.80   |      890      |                                --
-- |   16x16    |   19.85   |      2815     |                                --
-- |   32*32    |   37.34   |     10550     |                                --
-- -----------------------------------------                                 --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


   
function MULT_PYRAMID(MULTIPLICAND: STD_LOGIC_VECTOR; MULTIPLIER: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
variable RESULT: STD_LOGIC_VECTOR(MULTIPLICAND'length * 2 - 1 downto 0);  
variable HIGH_LEVEL_RESULT: STD_LOGIC_VECTOR(MULTIPLICAND'length * 2 - 3 downto 0);
variable FIRST_ADDER, SECOND_ADDER : STD_LOGIC_VECTOR(MULTIPLICAND'length - 2 downto 0);
variable SUM : STD_LOGIC_VECTOR(MULTIPLICAND'length - 1 downto 0);
variable NEW_MD, NEW_MR : STD_LOGIC_VECTOR(MULTIPLICAND'length - 2 downto 0);

begin
  NEW_MD := MULTIPLICAND(MULTIPLICAND'high downto 1);
  NEW_MR := MULTIPLIER(MULTIPLIER'high downto 1);

  if MULTIPLICAND'length = 2 then
    HIGH_LEVEL_RESULT := '0' & (MULTIPLICAND(1) and MULTIPLIER(1));
  else
    HIGH_LEVEL_RESULT := MULT_PYRAMID(NEW_MD, NEW_MR);
  end if;
  
  if MULTIPLICAND(0) = '1' then
    FIRST_ADDER := NEW_MR;
  else
    FIRST_ADDER := (others => '0');
  end if;
  
  if MULTIPLIER(0) = '1' then
    SECOND_ADDER := NEW_MD;
  else
    SECOND_ADDER := (others => '0');
  end if;
  
  SUM := '0' & FIRST_ADDER + SECOND_ADDER;

  RESULT := (HIGH_LEVEL_RESULT + SUM(SUM'high downto 1)) & SUM(0) & (MULTIPLICAND(0) and MULTIPLIER(0));
  return RESULT;
  
end MULT_PYRAMID;