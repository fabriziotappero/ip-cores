-------------------------------------------------------------------------------
-- File: rise_pack.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Package for RISE project.
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use work.RISE_CONST_PACK.all;

package RISE_PACK_SPECIFIC is

  constant OPCODE_WIDTH : integer := CONST_OPCODE_WIDTH;
  constant COND_WIDTH : integer := CONST_COND_WIDTH;

  -- RISE OPCODES --
  type OPCODE_T is (OPCODE_LD_IMM, OPCODE_LD_IMM_HB, OPCODE_LD_DISP, OPCODE_LD_DISP_MS,
                    OPCODE_LD_REG, OPCODE_ST_DISP, OPCODE_ADD, OPCODE_ADD_IMM, OPCODE_SUB,
                    OPCODE_SUB_IMM, OPCODE_NEG, OPCODE_ARS, OPCODE_ALS, OPCODE_AND, OPCODE_NOT,
                    OPCODE_EOR, OPCODE_LS, OPCODE_RS, OPCODE_JMP, OPCODE_TST, OPCODE_NOP);

  -- CONDITIONALS --
  type COND_T is (COND_UNCONDITIONAL, COND_NOT_ZERO, COND_ZERO, COND_CARRY, COND_NEGATIVE,
                  COND_OVERFLOW, COND_ZERO_NEGATIVE);

  function svector2opcode (v : std_logic_vector) return OPCODE_T;
  function svector2cond (v : std_logic_vector) return COND_T;
end RISE_PACK_SPECIFIC;

package body RISE_PACK_SPECIFIC is

-- purpose: converts std_logic_vector to enum type
  function svector2opcode (v : std_logic_vector) return OPCODE_T is
    variable result : OPCODE_T;
    variable v_tmp : CONST_OPCODE_T;
  begin  -- svector2opcode
    v_tmp := v;
    case v_tmp is
      when CONST_OPCODE_LD_IMM          => result := OPCODE_LD_IMM;
      when CONST_OPCODE_LD_IMM_HB       => result := OPCODE_LD_IMM_HB;
      when CONST_OPCODE_LD_DISP         => result := OPCODE_LD_DISP;
      when CONST_OPCODE_LD_DISP_MS      => result := OPCODE_LD_DISP_MS;
      when CONST_OPCODE_LD_REG          => result := OPCODE_LD_REG;
      when CONST_OPCODE_ST_DISP         => result := OPCODE_ST_DISP;
      when CONST_OPCODE_ADD             => result := OPCODE_ADD;
      when CONST_OPCODE_ADD_IMM         => result := OPCODE_ADD_IMM;
      when CONST_OPCODE_SUB             => result := OPCODE_SUB;
      when CONST_OPCODE_SUB_IMM         => result := OPCODE_SUB_IMM;
      when CONST_OPCODE_NEG             => result := OPCODE_NEG;
      when CONST_OPCODE_ARS             => result := OPCODE_ARS;
      when CONST_OPCODE_ALS             => result := OPCODE_ALS;
      when CONST_OPCODE_AND             => result := OPCODE_AND;
      when CONST_OPCODE_NOT             => result := OPCODE_NOT;
      when CONST_OPCODE_EOR             => result := OPCODE_EOR;
      when CONST_OPCODE_LS              => result := OPCODE_LS;
      when CONST_OPCODE_RS              => result := OPCODE_RS;
      when CONST_OPCODE_JMP             => result := OPCODE_JMP;
      when CONST_OPCODE_TST             => result := OPCODE_TST;
      when CONST_OPCODE_NOP             => result := OPCODE_NOP; 
      when others                       => result := OPCODE_NOP; 
    end case;
    return result;
  end svector2opcode;

-- purpose: converts std_logic_vector to enum type
  function svector2cond (v : std_logic_vector) return COND_T is
    variable result : COND_T;
    variable v_tmp : CONST_COND_T;
  begin  -- svector2cond
    v_tmp := v;
    case v_tmp is
      when CONST_COND_UNCONDITIONAL     => result := COND_UNCONDITIONAL;
      when CONST_COND_NOT_ZERO          => result := COND_NOT_ZERO;
      when CONST_COND_ZERO              => result := COND_ZERO;
      when CONST_COND_CARRY             => result := COND_CARRY;
      when CONST_COND_NEGATIVE          => result := COND_NEGATIVE;
      when CONST_COND_OVERFLOW          => result := COND_OVERFLOW;
      when CONST_COND_ZERO_NEGATIVE     => result := COND_ZERO_NEGATIVE;
      when others                       => result := COND_UNCONDITIONAL;
    end case;
    return result;
  end svector2cond;

end RISE_PACK_SPECIFIC;

