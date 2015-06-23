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
-- Entity:      pci
-- File:        pci.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: Package with component and type declarations for PCI testbench
--              modules
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.ambatest.all;

package pcitb is

type bar_type is array(0 to 5) of std_logic_vector(31 downto 0);
constant bar_init : bar_type := ((others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'));
type config_header_type is record
  devid       : std_logic_vector(15 downto 0);
  vendid      : std_logic_vector(15 downto 0);
  status      : std_logic_vector(15 downto 0);
  command     : std_logic_vector(15 downto 0);
  class_code  : std_logic_vector(23 downto 0);
  revid       : std_logic_vector(7 downto 0);
  bist        : std_logic_vector(7 downto 0);
  header_type : std_logic_vector(7 downto 0);
  lat_timer   : std_logic_vector(7 downto 0);
  cache_lsize : std_logic_vector(7 downto 0);
  bar         : bar_type;
  cis_p       : std_logic_vector(31 downto 0);
  subid       : std_logic_vector(15 downto 0);
  subvendid   : std_logic_vector(15 downto 0);
  exp_rom_ba  : std_logic_vector(31 downto 0);
  max_lat     : std_logic_vector(7 downto 0);
  min_gnt     : std_logic_vector(7 downto 0);
  int_pin     : std_logic_vector(7 downto 0);
  int_line    : std_logic_vector(7 downto 0);
end record;

constant config_init : config_header_type := (
          devid => conv_std_logic_vector(16#0BAD#,16),
          vendid => conv_std_logic_vector(16#AFFE#,16),
          status => (others => '0'),
          command => (others => '0'),
          class_code => conv_std_logic_vector(16#050000#,24),
          revid => conv_std_logic_vector(16#01#,8),
          bist => (others => '0'),
          header_type => (others => '0'),
          lat_timer => (others => '0'),
          cache_lsize => (others => '0'),
          bar => bar_init,
          cis_p => (others => '0'),
          subid => (others => '0'),
          subvendid => (others => '0'),
          exp_rom_ba => (others => '0'),
          max_lat => (others => '0'),
          min_gnt => (others => '0'),
          int_pin => (others => '0'),
          int_line => (others => '0'));


-- These types defines the TB PCI bus
type pci_ad_type is record
  ad      : std_logic_vector(31 downto 0);
  cbe     : std_logic_vector(3 downto 0);
  par     : std_logic;
end record;
constant ad_const : pci_ad_type := (
          ad => (others => 'Z'),
          cbe => (others => 'Z'),
          par => 'Z');

type pci_ifc_type is record
  frame   : std_logic;
  irdy    : std_logic;
  trdy    : std_logic;
  stop    : std_logic;
  devsel  : std_logic;
  idsel   : std_logic_vector(20 downto 0);
  lock    : std_logic;
end record;
constant ifc_const : pci_ifc_type := (
          frame => 'H',
          irdy => 'H',
          trdy => 'H',
          stop => 'H',
          lock => 'H',
          idsel => (others => 'L'),
          devsel => 'H');

type pci_err_type is record
  perr    : std_logic;
  serr    : std_logic;
end record;
constant err_const : pci_err_type := (
          perr => 'H',
          serr => 'H');

type pci_arb_type is record
  req     : std_logic_vector(20 downto 0);
  gnt     : std_logic_vector(20 downto 0);
end record;
constant arb_const : pci_arb_type := (
          req => (others => 'H'),
          gnt => (others => 'H'));

type pci_syst_type is record
  clk     : std_logic;
  rst     : std_logic;
end record;
constant syst_const : pci_syst_type := (
          clk => 'H',
          rst => 'H');

type pci_ext64_type is record
  ad      : std_logic_vector(63 downto 32);
  cbe     : std_logic_vector(7 downto 4);
  par64   : std_logic;
  req64   : std_logic;
  ack64   : std_logic;
end record;
constant ext64_const : pci_ext64_type := (
          ad => (others => 'Z'),
          cbe => (others => 'Z'),
          par64 => 'Z',
          req64 => 'Z',
          ack64 => 'Z');

type pci_int_type is record
  inta    : std_logic;
  intb    : std_logic;
  intc    : std_logic;
  intd    : std_logic;
end record;
constant int_const : pci_int_type := (
          inta => 'H',
          intb => 'H',
          intc => 'H',
          intd => 'H');

type pci_cache_type is record
  sbo     : std_logic;
  sdone   : std_logic;
end record;

constant cache_const : pci_cache_type := (
          sbo => 'U',
          sdone => 'U');

type pci_type is record
  ad      : pci_ad_type;
  ifc     : pci_ifc_type;
  err     : pci_err_type;
  arb     : pci_arb_type;
  syst    : pci_syst_type;
  ext64   : pci_ext64_type;
  int     : pci_int_type;
  cache   : pci_cache_type;
end record;

constant pci_idle : pci_type := ( ad_const, ifc_const, err_const, arb_const,
  syst_const, ext64_const, int_const, cache_const);

-- PCI emulators for TB

component pcitb_clkgen
  generic (
    mhz66 : boolean := false; -- PCI clock frequency. false = 33MHz, true = 66MHz
    rstclocks : integer := 20); -- How long (in clks) the rst signal is asserted
  port (
    rsttrig : in std_logic; -- Asynchronous reset trig, active high
    systclk : out pci_syst_type); -- clock and reset outputs
end component;

component pcitb_master -- A PCI master that is accessed through a Testbench vector
  generic (
    slot : integer := 0; -- Slot number for this unit
    tval : time := 7 ns; -- Output delay for signals that are driven by this unit
    dbglevel : integer := 1); -- Debug level. Higher value means more debug information
  port (
    pciin     : in pci_type;
    pciout    : out pci_type;
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type
    );
end component;

component pcitb_master_script
  generic (
    slot : integer := 0;     -- Slot number for this unit
    tval : time := 7 ns;     -- Output delay for signals that are driven by this unit
    dbglevel : integer := 2; -- Debug level. Higher value means more debug information
    maxburst : integer := 1024;
    filename : string := "pci.cmd"); 
  port (
    pciin     : in pci_type;
    pciout    : out pci_type
    );
end component;

component pcitb_target -- Represents a simple memory on the PCI bus
  generic (
    slot : integer := 0; -- Slot number for this unit
    abits : integer := 10; -- Memory size. Size is 2^abits 32-bit words
    bars : integer := 1; -- Number of bars for this target. Min 1, Max 6
    resptime : integer := 2; -- The initial response time in clks for this target
    latency : integer := 0; -- The latency in clks for every dataphase for a burst access
    rbuf : integer := 8; -- The maximum no of words this target can transfer in a continuous burst
    stopwd : boolean := true; -- Target disconnect type. true = disconnect WITH data, false = disconnect WITHOUT data
    tval : time := 7 ns; -- Output delay for signals that are driven by this unit
    conf : config_header_type := config_init; -- The reset condition of the configuration space of this target
    dbglevel : integer := 1); -- Debug level. Higher value means more debug information
  port (
    pciin     : in pci_type;
    pciout    : out pci_type;
    tbi       : in  tb_in_type;
    tbo       : out  tb_out_type
    );
end component;

component pcitb_stimgen
  generic (
    slots : integer := 5; -- The number of slots in the test system
    dbglevel : integer := 1); -- Debug level. Higher value means more debug information
  port (
    rsttrig   : out std_logic;
    tbi       : out tbi_array_type;
    tbo       : in  tbo_array_type
    );
end component;

component pcitb_arb
  generic (
    slots : integer := 5; -- The number of slots in the test system
    tval : time := 7 ns); -- Output delay for signals that are driven by this unit
  port (
    systclk : in pci_syst_type;
    ifcin : in pci_ifc_type;
    arbin : in pci_arb_type;
    arbout : out pci_arb_type);
end component;

component pcitb_monitor is
  generic (dbglevel : integer := 1);  -- Debug level. Higher value means more debug information
  port (pciin     : in pci_type);
end component;

end;

-- pragma translate_on
