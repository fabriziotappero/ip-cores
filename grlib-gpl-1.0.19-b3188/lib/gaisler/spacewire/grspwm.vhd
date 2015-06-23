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
-- Entity: 	grspwm
-- File:	grspwm.vhd
-- Author:	Nils-Johan Wessman - Gaisler Research
-- Description:	Module to select between grspw and grspw2
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.spacewire.all;

entity grspwm is
  generic(
    tech         : integer range 0 to NTECH := DEFFABTECH;
    hindex       : integer range 0 to NAHBMST-1 := 0;
    pindex       : integer range 0 to NAPBSLV-1 := 0;
    paddr        : integer range 0 to 16#FFF#   := 0;
    pmask        : integer range 0 to 16#FFF#   := 16#FFF#;
    pirq         : integer range 0 to NAHBIRQ-1 := 0;
    sysfreq      : integer := 10000;                          -- spw1
    usegen       : integer range 0 to 1  := 1;                -- spw1
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
    netlist      : integer range 0 to 1 := 0;                 -- spw1
    ports        : integer range 1 to 2 := 1;
    dmachan      : integer range 1 to 4 := 1;                 -- spw2
    memtech      : integer range 0 to NTECH := DEFMEMTECH;
    spwcore      : integer range 1 to 2 := 2                  -- select spw core spw1/spw2
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
end entity;
  
architecture rtl of grspwm is
begin

  spw1 : if spwcore = 1 generate
    u0 : grspw
    generic map(tech, hindex, pindex, paddr, pmask, pirq, 
          sysfreq, usegen, nsync, rmap, rmapcrc, fifosize1, fifosize2, 
          rxclkbuftype, rxunaligned, rmapbufs, ft, scantest, techfifo, 
          netlist, ports, memtech) 
    port map(rst, clk, txclk, ahbmi, ahbmo, apbi, apbo, swni, swno);
  end generate;

  spw2 : if spwcore = 2 generate
    u0 : grspw2
  generic map(tech, hindex, pindex, paddr, pmask, pirq, 
          nsync, rmap, rmapcrc, fifosize1, fifosize2, rxclkbuftype,
          rxunaligned, rmapbufs, ft, scantest, techfifo, ports,
          dmachan, memtech) 
  port map(rst, clk, txclk, ahbmi, ahbmo, apbi, apbo, swni, swno);
  end generate;

end architecture;


