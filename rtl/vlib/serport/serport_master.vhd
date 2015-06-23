-- $Id: serport_master.vhd 666 2015-04-12 21:17:54Z mueller $
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
-- Module Name:    serport_master - syn
-- Description:    serial port: serial port module, master side
--
-- Dependencies:   serport_uart_rxtx_ab
--                 serport_xonrx
--                 serport_xontx
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4; ghdl 0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-04-12   666 14.7  131013 xc6slx16-2   104  171    0   63 s  6.4
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-12   666   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;

entity serport_master is                -- serial port module, 1 clock domain
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    ENAXON : in slbit := '0';           -- enable xon/xoff handling
    ENAESC : in slbit := '0';           -- enable xon/xoff escaping
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXOK : in slbit := '1';             -- rx channel ok
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit busy
    RXSD : in slbit;                    -- receive serial data (uart view)
    TXSD : out slbit;                   -- transmit serial data (uart view)
    RXRTS_N : out slbit;                -- receive rts (uart view, act.low)
    TXCTS_N : in slbit := '0'           -- transmit cts (uart view, act.low)
  );
end serport_master;


architecture syn of serport_master is
  
  signal UART_RXDATA : slv8 := (others=>'0');
  signal UART_RXVAL : slbit := '0';
  signal UART_TXDATA : slv8 := (others=>'0');
  signal UART_TXENA : slbit := '0';
  signal UART_TXBUSY : slbit := '0';

  signal XONTX_TXENA : slbit := '0';
  signal XONTX_TXBUSY : slbit := '0';

  signal TXOK : slbit := '0';
  
begin

  UART : serport_uart_rxtx             -- uart, rx+tx combo
  generic map (
    CDWIDTH => CDWIDTH)
  port map (
    CLK        => CLK,
    RESET      => RESET,
    CLKDIV     => CLKDIV,
    RXSD       => RXSD,
    RXDATA     => UART_RXDATA,
    RXVAL      => UART_RXVAL,
    RXERR      => RXERR,
    RXACT      => open,
    TXSD       => TXSD,
    TXDATA     => UART_TXDATA,
    TXENA      => UART_TXENA,
    TXBUSY     => UART_TXBUSY
  );

  XONRX : serport_xonrx                 --  xon/xoff logic rx path
  port map (
    CLK         => CLK,
    RESET       => RESET,
    ENAXON      => ENAXON,
    ENAESC      => ENAESC,
    UART_RXDATA => UART_RXDATA,
    UART_RXVAL  => UART_RXVAL,
    RXDATA      => RXDATA,
    RXVAL       => RXVAL,
    RXHOLD      => '0',
    RXOVR       => open,
    TXOK        => TXOK
  );

  XONTX : serport_xontx                 --  xon/xoff logic tx path
  port map (
    CLK         => CLK,
    RESET       => RESET,
    ENAXON      => ENAXON,
    ENAESC      => ENAESC,
    UART_TXDATA => UART_TXDATA,
    UART_TXENA  => XONTX_TXENA,
    UART_TXBUSY => XONTX_TXBUSY,
    TXDATA      => TXDATA,
    TXENA       => TXENA,
    TXBUSY      => TXBUSY,
    RXOK        => RXOK,
    TXOK        => TXOK
  );  

  RXRTS_N <= not RXOK;

  proc_cts: process (TXCTS_N, XONTX_TXENA, UART_TXBUSY)
  begin
    if TXCTS_N = '0' then               -- transmit cts asserted
      UART_TXENA   <= XONTX_TXENA;
      XONTX_TXBUSY <= UART_TXBUSY;
    else                                -- transmit cts not asserted
      UART_TXENA   <= '0';
      XONTX_TXBUSY <= '1';
    end if;
  end process proc_cts;

end syn;
