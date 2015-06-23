-------------------------------------------------------------------------------
--
-- T48 Microcontroller Core
--
-- $Id: t48_core.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, 2005, Arnim Laeuger (arniml@opencores.org)
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
-- Limitations :
-- =============
--
-- Compared to the original MCS-48 architecture, the following limitations
-- apply:
--
--   * Single-step mode not implemented.
--     Not selected for future implementation.
--
--   * Reading of internal Program Memory not implemented.
--     Not selected for future implementation.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity t48_core is

  generic (
    -- divide XTAL1 by 3 to derive Clock States
    xtal_div_3_g          : integer := 1;
    -- store mnemonic in flip-flops (registered-out)
    register_mnemonic_g   : integer := 1;
    -- include the port 1 module
    include_port1_g       : integer := 1;
    -- include the port 2 module
    include_port2_g       : integer := 1;
    -- include the BUS module
    include_bus_g         : integer := 1;
    -- include the timer module
    include_timer_g       : integer := 1;
    -- state in which T1 is sampled (3 or 4)
    sample_t1_state_g     : integer := 4
  );

  port (
    -- T48 Interface ----------------------------------------------------------
    xtal_i        : in  std_logic;
    xtal_en_i     : in  std_logic;
    reset_i       : in  std_logic;
    t0_i          : in  std_logic;
    t0_o          : out std_logic;
    t0_dir_o      : out std_logic;
    int_n_i       : in  std_logic;
    ea_i          : in  std_logic;
    rd_n_o        : out std_logic;
    psen_n_o      : out std_logic;
    wr_n_o        : out std_logic;
    ale_o         : out std_logic;
    db_i          : in  std_logic_vector( 7 downto 0);
    db_o          : out std_logic_vector( 7 downto 0);
    db_dir_o      : out std_logic;
    t1_i          : in  std_logic;
    p2_i          : in  std_logic_vector( 7 downto 0);
    p2_o          : out std_logic_vector( 7 downto 0);
    p2l_low_imp_o : out std_logic;
    p2h_low_imp_o : out std_logic;
    p1_i          : in  std_logic_vector( 7 downto 0);
    p1_o          : out std_logic_vector( 7 downto 0);
    p1_low_imp_o  : out std_logic;
    prog_n_o      : out std_logic;
    -- Core Interface ---------------------------------------------------------
    clk_i         : in  std_logic;
    en_clk_i      : in  std_logic;
    xtal3_o       : out std_logic;
    dmem_addr_o   : out std_logic_vector( 7 downto 0);
    dmem_we_o     : out std_logic;
    dmem_data_i   : in  std_logic_vector( 7 downto 0);
    dmem_data_o   : out std_logic_vector( 7 downto 0);
    pmem_addr_o   : out std_logic_vector(11 downto 0);
    pmem_data_i   : in  std_logic_vector( 7 downto 0)
  );

end t48_core;


use work.t48_alu_pack.alu_op_t;
use work.t48_cond_branch_pack.branch_conditions_t;
use work.t48_cond_branch_pack.comp_value_t;
use work.t48_dmem_ctrl_pack.dmem_addr_ident_t;
use work.t48_pmem_ctrl_pack.pmem_addr_ident_t;
use work.t48_comp_pack.all;
use work.t48_pack.bus_idle_level_c;
use work.t48_pack.word_t;
use work.t48_pack.pmem_addr_t;
use work.t48_pack.mstate_t;
use work.t48_pack.to_stdLogic;
use work.t48_pack.to_boolean;

architecture struct of t48_core is

  signal t48_data_s : word_t;

  signal xtal_en_s  : boolean;
  signal en_clk_s   : boolean;

  -- ALU signals
  signal alu_data_s           : word_t;
  signal alu_write_accu_s     : boolean;
  signal alu_write_shadow_s   : boolean;
  signal alu_write_temp_reg_s : boolean;
  signal alu_read_alu_s       : boolean;
  signal alu_carry_s          : std_logic;
  signal alu_aux_carry_s      : std_logic;
  signal alu_op_s             : alu_op_t;
  signal alu_use_carry_s      : boolean;
  signal alu_da_high_s        : boolean;
  signal alu_da_overflow_s    : boolean;
  signal alu_accu_low_s       : boolean;
  signal alu_p06_temp_reg_s   : boolean;
  signal alu_p60_temp_reg_s   : boolean;

  -- BUS signals
  signal bus_write_bus_s  : boolean;
  signal bus_read_bus_s   : boolean;
  signal bus_output_pcl_s : boolean;
  signal bus_bidir_bus_s  : boolean;
  signal bus_data_s       : word_t;

  -- Clock Controller signals
  signal clk_multi_cycle_s  : boolean;
  signal clk_assert_psen_s  : boolean;
  signal clk_assert_prog_s  : boolean;
  signal clk_assert_rd_s    : boolean;
  signal clk_assert_wr_s    : boolean;
  signal clk_mstate_s       : mstate_t;
  signal clk_second_cycle_s : boolean;
  signal psen_s             : boolean;
  signal prog_s             : boolean;
  signal rd_s               : boolean;
  signal wr_s               : boolean;
  signal ale_s              : boolean;
  signal xtal3_s            : boolean;

  -- Conditional Branch Logic signals
  signal cnd_compute_take_s : boolean;
  signal cnd_branch_cond_s  : branch_conditions_t;
  signal cnd_take_branch_s  : boolean;
  signal cnd_comp_value_s   : comp_value_t;
  signal cnd_f1_s           : std_logic;
  signal cnd_tf_s           : std_logic;

  -- Data Memory Controller signals
  signal dm_write_dmem_addr_s : boolean;
  signal dm_write_dmem_s      : boolean;
  signal dm_read_dmem_s       : boolean;
  signal dm_addr_type_s       : dmem_addr_ident_t;
  signal dm_data_s            : word_t;

  -- Decoder signals
  signal dec_data_s           : word_t;

  -- Port 1 signals
  signal p1_write_p1_s : boolean;
  signal p1_read_p1_s  : boolean;
  signal p1_read_reg_s : boolean;
  signal p1_data_s     : word_t;

  -- Port 2 signals
  signal p2_write_p2_s   : boolean;
  signal p2_write_exp_s  : boolean;
  signal p2_read_p2_s    : boolean;
  signal p2_read_reg_s   : boolean;
  signal p2_read_exp_s   : boolean;
  signal p2_output_pch_s : boolean;
  signal p2_data_s       : word_t;

  -- Program Memory Controller signals
  signal pm_write_pcl_s       : boolean;
  signal pm_read_pcl_s        : boolean;
  signal pm_write_pch_s       : boolean;
  signal pm_read_pch_s        : boolean;
  signal pm_read_pmem_s       : boolean;
  signal pm_inc_pc_s          : boolean;
  signal pm_write_pmem_addr_s : boolean;
  signal pm_data_s            : word_t;
  signal pm_addr_type_s       : pmem_addr_ident_t;
  signal pmem_addr_s          : pmem_addr_t;

  -- PSW signals
  signal psw_read_psw_s        : boolean;
  signal psw_read_sp_s         : boolean;
  signal psw_write_psw_s       : boolean;
  signal psw_write_sp_s        : boolean;
  signal psw_carry_s           : std_logic;
  signal psw_aux_carry_s       : std_logic;
  signal psw_f0_s              : std_logic;
  signal psw_bs_s              : std_logic;
  signal psw_special_data_s    : std_logic;
  signal psw_inc_stackp_s      : boolean;
  signal psw_dec_stackp_s      : boolean;
  signal psw_write_carry_s     : boolean;
  signal psw_write_aux_carry_s : boolean;
  signal psw_write_f0_s        : boolean;
  signal psw_write_bs_s        : boolean;
  signal psw_data_s            : word_t;

  -- Timer signals
  signal tim_overflow_s    : boolean;
  signal tim_of_s          : std_logic;
  signal tim_read_timer_s  : boolean;
  signal tim_write_timer_s : boolean;
  signal tim_start_t_s     : boolean;
  signal tim_start_cnt_s   : boolean;
  signal tim_stop_tcnt_s   : boolean;
  signal tim_data_s        : word_t;

begin

  -----------------------------------------------------------------------------
  -- Check generics for valid values.
  -----------------------------------------------------------------------------
  -- pragma translate_off
  assert include_timer_g = 0 or include_timer_g = 1
    report "include_timer_g must be either 1 or 0!"
    severity failure;

  assert include_port1_g = 0 or include_port1_g = 1
    report "include_port1_g must be either 1 or 0!"
    severity failure;

  assert include_port2_g = 0 or include_port2_g = 1
    report "include_port2_g must be either 1 or 0!"
    severity failure;

  assert include_bus_g   = 0 or include_bus_g = 1
    report "include_bus_g must be either 1 or 0!"
    severity failure;
  -- pragma translate_on


  xtal_en_s <= to_boolean(xtal_en_i);
  en_clk_s  <= to_boolean(en_clk_i);

  alu_b : t48_alu
    port map (
      clk_i              => clk_i,
      res_i              => reset_i,
      en_clk_i           => en_clk_s,
      data_i             => t48_data_s,
      data_o             => alu_data_s,
      write_accu_i       => alu_write_accu_s,
      write_shadow_i     => alu_write_shadow_s,
      write_temp_reg_i   => alu_write_temp_reg_s,
      read_alu_i         => alu_read_alu_s,
      carry_i            => psw_carry_s,
      carry_o            => alu_carry_s,
      aux_carry_o        => alu_aux_carry_s,
      alu_op_i           => alu_op_s,
      use_carry_i        => alu_use_carry_s,
      da_high_i          => alu_da_high_s,
      da_overflow_o      => alu_da_overflow_s,
      accu_low_i         => alu_accu_low_s,
      p06_temp_reg_i     => alu_p06_temp_reg_s,
      p60_temp_reg_i     => alu_p60_temp_reg_s
    );

  bus_mux_b : t48_bus_mux
    port map (
      alu_data_i => alu_data_s,
      bus_data_i => bus_data_s,
      dec_data_i => dec_data_s,
      dm_data_i  => dm_data_s,
      pm_data_i  => pm_data_s,
      p1_data_i  => p1_data_s,
      p2_data_i  => p2_data_s,
      psw_data_i => psw_data_s,
      tim_data_i => tim_data_s,
      data_o     => t48_data_s
    );

  clock_ctrl_b : t48_clock_ctrl
    generic map (
      xtal_div_3_g   => xtal_div_3_g
    )
    port map (
      clk_i          => clk_i,
      xtal_i         => xtal_i,
      xtal_en_i      => xtal_en_s,
      res_i          => reset_i,
      en_clk_i       => en_clk_s,
      xtal3_o        => xtal3_s,
      t0_o           => t0_o,
      multi_cycle_i  => clk_multi_cycle_s,
      assert_psen_i  => clk_assert_psen_s,
      assert_prog_i  => clk_assert_prog_s,
      assert_rd_i    => clk_assert_rd_s,
      assert_wr_i    => clk_assert_wr_s,
      mstate_o       => clk_mstate_s,
      second_cycle_o => clk_second_cycle_s,
      ale_o          => ale_s,
      psen_o         => psen_s,
      prog_o         => prog_s,
      rd_o           => rd_s,
      wr_o           => wr_s
    );

  cond_branch_b : t48_cond_branch
    port map (
      clk_i          => clk_i,
      res_i          => reset_i,
      en_clk_i       => en_clk_s,
      compute_take_i => cnd_compute_take_s,
      branch_cond_i  => cnd_branch_cond_s,
      take_branch_o  => cnd_take_branch_s,
      accu_i         => alu_data_s,
      t0_i           => To_X01Z(t0_i),
      t1_i           => To_X01Z(t1_i),
      int_n_i        => int_n_i,
      f0_i           => psw_f0_s,
      f1_i           => cnd_f1_s,
      tf_i           => cnd_tf_s,
      carry_i        => psw_carry_s,
      comp_value_i   => cnd_comp_value_s
    );

  use_db_bus: if include_bus_g = 1 generate
    db_bus_b : t48_db_bus
      port map (
        clk_i        => clk_i,
        res_i        => reset_i,
        en_clk_i     => en_clk_s,
        ea_i         => ea_i,
        data_i       => t48_data_s,
        data_o       => bus_data_s,
        write_bus_i  => bus_write_bus_s,
        read_bus_i   => bus_read_bus_s,
        output_pcl_i => bus_output_pcl_s,
        bidir_bus_i  => bus_bidir_bus_s,
        pcl_i        => pmem_addr_s(word_t'range),
        db_i         => db_i,
        db_o         => db_o,
        db_dir_o     => db_dir_o
      );
  end generate;

  skip_db_bus: if include_bus_g = 0 generate
    bus_data_s <= (others => bus_idle_level_c);
    db_o       <= (others => '0');
    db_dir_o   <= '0';
  end generate;

  decoder_b : t48_decoder
    generic map (
      register_mnemonic_g => register_mnemonic_g
    )
    port map (
      clk_i                  => clk_i,
      res_i                  => reset_i,
      en_clk_i               => en_clk_s,
      xtal_i                 => xtal_i,
      xtal_en_i              => xtal_en_s,
      ea_i                   => ea_i,
      ale_i                  => ale_s,
      int_n_i                => int_n_i,
      t0_dir_o               => t0_dir_o,
      data_i                 => t48_data_s,
      data_o                 => dec_data_s,
      alu_write_accu_o       => alu_write_accu_s,
      alu_write_shadow_o     => alu_write_shadow_s,
      alu_write_temp_reg_o   => alu_write_temp_reg_s,
      alu_read_alu_o         => alu_read_alu_s,
      bus_write_bus_o        => bus_write_bus_s,
      bus_read_bus_o         => bus_read_bus_s,
      dm_write_dmem_addr_o   => dm_write_dmem_addr_s,
      dm_write_dmem_o        => dm_write_dmem_s,
      dm_read_dmem_o         => dm_read_dmem_s,
      p1_write_p1_o          => p1_write_p1_s,
      p1_read_p1_o           => p1_read_p1_s,
      pm_write_pcl_o         => pm_write_pcl_s,
      p2_write_p2_o          => p2_write_p2_s,
      p2_write_exp_o         => p2_write_exp_s,
      p2_read_p2_o           => p2_read_p2_s,
      pm_read_pcl_o          => pm_read_pcl_s,
      pm_write_pch_o         => pm_write_pch_s,
      pm_read_pch_o          => pm_read_pch_s,
      pm_read_pmem_o         => pm_read_pmem_s,
      psw_read_psw_o         => psw_read_psw_s,
      psw_read_sp_o          => psw_read_sp_s,
      psw_write_psw_o        => psw_write_psw_s,
      psw_write_sp_o         => psw_write_sp_s,
      alu_carry_i            => alu_carry_s,
      alu_op_o               => alu_op_s,
      alu_use_carry_o        => alu_use_carry_s,
      alu_da_high_o          => alu_da_high_s,
      alu_da_overflow_i      => alu_da_overflow_s,
      alu_accu_low_o         => alu_accu_low_s,
      alu_p06_temp_reg_o     => alu_p06_temp_reg_s,
      alu_p60_temp_reg_o     => alu_p60_temp_reg_s,
      bus_output_pcl_o       => bus_output_pcl_s,
      bus_bidir_bus_o        => bus_bidir_bus_s,
      clk_multi_cycle_o      => clk_multi_cycle_s,
      clk_assert_psen_o      => clk_assert_psen_s,
      clk_assert_prog_o      => clk_assert_prog_s,
      clk_assert_rd_o        => clk_assert_rd_s,
      clk_assert_wr_o        => clk_assert_wr_s,
      clk_mstate_i           => clk_mstate_s,
      clk_second_cycle_i     => clk_second_cycle_s,
      cnd_compute_take_o     => cnd_compute_take_s,
      cnd_branch_cond_o      => cnd_branch_cond_s,
      cnd_take_branch_i      => cnd_take_branch_s,
      cnd_comp_value_o       => cnd_comp_value_s,
      cnd_f1_o               => cnd_f1_s,
      cnd_tf_o               => cnd_tf_s,
      dm_addr_type_o         => dm_addr_type_s,
      tim_read_timer_o       => tim_read_timer_s,
      tim_write_timer_o      => tim_write_timer_s,
      tim_start_t_o          => tim_start_t_s,
      tim_start_cnt_o        => tim_start_cnt_s,
      tim_stop_tcnt_o        => tim_stop_tcnt_s,
      p1_read_reg_o          => p1_read_reg_s,
      p2_read_reg_o          => p2_read_reg_s,
      p2_read_exp_o          => p2_read_exp_s,
      p2_output_pch_o        => p2_output_pch_s,
      pm_inc_pc_o            => pm_inc_pc_s,
      pm_write_pmem_addr_o   => pm_write_pmem_addr_s,
      pm_addr_type_o         => pm_addr_type_s,
      psw_special_data_o     => psw_special_data_s,
      psw_carry_i            => psw_carry_s,
      psw_aux_carry_i        => psw_aux_carry_s,
      psw_f0_i               => psw_f0_s,
      psw_inc_stackp_o       => psw_inc_stackp_s,
      psw_dec_stackp_o       => psw_dec_stackp_s,
      psw_write_carry_o      => psw_write_carry_s,
      psw_write_aux_carry_o  => psw_write_aux_carry_s,
      psw_write_f0_o         => psw_write_f0_s,
      psw_write_bs_o         => psw_write_bs_s,
      tim_overflow_i         => tim_overflow_s
    );

  dmem_ctrl_b : t48_dmem_ctrl
    port map (
      clk_i             => clk_i,
      res_i             => reset_i,
      en_clk_i          => en_clk_s,
      data_i            => t48_data_s,
      write_dmem_addr_i => dm_write_dmem_addr_s,
      write_dmem_i      => dm_write_dmem_s,
      read_dmem_i       => dm_read_dmem_s,
      addr_type_i       => dm_addr_type_s,
      bank_select_i     => psw_bs_s,
      data_o            => dm_data_s,
      dmem_data_i       => dmem_data_i,
      dmem_addr_o       => dmem_addr_o,
      dmem_we_o         => dmem_we_o,
      dmem_data_o       => dmem_data_o
    );

  use_timer: if include_timer_g = 1 generate
    timer_b : t48_timer
      generic map (
        sample_t1_state_g => sample_t1_state_g
      )
      port map (
        clk_i         => clk_i,
        res_i         => reset_i,
        en_clk_i      => en_clk_s,
        t1_i          => To_X01Z(t1_i),
        clk_mstate_i  => clk_mstate_s,
        data_i        => t48_data_s,
        data_o        => tim_data_s,
        read_timer_i  => tim_read_timer_s,
        write_timer_i => tim_write_timer_s,
        start_t_i     => tim_start_t_s,
        start_cnt_i   => tim_start_cnt_s,
        stop_tcnt_i   => tim_stop_tcnt_s,
        overflow_o    => tim_of_s
      );
  end generate;

  skip_timer: if include_timer_g = 0 generate
    tim_data_s <= (others => bus_idle_level_c);
    tim_of_s   <= '0';
  end generate;

  tim_overflow_s <= to_boolean(tim_of_s);

  use_p1: if include_port1_g = 1 generate
    p1_b : t48_p1
      port map (
        clk_i        => clk_i,
        res_i        => reset_i,
        en_clk_i     => en_clk_s,
        data_i       => t48_data_s,
        data_o       => p1_data_s,
        write_p1_i   => p1_write_p1_s,
        read_p1_i    => p1_read_p1_s,
        read_reg_i   => p1_read_reg_s,
        p1_i         => p1_i,
        p1_o         => p1_o,
        p1_low_imp_o => p1_low_imp_o
      );
  end generate;

  skip_p1: if include_port1_g = 0 generate
    p1_data_s    <= (others => bus_idle_level_c);
    p1_o         <= (others => '0');
    p1_low_imp_o <= '0';
  end generate;

  use_p2: if include_port2_g = 1 generate
    p2_b : t48_p2
      port map (
        clk_i         => clk_i,
        res_i         => reset_i,
        en_clk_i      => en_clk_s,
        xtal_i        => xtal_i,
        xtal_en_i     => xtal_en_s,
        data_i        => t48_data_s,
        data_o        => p2_data_s,
        write_p2_i    => p2_write_p2_s,
        write_exp_i   => p2_write_exp_s,
        read_p2_i     => p2_read_p2_s,
        read_reg_i    => p2_read_reg_s,
        read_exp_i    => p2_read_exp_s,
        output_pch_i  => p2_output_pch_s,
        pch_i         => pmem_addr_s(11 downto 8),
        p2_i          => p2_i,
        p2_o          => p2_o,
        p2l_low_imp_o => p2l_low_imp_o,
        p2h_low_imp_o => p2h_low_imp_o
      );
  end generate;

  skip_p2: if include_port2_g = 0 generate
    p2_data_s     <= (others => bus_idle_level_c);
    p2_o          <= (others => '0');
    p2l_low_imp_o <= '0';
    p2h_low_imp_o <= '0';
  end generate;

  pmem_ctrl_b : t48_pmem_ctrl
    port map (
      clk_i             => clk_i,
      res_i             => reset_i,
      en_clk_i          => en_clk_s,
      data_i            => t48_data_s,
      data_o            => pm_data_s,
      write_pcl_i       => pm_write_pcl_s,
      read_pcl_i        => pm_read_pcl_s,
      write_pch_i       => pm_write_pch_s,
      read_pch_i        => pm_read_pch_s,
      inc_pc_i          => pm_inc_pc_s,
      write_pmem_addr_i => pm_write_pmem_addr_s,
      addr_type_i       => pm_addr_type_s,
      read_pmem_i       => pm_read_pmem_s,
      pmem_addr_o       => pmem_addr_s,
      pmem_data_i       => pmem_data_i
    );

  psw_b : t48_psw
    port map (
      clk_i              => clk_i,
      res_i              => reset_i,
      en_clk_i           => en_clk_s,
      data_i             => t48_data_s,
      data_o             => psw_data_s,
      read_psw_i         => psw_read_psw_s,
      read_sp_i          => psw_read_sp_s,
      write_psw_i        => psw_write_psw_s,
      write_sp_i         => psw_write_sp_s,
      special_data_i     => psw_special_data_s,
      inc_stackp_i       => psw_inc_stackp_s,
      dec_stackp_i       => psw_dec_stackp_s,
      write_carry_i      => psw_write_carry_s,
      write_aux_carry_i  => psw_write_aux_carry_s,
      write_f0_i         => psw_write_f0_s,
      write_bs_i         => psw_write_bs_s,
      carry_o            => psw_carry_s,
      aux_carry_i        => alu_aux_carry_s,
      aux_carry_o        => psw_aux_carry_s,
      f0_o               => psw_f0_s,
      bs_o               => psw_bs_s
    );


  -----------------------------------------------------------------------------
  -- Output Mapping.
  -----------------------------------------------------------------------------
  ale_o       <= to_stdLogic(ale_s);
  psen_n_o    <= to_stdLogic(not psen_s);
  prog_n_o    <= to_stdLogic(not prog_s);
  rd_n_o      <= to_stdLogic(not rd_s);
  wr_n_o      <= to_stdLogic(not wr_s);
  xtal3_o     <= to_stdLogic(xtal3_s);
  pmem_addr_o <= pmem_addr_s;

end struct;
