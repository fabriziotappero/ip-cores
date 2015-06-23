-- $Id: tb_tst_serloop1_n4.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    tb_tst_serloop1_n4 - sim
-- Description:    Test bench for sys_tst_serloop1_n4
--
-- Dependencies:   simlib/simclk
--                 sys_tst_serloop1_n4 [UUT]
--                 tb/tb_tst_serloop
--
-- To test:        sys_tst_serloop1_n4
--
-- Target Devices: generic
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-02-21   438   1.0    Initial version (cloned from tb_tst_serloop1_n3)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;
use work.simlib.all;

entity tb_tst_serloop1_n4 is
end tb_tst_serloop1_n4;

architecture sim of tb_tst_serloop1_n4 is
  
  signal CLK100 : slbit := '0';
  signal CLK_STOP  : slbit := '0';

  signal I_RXD : slbit := '1';
  signal O_TXD : slbit := '1';
  signal O_RTS_N : slbit := '0';
  signal I_CTS_N : slbit := '0';
  signal I_SWI : slv16 := (others=>'0');
  signal I_BTN : slv5 := (others=>'0');

  signal RXD : slbit := '1';
  signal TXD : slbit := '1';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
  signal SWI : slv16 := (others=>'0');
  signal BTN : slv5 := (others=>'0');
  
  constant clock_period : time :=   10 ns;
  constant clock_offset : time :=  200 ns;
  constant delay_time :   time :=    2 ns;
  
begin

  SYSCLK : simclk
    generic map (
      PERIOD => clock_period,
      OFFSET => clock_offset)
    port map (
      CLK       => CLK100,
      CLK_STOP  => CLK_STOP
    );

  UUT : entity work.sys_tst_serloop1_n4
    port map (
      I_CLK100     => CLK100,
      I_RXD        => I_RXD,
      O_TXD        => O_TXD,
      O_RTS_N      => O_RTS_N,
      I_CTS_N      => I_CTS_N,
      I_SWI        => I_SWI,
      I_BTN        => I_BTN,
      I_BTNRST_N   => '1',
      O_LED        => open,
      O_RGBLED0    => open,
      O_RGBLED1    => open,
      O_ANO_N      => open,
      O_SEG_N      => open
    );

  GENTB : entity work.tb_tst_serloop
    port map (
      CLKS      => CLK100,
      CLKH      => CLK100,
      CLK_STOP  => CLK_STOP,
      P0_RXD    => RXD,
      P0_TXD    => TXD,
      P0_RTS_N  => RTS_N,
      P0_CTS_N  => CTS_N,
      P1_RXD    => RXD,
      P1_TXD    => TXD,
      P1_RTS_N  => RTS_N,
      P1_CTS_N  => CTS_N,
      SWI       => SWI(7 downto 0),
      BTN       => BTN(3 downto 0)
    );

  I_RXD        <= RXD          after delay_time;
  TXD          <= O_TXD        after delay_time;
  RTS_N        <= O_RTS_N      after delay_time;
  I_CTS_N      <= CTS_N        after delay_time;

  I_SWI <= SWI after delay_time;
  I_BTN <= BTN after delay_time;

end sim;
