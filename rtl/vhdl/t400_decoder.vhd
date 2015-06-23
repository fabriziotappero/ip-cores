-------------------------------------------------------------------------------
--
-- The decoder unit.
-- Implements the instruction opcodes and controls all units of the T400 core.
--
-- $Id: t400_decoder.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006 Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-- The latest version of this file can be found at:
--      http://www.opencores.org/cvsweb.shtml/t400/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t400_opt_pack.all;
use work.t400_pack.all;

entity t400_decoder is

  generic (
    opt_type_g : integer := t400_opt_type_420_c
  );
  port (
    -- System Interface -------------------------------------------------------
    ck_i       : in  std_logic;
    ck_en_i    : in  boolean;
    por_i      : in  boolean;
    res_i      : in  boolean;
    out_en_i   : in  boolean;
    in_en_i    : in  boolean;
    icyc_en_i  : in  boolean;
    -- Module Control Interface -----------------------------------------------
    pc_op_o    : out pc_op_t;
    stack_op_o : out stack_op_t;
    dmem_op_o  : out dmem_op_t;
    b_op_o     : out b_op_t;
    skip_op_o  : out skip_op_t;
    alu_op_o   : out alu_op_t;
    io_l_op_o  : out io_l_op_t;
    io_d_op_o  : out io_d_op_t;
    io_g_op_o  : out io_g_op_t;
    io_in_op_o : out io_in_op_t;
    sio_op_o   : out sio_op_t;
    dec_data_o : out dec_data_t;
    en_o       : out dw_t;
    -- Skip Interface ---------------------------------------------------------
    skip_i     : in  boolean;
    skip_lbi_i : in  boolean;
    is_lbi_o   : out boolean;
    int_i      : in  boolean;
    -- Program Memory Interface -----------------------------------------------
    pm_addr_i  : in  pc_t;
    pm_data_i  : in  byte_t
  );

end t400_decoder;


library ieee;
use ieee.numeric_std.all;

use work.t400_mnemonic_pack.all;

architecture rtl of t400_decoder is

  signal cyc_cnt_q      : unsigned(2 downto 0);
  signal ibyte1_q,
         ibyte2_q       : byte_t;

  signal opcode_s       : byte_t;
  signal second_cyc_q   : boolean;
  signal mnemonic_rec_s : mnemonic_rec_t;
  signal mnemonic_s,
         mnemonic_q     : mnemonic_t;
  signal multi_byte_s,
         multi_byte_q   : boolean;
  signal last_cycle_s   : boolean;
  signal force_mc_s     : boolean;

  signal en_q           : dw_t;
  signal set_en_s       : boolean;
  signal ack_int_s      : boolean;

begin

  -----------------------------------------------------------------------------
  -- Theory of operation:
  --
  -- a) One instruction cycle lasts at least 4 ck_i cycles.
  -- b) PC for instruction/parameter fetch must be valid during cycle 2.
  --      => cycle 2 is the opcode fetch cycle
  -- c) Cycle 3 is the opcode decode cycle.
  --      => opcode_s is valid with cycle 3
  -- d) mnemonic_q is then valid with cycle 0 until end of instruction.
  --    So is ibyte1_q.
  -- e) PC for is incremented during last instruction cycle.
  --      => fetch of either new instruction or second instruction byte
  -- f) Second instruction byte is saved in ibyte2_q for cycle 0.
  --    Valid until end of instruction.
  --
  -- Constraints:
  --
  -- a) PC of next instruction must be pushed in cycle 0 or 1.
  -- b) PC for next instruction must be poped latest in cycle 1.
  -- c) PC for next instruction can only be calculated latest in cycle 1.
  -- d) IO output is enabled by out_en_i
  -- e) IO inputs are sampled with in_en_i
  --
  -- d) and e) are required for proper timing in relation to phi1
  -- (SK clock/sync output).
  --
  -- Conventions:
  --
  -- a) ALU operations take place in cycle 1.
  --
  -----------------------------------------------------------------------------

  last_cycle_s <= (not multi_byte_q and
                   not second_cyc_q and not force_mc_s)
                  or
                  second_cyc_q;


  -----------------------------------------------------------------------------
  -- Process seq
  --
  -- Purpose:
  --   Implements the various sequential elements.
  --     Cycle counter:
  --       It identifies the execution cycle of the
  --       current instruction.
  --     Instruction registers:
  --       They save the first and second byte of an instruction for
  --       further processing.
  --     New instruction flag:
  --       Indicates when a new instruction is fetched from the program
  --       memory. Implemented as a flip-flop to control the multiplexer
  --       which saves power by gating the combinational opcode decoder.
  --     Mnemonic register:
  --       Latches the decoded mnemonic of the current instruction.
  --     Multi byte flag:
  --       Latches the decoded multi byte status information.
  --
  seq: process (ck_i, por_i)
  begin
    if por_i then
      cyc_cnt_q    <= to_unsigned(1, cyc_cnt_q'length);
      second_cyc_q <= false;
      ibyte1_q     <= (others => '0');
      ibyte2_q     <= (others => '0');
      mnemonic_q   <= MN_CLRA;
      multi_byte_q <= false;
      en_q         <= (others => '0');

    elsif ck_i'event and ck_i = '1' then
      if    res_i then
        -- synchronous reset upon external reset event
        mnemonic_q     <= MN_CLRA;
        multi_byte_q   <= false;
        cyc_cnt_q      <= (others => '0');
        en_q           <= (others => '0');

      elsif ck_en_i then
        -- cycle counter ------------------------------------------------------
        if    icyc_en_i then
          -- new instruction cycle started
          cyc_cnt_q    <= (others => '0');
        elsif cyc_cnt_q /= 4 then
          cyc_cnt_q    <= cyc_cnt_q + 1;
        end if;

        -- second cycle flag --------------------------------------------------
        if icyc_en_i then
          if not last_cycle_s then
            second_cyc_q <= true;
          else
            second_cyc_q <= false;
          end if;
        end if;

        -- instruction byte 1 and mnemonic info -------------------------------
        if icyc_en_i and last_cycle_s then
          if not ack_int_s then
            -- update instruction descriptors in normal mode
            ibyte1_q     <= pm_data_i;
            mnemonic_q   <= mnemonic_s;
            multi_byte_q <= multi_byte_s;
          else
            -- force NOP instruction when vectoring to interrupt routine
            ibyte1_q     <= "01000100";
            mnemonic_q   <= MN_NOP;
            multi_byte_q <= false;
          end if;
        end if;

        -- instruction byte 2 -------------------------------------------------
        if icyc_en_i and not last_cycle_s then
          ibyte2_q     <= pm_data_i;
        end if;

        -- EN register --------------------------------------------------------
        if    set_en_s then
          en_q         <= ibyte2_q(dw_range_t);
        elsif ack_int_s then
          -- reset interrupt enable when INT has been acknowledged
          en_q(1)      <= '0';
        end if;

      end if;
    end if;
  end process seq;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Opcode multiplexer
  -----------------------------------------------------------------------------
  opcode_s <=   pm_data_i
              when icyc_en_i else
                ibyte1_q;

  -----------------------------------------------------------------------------
  -- Opcode decoder table
  --
  mnemonic_rec_s <= decode_opcode_f(opcode   => opcode_s,
                                    opt_type => opt_type_g);
  --
  mnemonic_s   <= mnemonic_rec_s.mnemonic;
  multi_byte_s <= mnemonic_rec_s.multi_byte;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process decoder_ctrl
  --
  -- Purpose:
  --   Implements the controlling logic of the decoder module.
  --
  decoder_ctrl: process (icyc_en_i,
                         out_en_i, in_en_i,
                         cyc_cnt_q,
                         mnemonic_q, second_cyc_q, last_cycle_s,
                         ibyte1_q, ibyte2_q,
                         skip_i, skip_lbi_i,
                         en_q, int_i,
                         pm_addr_i, pm_data_i)
    variable cyc_v        : natural range 0 to 4;
    variable t41x_type_v,
             t420_type_v  : boolean;
    variable en_int_v     : boolean;
  begin
    -- default assignments
    pc_op_o     <= PC_NONE;
    stack_op_o  <= STACK_NONE;
    dmem_op_o   <= DMEM_RB;             -- default is read via B
    b_op_o      <= B_NONE;
    skip_op_o   <= SKIP_NONE;
    alu_op_o    <= ALU_NONE;
    io_l_op_o   <= IOL_NONE;
    io_d_op_o   <= IOD_NONE;
    io_g_op_o   <= IOG_NONE;
    io_in_op_o  <= IOIN_NONE;
    sio_op_o    <= SIO_NONE;
    dec_data_o  <= (others => '0');
    is_lbi_o    <= false;
    set_en_s    <= false;
    force_mc_s  <= false;
    en_int_v    := true;
    ack_int_s   <= false;
    cyc_v       := to_integer(cyc_cnt_q);
    -- determine type
    t41x_type_v := opt_type_g = t400_opt_type_410_c;
    t420_type_v := opt_type_g = t400_opt_type_420_c;

    if icyc_en_i then
      -- immediately increment program counter
      -- this happens at two occasions:
      -- a) right before new mnemonic becomes valid
      -- b) before the second instruction cycle begins
      pc_op_o   <= PC_INC_PC;
    end if;

    if icyc_en_i and last_cycle_s then
      -- update skip state when last instruction cycle ends
      skip_op_o <= SKIP_UPDATE;
    end if;

    -- skip instruction execution
    if not skip_i then
      -- implement instruction control
      case mnemonic_q is
        -- Mnemonic ASC -------------------------------------------------------
        when MN_ASC =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_ADD_C;
            skip_op_o    <= SKIP_CARRY;
          end if;

        -- Mnemonic ADD -------------------------------------------------------
        when MN_ADD =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_ADD;
          end if;

        -- Mnemonic ADT -------------------------------------------------------
        when MN_ADT =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_ADD_10;
          end if;

        -- Mnemonic AISC ------------------------------------------------------
        when MN_AISC =>
          dec_data_o(dw_range_t) <= ibyte1_q(dw_range_t);
          if cyc_v = 1 then
            alu_op_o     <= ALU_ADD_DEC;
            skip_op_o    <= SKIP_CARRY;
          end if;

        -- Mnemonic CASC ------------------------------------------------------
        when MN_CASC =>
          case cyc_v is
            when 0 =>
              alu_op_o   <= ALU_COMP;
            when 1 =>
              alu_op_o   <= ALU_ADD_C;
              skip_op_o  <= SKIP_CARRY;
            when others =>
              null;
          end case;

        -- Mnemonic CLRA ------------------------------------------------------
        when MN_CLRA =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_CLRA;
          end if;

        -- Mnemonic COMP ------------------------------------------------------
        when MN_COMP =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_COMP;
          end if;

        -- Mnemonic NOP -------------------------------------------------------
        when MN_NOP =>
          -- do nothing
          null;

        -- Mnemonic C ---------------------------------------------------------
        when MN_C =>
          if cyc_v = 1 then
            if ibyte1_q(4) = '1' then
              alu_op_o   <= ALU_RC;
            else
              alu_op_o   <= ALU_SC;
            end if;
          end if;

        -- Mnemonic XOR -------------------------------------------------------
        when MN_XOR =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_XOR;
          end if;

        -- Mnemonic JID -------------------------------------------------------
        when MN_JID =>
          force_mc_s     <= true;
          en_int_v       := false;
          dec_data_o(byte_t'range) <= pm_data_i;
          if cyc_v = 1 then
            if not second_cyc_q then
              -- first cycle: load PC from A and M
              pc_op_o    <= PC_LOAD_A_M;
            else
              -- second cycle: load PC from program memory
              pc_op_o    <= PC_LOAD_8;
            end if;
          end if;

          if icyc_en_i and not second_cyc_q then
            -- do not increment PC for second instruction cycle
            pc_op_o      <= PC_NONE;
          end if;

        -- Mnemonic JMP -------------------------------------------------------
        when MN_JMP =>
          en_int_v       := false;
          dec_data_o <= ibyte1_q(1) & ibyte1_q(0) & ibyte2_q;
          if second_cyc_q and cyc_v = 1 then
            pc_op_o      <= PC_LOAD;
          end if;

        -- Mnemonic JP_JSRP ---------------------------------------------------
        when MN_JP_JSRP =>
          en_int_v       := false;
          -- universal decoder data
          dec_data_o <= '0' & "01" & ibyte1_q(6 downto 0);
          if cyc_v = 1 then
            if    pm_addr_i(9 downto 7) = "001" then
              -- JP within pages 2 & 3
              pc_op_o    <= PC_LOAD_7;
            elsif ibyte1_q(6) = '1' then
              -- JP outside of pages 2 & 3
              pc_op_o    <= PC_LOAD_6;
            else
              -- JSRP to page 2
              pc_op_o    <= PC_LOAD;
              stack_op_o <= STACK_PUSH;
            end if;
          end if;

        -- Mnemonic JSR -------------------------------------------------------
        when MN_JSR =>
          en_int_v       := false;
          dec_data_o <= ibyte1_q(1) & ibyte1_q(0) & ibyte2_q;
          if second_cyc_q and cyc_v = 1 then
            pc_op_o      <= PC_LOAD;
            stack_op_o   <= STACK_PUSH;
          end if;

        -- Mnemonic RET -------------------------------------------------------
        when MN_RET =>
          en_int_v       := false;
          if cyc_v = 1 then
            pc_op_o      <= PC_POP;
            stack_op_o   <= STACK_POP;

            if t420_type_v then
              -- always restore skip state in case this was an interrupt
              skip_op_o  <= SKIP_POP;
            end if;
          end if;

        -- Mnemonic RETSK -----------------------------------------------------
        when MN_RETSK =>
          en_int_v       := false;
          if cyc_v = 1 then
            pc_op_o      <= PC_POP;
            stack_op_o   <= STACK_POP;
            skip_op_o    <= SKIP_NOW;
          end if;

        -- Mnemonic LD --------------------------------------------------------
        when MN_LD =>
          dec_data_o(br_range_t) <= ibyte1_q(br_range_t);
          if cyc_v = 1 then
            alu_op_o     <= ALU_LOAD_M;
            b_op_o       <= B_XOR_BR;
          end if;

        -- Mnemonic LDD_XAD ---------------------------------------------------
        when MN_LDD_XAD =>
          -- preload decoder data
          dec_data_o(b_range_t) <= ibyte2_q(b_range_t);

          if second_cyc_q then
            case ibyte2_q(7 downto 6) is
              -- LDD
              when "00" =>
                if not t41x_type_v then
                  case cyc_v is
                    when 1 =>
                      dmem_op_o <= DMEM_RDEC;
                    when 2 =>
                      alu_op_o  <= ALU_LOAD_M;
                    when others =>
                      null;
                  end case;
                end if;
                -- XAD
              when "10" =>
                if not t41x_type_v                   or
                  unsigned(ibyte2_q(b_range_t)) = 63 then
                  case cyc_v is
                    when 1 =>
                      dmem_op_o <= DMEM_RDEC;
                    when 2 =>
                      alu_op_o  <= ALU_LOAD_M;
                      dmem_op_o <= DMEM_WDEC_SRC_A;
                    when others =>
                      null;
                  end case;
                end if;

              when others =>
                null;
            end case;
          end if;

        -- Mnemonic LQID ------------------------------------------------------
        when MN_LQID =>
          force_mc_s     <= true;
          en_int_v       := false;
          if not second_cyc_q then
            -- first cycle: push PC and set PC from A/M,
            --              read IOL from program memory
            if cyc_v = 1 then
              stack_op_o <= STACK_PUSH;
              pc_op_o    <= PC_LOAD_A_M;
            end if;

            if out_en_i then
              io_l_op_o  <= IOL_LOAD_PM;
            end if;
          else
            if cyc_v = 1 then
              -- second cycle: pop PC
              stack_op_o <= STACK_POP;
              pc_op_o    <= PC_POP;
            end if;
          end if;

          if icyc_en_i and not second_cyc_q then
            -- do not increment PC for second instruction cycle
            pc_op_o      <= PC_NONE;
          end if;

        -- Mnemonic RMB -------------------------------------------------------
        when MN_RMB =>
          if cyc_v = 1 then
            dmem_op_o  <= DMEM_WB_RES_BIT;
            -- select bit to be reset
            case ibyte1_q(dw_range_t) is
              when "1100" =>
                dec_data_o(dw_range_t) <= "0001";
              when "0101" =>
                dec_data_o(dw_range_t) <= "0010";
              when "0010" =>
                dec_data_o(dw_range_t) <= "0100";
              when "0011" =>
                dec_data_o(dw_range_t) <= "1000";
              when others =>
                null;
            end case;
          end if;

        -- Mnemonic SMB -------------------------------------------------------
        when MN_SMB =>
          if cyc_v = 1 then
            dmem_op_o  <= DMEM_WB_SET_BIT;
            -- select bit to be set
            case ibyte1_q(dw_range_t) is
              when "1101" =>
                dec_data_o(dw_range_t) <= "0001";
              when "0111" =>
                dec_data_o(dw_range_t) <= "0010";
              when "0110" =>
                dec_data_o(dw_range_t) <= "0100";
              when "1011" =>
                dec_data_o(dw_range_t) <= "1000";
              when others =>
                null;
            end case;
          end if;

        -- Mnemonic STII ------------------------------------------------------
        when MN_STII =>
          dec_data_o(dw_range_t) <= ibyte1_q(dw_range_t);
          if cyc_v = 1 then
            dmem_op_o    <= DMEM_WB_SRC_DEC;
            b_op_o       <= B_INC_BD;
          end if;

        -- Mnemonic X ---------------------------------------------------------
        when MN_X =>
          dec_data_o(br_range_t) <= ibyte1_q(br_range_t);
          if cyc_v = 1 then
            alu_op_o     <= ALU_LOAD_M;
            dmem_op_o    <= DMEM_WB_SRC_A;
            b_op_o       <= B_XOR_BR;
          end if;

        -- Mnemonic XDS -------------------------------------------------------
        when MN_XDS =>
          dec_data_o(br_range_t) <= ibyte1_q(br_range_t);
          case cyc_v is
            when 1 =>
              alu_op_o   <= ALU_LOAD_M;
              dmem_op_o  <= DMEM_WB_SRC_A;
              b_op_o     <= B_DEC_BD;
            when 2 =>
              b_op_o     <= B_XOR_BR;
              skip_op_o  <= SKIP_BD_UFLOW;
            when others =>
              null;
          end case;

        -- Mnemonic XIS -------------------------------------------------------
        when MN_XIS =>
          dec_data_o(br_range_t) <= ibyte1_q(br_range_t);
          case cyc_v is
            when 1 =>
              alu_op_o   <= ALU_LOAD_M;
              dmem_op_o  <= DMEM_WB_SRC_A;
              b_op_o     <= B_INC_BD;
            when 2 =>
              b_op_o     <= B_XOR_BR;
              skip_op_o  <= SKIP_BD_OFLOW;
            when others =>
              null;
          end case;

        -- Mnemonic CAB -------------------------------------------------------
        when MN_CAB =>
          if cyc_v = 1 then
            b_op_o       <= B_SET_BD;
          end if;

        -- Mnemonic CBA -------------------------------------------------------
        when MN_CBA =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_LOAD_BD;
          end if;

        -- Mnemonic LBI -------------------------------------------------------
        when MN_LBI =>
          is_lbi_o       <= true;
          en_int_v       := false;
          dec_data_o(br_range_t) <= ibyte1_q(br_range_t);
          dec_data_o(bd_range_t) <= ibyte1_q(bd_range_t);
          if cyc_v = 1 and not skip_lbi_i then
            -- increment Bd by 1
            b_op_o       <= B_SET_B_INC;
            skip_op_o    <= SKIP_LBI;
          end if;

        -- Mnemonic XABR ------------------------------------------------------
        when MN_XABR =>
          if cyc_v = 1 then
            alu_op_o     <= ALU_LOAD_BR;
            b_op_o       <= B_SET_BR;
          end if;

        -- Mnemonic SKC -------------------------------------------------------
        when MN_SKC =>
          if cyc_v = 1 then
            skip_op_o    <= SKIP_C;
          end if;

        -- Mnemonic SKE -------------------------------------------------------
        when MN_SKE =>
          if cyc_v = 1 then
            skip_op_o    <= SKIP_A_M;
          end if;

        -- Mnemonic SKMBZ -----------------------------------------------------
        when MN_SKMBZ =>
          if cyc_v = 1 then
            skip_op_o  <= SKIP_M_BIT;
            -- select bit to be checked
            case ibyte1_q is
              when "00000001" =>
                dec_data_o(dw_range_t) <= "0001";
              when "00010001" =>
                dec_data_o(dw_range_t) <= "0010";
              when "00000011" =>
                dec_data_o(dw_range_t) <= "0100";
              when "00010011" =>
                dec_data_o(dw_range_t) <= "1000";
              when others =>
                null;
            end case;
          end if;

        -- Mnemonic SKT -------------------------------------------------------
        when MN_SKT =>
          if cyc_v = 1 then
            skip_op_o  <= SKIP_TIMER;
          end if;

        -- Mnemonic XAS -------------------------------------------------------
        when MN_XAS =>
          if out_en_i then
            sio_op_o <= SIO_LOAD;
            alu_op_o <= ALU_LOAD_SIO;
          end if;

        -- Mnemonic EXT -------------------------------------------------------
        when MN_EXT =>
          if second_cyc_q then
            case ibyte2_q is
              -- CAMQ
              when "00111100" =>
                if out_en_i then
                  io_l_op_o <= IOL_LOAD_AM;
                end if;
              -- CQMA
              when "00101100" =>
                if not t41x_type_v and in_en_i then
                  io_l_op_o <= IOL_OUTPUT_Q;
                  alu_op_o  <= ALU_LOAD_Q;
                  dmem_op_o <= DMEM_WB_SRC_Q;
                end if;
              -- SKGZ
              when "00100001" =>
                if in_en_i then
                  skip_op_o <= SKIP_G_ZERO;
                end if;
              -- SKGBZ
              when "00000001" =>
                if in_en_i then
                  skip_op_o <= SKIP_G_BIT;
                  dec_data_o(dw_range_t) <= "0001";
                end if;
              when "00010001" =>
                if in_en_i then
                  skip_op_o <= SKIP_G_BIT;
                  dec_data_o(dw_range_t) <= "0010";
                end if;
              when "00000011" =>
                if in_en_i then
                  skip_op_o <= SKIP_G_BIT;
                  dec_data_o(dw_range_t) <= "0100";
                end if;
              when "00010011" =>
                if in_en_i then
                  skip_op_o <= SKIP_G_BIT;
                  dec_data_o(dw_range_t) <= "1000";
                end if;
              -- ING
              when "00101010" =>
                if cyc_v = 1 then
                  alu_op_o  <= ALU_LOAD_G;
                end if;
              -- INL
              when "00101110" =>
                if in_en_i then
                  io_l_op_o <= IOL_OUTPUT_L;
                  alu_op_o  <= ALU_LOAD_Q;
                  dmem_op_o <= DMEM_WB_SRC_Q;
                end if;
              -- ININ
              when "00101000" =>
                if not t41x_type_v and in_en_i then
                  alu_op_o  <= ALU_LOAD_IN;
                end if;
              -- INIL
              when "00101001" =>
                if not t41x_type_v and in_en_i then
                  alu_op_o   <= ALU_LOAD_IL;
                  io_in_op_o <= IOIN_INIL;
                end if;
              -- OBD
              when "00111110" =>
                if out_en_i then
                  io_d_op_o <= IOD_LOAD;
                end if;
              -- OMG
              when "00111010" =>
                if out_en_i then
                  io_g_op_o <= IOG_LOAD_M;
                end if;
              -- multiple codes
              when others =>
                -- apply default decoder output, largest required vector
                dec_data_o(b_range_t) <= ibyte2_q(b_range_t);
                -- LBI
                if ibyte2_q(7 downto 6) = "10" and not t41x_type_v then
                  is_lbi_o    <= true;
                  en_int_v    := false;
                  if cyc_v > 0 and not skip_lbi_i then
                    b_op_o    <= B_SET_B;
                    skip_op_o <= SKIP_LBI;
                  end if;
                end if;
                -- LEI
                if ibyte2_q(7 downto 4) = "0110" and in_en_i then
                  -- dec_data_o applied by default
                  set_en_s   <= true;

                  -- acknowledge pending interrupt when EN(1) is not
                  -- enabled - will clear them until interrupts are
                  -- enabled with EN(1) = '1'
                  if en_q(1) = '0' then
                    io_in_op_o <= IOIN_INTACK;
                  end if;
                end if;
                -- OGI
                if ibyte2_q(7 downto 4) = "0101" and out_en_i and
                   not t41x_type_v then
                  -- dec_data_o applied by default
                  io_g_op_o  <= IOG_LOAD_DEC;
                end if;
            end case;
          end if;

        when others =>
          null;
      end case;
    end if;


    -- Interrupt handling -----------------------------------------------------
    if t420_type_v and
       en_q(1) = '1' and int_i and en_int_v then
      if last_cycle_s then
        if cyc_v = 1 then
          stack_op_o <= STACK_PUSH;
        end if;
        if icyc_en_i then
          ack_int_s  <= true;
          io_in_op_o <= IOIN_INTACK;
          pc_op_o    <= PC_INT;
          -- push skip state that was determined by current instruction
          -- and will be valid for the next instruction which is delayed
          -- by the interrupt
          skip_op_o  <= SKIP_PUSH;
        end if;
      end if;
    end if;

  end process decoder_ctrl;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Output mapping
  -----------------------------------------------------------------------------
  en_o <= en_q;

end rtl;
