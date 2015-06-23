-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_iobs_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: This module instantiates all the iobs modules. It is the
--              interface between the main logic and the memory.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_iobs_0 is
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
end MIG_iobs_0;

architecture arch of MIG_iobs_0 is

  component MIG_infrastructure_iobs_0
    port(
      clk       : in std_logic;
      ddr_ck    : out std_logic_vector((CLK_WIDTH - 1) downto 0);
      ddr_ck_n  : out std_logic_vector((CLK_WIDTH - 1) downto 0)
      );
  end component;

  component MIG_data_path_iobs_0
    port (
      clk             : in std_logic;
      clk90           : in std_logic;
      dqs_idelay_inc  : in std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_ce   : in std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_rst  : in std_logic_vector((READENABLE - 1) downto 0);
      dqs_rst         : in std_logic;
      dqs_en          : in std_logic;
      dqs_delayed     : out std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
      data_idelay_inc : in std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_ce  : in std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_rst : in std_logic_vector((READENABLE - 1) downto 0);
      wr_data_rise    : in std_logic_vector((DATA_WIDTH - 1) downto 0);
      wr_data_fall    : in std_logic_vector((DATA_WIDTH - 1) downto 0);
      wr_en           : in std_logic;
      rd_data_rise    : out std_logic_vector((DATA_WIDTH - 1) downto 0);
      rd_data_fall    : out std_logic_vector((DATA_WIDTH - 1) downto 0);
      mask_data_rise  : in std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
      mask_data_fall  : in std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
      ddr_dq          : inout std_logic_vector((DATA_WIDTH - 1) downto 0);
      ddr_dqs         : inout std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
      ddr_dm          : out std_logic_vector((DATA_MASK_WIDTH - 1) downto 0)
      );
  end component;

  component MIG_controller_iobs_0
    port (
      ctrl_ddr_address : in  std_logic_vector((ROW_ADDRESS - 1) downto 0);
      ctrl_ddr_ba      : in  std_logic_vector((BANK_ADDRESS - 1) downto 0);
      ctrl_ddr_ras_l   : in  std_logic;
      ctrl_ddr_cas_l   : in  std_logic;
      ctrl_ddr_we_l    : in  std_logic;
      ctrl_ddr_cs_l    : in  std_logic;
      ctrl_ddr_cke     : in  std_logic;
      ddr_address      : out std_logic_vector((ROW_ADDRESS - 1) downto 0);
      ddr_ba           : out std_logic_vector((BANK_ADDRESS - 1) downto 0);
      ddr_ras_l        : out std_logic;
      ddr_cas_l        : out std_logic;
      ddr_we_l         : out std_logic;
      ddr_cke          : out std_logic;
      ddr_cs_l         : out std_logic
      );
  end component;

begin

  infrastructure_iobs_00: MIG_infrastructure_iobs_0
    port map   (
      clk       => clk,
      ddr_ck    => ddr_ck,
      ddr_ck_n  => ddr_ck_n
      );

  data_path_iobs_00: MIG_data_path_iobs_0
    port map    (
      clk                       => clk,
      clk90                     => clk90,
      dqs_idelay_inc            => dqs_idelay_inc,
      dqs_idelay_ce             => dqs_idelay_ce,
      dqs_idelay_rst            => dqs_idelay_rst,
      dqs_rst                   => dqs_rst,
      dqs_en                    => dqs_en,
      dqs_delayed               => dqs_delayed,
      data_idelay_inc           => data_idelay_inc,
      data_idelay_ce            => data_idelay_ce,
      data_idelay_rst           => data_idelay_rst,
      wr_data_rise              => wr_data_rise,
      wr_data_fall              => wr_data_fall,
      wr_en                     => wr_en,
      rd_data_rise              => rd_data_rise,
      rd_data_fall              => rd_data_fall,
      mask_data_rise            => mask_data_rise,
      mask_data_fall            => mask_data_fall,
      ddr_dq                    => ddr_dq,
      ddr_dqs                   => ddr_dqs,
      ddr_dm                    => ddr_dm
      );

  controller_iobs_00: MIG_controller_iobs_0
    port map     (
      ctrl_ddr_address => ctrl_ddr_address,
      ctrl_ddr_ba      => ctrl_ddr_ba,
      ctrl_ddr_ras_l   => ctrl_ddr_ras_l,
      ctrl_ddr_cas_l   => ctrl_ddr_cas_l,
      ctrl_ddr_we_l    => ctrl_ddr_we_l,
      ctrl_ddr_cs_l    => ctrl_ddr_cs_l,
      ctrl_ddr_cke     => ctrl_ddr_cke,
      ddr_address      => ddr_address,
      ddr_ba           => ddr_ba,
      ddr_ras_l        => ddr_ras_l,
      ddr_cas_l        => ddr_cas_l,
      ddr_we_l         => ddr_we_l,
      ddr_cke          => ddr_cke,
      ddr_cs_l         => ddr_cs_l
      );

end arch;
