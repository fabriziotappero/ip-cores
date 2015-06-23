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
-- Entity:      pcilib
-- File:        pcilib.vhd
-- Author:      Alf Vaerneus - Gaisler Research
-- Description: Package with type declarations for PCI registers & constants
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;

package pcilib is

constant zero : std_logic_vector(31 downto 0) := (others => '0');
constant addzero : std_logic_vector(31 downto 0) := (others => '0');
subtype word4 is std_logic_vector(3 downto 0);
subtype word32 is std_logic_vector(31 downto 0);
-- Constants for PCI commands
constant pci_memory_read : word4 := "0110";
constant pci_memory_write : word4 := "0111";
constant pci_config_read : word4 := "1010";
constant pci_config_write : word4 := "1011";
constant INT_ACK      : word4 := "0000";
constant SPEC_CYCLE   : word4 := "0001";
constant IO_READ      : word4 := "0010";
constant IO_WRITE     : word4 := "0011";
constant MEM_READ     : word4 := "0110";
constant MEM_WRITE    : word4 := "0111";
constant CONF_READ    : word4 := "1010";
constant CONF_WRITE   : word4 := "1011";
constant MEM_R_MULT   : word4 := "1100";
constant DAC          : word4 := "1101";
constant MEM_R_LINE   : word4 := "1110";
constant MEM_W_INV    : word4 := "1111";
-- Constants for word size
constant W_SIZE_8_n     : word4 := "1110"; -- word size active low
constant W_SIZE_16_n    : word4 := "1100";
constant W_SIZE_32_n    : word4 := "0000";



type pci_config_command_type is record
--  ioen     : std_logic; -- I/O access enable
  men      : std_logic; -- Memory access enable
  msen     : std_logic; -- Master enable
--  spcen    : std_logic; -- Special cycle enable
  mwie     : std_logic; -- Memory write and invalidate enable
--  vgaps    : std_logic; -- VGA palette snooping enable
  per      : std_logic; -- Parity error response enable
--  wcc      : std_logic; -- Address stepping enable
--  serre    : std_logic; -- Enable SERR# driver
--  fbtbe    : std_logic; -- Fast back-to-back enable
end record;
type pci_config_status_type is record
--  c66mhz   : std_logic; -- 66MHz capability
--  udf      : std_logic; -- UDF supported
--  fbtbc    : std_logic; -- Fast back-to-back capability
  dped     : std_logic; -- Data parity error detected
--  dst      : std_logic_vector(1 downto 0); -- DEVSEL timing
  sta      : std_logic; -- Signaled target abort
  rta      : std_logic; -- Received target abort
  rma      : std_logic; -- Received master abort
--  sse      : std_logic; -- Signaled system error
  dpe      : std_logic; -- Detected parity error
end record;
--type pci_config_type is record
--  conf_en  : std_logic;
--  bus      : std_logic_vector(7 downto 0);
--  dev      : std_logic_vector(4 downto 0);
--  func     : std_logic_vector(2 downto 0);
--  reg      : std_logic_vector(5 downto 0);
--  data     : std_logic_vector(31 downto 0);
--end record;
type pci_sigs_type is record
  ad       : std_logic_vector(31 downto 0);
  cbe      : std_logic_vector(3 downto 0);
  frame    : std_logic; -- Master frame
  devsel   : std_logic; -- PCI device select
  trdy     : std_logic; -- Target ready
  irdy     : std_logic; -- Master ready
  stop     : std_logic; -- Target stop request
  par      : std_logic; -- PCI bus parity
  req      : std_logic; -- Master bus request
  perr     : std_logic; -- Parity Error
  oe_par   : std_logic;
  oe_ad    : std_logic;
  oe_ctrl  : std_logic;
  oe_cbe   : std_logic;
  oe_frame : std_logic;
  oe_irdy  : std_logic;
  oe_req   : std_logic;
  oe_perr  : std_logic;
end record;


end ;
