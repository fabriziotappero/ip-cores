-------------------------------------------------------------------------------
--  File: mult_unit.vhd                                                      --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
-- function : entity and architecture for multiplication algorithms testing  -- 
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use definitions.all;

entity MULT_UNIT is
	port (
		CLK: in std_logic;
		A: in STD_LOGIC_VECTOR (data_width -1  downto 0);
		B: in STD_LOGIC_VECTOR (data_width - 1 downto 0);
		MUL_OUT: out STD_LOGIC_VECTOR (data_width * 2 -1 downto 0)
		);
end MULT_UNIT;



architecture RTL of MULT_UNIT is


-- insert multiplication function text from file here...
function MULT_SCHOOL(MULTIPLICAND: STD_LOGIC_VECTOR; MULTIPLIER: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
variable RESULT: STD_LOGIC_VECTOR(MULTIPLICAND'length + MULTIPLIER'length - 1 downto 0);    
variable HIGH_LEVEL_RESULT : STD_LOGIC_VECTOR(MULTIPLICAND'length + MULTIPLIER'length - 2 downto 0);
variable NEW_MR : STD_LOGIC_VECTOR(MULTIPLIER'length - 2 downto 0);

begin
  NEW_MR := MULTIPLIER(MULTIPLIER'high downto 1);

  if MULTIPLIER'length = 2 then
    if MULTIPLIER(1) = '1' and MULTIPLIER(0) = '1' then
      RESULT := ('0' & MULTIPLICAND + MULTIPLICAND(MULTIPLICAND'high downto 1)) & MULTIPLICAND(0);
    elsif MULTIPLIER(1) = '1' then
      RESULT := '0' & MULTIPLICAND & '0';
    elsif MULTIPLIER(0) = '1' then
      RESULT := "00" & MULTIPLICAND;
    else 
      RESULT := (others => '0');
    end if;
  else
    HIGH_LEVEL_RESULT := MULT_SCHOOL(MULTIPLICAND, NEW_MR);
    if MULTIPLIER(0) = '1' then
      RESULT := (HIGH_LEVEL_RESULT(HIGH_LEVEL_RESULT'high downto 0) + MULTIPLICAND(MULTIPLICAND'high downto 1)) & MULTIPLICAND(0);
    else
      RESULT := HIGH_LEVEL_RESULT & '0';
    end if;
  end if;
  
  return RESULT;
  
end MULT_SCHOOL;


signal A_REG, B_REG: std_logic_vector(data_width -1  downto 0) := (others => '0');
signal R_REG: std_logic_vector(data_width * 2 -1  downto 0) := (others => '0');

begin

TEST: process(CLK)
begin
if CLK'event and CLK = '1' then 
   A_REG <= A;
   B_REG <= B;

   R_REG <= MULT_SCHOOL(A_REG, B_REG); -- choise of multiplication algorithms
--   R_REG <= MULT_PYRAMID(A_REG, B_REG);
--   R_REG <= MULT_PYRAMID_MOD(A_REG, B_REG);
--   R_REG <= MULT_HIER(A_REG, B_REG);
--   R_REG <= MULT_HIER_MOD(A_REG, B_REG);
end if;
end process;


MUL_OUT <= R_REG;


end RTL;
