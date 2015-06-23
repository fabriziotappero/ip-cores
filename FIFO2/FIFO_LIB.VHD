--============================================================================--
--
--  S Y N T H E Z I A B L E    FIFO controller C O R E
--
--  www.OpenCores.Org - May 2001
--  This core adheres to the GNU public license  
--
-- Design units   : FIFO-Def (Package declaration and body)
--
-- File name      : FIFO_Lib.vhd
--
-- Purpose        : This packages defines all the types used for
--                the FIFO design which are not contained
--                in the IEEE Std_Logic_1164 package.
--
-- Errors         : None known
--
-- Library        : FIFO_Lib
--
-- Dependencies	: None
--
-- Author         : Ovidiu Lupas
--                 http://www.opencores.org/people/olupas
--                 olupas@opencores.org
--
-- Simulator     : ModelSim PE/PLUS version 4.7b on a Windows95 PC
--------------------------------------------------------------------------------
-- Revision list
-- Version   Author       Date          Changes
--
-- 0.1        OL      15 April 99      New model
-------------------------------------------------------------------------------- 
-------------------------------------------------------------------------------- 
-- package FIFO_Def
-------------------------------------------------------------------------------- 
library IEEE,STD;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
--**--
package FIFO_Def is
      -----------------------------------------------------------------------------
      -- function definition
      -----------------------------------------------------------------------------
      function "+"(left, right : bit_vector) 
         return bit_vector;
      -----------------------------------------------------------------------------
      -- Converts unsigned Std_LOGIC_Vector to Integer, leftmost bit is MSB
      -- Error message for unknowns (U, X, W, Z, -), converted to 0
      -- Verifies whether vector is too long (> 16 bits)
      -----------------------------------------------------------------------------
      function  BV2Integer (
         Invector : in  Std_Logic_Vector(3 downto 0))
       return     Integer;
      -----------------------------------------------------------------------------
      -- Converts unsigned Std_LOGIC_Vector to Integer, leftmost bit is MSB
      -- Error message for unknowns (U, X, W, Z, -), converted to 0
      -- Verifies whether vector is too long (> 16 bits)
      -----------------------------------------------------------------------------
      function  ToInteger (
         Invector : in  Unsigned(3 downto 0))
       return     Integer;
      -------------------------------------------------------------------------
      -- internal GRAY counter 16 bits - count up
      -------------------------------------------------------------------------
      component FIFOcnt
         port (
            ClkIn  : in  Std_Logic;
            Reset  : in  Std_Logic;
            Load   : in  Std_Logic;
            Data16 : in  Bit_Vector(15 downto 0);
            CntOut : out Std_Logic);
      end component;
      ---------------------------------------------------------------------
      -- Status counter for FIFO memory
      ---------------------------------------------------------------------
      component StatCnt
         port (
            ClkIn    : in   Std_Logic;
            Reset    : in   Std_Logic;
            Enable   : in   Std_Logic;
            UpDown   : in   Std_Logic;
            Full     : out  Std_Logic;
            Empty    : out  Std_Logic;
            AlmFull  : out  Std_Logic;
            AlmEmpty : out  Std_Logic);
      end component;
end FIFO_Def; --================= End of package header ===================--
package body FIFO_Def is
  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------
  function "+"(left, right : bit_vector) 
     return bit_vector is
     -- normalize the indexing
     alias left_val  : bit_vector(left'length downto 1) is left;
     alias right_val : bit_vector(right'length downto 1) is right;
     -- arbitrarily make the result the same size as the left input
     variable result : bit_vector(left_val'RANGE);
     -- temps
     variable carry : bit := '0';
     variable right_bit : bit;
     variable left_bit : bit;
  begin
     for i in result'reverse_range loop
         left_bit := left_val(i);
         if (i <= right_val'high) then
             right_bit := right_val(i);
         else
             -- zero extend the right input 
             right_bit := '0';
         end if;
         result(i) := (left_bit xor right_bit) xor carry;
         carry := (left_bit  and right_bit)
                or (left_bit and carry)
                or (right_bit and carry);
     end loop;
     return result;
  end "+";
  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------
  --function "+"(left, right : Std_Logic_Vector) 
  --   return Std_Logic_Vector is
  --   -- normalize the indexing
  --   alias left_val  : Std_Logic_Vector(left'length downto 1) is left;
  --   alias right_val : Std_Logic_Vector(right'length downto 1) is right;
  --   -- arbitrarily make the result the same size as the left input
  --   variable result : Std_Logic_Vector(left_val'RANGE);
  --   -- temps
  --   variable carry     : Std_Logic := '0';
  --   variable right_bit : Std_Logic;
  --   variable left_bit  : Std_Logic;
  --begin
  --   for i in result'reverse_range loop
  --       left_bit := left_val(i);
  --       if (i <= right_val'high) then
  --           right_bit := right_val(i);
  --       else
  --           -- zero extend the right input 
  --           right_bit := '0';
  --       end if;
  --       result(i) := (left_bit xor right_bit) xor carry;
  --       carry := (left_bit  and right_bit)
  --              or (left_bit and carry)
  --              or (right_bit and carry);
  --   end loop;
  --   return result;
  --end "+";
  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------
  function  BV2Integer (
       InVector : in Std_Logic_Vector(3 downto 0))
      return  Integer is
    constant HeaderMsg   : String          := "To_Integer:";
    constant MsgSeverity : Severity_Level  := Warning;
    variable Value       : Integer         := 0;
  begin
    for i in 0 to 3 loop
      if (InVector(i) = '1') then
         Value := Value + (2**I);
      end if;
    end loop;
    return Value;
  end BV2Integer;
  -------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------
  function  ToInteger (
       InVector : in Unsigned(3 downto 0))
      return  Integer is
    constant HeaderMsg   : String          := "To_Integer:";
    constant MsgSeverity : Severity_Level  := Warning;
    variable Value       : Integer         := 0;
  begin
    for i in 0 to 3 loop
      if (InVector(i) = '1') then
         Value := Value + (2**I);
      end if;
    end loop;
    return Value;
  end ToInteger;
end FIFO_Def; --================ End of package body ================--
library ieee;
use ieee.Std_Logic_1164.all;
use ieee.Numeric_STD.all;
library work;
use work.FIFO_Def.all;
---------------------------------------------------------------------
-- 16-bit GRAY counter
---------------------------------------------------------------------
entity FIFOcnt is
    port (
        ClkIn  : in  Std_Logic;
        Reset  : in  Std_Logic;
        Enable : in  Std_Logic;
        CntOut : out Std_Logic_Vector(3 downto 0));
end FIFOcnt;
-----------------------------------------------------------------------
-- Architecture for 16-bit GRAY counter - generates the internal clock
-----------------------------------------------------------------------
architecture Behaviour of FIFOcnt is
  ---------------------------------------------------------------------
  -- Signals
  ---------------------------------------------------------------------  
  type CNT_Array is array(0 to 15) of Std_Logic_Vector(3 downto 0);
  constant Cnt_Code : CNT_Array := ("0000","0010","0011","0001",
                                    "1000","1010","1011","1001",
                                    "1100","1110","1111","1101",
                                    "0100","0110","0111","0101");
  signal binidx : Unsigned(3 downto 0);
begin --======================== Architecture =======================--
  process(ClkIn,Reset,Enable)
  begin
     if Reset = '1' then
        binidx <= (others => '0');
     elsif ClkIn'Event and ClkIn = '1' then
        if Enable = '1' then
           binidx <= binidx + "1";
        end if;
     end if;
  end process;
  CntOut <= Cnt_Code(ToInteger(binidx));
end Behaviour; --================ End of architecture ================--

library ieee;
use ieee.Std_Logic_1164.all;
use ieee.Numeric_STD.all;
library work;
use work.FIFO_Def.all;
---------------------------------------------------------------------
-- Up-Down counter for FIFO status
---------------------------------------------------------------------
entity StatCnt is
    port (
        ClkIn    : in   Std_Logic;
        Reset    : in   Std_Logic;
        Enable   : in   Std_Logic;
        UpDown   : in   Std_Logic;
        Full     : out  Std_Logic;
        Empty    : out  Std_Logic;
        AlmFull  : out  Std_Logic;
        AlmEmpty : out  Std_Logic);
end StatCnt;
-----------------------------------------------------------------------
-- Architecture for 16-bit GRAY counter - generates the internal clock
-----------------------------------------------------------------------
architecture Behaviour of StatCnt is
  ---------------------------------------------------------------------
  -- Signals
  ---------------------------------------------------------------------  
  type CNT_Array is array(0 to 15) of Std_Logic_Vector(3 downto 0);
  constant Cnt_Code : CNT_Array := ("0000","0001","0010","0011",
                                    "0100","0101","0110","0111",
                                    "1000","1001","1010","1011",
                                    "1100","1101","1110","1111");
  signal binidx : Unsigned(3 downto 0);
  signal CntOut : Integer;
begin --======================== Architecture =======================--
  process(ClkIn,Reset,Enable)
  begin
     if Reset = '1' then
        binidx <= (others => '0');
     elsif (Rising_Edge(ClkIn) and Enable = '1') then
        if UpDown = '1' then
           binidx <= binidx + "1";
        else 
           binidx <= binidx - "1";
        end if;
     end if;
     CntOut <= ToInteger(binidx);
     case CntOut is
         when 0 => 
               Empty <= '1';
               AlmEmpty <= '0';
               AlmFull <= '0';
               Full <= '0';
         when 1 => 
               Empty <= '0';
               AlmEmpty <= '1';
               AlmFull <= '0';
               Full <= '0';
         when 2 => 
               Empty <= '0';
               AlmEmpty <= '1';
               AlmFull <= '0';
               Full <= '0';
         when 13 =>
               Empty <= '0';
               AlmEmpty <= '0';
               AlmFull <= '1';
               Full <= '0';
         when 14 =>
               Empty <= '0';
               AlmEmpty <= '0';
               AlmFull <= '1';
               Full <= '0';
         when 15 =>
               Empty <= '0';
               AlmEmpty <= '0';
               AlmFull <= '0';
               Full <= '1';
         when others =>
               Empty <= '0';
               AlmEmpty <= '0';
               AlmFull <= '0';
               Full <= '0';
     end case;
  end process;
end Behaviour; --================ End of architecture ================--
