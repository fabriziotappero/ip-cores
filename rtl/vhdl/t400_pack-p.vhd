-------------------------------------------------------------------------------
--
-- $Id: t400_pack-p.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package t400_pack is

  -- Byte ---------------------------------------------------------------------
  subtype byte_t     is std_logic_vector(7 downto 0);

  -- Data word ----------------------------------------------------------------
  subtype dw_t       is std_logic_vector(3 downto 0);

  -- Misc ranges --------------------------------------------------------------
  subtype dw_range_t is natural range dw_t'range;
  subtype b_range_t  is natural range 5 downto 0;
  subtype br_range_t is natural range 5 downto 4;
  subtype bd_range_t is natural range 3 downto 0;

  -- B address ----------------------------------------------------------------
  subtype b_t        is std_logic_vector(b_range_t);
  subtype br_t       is std_logic_vector(br_range_t);
  subtype bd_t       is std_logic_vector(bd_range_t);


  -- Program counter ----------------------------------------------------------
  subtype pc_t       is unsigned(9 downto 0);

  -- Data memory address vector -----------------------------------------------
  subtype dm_addr_t  is std_logic_vector(5 downto 0);

  -- Decoder data -------------------------------------------------------------
  subtype dec_data_t is std_logic_vector(pc_t'range);

  -- Program counter operations -----------------------------------------------
  type    pc_op_t    is (PC_NONE,
                         PC_INC_PC,
                         PC_LOAD_6, PC_LOAD_7, PC_LOAD_8, PC_LOAD,
                         PC_POP,
                         PC_LOAD_A_M,
                         PC_INT);

  -- Data memory controller operations ----------------------------------------
  type    dmem_op_t  is (DMEM_RB,
                         DMEM_WB_SRC_Q, DMEM_WB_SRC_DEC, DMEM_WB_SRC_A,
                         DMEM_RDEC,
                         DMEM_WB_SET_BIT, DMEM_WB_RES_BIT,
                         DMEM_WDEC_SRC_A);
  type    b_op_t     is (B_NONE,
                         B_SET_BD, B_SET_BR,
                         B_SET_B, B_SET_B_INC,
                         B_XOR_BR,
                         B_INC_BD,
                         B_DEC_BD);

  -- Stack operations ---------------------------------------------------------
  type    stack_op_t is (STACK_NONE,
                         STACK_PUSH,
                         STACK_POP);

  -- ALU operations -----------------------------------------------------------
  type    alu_op_t   is (ALU_NONE,
                         ALU_CLRA,
                         ALU_LOAD_M,
                         ALU_LOAD_Q, ALU_LOAD_G, ALU_LOAD_IN, ALU_LOAD_IL,
                         ALU_LOAD_BR, ALU_LOAD_BD,
                         ALU_LOAD_SIO,
                         ALU_ADD, ALU_ADD_10, ALU_ADD_C, ALU_ADD_DEC,
                         ALU_COMP,
                         ALU_RC, ALU_SC,
                         ALU_XOR);

  -- Skip operations ----------------------------------------------------------
  type    skip_op_t  is (SKIP_NONE,
                         SKIP_UPDATE,
                         SKIP_NOW,
                         SKIP_CARRY, SKIP_C,
                         SKIP_BD_UFLOW, SKIP_BD_OFLOW,
                         SKIP_LBI,
                         SKIP_A_M,
                         SKIP_G_ZERO, SKIP_G_BIT,
                         SKIP_M_BIT,
                         SKIP_TIMER,
                         SKIP_PUSH, SKIP_POP);

  -- IO L port operations -----------------------------------------------------
  type    io_l_op_t  is (IOL_NONE,
                         IOL_LOAD_AM, IOL_LOAD_PM,
                         IOL_OUTPUT_L,
                         IOL_OUTPUT_Q);

  -- IO D port operations -----------------------------------------------------
  type    io_d_op_t  is (IOD_NONE,
                         IOD_LOAD);

  -- IO G port operations -----------------------------------------------------
  type    io_g_op_t  is (IOG_NONE,
                         IOG_LOAD_M,
                         IOG_LOAD_DEC);

  -- IO IN port operations ----------------------------------------------------
  type    io_in_op_t is (IOIN_NONE,
                         IOIN_INIL,
                         IOIN_INTACK);

  -- SIO operations -----------------------------------------------------------
  type    sio_op_t   is (SIO_NONE,
                         SIO_LOAD);

end t400_pack;
