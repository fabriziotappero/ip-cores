-- $Id: rbd_tst_rlink.vhd 620 2014-12-25 10:48:35Z mueller $
--
-- Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    rbd_tst_rlink - syn
-- Description:    rbus device for tst_rlink
--
-- Dependencies:   rbus/rbd_tester
--                 rbus/rbd_bram
--                 rbus/rbd_rbmon
--                 rbus/rbd_eyemon
--                 rbus/rbd_timer
--                 rbus/rb_sres_or_3
--                 rbus/rb_sres_or_4
--
-- Test bench:     nexys3/tb/tb_tst_rlink_n3
--
-- Target Devices: generic
-- Tool versions:  xst 13.1-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-11-09   603   4.0    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   3.5    rb_mreq addr now 16 bit
-- 2011-11-11   351   1.0    Initial version (derived from tst_rlink)
------------------------------------------------------------------------------
-- Usage of STAT signal:
--   STAT(0):   timer 0 busy 
--   STAT(1):   timer 1 busy 
--   STAT(2:3): unused

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;
use work.rbdlib.all;

-- ----------------------------------------------------------------------------

entity rbd_tst_rlink is                 -- rbus device for tst_rlink
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_USEC : in slbit;                 -- usec pulse
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv4;                 -- rbus: status flags
    RB_SRES_TOP : in rb_sres_type;      -- top-level rb_sres, for rbd_mon
    RXSD : in slbit;                    -- serport rxsd, for rbd_eyemon
    RXACT : in slbit;                   -- serport rxact, for rbd_eyemon
    STAT : out slv8                     -- status flags

  );
end rbd_tst_rlink;

architecture syn of rbd_tst_rlink is

  signal RB_SRES_TEST  : rb_sres_type := rb_sres_init;
  signal RB_SRES_BRAM  : rb_sres_type := rb_sres_init;
  signal RB_SRES_MON   : rb_sres_type := rb_sres_init;
  signal RB_SRES_EMON  : rb_sres_type := rb_sres_init;
  signal RB_SRES_TIM0  : rb_sres_type := rb_sres_init;
  signal RB_SRES_TIM1  : rb_sres_type := rb_sres_init;
  signal RB_SRES_SUM1  : rb_sres_type := rb_sres_init;

  signal RB_LAM_TEST  : slv16 := (others=>'0');

  signal TIM0_DONE : slbit := '0';
  signal TIM0_BUSY : slbit := '0';
  signal TIM1_DONE : slbit := '0';
  signal TIM1_BUSY : slbit := '0';

  constant rbaddr_rbmon  : slv16 := x"ffe8"; -- ffe8/8: 1111 1111 1110 1xxx
  constant rbaddr_tester : slv16 := x"ffe0"; -- ffe0/8: 1111 1111 1110 0xxx
  constant rbaddr_eyemon : slv16 := x"ffd0"; -- ffd0/4: 1111 1111 1101 00xx
  constant rbaddr_tim1   : slv16 := x"fe11"; -- fe11/1: 1111 1110 0001 0001
  constant rbaddr_tim0   : slv16 := x"fe10"; -- fe10/1: 1111 1110 0001 0000
  constant rbaddr_bram   : slv16 := x"fe00"; -- fe00/2: 1111 1110 0000 00xx
  
begin

  TEST : rbd_tester
    generic map (
      RB_ADDR => rbaddr_tester)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_TEST,
      RB_LAM   => RB_LAM_TEST,
      RB_STAT  => RB_STAT
    );
  
  BRAM : rbd_bram
    generic map (
      RB_ADDR => rbaddr_bram)
    port map (
      CLK      => CLK,
      RESET    => RESET,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES_BRAM
    );
  
  MON : rbd_rbmon
    generic map (
      RB_ADDR => rbaddr_rbmon,
      AWIDTH  => 9)
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_MON,
      RB_SRES_SUM => RB_SRES_TOP
    );

  EMON : rbd_eyemon
    generic map (
      RB_ADDR => rbaddr_eyemon,
      RDIV    => slv(to_unsigned(0,8)))
    port map (
      CLK         => CLK,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_EMON,
      RXSD        => RXSD,
      RXACT       => RXACT
    );

  TIM0 : rbd_timer
    generic map (
      RB_ADDR => rbaddr_tim0)
    port map (
      CLK         => CLK,
      CE_USEC     => CE_USEC,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TIM0,
      DONE        => TIM0_DONE,
      BUSY        => TIM0_BUSY
    );

  TIM1 : rbd_timer
    generic map (
      RB_ADDR => rbaddr_tim1)
    port map (
      CLK         => CLK,
      CE_USEC     => CE_USEC,
      RESET       => RESET,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TIM1,
      DONE        => TIM1_DONE,
      BUSY        => TIM1_BUSY
    );

  RB_SRES_OR1 : rb_sres_or_3
    port map (
      RB_SRES_1  => RB_SRES_TEST,
      RB_SRES_2  => RB_SRES_BRAM,
      RB_SRES_3  => RB_SRES_MON,
      RB_SRES_OR => RB_SRES_SUM1
    );

  RB_SRES_OR : rb_sres_or_4
    port map (
      RB_SRES_1  => RB_SRES_SUM1,
      RB_SRES_2  => RB_SRES_EMON,
      RB_SRES_3  => RB_SRES_TIM0,
      RB_SRES_4  => RB_SRES_TIM1,
      RB_SRES_OR => RB_SRES
    );

  RB_LAM(15 downto 2) <= RB_LAM_TEST(15 downto 2);
  RB_LAM(1)           <= TIM1_DONE;
  RB_LAM(0)           <= TIM0_DONE;
  
  STAT(0) <= TIM0_BUSY;
  STAT(1) <= TIM1_BUSY;
  STAT(7 downto 2) <= (others=>'0');
  
end syn;
