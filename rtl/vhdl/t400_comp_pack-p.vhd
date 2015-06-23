-------------------------------------------------------------------------------
--
-- $Id: t400_comp_pack-p.vhd 179 2009-04-01 19:48:38Z arniml $
--
-- Copyright (c) 2006, Arnim Laeuger (arniml@opencores.org)
--
-- All rights reserved
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.t400_opt_pack.all;
use work.t400_pack.all;

package t400_comp_pack is

  component t400_clkgen
    generic (
      opt_ck_div_g : integer := t400_opt_ck_div_16_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i      : in  std_logic;
      ck_en_i   : in  boolean;
      por_i     : in  boolean;
      -- Clock Interface ------------------------------------------------------
      phi1_o    : out std_logic;
      out_en_o  : out boolean;
      in_en_o   : out boolean;
      icyc_en_o : out boolean
    );
  end component;

  component t400_reset
    port (
      -- System Interface -----------------------------------------------------
      ck_i      : in  std_logic;
      icyc_en_i : in  boolean;
      -- Reset Interface ------------------------------------------------------
      por_i     : in  boolean;
      reset_n_i : in  std_logic;
      res_o     : out boolean
    );
  end component;

  component t400_stack
    generic (
      opt_type_g : integer := t400_opt_type_420_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i    : in  std_logic;
      ck_en_i : in  boolean;
      por_i   : in  boolean;
      -- Stack Control Interface ----------------------------------------------
      op_i    : in  stack_op_t;
      -- Program Counter Interface --------------------------------------------
      pc_i    : in  pc_t;
      pc_o    : out pc_t
    );
  end component;

  component t400_pmem_ctrl
    generic (
      opt_type_g : integer := t400_opt_type_420_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i       : in  std_logic;
      ck_en_i    : in  boolean;
      por_i      : in  boolean;
      res_i      : in  boolean;
      a_i        : in  dw_t;
      m_i        : in  dw_t;
      -- Control Interface ----------------------------------------------------
      op_i       : in  pc_op_t;
      dec_data_i : in  dec_data_t;
      -- Stack Interface ------------------------------------------------------
      pc_o       : out pc_t;
      pc_i       : in  pc_t;
      -- Program Memory Interface ---------------------------------------------
      pm_addr_o  : out pc_t
    );
  end component;

  component t400_alu
    generic (
      opt_cko_g : integer := t400_opt_cko_crystal_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i       : in  std_logic;
      ck_en_i    : in  boolean;
      por_i      : in  boolean;
      res_i      : in  boolean;
      cko_i      : in  std_logic;
      -- Control Interface ----------------------------------------------------
      op_i       : in  alu_op_t;
      -- Data Interface -------------------------------------------------------
      m_i        : in  dw_t;
      dec_data_i : in  dec_data_t;
      q_low_i    : in  dw_t;
      b_i        : in  b_t;
      g_i        : in  dw_t;
      in_i       : in  dw_t;
      sio_i      : in  dw_t;
      a_o        : out dw_t;
      carry_o    : out std_logic;
      c_o        : out std_logic
    );
  end component;

  component t400_dmem_ctrl
    generic (
      opt_type_g : integer := t400_opt_type_420_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i       : in  std_logic;
      ck_en_i    : in  boolean;
      por_i      : in  boolean;
      res_i      : in  boolean;
      -- Control Interface ----------------------------------------------------
      dmem_op_i  : in  dmem_op_t;
      b_op_i     : in  b_op_t;
      dec_data_i : in  dec_data_t;
      a_i        : in  dw_t;
      q_high_i   : in  dw_t;
      b_o        : out b_t;
      -- Data Memory Interface ------------------------------------------------
      dm_addr_o  : out dm_addr_t;
      dm_data_i  : in  dw_t;
      dm_data_o  : out dw_t;
      dm_we_o    : out std_logic
    );
  end component;

  component t400_decoder
    generic (
      opt_type_g : integer := t400_opt_type_420_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i       : in  std_logic;
      ck_en_i    : in  boolean;
      por_i      : in  boolean;
      res_i      : in  boolean;
      out_en_i   : in  boolean;
      in_en_i    : in  boolean;
      icyc_en_i  : in  boolean;
      -- Module Control Interface ---------------------------------------------
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
      -- Skip Interface -------------------------------------------------------
      skip_i     : in  boolean;
      skip_lbi_i : in  boolean;
      is_lbi_o   : out boolean;
      int_i      : in  boolean;
      -- Program Memory Interface ---------------------------------------------
      pm_addr_i  : in  pc_t;
      pm_data_i  : in  byte_t
    );
  end component;

  component t400_skip
    generic (
      opt_type_g : integer := t400_opt_type_420_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i       : in  std_logic;
      ck_en_i    : in  boolean;
      por_i      : in  boolean;
      res_i      : in  boolean;
      -- Control Interface ----------------------------------------------------
      op_i       : in  skip_op_t;
      dec_data_i : in  dec_data_t;
      carry_i    : in  std_logic;
      c_i        : in  std_logic;
      bd_i       : in  dw_t;
      is_lbi_i   : in  boolean;
      skip_o     : out boolean;
      skip_lbi_o : out boolean;
      -- Data Interface -------------------------------------------------------
      a_i        : in  dw_t;
      m_i        : in  dw_t;
      g_i        : in  dw_t;
      tim_c_i    : in  boolean
    );
  end component;

  component t400_io_l
    generic (
      opt_out_type_7_g : integer := t400_opt_out_type_std_c;
      opt_out_type_6_g : integer := t400_opt_out_type_std_c;
      opt_out_type_5_g : integer := t400_opt_out_type_std_c;
      opt_out_type_4_g : integer := t400_opt_out_type_std_c;
      opt_out_type_3_g : integer := t400_opt_out_type_std_c;
      opt_out_type_2_g : integer := t400_opt_out_type_std_c;
      opt_out_type_1_g : integer := t400_opt_out_type_std_c;
      opt_out_type_0_g : integer := t400_opt_out_type_std_c;
      opt_microbus_g   : integer := t400_opt_no_microbus_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i      : in  std_logic;
      ck_en_i   : in  boolean;
      por_i     : in  boolean;
      in_en_i   : in  boolean;
      -- Control Interface ----------------------------------------------------
      op_i      : in  io_l_op_t;
      en2_i     : in  std_logic;
      m_i       : in  dw_t;
      a_i       : in  dw_t;
      pm_data_i : in  byte_t;
      q_o       : out byte_t;
      -- Microbus Interface ---------------------------------------------------
      cs_n_i    : in  std_logic;
      rd_n_i    : in  std_logic;
      wr_n_i    : in  std_logic;
      -- Port L Interface -----------------------------------------------------
      io_l_i    : in  byte_t;
      io_l_o    : out byte_t;
      io_l_en_o : out byte_t
    );
  end component;

  component t400_io_d
    generic (
      opt_out_type_3_g : integer := t400_opt_out_type_std_c;
      opt_out_type_2_g : integer := t400_opt_out_type_std_c;
      opt_out_type_1_g : integer := t400_opt_out_type_std_c;
      opt_out_type_0_g : integer := t400_opt_out_type_std_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i      : in  std_logic;
      ck_en_i   : in  boolean;
      por_i     : in  boolean;
      res_i     : in  boolean;
      -- Control Interface ----------------------------------------------------
      op_i      : in  io_d_op_t;
      bd_i      : in  bd_t;
      -- Port D Interface -----------------------------------------------------
      io_d_o    : out dw_t;
      io_d_en_o : out dw_t
    );
  end component;

  component t400_io_g
    generic (
      opt_out_type_3_g : integer := t400_opt_out_type_std_c;
      opt_out_type_2_g : integer := t400_opt_out_type_std_c;
      opt_out_type_1_g : integer := t400_opt_out_type_std_c;
      opt_out_type_0_g : integer := t400_opt_out_type_std_c;
      opt_microbus_g   : integer := t400_opt_no_microbus_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i       : in  std_logic;
      ck_en_i    : in  boolean;
      por_i      : in  boolean;
      res_i      : in  boolean;
      cs_n_i     : in  std_logic;
      wr_n_i     : in  std_logic;
      -- Control Interface ----------------------------------------------------
      op_i       : in  io_g_op_t;
      m_i        : in  dw_t;
      dec_data_i : in  dec_data_t;
      -- Port G Interface -----------------------------------------------------
      io_g_o     : out dw_t;
      io_g_en_o  : out dw_t
    );
  end component;

  component t400_io_in
    port (
      -- System Interface -----------------------------------------------------
      ck_i      : in  std_logic;
      ck_en_i   : in  boolean;
      por_i     : in  boolean;
      icyc_en_i : in boolean;
      in_en_i   : in  boolean;
      -- Control Interface ----------------------------------------------------
      op_i      : in  io_in_op_t;
      en1_i     : in  std_logic;
      -- Port Interface -------------------------------------------------------
      io_in_i   : in  dw_t;
      in_o      : out dw_t;
      int_o     : out boolean
    );
  end component;

  component t400_sio
    generic (
      opt_so_output_type_g : integer := t400_opt_out_type_std_c;
      opt_sk_output_type_g : integer := t400_opt_out_type_std_c
    );
    port (
      -- System Interface -----------------------------------------------------
      ck_i       : in  std_logic;
      ck_en_i    : in  boolean;
      por_i      : in  boolean;
      res_i      : in  boolean;
      phi1_i     : in  std_logic;
      out_en_i   : in  boolean;
      in_en_i    : in  boolean;
      -- Control Interface ----------------------------------------------------
      op_i       : in  sio_op_t;
      en0_i      : in  std_logic;
      en3_i      : in  std_logic;
      -- SIO Interface --------------------------------------------------------
      a_i        : in  dw_t;
      c_i        : in  std_logic;
      sio_o      : out dw_t;
      -- Pad Interface --------------------------------------------------------
      si_i       : in  std_logic;
      so_o       : out std_logic;
      so_en_o    : out std_logic;
      sk_o       : out std_logic;
      sk_en_o    : out std_logic
    );
  end component;

  component t400_timer
    port (
      -- System Interface -----------------------------------------------------
      ck_i      : in  std_logic;
      ck_en_i   : in  boolean;
      por_i     : in  boolean;
      icyc_en_i : in  boolean;
      -- Skip Interface -------------------------------------------------------
      op_i      : in  skip_op_t;
      c_o       : out boolean
    );
  end component;

end t400_comp_pack;
