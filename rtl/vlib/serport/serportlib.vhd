-- $Id: serportlib.vhd 666 2015-04-12 21:17:54Z mueller $
--
-- Copyright 2007-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   serportlib
-- Description:    serial port interface components
--
-- Dependencies:   -
-- Tool versions:  ise 8.2-14.7; viv 2014.4; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   1.3.1  add serport_master
-- 2015-02-01   641   1.3    add CLKDIV_F for autobaud
-- 2013-01-26   476   1.2.6  renamed package to serportlib
-- 2011-12-09   437   1.2.5  rename stat->moni port
-- 2011-10-23   419   1.2.4  remove serport_clkdiv_ consts
-- 2011-10-22   417   1.2.3  add serport_xon(rx|tx) defs
-- 2011-10-14   416   1.2.2  add c_serport defs
-- 2010-12-26   348   1.2.1  add ABCLKDIV to serport_uart_rxtx_ab
-- 2010-04-10   276   1.2    add clock divider constant defs
-- 2007-10-22    88   1.1    renames (in prev revs); remove std_logic_unsigned
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package serportlib is

  constant c_serport_xon  : slv8 := "00010001"; -- char xon:  ^Q = hex 11
  constant c_serport_xoff : slv8 := "00010011"; -- char xoff  ^S = hex 13
  constant c_serport_xesc : slv8 := "00011011"; -- char xesc  ^[ = ESC = hex 1B
  
component serport_uart_rxtx is          -- serial port uart: rx+tx combo
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    RXSD : in slbit;                    -- receive serial data (uart view)
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXACT : out slbit;                  -- receiver active
    TXSD : out slbit;                   -- transmit serial data (uart view)
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit                  -- transmit busy
  );
end component;

component serport_uart_rx is            -- serial port uart: receive part
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    RXSD : in slbit;                    -- receive serial data (uart view)
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXACT : out slbit                   -- receiver active
  );
end component;

component serport_uart_tx is            -- serial port uart: transmit part
  generic (
    CDWIDTH : positive := 13);          -- clk divider width
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    CLKDIV : in slv(CDWIDTH-1 downto 0); -- clock divider setting
    TXSD : out slbit;                   -- transmit serial data (uart view)
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit                  -- transmit busy
  );
end component;

component serport_uart_rxtx_ab is       -- serial port uart: rx+tx+autobaud
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT: natural := 15);             -- clk divider initial/reset setting
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET : in slbit;                   -- reset
    RXSD : in slbit;                    -- receive serial data (uart view)
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXERR : out slbit;                  -- receiver data error (frame error)
    RXACT : out slbit;                  -- receiver active
    TXSD : out slbit;                   -- transmit serial data (uart view)
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit busy
    ABACT : out slbit;                  -- autobaud active; if 1 clkdiv invalid
    ABDONE : out slbit;                 -- autobaud resync done
    ABCLKDIV : out slv(CDWIDTH-1 downto 0); -- autobaud clock divider setting
    ABCLKDIV_F : out slv3                   -- autobaud clock divider fraction
  );
end component;

component serport_uart_autobaud is      -- serial port uart: autobauder
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT: natural := 15);             -- clk divider initial/reset setting
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET : in slbit;                   -- reset
    RXSD : in slbit;                    -- receive serial data (uart view)
    CLKDIV : out slv(CDWIDTH-1 downto 0); -- clock divider setting
    CLKDIV_F: out slv3;                   -- clock divider fractional part
    ACT : out slbit;                    -- active; if 1 clkdiv is invalid
    DONE : out slbit                    -- resync done
  );
end component;

component serport_xonrx is              -- serial port: xon/xoff logic rx path
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    UART_RXDATA : in slv8;              -- uart data out
    UART_RXVAL : in slbit;              -- uart data valid
    RXDATA : out slv8;                  -- user data out
    RXVAL : out slbit;                  -- user data valid
    RXHOLD : in slbit;                  -- user data hold
    RXOVR : out slbit;                  -- user data overrun
    TXOK : out slbit                    -- tx channel ok
  );
end component;

component serport_xontx is              -- serial port: xon/xoff logic tx path
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    UART_TXDATA : out slv8;             -- uart data in
    UART_TXENA : out slbit;             -- uart data enable
    UART_TXBUSY : in slbit;             -- uart data busy
    TXDATA : in slv8;                   -- user data in
    TXENA : in slbit;                   -- user data enable
    TXBUSY : out slbit;                 -- user data busy
    RXOK : in slbit;                    -- rx channel ok
    TXOK : in slbit                     -- tx channel ok
  );
end component;

type serport_moni_type is record        -- serport monitor port
  rxerr : slbit;                        -- receiver data error (frame error)
  rxovr : slbit;                        -- receiver data overrun
  rxact : slbit;                        -- receiver active
  txact : slbit;                        -- transceiver active
  abact : slbit;                        -- autobauder active;if 1 clkdiv invalid
  abdone : slbit;                       -- autobauder resync done
  abclkdiv : slv16;                     -- autobauder clock divider
  abclkdiv_f : slv3;                    -- autobauder clock divider fraction
  rxok : slbit;                         -- rx channel ok
  txok : slbit;                         -- tx channel ok
end record serport_moni_type;
  
constant serport_moni_init : serport_moni_type := (
  '0','0',                              -- rxerr,rxovr
  '0','0',                              -- rxact,txact
  '0','0',                              -- abact,abdone
  (others=>'0'),                        -- abclkdiv
  (others=>'0'),                        -- abclkdiv_f
  '0','0'                               -- rxok,txok
);

component serport_1clock is             -- serial port module, 1 clock domain
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15;           -- clk divider initial/reset setting
    RXFAWIDTH : natural :=  5;          -- rx fifo address width
    TXFAWIDTH : natural :=  5);         -- tx fifo address width
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- 1 msec clock enable
    RESET : in slbit;                   -- reset
    ENAXON : in slbit;                  -- enable xon/xoff handling
    ENAESC : in slbit;                  -- enable xon/xoff escaping
    RXDATA : out slv8;                  -- receiver data out
    RXVAL : out slbit;                  -- receiver data valid
    RXHOLD : in slbit;                  -- receiver data hold
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit busy
    MONI : out serport_moni_type;       -- serport monitor port
    RXSD : in slbit;                    -- receive serial data (uart view)
    TXSD : out slbit;                   -- transmit serial data (uart view)
    RXRTS_N : out slbit;                -- receive rts (uart view, act.low)
    TXCTS_N : in slbit                  -- transmit cts (uart view, act.low)
  );
end component;

component serport_2clock is             -- serial port module, 2 clock domain
  generic (
    CDWIDTH : positive := 13;           -- clk divider width
    CDINIT : natural   := 15;           -- clk divider initial/reset setting
    RXFAWIDTH : natural :=  5;          -- rx fifo address width
    TXFAWIDTH : natural :=  5);         -- tx fifo address width
  port (
    CLKU : in slbit;                    -- clock (backend:user)
    RESET : in slbit;                   -- reset
    CLKS : in slbit;                    -- clock (frontend:serial)
    CES_MSEC : in slbit;                -- S|1 msec clock enable
    ENAXON : in slbit;                  -- U|enable xon/xoff handling
    ENAESC : in slbit;                  -- U|enable xon/xoff escaping
    RXDATA : out slv8;                  -- U|receiver data out
    RXVAL : out slbit;                  -- U|receiver data valid
    RXHOLD : in slbit;                  -- U|receiver data hold
    TXDATA : in slv8;                   -- U|transmit data in
    TXENA : in slbit;                   -- U|transmit data enable
    TXBUSY : out slbit;                 -- U|transmit busy
    MONI : out serport_moni_type;       -- U|serport monitor port
    RXSD : in slbit;                    -- S|receive serial data (uart view)
    TXSD : out slbit;                   -- S|transmit serial data (uart view)
    RXRTS_N : out slbit;                -- S|receive rts (uart view, act.low)
    TXCTS_N : in slbit                  -- S|transmit cts (uart view, act.low)
  );
end component;

component serport_master is             -- serial port module, master side
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
    TXCTS_N : in slbit :='0'            -- transmit cts (uart view, act.low)
  );
end component;

end package serportlib;
