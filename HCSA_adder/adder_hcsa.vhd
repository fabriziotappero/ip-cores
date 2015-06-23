-------------------------------------------------------------------------------
--  File: adder_hcsa.vhd                                                     --
--                                                                           --
-- Copyright (C) Deversys, 2003                                              --
--                                                                           --
-- hirerachical carry save adder                                             --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
-- SYNOPSYS synthesis results (0.35u library, worst case military conditions)--
-- ------------------------------------------                                --
-- |  operands  |   delay   | combinational |                                --
-- | dimension  |   (ns)    |  area (gates) |                                --
-- |------------|-----------|---------------|                                --
-- |    8       |    2.51   |       143     |                                --
-- |   16       |    3.09   |       327     |                                --
-- |   32       |    4.18   |       527     |                                --
-- |   64       |    5.34   |      1061     |                                --
-- |  128       |    6.64   |      1965     |                                --
-- ------------------------------------------                                --
-------------------------------------------------------------------------------
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

 
entity adder_HCSA is
	port (
		CLK: in std_logic;
		A_BUS: in STD_LOGIC_VECTOR (15 downto 0);
		B_BUS: in STD_LOGIC_VECTOR (15 downto 0);
		SUM_OUT: out STD_LOGIC_VECTOR (15 downto 0)
	  );
end adder_HCSA;



architecture RTL of adder_HCSA is


-- the operand (A or B) with the biggest length must have length of degree 2.

function FS(A: STD_LOGIC_VECTOR; B: STD_LOGIC_VECTOR; CIN: STD_LOGIC := '0') 
         return STD_LOGIC_VECTOR is
         
      function SPEEDSUM(A: STD_LOGIC_VECTOR; 
                        B: STD_LOGIC_VECTOR; 
                        constant CIN: STD_LOGIC) return STD_LOGIC_VECTOR is
      
      variable A1, B1, C1, D1: STD_LOGIC_VECTOR((A'length +1)/2 - 1 downto 0); 
      variable E1: STD_LOGIC_VECTOR((A'length +1)/2 downto 0); 
      variable F1: STD_LOGIC_VECTOR((A'length +1)/2 downto 0); 
      variable X: STD_LOGIC_VECTOR(2 downto 0);
      variable RETV: STD_LOGIC_VECTOR(A'length downto 0);
      
      begin
         if A'length = 1 then
            if CIN = '1' then
               return ((A(0) or B(0))  & (not (A(0) xor B(0))));
            else
               return ((A(0) and B(0)) &      (A(0) xor B(0)));
            end if;
         else
            A1 := A(A'high downto (A'high + 1)/2);
            B1 := B(A'high downto (A'high + 1)/2);
            C1 := A((A'high+1)/2 - 1 downto A'low);
            D1 := B((A'high+1)/2 - 1 downto A'low);
            E1 := SPEEDSUM(C1, D1, CIN);
            if E1(E1'high)='1' then
               F1 := SPEEDSUM(A1, B1, '1');
            else
               F1 := SPEEDSUM(A1, B1, '0');
            end if;
            RETV := F1 & E1(E1'high - 1 downto 0);
            return RETV;
         end if;
      end SPEEDSUM;

variable AIN, BIN : std_logic_vector((A'length+B'length+ABS(A'length-B'length))/2-1 downto 0) := (others=>'0');

begin
   AIN(A'high downto 0) := A;
   BIN(B'high downto 0) := B;
   
   return SPEEDSUM(AIN, BIN, CIN)((A'length+B'length+ABS(A'length-B'length))/2-1 downto 0);
end FS;



signal A_REG, B_REG, C_REG: std_logic_vector(15 downto 0);
--signal A_REG, C_REG: std_logic_vector(15 downto 0);
--signal B_REG: std_logic_vector(7 downto 0);

begin

aaa: process(CLK)
begin
if CLK'event and CLK = '1' then 
   A_REG <= A_BUS;
   B_REG <= B_BUS;
   C_REG <= FS(A_REG, B_REG);
end if;
end process;

SUM_OUT <= C_REG;

end RTL;
