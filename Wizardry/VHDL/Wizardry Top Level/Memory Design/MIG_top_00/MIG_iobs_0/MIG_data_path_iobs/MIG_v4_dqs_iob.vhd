-------------------------------------------------------------------------------
-- Copyright (c) 2005-2007 Xilinx, Inc.
-- This design is confidential and proprietary of Xilinx, All Rights Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /   Vendor             : Xilinx
-- \   \   \/    Version            : $Name: i+IP+131489 $
--  \   \        Application        : MIG
--  /   /        Filename           : MIG_v4_dqs_iob.vhd
-- /___/   /\    Date Last Modified : $Date: 2007/09/21 15:23:25 $
-- \   \  /  \   Date Created       : Mon May 2 2005
--  \___\/\___\
--
-- Device      : Virtex-4
-- Design Name : DDR SDRAM
-- Description: Places the data stobes in the IOBs.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity MIG_v4_dqs_iob is
  port(
    clk          : in    std_logic;
    dlyinc       : in    std_logic;
    dlyce        : in    std_logic;
    dlyrst       : in    std_logic;
    ctrl_dqs_rst : in    std_logic;
    ctrl_dqs_en  : in    std_logic;
    ddr_dqs      : inout std_logic;
    dqs_rise     : out   std_logic
    );
end MIG_v4_dqs_iob;

architecture arch of MIG_v4_dqs_iob is

  signal dqs_in         : std_logic;
  signal dqs_out        : std_logic;
  signal dqs_out_l      : std_logic;
  signal dqs_delayed    : std_logic;
  signal ctrl_dqs_en_r1 : std_logic;
  signal vcc            : std_logic;
  signal gnd            : std_logic;
  signal clk180         : std_logic;
  signal dqs_int        : std_logic;
  signal data1          : std_logic;
  
  attribute IOB : string;
  attribute IOB of tri_state_dqs : label is "true";
  attribute syn_useioff : boolean;
  attribute syn_useioff of tri_state_dqs : label is true;

begin

  vcc    <= '1';
  gnd    <= '0';
  clk180 <= not clk;

  process(clk180)
  begin
    if(clk180'event and clk180 = '1') then
      if (ctrl_dqs_rst = '1') then
        data1 <= '0';
      else
        data1 <= '1';
      end if;
    end if;
  end process;

  idelay_dqs : IDELAY
    generic map(
      IOBDELAY_TYPE  => "VARIABLE",
      IOBDELAY_VALUE => 0
      )
    port map(
      O   => dqs_delayed,
      I   => dqs_in,
      C   => clk,
      CE  => dlyce,
      INC => dlyinc,
      RST => dlyrst
      );

  dqs_pipe1 : FD
    port map(
      Q => dqs_int,
      C => clk,
      D => dqs_delayed
      );

  dqs_pipe2 : FD
    port map
    (Q  => dqs_rise,
      C => clk,
      D => dqs_int
      );

  oddr_dqs : ODDR
    generic map(
      SRTYPE       => "SYNC",
      DDR_CLK_EDGE => "OPPOSITE_EDGE"
      )
    port map
    (Q   => dqs_out,
      C  => clk180,
      CE => vcc,
      D1 => data1,
      D2 => gnd,
      R  => gnd,
      S  => gnd
      );

  tri_state_dqs : FD
    port map (
      Q => ctrl_dqs_en_r1,
      C => clk180,
      D => ctrl_dqs_en
      );

  iobuf_dqs : IOBUF
    port map (
      I  => dqs_out,
      T  => ctrl_dqs_en_r1,
      IO => ddr_dqs,
      O  => dqs_in
      );

end arch;
