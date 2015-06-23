-- $Id: tst_rlink_cuff.vhd 666 2015-04-12 21:17:54Z mueller $
--
-- Copyright 2012-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tst_rlink_cuff - syn
-- Description:    tester for rlink over cuff
--
-- Dependencies:   vlib/rlink/rlink_core8
--                 vlib/rlink/rlink_rlbmux
--                 vlib/serport/serport_1clock
--                 ../tst_rlink/rbd_tst_rlink
--                 vlib/rbus/rb_sres_or_2
--                 vlib/genlib/led_pulse_stretch
--
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   1.2    rearrange XON handling
-- 2014-08-28   588   1.1    use new rlink v4 iface generics and 4 bit STAT
-- 2013-01-02   467   1.0.1  use 64 usec led pulse width
-- 2012-12-29   466   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.serportlib.all;
use work.fx2lib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity tst_rlink_cuff is                -- tester for rlink over cuff
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RB_MREQ_TOP : out rb_mreq_type;     -- rbus: request
    RB_SRES_TOP : in rb_sres_type;      -- rbus: response from top level
    SWI : in slv8;                      -- hio: switches
    BTN : in slv4;                      -- hio: buttons
    LED : out slv8;                     -- hio: leds
    DSP_DAT : out slv16;                -- hio: display data
    DSP_DP : out slv4;                  -- hio: display decimal points
    RXSD : in slbit;                    -- receive serial data (uart view)
    TXSD : out slbit;                   -- transmit serial data (uart view)
    RTS_N : out slbit;                  -- receive rts (uart view, act.low)
    CTS_N : in slbit;                   -- transmit cts (uart view, act.low)
    FX2_RXDATA : in slv8;               -- fx2: receiver data out
    FX2_RXVAL : in slbit;               -- fx2: receiver data valid
    FX2_RXHOLD : out slbit;             -- fx2: receiver data hold
    FX2_TXDATA : out slv8;              -- fx2: transmit data in
    FX2_TXENA : out slbit;              -- fx2: transmit data enable
    FX2_TXBUSY : in slbit;              -- fx2: transmit busy
    FX2_TX2DATA : out slv8;             -- fx2: transmit 2 data in
    FX2_TX2ENA : out slbit;             -- fx2: transmit 2 data enable
    FX2_TX2BUSY : in slbit;             -- fx2: transmit 2 busy
    FX2_MONI : in fx2ctl_moni_type      -- fx2: fx2ctl monitor
  );
end tst_rlink_cuff;

architecture syn of tst_rlink_cuff is

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_SRES_TST : rb_sres_type := rb_sres_init;

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4  := (others=>'0');

  signal SER_MONI : serport_moni_type := serport_moni_init;
  signal STAT     : slv8  := (others=>'0');

  signal RLB_DI   : slv8 := (others=>'0');
  signal RLB_ENA  : slbit := '0';
  signal RLB_BUSY : slbit := '0';
  signal RLB_DO   : slv8 := (others=>'0');
  signal RLB_VAL  : slbit := '0';
  signal RLB_HOLD : slbit := '0';

  signal SER_RXDATA : slv8 := (others=>'0');
  signal SER_RXVAL  : slbit := '0';
  signal SER_RXHOLD : slbit := '0';
  signal SER_TXDATA : slv8 := (others=>'0');
  signal SER_TXENA  : slbit := '0';
  signal SER_TXBUSY : slbit := '0';

  signal FX2_TX2ENA_L : slbit := '0';
  signal FX2_TXENA_L : slbit := '0';

  signal FX2_TX2ENA_LED : slbit := '0';
  signal FX2_TXENA_LED : slbit := '0';
  signal FX2_RXVAL_LED : slbit := '0';

  signal R_LEDDIV : slv6 := (others=>'0');   -- clock divider for LED pulses
  signal R_LEDCE : slbit := '0';             -- ce every 64 usec
  
begin

  RLCORE : rlink_core8
    generic map (
      BTOWIDTH     => 6,
      RTAWIDTH     => 12,
      SYSID        => (others=>'0'),
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon)
    port map (
      CLK        => CLK,
      CE_INT     => CE_MSEC,
      RESET      => RESET,
      ESCXON     => SWI(1),
      ESCFILL    => '0',
      RLB_DI     => RLB_DI,
      RLB_ENA    => RLB_ENA,
      RLB_BUSY   => RLB_BUSY,
      RLB_DO     => RLB_DO,
      RLB_VAL    => RLB_VAL,
      RLB_HOLD   => RLB_HOLD,
      RL_MONI    => open,
      RB_MREQ    => RB_MREQ,
      RB_SRES    => RB_SRES,
      RB_LAM     => RB_LAM,
      RB_STAT    => RB_STAT
    );

  RLBMUX : rlink_rlbmux
    port map (
      SEL       => SWI(2),
      RLB_DI    => RLB_DI,
      RLB_ENA   => RLB_ENA,
      RLB_BUSY  => RLB_BUSY,
      RLB_DO    => RLB_DO,
      RLB_VAL   => RLB_VAL,
      RLB_HOLD  => RLB_HOLD,
      P0_RXDATA => SER_RXDATA,
      P0_RXVAL  => SER_RXVAL,
      P0_RXHOLD => SER_RXHOLD,
      P0_TXDATA => SER_TXDATA,
      P0_TXENA  => SER_TXENA,
      P0_TXBUSY => SER_TXBUSY,
      P1_RXDATA => FX2_RXDATA,
      P1_RXVAL  => FX2_RXVAL,
      P1_RXHOLD => FX2_RXHOLD,
      P1_TXDATA => FX2_TXDATA,
      P1_TXENA  => FX2_TXENA_L,
      P1_TXBUSY => FX2_TXBUSY
    );

  SERPORT : serport_1clock
    generic map (
      CDWIDTH   => 15,
      CDINIT    => sys_conf_ser2rri_cdinit,
      RXFAWIDTH =>  5,
      TXFAWIDTH =>  5)
    port map (
      CLK      => CLK,
      CE_MSEC  => CE_MSEC,
      RESET    => RESET,
      ENAXON   => SWI(1),
      ENAESC   => '0',                  -- escaping now in rlink_core8
      RXDATA   => SER_RXDATA,
      RXVAL    => SER_RXVAL,
      RXHOLD   => SER_RXHOLD,
      TXDATA   => SER_TXDATA,
      TXENA    => SER_TXENA,
      TXBUSY   => SER_TXBUSY,
      MONI     => SER_MONI,
      RXSD     => RXSD,
      TXSD     => TXSD,
      RXRTS_N  => RTS_N,
      TXCTS_N  => CTS_N
    );

  RBDTST : entity work.rbd_tst_rlink
    port map (
      CLK         => CLK,
      RESET       => RESET,
      CE_USEC     => CE_USEC,
      RB_MREQ     => RB_MREQ,
      RB_SRES     => RB_SRES_TST,
      RB_LAM      => RB_LAM,
      RB_STAT     => RB_STAT,
      RB_SRES_TOP => RB_SRES,
      RXSD        => RXSD,
      RXACT       => SER_MONI.rxact,
      STAT        => STAT
    );

  RB_SRES_OR1 : rb_sres_or_2
    port map (
      RB_SRES_1  => RB_SRES_TOP,
      RB_SRES_2  => RB_SRES_TST,
      RB_SRES_OR => RB_SRES
    );
  
  TX2ENA_PSTR : led_pulse_stretch
    port map (
      CLK        => CLK,
      CE_INT     => R_LEDCE,
      RESET      => '0',
      DIN        => FX2_TX2ENA_L,
      POUT       => FX2_TX2ENA_LED
    );
  TXENA_PSTR : led_pulse_stretch
    port map (
      CLK        => CLK,
      CE_INT     => R_LEDCE,
      RESET      => '0',
      DIN        => FX2_TXENA_L,
      POUT       => FX2_TXENA_LED
    );
  RXVAL_PSTR : led_pulse_stretch
    port map (
      CLK        => CLK,
      CE_INT     => R_LEDCE,
      RESET      => '0',
      DIN        => FX2_RXVAL,
      POUT       => FX2_RXVAL_LED
    );

  proc_clkdiv: process (CLK)
  begin

    if rising_edge(CLK) then
      R_LEDCE  <= '0';
      if CE_USEC = '1' then
        R_LEDDIV <= slv(unsigned(R_LEDDIV) - 1);
        if unsigned(R_LEDDIV) = 0 then
          R_LEDCE <= '1';
        end if;
      end if;
    end if;

  end process proc_clkdiv;

  proc_hiomux : process (SWI, SER_MONI, STAT, FX2_TX2BUSY,
                         FX2_TX2ENA_LED, FX2_TXENA_LED, FX2_RXVAL_LED)
  begin

    DSP_DAT   <= SER_MONI.abclkdiv;

    LED(7) <= SER_MONI.abact;
    LED(6 downto 2) <= (others=>'0');
    LED(1) <= STAT(1);
    LED(0) <= STAT(0);
    
    if SWI(2) = '0' then 
      DSP_DP(3) <= not SER_MONI.txok;
      DSP_DP(2) <= SER_MONI.txact;
      DSP_DP(1) <= not SER_MONI.rxok;
      DSP_DP(0) <= SER_MONI.rxact;
    else
      DSP_DP(3) <= FX2_TX2BUSY;
      DSP_DP(2) <= FX2_TX2ENA_LED;
      DSP_DP(1) <= FX2_TXENA_LED;
      DSP_DP(0) <= FX2_RXVAL_LED;
    end if;      
    
  end process proc_hiomux;

  RB_MREQ_TOP <= RB_MREQ;
  FX2_TX2ENA  <= FX2_TX2ENA_L;
  FX2_TXENA   <= FX2_TXENA_L;
  
end syn;
