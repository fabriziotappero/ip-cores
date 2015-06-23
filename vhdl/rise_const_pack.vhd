-------------------------------------------------------------------------------
-- File: rise_const_pack.vhd
-- Author: Jakob Lechner, Urban Stadler, Harald Trinkl, Christian Walter
-- Created: 2006-11-29
-- Last updated: 2006-11-29

-- Description:
-- Package for RISE project.
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

package RISE_CONST_PACK is

  constant CONST_OPCODE_WIDTH : integer := 5;
  constant CONST_COND_WIDTH : integer := 3;
    
  subtype CONST_OPCODE_T is std_logic_vector(CONST_OPCODE_WIDTH-1 downto 0);
  subtype CONST_COND_T is std_logic_vector(CONST_COND_WIDTH-1 downto 0);
    
  -- RISE OPCODES --
  -- load opcodes
  constant CONST_OPCODE_LD_IMM        : CONST_OPCODE_T := "10000";
  constant CONST_OPCODE_LD_IMM_HB     : CONST_OPCODE_T := "10010";  
  constant CONST_OPCODE_LD_DISP       : CONST_OPCODE_T := "10100";
  constant CONST_OPCODE_LD_DISP_MS    : CONST_OPCODE_T := "11000";
  constant CONST_OPCODE_LD_REG        : CONST_OPCODE_T := "00001";

  -- store opcodes
  constant CONST_OPCODE_ST_DISP       : CONST_OPCODE_T := "11100";
  
  -- arithmethic opcodes
  constant CONST_OPCODE_ADD           : CONST_OPCODE_T := "00010";  
  constant CONST_OPCODE_ADD_IMM       : CONST_OPCODE_T := "00011";  
  constant CONST_OPCODE_SUB           : CONST_OPCODE_T := "00100";  
  constant CONST_OPCODE_SUB_IMM       : CONST_OPCODE_T := "00101";  
  constant CONST_OPCODE_NEG           : CONST_OPCODE_T := "00110";  
  constant CONST_OPCODE_ARS           : CONST_OPCODE_T := "00111";  
  constant CONST_OPCODE_ALS           : CONST_OPCODE_T := "01000";

  -- logical opcodes
  constant CONST_OPCODE_AND : CONST_OPCODE_T := "01001";
  constant CONST_OPCODE_NOT : CONST_OPCODE_T := "01010";
  constant CONST_OPCODE_EOR : CONST_OPCODE_T := "01011";
  constant CONST_OPCODE_LS :  CONST_OPCODE_T := "01100";
  constant CONST_OPCODE_RS :  CONST_OPCODE_T := "01101";
  
  -- program control
  constant CONST_OPCODE_JMP : CONST_OPCODE_T := "01110";

  -- other
  constant CONST_OPCODE_TST : CONST_OPCODE_T := "01111";
  constant CONST_OPCODE_NOP : CONST_OPCODE_T := "00000";

  -- CONDITION CODES --
  constant CONST_COND_UNCONDITIONAL   : CONST_COND_T := "000";
  constant CONST_COND_NOT_ZERO        : CONST_COND_T := "001";
  constant CONST_COND_ZERO            : CONST_COND_T := "010";
  constant CONST_COND_CARRY           : CONST_COND_T := "011";
  constant CONST_COND_NEGATIVE        : CONST_COND_T := "100";
  constant CONST_COND_OVERFLOW        : CONST_COND_T := "101";
  constant CONST_COND_ZERO_NEGATIVE   : CONST_COND_T := "110";

end RISE_CONST_PACK;

