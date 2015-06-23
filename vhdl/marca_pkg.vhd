--  This file is part of the marca processor.
--  Copyright (C) 2007 Wolfgang Puffitsch

--  This program is free software; you can redistribute it and/or modify it
--  under the terms of the GNU Library General Public License as published
--  by the Free Software Foundation; either version 2, or (at your option)
--  any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Library General Public License for more details.

--  You should have received a copy of the GNU Library General Public
--  License along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

-------------------------------------------------------------------------------
-- Package MARCA
-------------------------------------------------------------------------------
-- global definitions for MARCA processor
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package marca_pkg is

  -----------------------------------------------------------------------------
  -- running at a whopping 20MHz
  -----------------------------------------------------------------------------
  constant CLOCK_FREQ : integer := 20000000;

  -----------------------------------------------------------------------------
  -- the reset-button is high when pressed
  -----------------------------------------------------------------------------
  constant RESET_ACTIVE : std_logic := '1';
  
  -----------------------------------------------------------------------------
  -- general constants
  -----------------------------------------------------------------------------
  constant REG_WIDTH : integer := 16;
  constant REG_WIDTH_LOG : integer := 4;

  constant REG_COUNT : integer := 16;
  constant REG_COUNT_LOG : integer := 4;

  constant VEC_COUNT : integer := 16;
  
  constant ADDR_WIDTH : integer := 13;
  constant DATA_WIDTH : integer := 8;

  constant RADDR_WIDTH : integer := 8;
  constant RDATA_WIDTH : integer := 8;
  
  constant PADDR_WIDTH : integer := 13;
  constant PDATA_WIDTH : integer := 16;

  constant OUT_BITS : integer := 2;
  constant IN_BITS : integer := 2;

  -----------------------------------------------------------------------------
  -- where to access which memory
  -----------------------------------------------------------------------------  
  constant MEM_MIN_ADDR   : std_logic_vector := "0000000000000000";
  constant MEM_MAX_ADDR   : std_logic_vector := "0001111111111111";

  constant ROM_MIN_ADDR   : std_logic_vector := "0010000000000000";
  constant ROM_MAX_ADDR   : std_logic_vector := "0010000011111111";

  -----------------------------------------------------------------------------
  -- opcodes
  -----------------------------------------------------------------------------
  constant OPC_ADD   : std_logic_vector(3 downto 0) := "0000";
  constant OPC_SUB   : std_logic_vector(3 downto 0) := "0001";
  constant OPC_ADDC  : std_logic_vector(3 downto 0) := "0010";
  constant OPC_SUBC  : std_logic_vector(3 downto 0) := "0011";
  constant OPC_AND   : std_logic_vector(3 downto 0) := "0100";
  constant OPC_OR    : std_logic_vector(3 downto 0) := "0101";
  constant OPC_XOR   : std_logic_vector(3 downto 0) := "0110";
  constant OPC_MUL   : std_logic_vector(3 downto 0) := "0111";
  constant OPC_DIV   : std_logic_vector(3 downto 0) := "1000";
  constant OPC_UDIV  : std_logic_vector(3 downto 0) := "1001";
  constant OPC_LDIL  : std_logic_vector(3 downto 0) := "1010";
  constant OPC_LDIH  : std_logic_vector(3 downto 0) := "1011";
  constant OPC_LDIB  : std_logic_vector(3 downto 0) := "1100";

  -- the following opcodes have this prefix
  constant OPC_PFX_A : std_logic_vector(3 downto 0) := "1101";
  
  constant OPC_MOV   : std_logic_vector(3 downto 0) := "0000";
  constant OPC_MOD   : std_logic_vector(3 downto 0) := "0001";
  constant OPC_UMOD  : std_logic_vector(3 downto 0) := "0010";
  constant OPC_NOT   : std_logic_vector(3 downto 0) := "0011";
  constant OPC_NEG   : std_logic_vector(3 downto 0) := "0100";
  constant OPC_CMP   : std_logic_vector(3 downto 0) := "0101";
  constant OPC_ADDI  : std_logic_vector(3 downto 0) := "0110";
  constant OPC_CMPI  : std_logic_vector(3 downto 0) := "0111";
  constant OPC_SHL   : std_logic_vector(3 downto 0) := "1000";
  constant OPC_SHR   : std_logic_vector(3 downto 0) := "1001";
  constant OPC_SAR   : std_logic_vector(3 downto 0) := "1010";
  constant OPC_ROLC  : std_logic_vector(3 downto 0) := "1011";
  constant OPC_RORC  : std_logic_vector(3 downto 0) := "1100";
  constant OPC_BSET  : std_logic_vector(3 downto 0) := "1101";
  constant OPC_BCLR  : std_logic_vector(3 downto 0) := "1110";
  constant OPC_BTEST : std_logic_vector(3 downto 0) := "1111";

  -- the following opcodes have this prefix
  constant OPC_PFX_B : std_logic_vector(3 downto 0) := "1110";
  
  constant OPC_LOAD  : std_logic_vector(3 downto 0) := "0000";
  constant OPC_STORE : std_logic_vector(3 downto 0) := "0001";
  constant OPC_LOADL : std_logic_vector(3 downto 0) := "0010";
  constant OPC_LOADH : std_logic_vector(3 downto 0) := "0011";
  constant OPC_LOADB : std_logic_vector(3 downto 0) := "0100";
  constant OPC_STOREL: std_logic_vector(3 downto 0) := "0101";
  constant OPC_STOREH: std_logic_vector(3 downto 0) := "0110";
  constant OPC_CALL  : std_logic_vector(3 downto 0) := "1000";
  
  -- the following opcodes have this prefix
  constant OPC_PFX_C : std_logic_vector(3 downto 0) := "1111";
  
  constant OPC_BR    : std_logic_vector(3 downto 0) := "0000";
  constant OPC_BRZ   : std_logic_vector(3 downto 0) := "0001";
  constant OPC_BRNZ  : std_logic_vector(3 downto 0) := "0010";
  constant OPC_BRLE  : std_logic_vector(3 downto 0) := "0011";
  constant OPC_BRLT  : std_logic_vector(3 downto 0) := "0100";
  constant OPC_BRGE  : std_logic_vector(3 downto 0) := "0101";
  constant OPC_BRGT  : std_logic_vector(3 downto 0) := "0110";
  constant OPC_BRULE : std_logic_vector(3 downto 0) := "0111";
  constant OPC_BRULT : std_logic_vector(3 downto 0) := "1000";
  constant OPC_BRUGE : std_logic_vector(3 downto 0) := "1001";
  constant OPC_BRUGT : std_logic_vector(3 downto 0) := "1010";
  constant OPC_SEXT  : std_logic_vector(3 downto 0) := "1011";
  constant OPC_LDVEC : std_logic_vector(3 downto 0) := "1100";
  constant OPC_STVEC : std_logic_vector(3 downto 0) := "1101";

  -- the following opcodes have this prefix additionally to OPC_PFX_C
  constant OPC_PFX_C1 : std_logic_vector(3 downto 0) := "1110";
  
  constant OPC_JMP   : std_logic_vector(3 downto 0):= "0000";
  constant OPC_JMPZ  : std_logic_vector(3 downto 0):= "0001";
  constant OPC_JMPNZ : std_logic_vector(3 downto 0):= "0010";
  constant OPC_JMPLE : std_logic_vector(3 downto 0):= "0011";
  constant OPC_JMPLT : std_logic_vector(3 downto 0):= "0100";
  constant OPC_JMPGE : std_logic_vector(3 downto 0):= "0101";
  constant OPC_JMPGT : std_logic_vector(3 downto 0):= "0110";
  constant OPC_JMPULE: std_logic_vector(3 downto 0):= "0111";
  constant OPC_JMPULT: std_logic_vector(3 downto 0):= "1000";
  constant OPC_JMPUGE: std_logic_vector(3 downto 0):= "1001";
  constant OPC_JMPUGT: std_logic_vector(3 downto 0):= "1010";
  constant OPC_INTR  : std_logic_vector(3 downto 0):= "1011";
  constant OPC_GETIRA: std_logic_vector(3 downto 0):= "1100";
  constant OPC_SETIRA: std_logic_vector(3 downto 0):= "1101";
  constant OPC_GETFL : std_logic_vector(3 downto 0):= "1110";
  constant OPC_SETFL : std_logic_vector(3 downto 0):= "1111";
  
  -- the following opcodes have this prefix additionally to OPC_PFX_C
  constant OPC_PFX_C2 : std_logic_vector(3 downto 0) := "1111";
  
  constant OPC_GETSHFL:std_logic_vector(3 downto 0):= "0000";
  constant OPC_SETSHFL:std_logic_vector(3 downto 0):= "0001";
  
  -- the following opcodes have this prefix additionally to OPC_PFX_C2
  constant OPC_PFX_C2a : std_logic_vector(3 downto 0) := "1111";
  
  constant OPC_RETI  : std_logic_vector(3 downto 0):= "0000";
  constant OPC_NOP   : std_logic_vector(3 downto 0):= "0001";
  constant OPC_SEI   : std_logic_vector(3 downto 0):= "0010";
  constant OPC_CLI   : std_logic_vector(3 downto 0):= "0011";
  constant OPC_ERROR : std_logic_vector(3 downto 0):= "1111";

  -----------------------------------------------------------------------------
  -- definitions for the flags register
  -----------------------------------------------------------------------------
  constant FLAG_Z : integer := 0;
  constant FLAG_C : integer := 1;
  constant FLAG_V : integer := 2;
  constant FLAG_N : integer := 3;
  constant FLAG_I : integer := 4;
  constant FLAG_P : integer := 5;

  -----------------------------------------------------------------------------
  -- definitions for the exception vectors
  -----------------------------------------------------------------------------
  constant EXC_ERR : integer := 0;
  constant EXC_ALU : integer := 1;
  constant EXC_MEM : integer := 2;

  -----------------------------------------------------------------------------
  -- which unit to be on duty
  -----------------------------------------------------------------------------
  type UNIT_SELECTOR is (UNIT_ALU, UNIT_MEM, UNIT_INTR, UNIT_CALL);
 
  -----------------------------------------------------------------------------
  -- where to write a result
  -----------------------------------------------------------------------------
  type TARGET_SELECTOR is (TARGET_NONE, TARGET_REGISTER, TARGET_PC, TARGET_BOTH);

  -----------------------------------------------------------------------------
  -- the operations of the ALU
  -----------------------------------------------------------------------------
  type ALU_OP is (ALU_ADD,
                  ALU_SUB,
                  ALU_ADDC,
                  ALU_SUBC,
                  ALU_NEG,
                  ALU_ADDI,
                  ALU_CMPI,
                  ALU_BRZ,
                  ALU_BRNZ,
                  ALU_BRLE,
                  ALU_BRLT,
                  ALU_BRGE,
                  ALU_BRGT,
                  ALU_BRULE,
                  ALU_BRULT,
                  ALU_BRUGE,
                  ALU_BRUGT,

                  ALU_MUL,
                  ALU_DIV,
                  ALU_UDIV,
                  ALU_MOD,
                  ALU_UMOD,
                  
                  ALU_AND,
                  ALU_OR,
                  ALU_XOR,
                  ALU_LDIL,
                  ALU_LDIH,
                  ALU_LDIB,
                  ALU_MOV,
                  ALU_NOT,
                  ALU_SHL,
                  ALU_SHR,
                  ALU_SAR,
                  ALU_ROLC,
                  ALU_RORC,
                  ALU_BSET,
                  ALU_BCLR,
                  ALU_BTEST,                  
                  ALU_SEXT,
                  ALU_JMP,
                  ALU_JMPZ,
                  ALU_JMPNZ,
                  ALU_JMPLE,
                  ALU_JMPLT,
                  ALU_JMPGE,
                  ALU_JMPGT,
                  ALU_JMPULE,
                  ALU_JMPULT,
                  ALU_JMPUGE,
                  ALU_JMPUGT,
                  ALU_GETFL,
                  ALU_SETFL,
                  ALU_GETSHFL,
                  ALU_SETSHFL,
                  ALU_INTR,
                  ALU_RETI,
                  ALU_SEI,
                  ALU_CLI,
                  ALU_NOP);
 
  -----------------------------------------------------------------------------
  -- the operations of the memory unit
  -----------------------------------------------------------------------------
  type MEM_OP is (MEM_LOAD,
                  MEM_LOADL,
                  MEM_LOADH,
                  MEM_LOADB,
                  MEM_STORE,
                  MEM_STOREL,
                  MEM_STOREH,
                  MEM_NOP);

  -----------------------------------------------------------------------------
  -- the operations of the interrupt unit
  -----------------------------------------------------------------------------
  type INTR_OP is (INTR_INTR,
                   INTR_RETI,
                   INTR_SETIRA,
                   INTR_GETIRA,
                   INTR_STVEC,
                   INTR_LDVEC,
                   INTR_NOP);
  
  -----------------------------------------------------------------------------
  -- more of a hack to reduce checks against zero to a large NOR
  -----------------------------------------------------------------------------
  function zero(a : std_logic_vector) return std_logic;

end marca_pkg;


package body marca_pkg is

  function zero(a : std_logic_vector)
    return std_logic is
    variable result : std_logic;
    variable i : integer;
  begin
    result := '0';
    for i in a'low to a'high loop
      result := result or a(i);
    end loop;
    return not result;
  end;

end marca_pkg;
