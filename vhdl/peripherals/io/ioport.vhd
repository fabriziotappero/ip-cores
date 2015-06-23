



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
-- Entity: 	ioport
-- File:	ioport.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Parallel I/O port. On reset, all port are programmed as
--		inputs and remaning registers are unknown. This means
--		that the interrupt configuration registers must be
--		written before I/O port interrputs are unmasked in the
--		interrupt controller.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed."-";
use work.leon_config.all;
use work.peri_serial_comp.all;
use work.peri_io_comp.all;
use work.macro.genmux;
use work.amba.all;

 
entity ioport is
  port (
    rst    : in  std_logic;
    clk    : in  std_logic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    uart1o : in  uart_out_type;
    uart2o : in  uart_out_type;
    mctrlo_pioh : in  std_logic_vector(15 downto 0);
    ioi    : in  io_in_type;
    pioo   : out pio_out_type
  );
end; 
 
architecture rtl of ioport is

constant ISELLEN : integer := 5;
type irq_ctrl_type is record
  isel	 : std_logic_vector(ISELLEN-1 downto 0);
  pol    : std_logic;
  edge   : std_logic;
  enable : std_logic;
end record;

type irq_conf_type is array (3 downto 0) of irq_ctrl_type;

type pioregs is record
  irqout	:  std_logic_vector(3 downto 0);
  irqlat	:  std_logic_vector(3 downto 0);
  pin1      	:  std_logic_vector(15 downto 0);
  pin2		:  std_logic_vector(31 downto 0);
  pdir		:  std_logic_vector(17 downto 0);
  pout		:  std_logic_vector(15 downto 0);
  iconf 	:  irq_conf_type;
end record;

signal r, rin : pioregs;

begin

  pioop : process(rst, r, apbi, mctrlo_pioh, ioi, uart1o, uart2o)
  variable rdata : std_logic_vector(31 downto 0);
  variable v : pioregs;
  variable wrio : std_logic;
  begin

    v := r; wrio := '0';

-- synchronise port inputs. Low 16 bits are latched twice while high 16 bits
-- are allready latched once in the memory controller and therefore only
-- latched once here.

    v.pin1 := ioi.piol; v.pin2 := mctrlo_pioh & r.pin1;

-- read/write registers

    rdata := (others => '0');
    case apbi.paddr(3 downto 2) is
    when "00" => rdata(31 downto 0) := r.pin2;
    when "01" => rdata(17 downto 0) := not r.pdir;
    when "10" => rdata(31 downto 0) := 
	  r.iconf(3).enable & r.iconf(3).edge & r.iconf(3).pol & r.iconf(3).isel &
	  r.iconf(2).enable & r.iconf(2).edge & r.iconf(2).pol & r.iconf(2).isel &
	  r.iconf(1).enable & r.iconf(1).edge & r.iconf(1).pol & r.iconf(1).isel &
	  r.iconf(0).enable & r.iconf(0).edge & r.iconf(0).pol & r.iconf(0).isel;
      when others => rdata := (others => '-');
    end case;

    if (apbi.psel and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(3 downto 2) is
      when "00" =>  v.pout := apbi.pwdata(15 downto 0); wrio := '1';
      when "01" =>  v.pdir := not apbi.pwdata(17 downto 0);
      when "10" =>  
	v.iconf(3).enable := apbi.pwdata(31); v.iconf(3).edge := apbi.pwdata(30);
	v.iconf(3).pol := apbi.pwdata(29); v.iconf(3).isel := apbi.pwdata(28 downto 24);
	v.iconf(2).enable := apbi.pwdata(23); v.iconf(2).edge := apbi.pwdata(22);
	v.iconf(2).pol := apbi.pwdata(21); v.iconf(2).isel := apbi.pwdata(20 downto 16);
	v.iconf(1).enable := apbi.pwdata(15); v.iconf(1).edge := apbi.pwdata(14);
	v.iconf(1).pol := apbi.pwdata(13); v.iconf(1).isel := apbi.pwdata(12 downto 8);
	v.iconf(0).enable := apbi.pwdata(7); v.iconf(0).edge := apbi.pwdata(6);
	v.iconf(0).pol := apbi.pwdata(5); v.iconf(0).isel := apbi.pwdata(4 downto 0);
      when others => null;
      end case;
    end if;

    -- override I/O port settings if UARTs are enabled
    if uart1o.txen = '1' then v.pout(15) := uart1o.txd; end if;
    if uart1o.flow = '1' then v.pout(13) := uart1o.rtsn; end if;
    if uart2o.txen = '1' then v.pout(11) := uart2o.txd; end if;
    if uart2o.flow = '1' then v.pout(9)  := uart2o.rtsn; end if;

-- interrupt generation

    for i in 0 to 3 loop	-- select and latch interrupt source
      v.irqlat(i) := genmux(r.iconf(i).isel, r.pin2);
  
      if r.iconf(i).enable = '1' then
      	if r.iconf(i).edge = '1' then
	  v.irqout(i) := (v.irqlat(i) xor r.irqlat(i)) and 
		       (v.irqlat(i) xor not r.iconf(i).pol);
        else
	  v.irqout(i) := (v.irqlat(i) xor not r.iconf(i).pol);
	end if;
      else
	v.irqout(i) := '0';
      end if;
    end loop;

-- reset operation

    if rst = '0' then 
      v.pdir := (others => '1');
      v.iconf(0).enable := '0'; v.iconf(1).enable := '0';
      v.iconf(2).enable := '0'; v.iconf(3).enable := '0';
    end if;

-- drive signals

    rin <= v; 		-- update registers
    apbo.prdata   <= rdata; 	-- drive data bus
    pioo.irq      <= r.irqout;
    pioo.piodir   <= r.pdir;
    pioo.io8lsb   <= r.pin2(7 downto 0);
    pioo.rxd(0)   <= r.pin2(14);
    pioo.ctsn(0)  <= r.pin2(12);
    pioo.rxd(1)   <= r.pin2(10);
    pioo.ctsn(1)  <= r.pin2(8);
    pioo.piol     <= apbi.pwdata(31 downto 16) & r.pout(15 downto 0);
    pioo.wrio      <= wrio;
    
  end process;

-- registers

  regs : process(clk,rst)
  begin 
    if rising_edge(clk) then r <= rin; end if; 
    if rst = '0' then r.pdir <= (others => '1'); end if;
  end process;


end;
