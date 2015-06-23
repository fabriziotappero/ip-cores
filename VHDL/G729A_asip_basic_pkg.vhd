-----------------------------------------------------------------
--                                                             --
-----------------------------------------------------------------
--                                                             --
-- Copyright (C) 2013 Stefano Tonello                          --
--                                                             --
-- This source file may be used and distributed without        --
-- restriction provided that this copyright statement is not   --
-- removed from the file and that any derivative work contains --
-- the original copyright notice and the associated disclaimer.--
--                                                             --
-- THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY         --
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   --
-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   --
-- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      --
-- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         --
-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    --
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   --
-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        --
-- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  --
-- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  --
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  --
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         --
-- POSSIBILITY OF SUCH DAMAGE.                                 --
--                                                             --
-----------------------------------------------------------------

---------------------------------------------------------------
-- Basic data types
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;

package G729A_ASIP_BASIC_PKG is

  constant MIN_16 : SDWORD_T := (SDLEN-1 => '1', others => '0'); 

  constant MAX_16 : SDWORD_T := (SDLEN-1 => '0', others => '1'); 

  constant MIN_32 : LDWORD_T := (LDLEN-1 => '1', others => '0'); 

  constant MAX_32 : LDWORD_T := (LDLEN-1 => '0', others => '1'); 

  subtype SHORT_SHIFT_T is integer range -SDLEN to SDLEN-1;

  subtype LONG_SHIFT_T is integer range -LDLEN to LDLEN-1;

  -- These additional types have been defined to handle overflow
  -- conditions: valid range top/bottom values are used to flag
  -- overflow.

  subtype SHORT_SHIFT_OVF_T is integer range -SDLEN to SDLEN;

  subtype LONG_SHIFT_OVF_T is integer range -LDLEN to LDLEN;

  ------------------------------------
  -- Convert hex digit string to signed value 
  ------------------------------------

  function hex_to_signed(XSTR : string;LEN : integer) return signed;

  ------------------------------------
  -- Convert LDWORD_T-type value to SDWORD_T-type
  ------------------------------------

  procedure sature(
    LVAL : in LDWORD_T;
    SVAL : out SDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  -- Get absolute value of SDWORD_T-type value
  ------------------------------------

  function abs_s(SVAL : SDWORD_T) return SDWORD_T;

  ------------------------------------
  -- Shift Left (WORD-type value)
  ------------------------------------

  procedure shl(
    SVALI : in SDWORD_T;
    SHFT : in  SHORT_SHIFT_T;
    SVALO : out SDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  -- Shift Right (WORD-type value)
  ------------------------------------

  procedure shr(
    SVALI : in SDWORD_T;
    SHFT : in  SHORT_SHIFT_T;
    SVALO : out SDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  -- Multiply (WORD-type result)
  ------------------------------------

  procedure mult(
    PROD : in LDWORD_T;
    RES : out SDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  -- Long Multiply (DWORD-type result)
  ------------------------------------

  procedure L_mult(
    PROD : in LDWORD_T;
    RES : out LDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  -- Get 2's complement of SDWORD_T-type value
  ------------------------------------

  function negate(SVAL : SDWORD_T) return SDWORD_T;

  ------------------------------------
  -- Long Addition/Subtraction 
  -- (DWORD-type result)
  ------------------------------------

  procedure L_add_sub(
    SUM : in LDWORD_T;
    AS : in std_logic;
    SA : in std_logic;
    SB : in std_logic;
    RES : out LDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  -- Get 2's complement of LDWORD_T-type value
  ------------------------------------

  function L_negate(LVAL : LDWORD_T) return LDWORD_T;

  ------------------------------------
  --  Long Shift Left (DWORD-type result)
  ------------------------------------

  procedure L_shl(
    LVALI : in LDWORD_T;
    SHFT : in  LONG_SHIFT_T;
    LVALO : out LDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  --  Long Shift Right (DWORD-type result)
  ------------------------------------

  procedure L_shr(
    LVALI : in LDWORD_T;
    SHFT : in  LONG_SHIFT_T;
    LVALO : out LDWORD_T;
    OVF : out std_logic
  );

  ------------------------------------
  -- Get absolute value of LDWORD_T-type value
  ------------------------------------

  function L_abs(LVAL : LDWORD_T) return LDWORD_T;

  ------------------------------------
  -- Get normalization shift amount
  -- (for a SDWORD_T-type value)
  ------------------------------------

  function norm_s(SVAL : SDWORD_T) return  SHORT_SHIFT_T;

  ------------------------------------
  -- Divide (WORD-type operands and result)
  ------------------------------------

  --function div_s(DD,DR : SDWORD_T) return SDWORD_T;

  ------------------------------------
  -- Get normalization shift amount
  -- (for a LDWORD_T-type value)
  ------------------------------------

  function norm_l(LVAL : LDWORD_T) return  LONG_SHIFT_T;

  ------------------------------------

  --function pos_overflow(VAL : LDWORD_T) return std_logic;

  --function neg_overflow(VAL : LDWORD_T) return std_logic;

end G729A_ASIP_BASIC_PKG;

package body G729A_ASIP_BASIC_PKG is

  ------------------------------------

  function hex_to_signed(XSTR : string;LEN : integer) return signed is
    variable VAL : signed(XSTR'length*4-1 downto 0);
    variable DGT : std_logic_vector(3 downto 0);
  begin
    for i in 1 to XSTR'length loop
      case XSTR(i) is
        when '0' => DGT := "0000";
        when '1' => DGT := "0001";
        when '2' => DGT := "0010";
        when '3' => DGT := "0011";
        when '4' => DGT := "0100";
        when '5' => DGT := "0101";
        when '6' => DGT := "0110";
        when '7' => DGT := "0111";
        when '8' => DGT := "1000";
        when '9' => DGT := "1001";
        when 'a' => DGT := "1010";
        when 'b' => DGT := "1011";
        when 'c' => DGT := "1100";
        when 'd' => DGT := "1101";
        when 'e' => DGT := "1110";
        when others => DGT := "1111";
      end case;
      for j in 3 downto 0 loop 
        VAL((XSTR'length-i)*4+j) := DGT(j);
      end loop;
    end loop;
    return(VAL(LEN-1 downto 0));
  end function;

  ------------------------------------

  procedure sature(
    LVAL : in LDWORD_T;
    SVAL : out SDWORD_T;
    OVF : out std_logic
  ) is
    constant ALL_ZERO : LDWORD_T := to_signed(0,LDLEN);
    constant ALL_ONE : LDWORD_T := not(ALL_ZERO);
    variable TMP : LDWORD_T;
  begin
    TMP := shift_right(LVAL,SDLEN-1);
    if((LVAL > 0) and not(TMP = ALL_ZERO)) then
      -- positive overflow
      SVAL := MAX_16;
      OVF := '1';
    elsif((LVAL < 0) and  not(TMP = ALL_ONE)) then
      -- negative overflow
      SVAL := MIN_16;
      OVF := '1';
    else
      -- exact result
      SVAL := LVAL(SDLEN-1 downto 0);
      OVF := '0';
    end if;
  end sature;

  ------------------------------------

  function abs_s(SVAL : SDWORD_T) return SDWORD_T is
  begin
    if(SVAL = MIN_16) then
      return(MAX_16);
    elsif(SVAL < 0) then
      return(-SVAL);
    else
      return(SVAL);
    end if;
  end function;

  ------------------------------------

  procedure shl(
    SVALI : in SDWORD_T;
    SHFT : in  SHORT_SHIFT_T;
    SVALO : out SDWORD_T;
    OVF : out std_logic
  ) is
    constant ALL_ZERO : SDWORD_T := to_signed(0,SDLEN);
    variable TMP : SDWORD_T;
  begin
    if(SVALI = ALL_ZERO) then
      SVALO := SVALI;
      OVF := '0';
    elsif(SHFT >= 0) then
      TMP := shift_left(SVALI,SHFT);
      if(TMP = ALL_ZERO)then
        if(SVALI < 0) then
          SVALO := MIN_16;
        else
          SVALO := MAX_16;
        end if;
        OVF := '1';
      else
        SVALO := TMP;
        OVF := '0';
      end if;
    else
      SVALO := shift_right(SVALI,-SHFT);
      OVF := '0';
    end if;
  end shl;

  ------------------------------------

  procedure shr(
    SVALI : in SDWORD_T;
    SHFT : in  SHORT_SHIFT_T;
    SVALO : out SDWORD_T;
    OVF : out std_logic
  ) is
    constant ALL_ZERO : SDWORD_T := to_signed(0,SDLEN);
    variable TMP : SDWORD_T;
  begin
    if(SVALI = ALL_ZERO) then
      SVALO := SVALI;
      OVF := '0';
    elsif(SHFT <= 0) then
      TMP := shift_left(SVALI,-SHFT);
      if(TMP = ALL_ZERO)then
        if(SVALI < 0) then
          SVALO := MIN_16;
        else
          SVALO := MAX_16;
        end if;
        OVF := '1';
      else
        SVALO := TMP;
        OVF := '0';
      end if;
    else
      SVALO := shift_right(SVALI,SHFT);
      OVF := '0';
    end if;
  end shr;

  ------------------------------------

  -- This procedure takes WLEN x WLEN multiplication
  -- result, right-shift it by WLEN-1 bits and
  -- convert it to WLEN-bits with saturation.
  -- Actual multiplication must be performed before
  -- invoking this procedure.

  procedure mult(
    PROD : in LDWORD_T;
    RES : out SDWORD_T;
    OVF : out std_logic
  ) is
    variable TMP : LDWORD_T;
  begin 
    TMP := shift_right(PROD,SDLEN-1);
    sature(TMP,RES,OVF);
  end mult;

  ------------------------------------

  -- This procedure takes WLEN x WLEN multiplication
  -- result and left-shift it by 1, checking for 
  -- overflow

  procedure L_mult(
    PROD : in LDWORD_T;
    RES : out LDWORD_T;
    OVF : out std_logic
  ) is
    constant OVFVAL : LDWORD_T := hex_to_signed("40000000",LDLEN);
  begin 
    if(PROD = OVFVAL) then
      RES := MAX_32;
      OVF := '1';
    else
      RES := shift_left(PROD,1);
      OVF := '0';
    end if;
  end L_mult;

  ------------------------------------

  -- This procedure generates -SVAL value.
  -- If SVAL = MIN_16 (minimum signed integer)
  -- negate result can't be exact, and is
  -- approximated to MAX_16.

  function negate(SVAL : SDWORD_T) return SDWORD_T is
  begin
    if(SVAL = MIN_16) then
      return(MAX_16);
    else
      return(-SVAL);
    end if;
  end function;

  ------------------------------------

  -- This procedure takes LDLEN-bit
  -- addition/subtraction result and
  -- operand signs, and checks for overflow.

  procedure L_add_sub(
    SUM : in LDWORD_T;
    AS : in std_logic;
    SA : in std_logic;
    SB : in std_logic;
    RES : out LDWORD_T;
    OVF : out std_logic
  ) is
    variable ST : std_logic;
    variable IOVF : std_logic;
  begin
    ST := SUM(LDLEN-1);
    -- overflow flag
    if(AS = '1') then
      -- addition
      if(ST = '1') then
        IOVF := not(SA or SB);
      else
        IOVF := (SA and SB);
      end if;
    else
      -- subtraction
      if(ST = '1') then
        IOVF := (not(SA) and SB);
      else
        IOVF := (SA and not(SB));
      end if;
    end if;
    -- saturated result
    if(IOVF = '0') then
      RES := SUM;
    elsif(ST = '0') then
      RES := MIN_32;
    else
      RES := MAX_32;
    end if;
    OVF := IOVF;
  end L_add_sub;

  ------------------------------------

  -- This procedure generates -LVAL value.
  -- If LVAL = MIN_32 (minimum signed integer)
  -- negate result can't be exact, and is
  -- approximated to MAX_32.

  function L_negate(LVAL : LDWORD_T) return LDWORD_T is
  begin
    if(LVAL = MIN_32) then
      return(MAX_32);
    else
      return(-LVAL);
    end if;
  end function;

  ------------------------------------

  procedure L_shl(
    LVALI : in LDWORD_T;
    SHFT : in  LONG_SHIFT_T;
    LVALO : out LDWORD_T;
    OVF : out std_logic
  ) is
    constant ALL_ZERO : LDWORD_T := to_signed(0,LDLEN);
    variable TMP : LDWORD_T;
  begin
    if(LVALI = ALL_ZERO) then
      LVALO := LVALI;
      OVF := '0';
    elsif(SHFT >= 0) then
      TMP := shift_left(LVALI,SHFT);
      if(TMP = ALL_ZERO)then
        if(LVALI < 0) then
          LVALO := MIN_32;
        else
          LVALO := MAX_32;
        end if;
        OVF := '1';
      else
        LVALO := TMP;
        OVF := '0';
      end if;
    else
      LVALO := shift_right(LVALI,-SHFT);
      OVF := '0';
    end if;
  end L_shl;

  ------------------------------------

  procedure L_shr(
    LVALI : in LDWORD_T;
    SHFT : in  LONG_SHIFT_T;
    LVALO : out LDWORD_T;
    OVF : out std_logic
  ) is
    constant ALL_ZERO : LDWORD_T := to_signed(0,LDLEN);
    variable TMP : LDWORD_T;
  begin
    if(LVALI = ALL_ZERO) then
      LVALO := LVALI;
      OVF := '0';
    elsif(SHFT <= 0) then
      TMP := shift_left(LVALI,-SHFT);
      if(TMP = ALL_ZERO)then
        if(LVALI < 0) then
          LVALO := MIN_32;
        else
          LVALO := MAX_32;
        end if;
        OVF := '1';
      else
        LVALO := TMP;
        OVF := '0';
      end if;
    else
      LVALO := shift_right(LVALI,SHFT);
      OVF := '0';
    end if;
  end L_shr;

  ------------------------------------

  function L_abs(LVAL : LDWORD_T) return LDWORD_T is
  begin
    if(LVAL = MIN_32) then
      return(MAX_32);
    elsif(LVAL < 0) then
      return(-LVAL);
    else
      return(LVAL);
    end if;
  end function;

  ------------------------------------

  function norm_s(SVAL : SDWORD_T) return  SHORT_SHIFT_T is
    constant ALL_ZERO : SDWORD_T := to_signed(0,SDLEN);
    constant ALL_ONE : SDWORD_T := not(ALL_ZERO);
    variable TMP : SDWORD_T;
    variable NRM :  SHORT_SHIFT_T;
  begin
    if(SVAL = ALL_ZERO) then
      return(0);
    elsif(SVAL = ALL_ONE) then
      return(SDLEN-1);
    else
      if(SVAL < 0) then
        TMP := not(SVAL);
      else
        TMP := SVAL;
      end if;

      if(TMP(SDLEN-2) = '1') then NRM := 0;
      elsif(TMP(SDLEN-3) = '1') then NRM := 1;
      elsif(TMP(SDLEN-4) = '1') then NRM := 2;
      elsif(TMP(SDLEN-5) = '1') then NRM := 3;
      elsif(TMP(SDLEN-6) = '1') then NRM := 4;
      elsif(TMP(SDLEN-7) = '1') then NRM := 5;
      elsif(TMP(SDLEN-8) = '1') then NRM := 6;
      elsif(TMP(SDLEN-9) = '1') then NRM := 7;
      elsif(TMP(SDLEN-10) = '1') then NRM := 8;
      elsif(TMP(SDLEN-11) = '1') then NRM := 9;
      elsif(TMP(SDLEN-12) = '1') then NRM := 10;
      elsif(TMP(SDLEN-13) = '1') then NRM := 11;
      elsif(TMP(SDLEN-14) = '1') then NRM := 12;
      elsif(TMP(SDLEN-15) = '1') then NRM := 13;
      else NRM := 14;
      end if;

--      case TMP is
--        when "0000000000000001" => NRM := 15; 
--        when "000000000000001-" => NRM := 14; 
--        when "00000000000001--" => NRM := 13; 
--        when "0000000000001---" => NRM := 12; 
--        when "000000000001----" => NRM := 11; 
--        when "00000000001-----" => NRM := 10; 
--        when "0000000001------" => NRM := 9; 
--        when "000000001-------" => NRM := 8; 
--        when "00000001--------" => NRM := 7; 
--        when "0000001---------" => NRM := 6; 
--        when "000001----------" => NRM := 5; 
--        when "00001-----------" => NRM := 4; 
--        when "0001------------" => NRM := 3; 
--        when "001-------------" => NRM := 2; 
--        when others => NRM := 1; 
--      end case;
      return(NRM);
    end if;
  end function;

  ------------------------------------

  function norm_l(LVAL : LDWORD_T) return  LONG_SHIFT_T is
    constant ALL_ZERO : LDWORD_T := to_signed(0,LDLEN);
    constant ALL_ONE : LDWORD_T := not(ALL_ZERO);
    variable TMP : LDWORD_T;
    variable NRM :  LONG_SHIFT_T;
  begin
    if(LVAL = ALL_ZERO) then
      return(0);
    elsif(LVAL = ALL_ONE) then
      return(LDLEN-1);
    else
      if(LVAL < 0) then
        TMP := not(LVAL);
      else
        TMP := LVAL;
      end if;
      NRM := 0;
      for i in 0 to LDLEN-2 loop
        if(TMP (i) = '1') then
          NRM := (LDLEN-2)-i; 
        end if;
      end loop;

      if(TMP(LDLEN-2) = '1') then NRM := 0;
      elsif(TMP(LDLEN-3)  = '1') then NRM := 1;
      elsif(TMP(LDLEN-4)  = '1') then NRM := 2;
      elsif(TMP(LDLEN-5)  = '1') then NRM := 3;
      elsif(TMP(LDLEN-6)  = '1') then NRM := 4;
      elsif(TMP(LDLEN-7)  = '1') then NRM := 5;
      elsif(TMP(LDLEN-8)  = '1') then NRM := 6;
      elsif(TMP(LDLEN-9)  = '1') then NRM := 7;
      elsif(TMP(LDLEN-10) = '1') then NRM := 8;
      elsif(TMP(LDLEN-11) = '1') then NRM := 9;
      elsif(TMP(LDLEN-12) = '1') then NRM := 10;
      elsif(TMP(LDLEN-13) = '1') then NRM := 11;
      elsif(TMP(LDLEN-14) = '1') then NRM := 12;
      elsif(TMP(LDLEN-15) = '1') then NRM := 13;
      elsif(TMP(LDLEN-16) = '1') then NRM := 14;
      elsif(TMP(LDLEN-17) = '1') then NRM := 15;
      elsif(TMP(LDLEN-18) = '1') then NRM := 16;
      elsif(TMP(LDLEN-19) = '1') then NRM := 17;
      elsif(TMP(LDLEN-20) = '1') then NRM := 18;
      elsif(TMP(LDLEN-21) = '1') then NRM := 19;
      elsif(TMP(LDLEN-22) = '1') then NRM := 20;
      elsif(TMP(LDLEN-23) = '1') then NRM := 21;
      elsif(TMP(LDLEN-24) = '1') then NRM := 22;
      elsif(TMP(LDLEN-25) = '1') then NRM := 23;
      elsif(TMP(LDLEN-26) = '1') then NRM := 24;
      elsif(TMP(LDLEN-27) = '1') then NRM := 25;
      elsif(TMP(LDLEN-28) = '1') then NRM := 26;
      elsif(TMP(LDLEN-29) = '1') then NRM := 27;
      elsif(TMP(LDLEN-30) = '1') then NRM := 28;
      elsif(TMP(LDLEN-31) = '1') then NRM := 29;
      else NRM := 30;
      end if;

--      case TMP is
--        when "00000000000000000000000000000001" => NRM := 31; 
--        when "0000000000000000000000000000001-" => NRM := 30; 
--        when "000000000000000000000000000001--" => NRM := 29; 
--        when "00000000000000000000000000001---" => NRM := 28; 
--        when "0000000000000000000000000001----" => NRM := 27; 
--        when "000000000000000000000000001-----" => NRM := 26; 
--        when "00000000000000000000000001------" => NRM := 25; 
--        when "0000000000000000000000001-------" => NRM := 24; 
--        when "000000000000000000000001--------" => NRM := 23; 
--        when "00000000000000000000001---------" => NRM := 22; 
--        when "0000000000000000000001----------" => NRM := 21; 
--        when "000000000000000000001-----------" => NRM := 20; 
--        when "00000000000000000001------------" => NRM := 19; 
--        when "0000000000000000001-------------" => NRM := 18; 
--        when "000000000000000001--------------" => NRM := 17; 
--        when "00000000000000001---------------" => NRM := 16; 
--        when "0000000000000001----------------" => NRM := 15; 
--        when "000000000000001-----------------" => NRM := 14; 
--        when "00000000000001------------------" => NRM := 13; 
--        when "0000000000001-------------------" => NRM := 12; 
--        when "000000000001--------------------" => NRM := 11; 
--        when "00000000001---------------------" => NRM := 10; 
--        when "0000000001----------------------" => NRM := 9; 
--        when "000000001-----------------------" => NRM := 8; 
--        when "00000001------------------------" => NRM := 7; 
--        when "0000001-------------------------" => NRM := 6; 
--        when "000001--------------------------" => NRM := 5; 
--        when "00001---------------------------" => NRM := 4; 
--        when "0001----------------------------" => NRM := 3; 
--        when "001-----------------------------" => NRM := 2; 
--        when others => NRM := 1; 
--      end case;
      return(NRM);
    end if;
  end function;

  ------------------------------------

--  function pos_overflow(VAL : LDWORD_T) return std_logic is
--    variable SVAL : LDWORD_T;
--  begin
--    if(VAL(LDLEN-1) = '1') then
--      return('0');
--    else
--      SVAL := shift_right(VAL,SDLEN-1);
--      if(SVAL = 0) then
--        return('0');
--      else
--        return('1');
--      end if;
--    end if;
--  end function;
--
--  function neg_overflow(VAL : LDWORD_T) return std_logic is
--    variable SVAL : LDWORD_T;
--  begin
--    if(VAL(LDLEN-1) = '0') then
--      return('0');
--    else
--      SVAL := not(shift_right(VAL,SDLEN-1));
--      if(SVAL = 0) then
--        return('0');
--      else
--        return('1');
--      end if;
--    end if;
--  end function;

end G729A_ASIP_BASIC_PKG;
