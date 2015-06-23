



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	uart
-- File:	uart.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Asynchronous UART. Implements 8-bit data frame with one
--		stop-bit. Programmable options:
--		* parity bit (on/off)
--		* parity polarity (odd/even)
--		* baud-rate (12-bit programmable divider)
--		* hardware flow-control (CTS/RTS)
--		* Loop-back testing

--		Error-detection in receiver detects parity, framing
--		break and overrun errors. 
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned."+";
use IEEE.std_logic_unsigned."-";
use work.leon_target.all;
use work.leon_config.all;
use work.peri_serial_comp.all;
use work.macro.all;
use work.amba.all;
--pragma translate_off
use ieee.std_logic_unsigned.conv_integer;
use STD.TEXTIO.all;
--pragma translate_on

entity uart is
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uarti  : in  uart_in_type;
    uarto  : out uart_out_type
  );
end; 
 
architecture rtl of uart is


type rxfsmtype is (idle, startbit, data, parity, stopbit);
type txfsmtype is (idle, data, parity, stopbit);


type uartregs is record
  rxen   	:  std_logic;	-- receiver enabled
  txen   	:  std_logic;	-- transmitter enabled
  rirqen 	:  std_logic;	-- receiver irq enable
  tirqen 	:  std_logic;	-- transmitter irq enable
  parsel 	:  std_logic;	-- parity select
  paren  	:  std_logic;	-- parity select
  flow   	:  std_logic;	-- flow control enable
  loopb   	:  std_logic;	-- loop back mode enable
  dready    	:  std_logic;	-- data ready
  rsempty   	:  std_logic;	-- receiver shift register empty (internal)
  tsempty   	:  std_logic;	-- transmitter shift register empty
  thempty   	:  std_logic;	-- transmitter hold register empty
  break  	:  std_logic;	-- break detected
  ovf    	:  std_logic;	-- receiver overflow
  parerr    	:  std_logic;	-- parity error
  frame     	:  std_logic;	-- framing error
  rtsn      	:  std_logic;	-- request to send
  extclken  	:  std_logic;	-- use external baud rate clock
  extclk    	:  std_logic;	-- rising edge detect register
  rhold 	:  std_logic_vector(7 downto 0);
  rshift	:  std_logic_vector(7 downto 0);
  tshift	:  std_logic_vector(10 downto 0);
  thold 	:  std_logic_vector(7 downto 0);

  irq       	:  std_logic;	-- tx/rx interrupt (internal)
  tpar       	:  std_logic;	-- tx data parity (internal)

  txstate	:  txfsmtype;

  txclk 	:  std_logic_vector(2 downto 0);  -- tx clock divider
  txtick     	:  std_logic;	-- tx clock (internal)


  rxstate	:  rxfsmtype;

  rxclk 	:  std_logic_vector(2 downto 0); -- rx clock divider
  rxdb  	:  std_logic_vector(1 downto 0);  -- rx delay
  dpar       	:  std_logic;	-- rx data parity (internal)
  rxtick     	:  std_logic;	-- rx clock (internal)

  tick     	:  std_logic;	-- rx clock (internal)
  scaler	:  std_logic_vector(11 downto 0);
  brate 	:  std_logic_vector(11 downto 0);
  rxf    	:  std_logic_vector(7 downto 0); --  rx data filtering buffer

end record;


signal r, rin : uartregs;

begin

  uartop : process(rst, r, apbi, uarti )
  variable rdata : std_logic_vector(31 downto 0);
  variable scaler : std_logic_vector(11 downto 0);
  variable rxclk, txclk : std_logic_vector(2 downto 0);
  variable rxd, ctsn : std_logic;
  variable v : uartregs;
--pragma translate_off
  variable L1 : line;
  variable CH : character;
  variable FIRST : boolean := true;
  variable pt : time := 0 ns;
--pragma translate_on

  begin

    v := r;
    v.irq := '0'; v.txtick := '0'; v.rxtick := '0'; v.tick := '0';
    rdata := (others => '0'); v.rxdb(1) := r.rxdb(0);

-- scaler

-- pragma translate_off
    if not is_x(r.scaler) then		-- avoid warnings at reset time
-- pragma translate_on
      scaler := r.scaler - 1;
-- pragma translate_off
    end if;
-- pragma translate_on
    if (r.rxen or r.txen) = '1' then
      v.scaler := scaler;
      v.tick := scaler(11) and not r.scaler(11);
      if v.tick = '1' then v.scaler := r.brate; end if;
    end if;

-- optional external uart clock
    v.extclk := uarti.scaler(3);
    if r.extclken = '1' then v.tick := r.extclk and not uarti.scaler(3); end if;

-- read/write registers

    case apbi.paddr(3 downto 2) is
    when "00" => 
      rdata(7 downto 0) := r.rhold; 
      if (apbi.psel and apbi.penable and (not apbi.pwrite)) = '1' then 
	v.dready := '0';
      end if;
    when "01" => 
      rdata(6 downto 0) := r.frame & r.parerr & r.ovf & 
		r.break & r.thempty & r.tsempty & r.dready;
--pragma translate_off
      if DEBUGUART then rdata(2 downto 1) := "11"; end if;
--pragma translate_on
    when "10" => 
      rdata(8 downto 0) := r.extclken & r.loopb & r.flow & r.paren & r.parsel &
		r.tirqen & r.rirqen & r.txen & r.rxen;
    when others => 
      rdata(11 downto 0) := r.brate;
    end case;

    if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
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

-- pragma translate_off
    if not is_x(r.txclk) then		-- avoid warnings at reset time
-- pragma translate_on
      txclk := r.txclk + 1;
-- pragma translate_off
    else
      txclk := (others => 'X');
    end if;
-- pragma translate_on
    if r.tick = '1' then
      v.txclk := txclk;
      v.txtick := r.txclk(2) and not txclk(2);
    end if;

-- rx clock

-- pragma translate_off
    if not is_x(r.rxclk) then		-- avoid warnings at reset time
-- pragma translate_on
      rxclk := r.rxclk + 1;
-- pragma translate_off
    else
      rxclk := (others => 'X');
    end if;
-- pragma translate_on
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
	    v.tshift(0) := r.tpar; v.txstate := parity;
	  else
	    v.tshift(0) := '1'; v.txstate := stopbit;
	  end if;
	end if;
      end if;
    when parity =>	-- transmitt parity bit
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

    if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
      when "00" =>  
	v.thold := apbi.pwdata(7 downto 0); v.thempty := '0';
--pragma translate_off
	if DEBUGUART then
	  if first then L1:= new string'(""); first := false; end if; --'
--	  if (pt + 20 ns) < now then
	  if apbi.penable'event then	--'
	    CH := character'val(conv_integer(apbi.pwdata(7 downto 0))); --'
	    if CH = CR then std.textio.writeline(OUTPUT, L1); 
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
	  if r.paren = '1' then v.rxstate := parity;
	  else
	    v.rxstate := stopbit; v.dpar := '0';
	  end if;
	end if;
      end if;
    when parity =>	-- receive parity bit
      if r.rxtick = '1' then
	v.dpar := r.dpar xor rxd; 
	v.rxstate := stopbit;
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
	  if r.rshift = "00000000" then
	    v.break := '1'; 		 -- break
	  else
	    v.frame := '1'; 		 -- framing error
	  end if;
	  v.rsempty := '1';
	end if;
        v.rxstate := idle;
      end if;

    end case;

    if r.rxtick = '1' then
      v.rtsn := (r.dready and not r.rsempty) or r.loopb;
    end if;

-- reset operation

    if rst = '0' then 
      v.frame := '0'; v.rsempty := '1';
      v.parerr := '0'; v.ovf := '0'; v.break := '0'; v.thempty := '1';
      v.tsempty := '1'; v.dready := '0'; v.txen := '0'; v.rxen := '0';
      v.txstate := idle; v.rxstate := idle; v.tshift(0) := '1';
      v.extclken := '0';
      if BOOTOPT /= memory then
	if EXTBAUD then v.brate := "0000" & uarti.scaler;
	else v.brate := std_logic_vector(UPRESC(11 downto 0)); end if;
	v.scaler := v.brate;
--      else
--        v.brate := (others => '0');
      end if;
-- pragma translate_off
--      v.scaler := (others => '0'); 	-- only need this for simulation
-- pragma translate_on
      v.rtsn := '1'; v.flow := '0';
      v.txclk := (others => '0'); v.rxclk := (others => '0');
    end if;

-- update registers

    rin <= v;

-- drive outputs
    uarto.txd <= r.tshift(0) or r.loopb;
    uarto.irq <= r.irq;
    uarto.flow <= r.flow;
    uarto.rtsn <= r.rtsn;
    uarto.txen <= r.txen;
    uarto.rxen <= r.rxen;
    apbo.prdata <= rdata;

  end process;

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;


end;
