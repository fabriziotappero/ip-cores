-------------------------------------------------------------------------------
--  File: mult_hier.vhd                                                      --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--   hirerachical multiplication algorithm                                   --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
--  Synthesis results for 0.35u library:                                     --
-- -----------------------------------------                                 --
-- |  operands  |   delay   | combinational |                                --
-- | dimension  |   (ns)    |  area (gates) |                                --
-- |------------|-----------|---------------|                                --
-- |    8x8     |    9.56   |       760     |                                --
-- |   16x16    |   15.15   |      2505     |                                --
-- |   32*32    |   23.12   |      9355     |                                --
-- |   64*64    |   35.34   |     33805     |                                --
-- -----------------------------------------                                 --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------

 

function MULT_HIER(MULTIPLICAND: STD_LOGIC_VECTOR; MULTIPLIER: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
variable MUL_RESULT_1, MUL_RESULT_2, MUL_RESULT_3, MUL_RESULT_4: STD_LOGIC_VECTOR(MULTIPLICAND'length - 1 downto 0); 
variable RESULT: STD_LOGIC_VECTOR(MULTIPLICAND'length * 2 - 1 downto 0); 
variable HIGH_HALF_OF_MCD, LOW_HALF_OF_MCD, HIGH_HALF_OF_MER, LOW_HALF_OF_MER: STD_LOGIC_VECTOR((MULTIPLICAND'length +1)/2 - 1 downto 0); 
variable MUL_RESULT_1_4: STD_LOGIC_VECTOR((MULTIPLICAND'length+1)/2*3 - 1 downto 0); 

variable TEMP1, TEMP2: STD_LOGIC_VECTOR(1 downto 0); 
variable TEMP3: STD_LOGIC_VECTOR(2 downto 0); 

begin
--   if MULTIPLICAND'length = 1 then --version of first 'IF' edge for better understanding
--      return ('0' & (MULTIPLICAND and MULTIPLIER));

  if MULTIPLICAND'length = 2 then
      TEMP1 := (MULTIPLIER(1) and MULTIPLICAND(0)) & (MULTIPLIER(0) and MULTIPLICAND(0));
      TEMP2 := (MULTIPLIER(1) and MULTIPLICAND(1)) & (MULTIPLIER(0) and MULTIPLICAND(1));
      if TEMP1(1) = '1' then
         TEMP3 := ((MULTIPLICAND(1) and MULTIPLIER(1) and MULTIPLIER(0)) & (TEMP2 + 1));
      else
         TEMP3 := ('0' & TEMP2);
      end if;
      return TEMP3 & TEMP1(0);
   else
      HIGH_HALF_OF_MCD := MULTIPLICAND(MULTIPLICAND'high downto (MULTIPLICAND'high + 1)/2);
      LOW_HALF_OF_MCD := MULTIPLICAND((MULTIPLICAND'high+1)/2 - 1 downto 0);
      HIGH_HALF_OF_MER := MULTIPLIER(MULTIPLIER'high downto (MULTIPLIER'high + 1)/2);
      LOW_HALF_OF_MER := MULTIPLIER((MULTIPLIER'high+1)/2 - 1 downto 0);
      
      MUL_RESULT_1 := MULT_HIER(LOW_HALF_OF_MCD, LOW_HALF_OF_MER);
      MUL_RESULT_2 := MULT_HIER(LOW_HALF_OF_MCD, HIGH_HALF_OF_MER);
      MUL_RESULT_3 := MULT_HIER(HIGH_HALF_OF_MCD, LOW_HALF_OF_MER);
      MUL_RESULT_4 := MULT_HIER(HIGH_HALF_OF_MCD, HIGH_HALF_OF_MER);

      MUL_RESULT_1_4 := MUL_RESULT_4 & MUL_RESULT_1(MULTIPLICAND'high downto (MULTIPLICAND'high+1)/2);
      RESULT := (MUL_RESULT_1_4 + (('0' & MUL_RESULT_2) + MUL_RESULT_3)) & MUL_RESULT_1((MULTIPLICAND'high+1)/2-1 downto 0);

      return(RESULT);
   end if;    
end MULT_HIER;
