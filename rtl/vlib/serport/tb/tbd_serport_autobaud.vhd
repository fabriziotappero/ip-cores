-- $Id: tbd_serport_autobaud.vhd 649 2015-02-21 21:10:16Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    tbd_serport_autobaud - syn
-- Description:    Wrapper for serport_uart_autobaud and serport_uart_rxtx to
--                 avoid records. It has a port interface which will not be
--                 modified by xst synthesis (no records, no generic port).
--
-- Dependencies:   clkdivce
--                 serport_uart_autobaud
--                 serport_uart_rxtx
--                 serport_uart_rx
--
-- To test:        serport_uart_autobaud
--                 serport_uart_rxtx
--
-- Target Devices: generic
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2007-10-27    92  9.2.02 J39  xc3s1000-4   151  291    0    - t 9.23
-- 2007-10-27    92  9.1    J30  xc3s1000-4   151  291    0    - t 9.23
-- 2007-10-27    92  8.2.03 I34  xc3s1000-4   153  338    0  178 s 9.45
-- 2007-10-27    92  8.1.03 I27  xc3s1000-4   152  293    0    - s 9.40
--
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-01-20   112   1.0.1  rename clkgen->clkdivce
-- 2007-06-24    60   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.serportlib.all;

entity tbd_serport_autobaud is          -- serial port autobaud [tb design]
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RXSD : in slbit;                    -- receive serial data (uart view)
    CE_USEC : out slbit;                -- usec pulse (here every  4 clocks)
    CE_MSEC : out slbit;                -- msec pulse (here every 20 clocks)
    CLKDIV : out slv13;                 -- clock divider setting
    ABACT : out slbit;                  -- autobaud active
    ABDONE : out slbit;                 -- autobaud done
    RXDATA : out slv8;                  -- receiver data out (1st rx)
    RXVAL : out slbit;                  -- receiver data valid (1st rx)
    RXERR : out slbit;                  -- receiver data error (1st rx)
    RXACT : out slbit;                  -- receiver active (1st rx)
    TXSD2 : out slbit;                  -- transmit serial data (2nd tx)
    RXDATA3 : out slv8;                 -- receiver data out (3rd rx)
    RXVAL3 : out slbit;                 -- receiver data valid (3rd rx)
    RXERR3 : out slbit;                 -- receiver data error  (3rd rx)
    RXACT3 : out slbit                  -- receiver active (3rd rx)
  );
end tbd_serport_autobaud;


architecture syn of tbd_serport_autobaud is

  constant cdwidth : positive := 13;

  signal LCE_MSEC : slbit := '0';
  signal LCLKDIV : slv13 := (others=>'0');
  signal LRXDATA : slv8 := (others=>'0');
  signal LRXVAL : slbit := '0';
  signal LTXSD2 : slbit := '0';
  signal LABACT : slbit := '0';
  
begin

  CKLDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV => 4,
      MSECDIV => 5)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => LCE_MSEC
    );
  
  AUTOBAUD : serport_uart_autobaud
    generic map (
      CDWIDTH => cdwidth,
      CDINIT => 15)
    port map (
      CLK     => CLK,
      CE_MSEC => LCE_MSEC,
      RESET   => RESET,
      RXSD    => RXSD,
      CLKDIV  => LCLKDIV,
      ACT     => LABACT,
      DONE    => ABDONE
    );
      
  UART1 : serport_uart_rxtx
    generic map (
      CDWIDTH => cdwidth)
    port map (
      CLK    => CLK,
      RESET  => LABACT,
      CLKDIV => LCLKDIV,
      RXSD   => RXSD,
      RXDATA => LRXDATA,
      RXVAL  => LRXVAL,
      RXERR  => RXERR,
      RXACT  => RXACT,
      TXSD   => LTXSD2,
      TXDATA => LRXDATA,
      TXENA  => LRXVAL,
      TXBUSY => open
    );
  
  UART2 : serport_uart_rx
    generic map (
      CDWIDTH => cdwidth)
    port map (
      CLK    => CLK,
      RESET  => LABACT,
      CLKDIV => LCLKDIV,
      RXSD   => LTXSD2,
      RXDATA => RXDATA3,
      RXVAL  => RXVAL3,
      RXERR  => RXERR3,
      RXACT  => RXACT3
    );

  CE_MSEC <= LCE_MSEC;
  CLKDIV  <= LCLKDIV;
  ABACT   <= LABACT;
  RXDATA  <= LRXDATA;
  RXVAL   <= LRXVAL;
  TXSD2   <= LTXSD2;
  
end syn;
