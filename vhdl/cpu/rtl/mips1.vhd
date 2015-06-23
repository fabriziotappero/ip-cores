--------------------------------------------------------------------------------
-- MIPS™ I CPU - Instruction Set                                              --
--------------------------------------------------------------------------------
-- Type definitions of the MIPS™ I instruction (sub-)set and some convenience --
-- functions to convert binary operation representations to symbolic          --
-- equivalents.                                                               --
--                                                                            --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mips1 is

   -----------------------------------------------------------------------------
   -- OP Codes                                                                --
   -----------------------------------------------------------------------------
   type op_t is (
      AD,    -- Operations with AluOp
      RI,    -- Additional Branches
      J,     -- Jump
      JAL,   -- Jump And Link to $ra
      BEQ,   -- Branch On Equal
      BNE,   -- Branch On Not Equal
      BLEZ,  -- Branch Less Equal Zero
      BGTZ,  -- Branch Greater Than Zero
      ADDI,  -- Add Immediate
      ADDIU, -- Add Immediate Unsigned
      SLTI,  -- SLT Immediate
      SLTIU, -- SLT Immediate Unsigned
      ANDI,  -- And Immediate
      ORI,   -- Or Immediate
      XORI,  -- Xor Immediate
      LUI,   -- Load Upper Immediate
      LB,    -- Load Byte
      LH,    -- Load Half Word
      LW,    -- Load Word
      LBU,   -- Load Byte Unsigned
      LHU,   -- Load Half Word Unsigned
      SB,    -- Store Byte
      SH,    -- Store Half Word
      SW,    -- Store Word
      CP0,   -- Co-Processor 0 Operations
      ERR    -- Unknown OP
   );

   function op(i : std_logic_vector) return op_t;

   -----------------------------------------------------------------------------
   -- ALU OP Codes                                                            --
   -----------------------------------------------------------------------------
   -- In this implementation of the MIPS™ I instruction set, ADD, ADDU and    --
   -- SUB, SUBU cause indentical behaviour. This means that ADDU and SUBU do  --
   -- NOT trap on overflow.                                                   --
   -----------------------------------------------------------------------------
   type alu_op_t is (
      ADD,   -- Addition
      ADDU,  -- Add Unsigned
      SUB,   -- Subtraction
      SUBU,  -- Subtract Unsigned
      AND0,  -- Logic and
      OR0,   -- Logic or
      NOR0,  -- Logic nor
      XOR0,  -- Logic xor
      SLT,   -- Set On Less Than
      SLTU,  -- SLT Unsigned
      SLL0,  -- Shift Left Logical
      SLLV,  -- SLL Variable
      SRA0,  -- Shift Right Arith
      SRAV,  -- SRA Variable
      SRL0,  -- Shift Right Logical
      SRLV,  -- SRL Variable
      JALR,  -- Jump And Link Reg
      JR,    -- Jump Reg
      MFCP0, -- Move From Co-Processor 0
      MTCP0, -- Move To Co-Processor 0
      RFE,   -- Restore From Exception
      ERR    -- Unknown ALU OP
   );

   -- Convert ALU Op bit pattern into its symbolic representation.
   function aluop(i : std_logic_vector) return alu_op_t;

   -----------------------------------------------------------------------------
   -- REGIMM Codes                                                            --
   -----------------------------------------------------------------------------
   type rimm_op_t is (
      BGEZ,   -- Branch Greater Equal 0
      BGEZAL, -- BGEZ And Link
      BLTZ,   -- Branch Less Than 0
      BLTZAL, -- BLTZ And Link
      ERR     -- Unknown RIMM OP
   );

   -- Convert Reg Immediate Op bit pattern into its symbolic representation.
   function rimmop(i : std_logic_vector) return rimm_op_t;

   -----------------------------------------------------------------------------
   -- CP0 Codes                                                               --
   -----------------------------------------------------------------------------
   type cp0_op_t is (
      MFCP0, -- Move From Co-Processor 0
      MTCP0, -- Move To Co-Processor 0
      RFE,   -- Restore From Exception
      ERR    -- Unknown CP0 OP
   );

   type cp0_reg_t is (
      SR,    -- Status Register
      CAUSE, -- Cause Register
      EPC,   -- EPC
      ERR    -- Unknown CP0 REG
   );

   -- Convert CP0 Op and Reg Addresses bit patterns into its symbolic
   -- representation.
   function cp0op(i : std_logic_vector) return cp0_op_t;
   function cp0reg(i : std_logic_vector) return cp0_reg_t;

end mips1;

package body mips1 is

   function op(i : std_logic_vector) return op_t is
   begin
      case i(31 downto 26) is
         when "000000" => return AD;    -- Operations with AluOp
         when "000001" => return RI;    -- Additional Branches
         when "000010" => return J;     -- Jump
         when "000011" => return JAL;   -- Jump And Link to $ra
         when "000100" => return BEQ;   -- Branch On Equal
         when "000101" => return BNE;   -- Branch On Not Equal
         when "000110" => return BLEZ;  -- Branch Less Equal Zero
         when "000111" => return BGTZ;  -- Branch Greater Than Zero
         when "001000" => return ADDI;  -- Add Immediate
         when "001001" => return ADDIU; -- Add Immediate Unsigned
         when "001010" => return SLTI;  -- SLT Immediate
         when "001011" => return SLTIU; -- SLT Immediate Unsigned
         when "001100" => return ANDI;  -- And Immediate
         when "001101" => return ORI;   -- Or Immediate
         when "001110" => return XORI;  -- Xor Immediate
         when "001111" => return LUI;   -- Load Upper Immediate
         when "100000" => return LB;    -- Load Byte
         when "100001" => return LH;    -- Load Half Word
         when "100011" => return LW;    -- Load Word
         when "100100" => return LBU;   -- Load Byte Unsigned
         when "100101" => return LHU;   -- Load Half Word Unsigned
         when "101000" => return SB;    -- Store Byte
         when "101001" => return SH;    -- Store Half Word
         when "101011" => return SW;    -- Store Word
         when "010000" => return CP0;   -- Co-Processor 0 Operations
         when others   => return ERR;   -- Unknown OP
      end case;
   end op;

   function aluop(i : std_logic_vector) return alu_op_t is
   begin
      case i(5 downto 0) is
         when "100000" => return ADD;  -- Addition
         when "100001" => return ADDU; -- Add Unsigned
         when "100010" => return SUB;  -- Subtract
         when "100011" => return SUBU; -- Subtract Unsigned
         when "100100" => return AND0; -- Logic and
         when "100101" => return OR0;  -- Logic or
         when "100111" => return NOR0; -- Logic nor
         when "100110" => return XOR0; -- Logic xor
         when "101010" => return SLT;  -- Set On Less Than
         when "101011" => return SLTU; -- SLT Unsigned
         when "000000" => return SLL0; -- Shift Left Logical
         when "000100" => return SLLV; -- SLL Variable
         when "000011" => return SRA0; -- Shift Right Arith
         when "000111" => return SRAV; -- SRA Variable
         when "000010" => return SRL0; -- Shift Right Logical
         when "000110" => return SRLV; -- SRL Variable
         when "001001" => return JALR; -- Jump And Link Reg
         when "001000" => return JR;   -- Jump Reg
         when others   => return ERR;  -- Unknown ALU OP
      end case;
   end aluop;

   function rimmop(i : std_logic_vector) return rimm_op_t is
   begin
      case i(20 downto 16) is
      when "00001" => return BGEZ;   -- Branch Greater Equal 0
      when "10001" => return BGEZAL; -- BGEZ And Link
      when "00000" => return BLTZ;   -- Branch Less Than 0
      when "10000" => return BLTZAL; -- BLTZ And Link
      when others  => return ERR;    -- Unknown RIMM OP
      end case;
   end rimmop;

   function cp0op(i : std_logic_vector) return cp0_op_t is
   begin
      case i(25 downto 21) is
      when "00000" => return MFCP0; -- Move From Co-Processor 0
      when "00100" => return MTCP0; -- Move To Co-Processor 0
      when "10000" => return RFE;   -- Restore From Exception
      when others  => return ERR;   -- Unknown CP0 OP
      end case;
   end cp0op;

   function cp0reg(i : std_logic_vector) return cp0_reg_t is
   begin
      case i(4 downto 0) is
      when "01100" => return SR;    -- Status Register
      when "01101" => return CAUSE; -- Cause Register
      when "01110" => return EPC;   -- EPC
      when others  => return ERR;   -- Unknown CP0 REG
      end case;
   end cp0reg;

end mips1;