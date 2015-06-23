-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_v4_dq_iob.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:25 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Places the data in the IOBs.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_v4_dq_iob is
  port(
    clk             : in    std_logic;
    clk90           : in    std_logic;
    data_dlyinc     : in    std_logic;
    data_dlyce      : in    std_logic;
    data_dlyrst     : in    std_logic;
    write_data_rise : in    std_logic;
    write_data_fall : in    std_logic;
    ctrl_wren       : in    std_logic;
    ddr_dq          : inout std_logic;
    read_data_rise  : out   std_logic;
    read_data_fall  : out   std_logic
    );
end MIG_v4_dq_iob;

architecture arch of MIG_v4_dq_iob is

  signal dq_in         : std_logic;
  signal dq_out        : std_logic;
  signal dq_delayed    : std_logic;
  signal write_en_l    : std_logic;
  signal write_en_l_r1 : std_logic;
  signal vcc           : std_logic;
  signal gnd           : std_logic;

  attribute IOB : string;
  attribute IOB of tri_state_dq : label is "true";
  attribute syn_useioff : boolean;
  attribute syn_useioff of tri_state_dq : label is true;

begin


  vcc <= '1';
  gnd <= '0';

  write_en_l <= not ctrl_wren;

  oddr_dq : ODDR
    generic map(
      SRTYPE       => "SYNC",
      DDR_CLK_EDGE => "SAME_EDGE"
      )
    port map(
      Q  => dq_out,
      C  => clk90,
      CE => vcc,
      D1 => write_data_rise,
      D2 => write_data_fall,
      R  => gnd,
      S  => gnd
      );

  tri_state_dq : FDCE
    port map(
      Q   => write_en_l_r1,
      C   => clk90,
      CE  => vcc,
      CLR => gnd,
      D   => write_en_l
      );

  iobuf_dq : IOBUF port map
    (
      I  => dq_out,
      T  => write_en_l_r1,
      IO => ddr_dq,
      O  => dq_in
      );

  idelay_dq : IDELAY
    generic map(
      IOBDELAY_TYPE  => "VARIABLE",
      IOBDELAY_VALUE => 0
      )
    port map(
      O   => dq_delayed,
      I   => dq_in,
      C   => clk,
      CE  => data_dlyce,
      INC => data_dlyinc,
      RST => data_dlyrst
      );

  iddr_dq : IDDR
    generic map(
      SRTYPE       => "SYNC",
      DDR_CLK_EDGE => "SAME_EDGE_PIPELINED"
      )
    port map (
      Q1 => read_data_rise,
      Q2 => read_data_fall,
      C  => clk,
      CE => vcc,
      D  => dq_delayed,
      R  => gnd,
      S  => gnd
      );

end arch;
