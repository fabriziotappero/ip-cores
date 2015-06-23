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

  subtype OPCODE_T is std_logic_vector(OPCODE_WIDTH-1 downto 0);
  subtype COND_T is std_logic_vector(COND_WIDTH-1 downto 0);


  -- RISE OPCODES --
  -- load opcodes
  constant OPCODE_LD_IMM        : OPCODE_T := CONST_OPCODE_LD_IMM;
  constant OPCODE_LD_IMM_HB     : OPCODE_T := CONST_OPCODE_LD_IMM_HB;
  constant OPCODE_LD_DISP       : OPCODE_T := CONST_OPCODE_LD_DISP;
  constant OPCODE_LD_DISP_MS    : OPCODE_T := CONST_OPCODE_LD_DISP_MS;
  constant OPCODE_LD_REG        : OPCODE_T := CONST_OPCODE_LD_REG;

  -- store opcodes
  constant OPCODE_ST_DISP       : OPCODE_T := CONST_OPCODE_ST_DISP;
  
  -- arithmethic opcodes
  constant OPCODE_ADD           : OPCODE_T := CONST_OPCODE_ADD;
  constant OPCODE_ADD_IMM       : OPCODE_T := CONST_OPCODE_ADD_IMM;
  constant OPCODE_SUB           : OPCODE_T := CONST_OPCODE_SUB;
  constant OPCODE_SUB_IMM       : OPCODE_T := CONST_OPCODE_SUB_IMM;
  constant OPCODE_NEG           : OPCODE_T := CONST_OPCODE_NEG;
  constant OPCODE_ARS           : OPCODE_T := CONST_OPCODE_ARS;
  constant OPCODE_ALS           : OPCODE_T := CONST_OPCODE_ALS;

  -- logical opcodes
  constant OPCODE_AND : OPCODE_T := CONST_OPCODE_AND;
  constant OPCODE_NOT : OPCODE_T := CONST_OPCODE_NOT;
  constant OPCODE_EOR : OPCODE_T := CONST_OPCODE_EOR;
  constant OPCODE_LS :  OPCODE_T := CONST_OPCODE_LS;
  constant OPCODE_RS :  OPCODE_T := CONST_OPCODE_RS;
  
  -- program control
  constant OPCODE_JMP : OPCODE_T := CONST_OPCODE_JMP;

  -- other
  constant OPCODE_TST : OPCODE_T := CONST_OPCODE_TST;
  constant OPCODE_NOP : OPCODE_T := CONST_OPCODE_NOP;
  
  -- CONDITION CODES --
  constant COND_UNCONDITIONAL   : COND_T := CONST_COND_UNCONDITIONAL;
  constant COND_NOT_ZERO        : COND_T := CONST_COND_NOT_ZERO; 
  constant COND_ZERO            : COND_T := CONST_COND_ZERO;
  constant COND_CARRY           : COND_T := CONST_COND_CARRY;
  constant COND_NEGATIVE        : COND_T := CONST_COND_NEGATIVE;
  constant COND_OVERFLOW        : COND_T := CONST_COND_OVERFLOW;
  constant COND_ZERO_NEGATIVE   : COND_T := CONST_COND_ZERO_NEGATIVE;

  function svector2opcode (v : std_logic_vector) return OPCODE_T;
  function svector2cond (v : std_logic_vector) return COND_T;
  
end RISE_PACK_SPECIFIC;

package body RISE_PACK_SPECIFIC is

-- purpose: converts std_logic_vector to enum type
  function svector2opcode (v : std_logic_vector) return OPCODE_T is
    variable v_tmp : CONST_OPCODE_T;
  begin  -- svector2opcode
    v_tmp := v;
    return v_tmp;
  end svector2opcode;

-- purpose: converts std_logic_vector to enum type
  function svector2cond (v : std_logic_vector) return COND_T is
    variable v_tmp : CONST_COND_T;
  begin  -- svector2cond
    v_tmp := v;
    return v_tmp;
  end svector2cond;

end RISE_PACK_SPECIFIC;


