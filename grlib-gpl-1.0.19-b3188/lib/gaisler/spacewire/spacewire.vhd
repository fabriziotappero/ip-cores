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
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;

package spacewire is
  type grspw_in_type is record
    d           : std_logic_vector(1 downto 0);
    s           : std_logic_vector(1 downto 0);
    tickin      : std_ulogic;
    clkdiv10    : std_logic_vector(7 downto 0);
    rmapen      : std_ulogic;
    dcrstval    : std_logic_vector(9 downto 0);
    timerrstval : std_logic_vector(11 downto 0);
  end record;

  type grspw_out_type is record
    d           : std_logic_vector(1 downto 0);
    s           : std_logic_vector(1 downto 0);
    tickout     : std_ulogic;
    linkdis     : std_ulogic;
  end record;

  component grspw2 is
    generic(
      tech         : integer range 0 to NTECH     := inferred;
      hindex       : integer range 0 to NAHBMST-1 := 0;
      pindex       : integer range 0 to NAPBSLV-1 := 0;
      paddr        : integer range 0 to 16#FFF#   := 0;
      pmask        : integer range 0 to 16#FFF#   := 16#FFF#;
      pirq         : integer range 0 to NAHBIRQ-1 := 0;
      nsync        : integer range 1 to 2  := 1; 
      rmap         : integer range 0 to 1  := 0;
      rmapcrc      : integer range 0 to 1  := 0;
      fifosize1    : integer range 4 to 32 := 32;
      fifosize2    : integer range 16 to 64 := 64;
      rxclkbuftype : integer range 0 to 2 := 0;
      rxunaligned  : integer range 0 to 1 := 0;
      rmapbufs     : integer range 2 to 8 := 4;
      ft           : integer range 0 to 2 := 0;
      scantest     : integer range 0 to 1 := 0;
      techfifo     : integer range 0 to 1 := 1;
      ports        : integer range 1 to 2 := 1;
      dmachan      : integer range 1 to 4 := 1;
      memtech      : integer range 0 to NTECH := DEFMEMTECH
    );
    port(
      rst        : in  std_ulogic;
      clk        : in  std_ulogic;
      txclk      : in  std_ulogic;
      ahbmi      : in  ahb_mst_in_type;
      ahbmo      : out ahb_mst_out_type;
      apbi       : in  apb_slv_in_type;
      apbo       : out apb_slv_out_type;
      swni       : in  grspw_in_type;
      swno       : out grspw_out_type
    );
  end component;

  component grspw is
    generic(
      tech         : integer range 0 to NTECH := DEFFABTECH;
      hindex       : integer range 0 to NAHBMST-1 := 0;
      pindex       : integer range 0 to NAPBSLV-1 := 0;
      paddr        : integer range 0 to 16#FFF#   := 0;
      pmask        : integer range 0 to 16#FFF#   := 16#FFF#;
      pirq         : integer range 0 to NAHBIRQ-1 := 0;
      sysfreq      : integer := 10000;
      usegen       : integer range 0 to 1  := 1;
      nsync        : integer range 1 to 2  := 1; 
      rmap         : integer range 0 to 1  := 0;
      rmapcrc      : integer range 0 to 1  := 0;
      fifosize1    : integer range 4 to 32 := 32;
      fifosize2    : integer range 16 to 64 := 64;
      rxclkbuftype : integer range 0 to 2 := 0;
      rxunaligned  : integer range 0 to 1 := 0;
      rmapbufs     : integer range 2 to 8 := 4;
      ft           : integer range 0 to 2 := 0;
      scantest     : integer range 0 to 1 := 0;
      techfifo     : integer range 0 to 1 := 1;
      netlist      : integer range 0 to 1 := 0;
      ports        : integer range 1 to 2 := 1;
      memtech      : integer range 0 to NTECH := DEFMEMTECH
    );
    port(
      rst        : in  std_ulogic;
      clk        : in  std_ulogic;
      txclk      : in  std_ulogic;
      ahbmi      : in  ahb_mst_in_type;
      ahbmo      : out ahb_mst_out_type;
      apbi       : in  apb_slv_in_type;
      apbo       : out apb_slv_out_type;
      swni       : in  grspw_in_type;
      swno       : out grspw_out_type);
  end component;

  type grspw_in_type_vector is array (natural range <>) of grspw_in_type;
  type grspw_out_type_vector is array (natural range <>) of grspw_out_type;

  component grspwm is
    generic(
      tech         : integer range 0 to NTECH := DEFFABTECH;
      hindex       : integer range 0 to NAHBMST-1 := 0;
      pindex       : integer range 0 to NAPBSLV-1 := 0;
      paddr        : integer range 0 to 16#FFF#   := 0;
      pmask        : integer range 0 to 16#FFF#   := 16#FFF#;
      pirq         : integer range 0 to NAHBIRQ-1 := 0;
      sysfreq      : integer := 10000;
      usegen       : integer range 0 to 1  := 1;
      nsync        : integer range 1 to 2  := 1; 
      rmap         : integer range 0 to 1  := 0;
      rmapcrc      : integer range 0 to 1  := 0;
      fifosize1    : integer range 4 to 32 := 32;
      fifosize2    : integer range 16 to 64 := 64;
      rxclkbuftype : integer range 0 to 2 := 0;
      rxunaligned  : integer range 0 to 1 := 0;
      rmapbufs     : integer range 2 to 8 := 4;
      ft           : integer range 0 to 2 := 0;
      scantest     : integer range 0 to 1 := 0;
      techfifo     : integer range 0 to 1 := 1;
      netlist      : integer range 0 to 1 := 0;
      ports        : integer range 1 to 2 := 1;
      dmachan      : integer range 1 to 4 := 1;
      memtech      : integer range 0 to NTECH := DEFMEMTECH;
      spwcore      : integer range 1 to 2 := 2
    ); 
    port(
      rst        : in  std_ulogic;
      clk        : in  std_ulogic;
      txclk      : in  std_ulogic;
      ahbmi      : in  ahb_mst_in_type;
      ahbmo      : out ahb_mst_out_type;
      apbi       : in  apb_slv_in_type;
      apbo       : out apb_slv_out_type;
      swni       : in  grspw_in_type;
      swno       : out grspw_out_type
    );
  end component;

end package;
