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
-- Entity:      pcitb_target
-- File:        pcitb_target.vhd
-- Author:      Alf Vaerneus, Gaisler Research
-- Description: PCI Target emulator.
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.pcitb.all;
use gaisler.pcilib.all;
use gaisler.ambatest.all;


library std;
use std.textio.all;


entity pcitb_target is
  generic (
    slot : integer := 0;
    abits : integer := 10;
    bars : integer := 1;
    resptime : integer := 2;
    latency : integer := 0;
    rbuf : integer := 8;
    stopwd : boolean := true;
    tval : time := 7 ns;
    conf : config_header_type := config_init;
    dbglevel : integer := 1);
  port (
    -- PCI signals
    pciin     : in pci_type;
    pciout    : out pci_type;
    -- TB signals
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type
       );
end pcitb_target;

architecture tb of pcitb_target is

constant T_O : integer := 9;
constant word : std_logic_vector(2 downto 0) := "100";

type mem_type is array(0 to ((2**abits)-1)) of std_logic_vector(31 downto 0);

type state_type is(idle,respwait,write,read,latw);
type reg_type is record
  state         : state_type;
  pci           : pci_type;
  pcien         : std_logic;
  aden          : std_logic;
  paren         : std_logic;
  erren         : std_logic;
  write         : std_logic;
  waitcycles    : integer;
  latcnt        : integer;
  curword       : integer;
  first         : boolean;
  di            : std_logic_vector(31 downto 0);
  ad            : std_logic_vector(31 downto 0);
  comm          : std_logic_vector(3 downto 0);
  config        : config_header_type;
  cbe           : std_logic_vector(3 downto 0); -- *** sub-word write
end record;

signal r,rin : reg_type;
signal do : std_logic_vector(31 downto 0);

procedure writeconf(ad : in std_logic_vector(5 downto 0);
                    data : in std_logic_vector(31 downto 0);
                    vconfig : out config_header_type) is
begin
  case conv_integer(ad) is
--  when 0 => vconfig.devid := data(31 downto 16); vconfig.vendid <= data(15 downto 0);
  when 1 => vconfig.status := data(31 downto 16); vconfig.command := data(15 downto 0);
  when 2 => vconfig.class_code := data(31 downto 8); vconfig.revid := data(7 downto 0);
  when 3 => vconfig.bist := data(31 downto 24); vconfig.header_type := data(23 downto 16);
            vconfig.lat_timer := data(15 downto 8); vconfig.cache_lsize := data(7 downto 0);
  when 4 => vconfig.bar(0) := data;
  when 5 => vconfig.bar(1) := data;
  when 6 => vconfig.bar(2) := data;
  when 7 => vconfig.bar(3) := data;
  when 8 => vconfig.bar(4) := data;
  when 9 => vconfig.bar(5) := data;
  when 10 => vconfig.cis_p := data;
  when 11 => vconfig.subid := data(31 downto 16); vconfig.subvendid := data(15 downto 0);
  when 12 => vconfig.exp_rom_ba := data;
  when 13 => vconfig.max_lat := data(31 downto 24); vconfig.min_gnt := data(23 downto 16);
             vconfig.int_pin := data(15 downto 8); vconfig.int_line := data(7 downto 0);
  when others =>
  end case;
end procedure;

procedure readconf(ad : in std_logic_vector(5 downto 0); data : out std_logic_vector(31 downto 0)) is
begin
  case conv_integer(ad) is
  when 0 => data(31 downto 16) := (conv_std_logic_vector(slot,4) & r.config.devid(11 downto 0));
            data(15 downto 0) := r.config.vendid;
  when 1 => data(31 downto 16) := r.config.status; data(15 downto 0) := r.config.command;
  when 2 => data(31 downto 8) := r.config.class_code; data(7 downto 0) := r.config.revid;
  when 3 => data(31 downto 24) := r.config.bist; data(23 downto 16) := r.config.header_type;
            data(15 downto 8) := r.config.lat_timer; data(7 downto 0) := r.config.cache_lsize;
  when 4 => data := r.config.bar(0)(31 downto abits) & zero32(abits-1 downto 0);
  when 5 => if bars > 1 then data := r.config.bar(1)(31 downto 9) & zero32(8 downto 1) & '1';
            else data := (others => '0'); end if;
  when 6 => if bars > 2 then data := r.config.bar(2)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 7 => if bars > 3 then data := r.config.bar(3)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 8 => if bars > 4 then data := r.config.bar(4)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 9 => if bars > 5 then data := r.config.bar(5)(31 downto abits) & zero32(abits-1 downto 0);
            else data := (others => '0'); end if;
  when 10 => data := r.config.cis_p;
  when 11 => data(31 downto 16) := r.config.subid; data(15 downto 0) := r.config.subvendid;
  when 12 => data := r.config.exp_rom_ba;
  when 13 => data(31 downto 24) := r.config.max_lat; data(23 downto 16) := r.config.min_gnt;
             data(15 downto 8) := r.config.int_pin; data(7 downto 0) := r.config.int_line;
  when others =>
  end case;
end procedure;

function pci_hit(ad : std_logic_vector(31 downto 0);
                 c : std_logic_vector(3 downto 0);
                 idsel : std_logic;
                 con : config_header_type) return boolean is
variable hit : boolean;
begin
  hit := false;

  if ((c = CONF_READ or c = CONF_WRITE)
  and idsel = '1' and ad(1 downto 0) = "00")
  then hit := true;
  else
    for i in 0 to bars loop
      if i = 1 then
        if ((c = IO_READ or c = IO_WRITE)
        and ad(31 downto abits) = con.bar(i)(31 downto abits))
        then hit := true; end if;
      else
        if ((c = MEM_READ or c = MEM_WRITE or c = MEM_R_MULT or c = MEM_R_LINE or c = MEM_W_INV)
        and ad(31 downto abits) = con.bar(i)(31 downto abits))
        then hit := true; end if;
      end if;
    end loop;
  end if;
  return(hit);
end function;



begin

  cont : process
  file readfile,writefile : text;
  variable first : boolean := true;
  variable mem : mem_type;
  variable L : line;
  variable datahex : string(1 to 8);
  variable count : integer;
  begin
    if first then
      for i in 0 to ((2**abits)-1) loop
        mem(i) := (others => '0');
      end loop;
      first := false;
    elsif tbi.start = '1' then
      if tbi.usewfile then
        file_open(writefile, external_name => tbi.wfile(18 downto trimlen(tbi.wfile)), open_kind => write_mode);
        count := conv_integer(tbi.address);
        for i in 0 to tbi.no_words-1 loop
          write(L,printhex(mem(count),32));
          writeline(writefile,L);
          count := count+4;
        end loop;
        file_close(writefile);
      end if;
    elsif r.ad(0) /= 'U' then
      do <= mem(conv_integer(to_x01(r.ad)));
      --if r.write = '1' then mem(conv_integer(to_x01(r.ad))) := r.di; end if; -- *** sub-word write
      if r.write = '1' then 
        case r.cbe is
        when "1110" =>
          mem(conv_integer(to_x01(r.ad)))(7 downto 0) := r.di(7 downto 0); 
        when "1101" =>
          mem(conv_integer(to_x01(r.ad)))(15 downto 8) := r.di(15 downto 8); 
        when "1011" =>
          mem(conv_integer(to_x01(r.ad)))(23 downto 16) := r.di(23 downto 16); 
        when "0111" =>
          mem(conv_integer(to_x01(r.ad)))(31 downto 24) := r.di(31 downto 24); 
        when "1100" =>
          mem(conv_integer(to_x01(r.ad)))(15 downto 0) := r.di(15 downto 0); 
        when "0011" =>
          mem(conv_integer(to_x01(r.ad)))(31 downto 16) := r.di(31 downto 16); 
        when others =>
          mem(conv_integer(to_x01(r.ad))) := r.di;
        end case;
      end if;
    end if;
    tbo.ready <= tbi.start;
    wait for 1 ns;
  end process;

  comb : process(pciin, do)
  variable v : reg_type;
  begin
    v := r; v.write := '0';
    v.pci.ad.par := xorv(r.pci.ad.ad & pciin.ad.cbe);
    v.paren := r.aden; v.erren := r.paren; 

    case r.state is
    when idle =>
      if (r.pci.ifc.trdy and r.pci.ifc.stop and r.pci.ifc.devsel) = '1' then v.pcien := '1'; end if;
      v.aden := '1'; v.waitcycles := 1; v.latcnt := latency; v.first := true;
      v.pci.ifc.trdy := '1'; v.pci.ifc.stop := '1'; v.curword := 0;
      v.pci.ifc.devsel := '1'; v.pci.err.perr := '1';
      if pciin.ifc.frame = '0' then
        v.comm := pciin.ad.cbe;
        if pci_hit(pciin.ad.ad,pciin.ad.cbe,pciin.ifc.idsel(slot),v.config) then
          v.ad := zero32(31 downto abits) & pciin.ad.ad(abits-1 downto 0);
          if r.waitcycles = resptime then
            v.pci.ifc.devsel := '0'; v.pcien := '0';
            if pciin.ad.cbe(0) = '1' then v.state := write; v.pci.ifc.trdy := '0';
            else v.state := read; v.aden := '0'; end if;
          else v.state := respwait; v.waitcycles := r.waitcycles+1; end if;
        end if;
      end if;
    when respwait => -- Initial response time
      if r.waitcycles = resptime then
        v.pci.ifc.devsel := '0'; v.pcien := '0';
        if r.comm(0) = '1' then v.state := write; v.pci.ifc.trdy := '0';
        else v.state := read; v.aden := '0'; end if;
      else v.waitcycles := r.waitcycles+1; end if;
    when write => -- Write access
      if pciin.ifc.irdy = '0' then
        v.curword := r.curword+1;
        if r.comm = CONF_WRITE then writeconf(r.ad(7 downto 2),pciin.ad.ad,v.config);
        --else v.di := pciin.ad.ad; v.write := '1'; end if; -- *** sub-word write
        else v.di := pciin.ad.ad; v.write := '1'; v.cbe := pciin.ad.cbe; end if;
      end if;
      if r.write = '1' then v.ad := r.ad + "100"; end if;
      if pciin.ifc.frame = '1' then
        v.state := idle;
        v.pci.ifc.trdy := '1'; v.pci.ifc.devsel := '1';
      elsif (r.latcnt > 0 and pciin.ifc.irdy = '0') then v.state := latw; v.pci.ifc.trdy := '1'; v.latcnt := r.latcnt-1;
      end if;
    when read => -- Read access
      v.pci.ifc.trdy := '0';
      if (pciin.ifc.irdy = '0' or r.first = true) then
        v.ad := r.ad + "100"; v.first := false;
        if r.comm = CONF_READ then readconf(r.ad(7 downto 2),v.pci.ad.ad);
        else v.pci.ad.ad := do; end if;
      end if;
      if (pciin.ifc.trdy or pciin.ifc.irdy) = '0' then v.curword := r.curword+1; end if;
      if (pciin.ifc.frame and not (pciin.ifc.trdy and pciin.ifc.stop)) = '1' then
        v.state := idle; v.aden := '1';
        v.pci.ifc.trdy := '1'; v.pci.ifc.devsel := '1';
      elsif (r.latcnt > 0 and (pciin.ifc.trdy or pciin.ifc.irdy) = '0' and pciin.ifc.stop = '1') then
        v.state := latw; v.latcnt := r.latcnt-1; v.pci.ifc.trdy := '1';
      end if;
    when latw => -- Latency between data phases
      v.pci.ifc.trdy := '1';
      if r.write = '1' then v.ad := r.ad + "100"; end if;
      if (r.latcnt <= 1 and r.comm(0) = '0') then
        v.latcnt := latency;
        v.state := read; v.aden := '0';
      elsif r.latcnt = 0 then
        v.latcnt := latency;
        v.state := write; v.pci.ifc.trdy := '0';
      else v.latcnt := r.latcnt-1; end if;
    when others =>
    end case;

    -- Disconnect type
    if ((v.curword+1) >= rbuf) then
      if pciin.ifc.frame = '1' then
        v.pci.ifc.stop := '1';
      elsif stopwd then
        if r.pci.ifc.stop = '1' then
          v.pci.ifc.stop := v.pci.ifc.trdy;
        else
          if pciin.ifc.irdy = '0' then v.pci.ifc.trdy := '1'; end if;
          v.pci.ifc.stop := '0';
        end if;
      else
        v.pci.ifc.stop := '0';
        v.pci.ifc.trdy := '1';
      end if;
    end if;

    if pciin.syst.rst = '0' then
      v.state := idle;
      v.config := conf;
      v.waitcycles := 1;
      v.latcnt := latency;
      v.ad := (others => '0');
      v.di := (others => '0');
    end if;

    rin <= v;

  end process;

  clockreg : process(pciin.syst)
  begin
    if rising_edge(pciin.syst.clk) then
      r <= rin;
    end if;
  end process;

  pciout.ad.ad <= r.pci.ad.ad after tval when r.aden = '0' else (others => 'Z') after tval;
  pciout.ad.par <= r.pci.ad.par after tval when (r.paren = '0' and (r.pci.ad.par = '1' or r.pci.ad.par = '0')) else 'Z' after tval;
  pciout.ifc.trdy <= r.pci.ifc.trdy after tval when r.pcien = '0' else 'Z' after tval;
  pciout.ifc.stop <= r.pci.ifc.stop after tval when r.pcien = '0' else 'Z' after tval;
  pciout.ifc.devsel <= r.pci.ifc.devsel after tval when r.pcien = '0' else 'Z' after tval;
  pciout.err.perr <= r.pci.err.perr after tval when r.erren = '0' else 'Z' after tval;

end;

-- pragma translate_on
