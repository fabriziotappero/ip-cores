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
-- Package: 	can
-- File:	can.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	CAN component declartions
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;

package can is

  component can_mod
  generic (memtech : integer := DEFMEMTECH; syncrst : integer := 0;
	   ft : integer := 0);
  port (
      reset  : in  std_logic;
      clk     : in  std_logic;
      cs      : in  std_logic;
      we      : in  std_logic;
      addr    : in  std_logic_vector(7 downto 0);
      data_in : in  std_logic_vector(7 downto 0);
      data_out: out std_logic_vector(7 downto 0);
      irq     : out std_logic;
      rxi     : in  std_logic;
      txo     : out std_logic;
      testen  : in  std_logic);
  end component;

  component can_oc
  generic (
    slvndx    : integer := 0;
    ioaddr    : integer := 16#000#;
    iomask    : integer := 16#FF0#;
    irq       : integer := 0;
    memtech   : integer := DEFMEMTECH;
    syncrst   : integer := 0;
    ft        : integer := 0);
  port (
      resetn  : in  std_logic;
      clk     : in  std_logic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      can_rxi : in  std_logic;
      can_txo : out std_logic
   );
  end component;

  component can_mc
  generic (
    slvndx    : integer := 0;
    ioaddr    : integer := 16#000#;
    iomask    : integer := 16#FF0#;
    irq       : integer := 0;
    memtech   : integer := DEFMEMTECH;
    ncores    : integer range 1 to 8 := 1;
    sepirq    : integer range 0 to 1 := 0;
    syncrst   : integer range 0 to 1 := 0;
    ft        : integer range 0 to 1 := 0);
  port (
    resetn  : in  std_logic;
    clk     : in  std_logic;
    ahbsi   : in  ahb_slv_in_type;
    ahbso   : out ahb_slv_out_type;
    can_rxi : in  std_logic_vector(0 to 7);
    can_txo : out std_logic_vector(0 to 7)
  );
  end component;

  component can_rd
  generic (
    slvndx    : integer := 0;
    ioaddr    : integer := 16#000#;
    iomask    : integer := 16#FF0#;
    irq       : integer := 0;
    memtech   : integer := DEFMEMTECH;
    syncrst   : integer := 0;
    dmap      : integer := 0);
  port (
      resetn  : in  std_logic;
      clk     : in  std_logic;
      ahbsi   : in  ahb_slv_in_type;
      ahbso   : out ahb_slv_out_type;
      can_rxi : in  std_logic_vector(1 downto 0);
      can_txo : out std_logic_vector(1 downto 0)
   );
  end component;

  component canmux
  port(
    sel      : in std_logic;
    canrx    : out std_logic;
    cantx    : in std_logic;
    canrxv   : in std_logic_vector(0 to 1);
    cantxv   : out std_logic_vector(0 to 1)
  );
  end component;

   -----------------------------------------------------------------------------
   -- interface type declarations for can controller
   -----------------------------------------------------------------------------
   type can_in_type is record
      rx:                  std_logic_vector(1 downto 0); -- receive lines
   end record;

   type can_out_type is record
      tx:                  std_logic_vector(1 downto 0); -- transmit lines
      en:                  std_logic_vector(1 downto 0); -- transmit enables
   end record;

   -----------------------------------------------------------------------------
   -- component declaration for grcan controller
   -----------------------------------------------------------------------------
   component grcan is
      generic (
         hindex:           integer := 0;
         pindex:           integer := 0;
         paddr:            integer := 0;
         pmask:            integer := 16#ffc#;
         pirq:             integer := 1;                 -- index of first irq
         singleirq:        integer := 0;                 -- single irq output
         txchannels:       integer range 1 to 16 := 1;   -- 1 to 16 channels
         rxchannels:       integer range 1 to 16 := 1;   -- 1 to 16 channels
         ptrwidth:         integer range 4 to 16 := 16); -- 16 to 64k messages
                                                         -- 2k to 8M bits
      port (
         rstn:       in    std_ulogic;
         clk:        in    std_ulogic;
         apbi:       in    apb_slv_in_type;
         apbo:       out   apb_slv_out_type;
         ahbi:       in    ahb_mst_in_type;
         ahbo:       out   ahb_mst_out_type;
         cani:       in    can_in_type;
         cano:       out   can_out_type);
   end component;

end;
