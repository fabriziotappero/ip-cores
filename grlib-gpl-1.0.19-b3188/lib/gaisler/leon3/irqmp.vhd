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
-- Entity: 	irqmp
-- File:	irqmp.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Multi-processor APB interrupt controller. Implements a
--		two-level interrupt controller for 15 interrupts.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.leon3.all;

entity irqmp is
  generic (
    pindex  : integer := 0;
    paddr   : integer := 0;
    pmask   : integer := 16#fff#;
    ncpu    : integer := 1;
    eirq    : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    irqi   : in  irq_out_vector(0 to ncpu-1);
    irqo   : out irq_in_vector(0 to ncpu-1)
  );
end;

architecture rtl of irqmp is

constant REVISION : integer := 3;

constant pconfig : apb_config_type := (
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_IRQMP, 0, REVISION, 0),
  1 => apb_iobar(paddr, pmask));

type mask_type is array (0 to ncpu-1) of std_logic_vector(15 downto 1);
type mask2_type is array (0 to ncpu-1) of std_logic_vector(15 downto 0);
type irl_type is array (0 to ncpu-1) of std_logic_vector(3 downto 0);
type irl2_type is array (0 to ncpu-1) of std_logic_vector(4 downto 0);

type reg_type is record
  imask		: mask_type;
  ilevel	: std_logic_vector(15 downto 1);
  ipend		: std_logic_vector(15 downto 1);
  iforce	: mask_type;
  ibroadcast	: std_logic_vector(15 downto 1);
  irl    	: irl_type;
  cpurst	: std_logic_vector(ncpu-1 downto 0);
end record;

type ereg_type is record
  imask		: mask2_type;
  ipend		: std_logic_vector(15 downto 0);
  irl    	: irl2_type;
end record;

function prioritize(b : std_logic_vector(15 downto 0)) return std_logic_vector is
variable a : std_logic_vector(15 downto 0);
variable irl : std_logic_vector(3 downto 0);
variable level : integer range 0 to 15;
begin
  irl := "0000"; level := 0; a := b;
  for i in 15 downto 0 loop
    level := i;
    if a(i) = '1' then exit; end if;
  end loop;
  irl := conv_std_logic_vector(level, 4);
  return(irl);
end;

signal r, rin : reg_type;
signal r2, r2in : ereg_type;

begin

  comb : process(rst, r, r2, apbi, irqi)
  variable v : reg_type;
  variable temp : mask_type;
  variable prdata : std_logic_vector(31 downto 0);
  variable tmpirq : std_logic_vector(15 downto 0);
  variable tmpvar : std_logic_vector(15 downto 1);
  variable cpurun	: std_logic_vector(ncpu-1 downto 0);
  variable v2 : ereg_type;
  variable irl2 : std_logic_vector(3 downto 0);
  variable ipend2 : std_logic_vector(ncpu-1 downto 0);
  variable temp2 : mask2_type;
  variable neirq : integer;
  
  begin

    v := r; v.cpurst := (others => '0');
    cpurun := (others => '0'); cpurun(0) := '1';
    tmpvar := (others => '0'); ipend2 := (others => '0');
    v2 := r2;
    
-- prioritize interrupts

    if eirq /= 0 then
      for i in 0 to ncpu-1 loop
        temp2(i) := r2.ipend and r2.imask(i);
        ipend2(i) := orv(temp2(i));
      end loop;
    end if;

    for i in 0 to ncpu-1 loop
      temp(i) := ((r.iforce(i) or r.ipend) and r.imask(i));
      if eirq /= 0 then temp(i)(eirq) := temp(i)(eirq) or ipend2(i); end if;
      v.irl(i) := prioritize((temp(i) and r.ilevel) & '0');
      if v.irl(i) = "0000" then
        if eirq /= 0 then temp(i)(eirq) := temp(i)(eirq) or ipend2(i); end if;
        v.irl(i) := prioritize((temp(i) and not r.ilevel) & '0');
      end if;
    end loop;

-- register read

    prdata := (others => '0');
    case apbi.paddr(7 downto 6) is
    when "00" =>
      case apbi.paddr(4 downto 2) is
      when "000" => prdata(15 downto 1) := r.ilevel;
      when "001" => 
	prdata(15 downto 1) := r.ipend;
        if eirq /= 0 then prdata(31 downto 16) := r2.ipend; end if;
      when "010" => prdata(15 downto 1) := r.iforce(0);
      when "011" =>
      when "100" | "101" =>
        prdata(31 downto 28) := conv_std_logic_vector(ncpu-1, 4);
        prdata(19 downto 16) := conv_std_logic_vector(eirq, 4);
        for i in 0 to ncpu -1 loop prdata(i) := irqi(i).pwd; end loop;
        if ncpu > 1 then
          prdata(27) := '1';
          case apbi.paddr(4 downto 2) is
            when "101" =>
              prdata := (others => '0');
              prdata(15 downto 1) := r.ibroadcast;
            when others =>  
          end case;
        end if;
      when others =>
      end case;
    when "01" =>
      for i in 0 to ncpu-1 loop
	if i = conv_integer( apbi.paddr(5 downto 2)) then
	  prdata(15 downto 1) := r.imask(i);
          if eirq /= 0 then prdata(31 downto 16) := r2.imask(i); end if;
	end if;
      end loop;
    when "10" =>
      for i in 0 to ncpu-1 loop
	if i = conv_integer( apbi.paddr(5 downto 2)) then
	    prdata(15 downto  1) := r.iforce(i);
	end if;
      end loop;
    when "11" =>
      if eirq /= 0 then
        for i in 0 to ncpu-1 loop
	  if i = conv_integer( apbi.paddr(5 downto 2)) then
	    prdata(4 downto 0) := r2.irl(i);
	  end if;
        end loop;
      end if;
    when others =>
    end case;

-- register write

    if (apbi.psel(pindex) and apbi.penable and apbi.pwrite) = '1' then
      case apbi.paddr(7 downto 6) is
      when "00" =>
        case apbi.paddr(4 downto 2) is
        when "000" => v.ilevel := apbi.pwdata(15 downto 1);
        when "001" => v.ipend  := apbi.pwdata(15 downto 1);
          if eirq /= 0 then v2.ipend := apbi.pwdata(31 downto 16); end if;
        when "010" => v.iforce(0) := apbi.pwdata(15 downto 1);
        when "011" => v.ipend  := r.ipend and not apbi.pwdata(15 downto 1);
          if eirq /= 0 then v2.ipend := r2.ipend and not apbi.pwdata(31 downto 16); end if;
        when "100" =>
          for i in 0 to ncpu -1 loop v.cpurst(i) := apbi.pwdata(i); end loop;
        when others =>
          if ncpu > 1 then
            case apbi.paddr(4 downto 2) is
              when "101" =>
                v.ibroadcast := apbi.pwdata(15 downto 1);
              when others =>  
            end case;
          end if;
        end case;
      when "01" =>
        for i in 0 to ncpu-1 loop
	  if i = conv_integer( apbi.paddr(5 downto 2)) then
	    v.imask(i) := apbi.pwdata(15 downto 1);
            if eirq /= 0 then v2.imask(i) := apbi.pwdata(31 downto 16); end if;
	  end if;
        end loop;
      when "10" =>
        for i in 0 to ncpu-1 loop
	  if i = conv_integer( apbi.paddr(5 downto 2)) then
	    v.iforce(i) := (r.iforce(i) or apbi.pwdata(15 downto 1)) and
			not apbi.pwdata(31 downto 17);
	  end if;
        end loop;
      when others =>
      end case;
    end if;

-- register new interrupts

    for i in 1 to 15 loop
      if i > NAHBIRQ-1 then
         exit;
      end if;
      if ncpu = 1 then
        v.ipend(i) := v.ipend(i) or apbi.pirq(i);
      else  
        v.ipend(i) := v.ipend(i) or (apbi.pirq(i) and not r.ibroadcast(i));
        for j in 0 to ncpu-1 loop
          tmpvar := v.iforce(j);
          tmpvar(i) := tmpvar(i) or (apbi.pirq(i) and r.ibroadcast(i));
          v.iforce(j) := tmpvar;
        end loop;
      end if;
    end loop;

    if eirq /= 0 then
      for i in 16 to 31 loop
        if i > NAHBIRQ-1 then exit; end if;
        v2.ipend(i-16) := v2.ipend(i-16) or apbi.pirq(i);
      end loop;
    end if;

-- interrupt acknowledge

    for i in 0 to ncpu-1 loop
      if irqi(i).intack = '1' then
        tmpirq := decode(irqi(i).irl);
        temp(i) := tmpirq(15 downto 1);
        v.iforce(i) := v.iforce(i) and not temp(i);
        v.ipend  := v.ipend and not ((not r.iforce(i)) and temp(i));
        if eirq /= 0 then
--          v2.irl(i) := '0' & irqi(i).irl;
          if eirq = conv_integer(irqi(i).irl) then
            v2.irl(i) := orv(temp2(i)) & prioritize(temp2(i));
            if v2.irl(i)(4) = '1' then
                v2.ipend(conv_integer(v2.irl(i)(3 downto 0))) := '0';
            end if;
 	  end if;
	end if;
      end if;
    end loop;

-- reset

    if rst = '0' then
      v.imask := (others => (others => '0'));
      v.iforce := (others => (others => '0'));
      v.ipend := (others => '0');
      if ncpu > 1 then
        v.ibroadcast := (others => '0');
      end if;
      v2.ipend := (others => '0');
      v2.imask := (others => (others => '0'));
      v2.irl := (others => (others => '0'));
    end if;

    apbo.prdata <= prdata;
    for i in 0 to ncpu-1 loop
      irqo(i).irl <= r.irl(i); irqo(i).rst <= r.cpurst(i);
      irqo(i).run <= cpurun(i);
      irqo(i).rstvec <= (others => '0');  -- Alternate reset vector
    end loop;

    rin <= v; r2in <= v2;
    
  end process;

  apbo.pirq <= (others => '0');
  apbo.pconfig <= pconfig;
  apbo.pindex <= pindex;

  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;
  
  dor2regs : if eirq /= 0 generate
    regs : process(clk)
    begin if rising_edge(clk) then r2 <= r2in; end if; end process;
  end generate;
  nor2regs : if eirq = 0 generate
--    r2 <= ((others => "0000000000000000"), "0000000000000000", (others => "00000"));
    r2.ipend <= (others => '0');
    driveregs: for i in 0 to (ncpu-1) generate
      r2.imask(i) <= (others => '0');
      r2.irl(i) <= (others => '0');
    end generate driveregs;  
  end generate;

-- pragma translate_off
    bootmsg : report_version
    generic map ("irqmp" &
	": Multi-processor Interrupt Controller rev " & tost(REVISION) &
	", #cpu " & tost(NCPU) & ", eirq " & tost(eirq));
-- pragma translate_on


end;
