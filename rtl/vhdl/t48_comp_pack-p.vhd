-------------------------------------------------------------------------------
--
-- $Id: t48_comp_pack-p.vhd 295 2009-04-01 19:32:48Z arniml $
--
-- Copyright (c) 2004, 2005, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t48_alu_pack.alu_op_t;
use work.t48_cond_branch_pack.branch_conditions_t;
use work.t48_cond_branch_pack.comp_value_t;
use work.t48_decoder_pack.mnemonic_t;
use work.t48_dmem_ctrl_pack.dmem_addr_ident_t;
use work.t48_pmem_ctrl_pack.pmem_addr_ident_t;
use work.t48_pack.dmem_addr_t;
use work.t48_pack.pmem_addr_t;
use work.t48_pack.mstate_t;
use work.t48_pack.word_t;
use work.t48_pack.nibble_t;

package t48_comp_pack is

  component t48_alu
    port (
      clk_i              : in  std_logic;
      res_i              : in  std_logic;
      en_clk_i           : in  boolean;
      data_i             : in  word_t;
      data_o             : out word_t;
      write_accu_i       : in  boolean;
      write_shadow_i     : in  boolean;
      write_temp_reg_i   : in  boolean;
      read_alu_i         : in  boolean;
      carry_i            : in  std_logic;
      carry_o            : out std_logic;
      aux_carry_o        : out std_logic;
      alu_op_i           : in  alu_op_t;
      use_carry_i        : in  boolean;
      da_high_i          : in  boolean;
      da_overflow_o      : out boolean;
      accu_low_i         : in  boolean;
      p06_temp_reg_i     : in  boolean;
      p60_temp_reg_i     : in  boolean
    );
  end component;

  component t48_bus_mux
    port (
      alu_data_i : in  word_t;
      bus_data_i : in  word_t;
      dec_data_i : in  word_t;
      dm_data_i  : in  word_t;
      pm_data_i  : in  word_t;
      p1_data_i  : in  word_t;
      p2_data_i  : in  word_t;
      psw_data_i : in  word_t;
      tim_data_i : in  word_t;
      data_o     : out word_t
    );
  end component;

  component t48_clock_ctrl
    generic (
      xtal_div_3_g   : integer := 1
    );
    port (
      clk_i          : in  std_logic;
      xtal_i         : in  std_logic;
      xtal_en_i      : in  boolean;
      res_i          : in  std_logic;
      en_clk_i       : in  boolean;
      xtal3_o        : out boolean;
      t0_o           : out std_logic;
      multi_cycle_i  : in  boolean;
      assert_psen_i  : in  boolean;
      assert_prog_i  : in  boolean;
      assert_rd_i    : in  boolean;
      assert_wr_i    : in  boolean;
      mstate_o       : out mstate_t;
      second_cycle_o : out boolean;
      ale_o          : out boolean;
      psen_o         : out boolean;
      prog_o         : out boolean;
      rd_o           : out boolean;
      wr_o           : out boolean
    );
  end component;

  component t48_cond_branch
    port (
      clk_i          : in  std_logic;
      res_i          : in  std_logic;
      en_clk_i       : in  boolean;
      compute_take_i : in  boolean;
      branch_cond_i  : in  branch_conditions_t;
      take_branch_o  : out boolean;
      accu_i         : in  word_t;
      t0_i           : in  std_logic;
      t1_i           : in  std_logic;
      int_n_i        : in  std_logic;
      f0_i           : in  std_logic;
      f1_i           : in  std_logic;
      tf_i           : in  std_logic;
      carry_i        : in  std_logic;
      comp_value_i   : in  comp_value_t
    );
  end component;

  component t48_db_bus
    port (
      clk_i        : in  std_logic;
      res_i        : in  std_logic;
      en_clk_i     : in  boolean;
      ea_i         : in  std_logic;
      data_i       : in  word_t;
      data_o       : out word_t;
      write_bus_i  : in  boolean;
      read_bus_i   : in  boolean;
      output_pcl_i : in  boolean;
      bidir_bus_i  : in  boolean;
      pcl_i        : in  word_t;
      db_i         : in  word_t;
      db_o         : out word_t;
      db_dir_o     : out std_logic
    );
  end component;

  component t48_decoder
    generic (
      register_mnemonic_g   : integer := 1
    );
    port (
      clk_i                  : in  std_logic;
      res_i                  : in  std_logic;
      en_clk_i               : in  boolean;
      xtal_i                 : in  std_logic;
      xtal_en_i              : in  boolean;
      ea_i                   : in  std_logic;
      ale_i                  : in  boolean;
      int_n_i                : in  std_logic;
      t0_dir_o               : out std_logic;
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
      pm_write_pcl_o         : out boolean;
      pm_read_pcl_o          : out boolean;
      pm_write_pch_o         : out boolean;
      pm_read_pch_o          : out boolean;
      pm_read_pmem_o         : out boolean;
      psw_read_psw_o         : out boolean;
      psw_read_sp_o          : out boolean;
      psw_write_psw_o        : out boolean;
      psw_write_sp_o         : out boolean;
      alu_carry_i            : in  std_logic;
      alu_op_o               : out alu_op_t;
      alu_da_high_o          : out boolean;
      alu_accu_low_o         : out boolean;
      alu_da_overflow_i      : in  boolean;
      alu_p06_temp_reg_o     : out boolean;
      alu_p60_temp_reg_o     : out boolean;
      alu_use_carry_o        : out boolean;
      bus_output_pcl_o       : out boolean;
      bus_bidir_bus_o        : out boolean;
      clk_multi_cycle_o      : out boolean;
      clk_assert_psen_o      : out boolean;
      clk_assert_prog_o      : out boolean;
      clk_assert_rd_o        : out boolean;
      clk_assert_wr_o        : out boolean;
      clk_mstate_i           : in  mstate_t;
      clk_second_cycle_i     : in  boolean;
      cnd_compute_take_o     : out boolean;
      cnd_branch_cond_o      : out branch_conditions_t;
      cnd_take_branch_i      : in  boolean;
      cnd_comp_value_o       : out comp_value_t;
      cnd_f1_o               : out std_logic;
      cnd_tf_o               : out std_logic;
      dm_addr_type_o         : out dmem_addr_ident_t;
      tim_read_timer_o       : out boolean;
      tim_write_timer_o      : out boolean;
      tim_start_t_o          : out boolean;
      tim_start_cnt_o        : out boolean;
      tim_stop_tcnt_o        : out boolean;
      p1_read_reg_o          : out boolean;
      p2_read_reg_o          : out boolean;
      p2_read_exp_o          : out boolean;
      p2_output_pch_o        : out boolean;
      pm_inc_pc_o            : out boolean;
      pm_write_pmem_addr_o   : out boolean;
      pm_addr_type_o         : out pmem_addr_ident_t;
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
      tim_overflow_i         : in  boolean
    );
  end component;

  component t48_dmem_ctrl
    port (
      clk_i             : in  std_logic;
      res_i             : in  std_logic;
      en_clk_i          : in  boolean;
      data_i            : in  word_t;
      write_dmem_addr_i : in  boolean;
      write_dmem_i      : in  boolean;
      read_dmem_i       : in  boolean;
      addr_type_i       : in  dmem_addr_ident_t;
      bank_select_i     : in  std_logic;
      data_o            : out word_t;
      dmem_data_i       : in  word_t;
      dmem_addr_o       : out dmem_addr_t;
      dmem_we_o         : out std_logic;
      dmem_data_o       : out word_t
    );
  end component;

  component t48_int
    port (
      clk_i             : in  std_logic;
      res_i             : in  std_logic;
      en_clk_i          : in  boolean;
      xtal_i            : in  std_logic;
      xtal_en_i         : in  boolean;
      clk_mstate_i      : in  mstate_t;
      jtf_executed_i    : in  boolean;
      tim_overflow_i    : in  boolean;
      tf_o              : out std_logic;
      en_tcnti_i        : in  boolean;
      dis_tcnti_i       : in  boolean;
      int_n_i           : in  std_logic;
      ale_i             : in  boolean;
      last_cycle_i      : in  boolean;
      en_i_i            : in  boolean;
      dis_i_i           : in  boolean;
      ext_int_o         : out boolean;
      tim_int_o         : out boolean;
      retr_executed_i   : in  boolean;
      int_executed_i    : in  boolean;
      int_pending_o     : out boolean;
      int_in_progress_o : out boolean
    );
  end component;

  component t48_timer
    generic (
      sample_t1_state_g : integer := 4
    );
    port (
      clk_i         : in  std_logic;
      res_i         : in  std_logic;
      en_clk_i      : in  boolean;
      t1_i          : in  std_logic;
      clk_mstate_i  : in  mstate_t;
      data_i        : in  word_t;
      data_o        : out word_t;
      read_timer_i  : in  boolean;
      write_timer_i : in  boolean;
      start_t_i     : in  boolean;
      start_cnt_i   : in  boolean;
      stop_tcnt_i   : in  boolean;
      overflow_o    : out std_logic
    );
  end component;

  component t48_p1
    port (
      clk_i        : in  std_logic;
      res_i        : in  std_logic;
      en_clk_i     : in  boolean;
      data_i       : in  word_t;
      data_o       : out word_t;
      write_p1_i   : in  boolean;
      read_p1_i    : in  boolean;
      read_reg_i   : in  boolean;
      p1_i         : in  word_t;
      p1_o         : out word_t;
      p1_low_imp_o : out std_logic
    );
  end component;

  component t48_p2
    port (
      clk_i         : in  std_logic;
      res_i         : in  std_logic;
      en_clk_i      : in  boolean;
      xtal_i        : in  std_logic;
      xtal_en_i     : in  boolean;
      data_i        : in  word_t;
      data_o        : out word_t;
      write_p2_i    : in  boolean;
      write_exp_i   : in  boolean;
      read_p2_i     : in  boolean;
      read_reg_i    : in  boolean;
      read_exp_i    : in  boolean;
      output_pch_i  : in  boolean;
      pch_i         : in  nibble_t;
      p2_i          : in  word_t;
      p2_o          : out word_t;
      p2l_low_imp_o : out std_logic;
      p2h_low_imp_o : out std_logic
    );
  end component;

  component t48_pmem_ctrl
    port (
      clk_i             : in  std_logic;
      res_i             : in  std_logic;
      en_clk_i          : in  boolean;
      data_i            : in  word_t;
      data_o            : out word_t;
      write_pcl_i       : in  boolean;
      read_pcl_i        : in  boolean;
      write_pch_i       : in  boolean;
      read_pch_i        : in  boolean;
      inc_pc_i          : in  boolean;
      write_pmem_addr_i : in  boolean;
      addr_type_i       : in  pmem_addr_ident_t;
      read_pmem_i       : in  boolean;
      pmem_addr_o       : out pmem_addr_t;
      pmem_data_i       : in  word_t
    );
  end component;

  component t48_psw
    port (
      clk_i              : in  std_logic;
      res_i              : in  std_logic;
      en_clk_i           : in  boolean;
      data_i             : in  word_t;
      data_o             : out word_t;
      read_psw_i         : in  boolean;
      read_sp_i          : in  boolean;
      write_psw_i        : in  boolean;
      write_sp_i         : in  boolean;
      special_data_i     : in  std_logic;
      inc_stackp_i       : in  boolean;
      dec_stackp_i       : in  boolean;
      write_carry_i      : in  boolean;
      write_aux_carry_i  : in  boolean;
      write_f0_i         : in  boolean;
      write_bs_i         : in  boolean;
      carry_o            : out std_logic;
      aux_carry_i        : in  std_logic;
      aux_carry_o        : out std_logic;
      f0_o               : out std_logic;
      bs_o               : out std_logic
    );
  end component;

end t48_comp_pack;
