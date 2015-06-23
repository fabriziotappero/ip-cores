-------------------------------------------------------------------------------
--  File: mult_pyramid_mod.vhd                                               --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--   modified pyramid multiplication algorithm                               --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
--  Synthesis results for 0.35u library:                                     --
-- -----------------------------------------                                 --
-- |  operands  |   delay   | combinational |                                --
-- | dimension  |   (ns)    |  area (gates) |                                --
-- |------------|-----------|---------------|                                --
-- |    8x8     |    9.92   |       700     |                                --
-- |   16x16    |   17.70   |      2300     |                                --
-- |   32*32    |   33.94   |      8580     |                                --
-- |   64*64    |   69.78   |     33300     |                                --
-- -----------------------------------------                                 --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


function MULT_PYRAMID_MOD(MULTIPLICAND: STD_LOGIC_VECTOR; MULTIPLIER: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
variable RESULT: STD_LOGIC_VECTOR(MULTIPLICAND'length * 2 - 1 downto 0);  
variable HIGH_LEVEL_RESULT: STD_LOGIC_VECTOR(MULTIPLICAND'length * 2 - 5 downto 0);
variable NEW_MR_x_MD1, NEW_MD_x_MR1 : STD_LOGIC_VECTOR(MULTIPLICAND'length - 3 downto 0);
variable NEW_MR_x_MD10, NEW_MD_x_MR10 : STD_LOGIC_VECTOR(MULTIPLICAND'length - 1 downto 0);
variable SUM : STD_LOGIC_VECTOR(MULTIPLICAND'length downto 0);
variable NEW_MD, NEW_MR : STD_LOGIC_VECTOR(MULTIPLICAND'length - 3 downto 0);

variable TEMP1, TEMP2: STD_LOGIC_VECTOR(1 downto 0); 
variable TEMP3: STD_LOGIC_VECTOR(2 downto 0); 
variable TEMP4: STD_LOGIC_VECTOR(3 downto 0); 

begin
  NEW_MD := MULTIPLICAND(MULTIPLICAND'high downto 2);
  NEW_MR := MULTIPLIER(MULTIPLIER'high downto 2);

  if MULTIPLICAND'length = 4 then
    TEMP1 := (MULTIPLIER(3) and MULTIPLICAND(2)) & (MULTIPLIER(2) and MULTIPLICAND(2));
    TEMP2 := (MULTIPLIER(3) and MULTIPLICAND(3)) & (MULTIPLIER(2) and MULTIPLICAND(3));
    if TEMP1(1) = '1' then
       TEMP3 := ((MULTIPLICAND(3) and MULTIPLIER(3) and MULTIPLIER(2)) & (TEMP2 + 1));
    else
       TEMP3 := ('0' & TEMP2);
    end if;
    HIGH_LEVEL_RESULT := TEMP3 & TEMP1(0);
  else
    HIGH_LEVEL_RESULT := MULT_PYRAMID_MOD(NEW_MD, NEW_MR);
  end if;
  
  if MULTIPLICAND(1) = '1' then
    NEW_MR_x_MD1 := NEW_MR;
  else
    NEW_MR_x_MD1 := (others => '0');
  end if;
  if MULTIPLICAND(0) = '1' then
    NEW_MR_x_MD10 := (('0' & NEW_MR_x_MD1) + NEW_MR(NEW_MR'high downto 1)) & NEW_MR(0);
  else
    NEW_MR_x_MD10 := '0' & NEW_MR_x_MD1 & '0';
  end if;
  
  if MULTIPLIER(1) = '1' then
    NEW_MD_x_MR1 := NEW_MD;
  else
    NEW_MD_x_MR1 := (others => '0');
  end if;
  if MULTIPLIER(0) = '1' then
    NEW_MD_x_MR10 := (('0' & NEW_MD_x_MR1) + NEW_MD(NEW_MD'high downto 1)) & NEW_MD(0);
  else
    NEW_MD_x_MR10 := '0' & NEW_MD_x_MR1 & '0';
  end if;
  
  SUM := ('0' & NEW_MR_x_MD10) + NEW_MD_x_MR10;

  TEMP1 := (MULTIPLIER(1) and MULTIPLICAND(0)) & (MULTIPLIER(0) and MULTIPLICAND(0));
  TEMP2 := (MULTIPLIER(1) and MULTIPLICAND(1)) & (MULTIPLIER(0) and MULTIPLICAND(1));
  if TEMP1(1) = '1' then
     TEMP3 := ((MULTIPLICAND(1) and MULTIPLIER(1) and MULTIPLIER(0)) & (TEMP2 + 1));
  else
     TEMP3 := ('0' & TEMP2);
  end if;
  TEMP4 := TEMP3 & TEMP1(0);


  RESULT := (HIGH_LEVEL_RESULT & TEMP4(3 downto 2) + SUM) & TEMP4(1 downto 0);
  return RESULT;
  
end MULT_PYRAMID_MOD;
