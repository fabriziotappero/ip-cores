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
-- Entity: 	pci_tbfunct
-- File:	pci_tbfunct.vhd
-- Author:      Alf Vaerneus - Gaisler Research
-- Description:	Various PCI test functions
-----------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.ambatest.all;

package pci_tb is

procedure PCI_read_single(ctrl : inout ctrl_type; signal tbi : out tb_in_type; signal tbo : in tb_out_type; dbglevel : in integer);

procedure PCI_read_burst(ctrl : inout ctrl_type; signal tbi : out tb_in_type; signal tbo : in tb_out_type; dbglevel : in integer);

procedure PCI_write_single(ctrl : inout ctrl_type; signal tbi : out tb_in_type; signal tbo : in tb_out_type; dbglevel : in integer);

procedure PCI_write_burst(ctrl : inout ctrl_type; signal tbi : out tb_in_type; signal tbo : in tb_out_type; dbglevel : in integer);

procedure PCI_read_config(ctrl : inout ctrl_type; signal tbi : out tb_in_type; signal tbo : in tb_out_type; dbglevel : in integer);

procedure PCI_write_config(ctrl : inout ctrl_type; signal tbi : out tb_in_type; signal tbo : in tb_out_type; dbglevel : in integer);

end pci_tb;

package body pci_tb is

constant printlevel : integer := 2;

function string_inv(instring : string(18 downto 1)) return string is
  variable vstr : string(1 to 18);
  begin

    vstr(1 to 18) := instring(18 downto 1);

    return(vstr);
end string_inv;

procedure PCI_read_single(
  ctrl   : inout ctrl_type;
  signal tbi  : out tb_in_type;
  signal tbo  : in tb_out_type;
  dbglevel : in integer) is

  begin

  if tbo.ready = '1' then wait until tbo.ready = '0'; end if;
  tbi.address <= ctrl.address;
  tbi.command <= M_READ;
  tbi.no_words <= 1;
  tbi.userfile <= ctrl.userfile;
  tbi.rfile <= ctrl.rfile;
  if ctrl.userfile then
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Read from file %s",string_inv(ctrl.rfile));
    end if;
  else
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Read from address %x",ctrl.address);
    end if;
  end if;
  tbi.usewfile <= ctrl.usewfile;
  tbi.wfile <= ctrl.wfile;
  tbi.start <= '1';
  wait until tbo.ready = '1';
  ctrl.data := tbo.data;
  ctrl.status := tbo.status;
  if ctrl.status = ERR then
    if dbglevel >= printlevel then
      printf("PCIMST TB: #ERROR# Read access failed at %x",ctrl.address);
    end if;
  elsif ctrl.status = OK then
    if dbglevel >= printlevel then
      printf("PCIMST TB: Returned data: %x",ctrl.data);
    end if;
  end if;
  tbi.start <= '0';

end procedure;

procedure PCI_read_burst(
  ctrl   : inout ctrl_type;
  signal tbi  : out tb_in_type;
  signal tbo  : in tb_out_type;
  dbglevel : in integer) is

  variable i : integer;
  begin

  if tbo.ready = '1' then wait until tbo.ready = '0'; end if;
  tbi.address <= ctrl.address;
  tbi.command <= M_READ_MULT;
  tbi.no_words <= ctrl.no_words;
  tbi.userfile <= ctrl.userfile;
  tbi.rfile <= ctrl.rfile;
  if ctrl.userfile then
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Read burst from file %s",string_inv(ctrl.rfile));
    end if;
  else
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Read burst from address %x",ctrl.address);
    end if;
  end if;
  tbi.usewfile <= ctrl.usewfile;
  tbi.wfile <= ctrl.wfile;
  tbi.start <= '1';
  wait until tbo.ready = '1';
  ctrl.data := tbo.data;
  if ctrl.status = ERR then
    if dbglevel >= printlevel then
      printf("PCIMST TB: #ERROR# Read access failed at %x",ctrl.address);
    end if;
  elsif ctrl.status = OK then
    if dbglevel >= printlevel then
      printf("PCIMST TB: Returned data: %x",ctrl.data);
    end if;
  end if;
  ctrl.status := tbo.status;
  tbi.start <= '0';

end procedure;

procedure PCI_write_single(
  ctrl   : inout ctrl_type;
  signal tbi  : out tb_in_type;
  signal tbo  : in tb_out_type;
  dbglevel : in integer) is

  begin

  if tbo.ready = '1' then wait until tbo.ready = '0'; end if;
  tbi.address <= ctrl.address;
  tbi.data <= ctrl.data;
  tbi.command <= M_WRITE;
  tbi.no_words <= 1;
  tbi.userfile <= ctrl.userfile;
  tbi.rfile <= ctrl.rfile;
  if ctrl.userfile then
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Write from file %s",string_inv(ctrl.rfile));
    end if;
  else
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Write to address %x",ctrl.address);
    end if;
  end if;
  tbi.usewfile <= false; -- No log file for write accesses
  tbi.wfile <= ctrl.wfile;
  tbi.start <= '1';
  wait until tbo.ready = '1';
  ctrl.status := tbo.status;
  if ctrl.status = ERR then
    if dbglevel >= printlevel then
      printf("PCIMST TB: #ERROR# Write access failed at %x",ctrl.address);
    end if;
  elsif ctrl.status = OK then
    if dbglevel >= printlevel then
      printf("PCIMST TB: Write success!");
    end if;
  end if;
  tbi.start <= '0';

end procedure;

procedure PCI_write_burst(
  ctrl   : inout ctrl_type;
  signal tbi  : out tb_in_type;
  signal tbo  : in tb_out_type;
  dbglevel : in integer) is

  begin

  if tbo.ready = '1' then wait until tbo.ready = '0'; end if;
  tbi.address <= ctrl.address;
  tbi.data <= ctrl.data;
  tbi.command <= M_WRITE;
  tbi.no_words <= ctrl.no_words;
  tbi.userfile <= ctrl.userfile;
  tbi.rfile <= ctrl.rfile;
  if ctrl.userfile then
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Write from file %s",string_inv(ctrl.rfile));
    end if;
  else
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Write burst to address %x",ctrl.address);
    end if;
  end if;
  tbi.usewfile <= false; -- No log file for write accesses
  tbi.wfile <= ctrl.wfile;
  tbi.start <= '1';
  wait until tbo.ready = '1';
  ctrl.status := tbo.status;
  if ctrl.status = ERR then
    if dbglevel >= printlevel then
      printf("PCIMST TB: #ERROR# Write access failed at %x",ctrl.address);
    end if;
  elsif ctrl.status = OK then
    if dbglevel >= printlevel then
      printf("PCIMST TB: Write success!");
    end if;
  end if;
  tbi.start <= '0';

end procedure;

procedure PCI_read_config(
  ctrl   : inout ctrl_type;
  signal tbi  : out tb_in_type;
  signal tbo  : in tb_out_type;
  dbglevel : in integer) is

  begin

  if tbo.ready = '1' then wait until tbo.ready = '0'; end if;
  tbi.address <= ctrl.address;
  tbi.command <= C_READ;
  tbi.no_words <= 1;
  tbi.userfile <= ctrl.userfile;
  tbi.rfile <= ctrl.rfile;
  if ctrl.userfile then
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Config Read from file %s",string_inv(ctrl.rfile));
    end if;
  else
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Config Read from address %x",ctrl.address);
    end if;
  end if;
  tbi.usewfile <= ctrl.usewfile;
  tbi.wfile <= ctrl.wfile;
  tbi.start <= '1';
  wait until tbo.ready = '1';
  ctrl.data := tbo.data;
  ctrl.status := tbo.status;
  if ctrl.status = ERR then
    if dbglevel >= printlevel then
      printf("PCIMST TB: #ERROR# Read access failed at %x",ctrl.address);
    end if;
  elsif ctrl.status = OK then
    if dbglevel >= printlevel then
      printf("PCIMST TB: Returned data: %x",ctrl.data);
    end if;
  end if;
  tbi.start <= '0';

end procedure;

procedure PCI_write_config(
  ctrl   : inout ctrl_type;
  signal tbi  : out tb_in_type;
  signal tbo  : in tb_out_type;
  dbglevel : in integer) is

  begin

  if tbo.ready = '1' then wait until tbo.ready = '0'; end if;
  tbi.address <= ctrl.address;
  tbi.data <= ctrl.data;
  tbi.command <= C_WRITE;
  tbi.no_words <= 1;
  tbi.userfile <= ctrl.userfile;
  tbi.rfile <= ctrl.rfile;
  if ctrl.userfile then
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Config Write from file %s",string_inv(ctrl.rfile));
    end if;
  else
    if dbglevel >= printlevel then
      printf("PCIMST TB: PCI Config Write to address %x",ctrl.address);
    end if;
  end if;
  tbi.usewfile <= false; -- No log file for write accesses
  tbi.wfile <= ctrl.wfile;
  tbi.start <= '1';
  wait until tbo.ready = '1';
  ctrl.status := tbo.status;
  if ctrl.status = ERR then
    if dbglevel >= printlevel then
      printf("PCIMST TB: #ERROR# Config write access failed at %x",ctrl.address);
    end if;
  elsif ctrl.status = OK then
    if dbglevel >= printlevel then
      printf("PCIMST TB: Config write success!");
    end if;
  end if;
  tbi.start <= '0';

end procedure;

end package body;

-- pragma translate_on
