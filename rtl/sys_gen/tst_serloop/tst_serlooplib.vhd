-- $Id: tst_serlooplib.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   tst_serlooplib
-- Description:    Definitions for tst_serloop records and helpers
--
-- Dependencies:   -
-- Tool versions:  ise 13.1-14.7; viv 2014.7; ghdl 0.29-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-12-10   438   1.0.2  add rxui(cnt|dat) fields in hio_stat_type
-- 2011-12-09   437   1.0.1  rename serport stat->moni port
-- 2011-10-14   416   1.0    Initial version 
------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.serportlib.all;

package tst_serlooplib is

  constant c_mode_idle    : slv2 := "00"; -- mode: idle (no tx activity)
  constant c_mode_rxblast : slv2 := "01"; -- mode: rxblast (check rx activity)
  constant c_mode_txblast : slv2 := "10"; -- mode: txblast (saturate tx)
  constant c_mode_loop    : slv2 := "11"; -- mode: loop (rx->tx loop-back)

  type hio_cntl_type is record          -- humanio controls
    mode : slv2;                        -- mode (idle,(tx|tx)blast,loop)
    enaxon : slbit;                     -- enable xon/xoff handling
    enaesc : slbit;                     -- enable xon/xoff escaping
    enathrottle : slbit;                -- enable 1 msec tx throttling
    enaftdi : slbit;                    -- enable ftdi flush handling
  end record hio_cntl_type;

  constant hio_cntl_init : hio_cntl_type := (
    c_mode_idle,                        -- mode
    '0','0','0','0'                     -- enaxon,enaesc,enathrottle,enaftdi
  );

  type hio_stat_type is record          -- humanio status
    rxfecnt : slv16;                    -- rx frame error counter
    rxoecnt : slv16;                    -- rx overrun error counter
    rxsecnt : slv16;                    -- rx sequence error counter
    rxcnt : slv32;                      -- rx char counter
    txcnt : slv32;                      -- tx char counter
    rxuicnt : slv8;                     -- rx unsolicited input counter
    rxuidat : slv8;                     -- rx unsolicited input data
    rxokcnt : slv16;                    -- rxok 1->0 transition counter
    txokcnt : slv16;                    -- txok 1->0 transition counter
  end record hio_stat_type;

  constant hio_stat_init : hio_stat_type := (
    (others=>'0'),                      -- rxfecnt
    (others=>'0'),                      -- rxoecnt
    (others=>'0'),                      -- rxsecnt
    (others=>'0'),                      -- rxcnt
    (others=>'0'),                      -- txcnt 
    (others=>'0'),                      -- rxuicnt
    (others=>'0'),                      -- rxuidat
    (others=>'0'),                      -- rxokcnt
    (others=>'0')                       -- txokcnt 
  );

-- -------------------------------------
  
component tst_serloop is                -- tester for serport components
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CE_MSEC : in slbit;                 -- msec pulse
    HIO_CNTL : in hio_cntl_type;        -- humanio controls
    HIO_STAT : out hio_stat_type;       -- humanio status
    SER_MONI : in serport_moni_type;    -- serport monitor
    RXDATA : in slv8;                   -- receiver data out
    RXVAL : in slbit;                   -- receiver data valid
    RXHOLD : out slbit;                 -- receiver data hold
    TXDATA : out slv8;                  -- transmit data in
    TXENA : out slbit;                  -- transmit data enable
    TXBUSY : in slbit                   -- transmit busy
  );
end component;

component tst_serloop_hiomap is         -- default human I/O mapper
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    HIO_CNTL : out hio_cntl_type;       -- tester controls from hio
    HIO_STAT : in hio_stat_type;        -- tester status to display by hio
    SER_MONI : in serport_moni_type;    -- serport monitor to display by hio
    SWI : in slv8;                      -- switch settings
    BTN : in slv4;                      -- button settings
    LED : out slv8;                     -- led data
    DSP_DAT : out slv16;                -- display data
    DSP_DP : out slv4                   -- display decimal points
  );
end component;

end package tst_serlooplib;
