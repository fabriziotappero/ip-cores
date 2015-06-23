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
-- Entity:      pcitb_master
-- File:        pcitb_master.vhd
-- Author:      Alf Vaerneus, Gaisler Research
-- Description: PCI Master emulator. Can act as a system host
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;

library std;
use std.textio.all;

library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.pcitb.all;
use gaisler.pcilib.all;
use gaisler.ambatest.all;

library grlib;
use grlib.stdlib.xorv;


entity pcitb_master is
  generic (
    slot : integer := 0;
    tval : time := 7 ns;
    dbglevel : integer := 1);
  port (
    -- PCI signals
    pciin     : in pci_type;
    pciout    : out pci_type;
    -- TB signals
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type
       );
end pcitb_master;

architecture tb of pcitb_master is

constant T_O : integer := 9;

type filedata_type is record
  address : std_logic_vector(31 downto 0);
  data : std_logic_vector(31 downto 0);
  command : std_logic_vector(3 downto 0);
  last : std_logic;
  openrfile : std_logic;
  openwfile : std_logic;
end record;

type state_type is(idle,active,done);
type reg_type is record
  state         : state_type;
  pcien         : std_logic_vector(3 downto 0);
  paren         : std_logic;
  read          : std_logic;
  burst         : std_logic;
  grant         : std_logic;
  address       : std_logic_vector(31 downto 0);
  data          : std_logic_vector(31 downto 0);
  current_word  : natural;
  tocnt         : integer;
  running       : std_logic;
  pci           : pci_type;
  status        : status_type;
end record;

signal r,rin : reg_type;
signal filedata : filedata_type;

begin

  comb : process(pciin)
  variable vpci : pci_type;
  variable v : reg_type;
  variable i,count,dataintrans : integer;
  variable status : status_type;
  variable ready,stop : std_logic;
  variable comm : std_logic_vector(3 downto 0);
  begin
    v := r; count := count+1; v.tocnt := 0; ready := '0'; stop := '0';
    v.pcien(0) := '1'; v.pcien(3 downto 1) := r.pcien(2 downto 0);

    if tbi.start = '1' then
      if (r.running = '0' and r.state = idle) then
        v.address := tbi.address(31 downto 2) & "00";
        status := OK;
        v.running := '1';
      end if;
      case tbi.command is
      when M_READ => v.burst := '0'; v.read := '1'; comm := MEM_READ;
      when M_READ_MULT => v.burst := '1'; v.read := '1'; comm := MEM_R_MULT;
      when M_READ_LINE => v.burst := '1'; v.read := '1'; comm := MEM_R_LINE;
      when M_WRITE =>
        if tbi.no_words = 1 then v.burst := '0'; else v.burst := '1'; end if;
        v.read := '0'; comm := MEM_WRITE;
      when M_WRITE_INV => v.burst := '1'; v.read := '0'; comm := MEM_W_INV;
      when C_READ => v.burst := '0'; v.read := '1'; comm := CONF_READ;
      when C_WRITE => v.burst := '0'; v.read := '0'; comm := CONF_WRITE;
      when others =>
      end case;
      if not tbi.userfile then v.pci.ad.ad := tbi.data; end if;
    end if;

    if tbi.userfile then
      v.address := (filedata.address(31 downto 2) + conv_std_logic_vector(v.current_word,30)) & "00";
      comm := filedata.command;
      v.pci.ad.ad := filedata.data;
      v.burst := not filedata.last;
      stop := filedata.last;
    end if;

    v.pci.ad.par := xorv(r.pci.ad.ad & r.pci.ad.cbe);
    v.paren := r.read;

    if (pciin.ifc.devsel and not pciin.ifc.stop) = '1' and r.running = '1' then
      status := ERR;
    elsif r.tocnt = T_O then
      status := TIMEOUT;
    else
        status := OK;
    end if;

    case r.state is
    when idle =>
      v.pci.arb.req(slot) := not (r.running and r.pcien(1));
      v.pci.ifc.irdy := '1'; dataintrans := 0;
      if r.grant = '1' then
        v.state := active; v.pci.ifc.frame := '0'; v.read := '0';
        v.pcien(0) := '0'; v.pci.ad.ad := v.address; v.pci.ad.cbe := comm;
      end if;
    when active =>
      v.tocnt := r.tocnt + 1; v.pcien(0) := '0';
      v.pci.ifc.irdy := '0';
      v.pci.ad.cbe := (others => '0');
      v.pci.arb.req(slot) := not (r.burst and not pciin.ifc.frame);
      if (pciin.ifc.irdy or (pciin.ifc.trdy and pciin.ifc.stop)) = '0' then
        if pciin.ifc.trdy = '0' then
          v.current_word := r.current_word+1; v.data := pciin.ad.ad;
          dataintrans := dataintrans+1;
        end if;
      end if;
      if pciin.ifc.devsel = '0' then v.tocnt := 0; end if;
      if ((v.current_word+conv_integer(r.burst)) >= tbi.no_words and tbi.userfile = false) then
        stop := '1';
        if pciin.ifc.frame = '1' then
          if pciin.ifc.trdy = '0' then
            v.running := '0'; v.pci.ifc.irdy := '1'; v.pcien(0) := '1';
          elsif (pciin.ifc.trdy and not pciin.ifc.stop) = '1' then
            v.state := idle; v.pci.ifc.irdy := '1'; v.pcien(0) := '1';
            if dataintrans > 0 then
              v.address := (tbi.address(31 downto 2) + conv_std_logic_vector(v.current_word,30)) & "00";
            end if;
          end if;
        end if;
      elsif pciin.ifc.stop = '0' then
        v.pcien(0) := pciin.ifc.frame; stop := '1'; v.state := idle; v.pci.ifc.irdy := pciin.ifc.frame;
        if not tbi.userfile then v.address := (tbi.address(31 downto 2) + conv_std_logic_vector(v.current_word,30)) & "00"; end if;
      end if;
--      if (status /= OK or (r.running = '0' and ((pciin.ifc.irdy or not (pciin.ifc.trdy and pciin.ifc.stop)) = '1' or tbi.userfile = true))) then
      if (r.status /= OK or ((pciin.ifc.frame and not pciin.ifc.irdy and not pciin.ifc.trdy) = '1')) then
        v.state := done; v.pci.ifc.irdy := '1'; v.pcien(0) := '1'; v.pci.arb.req(slot) := '1';
      end if;
      v.pci.ifc.frame := not (r.burst and not stop);
    when done =>
      v.running := '0'; ready := '1';
      if tbi.start = '0' then
        v.state := idle;
        v.current_word := 0;
      end if;
    when others =>
    end case;

    v.grant := to_x01(pciin.ifc.frame) and to_x01(pciin.ifc.irdy) and not r.pci.arb.req(slot) and not to_x01(pciin.arb.gnt(slot));

    if pciin.syst.rst = '0' then
      v.pcien := (others => '1');
      v.state := idle;
      v.read := '0';
      v.burst := '0';
      v.grant := '0';
      v.address := (others => '0');
      v.data := (others => '0');
      v.current_word := 0;
      v.running := '0';
      v.pci := pci_idle;
    end if;

    tbo.ready <= ready;
    v.status := status;
    tbo.status <= status;
    tbo.data <= r.data;
    rin <= v;
  end process;

  clockreg : process(pciin.syst)
  file readfile,writefile : text;
  variable L : line;
  variable datahex : string(1 to 8);
  variable count : integer;
  begin
    if pciin.syst.rst = '0' then
      filedata.address <= (others => '0');
      filedata.data <= (others => '0');
      filedata.command <= (others => '0');
      filedata.last <= '0';
      filedata.openrfile <= '0';
      filedata.openwfile <= '0';
    elsif rising_edge(pciin.syst.clk) then
--      r <= rin;
      if tbi.usewfile then
        case r.state is
        when idle =>
          if (tbi.start and not filedata.openwfile) = '1' then
            file_open(writefile, external_name => tbi.wfile(18 downto trimlen(tbi.wfile)), open_kind => write_mode);
            filedata.openwfile <= '1';
            count := 0;
          end if;
        when active =>
          if (pciin.ifc.trdy or pciin.ifc.irdy) = '0' then
            if (tbi.userfile = false or count > 0) then
              write(L,printhex(pciin.ad.ad,32));
              writeline(writefile,L);
            end if;
            count := count+1;
          end if;
          if rin.state = done then
            file_close(writefile);
            filedata.openwfile <= '0';
          end if;
        when others =>
        end case;
      end if;
      if tbi.userfile then
        case r.state is
        when idle =>
          if (tbi.start and not filedata.openrfile) = '1' then
            filedata.last <= '0'; filedata.openrfile <= '1';
            file_open(readfile,external_name => tbi.rfile(18 downto trimlen(tbi.rfile)), open_kind => read_mode);
            readline(readfile,L); -- Dummy read for header
            readline(readfile,L); read(L,datahex);
            filedata.address <= conv_std_logic_vector(datahex,32);
            readline(readfile,L); read(L,datahex);
            filedata.command <= conv_std_logic_vector(datahex,4);
            readline(readfile,L); -- Dummy read for header
            readline(readfile,L); read(L,datahex);
            filedata.data <= conv_std_logic_vector(datahex,32);
          end if;
        when active =>
          if (pciin.ifc.trdy or pciin.ifc.irdy) = '0' then
            if not endfile(readfile) then
              readline(readfile,L); read(L,datahex);
              filedata.data <= conv_std_logic_vector(datahex,32);
              r.pci.ad.ad <= conv_std_logic_vector(datahex,32);
            end if;
            if endfile(readfile) then filedata.last <= '1'; r.pci.ifc.frame <= '1'; r.running <= '0'; end if;
          end if;
        when done =>
            if tbi.start = '0' then
              file_close(readfile); filedata.openrfile <= '0';
            end if;
        when others =>
        end case;
      end if;
    end if;
    if rising_edge(pciin.syst.clk) then
      r <= rin;
    end if;
  end process;

  pciout.ad.ad <= r.pci.ad.ad after tval when (r.read or r.pcien(0)) = '0' else (others => 'Z') after tval;
  pciout.ad.cbe <= r.pci.ad.cbe after tval when r.pcien(0) = '0' else (others => 'Z') after tval;
  pciout.ad.par <= r.pci.ad.par after tval when (r.paren or r.pcien(1)) = '0' else 'Z' after tval;
  pciout.ifc.frame <= r.pci.ifc.frame after tval when r.pcien(0) = '0' else 'Z' after tval;
  pciout.ifc.irdy <= r.pci.ifc.irdy after tval when r.pcien(1) = '0' else 'Z' after tval;
  pciout.err.perr <= r.pci.err.perr after tval when r.pcien(2) = '0' else 'Z' after tval;
  pciout.err.serr <= r.pci.err.serr after tval when r.pcien(2) = '0' else 'Z' after tval;
  pciout.arb.req(slot) <= r.pci.arb.req(slot) after tval;

end;

-- pragma translate_on
