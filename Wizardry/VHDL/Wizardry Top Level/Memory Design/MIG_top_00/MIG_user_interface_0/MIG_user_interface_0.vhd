-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_user_interface_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:25 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Interfaces with the user. The user should provide the data and
--              various commands.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_user_interface_0 is
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
end MIG_user_interface_0;

architecture arch of MIG_user_interface_0 is

  component MIG_rd_data_0
    port(
      clk                 : in  std_logic;
      reset               : in  std_logic;
      ctrl_rden           : in  std_logic;
      read_data_rise      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      read_data_fall      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      read_data_fifo_rise : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      read_data_fifo_fall : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      comp_done           : out std_logic;
      read_data_valid     : out std_logic
      );
  end component;

  component MIG_backend_fifos_0
    port(
      clk0            : in  std_logic;
      clk90           : in  std_logic;
      rst             : in  std_logic;
      app_af_addr     : in  std_logic_vector(35 downto 0);
      app_af_wren     : in  std_logic;
      ctrl_af_rden    : in  std_logic;
      af_addr         : out std_logic_vector(35 downto 0);
      af_empty        : out std_logic;
      af_almost_full  : out std_logic;
      app_wdf_data    : in  std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
      app_mask_data   : in  std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
      app_wdf_wren    : in  std_logic;
      ctrl_wdf_rden   : in  std_logic;
      wdf_data        : out std_logic_vector((DATA_WIDTH*2 - 1) downto 0);
      mask_data       : out std_logic_vector((DATA_MASK_WIDTH*2 - 1) downto 0);
      wdf_almost_full : out std_logic
      );
  end component;

  signal read_data_fifo_rise_i : std_logic_vector((DATA_WIDTH - 1) downto 0);
  signal read_data_fifo_fall_i : std_logic_vector((DATA_WIDTH - 1) downto 0);

begin

  read_data_fifo_out <= read_data_fifo_rise_i & read_data_fifo_fall_i;

  rd_data_00 : MIG_rd_data_0
    port map (
      clk                 => clk,
      reset               => reset,
      ctrl_rden           => ctrl_rden,
      read_data_rise      => read_data_rise,
      read_data_fall      => read_data_fall,
      read_data_fifo_rise => read_data_fifo_rise_i,
      read_data_fifo_fall => read_data_fifo_fall_i,
      comp_done           => comp_done,
      read_data_valid     => read_data_valid
      );

  backend_fifos_00 : MIG_backend_fifos_0
    port map (
      clk0            => clk,
      clk90           => clk90,
      rst             => reset,
      app_af_addr     => app_af_addr,
      app_af_wren     => app_af_wren,
      ctrl_af_rden    => ctrl_af_rden,
      af_addr         => af_addr,
      af_empty        => af_empty,
      af_almost_full  => af_almost_full,
      app_wdf_data    => app_wdf_data,
      app_mask_data   => app_mask_data,
      app_wdf_wren    => app_wdf_wren,
      ctrl_wdf_rden   => ctrl_wdf_rden,
      wdf_data        => wdf_data,
      mask_data       => mask_data,
      wdf_almost_full => wdf_almost_full
      );

end arch;
