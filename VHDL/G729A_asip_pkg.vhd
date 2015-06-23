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
-- G.729A data types and conversion functions package
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

package G729A_ASIP_PKG is

  -- short data word-length
  constant SDLEN : integer := 16;

  -- long data word-length
  constant LDLEN : integer := 32;

  -- instruction word-length
  constant ILEN : integer := 24;

  -- address word-length
  constant ALEN : integer := 16;

  -- short data word type
  subtype SDWORD_T is signed(SDLEN-1 downto 0);

  -- long data word type
  subtype LDWORD_T is signed(LDLEN-1 downto 0);

  -- Signed 16-bit integer type
  subtype SINT16_T is integer range -2**(SDLEN-1) to 2**(SDLEN-1)-1;

  -- Unsigned 16-bit integer type
  subtype UINT16_T is integer range 0 to 2**SDLEN-1;

  -- register identifier type
  subtype RID_T is integer range 0 to 16-1;

  function log2(VAL : integer range 1 to 2**20-1) return integer;

  function hex_to_int(XSTR : string) return integer;

  function hex_to_uint16(XSTR : string (1 to 4)) return UINT16_T;

  function pos_overflow(VAL : LDWORD_T) return std_logic;

  function neg_overflow(VAL : LDWORD_T) return std_logic;

  -- convert hex string to integer
  function hex_to_natural(XSTR : string) return natural;

  -- convert hex string to std_logic_vector
  function hex_to_std_logic(XSTR : string) return std_logic_vector;

  -- convert hex string to unsigned
  function hex_to_unsigned(XSTR : string) return unsigned;

  -- convert unsigned to std_logic_vector
  function to_std_logic_vector(U : unsigned) return std_logic_vector;

  -- convert signed to std_logic_vector
  function to_std_logic_vector(S : signed) return std_logic_vector;

  -- convert std_logic_vector to unsigned
  function to_unsigned(V : std_logic_vector) return unsigned;

  -- convert signed to unsigned
  function to_unsigned(S : signed) return unsigned;

  -- convert std_logic_vector to signed
  function to_signed(V : std_logic_vector) return signed;

end G729A_ASIP_PKG;

package body G729A_ASIP_PKG is

  function log2(VAL : integer range 1 to 2**20-1) return integer is
    variable LOG2 : integer range 0 to 20 := 0;
  begin
    while (VAL > 2**LOG2) loop
      LOG2 := LOG2 + 1;
    end loop;
    return(LOG2);
  end function;

  function hex_to_int(XSTR : string) return integer is
    variable VAL : integer := 0;
    variable DGT : integer range 0 to 15;
  begin
    for i in XSTR'length downto 1 loop
      case XSTR(i) is
        when '0' => DGT := 0;
        when '1' => DGT := 1;
        when '2' => DGT := 2;
        when '3' => DGT := 3;
        when '4' => DGT := 4;
        when '5' => DGT := 5;
        when '6' => DGT := 6;
        when '7' => DGT := 7;
        when '8' => DGT := 8;
        when '9' => DGT := 9;
        when 'a' => DGT := 10;
        when 'b' => DGT := 11;
        when 'c' => DGT := 12;
        when 'd' => DGT := 13;
        when 'e' => DGT := 14;
        when others => DGT := 15;
      end case;
      VAL := VAL + DGT*(16**(4-i));
    end loop;
    return(VAL);
  end function;

  function hex_to_uint16(XSTR : string(1 to 4)) return UINT16_T is
  begin
    return(hex_to_int(XSTR));
  end function;

  function pos_overflow(VAL : LDWORD_T) return std_logic is
    variable SVAL : LDWORD_T;
  begin
    if(VAL(LDLEN-1) = '1') then
      return('0');
    else
      SVAL := shift_right(VAL,SDLEN-1);
      if(SVAL = 0) then
        return('0');
      else
        return('1');
      end if;
    end if;
  end function;

  function neg_overflow(VAL : LDWORD_T) return std_logic is
    variable SVAL : LDWORD_T;
  begin
    if(VAL(LDLEN-1) = '0') then
      return('0');
    else
      SVAL := not(shift_right(VAL,SDLEN-1));
      if(SVAL = 0) then
        return('0');
      else
        return('1');
      end if;
    end if;
  end function;

  function hex_to_natural(XSTR : string) return natural is
    variable VAL : natural := 0;
    variable DGT : natural range 0 to 15;
  begin
    for i in 1 to XSTR'length loop
      case XSTR(i) is
        when '0' => DGT := 0;
        when '1' => DGT := 1;
        when '2' => DGT := 2;
        when '3' => DGT := 3;
        when '4' => DGT := 4;
        when '5' => DGT := 5;
        when '6' => DGT := 6;
        when '7' => DGT := 7;
        when '8' => DGT := 8;
        when '9' => DGT := 9;
        when 'a' => DGT := 10;
        when 'b' => DGT := 11;
        when 'c' => DGT := 12;
        when 'd' => DGT := 13;
        when 'e' => DGT := 14;
        when others => DGT := 15;
      end case;
      VAL := VAL + DGT*(16**(XSTR'length-i));
    end loop;
    return(VAL);
  end function;

  function hex_to_std_logic(XSTR : string) return std_logic_vector is
    variable VEC : unsigned(XSTR'length*4-1 downto 0);
    variable DGT : unsigned(4-1 downto 0);
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
      VEC(XSTR'length*4-1 downto 4) := VEC(XSTR'length*4-1-4 downto 0);
      VEC(4-1 downto 0) := DGT;
    end loop;
    return(to_std_logic_vector(VEC));
  end function;

  function hex_to_unsigned(XSTR : string) return unsigned is
    variable VEC : unsigned(XSTR'length*4-1 downto 0);
    variable DGT : unsigned(4-1 downto 0);
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
      VEC(XSTR'length*4-1 downto 4) := VEC(XSTR'length*4-1-4 downto 0);
      VEC(4-1 downto 0) := DGT;
    end loop;
    return(VEC);
  end function;

  function to_std_logic_vector(U : unsigned) return std_logic_vector is
    variable V : std_logic_vector(U'high downto U'low);
  begin
    for i in U'low to U'high loop
      V(i) := U(i);
    end loop;
    return(V);
  end function;

  function to_std_logic_vector(S : signed) return std_logic_vector is
     variable V : std_logic_vector(S'high downto S'low);
  begin
    for i in S'low to S'high loop
      V(i) := S(i);
    end loop;
    return(V);
  end function;

  function to_unsigned(V : std_logic_vector) return unsigned is
    variable U : unsigned(V'high downto V'low);
  begin
    for i in V'low to V'high loop
      U(i) := V(i);
    end loop;
    return(U);
  end function;

  function to_unsigned(S : signed) return unsigned is
    variable U : unsigned(S'high downto S'low);
  begin
    for i in S'low to S'high loop
      U(i) := S(i);
    end loop;
    return(U);
  end function;

  function to_signed(V : std_logic_vector) return signed is
    variable S : signed(V'high downto V'low);
  begin
    for i in V'low to V'high loop
      S(i) := V(i);
    end loop;
    return(S);
  end function;

end G729A_ASIP_PKG;
