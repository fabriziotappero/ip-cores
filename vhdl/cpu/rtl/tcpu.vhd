--------------------------------------------------------------------------------
-- MIPS™ I CPU - Type Definitions                                             --
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

library work;
use work.mips1.all;

package tcpu is

   component gpr is
      port(
         clk_i : in  std_logic;
         hld_i : in  std_logic;
         rs_a  : in  std_logic_vector(4 downto 0);
         rt_a  : in  std_logic_vector(4 downto 0);
         rd_a  : in  std_logic_vector(4 downto 0);
         rd_we : in  std_logic;
         rd_i  : in  std_logic_vector(31 downto 0);
         rs_o  : out std_logic_vector(31 downto 0);
         rt_o  : out std_logic_vector(31 downto 0)
      );
   end component;

   -----------------------------------------------------------------------------
   -- MEMORY STAGE                                                            --
   -----------------------------------------------------------------------------
   type wc_t is record
      we  : std_logic;                       -- Write back enable.
   end record;

   type me_t is record
      wc  : wc_t;                            -- Write Back Stage control.
      rd  : std_logic_vector(4 downto 0);    -- Write back register address.
      res : std_logic_vector(31 downto 0);   -- Write back data (ALU or Memory).
   end record;

   -----------------------------------------------------------------------------
   -- EXECUTION STAGE                                                         --
   -----------------------------------------------------------------------------
   type mem_ext_t is (ZERO, SIGN);
   type mem_byt_t is (NONE, BYTE, HALF, WORD);

   type jadr_t is record
      j   : unsigned(31 downto 2);           -- Jump/Branch address.
      jmp : std_logic;                       -- Jump or don't jump. That's ...
   end record;

   type mem_t is record
      we  : std_logic;                       -- Stored data write enable.
      ext : mem_ext_t;                       -- Loaded Data extension.
      byt : mem_byt_t;                       -- Data width.
   end record;

   type ret_t is (ALU, MEM);

   type mc_t is record
      src : ret_t;                           -- Either ALU or Memory result.
      mem : mem_t;                           -- Load/Store control signals.
   end record;

   type ex_t is record
      mc  : mc_t;                            -- Memory Stage control.
      wc  : wc_t;                            -- Write Back Stage control.
      rd  : std_logic_vector(4 downto 0);    -- Write back register address.
      f   : jadr_t;                          -- Jump/Branch information for IF.
      str : std_logic_vector(31 downto 0);   -- ALU source B saved to memory.
      res : std_logic_vector(31 downto 0);   -- ALU result.
   end record;

   -----------------------------------------------------------------------------
   -- DECODE STAGE                                                            --
   -----------------------------------------------------------------------------
   type jmp_op_t is (NOP, JMP, EQ, NEQ, GTZ, LTZ, GEZ, LEZ);
   type jmp_src_t is (REG, JMP, BRA);

   type jmp_t is record
      op  : jmp_op_t;                        -- Possible branching conditions.
      src : jmp_src_t;                       -- Possile jump/branch sources.
   end record;

   type alu_src_a_t is (SH_CONST, SH_16, ADD_4, REG);
   type alu_src_b_t is (ZERO, SIGN, PC, REG);

   type alu_src_t is record
      a : alu_src_a_t;                       -- Sources for input A.
      b : alu_src_b_t;                       -- Sources for input B.
   end record;

   type alu_t is record
      op  : alu_op_t;                        -- ALU Ops [Mips1.vhd]
      src : alu_src_t;                       -- ALU sources.
   end record;

   type wbr_t is (RD, RT, RA);               -- Possible write back addresses.

   type ec_t is record
      wbr : wbr_t;                           -- Write back register type.
      alu : alu_t;                           -- ALU control signals.
      jmp : jmp_t;                           -- Jump/Branch control signals.
   end record;

   type cc_t is record
      mtsr : boolean;                        -- CP0 move to SR enable.
      rfe  : boolean;                        -- Restore from exception.
   end record;

   type dc_t is record
      we  : std_logic;                       -- WB forward write enable.
   end record;

   type de_t is record
      cc  : cc_t;                            -- CP0 control.
      dc  : dc_t;                            -- Decode Stage control.
      ec  : ec_t;                            -- Execution Stage control.
      mc  : mc_t;                            -- Memory Stage control.
      wc  : wc_t;                            -- Write Back Stage control.
      --f   : jadr_t;                        -- J, JAL control signals.
      rd  : std_logic_vector(4 downto 0);    -- WB forward destination address.
      res : std_logic_vector(31 downto 0);   -- WB forward data.
      i   : std_logic_vector(25 downto 0);   -- Instruction (without OP code).
   end record;

   -----------------------------------------------------------------------------
   -- FETCH STAGE                                                             --
   -----------------------------------------------------------------------------
   type fe_t is record
      pc : unsigned(31 downto 2);            -- Program counter.
   end record;

   -----------------------------------------------------------------------------
   -- CO-PROCESSOR 0                                                          --
   -----------------------------------------------------------------------------
   type sr_t is record
      im  : std_logic_vector(7 downto 0);    -- Interrupt mask.
      iec : std_logic;                       -- IEc: Interrupt enable current.
      iep : std_logic;                       -- IEp: Interrupt enable previous.
      ieo : std_logic;                       -- IEo: Interrupt enable old.
   end record;

   type cp0_t is record
      sr  : sr_t;                            -- Status register.
      epc : unsigned(29 downto 0);           -- Exception program counter.
   end record;

end tcpu;