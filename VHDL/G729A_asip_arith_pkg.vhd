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
-- Arithmetic operations macros and shifting functions
---------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

library WORK;
use WORK.G729A_ASIP_PKG.all;
use WORK.G729A_ASIP_BASIC_PKG.all;

package G729A_ASIP_ARITH_PKG is

  type ADD_CTRL is (
    AC_ABS,
    AC_ADD,
    AC_NEG,
    AC_SUB,
    AC_LABS,
    AC_LADD,
    AC_LNEG,
    AC_LSUB,
    AC_LEXT,
    AC_RND,
    AC_INC,
    AC_DEC,
    AC_NIL
  );

  type MUL_CTRL is (
    MC_MUL,
    MC_LMUL,
    MC_MULA,
    MC_MULR,
    MC_LMAC,
    MC_LMSU,
    MC_M3216,
    MC_M32,
    MC_NIL
  );

  type SHF_CTRL is (
    SC_SHL,
    SC_SHR,
    SC_LSHL,
    SC_LSHR,
    SC_NRMS,
    SC_NRML,
    SC_NIL
  );

  type LOG_CTRL is (
    LC_AND,
    LC_OR,
    LC_ANDL,
    LC_ANDH,
    LC_ORL,
    LC_ORH,
    LC_NIL
  );

  function shift_left16(SI : SDWORD_T;SHFT : LONG_SHIFT_T) return SDWORD_T;
  
  function shift_right16(SI : SDWORD_T;SHFT : LONG_SHIFT_T) return SDWORD_T;

  function shift_left32(SI : LDWORD_T;SHFT : LONG_SHIFT_T) return LDWORD_T;
  
  function shift_right32(SI : LDWORD_T;SHFT : LONG_SHIFT_T) return LDWORD_T;
  
end G729A_ASIP_ARITH_PKG;

package body G729A_ASIP_ARITH_PKG is

  function shift_left16(SI : SDWORD_T;SHFT : LONG_SHIFT_T) return SDWORD_T is
    variable SO : SDWORD_T;
  begin
    case SHFT is
      when  0 => SO := shift_left(SI, 0);
      when  1 => SO := shift_left(SI, 1);
      when  2 => SO := shift_left(SI, 2);
      when  3 => SO := shift_left(SI, 3);
      when  4 => SO := shift_left(SI, 4);
      when  5 => SO := shift_left(SI, 5);
      when  6 => SO := shift_left(SI, 6);
      when  7 => SO := shift_left(SI, 7);
      when  8 => SO := shift_left(SI, 8);
      when  9 => SO := shift_left(SI, 9);
      when 10 => SO := shift_left(SI,10);
      when 11 => SO := shift_left(SI,11);
      when 12 => SO := shift_left(SI,12);
      when 13 => SO := shift_left(SI,13);
      when 14 => SO := shift_left(SI,14);
      when others => SO := shift_left(SI,15);
    end case;
    return(SO);
  end function;

  function shift_right16(SI : SDWORD_T;SHFT : LONG_SHIFT_T) return SDWORD_T is
    variable SO : SDWORD_T;
  begin
    case SHFT is
      when  0 => SO := shift_right(SI, 0);
      when  1 => SO := shift_right(SI, 1);
      when  2 => SO := shift_right(SI, 2);
      when  3 => SO := shift_right(SI, 3);
      when  4 => SO := shift_right(SI, 4);
      when  5 => SO := shift_right(SI, 5);
      when  6 => SO := shift_right(SI, 6);
      when  7 => SO := shift_right(SI, 7);
      when  8 => SO := shift_right(SI, 8);
      when  9 => SO := shift_right(SI, 9);
      when 10 => SO := shift_right(SI,10);
      when 11 => SO := shift_right(SI,11);
      when 12 => SO := shift_right(SI,12);
      when 13 => SO := shift_right(SI,13);
      when 14 => SO := shift_right(SI,14);
      when others => SO := shift_right(SI,15);
    end case;
    return(SO);
  end function;

  function shift_left32(SI : LDWORD_T;SHFT : LONG_SHIFT_T) return LDWORD_T is
    variable SO : LDWORD_T;
  begin
    case SHFT is
      when  0 => SO := shift_left(SI, 0);
      when  1 => SO := shift_left(SI, 1);
      when  2 => SO := shift_left(SI, 2);
      when  3 => SO := shift_left(SI, 3);
      when  4 => SO := shift_left(SI, 4);
      when  5 => SO := shift_left(SI, 5);
      when  6 => SO := shift_left(SI, 6);
      when  7 => SO := shift_left(SI, 7);
      when  8 => SO := shift_left(SI, 8);
      when  9 => SO := shift_left(SI, 9);
      when 10 => SO := shift_left(SI,10);
      when 11 => SO := shift_left(SI,11);
      when 12 => SO := shift_left(SI,12);
      when 13 => SO := shift_left(SI,13);
      when 14 => SO := shift_left(SI,14);
      when 15 => SO := shift_left(SI,15);
      when 16 => SO := shift_left(SI,16);
      when 17 => SO := shift_left(SI,17);
      when 18 => SO := shift_left(SI,18);
      when 19 => SO := shift_left(SI,19);
      when 20 => SO := shift_left(SI,20);
      when 21 => SO := shift_left(SI,21);
      when 22 => SO := shift_left(SI,22);
      when 23 => SO := shift_left(SI,23);
      when 24 => SO := shift_left(SI,24);
      when 25 => SO := shift_left(SI,25);
      when 26 => SO := shift_left(SI,26);
      when 27 => SO := shift_left(SI,27);
      when 28 => SO := shift_left(SI,28);
      when 29 => SO := shift_left(SI,29);
      when 30 => SO := shift_left(SI,30);
      when others => SO := shift_left(SI,31);
    end case;
    return(SO);
  end function;

  function shift_right32(SI : LDWORD_T;SHFT : LONG_SHIFT_T) return LDWORD_T is
    variable SO : LDWORD_T;
  begin
    case SHFT is
      when  0 => SO := shift_right(SI, 0);
      when  1 => SO := shift_right(SI, 1);
      when  2 => SO := shift_right(SI, 2);
      when  3 => SO := shift_right(SI, 3);
      when  4 => SO := shift_right(SI, 4);
      when  5 => SO := shift_right(SI, 5);
      when  6 => SO := shift_right(SI, 6);
      when  7 => SO := shift_right(SI, 7);
      when  8 => SO := shift_right(SI, 8);
      when  9 => SO := shift_right(SI, 9);
      when 10 => SO := shift_right(SI,10);
      when 11 => SO := shift_right(SI,11);
      when 12 => SO := shift_right(SI,12);
      when 13 => SO := shift_right(SI,13);
      when 14 => SO := shift_right(SI,14);
      when 15 => SO := shift_right(SI,15);
      when 16 => SO := shift_right(SI,16);
      when 17 => SO := shift_right(SI,17);
      when 18 => SO := shift_right(SI,18);
      when 19 => SO := shift_right(SI,19);
      when 20 => SO := shift_right(SI,20);
      when 21 => SO := shift_right(SI,21);
      when 22 => SO := shift_right(SI,22);
      when 23 => SO := shift_right(SI,23);
      when 24 => SO := shift_right(SI,24);
      when 25 => SO := shift_right(SI,25);
      when 26 => SO := shift_right(SI,26);
      when 27 => SO := shift_right(SI,27);
      when 28 => SO := shift_right(SI,28);
      when 29 => SO := shift_right(SI,29);
      when 30 => SO := shift_right(SI,30);
      when others => SO := shift_right(SI,31);
    end case;
    return(SO);
  end function;

end G729A_ASIP_ARITH_PKG;