-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_data_path_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Instantiates the tap logic and the data write modules. Gives
--              the rise and the fall data and the calibration information for
--              IDELAY elements.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_data_path_0 is
  port(
    clk                  : in std_logic;
    clk90                : in std_logic;
    reset0               : in std_logic;
    reset90              : in std_logic;
    idelay_ctrl_rdy      : in std_logic;
    dummy_write_pattern  : in std_logic;
    ctrl_dummyread_start : in std_logic;
    wdf_data             : in std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
    mask_data            : in std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
    ctrl_wren            : in std_logic;
    ctrl_dqs_rst         : in std_logic;
    ctrl_dqs_en          : in std_logic;
    dqs_delayed          : in std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
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
end MIG_data_path_0;

architecture arch of MIG_data_path_0 is

  component MIG_data_write_0
    port(
      clk                 : in std_logic;
      clk90               : in std_logic;
      reset90             : in std_logic;
      wdf_data            : in std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
      mask_data           : in std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
      dummy_write_pattern : in std_logic;
      ctrl_wren           : in std_logic;
      ctrl_dqs_rst        : in std_logic;
      ctrl_dqs_en         : in std_logic;
      dqs_rst             : out std_logic;
      dqs_en              : out std_logic;
      wr_en               : out std_logic;
      wr_data_rise        : out std_logic_vector((DATA_WIDTH - 1) downto 0);
      wr_data_fall        : out std_logic_vector((DATA_WIDTH - 1) downto 0);
      mask_data_rise      : out std_logic_vector((DATA_MASK_WIDTH - 1) downto 0);
      mask_data_fall      : out std_logic_vector((DATA_MASK_WIDTH - 1) downto 0)
      );
  end component;

  component MIG_tap_logic_0
    port(
      clk                  : in std_logic;
      reset0               : in std_logic;
      idelay_ctrl_rdy      : in std_logic;
      ctrl_dummyread_start : in std_logic;
      dqs_delayed          : in std_logic_vector((DATA_STROBE_WIDTH - 1) downto 0);
      data_idelay_inc      : out std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_ce       : out std_logic_vector((READENABLE - 1) downto 0);
      data_idelay_rst      : out std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_inc       : out std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_ce        : out std_logic_vector((READENABLE - 1) downto 0);
      dqs_idelay_rst       : out std_logic_vector((READENABLE - 1) downto 0);
      sel_done             : out std_logic
      );
  end component;

begin

  data_write_10: MIG_data_write_0
    port map (
      clk                  => clk,
      clk90                => clk90,
      reset90              => reset90,
      wdf_data             => wdf_data,
      mask_data            => mask_data,
      dummy_write_pattern  => dummy_write_pattern,
      ctrl_wren            => ctrl_wren,
      ctrl_dqs_rst         => ctrl_dqs_rst,
      ctrl_dqs_en          => ctrl_dqs_en,
      dqs_rst              => dqs_rst,
      dqs_en               => dqs_en,
      wr_en                => wr_en,
      wr_data_rise         => wr_data_rise,
      wr_data_fall         => wr_data_fall,
      mask_data_rise       => mask_data_rise,
      mask_data_fall       => mask_data_fall
      );

  tap_logic_00: MIG_tap_logic_0
    port map (
      clk                   => clk,
      reset0                => reset0,
      idelay_ctrl_rdy       => idelay_ctrl_rdy,
      ctrl_dummyread_start  => ctrl_dummyread_start,
      dqs_delayed           => dqs_delayed,
      data_idelay_inc       => data_idelay_inc,
      data_idelay_ce        => data_idelay_ce,
      data_idelay_rst       => data_idelay_rst,
      dqs_idelay_inc        => dqs_idelay_inc,
      dqs_idelay_ce         => dqs_idelay_ce,
      dqs_idelay_rst        => dqs_idelay_rst,
      sel_done              => sel_done
      );

end arch;
