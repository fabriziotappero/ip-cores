-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_backend_fifos_0.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:24 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: This module instantiates the modules containing internal FIFOs
--              to store the data and the address.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.MIG_parameters_0.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_backend_fifos_0 is
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
end MIG_backend_fifos_0;

architecture arch of MIG_backend_fifos_0 is

  component MIG_rd_wr_addr_fifo_0
    port(
      clk0           : in  std_logic;
      clk90          : in  std_logic;
      rst            : in  std_logic;
      app_af_addr    : in  std_logic_vector(35 downto 0);
      app_af_wren    : in  std_logic;
      ctrl_af_rden   : in  std_logic;
      af_addr        : out std_logic_vector(35 downto 0);
      af_empty       : out std_logic;
      af_almost_full : out std_logic
      );
  end component;

  component MIG_wr_data_fifo_16
    port(
      clk0              : in  std_logic;
      clk90             : in  std_logic;
      rst               : in  std_logic;
      app_wdf_data      : in  std_logic_vector(31 downto 0);
      app_mask_data     : in  std_logic_vector(3 downto 0);
      app_wdf_wren      : in  std_logic;
      ctrl_wdf_rden     : in  std_logic;
      wdf_data          : out std_logic_vector(31 downto 0);
      mask_data         : out std_logic_vector(3 downto 0);
      wr_df_almost_full : out std_logic
      );
  end component;

  component MIG_wr_data_fifo_8
    port(
      clk0              : in  std_logic;
      clk90             : in  std_logic;
      rst               : in  std_logic;
      app_wdf_data      : in  std_logic_vector(15 downto 0);
      app_mask_data     : in  std_logic_vector(1 downto 0);
      app_wdf_wren      : in  std_logic;
      ctrl_wdf_rden     : in  std_logic;
      wdf_data          : out std_logic_vector(15 downto 0);
      mask_data         : out std_logic_vector(1 downto 0);
      wr_df_almost_full : out std_logic
      );
  end component;

  signal wr_df_almost_full_w : std_logic_vector(FIFO_16-1 downto 0);

begin

  wdf_almost_full <= wr_df_almost_full_w(0);

  rd_wr_addr_fifo_00 : MIG_rd_wr_addr_fifo_0
    port map (
      clk0           => clk0,
      clk90          => clk90,
      rst            => rst,
      app_af_addr    => app_af_addr,
      app_af_wren    => app_af_wren,
      ctrl_af_rden   => ctrl_af_rden,
      af_addr        => af_addr,
      af_empty       => af_empty,
      af_almost_full => af_almost_full
      );

  
wr_data_fifo_160 : MIG_wr_data_fifo_16
  port map (
          clk0              => clk0,
          clk90             => clk90,
          rst               => rst,
          app_wdf_data      => app_wdf_data(31 downto 0),
          app_mask_data     => app_mask_data(3 downto 0),
          app_wdf_wren      => app_Wdf_WrEn,
          ctrl_wdf_rden     => ctrl_Wdf_RdEn,
          wdf_data          => wdf_data(31 downto 0),
          mask_data         => mask_data(3 downto 0),
          wr_df_almost_full => wr_df_almost_full_w(0)
         );



wr_data_fifo_161 : MIG_wr_data_fifo_16
  port map (
          clk0              => clk0,
          clk90             => clk90,
          rst               => rst,
          app_wdf_data      => app_wdf_data(63 downto 32),
          app_mask_data     => app_mask_data(7 downto 4),
          app_wdf_wren      => app_Wdf_WrEn,
          ctrl_wdf_rden     => ctrl_Wdf_RdEn,
          wdf_data          => wdf_data(63 downto 32),
          mask_data         => mask_data(7 downto 4),
          wr_df_almost_full => wr_df_almost_full_w(1)
         );


  

end arch;
