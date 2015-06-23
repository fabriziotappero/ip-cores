-------------------------------------------------------------------------------
--
-- The Decoder unit.
-- It decodes the instruction opcodes and executes them.
--
-- $Id: decoder.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
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
--      http://www.opencores.org/cvsweb.shtml/t48/
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t48_pack.word_t;
use work.t48_pack.mstate_t;
use work.t48_alu_pack.alu_op_t;
use work.t48_cond_branch_pack.all;
use work.t48_dmem_ctrl_pack.all;
use work.t48_pmem_ctrl_pack.all;

entity t48_decoder is

  generic (
    -- store mnemonic in flip-flops (registered-out)
    register_mnemonic_g   : integer := 1
  );

  port (
    -- Global Interface -------------------------------------------------------
    clk_i                  : in  std_logic;
    res_i                  : in  std_logic;
    en_clk_i               : in  boolean;
    xtal_i                 : in  std_logic;
    xtal_en_i              : in  boolean;
    ea_i                   : in  std_logic;
    ale_i                  : in  boolean;
    int_n_i                : in  std_logic;
    t0_dir_o               : out std_logic;
    -- T48 Bus Interface ------------------------------------------------------
    data_i                 : in  word_t;
    data_o                 : out word_t;
    alu_write_accu_o       : out boolean;
    alu_write_shadow_o     : out boolean;
    alu_write_temp_reg_o   : out boolean;
    alu_read_alu_o         : out boolean;
    bus_write_bus_o        : out boolean;
    bus_read_bus_o         : out boolean;
    dm_write_dmem_addr_o   : out boolean;
    dm_write_dmem_o        : out boolean;
    dm_read_dmem_o         : out boolean;
    p1_write_p1_o          : out boolean;
    p1_read_p1_o           : out boolean;
    p2_write_p2_o          : out boolean;
    p2_write_exp_o         : out boolean;
    p2_read_p2_o           : out boolean;
    p2_read_exp_o          : out boolean;
    pm_write_pcl_o         : out boolean;
    pm_read_pcl_o          : out boolean;
    pm_write_pch_o         : out boolean;
    pm_read_pch_o          : out boolean;
    pm_read_pmem_o         : out boolean;
    psw_read_psw_o         : out boolean;
    psw_read_sp_o          : out boolean;
    psw_write_psw_o        : out boolean;
    psw_write_sp_o         : out boolean;
    -- ALU Interface ----------------------------------------------------------
    alu_carry_i            : in  std_logic;
    alu_op_o               : out alu_op_t;
    alu_use_carry_o        : out boolean;
    alu_da_high_o          : out boolean;
    alu_accu_low_o         : out boolean;
    alu_p06_temp_reg_o     : out boolean;
    alu_p60_temp_reg_o     : out boolean;
    alu_da_overflow_i      : in  boolean;
    -- BUS Interface ----------------------------------------------------------
    bus_output_pcl_o       : out boolean;
    bus_bidir_bus_o        : out boolean;
    -- Clock Controller Interface ---------------------------------------------
    clk_multi_cycle_o      : out boolean;
    clk_assert_psen_o      : out boolean;
    clk_assert_prog_o      : out boolean;
    clk_assert_rd_o        : out boolean;
    clk_assert_wr_o        : out boolean;
    clk_mstate_i           : in  mstate_t;
    clk_second_cycle_i     : in  boolean;
    -- Conditional Branch Logic Interface -------------------------------------
    cnd_compute_take_o     : out boolean;
    cnd_branch_cond_o      : out branch_conditions_t;
    cnd_take_branch_i      : in  boolean;
    cnd_comp_value_o       : out comp_value_t;
    cnd_f1_o               : out std_logic;
    cnd_tf_o               : out std_logic;
    -- Data Memory Controller Interface ---------------------------------------
    dm_addr_type_o         : out dmem_addr_ident_t;
    -- Port 1 Interface -------------------------------------------------------
    p1_read_reg_o          : out boolean;
    -- Port 2 Interface -------------------------------------------------------
    p2_read_reg_o          : out boolean;
    p2_output_pch_o        : out boolean;
    -- Program Memory Controller Interface ------------------------------------
    pm_inc_pc_o            : out boolean;
    pm_write_pmem_addr_o   : out boolean;
    pm_addr_type_o         : out pmem_addr_ident_t;
    -- Program Status Word Interface ------------------------------------------
    psw_special_data_o     : out std_logic;
    psw_carry_i            : in  std_logic;
    psw_aux_carry_i        : in  std_logic;
    psw_f0_i               : in  std_logic;
    psw_inc_stackp_o       : out boolean;
    psw_dec_stackp_o       : out boolean;
    psw_write_carry_o      : out boolean;
    psw_write_aux_carry_o  : out boolean;
    psw_write_f0_o         : out boolean;
    psw_write_bs_o         : out boolean;
    -- Timer Interface --------------------------------------------------------
    tim_read_timer_o       : out boolean;
    tim_write_timer_o      : out boolean;
    tim_start_t_o          : out boolean;
    tim_start_cnt_o        : out boolean;
    tim_stop_tcnt_o        : out boolean;
    tim_overflow_i         : in  boolean
  );

end t48_decoder;


use work.t48_pack.all;
use work.t48_alu_pack.all;
use work.t48_decoder_pack.all;

use work.t48_comp_pack.t48_int;

-- pragma translate_off
use work.t48_tb_pack.tb_istrobe_s;
-- pragma translate_on

architecture rtl of t48_decoder is

  -- Enable fixing a bug of Quartus II 4.0
  constant enable_quartus_bugfix_c : boolean := true;

  -- Opcode Decoder
  signal opc_multi_cycle_s : boolean;
  signal opc_read_bus_s    : boolean;
  signal opc_inj_int_s     : boolean;
  signal opc_opcode_q      : word_t;
  signal opc_mnemonic_s    : mnemonic_t;
  signal last_cycle_s      : boolean;

  -- state translators
  signal assert_psen_s     : boolean;

  -- branch taken handshake
  signal branch_taken_s,
         branch_taken_q        : boolean;
  signal pm_inc_pc_s           : boolean;
  signal pm_write_pmem_addr_s  : boolean;
  -- additional signal to increment PC during CALL
  signal add_inc_pc_s          : boolean;
  -- addtional signal to set PC during RET(R)
  signal add_write_pmem_addr_s : boolean;

  -- Flag 1
  signal clear_f1_s,
         cpl_f1_s           : boolean;
  signal f1_q               : std_logic;
  -- memory bank select
  signal clear_mb_s,
         set_mb_s           : boolean;
  signal mb_q               : std_logic;

  -- T0 direction selection
  signal ent0_clk_s         : boolean;
  signal t0_dir_q           : std_logic;

  signal data_s             : word_t;
  signal read_dec_s         : boolean;

  signal tf_s               : std_logic;

  signal bus_read_bus_s     : boolean;
  signal add_read_bus_s     : boolean;

  signal dm_write_dmem_s    : boolean;

  signal p2_output_exp_s    : boolean;

  signal movx_first_cycle_s : boolean;

  -- interrupt handling
  signal jtf_executed_s     : boolean;
  signal en_tcnti_s         : boolean;
  signal dis_tcnti_s        : boolean;
  signal en_i_s             : boolean;
  signal dis_i_s            : boolean;
  signal tim_int_s          : boolean;
  signal retr_executed_s    : boolean;
  signal int_executed_s     : boolean;
  signal int_pending_s      : boolean;
  signal int_in_progress_s  : boolean;

  -- the mnemonic
  signal mnemonic_rec_s     : mnemonic_rec_t;
  signal mnemonic_q         : mnemonic_t;

  -- pragma translate_off
  signal istrobe_res_q      : std_logic;
  signal istrobe_q          : std_logic;
  signal injected_int_q     : std_logic;
  -- pragma translate_on

begin

  -- pragma translate_off

  -- Register Mnemonic --------------------------------------------------------
  assert (register_mnemonic_g = 1) or (register_mnemonic_g = 0)
    report "register_mnemonic_g must be either 1 or 0!"
    severity failure;

  -- pragma translate_on


  -----------------------------------------------------------------------------
  -- Opcode Decoder
  --
  mnemonic_rec_s <= decode_opcode_f(opcode => opc_opcode_q);
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process opc_regs
  --
  -- Purpose:
  --   Implements the opcode and mnemonic registers.
  --
  opc_regs: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      opc_opcode_q <= (others => '0');      -- NOP
      mnemonic_q   <= MN_NOP;

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        if opc_read_bus_s then
          opc_opcode_q <= data_i;
        elsif opc_inj_int_s then
          opc_opcode_q <= "00010100";
        else
          mnemonic_q <= mnemonic_rec_s.mnemonic;
        end if;

      end if;

    end if;

  end process opc_regs;
  --
  opc_multi_cycle_s <= mnemonic_rec_s.multi_cycle;
  opc_mnemonic_s    <=   mnemonic_q
                       when register_mnemonic_g = 1 else
                         mnemonic_rec_s.mnemonic;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Interrupt Controller.
  -----------------------------------------------------------------------------
  int_b : t48_int
    port map (
      clk_i             => clk_i,
      res_i             => res_i,
      en_clk_i          => en_clk_i,
      xtal_i            => xtal_i,
      xtal_en_i         => xtal_en_i,
      clk_mstate_i      => clk_mstate_i,
      jtf_executed_i    => jtf_executed_s,
      tim_overflow_i    => tim_overflow_i,
      tf_o              => tf_s,
      en_tcnti_i        => en_tcnti_s,
      dis_tcnti_i       => dis_tcnti_s,
      int_n_i           => int_n_i,
      ale_i             => ale_i,
      last_cycle_i      => last_cycle_s,
      en_i_i            => en_i_s,
      dis_i_i           => dis_i_s,
      ext_int_o         => open,
      tim_int_o         => tim_int_s,
      retr_executed_i   => retr_executed_s,
      int_executed_i    => int_executed_s,
      int_pending_o     => int_pending_s,
      int_in_progress_o => int_in_progress_s
    );

  last_cycle_s <= not opc_multi_cycle_s or
                  (opc_multi_cycle_s and clk_second_cycle_i);

  -----------------------------------------------------------------------------
  -- Process machine_cycle
  --
  -- Purpose:
  --   Generates the control signals that are basically needed for the
  --   handling of a machine cycle.
  --
  machine_cycle: process (clk_mstate_i,
                          clk_second_cycle_i,
                          last_cycle_s,
                          ea_i,
                          assert_psen_s,
                          branch_taken_q,
                          int_pending_s,
                          p2_output_exp_s,
                          movx_first_cycle_s)

   variable need_address_v      : boolean;

  begin
    -- default assignments
    clk_assert_psen_o    <= false;
    pm_inc_pc_s          <= false;
    pm_write_pmem_addr_s <= false;
    pm_read_pmem_o       <= false;
    bus_output_pcl_o     <= false;
    p2_output_pch_o      <= false;
    opc_read_bus_s       <= false;
    opc_inj_int_s        <= false;
    bus_read_bus_s       <= false;

    need_address_v    := not clk_second_cycle_i or
                         (clk_second_cycle_i and assert_psen_s);

    case clk_mstate_i is
      when MSTATE1 =>
        if need_address_v then
          if ea_i = '0' then
            if not int_pending_s then
              pm_read_pmem_o <= true;
            end if;

          else
            if not int_pending_s then
              bus_read_bus_s <= true;
            end if;
            p2_output_pch_o  <= true;
          end if;

        end if;

        if not clk_second_cycle_i then
          if not int_pending_s then
            opc_read_bus_s  <= true;
          else
            opc_inj_int_s   <= true;    -- inject interrupt call
          end if;
        end if;

      when MSTATE2 =>
        if need_address_v and not branch_taken_q and
           not int_pending_s then
          pm_inc_pc_s       <= true;
        end if;

      when MSTATE3 =>
        if need_address_v then
          -- Theory of operation:
          -- Program Memory address is updated at end of State 3 (or end of
          -- State 2 in case of a RET). Address information is thus available
          -- latest with State 4.
          -- This is the time where we need information about access target
          -- (internal or external = EA). EA information needs to be stable
          -- until end of State 1.
          pm_write_pmem_addr_s <= true;
        end if;

      when MSTATE4 =>
        if ea_i = '1' and
           ((not clk_second_cycle_i and assert_psen_s)
            or last_cycle_s) then
          clk_assert_psen_o <= true;
          p2_output_pch_o   <= true;
          bus_output_pcl_o  <= true;
        end if;

      when MSTATE5 =>
        if ea_i = '1' and
           (need_address_v or last_cycle_s) and
           -- Suppress output of PCH when either
           -- a) expander port is driven on P2, has priority
           not p2_output_exp_s and
           -- b) first cycle of MOVX, don't disturb external access
           not movx_first_cycle_s then
          p2_output_pch_o   <= true;
        end if;

      when others =>
        -- pragma translate_off
        assert false
          report "Unkown machine state!"
          severity error;
        -- pragma translate_on

    end case;

  end process machine_cycle;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process decode
  --
  -- Purpose:
  --   Indentifies each single instruction and steps through the related
  --   execution sequence.
  --
  decode: process (alu_carry_i,
                   psw_aux_carry_i,
                   alu_da_overflow_i,
                   clk_mstate_i,
                   clk_second_cycle_i,
                   cnd_take_branch_i,
                   opc_opcode_q,
                   opc_mnemonic_s,
                   psw_carry_i,
                   psw_f0_i,
                   f1_q,
                   mb_q,
                   tim_int_s,
                   int_pending_s,
                   int_in_progress_s)

    procedure address_indirect_3_f is
    begin
      -- apply dmem address from selected register for indirect mode
      if opc_opcode_q(3) = '0' or enable_quartus_bugfix_c then
        dm_read_dmem_o       <= true;
        dm_write_dmem_addr_o <= true;
        dm_addr_type_o       <= DM_PLAIN;
      end if;
    end;

    procedure and_or_xor_add_4_f is
    begin
      -- write dmem contents to Temp Reg
      dm_read_dmem_o         <= true;
      alu_write_temp_reg_o   <= true;
    end;

    procedure and_or_xor_add_5_f (alu_op : alu_op_t) is
    begin
      -- perform ALU operation and store in Accumulator
      alu_op_o               <= alu_op;
      alu_read_alu_o         <= true;
      alu_write_accu_o       <= true;
    end;

    procedure cond_jump_c2_m1_f is
    begin
      -- store address in Program Counter low byte if branch has to
      -- be taken
--      if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
        pm_write_pcl_o       <= true;
        branch_taken_s       <= true;
--      end if;
    end;

    -- intermediate value of the Program Memory Bank Flag
    variable mb_v : std_logic;

  begin
    -- default assignments
    data_s                 <= (others => '-');
    read_dec_s             <= false;
    branch_taken_s         <= false;
    clear_f1_s             <= false;
    cpl_f1_s               <= false;
    clear_mb_s             <= false;
    set_mb_s               <= false;
    add_inc_pc_s           <= false;
    assert_psen_s          <= false;
    alu_write_accu_o       <= false;
    alu_write_shadow_o     <= false;
    alu_write_temp_reg_o   <= false;
    alu_p06_temp_reg_o     <= false;
    alu_p60_temp_reg_o     <= false;
    alu_read_alu_o         <= false;
    bus_write_bus_o        <= false;
    bus_bidir_bus_o        <= false;
    dm_write_dmem_addr_o   <= false;
    dm_write_dmem_s        <= false;
    dm_read_dmem_o         <= false;
    pm_write_pcl_o         <= false;
    pm_read_pcl_o          <= false;
    pm_write_pch_o         <= false;
    pm_read_pch_o          <= false;
    pm_addr_type_o         <= PM_PC;
    psw_read_psw_o         <= false;
    psw_read_sp_o          <= false;
    psw_write_psw_o        <= false;
    psw_write_sp_o         <= false;
    alu_op_o               <= ALU_NOP;
    alu_use_carry_o        <= false;
    alu_da_high_o          <= false;
    alu_accu_low_o         <= false;
    clk_assert_prog_o      <= false;
    clk_assert_rd_o        <= false;
    clk_assert_wr_o        <= false;
    cnd_branch_cond_o      <= COND_ON_BIT;
    cnd_compute_take_o     <= false;
    cnd_comp_value_o       <= opc_opcode_q(7 downto 5);
    dm_addr_type_o         <= DM_REG;
    tim_read_timer_o       <= false;
    tim_write_timer_o      <= false;
    tim_start_t_o          <= false;
    tim_start_cnt_o        <= false;
    tim_stop_tcnt_o        <= false;
    p1_write_p1_o          <= false;
    p1_read_p1_o           <= false;
    p1_read_reg_o          <= false;
    p2_write_p2_o          <= false;
    p2_write_exp_o         <= false;
    p2_read_p2_o           <= false;
    p2_read_reg_o          <= false;
    p2_read_exp_o          <= false;
    p2_output_exp_s        <= false;
    psw_special_data_o     <= '0';
    psw_inc_stackp_o       <= false;
    psw_dec_stackp_o       <= false;
    psw_write_carry_o      <= false;
    psw_write_aux_carry_o  <= false;
    psw_write_f0_o         <= false;
    psw_write_bs_o         <= false;
    jtf_executed_s         <= false;
    en_tcnti_s             <= false;
    dis_tcnti_s            <= false;
    en_i_s                 <= false;
    dis_i_s                <= false;
    retr_executed_s        <= false;
    int_executed_s         <= false;
    add_write_pmem_addr_s  <= false;
    ent0_clk_s             <= false;
    add_read_bus_s         <= false;
    movx_first_cycle_s     <= false;

    -- the Program Memory Bank Flag is held low when interrupts are in progress
    -- according to the MCS-48 User's Manual
    if int_in_progress_s then
      mb_v := '0';
    else
      mb_v := mb_q;
    end if;

    -- prepare potential register indirect address mode
    if not clk_second_cycle_i and clk_mstate_i = MSTATE2 then
      data_s               <= (others => '0');
      if opc_opcode_q(3) = '1' then
        data_s(2 downto 0) <= opc_opcode_q(2 downto 0);
      else
        data_s(2 downto 0) <= "00" & opc_opcode_q(0);
      end if;

      read_dec_s           <= true;
      dm_write_dmem_addr_o <= true;
      dm_addr_type_o       <= DM_REG;
    end if;

    case opc_mnemonic_s is

      -- Mnemonic ADD ---------------------------------------------------------
      when MN_ADD =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          -- store data from RAM to Temp Reg
          when MSTATE4 =>
            and_or_xor_add_4_f;

          -- perform ADD and store in Accumulator
          when MSTATE5 =>
            and_or_xor_add_5_f(alu_op => ALU_ADD);

            if opc_opcode_q(4) = '1' then
              alu_use_carry_o     <= true;
            end if;

            psw_special_data_o    <= alu_carry_i;
            psw_write_carry_o     <= true;
            psw_write_aux_carry_o <= true;

          when others =>
            null;

        end case;

      -- Mnemonic ADD_A_DATA --------------------------------------------------
      when MN_ADD_A_DATA =>
        assert_psen_s               <= true;

        if clk_second_cycle_i then
          case clk_mstate_i is
            -- write Temp Reg when contents of Program Memory is on bus
            when MSTATE1 =>
              alu_write_temp_reg_o  <= true;

            -- perform ADD and store in Accumulator
            when MSTATE3 =>
              and_or_xor_add_5_f(alu_op => ALU_ADD);

              if opc_opcode_q(4) = '1' then
                alu_use_carry_o     <= true;
              end if;

              psw_special_data_o    <= alu_carry_i;
              psw_write_carry_o     <= true;
              psw_write_aux_carry_o <= true;

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic ANL ---------------------------------------------------------
      when MN_ANL =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          -- store data from RAM to Temp Reg
          when MSTATE4 =>
            and_or_xor_add_4_f;

          -- perform AND and store in Accumulator
          when MSTATE5 =>
            and_or_xor_add_5_f(alu_op => ALU_AND);

          when others =>
            null;

        end case;

      -- Mnemonic ANL_A_DATA --------------------------------------------------
      when MN_ANL_A_DATA =>
        assert_psen_s              <= true;

        if clk_second_cycle_i then
          case clk_mstate_i is
            -- write Temp Reg when contents of Program Memory is on bus
            when MSTATE1 =>
              alu_write_temp_reg_o <= true;

            -- perform AND and store in Accumulator
            when MSTATE3 =>
              and_or_xor_add_5_f(alu_op => ALU_AND);

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic ANL_EXT -----------------------------------------------------
      when MN_ANL_EXT =>
        assert_psen_s            <= true;

        if not clk_second_cycle_i then
          -- read port to Temp Reg
          if clk_mstate_i = MSTATE5 then
            if opc_opcode_q(1 downto 0) = "00" then
              add_read_bus_s     <= true;
            elsif opc_opcode_q(1) = '0' then
              p1_read_p1_o       <= true;
              p1_read_reg_o      <= true;
            else
              p2_read_p2_o       <= true;
              p2_read_reg_o      <= true;
            end if;

            alu_write_temp_reg_o <= true;
          end if;

        else
          case clk_mstate_i is
            -- write shadow Accumulator when contents of Program Memory is
            -- on bus
            when MSTATE1 =>
              alu_write_shadow_o <= true;

            -- loop shadow Accumulator through ALU to prevent update from
            -- real Accumulator
            when MSTATE2 =>
              alu_read_alu_o     <= true;
              alu_write_shadow_o <= true;

            -- write result of AND operation back to port
            when MSTATE3 =>
              alu_op_o           <= ALU_AND;
              alu_read_alu_o     <= true;

              if opc_opcode_q(1 downto 0) = "00" then
                bus_write_bus_o  <= true;
              elsif opc_opcode_q(1) = '0' then
                p1_write_p1_o    <= true;
              else
                p2_write_p2_o    <= true;
              end if;

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic CALL --------------------------------------------------------
      when MN_CALL =>
        assert_psen_s              <= true;

        if not clk_second_cycle_i then
          case clk_mstate_i is
            -- read Stack Pointer and address Data Memory for low byte
            -- also increment Program Counter to point to next instruction
            when MSTATE3 =>
              psw_read_sp_o        <= true;
              dm_write_dmem_addr_o <= true;
              dm_addr_type_o       <= DM_STACK;

              -- only increment PC if this is not an injected CALL
              -- injected CALLS are not located in Program Memory,
              -- the PC points already to the instruction to be executed
              -- after the interrupt
              if not int_pending_s then
                add_inc_pc_s       <= true;
              end if;

            -- store Program Counter low byte on stack
            when MSTATE4 =>
              pm_read_pcl_o        <= true;
              dm_write_dmem_s      <= true;

            -- store Program Counter high byte and PSW on stack
            -- increment Stack pointer
            when MSTATE5 => 
              psw_read_psw_o       <= true;
              pm_read_pch_o        <= true;
              dm_write_dmem_addr_o <= true;
              dm_addr_type_o       <= DM_STACK_HIGH;
              dm_write_dmem_s      <= true;
              psw_inc_stackp_o     <= true;

            when others =>
              null;

          end case;

        else
          case clk_mstate_i is
            -- store address in Program Counter low byte
            when MSTATE1 =>
              pm_write_pcl_o       <= true;
              branch_taken_s       <= true;
              if int_pending_s then
                -- apply low part of vector address manually
                data_s             <= (others => '0');
                data_s(1 downto 0) <= "11";
                if tim_int_s then
                  data_s(2)        <= '1';
                end if;
                read_dec_s         <= true;
              end if;

            when MSTATE2 =>
              pm_write_pch_o       <= true;
              read_dec_s           <= true;
              if not int_pending_s then
                -- store high part of target address in Program Counter
                data_s             <= "0000" & mb_v & opc_opcode_q(7 downto 5);
              else
                -- apply high part of vector address manually
                data_s             <= (others => '0');
                int_executed_s     <= true;
              end if;

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic CLR_A -------------------------------------------------------
      when MN_CLR_A =>
        -- write CLR output of ALU to Accumulator
        if clk_mstate_i = MSTATE3 then
          alu_op_o         <= ALU_CLR;
          alu_read_alu_o   <= true;
          alu_write_accu_o <= true;
        end if;

      -- Mnemonic CLR_C -------------------------------------------------------
      when MN_CLR_C =>
        -- store 0 to Carry
        if clk_mstate_i = MSTATE3 then
          psw_special_data_o <= '0';
          psw_write_carry_o  <= true;
        end if;

      -- Mnemonic CLR_F -------------------------------------------------------
      when MN_CLR_F =>
        -- store 0 to selected flag
        if clk_mstate_i = MSTATE3 then
          if opc_opcode_q(5) = '0' then
            psw_special_data_o <= '0';
            psw_write_f0_o     <= true;
          else
            clear_f1_s         <= true;
          end if;

        end if;

      -- Mnemonic CPL_A -------------------------------------------------------
      when MN_CPL_A =>
        -- write CPL output of ALU to Accumulator
        if clk_mstate_i = MSTATE3 then
          alu_op_o         <= ALU_CPL;
          alu_read_alu_o   <= true;
          alu_write_accu_o <= true;
        end if;

      -- Mnemnonic CPL_C ------------------------------------------------------
      when MN_CPL_C =>
        -- write inverse of Carry to PSW
        if clk_mstate_i = MSTATE3 then
          psw_special_data_o <= not psw_carry_i;
          psw_write_carry_o  <= true;
        end if;

      -- Mnemonic CPL_F -------------------------------------------------------
      when MN_CPL_f =>
        -- write inverse of selected flag back to flag
        if clk_mstate_i = MSTATE3 then
          if opc_opcode_q(5) = '0' then
            psw_special_data_o <= not psw_f0_i;
            psw_write_f0_o     <= true;
          else
            cpl_f1_s           <= true;
          end if;

        end if;

      -- Mnemonic DA ----------------------------------------------------------
      when MN_DA =>
        alu_op_o                 <= ALU_ADD;

        case clk_mstate_i is
          -- Step 1: Preload Temp Reg with 0x06
          when MSTATE3 =>
            alu_p06_temp_reg_o   <= true;

          -- Step 2: Check Auxiliary Carry and overflow on low nibble
          --         Add 0x06 to shadow Accumulator if one is true
          when MSTATE4 =>
            if psw_aux_carry_i = '1' or alu_da_overflow_i then
              alu_read_alu_o     <= true;
              alu_write_shadow_o <= true;
            end if;

            -- preload Temp Reg with 0x60
            alu_p60_temp_reg_o  <= true;

          -- Step 3: Check overflow on high nibble
          --         Add 0x60 to shadow Accumulator if true and store result
          --         in Accumulator and PSW (only Carry)
          when MSTATE5 =>
            alu_da_high_o        <= true;

            if alu_da_overflow_i then
              psw_special_data_o <= alu_carry_i;
            else
              alu_op_o           <= ALU_NOP;
              psw_special_data_o <= '0';
            end if;
            alu_read_alu_o       <= true;
            alu_write_accu_o     <= true;
            psw_write_carry_o    <= true;

          when others =>
            null;

        end case;

      -- Mnemonic DEC ---------------------------------------------------------
      when MN_DEC =>
        case clk_mstate_i is
          when MSTATE4 =>
            -- DEC Rr: store data from RAM to shadow Accumulator
            if opc_opcode_q(6) = '1' then
              dm_read_dmem_o         <= true;
              alu_write_shadow_o     <= true;
            end if;

          when MSTATE5 =>
            alu_op_o                 <= ALU_DEC;
            alu_read_alu_o           <= true;

            if opc_opcode_q(6) = '0' then
              -- write DEC of Accumulator to Accumulator
              alu_write_accu_o       <= true;
            else
              -- store DEC of shadow Accumulator back to dmem
              dm_write_dmem_s        <= true;
            end if;

          when others =>
            null;

        end case;

      -- Mnemonic DIS_EN_I ----------------------------------------------------
      when MN_DIS_EN_I =>
        if clk_mstate_i = MSTATE3 then
          if opc_opcode_q(4) = '1' then
            dis_i_s <= true;
          else
            en_i_s  <= true;
          end if;
        end if;

      -- Mnemonic DIS_EN_TCNTI ------------------------------------------------
      when MN_DIS_EN_TCNTI =>
        if clk_mstate_i = MSTATE3 then
          if opc_opcode_q(4) = '1' then
            dis_tcnti_s <= true;
          else
            en_tcnti_s  <= true;
          end if;
        end if;

      -- Mnemonic DJNZ --------------------------------------------------------
      when MN_DJNZ =>
        assert_psen_s              <= true;

        if not clk_second_cycle_i then
          case clk_mstate_i is
            -- store data from RAM to shadow Accumulator
            when MSTATE4 =>
              dm_read_dmem_o         <= true;
              alu_write_shadow_o     <= true;

            -- write DEC result of shadow Accumulator back to dmem and
            -- conditional branch logic
            when MSTATE5 =>
              alu_op_o               <= ALU_DEC;
              alu_read_alu_o         <= true;
              dm_write_dmem_s        <= true;

              cnd_compute_take_o     <= true;
              cnd_branch_cond_o      <= COND_Z;
              cnd_comp_value_o(0)    <= '0';

            when others =>
              null;

          end case;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;

      -- Mnemonic ENT0_CLK ----------------------------------------------------
      when MN_ENT0_CLK =>
        if clk_mstate_i = MSTATE3 then
          ent0_clk_s <= true;
        end if;

      -- Mnemonic IN ----------------------------------------------------------
      when MN_IN =>
        -- read Port and store in Accumulator
        if clk_second_cycle_i and clk_mstate_i = MSTATE2 then
          alu_write_accu_o <= true;

          if opc_opcode_q(1) = '0' then
            p1_read_p1_o   <= true;
          else
            p2_read_p2_o   <= true;
          end if;
        end if;

      -- Mnemonic INS ---------------------------------------------------------
      when MN_INS =>
        clk_assert_rd_o  <= true;

        -- read BUS and store in Accumulator
        if clk_second_cycle_i and clk_mstate_i = MSTATE2 then
          alu_write_accu_o <= true;

          add_read_bus_s   <= true;
        end if;

      -- Mnemonic INC ---------------------------------------------------------
      when MN_INC =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          when MSTATE4 =>
            -- INC Rr; INC @ Rr: store data from RAM to shadow Accumulator
            if opc_opcode_q(3 downto 2) /= "01" then
              dm_read_dmem_o         <= true;
              alu_write_shadow_o     <= true;
            end if;

          when MSTATE5 =>
            alu_op_o                 <= ALU_INC;
            alu_read_alu_o           <= true;

            if opc_opcode_q(3 downto 2) = "01" then
              -- write INC output of ALU to Accumulator
              alu_write_accu_o       <= true;
            else
              -- store INC of shadow Accumulator back to dmem
              dm_write_dmem_s        <= true;
            end if;

          when others =>
            null;

        end case;

      -- Mnemonic JBB ---------------------------------------------------------
      when MN_JBB =>
        assert_psen_s          <= true;
        cnd_branch_cond_o      <= COND_ON_BIT;

        if not clk_second_cycle_i then
          -- read Accumulator and start branch calculation
          if clk_mstate_i = MSTATE3 then
            alu_read_alu_o     <= true;
            cnd_compute_take_o <= true;
            -- cnd_comp_value_o is ok by default assignment
          end if;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;

      -- Mnemonic JC ----------------------------------------------------------
      when MN_JC =>
        assert_psen_s           <= true;
        cnd_branch_cond_o       <= COND_C;

        if not clk_second_cycle_i then
          -- start branch calculation
          if clk_mstate_i = MSTATE3 then
            cnd_compute_take_o  <= true;
            cnd_comp_value_o(0) <= opc_opcode_q(4);
          end if;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;

      -- Mnemonic JF ----------------------------------------------------------
      when MN_JF =>
        assert_psen_s           <= true;

        if not clk_second_cycle_i then
          -- start branch calculation
          if clk_mstate_i = MSTATE3 then
            cnd_compute_take_o  <= true;
            if opc_opcode_q(7) = '1' then
              -- JF0
              cnd_branch_cond_o <= COND_F0;
            else
              -- JF1
              cnd_branch_cond_o <= COND_F1;
            end if;

          end if;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;


      -- Mnemonic JMP ---------------------------------------------------------
      when MN_JMP =>
        assert_psen_s        <= true;

        if clk_second_cycle_i then
          case clk_mstate_i is
            -- store address in Program Counter low byte
            when MSTATE1 =>
              pm_write_pcl_o <= true;
              branch_taken_s <= true;

            -- store high part of target address in Program Counter
            when MSTATE2 =>
              data_s         <= "0000" & mb_v & opc_opcode_q(7 downto 5);
              read_dec_s     <= true;
              pm_write_pch_o <= true;

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic JMPP --------------------------------------------------------
      when MN_JMPP =>
        assert_psen_s    <= true;

        if not clk_second_cycle_i then
          -- write Accumulator to Program Memory address
          -- (skip page offset update from Program Counter)
          if clk_mstate_i = MSTATE3 then
            alu_read_alu_o <= true;
            pm_addr_type_o <= PM_PAGE;
          end if;

        else
          if clk_mstate_i = MSTATE1 then
            -- store address in Program Counter low byte
            pm_write_pcl_o <= true;
            branch_taken_s <= true;
          end if;

        end if;

      -- Mnemonic JNI ---------------------------------------------------------
      when MN_JNI =>
        assert_psen_s          <= true;
        cnd_branch_cond_o      <= COND_INT;

        if not clk_second_cycle_i then
          -- start branch calculation
          if clk_mstate_i = MSTATE3 then
            cnd_compute_take_o <= true;
          end if;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;

      -- Mnemonic JT ----------------------------------------------------------
      when MN_JT =>
        assert_psen_s           <= true;
        if opc_opcode_q(6) = '0' then
          cnd_branch_cond_o     <= COND_T0;
        else
          cnd_branch_cond_o     <= COND_T1;
        end if;

        if not clk_second_cycle_i then
          -- start branch calculation
          if clk_mstate_i = MSTATE3 then
            cnd_compute_take_o  <= true;
            cnd_comp_value_o(0) <= opc_opcode_q(4);
          end if;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;

      -- Mnemonic JTF ---------------------------------------------------------
      when MN_JTF =>
        assert_psen_s          <= true;
        cnd_branch_cond_o      <= COND_TF;

        if not clk_second_cycle_i then
          -- start branch calculation
          if clk_mstate_i = MSTATE3 then
            cnd_compute_take_o <= true;
            jtf_executed_s     <= true;
          end if;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;

      -- Mnemonic JZ ----------------------------------------------------------
      when MN_JZ =>
        assert_psen_s           <= true;
        cnd_branch_cond_o       <= COND_Z;

        if not clk_second_cycle_i then
          -- read Accumulator and start branch calculation
          if clk_mstate_i = MSTATE3 then
            alu_read_alu_o      <= true;
            cnd_compute_take_o  <= true;
            cnd_comp_value_o(0) <= opc_opcode_q(6);
          end if;

        else
          -- store address in Program Counter low byte if branch has to
          -- be taken
          if clk_mstate_i = MSTATE1 and cnd_take_branch_i then
            cond_jump_c2_m1_f;
          end if;

        end if;

      -- Mnemonic MOV_A_DATA --------------------------------------------------
      when MN_MOV_A_DATA =>
        assert_psen_s      <= true;

        -- Write Accumulator when contents of Program Memory is on bus
        -- during machine state 1 of second cycle.
        if clk_second_cycle_i and clk_mstate_i = MSTATE1 then
          alu_write_accu_o <= true;
        end if;

      -- Mnemonic MOV_A_RR ----------------------------------------------------
      when MN_MOV_A_RR =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          -- read data from RAM and store in Accumulator
          when MSTATE4 =>
            and_or_xor_add_4_f;
            alu_write_accu_o <= true;

          when others =>
            null;

        end case;

      -- Mnemonic MOV_A_PSW ---------------------------------------------------
      when MN_MOV_A_PSW =>
        if clk_mstate_i = MSTATE3 then
          psw_read_psw_o   <= true;
          psw_read_sp_o    <= true;
          alu_write_accu_o <= true;
        end if;

      -- Mnemoniv MOV_PSW_A ---------------------------------------------------
      when MN_MOV_PSW_A =>
        if clk_mstate_i = MSTATE3 then
          alu_read_alu_o  <= true;
          psw_write_psw_o <= true;
          psw_write_sp_o  <= true;
        end if;

      -- Mnemonic MOV_RR ------------------------------------------------------
      when MN_MOV_RR =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          -- write Accumulator to dmem
          when MSTATE5 =>
            alu_read_alu_o       <= true;
            dm_write_dmem_s      <= true;

          when others =>
            null;

        end case;

      -- Mnemonic MOV_RR_DATA -------------------------------------------------
      when MN_MOV_RR_DATA =>
        assert_psen_s     <= true;

        -- read RAM once for indirect address mode
        if not clk_second_cycle_i and clk_mstate_i = MSTATE3 then
          if not enable_quartus_bugfix_c or
             opc_opcode_q(3) = '0' then
            address_indirect_3_f;
          end if;
        end if;

        -- Write Data Memory when contents of Program Memory is on bus
        -- during machine state 1 of second cycle.
        if clk_second_cycle_i and clk_mstate_i = MSTATE1 then
          dm_write_dmem_s <= true;
        end if;

      -- Mnemonic MOV_T -------------------------------------------------------
      when MN_MOV_T =>
        if clk_mstate_i = MSTATE3 then
          if opc_opcode_q(5) = '1' then
            alu_read_alu_o    <= true;  -- MOV T, A
            tim_write_timer_o <= true;
          else
            tim_read_timer_o  <= true;  -- MOV A, T
            alu_write_accu_o  <= true;
          end if;
        end if;

      -- Mnemonic OUTD_PP_A ---------------------------------------------------
      when MN_OUTD_PP_A =>
        clk_assert_prog_o     <= true;

        if not clk_second_cycle_i then
          case clk_mstate_i is
            -- propagate expander port number to Port 2
            when MSTATE3 =>

              data_s(7 downto 4)     <= (others => '0');
              data_s(1 downto 0)     <= opc_opcode_q(1 downto 0);
              -- decide which 8243 command to use
              case opc_opcode_q(7 downto 4) is
                when "1001" =>
                  data_s(3 downto 2) <= "11";  -- ANLD command
                when "1000" =>
                  data_s(3 downto 2) <= "10";  -- ORLD command
                when "0011" =>
                  data_s(3 downto 2) <= "01";  -- MOVD command
                when others =>
                  null;
              end case;
                                  
              read_dec_s      <= true;
              p2_write_exp_o  <= true;

            -- output expander port number on Port 2 while active edge of PROG
            -- write Accumulator to expander port
            when MSTATE4 =>
              p2_output_exp_s <= true;

              alu_read_alu_o  <= true;
              p2_write_exp_o  <= true;

            when MSTATE5 =>
              p2_output_exp_s <= true;

            when others =>
              null;

          end case;

        else
          -- hold expander port until inactive edge of PROG 
          if clk_mstate_i = MSTATE1 or clk_mstate_i = MSTATE2 then
            p2_output_exp_s   <= true;
          end if;

        end if;

      -- Mnemonic MOVD_A_PP ---------------------------------------------------
      when MN_MOVD_A_PP =>
        clk_assert_prog_o            <= true;

        if not clk_second_cycle_i then
          case clk_mstate_i is
            -- propagate expander port number to Port 2
            when MSTATE3 =>
              data_s                 <= "0000" &
                                        "00"   &  -- 8243 command: read
                                        opc_opcode_q(1 downto 0);
              read_dec_s             <= true;
              p2_write_exp_o         <= true;

            -- output expander port number on Port 2 while active edge of PROG
            -- write 1's to expander port to set lower nibble of Port 2 to input
            when MSTATE4 =>
              p2_output_exp_s        <= true;

              data_s(nibble_t'range) <= (others => '1');
              read_dec_s             <= true;
              p2_write_exp_o         <= true;

            when MSTATE5 =>
              p2_output_exp_s        <= true;

            when others =>
              null;

          end case;

        else
          case clk_mstate_i is
            -- hold expander port until inactive edge of PROG
            when MSTATE1 =>
              p2_output_exp_s  <= true;

            -- hold expander port until inactive edge of PROG
            -- write Accumulator with nibble of expander port
            when MSTATE2 =>
              p2_read_p2_o     <= true;
              p2_output_exp_s  <= true;
              p2_read_exp_o    <= true;
              alu_write_accu_o <= true;

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic MOVP --------------------------------------------------------
      when MN_MOVP =>
        assert_psen_s        <= true;

        if not clk_second_cycle_i then
          -- write Accumulator to Program Memory address
          -- (skip page offset update from Program Counter)
          if clk_mstate_i = MSTATE3 then
            alu_read_alu_o   <= true;
            if opc_opcode_q(6) = '0' then
              pm_addr_type_o <= PM_PAGE;
            else
              pm_addr_type_o <= PM_PAGE3;
            end if;
          end if;

        else
          if clk_mstate_i = MSTATE1 then
            -- store data from Program Memory in Accumulator
            alu_write_accu_o <= true;
            -- trick & treat to prevent additional PC increment
            -- our branch target is the previously incremented PC!
            branch_taken_s   <= true;
          end if;

        end if;

      -- Mnemonic MOVX --------------------------------------------------------
      when MN_MOVX =>
        bus_bidir_bus_o        <= true;

        if opc_opcode_q(4) = '0' then
          clk_assert_rd_o      <= true;
        else
          clk_assert_wr_o      <= true;
        end if;

        if not clk_second_cycle_i then
          movx_first_cycle_s     <= true;
          case clk_mstate_i is
            -- read dmem and put contents on BUS as external address
            when MSTATE3 =>
              dm_read_dmem_o     <= true;
              bus_write_bus_o    <= true;

            -- store contents of Accumulator to BUS
            when MSTATE5 =>
              if opc_opcode_q(4) = '1' then
                alu_read_alu_o   <= true;
                bus_write_bus_o  <= true;
              end if;

            when others =>
              null;
          end case;
    
        else
          if clk_mstate_i = MSTATE2 then
            if opc_opcode_q(4) = '0' then
              -- store contents of BUS in Accumulator
              add_read_bus_s   <= true;
              alu_write_accu_o <= true;
            else
              -- store contents of Accumulator to BUS
              -- to this to keep bus in output direction
              alu_read_alu_o   <= true;
              bus_write_bus_o  <= true;
            end if;
          end if;

        end if;

      -- Mnemonic NOP ---------------------------------------------------------
      when MN_NOP =>
        -- nothing to do

      -- Mnemonic ORL ---------------------------------------------------------
      when MN_ORL =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          -- store data from RAM to Temp Reg
          when MSTATE4 =>
            and_or_xor_add_4_f;

          -- perform OR and store in Accumulator
          when MSTATE5 =>
            and_or_xor_add_5_f(alu_op => ALU_OR);

          when others =>
            null;

        end case;

      -- Mnemonic ORL_A_DATA --------------------------------------------------
      when MN_ORL_A_DATA =>
        assert_psen_s              <= true;

        if clk_second_cycle_i then
          case clk_mstate_i is
            -- write Temp Reg when contents of Program Memory is on bus
            when MSTATE1 =>
              alu_write_temp_reg_o <= true;

            -- perform OR and store in Accumulator
            when MSTATE3 =>
              and_or_xor_add_5_f(alu_op => ALU_OR);

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic ORL_EXT -----------------------------------------------------
      when MN_ORL_EXT =>
        assert_psen_s            <= true;

        if not clk_second_cycle_i then
          -- read port to Temp Reg
          if clk_mstate_i = MSTATE5 then
            if opc_opcode_q(1 downto 0) = "00" then
              add_read_bus_s     <= true;
            elsif opc_opcode_q(1) = '0' then
              p1_read_p1_o       <= true;
              p1_read_reg_o      <= true;
            else
              p2_read_p2_o       <= true;
              p2_read_reg_o      <= true;
            end if;

            alu_write_temp_reg_o <= true;
          end if;

        else
          case clk_mstate_i is
            -- write shadow Accumulator when contents of Program Memory is
            -- on bus
            when MSTATE1 =>
              alu_write_shadow_o <= true;

            -- loop shadow Accumulator through ALU to prevent update from
            -- real Accumulator
            when MSTATE2 =>
              alu_read_alu_o     <= true;
              alu_write_shadow_o <= true;

            -- write result of OR operation back to port
            when MSTATE3 =>
              alu_op_o           <= ALU_OR;
              alu_read_alu_o     <= true;

              if opc_opcode_q(1 downto 0) = "00" then
                bus_write_bus_o  <= true;
              elsif opc_opcode_q(1) = '0' then
                p1_write_p1_o    <= true;
              else
                p2_write_p2_o    <= true;
              end if;

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic OUTL_EXT ----------------------------------------------------
      when MN_OUTL_EXT =>
        if opc_opcode_q(4) = '0' then
          clk_assert_wr_o <= true;
        end if;

        -- read Accumulator and store in Port/BUS output register
        if not clk_second_cycle_i and clk_mstate_i = MSTATE4 then
          alu_read_alu_o  <= true;

          if opc_opcode_q(4) = '1' then
            if opc_opcode_q(1) = '0' then
              p1_write_p1_o <= true;
            else
              p2_write_p2_o <= true;
            end if;

          else
            bus_write_bus_o <= true;

          end if;

        end if;

      -- Mnemonic RET ---------------------------------------------------------
      when MN_RET =>
        if not clk_second_cycle_i then
          case clk_mstate_i is
            -- decrement Stack Pointer
            when MSTATE3 =>
              psw_dec_stackp_o     <= true;

            -- read Stack Pointer and address Data Memory for low byte
            when MSTATE4 =>
              psw_read_sp_o        <= true;
              dm_write_dmem_addr_o <= true;
              dm_addr_type_o       <= DM_STACK;

            -- read Data Memory and store to Program Counter low
            -- prepare address to Data memory for high byte
            when MSTATE5 =>
              dm_read_dmem_o       <= true;
              pm_write_pcl_o       <= true;
              dm_write_dmem_addr_o <= true;
              dm_addr_type_o       <= DM_STACK_HIGH;

            when others =>
              null;

          end case;

        else
          case clk_mstate_i is
            -- read Data Memory and store to Program Counter high and PSW
            when MSTATE1 =>
              dm_read_dmem_o         <= true;
              pm_write_pch_o         <= true;
              if opc_opcode_q(4) = '1' then
                psw_write_psw_o      <= true;
                retr_executed_s      <= true;
              end if;

            when MSTATE2 =>
              add_write_pmem_addr_s  <= true;

            when others =>
              null;

          end case;

        end if;

      -- Mnemonic RL ----------------------------------------------------------
      when MN_RL =>
        if clk_mstate_i = MSTATE3 then
          alu_op_o             <= ALU_RL;
          alu_read_alu_o       <= true;
          alu_write_accu_o     <= true;

          if opc_opcode_q(4) = '1' then
            psw_special_data_o <= alu_carry_i;
            psw_write_carry_o  <= true;
            alu_use_carry_o    <= true;
          end if;
        end if;

      -- Mnemonic RR ----------------------------------------------------------
      when MN_RR =>
        if clk_mstate_i = MSTATE3 then
          alu_op_o             <= ALU_RR;
          alu_read_alu_o       <= true;
          alu_write_accu_o     <= true;

          if opc_opcode_q(4) = '0' then
            psw_special_data_o <= alu_carry_i;
            psw_write_carry_o  <= true;
            alu_use_carry_o    <= true;
          end if;
        end if;

      -- Mnemonic SEL_MB ------------------------------------------------------
      when MN_SEL_MB =>
        if clk_mstate_i = MSTATE3 then
          if opc_opcode_q(4) = '1' then
            set_mb_s   <= true;
          else
            clear_mb_s <= true;
          end if;
        end if;

      -- Mnemonic SEL_RB ------------------------------------------------------
      when MN_SEL_RB =>
        if clk_mstate_i = MSTATE3 then
          psw_special_data_o <= opc_opcode_q(4);
          psw_write_bs_o     <= true;
        end if;

      -- Mnemonic STOP_TCNT ---------------------------------------------------
      when MN_STOP_TCNT =>
        if clk_mstate_i = MSTATE3 then
          tim_stop_tcnt_o <= true;
        end if;

      -- Mnemonic STRT --------------------------------------------------------
      when MN_STRT =>
        if clk_mstate_i = MSTATE3 then
          if opc_opcode_q(4) = '1' then
            tim_start_t_o   <= true;
          else
            tim_start_cnt_o <= true;
          end if;
        end if;

      -- Mnemonic SWAP --------------------------------------------------------
      when MN_SWAP =>
        alu_op_o           <= ALU_SWAP;

        if clk_mstate_i = MSTATE3 then
          alu_read_alu_o   <= true;
          alu_write_accu_o <= true;
        end if;

      -- Mnemonic XCH ---------------------------------------------------------
      when MN_XCH =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          -- store data from RAM in Accumulator and Temp Reg
          -- Accumulator is already shadowed!
          when MSTATE4 =>
            dm_read_dmem_o       <= true;
            alu_write_accu_o     <= true;
            alu_write_temp_reg_o <= true;
            if opc_opcode_q(4) = '1' then
              -- XCHD
              -- only write lower nibble of Accumulator
              alu_accu_low_o     <= true;
            end if;

          -- store data from shadow (previous) Accumulator to dmem
          when MSTATE5 =>
            dm_write_dmem_s      <= true;
            alu_read_alu_o       <= true;
            if opc_opcode_q(4) = '1' then
              -- XCHD
              -- concatenate shadow Accumulator and Temp Reg
              alu_op_o           <= ALU_CONCAT;
            end if;

          when others =>
            null;

        end case;

      -- Mnemonic XRL ---------------------------------------------------------
      when MN_XRL =>
        case clk_mstate_i is
          -- read RAM once for indirect address mode
          when MSTATE3 =>
            if not enable_quartus_bugfix_c or
               opc_opcode_q(3) = '0' then
              address_indirect_3_f;
            end if;

          -- store data from RAM to Temp Reg
          when MSTATE4 =>
            and_or_xor_add_4_f;

          -- perform XOR and store in Accumulator
          when MSTATE5 =>
            and_or_xor_add_5_f(alu_op => ALU_XOR);

          when others =>
            null;

        end case;

      -- Mnemonic XRL_A_DATA --------------------------------------------------
      when MN_XRL_A_DATA =>
        assert_psen_s              <= true;

        if clk_second_cycle_i then
          case clk_mstate_i is
            -- write Temp Reg when contents of Program Memory is on bus
            when MSTATE1 =>
              alu_write_temp_reg_o <= true;

            -- perform XOR and store in Accumulator
            when MSTATE3 =>
              and_or_xor_add_5_f(alu_op => ALU_XOR);

            when others =>
              null;

          end case;

        end if;

      -- Unimplemented mnemonic -----------------------------------------------
      when others =>
        -- this will behave like a NOP

        -- pragma translate_off
        assert false
          report "Mnemonic not yet implemented."
          severity warning;
        -- pragma translate_on

    end case;

  end process decode;
  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  -- Process regs
  --
  -- Purpose:
  --   Implements the various registes.
  --
  regs: process (res_i, clk_i)
  begin
    if res_i = res_active_c then
      branch_taken_q <= false;
      f1_q           <= '0';
      mb_q           <= '0';
      t0_dir_q       <= '0';
      -- pragma translate_off
      istrobe_res_q  <= '1';
      istrobe_q      <= '0';
      injected_int_q <= '0';
      -- pragma translate_on

    elsif clk_i'event and clk_i = clk_active_c then
      if en_clk_i then

        -- branch taken flag
        if branch_taken_s then
          branch_taken_q <= true;
        elsif clk_mstate_i = MSTATE5 then
          -- release flag when new instruction starts
          branch_taken_q <= false;
        end if;

        -- Flag 1
        if clear_f1_s then
          f1_q         <= '0';
        elsif cpl_f1_s then
          f1_q         <= not f1_q;
        end if;

        -- Memory Bank select
        if clear_mb_s then
          mb_q         <= '0';
        elsif set_mb_s then
          mb_q         <= '1';
        end if;

        -- T0 direction selection
        if ent0_clk_s then
          t0_dir_q     <= '1';
        end if;

        -- pragma translate_off
        -- Marker for injected instruction ------------------------------------
        if opc_inj_int_s then
          injected_int_q <= '1';
        elsif clk_mstate_i = MSTATE5 and last_cycle_s then
          injected_int_q <= '0';
        end if;

        -- Remove istrobe after reset suppression -----------------------------
        if clk_mstate_i = MSTATE5 and last_cycle_s then
          istrobe_res_q  <= '0';
        end if;
        -- pragma translate_on

      end if;

      -- pragma translate_off
      -- Instruction Strobe ---------------------------------------------------
      if clk_mstate_i = MSTATE5 and last_cycle_s and
         injected_int_q = '0' then
        if istrobe_res_q = '0' then
          istrobe_q <= '1';
        end if;
      else
        istrobe_q   <= '0';
      end if;
      -- pragma translate_on

    end if;

  end process regs;
  --
  -----------------------------------------------------------------------------

  -- pragma translate_off
  -- assign to global signal for testbench
  tb_istrobe_s <= istrobe_q;
  -- pragma translate_on


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  clk_multi_cycle_o    <= opc_multi_cycle_s;
  cnd_f1_o             <= f1_q;
  cnd_tf_o             <= tf_s;
  data_o               <=   data_s
                          when read_dec_s else
                            (others => bus_idle_level_c);
  dm_write_dmem_o      <= dm_write_dmem_s      and en_clk_i;
  pm_inc_pc_o          <= pm_inc_pc_s          or add_inc_pc_s;
  pm_write_pmem_addr_o <= pm_write_pmem_addr_s or add_write_pmem_addr_s;
  t0_dir_o             <= t0_dir_q;
  bus_read_bus_o       <= bus_read_bus_s       or add_read_bus_s;

end rtl;
