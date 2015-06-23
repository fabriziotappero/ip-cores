-- $Id: tst_fx2looplib.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2011-2012 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   tst_fx2looplib
-- Description:    Definitions for tst_fx2loop records and helpers
--
-- Dependencies:   -
-- Tool versions:  xst 13.3-14.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-01-15   453   1.1    drop pecnt, add rxhold,(tx|tx2)busy in hio_stat
-- 2011-12-26   445   1.0    Initial version 
------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.fx2lib.all;

package tst_fx2looplib is

  constant c_ctltyp_2fifo_as : integer := 0; -- fx2ctl type: 2fifo_as
  constant c_ctltyp_2fifo_ic : integer := 1; -- fx2ctl type: 2fifo_ic
  constant c_ctltyp_3fifo_ic : integer := 2; -- fx2ctl type: 3fifo_ic
  
  constant c_mode_idle    : slv2 := "00"; -- mode: idle (no tx activity)
  constant c_mode_rxblast : slv2 := "01"; -- mode: rxblast (check rx activity)
  constant c_mode_txblast : slv2 := "10"; -- mode: txblast (saturate tx)
  constant c_mode_loop    : slv2 := "11"; -- mode: loop (rx->tx loop-back)

  type hio_cntl_type is record          -- humanio controls
    mode : slv2;                        -- mode (idle,(tx|tx)blast,loop)
    tx2blast : slbit;                   -- enable tx2 blast
    throttle : slbit;                   -- enable 1 msec tx throttling
  end record hio_cntl_type;

  constant hio_cntl_init : hio_cntl_type := (
    c_mode_idle,                        -- mode
    '0','0'                             -- tx2blast,throttle
  );

  type hio_stat_type is record          -- humanio status
    rxhold : slbit;                     -- rx hold
    txbusy : slbit;                     -- tx busy
    tx2busy : slbit;                    -- tx2 busy
    rxsecnt : slv16;                    -- rx sequence error counter
    rxcnt : slv32;                      -- rx word counter
    txcnt : slv32;                      -- tx word counter
    tx2cnt : slv32;                     -- tx2 word counter
  end record hio_stat_type;

  constant hio_stat_init : hio_stat_type := (
    '0','0','0',                        -- rxhold,txbusy,tx2busy
    (others=>'0'),                      -- rxsecnt
    (others=>'0'),                      -- rxcnt
    (others=>'0'),                      -- txcnt 
    (others=>'0')                       -- tx2cnt 
  );

-- -------------------------------------
  
component tst_fx2loop is                -- tester for serport components
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- msec pulse
    HIO_CNTL : in hio_cntl_type;        -- humanio controls
    HIO_STAT : out hio_stat_type;       -- humanio status
    FX2_MONI : in fx2ctl_moni_type;     -- fx2ctl monitor
    RXDATA : in slv8;                   -- receiver data out
    RXVAL : in slbit;                   -- receiver data valid
    RXHOLD : out slbit;                 -- receiver data hold
    TXDATA : out slv8;                  -- transmit data in
    TXENA : out slbit;                  -- transmit data enable
    TXBUSY : in slbit;                  -- transmit busy
    TX2DATA : out slv8;                 -- transmit 2 data in
    TX2ENA : out slbit;                 -- transmit 2 data enable
    TX2BUSY : in slbit                  -- transmit 2 busy
  );
end component;

component tst_fx2loop_hiomap is         -- default human I/O mapper
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    HIO_CNTL : out hio_cntl_type;       -- tester controls from hio
    HIO_STAT : in hio_stat_type;        -- tester status to display by hio
    FX2_MONI : in fx2ctl_moni_type;     -- fx2ctl monitor to display by hio
    SWI : in slv8;                      -- switch settings
    BTN : in slv4;                      -- button settings
    LED : out slv8;                     -- led data
    DSP_DAT : out slv16;                -- display data
    DSP_DP : out slv4                   -- display decimal points
  );
end component;

end package tst_fx2looplib;
