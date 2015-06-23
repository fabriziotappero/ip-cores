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
-- Entity:      ahbslv_em
-- File:        ahbslv_em.vhd
-- Author:      Alf Vaerneus, Gaisler Research
-- Description: AMBA AHB Slave emulator for simulation purposes only
------------------------------------------------------------------------------

-- pragma translate_off
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.ambatest.all;
library std;
use std.textio.all;

entity ahbslv_em is
  generic(
    hindex      : integer := 0;
    abits       : integer := 10;
    waitcycles  : integer := 2;
    retries     : integer := 0;
    memaddr     : integer := 16#E00#;
    memmask     : integer := 16#F00#;
    ioaddr      : integer := 16#000#;
    timeoutc    : integer := 100;
    dbglevel    : integer := 1
  );
  port(
    rst       : in std_logic;
    clk       : in std_logic;
    -- AMBA signals
    ahbsi     : in  ahb_slv_in_type;
    ahbso     : out ahb_slv_out_type;
    -- TB signals
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type
  );
end;

architecture tb of ahbslv_em is

constant VERSION : integer := 1;
constant hconfig : ahb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_AHBSLV_EM, 0, VERSION, 0),
  4 => ahb_membar(memaddr, '0', '0', memmask),
  others => zero32);

constant T_O : integer := timeoutc;

type mem_type is array(0 to ((2**abits)-1)) of std_logic_vector(31 downto 0);

type state_type is(idle,w,write,read,retry1,retry2);
type reg_type is record
  state : state_type;
  ad : std_logic_vector(abits-1 downto 0);
  di : std_logic_vector(31 downto 0);
  waitc : integer;
  nretry : integer;
  write : std_logic;
end record;

signal r,rin : reg_type;
signal do : std_logic_vector(31 downto 0);

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
        count := conv_integer(tbi.address(abits-1 downto 0));
        for i in 0 to tbi.no_words-1 loop
          write(L,printhex(mem(count),32));
          writeline(writefile,L);
          count := count+4;
        end loop;
        file_close(writefile);
      end if;
    elsif r.ad(0) /= 'U' then
      do <= mem(conv_integer(to_x01(r.ad)));
      if r.write = '1' then mem(conv_integer(to_x01(r.ad))) := ahbsi.hwdata; end if;
    end if;
    tbo.ready <= tbi.start;
    wait for 1 ns;
  end process;

  comb : process(ahbsi, rst, r)
  variable v : reg_type;
  variable vahbso : ahb_slv_out_type;
  begin
    v := r; v.write := '0';
    v.di := ahbsi.hwdata;
    vahbso.hready := '1'; vahbso.hresp := HRESP_OKAY;
    vahbso.hrdata := do; vahbso.hsplit := (others => '0');
    vahbso.hcache := '0'; vahbso.hirq := (others => '0');
    vahbso.hconfig := hconfig;

    if ahbsi.hready = '1' then v.ad := ahbsi.haddr(abits-1 downto 0); end if;

    case r.state is
    when idle =>
      if (ahbsi.hsel(hindex) and ahbsi.hready and ahbsi.htrans(1)) = '1' then
        if r.waitc > 0 then v.state := w; v.waitc := r.waitc-1;
        elsif r.nretry > 0 then v.state := retry1;
        elsif ahbsi.hwrite = '1' then v.state := write; v.write := '1';
        else v.state := read; end if;
      end if;
    when w =>
      vahbso.hready := '0';
      if r.waitc = 0 then
        v.waitc := waitcycles;
        if r.nretry > 0 then v.state := retry1;
        elsif ahbsi.hwrite = '1' then v.state := write; v.write := '1';
        else v.state := read; end if;
      else v.waitc := r.waitc-1; end if;
    when write =>
      v.nretry := retries;
      if (ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '0' then v.state := idle;
      elsif r.waitc > 0 then v.state := w; v.waitc := r.waitc-1;
      elsif ahbsi.hwrite = '0' then v.state := read;
      else v.write := '1'; end if;
    when read =>
      v.nretry := retries;
      if (ahbsi.hsel(hindex) and ahbsi.htrans(1)) = '0' then v.state := idle;
      elsif r.waitc > 0 then v.state := w; v.waitc := r.waitc-1;
      elsif ahbsi.hwrite = '1' then v.state := write; end if;
    when retry1 =>
      vahbso.hready := '0'; v.nretry := r.nretry-1;
      vahbso.hresp := HRESP_RETRY;
      v.state := retry2;
    when retry2 =>
      vahbso.hresp := HRESP_RETRY;
      if (ahbsi.hsel(hindex) and ahbsi.hready and ahbsi.htrans(1)) = '1' then
        if r.waitc > 0 then v.state := w; v.waitc := r.waitc-1;
        elsif r.nretry > 0 then v.state := retry1;
        elsif ahbsi.hwrite = '1' then v.state := write; v.write := '1';
        else v.state := read; end if;
      end if;
    when others =>
    end case;

    vahbso.hindex := hindex;

    if rst = '0' then
      v.state := idle;
      v.waitc := waitcycles;
      v.nretry := retries;
      v.ad := (others => '0');
      v.di := (others => '0');
    end if;

    rin <= v;
    ahbso <= vahbso;

  end process;

  clockreg : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process;

  bootmsg : report_version
  generic map ("pcislv_em" & tost(hindex) &
  ": PCI Slave Emulator rev " & tost(VERSION) &
  " for simulation purpose only." &
  " NOT syntheziseable.");

end;
-- pragma translate_on
