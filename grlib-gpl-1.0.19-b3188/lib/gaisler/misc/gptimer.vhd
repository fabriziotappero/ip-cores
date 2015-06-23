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
-- Entity: 	gptimer
-- File:	gptimer.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	This unit implemets a set of general-purpose timers with a 
--		common prescaler. Then number of timers and the width of
--		the timers is propgrammable through generics
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
--pragma translate_off
use std.textio.all;
--pragma translate_on

entity gptimer is
  generic (
    pindex   : integer := 0;
    paddr    : integer := 0;
    pmask    : integer := 16#fff#;
    pirq     : integer := 0;
    sepirq   : integer := 0;	-- use separate interrupts for each timer
    sbits    : integer := 16;			-- scaler bits
    ntimers  : integer range 1 to 7 := 1; 	-- number of timers
    nbits    : integer := 32;			-- timer bits
    wdog     : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    gpti   : in  gptimer_in_type;
    gpto   : out gptimer_out_type
  );
end; 
 
architecture rtl of gptimer is

constant REVISION : integer := 0;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_GPTIMER, 0, REVISION, pirq),
  1 => apb_iobar(paddr, pmask));

type timer_reg is record
  enable	:  std_ulogic;	-- enable counter
  load		:  std_ulogic;	-- load counter
  restart	:  std_ulogic;	-- restart counter
  irqpen  	:  std_ulogic;	-- interrupt pending
  irqen   	:  std_ulogic;	-- interrupt enable
  irq   	:  std_ulogic;	-- interrupt pulse
  chain 	:  std_ulogic;	-- chain with previous timer
  value 	:  std_logic_vector(nbits-1 downto 0);
  reload	:  std_logic_vector(nbits-1 downto 0);
end record;

type timer_reg_vector is array (Natural range <> ) of timer_reg;

constant TBITS   : integer := log2x(ntimers+1);

type registers is record
  scaler	:  std_logic_vector(sbits-1 downto 0);
  reload 	:  std_logic_vector(sbits-1 downto 0);
  tick          :  std_ulogic;
  tsel   	:  integer range 0 to ntimers;
  timers	:  timer_reg_vector(1 to ntimers);
  dishlt        :  std_ulogic;   
  wdogn         :  std_ulogic;   
  wdog         :  std_ulogic;   
end record;

signal r, rin : registers;

begin

  comb : process(rst, r, apbi, gpti)
  variable scaler : std_logic_vector(sbits downto 0);
  variable readdata, timer1 : std_logic_vector(31 downto 0);
  variable res, addin : std_logic_vector(nbits-1 downto 0);
  variable v : registers;
  variable z : std_ulogic;
  variable vtimers : timer_reg_vector(0 to ntimers);
  variable xirq : std_logic_vector(NAHBIRQ-1 downto 0);
  variable nirq : std_logic_vector(0 to ntimers-1);
  variable tick : std_logic_vector(1 to 7);
  begin

    v := r; v.tick := '0'; tick := (others => '0');
    vtimers(0) := ('0', '0', '0', '0', '0', '0', '0', 
		    zero32(nbits-1 downto 0), zero32(nbits-1 downto 0) );
    vtimers(1 to ntimers) := r.timers; xirq := (others => '0');
    for i in 1 to ntimers loop
      v.timers(i).irq := '0'; v.timers(i).load := '0';
      tick(i) := r.timers(i).irq;
    end loop;
    v.wdogn := not r.timers(ntimers).irqpen; v.wdog := r.timers(ntimers).irqpen;

-- scaler operation

    scaler := ('0' & r.scaler) - 1;	-- decrement scaler

    if (not gpti.dhalt or r.dishlt) = '1' then 	-- halt timers in debug mode
      if (scaler(sbits) = '1') then
        v.scaler := r.reload; v.tick := '1'; -- reload scaler
      else v.scaler := scaler(sbits-1 downto 0); end if;
    end if;

-- timer operation

    if (r.tick = '1') or (r.tsel /= 0) then
      if r.tsel = ntimers then v.tsel := 0;
      else v.tsel := r.tsel + 1; end if;
    end if;

    res := vtimers(r.tsel).value - 1;   -- decrement selected timer
    if (res(nbits-1) = '1') and ((vtimers(r.tsel).value(nbits-1) = '0'))
    then z := '1'; else z := '0'; end if; -- undeflow detect

-- update corresponding register and generate irq

    for i in 1 to ntimers-1 loop nirq(i) := r.timers(i).irq; end loop;
    nirq(0) := r.timers(ntimers).irq;

    for i in 1 to ntimers loop

      if i = r.tsel then
        if (r.timers(i).enable = '1') and 
	   (((r.timers(i).chain and nirq(i-1)) or not (r.timers(i).chain)) = '1') 
	then
          v.timers(i).irq := z and not r.timers(i).load;
	  if (v.timers(i).irq and r.timers(i).irqen) = '1' then 
	    v.timers(i).irqpen := '1';
	  end if;
	  v.timers(i).value := res;
	  if (z and not r.timers(i).load) = '1' then 
            v.timers(i).enable := r.timers(i).restart;
            if r.timers(i).restart = '1' then 
	      v.timers(i).value := r.timers(i).reload;
	    end if;
	  end if;
        end if;
      end if;
      if r.timers(i).load = '1' then 
	v.timers(i).value := r.timers(i).reload;
      end if;
    end loop;

    if sepirq /= 0 then 
      for i in 1 to ntimers loop 
	xirq(i-1+pirq) := r.timers(i).irq and r.timers(i).irqen;
      end loop;
    else 
      for i in 1 to ntimers loop
	xirq(pirq) := xirq(pirq) or (r.timers(i).irq and r.timers(i).irqen);
      end loop;
    end if;

-- read registers

    readdata := (others => '0');
    case apbi.paddr(6 downto 2) is
    when "00000" => readdata(sbits-1 downto 0)  := r.scaler;
    when "00001" => readdata(sbits-1 downto 0)  := r.reload;
    when "00010" => 
	readdata(2 downto 0) := conv_std_logic_vector(ntimers, 3) ;
	readdata(7 downto 3) := conv_std_logic_vector(pirq, 5) ;
	if (sepirq /= 0) then readdata(8) := '1'; end if;
        readdata(9) := r.dishlt;
    when others =>
      for i in 1 to ntimers loop
        if conv_integer(apbi.paddr(6 downto 4)) = i then
          case apbi.paddr(3 downto 2) is
          when "00" => readdata(nbits-1 downto 0) := r.timers(i).value;
          when "01" => readdata(nbits-1 downto 0) := r.timers(i).reload;
    	  when "10" => readdata(6 downto 0) := 
		gpti.dhalt & r.timers(i).chain &
		r.timers(i).irqpen & r.timers(i).irqen & r.timers(i).load &
		r.timers(i).restart & r.timers(i).enable;
          when others => 
          end case;
        end if;
      end loop;
    end case;

-- write registers

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(6 downto 2) is
      when "00000" => v.scaler := apbi.pwdata(sbits-1 downto 0);
      when "00001" => v.reload := apbi.pwdata(sbits-1 downto 0);
                      v.scaler := apbi.pwdata(sbits-1 downto 0);
      when "00010" => v.dishlt := apbi.pwdata(9);
      when others => 
        for i in 1 to ntimers loop
          if conv_integer(apbi.paddr(6 downto 4)) = i then
            case apbi.paddr(3 downto 2) is
              when "00" => v.timers(i).value   := apbi.pwdata(nbits-1 downto 0);
              when "01" => v.timers(i).reload  := apbi.pwdata(nbits-1 downto 0);
              when "10" => v.timers(i).chain   := apbi.pwdata(5);
                           v.timers(i).irqpen  := apbi.pwdata(4);
			   v.timers(i).irqen   := apbi.pwdata(3);
			   v.timers(i).load    := apbi.pwdata(2);
			   v.timers(i).restart := apbi.pwdata(1);
			   v.timers(i).enable  := apbi.pwdata(0);
            when others => 
            end case;
          end if;
        end loop;
      end case;
    end if;


-- reset operation

    if rst = '0' then 
      for i in 1 to ntimers loop
        v.timers(i).enable := '0'; v.timers(i).irqen := '0';
      end loop;
      v.scaler := (others => '1'); v.reload := (others => '1'); 
      v.tsel := 0; v.dishlt := '0'; v.timers(ntimers).irq := '0';
      if (wdog /= 0) then
	v.timers(ntimers).enable := '1'; v.timers(ntimers).load := '1';
	v.timers(ntimers).reload := conv_std_logic_vector(wdog, nbits);
	v.timers(ntimers).chain := '0'; v.timers(ntimers).irqen := '1';
	v.timers(ntimers).irqpen := '0'; v.timers(ntimers).restart := '0';
      end if;
    end if;

    timer1 := (others => '0'); timer1(nbits-1 downto 0) := r.timers(1).value;

    rin <= v;
    apbo.prdata <= readdata; 	-- drive apb read bus
    apbo.pirq <= xirq;
    apbo.pindex <= pindex;
    gpto.tick <= r.tick & tick;
    gpto.timer1 <= timer1;	-- output timer1 value for debugging
    gpto.wdogn <= r.wdogn;
    gpto.wdog  <= r.wdog;

  end process;

  apbo.pconfig <= pconfig;

-- registers

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

-- boot message

-- pragma translate_off
    bootmsg : report_version 
    generic map ("gptimer" & tost(pindex) & 
	": GR Timer Unit rev " & tost(REVISION) & 
	", " & tost(sbits) & "-bit scaler, " & tost(ntimers) & 
	" " & tost(nbits) & "-bit timers" & ", irq " & tost(pirq));
-- pragma translate_on

end;
