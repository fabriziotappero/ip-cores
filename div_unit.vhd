-------------------------------------------------------------------------------
--  File: div_unit.vhd                                                       --
--                                                                           --
--  Copyright (C) Deversys, 2004                                             --
--                                                                           --
--  one-clock division algorithm                                             --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--          e-mails: vladvas@deversys.com; vladvas@verilog.ru;               --
--                                                                           --
--  Synthesis results for 0.35u library:                                     --
-- -----------------------------------------                                 --
-- |  operands  |   delay   | combinational |                                --
-- | dimension  |   (ns)    |  area (gates) |                                --
-- |------------|-----------|---------------|                                --
-- |   32/16    |   63.12   |      4,200    |                                --
-- -----------------------------------------                                 --
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

 
entity DIV_UNIT is
	port (
		CLK: in std_logic;
		DIVIDEND: in STD_LOGIC_VECTOR (data_width*2 - 1 downto 0);
		DIVISOR: in STD_LOGIC_VECTOR (data_width - 1 downto 0);
		DIV_RESULT: out STD_LOGIC_VECTOR (data_width*2 downto 0)
	);
end DIV_UNIT;

architecture RTL of DIV_UNIT is


function division(DIVIDEND: STD_LOGIC_VECTOR; 
                  DIVISOR: STD_LOGIC_VECTOR) 
         return STD_LOGIC_VECTOR is

variable B : STD_LOGIC_VECTOR(DIVISOR'length - 1 downto 0); 
variable A : STD_LOGIC_VECTOR(DIVIDEND'length - 1 downto 0);
variable QUOTIENT, REMAINDER : STD_LOGIC_VECTOR(DIVISOR'length - 1 downto 0); 
variable VECT : STD_LOGIC_VECTOR(DIVIDEND'length downto 0);
variable QI : STD_LOGIC_VECTOR(0 downto 0); 
variable OVFL : STD_LOGIC; 

function div(A: STD_LOGIC_VECTOR; 
             B: STD_LOGIC_VECTOR; 
             Q: STD_LOGIC_VECTOR; 
             EXT: STD_LOGIC) 
         return STD_LOGIC_VECTOR is

variable R : STD_LOGIC_VECTOR(A'length - 2 downto 0); 
variable RESIDUAL : STD_LOGIC_VECTOR(A'length - 1 downto 0); 
variable QN : STD_LOGIC_VECTOR(Q'length downto 0); 
variable S : STD_LOGIC_VECTOR(B'length + Q'length downto 0); 

function div1(A: STD_LOGIC_VECTOR; B: STD_LOGIC_VECTOR; Q: STD_LOGIC_VECTOR; EXT: STD_LOGIC) 
         return STD_LOGIC_VECTOR is
variable S : STD_LOGIC_VECTOR(A'length downto 0); 
variable REST : STD_LOGIC_VECTOR(A'length - 1 downto 0); 
variable QN : STD_LOGIC_VECTOR(Q'length downto 0); 

begin
  S := EXT & A - B;

  QN := Q & (not S(S'high));
  if S(S'high) = '1' then
    REST := A;
  else
    REST := S(S'high - 1 downto 0);
  end if;
  return QN & REST;
end div1;

begin
  S := div1(A(A'high downto A'high - B'high), B, Q, EXT);
  QN := S(S'high downto B'high + 1);

  if A'length > B'length then
    R := S(B'high - 1 downto 0) & A(A'high - B'high - 1 downto 0);
    return DIV(R, B, QN, S(B'high));    -- save MSB '1' in the rest for future sum
  else
    RESIDUAL := S(B'high downto 0);
    return QN(QN'high - 1 downto 0) & RESIDUAL;  -- delete initial '0'
  end if;
end div;

begin
  A := DIVIDEND;                                     -- it is necessary to avoid errors during synthesis!!!!
  B := DIVISOR;
  QI := (others =>'0');

  VECT := div(A, B, QI, '0');

  QUOTIENT := VECT(VECT'high - 1 downto B'high + 1); 
  REMAINDER := VECT(B'high downto 0);
  OVFL := VECT(VECT'high );
 return OVFL & QUOTIENT & REMAINDER;
-- return VECT;

end division;



signal A_REG: std_logic_vector(data_width*2 - 1 downto 0);
signal B_REG: std_logic_vector(data_width - 1 downto 0);
signal RD_REG: std_logic_vector(data_width*2 downto 0);

begin

aaa: process(CLK)
begin
if CLK'event and CLK = '1' then 
   A_REG <= DIVIDEND;
   B_REG <= DIVISOR;

  RD_REG <= DIVISION(A_REG, B_REG);
--  RD_REG <= IDIVISION(A_REG, B_REG);

end if;

end process;

DIV_RESULT <= RD_REG;


end RTL;
