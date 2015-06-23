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
-- Entity:      ahbmst_em
-- File:        ahbmst_em.vhd
-- Author:      Alf Vaerneus, Gaisler Research
-- Description: AMBA AHB Master emulator for simulation purposes only
------------------------------------------------------------------------------

-- pragma translate_off
library IEEE;
use IEEE.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use grlib.devices.all;
use gaisler.ambatest.all;
library std;
use std.textio.all;


entity ahbmst_em is
  generic(
    hindex    : integer := 0;
    timeoutc   : integer := 100;
    dbglevel  : integer := 2
  );
  port(
    rst       : in std_logic;
    clk       : in std_logic;
    -- AMBA signals
    ahbmi     : in  ahb_mst_in_type;
    ahbmo     : out ahb_mst_out_type;
    -- TB signals
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type

  );
end;

architecture tb of ahbmst_em is

constant VERSION : integer := 1;
constant hconfig : ahb_config_type := (
  0 => ahb_device_reg (VENDOR_GAISLER, GAISLER_AHBMST_EM, 0, VERSION, 0),
  others => zero32);

constant T_O : integer := timeoutc;

type state_type is(idle,active,done);
type reg_type is record
  state : state_type;
  current_word : integer;
  address : std_logic_vector(31 downto 0);
  data : std_logic_vector(31 downto 0);
  tocnt : integer;
  running : std_logic;
  longfile : std_logic;
  active : std_logic;
  grant : std_logic;
  ahbmo : ahb_mst_out_type;
end record;

signal r,rin : reg_type;
signal fileahbmo : ahb_mst_out_type;

begin

tb : process(tbi,ahbmi,r,rst)
variable v : reg_type;
variable status : status_type;
variable ready : std_logic;
variable ahbm : ahb_mst_out_type;
variable newaddress : std_logic_vector(31 downto 0);
variable inc : std_logic_vector(3 downto 0);
begin
  v := r; ahbm := AHB_IDLE; newaddress := r.address;
  v.tocnt := 0; ready := '0'; inc := (others => '0');
  ahbm.hconfig := hconfig;

  if tbi.start = '1' then
    if (r.running = '0' and r.state = idle) then
      v.address := tbi.address;
      status := OK;
      v.running := '1';
    end if;
    case tbi.command is
    when RD_SINGLE => ahbm := READ_SINGLE;
    when RD_INCR => ahbm := READ_INCR;
    when WR_SINGLE => ahbm := WRITE_SINGLE;
    when WR_INCR => ahbm := WRITE_INCR;
    when others =>
    end case;
    ahbm.hwdata := tbi.data;
  end if;

  inc(conv_integer(ahbm.hsize)) := '1';

  if ((r.active and not ahbmi.hresp(1)) = '1') then
    if ahbm.htrans = HTRANS_NONSEQ then
      ahbm.htrans := HTRANS_SEQ; newaddress := newaddress+inc;
    end if;
    if ahbmi.hready = '1' then
      v.address := r.address + inc; v.current_word := r.current_word+1;
    end if;
    if newaddress(9 downto 0) = "0000000000" then ahbm.htrans := HTRANS_NONSEQ; end if;
  end if;

  if v.current_word >= tbi.no_words then ahbm.htrans := HTRANS_IDLE; end if;

  ahbm.haddr := newaddress;

  if tbi.userfile then
    if ahbmi.hresp(1) = '0' then
      v.ahbmo := fileahbmo;
      v.ahbmo.hwrite := ahbm.hwrite;
      ahbm.haddr := fileahbmo.haddr;
      if ahbmi.hready = '1' then v.data := fileahbmo.hwdata; end if;
      ahbm.hwdata := r.data;
      if r.longfile = '1' then
        ahbm.htrans := fileahbmo.htrans;
        ahbm.hburst := fileahbmo.hburst;
        ahbm.hsize := fileahbmo.hsize;
        ahbm.hprot := fileahbmo.hprot;
      end if;
    else ahbm := r.ahbmo; end if;
  end if;

  if ahbmi.hresp = HRESP_ERROR then status := ERR;
  elsif r.tocnt = T_O then status := TIMEOUT; end if;

  case r.state is
  when idle =>
    if r.running = '1' then
      v.state := active;
    end if;
  when active =>
    v.tocnt := r.tocnt + 1;
    ahbm.hbusreq := r.running;
    if (r.grant and ahbmi.hready) = '1' then v.tocnt := 0; end if;
    if (v.current_word >= tbi.no_words and r.grant = '1' and tbi.userfile = false) then v.running := '0'; ahbm.hbusreq := '0'; end if;
    if (status /= OK or ((ahbmi.hready and not r.running) = '1' and ahbmi.hresp = HRESP_OKAY)) then
      v.state := done; ahbm.htrans := HTRANS_IDLE;
    end if;
  when done =>
    v.running := '0'; ready := '1';
    if tbi.start = '0' then
      v.state := idle; v.longfile := '0';
      v.current_word := 0;
    end if;
  when others =>
  end case;

  if ahbmi.hready = '1' then
    v.grant := ahbmi.hgrant(hindex);
    if ahbm.htrans /= HTRANS_IDLE then v.active := r.grant;
    else v.active := '0'; end if;
  end if;

  ahbm.hindex := hindex;

  if rst = '0' then
    v.address := (others => '0');
    v.state := idle;
    v.running := '0';
    v.current_word := 0;
    v.tocnt := 0;
    v.longfile := '0';
    v.ahbmo := AHB_IDLE;
  end if;

  tbo.ready <= ready;
  tbo.status <= status;
  rin <= v;
  ahbmo <= ahbm;

end process;

tbo.data <= ahbmi.hrdata when (ahbmi.hready and r.running) = '1';

cpur : process (clk)
file datafile_write,datafile_read :text;
variable L : line;
variable dataint : integer;
variable datahex : string(1 to 8);
variable count : integer;
begin

  if rising_edge (clk) then
    r <= rin;
    if tbi.usewfile then
      case r.state is
      when idle =>
        if r.running = '1' then
          file_open(datafile_write,external_name => tbi.wfile(18 downto trimlen(tbi.wfile)), open_kind => write_mode);
          count := 0;
        end if;
      when active =>
        if ((r.active and ahbmi.hready) = '1' and ahbmi.hresp = HRESP_OKAY) then
          if (tbi.userfile = false or count > 0) then
            write(L,printhex(ahbmi.hrdata,32));
            writeline(datafile_write,L);
          end if;
          count := count+1;
        end if;
        if rin.state = done then file_close(datafile_write); end if;
      when done =>
      when others =>
      end case;
    end if;
    if tbi.userfile then
      case r.state is
      when idle =>
        if r.running = '1' then
          fileahbmo <= AHB_IDLE; fileahbmo.hwrite <= rin.ahbmo.hwrite;
          file_open(datafile_read,external_name => tbi.rfile(18 downto trimlen(tbi.rfile)), open_kind => read_mode);
          readline(datafile_read,L); read(L,dataint);
          if dataint = 1 then r.longfile <= '1';
          else r.longfile <= '0'; end if;
        end if;
      when active =>
        if ((ahbmi.hgrant(hindex) and ahbmi.hready) = '1' and ahbmi.hresp = HRESP_OKAY) then
          if not endfile(datafile_read) then
            if r.longfile = '1' then
              readline(datafile_read,L); -- Dummy read for header
              readline(datafile_read,L); read(L,dataint);
              fileahbmo.htrans <= conv_std_logic_vector(dataint,2);
              readline(datafile_read,L); read(L,dataint);
              fileahbmo.hburst <= conv_std_logic_vector(dataint,3);
              readline(datafile_read,L); read(L,dataint);
              fileahbmo.hsize <= conv_std_logic_vector(dataint,3);
              readline(datafile_read,L); read(L,dataint);
              fileahbmo.hprot <= conv_std_logic_vector(dataint,4);
              readline(datafile_read,L); read(L,datahex);
              fileahbmo.haddr <= conv_std_logic_vector(datahex,32);
              readline(datafile_read,L); read(L,datahex);
              fileahbmo.hwdata <= conv_std_logic_vector(datahex,32);
            else
              readline(datafile_read,L); -- Dummy read for header
              readline(datafile_read,L); read(L,datahex);
              fileahbmo.haddr <= conv_std_logic_vector(datahex,32);
              readline(datafile_read,L); read(L,datahex);
              fileahbmo.hwdata <= conv_std_logic_vector(datahex,32);
            end if;
          else r.running <= '0'; end if;
        end if;
      when done =>
          if tbi.start = '0' then
            file_close(datafile_read);
          end if;
      when others =>
      end case;
    end if;
  end if;

end process;

bootmsg : report_version
generic map ("pcimst_em" & tost(hindex) &
": PCI Master Emulator rev " & tost(VERSION) &
" for simulation purpose only." &
" NOT syntheziseable.");

end;
-- pragma translate_on
