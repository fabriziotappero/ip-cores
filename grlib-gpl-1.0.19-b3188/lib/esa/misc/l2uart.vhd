----------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2004 GAISLER RESEARCH
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  See the file COPYING for the full details of the license.
--
-----------------------------------------------------------------------------
-- Entity: 	l2uart
-- File:	l2uart.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Asynchronous UART originally developed for LEON2.
--		Implements 8-bit data frame with one stop-bit.
--		Programmable options:
--		* parity bit (on/off)
--		* parity polarity (odd/even)
--		* baud-rate (12-bit programmable divider)
--		* hardware flow-control (CTS/RTS)
--		* Loop-back testing
--
--		Error-detection in receiver detects parity, framing
--		break and overrun errors.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.uart.all;
use grlib.devices.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

entity l2uart is
  generic (
    pindex  : integer := 0;
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    console : integer := 0;
    pirq    : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uarti  : in  uart_in_type;
    uarto  : out uart_out_type);
end;

architecture rtl of l2uart is

constant REVISION : integer := 1;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_ESA, ESA_UART, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

type rxfsmtype is (idle, startbit, data, cparity, stopbit);
type txfsmtype is (idle, data, cparity, stopbit);

type uartregs is record
  rxen   	:  std_ulogic;	-- receiver enabled
  txen   	:  std_ulogic;	-- transmitter enabled
  rirqen 	:  std_ulogic;	-- receiver irq enable
  tirqen 	:  std_ulogic;	-- transmitter irq enable
  parsel 	:  std_ulogic;	-- parity select
  paren  	:  std_ulogic;	-- parity select
  flow   	:  std_ulogic;	-- flow control enable
  loopb   	:  std_ulogic;	-- loop back mode enable
  dready    	:  std_ulogic;	-- data ready
  rsempty   	:  std_ulogic;	-- receiver shift register empty (internal)
  tsempty   	:  std_ulogic;	-- transmitter shift register empty
  thempty   	:  std_ulogic;	-- transmitter hold register empty
  break  	:  std_ulogic;	-- break detected
  ovf    	:  std_ulogic;	-- receiver overflow
  parerr    	:  std_ulogic;	-- parity error
  frame     	:  std_ulogic;	-- framing error
  rtsn      	:  std_ulogic;	-- request to send
  extclken  	:  std_ulogic;	-- use external baud rate clock
  extclk    	:  std_ulogic;	-- rising edge detect register
  rhold 	:  std_logic_vector(7 downto 0);
  rshift	:  std_logic_vector(7 downto 0);
  tshift	:  std_logic_vector(10 downto 0);
  thold 	:  std_logic_vector(7 downto 0);
  irq       	:  std_ulogic;	-- tx/rx interrupt (internal)
  tpar       	:  std_ulogic;	-- tx data parity (internal)
  txstate	:  txfsmtype;
  txclk 	:  std_logic_vector(2 downto 0);  -- tx clock divider
  txtick     	:  std_ulogic;	-- tx clock (internal)
  rxstate	:  rxfsmtype;
  rxclk 	:  std_logic_vector(2 downto 0); -- rx clock divider
  rxdb  	:  std_logic_vector(1 downto 0);  -- rx delay
  dpar       	:  std_ulogic;	-- rx data parity (internal)
  rxtick     	:  std_ulogic;	-- rx clock (internal)
  tick     	:  std_ulogic;	-- rx clock (internal)
  scaler	:  std_logic_vector(11 downto 0);
  brate 	:  std_logic_vector(11 downto 0);
  rxf    	:  std_logic_vector(7 downto 0); --  rx data filtering buffer
  txd        	:  std_ulogic;	-- transmitter data
end record;


signal r, rin : uartregs;

begin

  uartop : process(rst, r, apbi, uarti )
  variable rdata : std_logic_vector(31 downto 0);
  variable scaler : std_logic_vector(11 downto 0);
  variable rxclk, txclk : std_logic_vector(2 downto 0);
  variable rxd, ctsn : std_ulogic;
  variable irq : std_logic_vector(NAHBIRQ-1 downto 0);
  variable v : uartregs;
--pragma translate_off
  variable L1 : line;
  variable CH : character;
  variable FIRST : boolean := true;
  variable pt : time := 0 ns;
--pragma translate_on

  begin

    v := r; irq := (others => '0'); irq(pirq) := r.irq;
    v.irq := '0'; v.txtick := '0'; v.rxtick := '0'; v.tick := '0';
    rdata := (others => '0'); v.rxdb(1) := r.rxdb(0);

-- scaler

    scaler := r.scaler - 1;
    if (r.rxen or r.txen) = '1' then
      v.scaler := scaler;
      v.tick := scaler(11) and not r.scaler(11);
      if v.tick = '1' then v.scaler := r.brate; end if;
    end if;

-- optional external uart clock
    v.extclk := uarti.extclk;
    if r.extclken = '1' then v.tick := r.extclk and not uarti.extclk; end if;

-- read/write registers

    case apbi.paddr(3 downto 2) is
    when "00" =>
      rdata(7 downto 0) := r.rhold;
      if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
	v.dready := '0';
      end if;
    when "01" =>
      rdata(6 downto 0) := r.frame & r.parerr & r.ovf &
		r.break & r.thempty & r.tsempty & r.dready;
--pragma translate_off
      if CONSOLE = 1 then rdata(2 downto 1) := "11"; end if;
--pragma translate_on
    when "10" =>
      rdata(8 downto 0) := r.extclken & r.loopb & r.flow & r.paren & r.parsel &
		r.tirqen & r.rirqen & r.txen & r.rxen;
    when others =>
      rdata(11 downto 0) := r.brate;
    end case;

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
      when "01" =>
	v.frame  := apbi.pwdata(6);
	v.parerr := apbi.pwdata(5);
	v.ovf 	 := apbi.pwdata(4);
	v.break  := apbi.pwdata(3);
      when "10" =>
	v.extclken := apbi.pwdata(8);
	v.loopb	 := apbi.pwdata(7);
	v.flow 	 := apbi.pwdata(6);
	v.paren  := apbi.pwdata(5);
	v.parsel := apbi.pwdata(4);
	v.tirqen := apbi.pwdata(3);
	v.rirqen := apbi.pwdata(2);
	v.txen 	 := apbi.pwdata(1);
	v.rxen 	 := apbi.pwdata(0);
      when "11" =>
	v.brate := apbi.pwdata(11 downto 0);
	v.scaler := apbi.pwdata(11 downto 0);
      when others =>
      end case;
    end if;

-- tx clock

    txclk := r.txclk + 1;
    if r.tick = '1' then
      v.txclk := txclk;
      v.txtick := r.txclk(2) and not txclk(2);
    end if;

-- rx clock

    rxclk := r.rxclk + 1;
    if r.tick = '1' then
      v.rxclk := rxclk;
      v.rxtick := r.rxclk(2) and not rxclk(2);
    end if;

-- filter rx data

    v.rxf := r.rxf(6 downto 0) & uarti.rxd;
    if ((r.rxf(7) & r.rxf(7) & r.rxf(7) & r.rxf(7) & r.rxf(7) & r.rxf(7) &
	 r.rxf(7)) = r.rxf(6 downto 0))
    then v.rxdb(0) := r.rxf(7); end if;

-- loop-back mode
    if r.loopb = '1' then
      v.rxdb(0) := r.tshift(0); ctsn := r.dready and not r.rsempty;
    else
      ctsn := uarti.ctsn;
    end if;
    rxd := r.rxdb(0);

-- transmitter operation

    case r.txstate is
    when idle =>	-- idle state
      if (r.txtick = '1') then v.tsempty := '1'; end if;
      if ((r.txen and (not r.thempty) and r.txtick) and
	  ((not ctsn) or not r.flow)) = '1' then
	v.tshift := "10" & r.thold & '0'; v.txstate := data;
	v.tpar := r.parsel; v.irq := r.tirqen; v.thempty := '1';
	v.tsempty := '0'; v.txclk := "00" & r.tick; v.txtick := '0';
      end if;
    when data =>	-- transmitt data frame
      if r.txtick = '1' then
	v.tpar := r.tpar xor r.tshift(1);
	v.tshift := '1' & r.tshift(10 downto 1);
        if r.tshift(10 downto 1) = "1111111110" then
	  if r.paren = '1' then
	    v.tshift(0) := r.tpar; v.txstate := cparity;
	  else
	    v.tshift(0) := '1'; v.txstate := stopbit;
	  end if;
	end if;
      end if;
    when cparity =>	-- transmitt parity bit
      if r.txtick = '1' then
	v.tshift := '1' & r.tshift(10 downto 1); v.txstate := stopbit;
      end if;
    when stopbit =>	-- transmitt stop bit
      if r.txtick = '1' then
	v.tshift := '1' & r.tshift(10 downto 1); v.txstate := idle;
      end if;

    end case;

-- writing of tx data register must be done after tx fsm to get correct
-- operation of thempty flag

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
      when "00" =>
	v.thold := apbi.pwdata(7 downto 0); v.thempty := '0';
--pragma translate_off
	if CONSOLE = 1 then
	  if first then L1:= new string'(""); first := false; end if; --'
	  if apbi.penable'event then	--'
	    CH := character'val(conv_integer(apbi.pwdata(7 downto 0))); --'
	    if CH = CR then
	      std.textio.writeline(OUTPUT, L1);
	    elsif CH /= LF then
	      std.textio.write(L1,CH);
	    end if;
	    pt := now;
	  end if;
	end if;
--pragma translate_on
      when others => null;
      end case;
    end if;

-- receiver operation

    case r.rxstate is
    when idle =>	-- wait for start bit
      if ((not r.rsempty) and not r.dready) = '1' then
	v.rhold := r.rshift; v.rsempty := '1'; v.dready := '1';
      end if;
      if (r.rxen and r.rxdb(1) and (not rxd)) = '1' then
	v.rxstate := startbit; v.rshift := (others => '1'); v.rxclk := "100";
	if v.rsempty = '0' then v.ovf := '1'; end if;
	v.rsempty := '0'; v.rxtick := '0';
      end if;
    when startbit =>	-- check validity of start bit
      if r.rxtick = '1' then
	if rxd = '0' then
	  v.rshift := rxd & r.rshift(7 downto 1); v.rxstate := data;
	  v.dpar := r.parsel;
	else
	  v.rxstate := idle;
        end if;
      end if;
    when data =>	-- receive data frame
      if r.rxtick = '1' then
	v.dpar := r.dpar xor rxd;
	v.rshift := rxd & r.rshift(7 downto 1);
	if r.rshift(0) = '0' then
	  if r.paren = '1' then v.rxstate := cparity;
	  else v.rxstate := stopbit; v.dpar := '0'; end if;
	end if;
      end if;
    when cparity =>	-- receive parity bit
      if r.rxtick = '1' then
	v.dpar := r.dpar xor rxd; v.rxstate := stopbit;
      end if;
    when stopbit =>	-- receive stop bit
      if r.rxtick = '1' then
	v.irq := v.irq or r.rirqen; -- make sure no tx irqs are lost !
	if rxd = '1' then
	  v.parerr := r.dpar; v.rsempty := r.dpar;
	  if v.dready = '0' then
	    v.rhold := r.rshift; v.rsempty := '1'; v.dready := not r.dpar;
	  end if;
	else
	  if r.rshift = "00000000" then v.break := '1';
	  else v.frame := '1'; end if;
	  v.rsempty := '1';
	end if;
        v.rxstate := idle;
      end if;

    end case;

    if r.rxtick = '1' then
      v.rtsn := (r.dready and not r.rsempty) or r.loopb;
    end if;

    v.txd := r.tshift(0) or r.loopb;

-- reset operation

    if rst = '0' then
      v.frame := '0'; v.rsempty := '1';
      v.parerr := '0'; v.ovf := '0'; v.break := '0'; v.thempty := '1';
      v.tsempty := '1'; v.dready := '0'; v.txen := '0'; v.rxen := '0';
      v.txstate := idle; v.rxstate := idle; v.tshift(0) := '1';
      v.extclken := '0'; v.rtsn := '1'; v.flow := '0';
      v.txclk := (others => '0'); v.rxclk := (others => '0');
    end if;

-- update registers

    rin <= v;

-- drive outputs

    uarto.txd <= r.txd; uarto.rtsn <= r.rtsn;
    apbo.prdata <= rdata; apbo.pirq <= irq;
    apbo.pindex <= pindex;

  end process;

  apbo.pconfig <= pconfig;

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

-- pragma translate_off
    bootmsg : report_version
    generic map ("l2uart" & tost(pindex) &
	": LEON2 Generic UART rev " & tost(REVISION) & ", irq " & tost(pirq));
-- pragma translate_on

end;
