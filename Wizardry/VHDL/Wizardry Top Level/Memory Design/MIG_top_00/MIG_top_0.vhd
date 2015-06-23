-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_top_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Instantiates the main design logic of memory interface and
--              interfaces with the user.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_top_0 is
  port(
    clk_0              : in    std_logic;
    clk_90             : in    std_logic;
    idelay_ctrl_rdy    : in    std_logic;
    sys_rst            : in    std_logic;
    sys_rst90          : in    std_logic;
    ddr_ras_n          : out   std_logic;
    ddr_cas_n          : out   std_logic;
    ddr_we_n           : out   std_logic;
    ddr_cke            : out   std_logic;
    ddr_cs_n           : out   std_logic;
    ddr_dq             : inout std_logic_vector((DATA_WIDTH - 1) downto 0);
    ddr_dqs            : inout std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
ddr_dm                 : out std_logic_vector((DATA_MASK_WIDTH-1) downto 0);
    app_mask_data          : in std_logic_vector((DATA_MASK_WIDTH*2 -1) downto 0);

    ddr_ck             : out   std_logic_vector((CLK_WIDTH - 1) downto 0);
    ddr_ck_n           : out   std_logic_vector((CLK_WIDTH - 1) downto 0);
    ddr_ba             : out   std_logic_vector((BANK_ADDRESS - 1) downto 0);
    ddr_a              : out   std_logic_vector((ROW_ADDRESS - 1) downto 0);
    wdf_almost_full    : out   std_logic;
    af_almost_full     : out   std_logic;
    burst_length_div2  : out   std_logic_vector(2 downto 0);
    read_data_valid    : out   std_logic;
    read_data_fifo_out : out   std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
    app_af_addr        : in    std_logic_vector(35 downto 0);
    app_af_wren        : in    std_logic;
    app_wdf_data       : in    std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
    app_wdf_wren       : in    std_logic;
    init_done          : out   std_logic;
    clk_tb             : out   std_logic;
    reset_tb           : out   std_logic
    );
end MIG_top_0;

architecture arch of MIG_top_0 is

  component MIG_data_path_0
    port(
      clk                  : in  std_logic;
      clk90                : in  std_logic;
      reset0               : in  std_logic;
      reset90              : in  std_logic;
      idelay_ctrl_rdy      : in  std_logic;
      dummy_write_pattern  : in  std_logic;
      ctrl_dummyread_start : in  std_logic;
      wdf_data             : in  std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
      mask_data            : in  std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
      ctrl_wren            : in  std_logic;
      ctrl_dqs_rst         : in  std_logic;
      ctrl_dqs_en          : in  std_logic;
      dqs_delayed          : in  std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
      data_idelay_inc      : out std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_ce       : out std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_rst      : out std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_inc       : out std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_ce        : out std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_rst       : out std_logic_vector((READENABLE - 1) downto 0);
      sel_done             : out std_logic;
      dqs_rst              : out std_logic;
      dqs_en               : out std_logic;
      wr_en                : out std_logic;
      wr_data_rise         : out std_logic_vector((DATA_WIDTH - 1) downto 0);
      wr_data_fall         : out std_logic_vector((DATA_WIDTH - 1) downto 0);
      mask_data_rise       : out std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
      mask_data_fall       : out std_logic_vector((DATA_MASK_WIDTH - 1) downto 0)
      );
  end component;

  component MIG_iobs_0
    port(
      ddr_ck           : out   std_logic_vector((CLK_WIDTH - 1) downto 0);
      ddr_ck_n         : out   std_logic_vector((CLK_WIDTH - 1) downto 0);
      clk              : in    std_logic;
      clk90            : in    std_logic;
      dqs_idelay_inc   : in    std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_ce    : in    std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_rst   : in    std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_inc  : in    std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_ce   : in    std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_rst  : in    std_logic_vector((READENABLE - 1) downto 0);
      dqs_rst          : in    std_logic;
      dqs_en           : in    std_logic;
      wr_en            : in    std_logic;
      wr_data_rise     : in    std_logic_vector((DATA_WIDTH - 1) downto 0);
      wr_data_fall     : in    std_logic_vector((DATA_WIDTH - 1) downto 0);
      mask_data_rise   : in    std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
      mask_data_fall   : in    std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
      rd_data_rise     : out   std_logic_vector((DATA_WIDTH - 1) downto 0);
      rd_data_fall     : out   std_logic_vector((DATA_WIDTH - 1) downto 0);
      dqs_delayed      : out   std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
      ddr_dq           : inout std_logic_vector((DATA_WIDTH - 1) downto 0);
      ddr_dqs          : inout std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
      ddr_dm           : out   std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
      ctrl_ddr_address : in    std_logic_vector((ROW_ADDRESS - 1) downto 0);
      ctrl_ddr_ba      : in    std_logic_vector((BANK_ADDRESS - 1) downto 0);
      ctrl_ddr_ras_l   : in    std_logic;
      ctrl_ddr_cas_l   : in    std_logic;
      ctrl_ddr_we_l    : in    std_logic;
      ctrl_ddr_cs_l    : in    std_logic;
      ctrl_ddr_cke     : in    std_logic;
      ddr_address      : out   std_logic_vector((ROW_ADDRESS - 1) downto 0);
      ddr_ba           : out   std_logic_vector((BANK_ADDRESS - 1) downto 0);
      ddr_ras_l        : out   std_logic;
      ddr_cas_l        : out   std_logic;
      ddr_we_l         : out   std_logic;
      ddr_cke          : out   std_logic;
      ddr_cs_l         : out   std_logic
      );
  end component;

  component MIG_user_interface_0
    port(
      clk                : in  std_logic;
      clk90              : in  std_logic;
      reset              : in  std_logic;
      ctrl_rden          : in  std_logic;
      read_data_rise     : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
      read_data_fall     : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
      read_data_fifo_out : out std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
      comp_done          : out std_logic;
      read_data_valid    : out std_logic;
      af_empty           : out std_logic;
      af_almost_full     : out std_logic;
      app_af_addr        : in  std_logic_vector(35 downto 0);
      app_af_wren        : in  std_logic;
      ctrl_af_rden       : in  std_logic;
      af_addr            : out std_logic_vector(35 downto 0);
      app_wdf_data       : in  std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
      app_mask_data      : in  std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
      app_wdf_wren       : in  std_logic;
      ctrl_wdf_rden      : in  std_logic;
      wdf_data           : out std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
      mask_data          : out std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
      wdf_almost_full    : out std_logic
      );
  end component;

  component MIG_ddr_controller_0
    port(
      clk_0                : in  std_logic;
      rst                  : in  std_logic;
      af_addr              : in  std_logic_vector(35 downto 0);
      af_empty             : in  std_logic;
      comp_done            : in  std_logic;
      phy_dly_slct_done    : in  std_logic;
      ctrl_dummyread_start : out std_logic;
      ctrl_af_rden         : out std_logic;
      ctrl_wdf_rden        : out std_logic;
      ctrl_dqs_rst         : out std_logic;
      ctrl_dqs_en          : out std_logic;
      ctrl_wren            : out std_logic;
      ctrl_rden            : out std_logic;
      ctrl_ddr_address     : out std_logic_vector((ROW_ADDRESS - 1) downto 0);
      ctrl_ddr_ba          : out std_logic_vector((BANK_ADDRESS - 1) downto 0);
      ctrl_ddr_ras_l       : out std_logic;
      ctrl_ddr_cas_l       : out std_logic;
      ctrl_ddr_we_l        : out std_logic;
      ctrl_ddr_cs_l        : out std_logic;
      ctrl_ddr_cke         : out std_logic;
      init_done            : out std_logic;
      dummy_write_pattern  : out std_logic;
      burst_length_div2    : out std_logic_vector(2 downto 0)
      );
  end component;



  signal wr_df_data          : std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
  signal mask_df_data        : std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
  signal rd_data_rise        : std_logic_vector((DATA_WIDTH - 1) downto 0);
  signal rd_data_fall        : std_logic_vector((DATA_WIDTH - 1) downto 0);
  signal af_empty_w          : std_logic;
  signal dq_tap_sel_done     : std_logic;
  signal af_addr             : std_logic_vector(35 downto 0);
  signal ctrl_af_rden        : std_logic;
  signal ctrl_wr_df_rden     : std_logic;
  signal ctrl_dummy_rden     : std_logic;
  signal ctrl_dqs_enable     : std_logic;
  signal ctrl_dqs_reset      : std_logic;
  signal ctrl_wr_en          : std_logic;
  signal ctrl_rden           : std_logic;
  signal dqs_idelay_inc      : std_logic_vector((READENABLE - 1) downto 0);
  signal dqs_idelay_ce       : std_logic_vector((READENABLE - 1) downto 0);
  signal dqs_idelay_rst      : std_logic_vector((READENABLE - 1) downto 0);
  signal data_idelay_inc     : std_logic_vector((READENABLE - 1) downto 0);
  signal data_idelay_ce      : std_logic_vector((READENABLE - 1) downto 0);
  signal data_idelay_rst     : std_logic_vector((READENABLE - 1) downto 0);
  signal wr_en               : std_logic;
  signal dqs_rst             : std_logic;
  signal dqs_en              : std_logic;
  signal wr_data_rise        : std_logic_vector((DATA_WIDTH - 1) downto 0);
  signal wr_data_fall        : std_logic_vector((DATA_WIDTH - 1) downto 0);
  signal dqs_delayed         : std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
  signal mask_data_fall      : std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
  signal mask_data_rise      : std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
  signal ctrl_ddr_address    : std_logic_vector((ROW_ADDRESS - 1) downto 0);
  signal ctrl_ddr_ba         : std_logic_vector((BANK_ADDRESS - 1) downto 0);
  signal ctrl_ddr_ras_l      : std_logic;
  signal ctrl_ddr_cas_l      : std_logic;
  signal ctrl_ddr_we_l       : std_logic;
  signal ctrl_ddr_cs_l       : std_logic;
  signal ctrl_ddr_cke        : std_logic;
  signal duMmy_write_pattern : std_logic;
  signal comp_done       : std_logic;



begin

  clk_tb    <= clk_0;
  reset_tb  <= sys_rst;



  data_path_00 : MIG_data_path_0
    port map (
      clk                  => clk_0,
      clk90                => clk_90,
      reset0               => sys_rst,
      reset90              => sys_rst90,
      idelay_ctrl_rdy      => idelay_ctrl_rdy,
      dummy_write_pattern  => dummy_write_pattern,
      ctrl_dummyread_start => ctrl_dummy_rden,
      wdf_data             => wr_df_data,
      mask_data            => mask_df_data,
      ctrl_wren            => ctrl_wr_en,
      ctrl_dqs_rst         => ctrl_dqs_reset,
      ctrl_dqs_en          => ctrl_dqs_enable,
      dqs_delayed          => dqs_delayed,
      data_idelay_inc      => data_idelay_inc,
      data_idelay_ce       => data_idelay_ce,
      data_idelay_rst      => data_idelay_rst,
      dqs_idelay_inc       => dqs_idelay_inc,
      dqs_idelay_ce        => dqs_idelay_ce,
      dqs_idelay_rst       => dqs_idelay_rst,
      sel_done             => dq_tap_sel_done,
      dqs_rst              => dqs_rst,
      dqs_en               => dqs_en,
      wr_en                => wr_en,
      wr_data_rise         => wr_data_rise,
      wr_data_fall         => wr_data_fall,
      mask_data_rise       => mask_data_rise,
      mask_data_fall       => mask_data_fall
      );

  iobs_00 : MIG_iobs_0
    port map (
      ddr_ck           => ddr_ck,
      ddr_ck_n         => ddr_ck_n,
      clk              => clk_0,
      clk90            => clk_90,
      dqs_idelay_inc   => dqs_idelay_inc,
      dqs_idelay_ce    => dqs_idelay_ce,
      dqs_idelay_rst   => dqs_idelay_rst,
      data_idelay_inc  => data_idelay_inc,
      data_idelay_ce   => data_idelay_ce,
      data_idelay_rst  => data_idelay_rst,
      dqs_rst          => dqs_rst,
      dqs_en           => dqs_en,
      wr_en            => wr_en,
      wr_data_rise     => wr_data_rise,
      wr_data_fall     => wr_data_fall,
      mask_data_rise   => mask_data_rise,
      mask_data_fall   => mask_data_fall,
      rd_data_rise     => rd_data_rise,
      rd_data_fall     => rd_data_fall,
      dqs_delayed      => dqs_delayed,
      ddr_dq           => ddr_dq,
      ddr_dqs          => ddr_dqs,
      ddr_dm           => ddr_dm,
      ctrl_ddr_address => ctrl_ddr_address,
      ctrl_ddr_ba      => ctrl_ddr_ba,
      ctrl_ddr_ras_l   => ctrl_ddr_ras_l,
      ctrl_ddr_cas_l   => ctrl_ddr_cas_l,
      ctrl_ddr_we_l    => ctrl_ddr_we_l,
      ctrl_ddr_cs_l    => ctrl_ddr_cs_l,
      ctrl_ddr_cke     => ctrl_ddr_cke,
      ddr_address      => ddr_a,
      ddr_ba           => ddr_ba,
      ddr_ras_l        => ddr_ras_n,
      ddr_cas_l        => ddr_cas_n,
      ddr_we_l         => ddr_we_n,
      ddr_cke          => ddr_cke,
      ddr_cs_l         => ddr_cs_n
      );

  user_interface_00 : MIG_user_interface_0
    port map (
      clk                => clk_0,
      clk90              => clk_90,
      reset              => sys_rst,
      ctrl_rden          => ctrl_rden,
      read_data_rise     => rd_data_rise,
      read_data_fall     => rd_data_fall,
      read_data_fifo_out => read_data_fifo_out,
      comp_done          => comp_done,
      read_data_valid    => read_data_valid,
      af_empty           => af_empty_w,
      af_almost_full     => af_almost_full,
      app_af_addr        => app_af_addr,
      app_af_wren        => app_af_wren,
      ctrl_af_rden       => ctrl_af_rden,
      af_addr            => af_addr,
      app_wdf_data       => app_wdf_data,
      app_mask_data      => app_mask_data,
      app_wdf_wren       => app_wdf_wren,
      ctrl_wdf_rden      => ctrl_wr_df_rden,
      wdf_data           => wr_df_data,
      mask_data          => mask_df_data,
      wdf_almost_full    => wdf_almost_full
      );

  ddr_controller_00 : MIG_ddr_controller_0
    port map (
      clk_0                => clk_0,
      rst                  => sys_rst,
      af_addr              => af_addr,
      af_empty             => af_empty_w,
      phy_dly_slct_done    => dq_tap_sel_done,
      comp_done            => comp_done,
      ctrl_dummyread_start => ctrl_dummy_rden,
      ctrl_af_rden         => ctrl_af_rden,
      ctrl_wdf_rden        => ctrl_wr_df_rden,
      ctrl_dqs_rst         => ctrl_dqs_reset,
      ctrl_dqs_en          => ctrl_dqs_enable,
      ctrl_wren            => ctrl_wr_en,
      ctrl_rden            => ctrl_rden,
      ctrl_ddr_address     => ctrl_ddr_address,
      ctrl_ddr_ba          => ctrl_ddr_ba,
      ctrl_ddr_ras_l       => ctrl_ddr_ras_l,
      ctrl_ddr_cas_l       => ctrl_ddr_cas_l,
      ctrl_ddr_we_l        => ctrl_ddr_we_l,
      ctrl_ddr_cs_l        => ctrl_ddr_cs_l,
      ctrl_ddr_cke         => ctrl_ddr_cke,
      init_done            => init_done,
      dummy_write_pattern  => dummy_write_pattern,
      burst_length_div2    => burst_length_div2
      );


end arch;
