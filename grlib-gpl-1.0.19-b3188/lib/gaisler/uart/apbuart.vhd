------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity: 	uart
-- File:	uart.vhd
-- Authors:	Jiri Gaisler - Gaisler Research
--              Marko Isomaki - Gaisler Research
-- Description:	Asynchronous UART. Implements 8-bit data frame with one stop-bit.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.uart.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

entity apbuart is
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    console  : integer := 0;
    pirq     : integer := 0;
    parity   : integer := 1;
    flow     : integer := 1;
    fifosize : integer range 1 to 32 := 1;
    abits    : integer := 8);
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uarti  : in  uart_in_type;
    uarto  : out uart_out_type);
end;

architecture rtl of apbuart is

constant REVISION : integer := 1;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_APBUART, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

type rxfsmtype is (idle, startbit, data, cparity, stopbit);
type txfsmtype is (idle, data, cparity, stopbit);

type fifo is array (0 to fifosize - 1) of std_logic_vector(7 downto 0);

type uartregs is record
  rxen   	:  std_ulogic;	-- receiver enabled
  txen   	:  std_ulogic;	-- transmitter enabled
  rirqen 	:  std_ulogic;	-- receiver irq enable
  tirqen 	:  std_ulogic;	-- transmitter irq enable
  oen           :  std_ulogic;  -- output enable
  parsel 	:  std_ulogic;	-- parity select
  paren  	:  std_ulogic;	-- parity select
  flow   	:  std_ulogic;	-- flow control enable
  loopb   	:  std_ulogic;	-- loop back mode enable
  debug         :  std_ulogic;  -- debug mode enable
  rsempty   	:  std_ulogic;	-- receiver shift register empty (internal)
  tsempty   	:  std_ulogic;	-- transmitter shift register empty
  break  	:  std_ulogic;	-- break detected
  ovf    	:  std_ulogic;	-- receiver overflow
  parerr    	:  std_ulogic;	-- parity error
  frame     	:  std_ulogic;	-- framing error
  ctsn      	:  std_logic_vector(1 downto 0); -- clear to send
  rtsn      	:  std_ulogic;	-- request to send
  extclken  	:  std_ulogic;	-- use external baud rate clock
  extclk    	:  std_ulogic;	-- rising edge detect register
  rhold 	:  fifo;
  rshift	:  std_logic_vector(7 downto 0);
  tshift	:  std_logic_vector(10 downto 0);
  thold 	:  fifo;
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
  rxf    	:  std_logic_vector(4 downto 0); --  rx data filtering buffer
  txd        	:  std_ulogic;	-- transmitter data
  rfifoirqen    :  std_ulogic;  -- receiver fifo interrupt enable
  tfifoirqen    :  std_ulogic;  -- transmitter fifo interrupt enable
 --fifo counters
  rwaddr        :  std_logic_vector(log2x(fifosize) - 1 downto 0);
  rraddr        :  std_logic_vector(log2x(fifosize) - 1 downto 0);
  traddr        :  std_logic_vector(log2x(fifosize) - 1 downto 0);
  twaddr        :  std_logic_vector(log2x(fifosize) - 1 downto 0);
  rcnt          :  std_logic_vector(log2x(fifosize) downto 0);
  tcnt          :  std_logic_vector(log2x(fifosize) downto 0);
end record;

constant  rcntzero : std_logic_vector(log2x(fifosize) downto 0) := (others => '0');

signal r, rin : uartregs;

begin
  uartop : process(rst, r, apbi, uarti )
  variable rdata : std_logic_vector(31 downto 0);
  variable scaler : std_logic_vector(11 downto 0);
  variable rxclk, txclk : std_logic_vector(2 downto 0);
  variable rxd, ctsn : std_ulogic;
  variable irq : std_logic_vector(NAHBIRQ-1 downto 0);
  variable paddr : std_logic_vector(7 downto 2);
  variable v : uartregs;
  variable thalffull : std_ulogic;
  variable rhalffull : std_ulogic;
  variable rfull : std_ulogic;
  variable tfull : std_ulogic;
  variable dready : std_ulogic;
  variable thempty : std_ulogic;
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
    dready := '0'; thempty := '1'; thalffull := '1'; rhalffull := '0';
    v.ctsn := r.ctsn(0) & uarti.ctsn;

    if fifosize = 1 then
      dready := r.rcnt(0); rfull := dready; tfull := r.tcnt(0);
      thempty := not tfull;
    else
      tfull := r.tcnt(log2x(fifosize)); rfull := r.rcnt(log2x(fifosize));
      if (r.rcnt(log2x(fifosize)) or r.rcnt(log2x(fifosize) - 1)) = '1' then
        rhalffull := '1';
      end if;
      if ((r.tcnt(log2x(fifosize)) or r.tcnt(log2x(fifosize) - 1))) = '1' then
        thalffull := '0';
      end if;
      if r.rcnt /= rcntzero then dready := '1'; end if;
      if r.tcnt /= rcntzero then thempty := '0'; end if;
    end if;

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

  if (apbi.psel(pindex) and apbi.penable and (not apbi.pwrite)) = '1' then
    case paddr(7 downto 2) is
    when "000000" =>
      rdata(7 downto 0) := r.rhold(conv_integer(r.rraddr));
	if fifosize = 1 then v.rcnt(0) := '0';
	else
	  if r.rcnt /= rcntzero then
	    v.rraddr := r.rraddr + 1; v.rcnt := r.rcnt - 1;
	  end if;
	end if;
    when "000001" =>
      if fifosize /= 1 then
	rdata (26 + log2x(fifosize) downto 26) := r.rcnt;
	rdata (20 + log2x(fifosize) downto 20) := r.tcnt;
	rdata (10 downto 7) := rfull & tfull & rhalffull & thalffull;
      end if;

      rdata(6 downto 0) := r.frame & r.parerr & r.ovf &
        	r.break & thempty & r.tsempty & dready;
--pragma translate_off
      if CONSOLE = 1 then rdata(2 downto 1) := "11"; end if;
--pragma translate_on
    when "000010" =>
      if fifosize > 1 then
        rdata(31) := '1';
      end if;
      rdata(12) := r.oen;
      rdata(11) := r.debug;
      if fifosize /= 1 then
	rdata(10 downto 9) := r.rfifoirqen & r.tfifoirqen;
      end if;
      rdata(8 downto 0) := r.extclken & r.loopb &
           r.flow & r.paren & r.parsel & r.tirqen & r.rirqen & r.txen & r.rxen;
    when "000011" =>
      rdata(11 downto 0) := r.brate;
    when "000100" =>
    
        -- Read TX FIFO.
        if r.debug = '1' and r.tcnt /= rcntzero then
            rdata(7 downto 0) := r.thold(conv_integer(r.traddr));
            if fifosize = 1 then
                v.tcnt(0) := '0';
            else
                v.traddr := r.traddr + 1;
                v.tcnt := r.tcnt - 1;
            end if;
        end if;
    when others =>
      null;
    end case;
  end if;

    paddr := "000000"; paddr(abits-1 downto 2) := apbi.paddr(abits-1 downto 2);
    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case paddr(7 downto 2) is
      when "000000" =>
      when "000001" =>
	v.frame      := apbi.pwdata(6);
	v.parerr     := apbi.pwdata(5);
	v.ovf 	     := apbi.pwdata(4);
	v.break      := apbi.pwdata(3);
      when "000010" =>
        v.oen        := apbi.pwdata(12);
        v.debug      := apbi.pwdata(11);
	if fifosize /= 1 then
	  v.rfifoirqen := apbi.pwdata(10);
	  v.tfifoirqen := apbi.pwdata(9);
	end if;
	v.extclken   := apbi.pwdata(8);
	v.loopb	     := apbi.pwdata(7);
	v.flow 	     := apbi.pwdata(6);
	v.paren      := apbi.pwdata(5);
	v.parsel     := apbi.pwdata(4);
	v.tirqen     := apbi.pwdata(3);
	v.rirqen     := apbi.pwdata(2);
	v.txen 	     := apbi.pwdata(1);
	v.rxen 	     := apbi.pwdata(0);
      when "000011" =>
	v.brate      := apbi.pwdata(11 downto 0);
	v.scaler     := apbi.pwdata(11 downto 0);
      when "000100" =>
        -- Write RX fifo and generate irq
	if flow /= 0 then
	  v.rhold(conv_integer(r.rwaddr)) := apbi.pwdata(7 downto 0);
	  if fifosize = 1 then v.rcnt(0) := '1';
	  else v.rwaddr := r.rwaddr + 1; v.rcnt := v.rcnt + 1; end if;

          if r.debug = '1' then
              v.irq := v.irq or r.rirqen;
          end if;
          
        end if;
      when others =>
        null;
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

--    v.rxf := r.rxf(6 downto 0) & uarti.rxd;
--    if ((r.rxf(7) & r.rxf(7) & r.rxf(7) & r.rxf(7) & r.rxf(7) & r.rxf(7) &
--	 r.rxf(7)) = r.rxf(6 downto 0))
--    then v.rxdb(0) := r.rxf(7); end if;

    v.rxf(1 downto 0) := r.rxf(0) & uarti.rxd;	-- meta-stability filter
    if r.tick = '1' then
      v.rxf(4 downto 2) := r.rxf(3 downto 1);
    end if;
    v.rxdb(0) := (r.rxf(4) and r.rxf(3)) or (r.rxf(4) and r.rxf(2)) or 
		  (r.rxf(3) and r.rxf(2));
-- loop-back mode
    if r.loopb = '1' then
      v.rxdb(0) := r.tshift(0); ctsn := dready and not r.rsempty;
    elsif (flow = 1) then ctsn := r.ctsn(1); else ctsn := '0'; end if;
    rxd := r.rxdb(0);

-- transmitter operation

    case r.txstate is
    when idle =>	-- idle state
      if (r.txtick = '1') then v.tsempty := '1'; end if;
      
      if ((not r.debug and r.txen and (not thempty) and r.txtick) and
          ((not ctsn) or not r.flow)) = '1' then
          v.txstate := data;
          v.tpar := r.parsel; v.tsempty := '0';
          v.txclk := "00" & r.tick; v.txtick := '0';
          v.tshift := "10" & r.thold(conv_integer(r.traddr)) & '0';
          if fifosize = 1 then
              v.irq := r.irq or r.tirqen; v.tcnt(0) := '0';
          else
              v.traddr := r.traddr + 1;
              v.tcnt := r.tcnt - 1;
          end if;
      end if;
      
    when data =>	-- transmit data frame
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
    when cparity =>	-- transmit parity bit
      if r.txtick = '1' then
	v.tshift := '1' & r.tshift(10 downto 1); v.txstate := stopbit;
      end if;
    when stopbit =>	-- transmit stop bit
      if r.txtick = '1' then
	v.tshift := '1' & r.tshift(10 downto 1); v.txstate := idle;
      end if;

    end case;

-- writing of tx data register must be done after tx fsm to get correct
-- operation of thempty flag

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case paddr(4 downto 2) is
      when "000" =>
        if fifosize = 1 then
	  v.thold(0) := apbi.pwdata(7 downto 0); v.tcnt(0) := '1';
	else
	  v.thold(conv_integer(r.twaddr)) := apbi.pwdata(7 downto 0);
	  if not (tfull = '1') then
	    v.twaddr := r.twaddr + 1; v.tcnt :=  v.tcnt + 1;
	  end if;
	end if;
--pragma translate_off
	if CONSOLE = 1 then
	  if first then L1:= new string'(""); first := false; end if; --'
	  if apbi.penable'event then	--'
	    CH := character'val(conv_integer(apbi.pwdata(7 downto 0))); --'
	    if CH  = CR then
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
      if ((r.rsempty = '0') and not (rfull = '1')) then
	  v.rsempty := '1';
	  v.rhold(conv_integer(r.rwaddr)) := r.rshift;
	  if fifosize = 1 then v.rcnt(0) := '1';
	  else v.rwaddr := r.rwaddr + 1; v.rcnt := v.rcnt + 1; end if;
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
	  v.parerr := r.parerr or r.dpar; v.rsempty := r.dpar;
          if not (rfull = '1') and (r.dpar = '0') then
	    v.rsempty := '1';
	    v.rhold(conv_integer(r.rwaddr)) := r.rshift;
	    if fifosize = 1 then v.rcnt(0) := '1';
	    else v.rwaddr := r.rwaddr + 1; v.rcnt := v.rcnt + 1; end if;
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
      v.rtsn := (rfull and not r.rsempty) or r.loopb;
    end if;

    v.txd := r.tshift(0) or r.loopb or r.debug;

    if fifosize /= 1 then
      if thempty = '0' and v.tcnt = rcntzero then
        v.irq := v.irq or r.tirqen;
      end if;
      v.irq := v.irq or (r.tfifoirqen and r.txen and thalffull);
      v.irq := v.irq or (r.rfifoirqen and r.rxen and rhalffull);
    end if;



-- reset operation

    if rst = '0' then
      v.frame := '0'; v.rsempty := '1';
      v.parerr := '0'; v.ovf := '0'; v.break := '0';
      v.tsempty := '1'; v.txen := '0'; v.rxen := '0';
      v.txstate := idle; v.rxstate := idle; v.tshift(0) := '1';
      v.extclken := '0'; v.rtsn := '1'; v.flow := '0';
      v.txclk := (others => '0'); v.rxclk := (others => '0');
      v.rcnt := (others => '0'); v.tcnt := (others => '0');
      v.rwaddr := (others => '0'); v.twaddr := (others => '0');
      v.rraddr := (others => '0'); v.traddr := (others => '0');
    end if;

-- update registers

    rin <= v;

-- drive outputs

    uarto.txd <= r.txd; uarto.rtsn <= r.rtsn;
    uarto.scaler <= "000000" & r.scaler;
    uarto.txen <= r.oen; uarto.rxen <= r.rxen;
    apbo.prdata <= rdata; apbo.pirq <= irq;
    apbo.pindex <= pindex;
    uarto.txen <= r.txen; uarto.rxen <= r.rxen;

  end process;

  apbo.pconfig <= pconfig;

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

-- pragma translate_off
    bootmsg : report_version
    generic map ("apbuart" & tost(pindex) &
	": Generic UART rev " & tost(REVISION) & ", fifo " & tost(fifosize) &
	", irq " & tost(pirq));
-- pragma translate_on

end;
