-------------------------------------------------------------------------------
--  File: mult_hier_mod.vhd                                                  --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--  modified hirerachical multiplication algorithm                           --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
--  Synthesis results for 0.35u library:                                     --
-- -----------------------------------------                                 --
-- |  operands  |   delay   | combinational |                                --
-- | dimension  |   (ns)    |  area (gates) |                                --
-- |------------|-----------|---------------|                                --
-- |    8x8     |   14.28   |      1015     |                                --
-- |   16x16    |   21.76   |      3585     |                                --
-- |   32*32    |   33.85   |     11240     |                                --
-- |   64*64    |   56.48   |     30368     |                                --
-- -----------------------------------------                                 --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------



function MULT_HIER_MOD(MUTIPLICAND: STD_LOGIC_VECTOR; MUTIPLIER: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
variable MUL_RESULT_1, MUL_RESULT_2: STD_LOGIC_VECTOR(MUTIPLICAND'length - 1 downto 0);
variable RESULT: STD_LOGIC_VECTOR(MUTIPLICAND'length * 2 - 1 downto 0); 
variable HIGH_HALF_OF_MCD, LOW_HALF_OF_MCD, HIGH_HALF_OF_MER, LOW_HALF_OF_MER: STD_LOGIC_VECTOR((MUTIPLICAND'length +1)/2 - 1 downto 0);
variable MUL_SUM: STD_LOGIC_VECTOR(MUTIPLICAND'length - 1 downto 0);
variable SUM_1_2: STD_LOGIC_VECTOR((MUTIPLICAND'length+1)/2*3 - 1 downto 0);
variable SUM_HL_MD, SUM_HL_MER: STD_LOGIC_VECTOR((MUTIPLICAND'length +1)/2 downto 0);
variable ADDITION_1, ADDITION_2: STD_LOGIC_VECTOR((MUTIPLICAND'length +1)/2 - 1 downto 0);
variable SUM_ADDITIONS: STD_LOGIC_VECTOR((MUTIPLICAND'length +1)/2 + 1 downto 0);
variable SUM_TEMP: STD_LOGIC_VECTOR(MUTIPLICAND'length + 1 downto 0);
variable SUM_FULL: STD_LOGIC_VECTOR(MUTIPLICAND'length + 1  downto 0);
variable SUM_CORRECTED: STD_LOGIC_VECTOR(MUTIPLICAND'length + 1  downto 0);
variable SUM_REAL: STD_LOGIC_VECTOR(MUTIPLICAND'length  downto 0);
variable ROUND_SUM_HL_MD, ROUND_SUM_HL_MER: STD_LOGIC_VECTOR((MUTIPLICAND'length +1)/2-1 downto 0);

variable TEMP1, TEMP2: STD_LOGIC_VECTOR(1 downto 0); 
variable TEMP3: STD_LOGIC_VECTOR(2 downto 0); 

begin
--   if MUTIPLICAND'length = 1 then 
--      return ('0' & (MUTIPLICAND and MUTIPLIER));
   if MUTIPLICAND'length = 2 then
      TEMP1 := (MUTIPLIER(1) and MUTIPLICAND(0)) & (MUTIPLIER(0) and MUTIPLICAND(0));
      TEMP2 := (MUTIPLIER(1) and MUTIPLICAND(1)) & (MUTIPLIER(0) and MUTIPLICAND(1));
      if TEMP1(1) = '1' then
         TEMP3 := ((MUTIPLICAND(1) and MUTIPLIER(1) and MUTIPLIER(0)) & (TEMP2 + 1));
      else
         TEMP3 := ('0' & TEMP2);
      end if;
      return TEMP3 & TEMP1(0);
   else
      HIGH_HALF_OF_MCD := MUTIPLICAND(MUTIPLICAND'high downto (MUTIPLICAND'high + 1)/2);
      LOW_HALF_OF_MCD := MUTIPLICAND((MUTIPLICAND'high+1)/2 - 1 downto 0);
      HIGH_HALF_OF_MER := MUTIPLIER(MUTIPLIER'high downto (MUTIPLIER'high + 1)/2);
      LOW_HALF_OF_MER := MUTIPLIER((MUTIPLIER'high+1)/2 - 1 downto 0);
      
      MUL_RESULT_1 := MULT_HIER_MOD(LOW_HALF_OF_MCD, LOW_HALF_OF_MER);
      MUL_RESULT_2 := MULT_HIER_MOD(HIGH_HALF_OF_MCD, HIGH_HALF_OF_MER);

      SUM_1_2 := MUL_RESULT_2 & MUL_RESULT_1(MUTIPLICAND'high downto (MUTIPLICAND'high+1)/2);

      SUM_HL_MD := ('0' & HIGH_HALF_OF_MCD) + LOW_HALF_OF_MCD;
      SUM_HL_MER := ('0' & HIGH_HALF_OF_MER) + LOW_HALF_OF_MER;
      ROUND_SUM_HL_MD := SUM_HL_MD(SUM_HL_MD'high downto 1);
      ROUND_SUM_HL_MER := SUM_HL_MER(SUM_HL_MER'high downto 1);
      MUL_SUM := MULT_HIER_MOD(ROUND_SUM_HL_MD, ROUND_SUM_HL_MER);
      SUM_TEMP := MUL_SUM & '0' & (SUM_HL_MD(0) and SUM_HL_MER(0));
      
      if SUM_HL_MD(0) = '1' then
         ADDITION_1 := ROUND_SUM_HL_MER;
      else
         ADDITION_1 := (others => '0');
      end if;
      if SUM_HL_MER(0) = '1' then
         ADDITION_2 := ROUND_SUM_HL_MD;
      else
         ADDITION_2 := (others => '0');
      end if;
      
      SUM_ADDITIONS := (('0' & ADDITION_1) + ADDITION_2) & '0'; 
      
      SUM_FULL := (SUM_ADDITIONS(SUM_ADDITIONS'high downto 2) + SUM_TEMP(SUM_TEMP'high downto 2)) &  SUM_ADDITIONS(1) & SUM_TEMP(0);
      SUM_CORRECTED := SUM_FULL - MUL_RESULT_2 - MUL_RESULT_1;
      SUM_REAL := SUM_CORRECTED(SUM_REAL'high downto 0);
      
      RESULT := ((SUM_1_2 + SUM_REAL) & MUL_RESULT_1((MUTIPLICAND'high+1)/2-1 downto 0));
      return(RESULT);
   end if;    
end MULT_HIER_MOD;