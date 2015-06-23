-- $Id: serport_1clock.vhd 666 2015-04-12 21:17:54Z mueller $
--
-- Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    serport_1clock - syn
-- Description:    serial port: serial port module, 1 clock domain
--
-- Dependencies:   serport_uart_rxtx_ab
--                 serport_xonrx
--                 serport_xontx
--                 memlib/fifo_1c_dram
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 13.1-14.7; viv 2014.4; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-04-12   666 14.7  131013 xc6slx16-2   171  239   32   94 s  6.3
-- 2011-11-13   424 13.1    O40d xc3s1000-4   157  337   64  232 s  9.9
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   1.1.1  add sim assertions for RXOVR and RXERR
-- 2015-02-01   641   1.1    add CLKDIV_F for autobaud;
-- 2011-12-10   438   1.0.2  internal reset on abact
-- 2011-12-09   437   1.0.1  rename stat->moni port
-- 2011-11-13   424   1.0    Initial version
-- 2011-10-23   419   0.5    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.memlib.all;

entity serport_1clock is                -- serial port module, 1 clock domain
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
end serport_1clock;


architecture syn of serport_1clock is
  
  signal R_RXOK : slbit := '1';

  signal RESET_INT : slbit := '0';

  signal UART_RXDATA : slv8 := (others=>'0');
  signal UART_RXVAL : slbit := '0';
  signal UART_TXDATA : slv8 := (others=>'0');
  signal UART_TXENA : slbit := '0';
  signal UART_TXBUSY : slbit := '0';

  signal XONTX_TXENA : slbit := '0';
  signal XONTX_TXBUSY : slbit := '0';

  signal RXFIFO_DI : slv8 := (others=>'0');
  signal RXFIFO_ENA : slbit := '0';
  signal RXFIFO_BUSY : slbit := '0';
  signal RXFIFO_SIZE : slv(RXFAWIDTH downto 0) := (others=>'0');
  signal TXFIFO_DO : slv8 := (others=>'0');
  signal TXFIFO_VAL : slbit := '0';
  signal TXFIFO_HOLD : slbit := '0';

  signal RXERR  : slbit := '0';
  signal RXOVR  : slbit := '0';
  signal RXACT  : slbit := '0';
  signal ABACT  : slbit := '0';
  signal ABDONE : slbit := '0';
  signal ABCLKDIV : slv(CDWIDTH-1 downto 0) := (others=>'0');
  signal ABCLKDIV_F : slv3 := (others=>'0');

  signal TXOK : slbit := '0';
  signal RXOK : slbit := '0';
  
begin

  assert CDWIDTH<=16
    report "assert(CDWIDTH<=16): max width of UART clock divider"
    severity failure;

  UART : serport_uart_rxtx_ab           -- uart, rx+tx+autobauder combo
  generic map (
    CDWIDTH => CDWIDTH,
    CDINIT  => CDINIT)
  port map (
    CLK        => CLK,
    CE_MSEC    => CE_MSEC,
    RESET      => RESET,
    RXSD       => RXSD,
    RXDATA     => UART_RXDATA,
    RXVAL      => UART_RXVAL,
    RXERR      => RXERR,
    RXACT      => RXACT,
    TXSD       => TXSD,
    TXDATA     => UART_TXDATA,
    TXENA      => UART_TXENA,
    TXBUSY     => UART_TXBUSY,
    ABACT      => ABACT,
    ABDONE     => ABDONE,
    ABCLKDIV   => ABCLKDIV,
    ABCLKDIV_F => ABCLKDIV_F
  );

  RESET_INT <= RESET or ABACT;
  
  XONRX : serport_xonrx                 --  xon/xoff logic rx path
  port map (
    CLK         => CLK,
    RESET       => RESET_INT,
    ENAXON      => ENAXON,
    ENAESC      => ENAESC,
    UART_RXDATA => UART_RXDATA,
    UART_RXVAL  => UART_RXVAL,
    RXDATA      => RXFIFO_DI,
    RXVAL       => RXFIFO_ENA,
    RXHOLD      => RXFIFO_BUSY,
    RXOVR       => RXOVR,
    TXOK        => TXOK
  );

  XONTX : serport_xontx                 --  xon/xoff logic tx path
  port map (
    CLK         => CLK,
    RESET       => RESET_INT,
    ENAXON      => ENAXON,
    ENAESC      => ENAESC,
    UART_TXDATA => UART_TXDATA,
    UART_TXENA  => XONTX_TXENA,
    UART_TXBUSY => XONTX_TXBUSY,
    TXDATA      => TXFIFO_DO,
    TXENA       => TXFIFO_VAL,
    TXBUSY      => TXFIFO_HOLD,
    RXOK        => RXOK,
    TXOK        => TXOK
  );
  
  RXFIFO : fifo_1c_dram                 -- input fifo, 1 clock, dram based
  generic map (
    AWIDTH => RXFAWIDTH,
    DWIDTH => 8)
  port map (
    CLK   => CLK,
    RESET => RESET_INT,
    DI    => RXFIFO_DI,
    ENA   => RXFIFO_ENA,
    BUSY  => RXFIFO_BUSY,
    DO    => RXDATA,
    VAL   => RXVAL,
    HOLD  => RXHOLD,
    SIZE  => RXFIFO_SIZE
  );

  TXFIFO : fifo_1c_dram                 -- input fifo, 1 clock, dram based
  generic map (
    AWIDTH => TXFAWIDTH,
    DWIDTH => 8)
  port map (
    CLK   => CLK,
    RESET => RESET_INT,
    DI    => TXDATA,
    ENA   => TXENA,
    BUSY  => TXBUSY,
    DO    => TXFIFO_DO,
    VAL   => TXFIFO_VAL,
    HOLD  => TXFIFO_HOLD,
    SIZE  => open
  );
    
  -- receive back preasure
  --    on if fifo more than 3/4 full
  --   off if fifo less than 1/2 full
  proc_rxok: process (CLK)
    constant rxsize_rxok_off : slv3 := "011";
    constant rxsize_rxok_on  : slv3 := "010";
    variable rxsize_msb : slv3 := "000";
  begin
    if rising_edge(CLK) then
      if RESET_INT = '1' then
        R_RXOK <= '1';
      else
        rxsize_msb := RXFIFO_SIZE(RXFAWIDTH downto RXFAWIDTH-2);
        if unsigned(rxsize_msb) >=  unsigned(rxsize_rxok_off) then
          R_RXOK <= '0';
        elsif unsigned(rxsize_msb) <=  unsigned(rxsize_rxok_on) then
          R_RXOK <= '1';
        end if;
      end if;
    end if;
  end process proc_rxok;

  RXOK    <= R_RXOK;
  RXRTS_N <= not R_RXOK;

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

  MONI.rxerr  <= RXERR;
  MONI.rxovr  <= RXOVR;
  MONI.rxact  <= RXACT;
  MONI.txact  <= UART_TXBUSY;
  MONI.abact  <= ABACT;
  MONI.abdone <= ABDONE;
  MONI.rxok   <= RXOK;
  MONI.txok   <= TXOK;
  
  proc_abclkdiv: process (ABCLKDIV, ABCLKDIV_F)
  begin
    MONI.abclkdiv <= (others=>'0');
    MONI.abclkdiv(ABCLKDIV'range) <= ABCLKDIV;
    MONI.abclkdiv_f <= ABCLKDIV_F;
  end process proc_abclkdiv;

-- synthesis translate_off

  proc_check: process (CLK)
  begin
    if rising_edge(CLK) then
      assert RXOVR = '0'
        report "serport_1clock-W: RXOVR = " & slbit'image(RXOVR) &
               "; data loss in receive fifo"
        severity warning;
      assert RXERR = '0'
        report "serport_1clock-W: RXERR = " & slbit'image(RXERR) &
               "; spurious receive error"
        severity warning;
    end if;
  end process proc_check;

-- synthesis translate_on
  
end syn;
