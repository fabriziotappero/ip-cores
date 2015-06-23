-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_v4_dm_iob.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:25 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Places the data mask signals into the IOBs.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_v4_dm_iob is
  port(
    clk90          : in  std_logic;
    mask_data_rise : in  std_logic;
    mask_data_fall : in  std_logic;
    ddr_dm         : out std_logic
    );
end MIG_v4_dm_iob;

architecture arch of MIG_v4_dm_iob is

  signal vcc       : std_logic;
  signal gnd       : std_logic;
  signal data_mask : std_logic;

begin

  vcc <= '1';
  gnd <= '0';

  oddr_dm : ODDR
    generic map(
      SRTYPE       => "SYNC",
      DDR_CLK_EDGE => "SAME_EDGE"
      )
    port map(
      Q  => data_mask,
      C  => clk90,
      CE => vcc,
      D1 => mask_data_rise,
      D2 => mask_data_fall,
      R  => gnd,
      S  => gnd
      );

  DM_OBUF : OBUF
    port map (
      I => data_mask,
      O => ddr_dm
      );


end arch;
