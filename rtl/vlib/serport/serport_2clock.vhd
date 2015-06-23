-- $Id: serport_2clock.vhd 666 2015-04-12 21:17:54Z mueller $
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
-- Module Name:    serport_2clock - syn
-- Description:    serial port: serial port module, 2 clock domain
--
-- Dependencies:   genlib/cdc_pulse
--                 serport_uart_rxtx_ab
--                 serport_xonrx
--                 serport_xontx
--                 memlib/fifo_2c_dram
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 13.1-14.7; ghdl 0.29-0.31
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-04-12   666 14.7  131013 xc6slx16-2   285  283   32  138 s  6.2/5.9
-- 2011-11-13   424 13.1    O40d xc3s1000-4   224  362   64  295 s  8.6/10.1
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2015-04-11   666   1.1.1  add sim assertions for RXOVR and RXERR
-- 2015-02-01   641   1.1    add CLKDIV_F for autobaud;
-- 2011-12-10   438   1.0.2  internal reset on abact
-- 2011-12-09   437   1.0.1  rename stat->moni port
-- 2011-11-13   424   1.0    Initial version
-- 2011-11-07   421   0.5    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.serportlib.all;
use work.genlib.all;
use work.memlib.all;

entity serport_2clock is                -- serial port module, 2 clock domain
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
end serport_2clock;


architecture syn of serport_2clock is
  
  type synu_type is record
    rxact_c : slbit;                    -- rxact (capt from CLKS->CLKU)
    rxact_s : slbit;                    -- rxact (sync in CLKU)
    txact_c : slbit;                    -- txact (capt from CLKS->CLKU)
    txact_s : slbit;                    -- txact (sync in CLKU)
    abact_c : slbit;                    -- abact (capt from CLKS->CLKU)
    abact_s : slbit;                    -- abact (sync in CLKU)
    rxok_c : slbit;                     -- rxok (capt from CLKS->CLKU)
    rxok_s : slbit;                     -- rxok (sync in CLKU)
    txok_c : slbit;                     -- txok (capt from CLKS->CLKU)
    txok_s : slbit;                     -- txok (sync in CLKU)
    abclkdiv_c : slv(CDWIDTH-1 downto 0); -- abclkdiv (capt from CLKS->CLKU)
    abclkdiv_s : slv(CDWIDTH-1 downto 0); -- abclkdiv (sync in CLKU)
  end record synu_type;

  constant synu_init : synu_type := (
    '0','0',                            -- rxact_c,_s
    '0','0',                            -- txact_c,_s
    '0','0',                            -- abact_c,_s
    '0','0',                            -- rxok_c,_s
    '0','0',                            -- txok_c,_s
    slv(to_unsigned(0,CDWIDTH)),        -- abclkdiv_c
    slv(to_unsigned(0,CDWIDTH))         -- abclkdiv_s
  );
  
  type syns_type is record
    enaxon_c : slbit;                   -- enaxon (capt from CLKU->CLKS)
    enaxon_s : slbit;                   -- enaxon (sync in CLKS)
    enaesc_c : slbit;                   -- enaesc (capt from CLKU->CLKS)
    enaesc_s : slbit;                   -- enaesc (sync in CLKS)
  end record syns_type;

  constant syns_init : syns_type := (
    '0','0',                            -- enaxon_c,_s
    '0','0'                             -- enaxon_c,_s
  );
  
  signal R_SYNU : synu_type := synu_init;  -- sync registers (clku)
  signal R_SYNS : syns_type := syns_init;  -- sync registers (clks)

  signal R_RXOK : slbit := '1';

  signal RESET_INT : slbit := '0';
  signal RESET_CLKS : slbit := '0';

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
  signal RXFIFO_SIZEW : slv(RXFAWIDTH-1 downto 0) := (others=>'0');
  signal TXFIFO_DO : slv8 := (others=>'0');
  signal TXFIFO_VAL : slbit := '0';
  signal TXFIFO_HOLD : slbit := '0';
  
  signal RXERR  : slbit := '0';
  signal RXOVR  : slbit := '0';
  signal RXACT  : slbit := '0';
  signal ABACT  : slbit := '0';
  signal ABDONE : slbit := '0';
  signal ABCLKDIV : slv(CDWIDTH-1 downto 0) := (others=>'0');

  signal TXOK : slbit := '0';
  signal RXOK : slbit := '0';

  signal RXERR_CLKU  : slbit := '0';
  signal RXOVR_CLKU  : slbit := '0';
  signal ABDONE_CLKU : slbit := '0';

begin

  assert CDWIDTH<=16
    report "assert(CDWIDTH<=16): max width of UART clock divider"
    severity failure;

  CDC_RESET : cdc_pulse
  generic map (
    POUT_SINGLE => false,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKU,
    RESET    => '0',
    CLKS     => CLKS,
    PIN      => RESET,
    BUSY     => open,
    POUT     => RESET_CLKS
  );
  
  UART : serport_uart_rxtx_ab           -- uart, rx+tx+autobauder combo
  generic map (
    CDWIDTH => CDWIDTH,
    CDINIT  => CDINIT)
  port map (
    CLK        => CLKS,
    CE_MSEC    => CES_MSEC,
    RESET      => RESET_CLKS,
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
    ABCLKDIV_F => open
  );

  RESET_INT <= RESET_CLKS or ABACT;
  
  XONRX : serport_xonrx                 --  xon/xoff logic rx path
  port map (
    CLK         => CLKS,
    RESET       => RESET_INT,
    ENAXON      => R_SYNS.enaxon_s,
    ENAESC      => R_SYNS.enaesc_s,
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
    CLK         => CLKS,
    RESET       => RESET_INT,
    ENAXON      => R_SYNS.enaxon_s,
    ENAESC      => R_SYNS.enaesc_s,
    UART_TXDATA => UART_TXDATA,
    UART_TXENA  => XONTX_TXENA,
    UART_TXBUSY => XONTX_TXBUSY,
    TXDATA      => TXFIFO_DO,
    TXENA       => TXFIFO_VAL,
    TXBUSY      => TXFIFO_HOLD,
    RXOK        => RXOK,
    TXOK        => TXOK
  );
  
  RXFIFO : fifo_2c_dram                 -- input fifo, 2 clock, dram based
  generic map (
    AWIDTH => RXFAWIDTH,
    DWIDTH => 8)
  port map (
    CLKW   => CLKS,
    CLKR   => CLKU,
    RESETW => ABACT,                    -- clear fifo on abact
    RESETR => RESET,
    DI     => RXFIFO_DI,
    ENA    => RXFIFO_ENA,
    BUSY   => RXFIFO_BUSY,
    DO     => RXDATA,
    VAL    => RXVAL,
    HOLD   => RXHOLD,
    SIZEW  => RXFIFO_SIZEW,
    SIZER  => open
  );

  TXFIFO : fifo_2c_dram                 -- output fifo, 2 clock, dram based
  generic map (
    AWIDTH => TXFAWIDTH,
    DWIDTH => 8)
  port map (
    CLKW   => CLKU,
    CLKR   => CLKS,
    RESETW => RESET,
    RESETR => ABACT,                    -- clear fifo on abact
    DI     => TXDATA,
    ENA    => TXENA,
    BUSY   => TXBUSY,
    DO     => TXFIFO_DO,
    VAL    => TXFIFO_VAL,
    HOLD   => TXFIFO_HOLD,
    SIZEW  => open,
    SIZER  => open
  );

  -- receive back preasure
  --    on if fifo more than 3/4 full (less than 1/4 free)
  --   off if fifo less than 1/2 full (more than 1/2 free)
  proc_rxok: process (CLKS)
    constant rxsize_rxok_off : slv2 := "01";
    constant rxsize_rxok_on  : slv2 := "10";
    variable rxsize_msb : slv2 := "00";
  begin
    if rising_edge(CLKS) then
      if RESET_INT = '1' then
        R_RXOK <= '1';
      else
        rxsize_msb := RXFIFO_SIZEW(RXFAWIDTH-1 downto RXFAWIDTH-2);
        if unsigned(rxsize_msb) <  unsigned(rxsize_rxok_off) then
          R_RXOK <= '0';
        elsif unsigned(RXSIZE_MSB) >=  unsigned(rxsize_rxok_on) then
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

  proc_synu: process (CLKU)
  begin
    if rising_edge(CLKU) then
      R_SYNU.rxact_c    <= RXACT;
      R_SYNU.rxact_s    <= R_SYNU.rxact_c;
      R_SYNU.txact_c    <= UART_TXBUSY;
      R_SYNU.txact_s    <= R_SYNU.txact_c;
      R_SYNU.abact_c    <= ABACT;
      R_SYNU.abact_s    <= R_SYNU.abact_c;
      R_SYNU.rxok_c     <= RXOK;
      R_SYNU.rxok_s     <= R_SYNU.rxok_c;
      R_SYNU.txok_c     <= TXOK;
      R_SYNU.txok_s     <= R_SYNU.txok_c;
      R_SYNU.abclkdiv_c <= ABCLKDIV;
      R_SYNU.abclkdiv_s <= R_SYNU.abclkdiv_c;
    end if;
  end process proc_synu;
 
  proc_syns: process (CLKS)
  begin
    if rising_edge(CLKS) then
      R_SYNS.enaxon_c <= ENAXON;
      R_SYNS.enaxon_s <= R_SYNS.enaxon_c;
      R_SYNS.enaesc_c <= ENAESC;
      R_SYNS.enaesc_s <= R_SYNS.enaesc_c;
    end if;
  end process proc_syns; 

  CDC_RXERR : cdc_pulse
  generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKS,
    RESET    => '0',
    CLKS     => CLKU,
    PIN      => RXERR,
    BUSY     => open,
    POUT     => RXERR_CLKU
  );
  
  CDC_RXOVR : cdc_pulse
  generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKS,
    RESET    => '0',
    CLKS     => CLKU,
    PIN      => RXOVR,
    BUSY     => open,
    POUT     => RXOVR_CLKU
  );
  
  CDC_ABDONE : cdc_pulse
  generic map (
    POUT_SINGLE => true,
    BUSY_WACK   => false)
  port map (
    CLKM     => CLKS,
    RESET    => '0',
    CLKS     => CLKU,
    PIN      => ABDONE,
    BUSY     => open,
    POUT     => ABDONE_CLKU
  );
  
  MONI.rxerr  <= RXERR_CLKU;
  MONI.rxovr  <= RXOVR_CLKU;
  MONI.rxact  <= R_SYNU.rxact_s;
  MONI.txact  <= R_SYNU.txact_s;
  MONI.abact  <= R_SYNU.abact_s;
  MONI.abdone <= ABDONE_CLKU;
  MONI.rxok   <= R_SYNU.rxok_s;
  MONI.txok   <= R_SYNU.txok_s;
  
  proc_abclkdiv: process (R_SYNU.abclkdiv_s)
  begin
    MONI.abclkdiv <= (others=>'0');
    MONI.abclkdiv(R_SYNU.abclkdiv_s'range) <= R_SYNU.abclkdiv_s;
  end process proc_abclkdiv; 

-- synthesis translate_off

  proc_check: process (CLKS)
  begin
    assert RXOVR = '0'
      report "serport_2clock-W: RXOVR = '1'; data loss in receive fifo"
      severity warning;
    assert RXERR = '0'
      report "serport_2clock-W: RXERR = '1'; spurious receive error"
      severity warning;
  end process proc_check;

-- synthesis translate_on
  
end syn;
