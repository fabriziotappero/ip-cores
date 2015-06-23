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
-- Entity: 	dsu
-- File:	dsu.vhd
-- Author:	Jiri Gaisler, Edvin Catovic - Gaisler Research
-- Description:	Combined LEON3 debug support and AHB trace unit
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.leon3.all;
use gaisler.libiu.all;
library techmap;
use techmap.gencomp.all;

entity dsu3 is
  generic (
    hindex  : integer := 0;
    haddr : integer := 16#900#;
    hmask : integer := 16#f00#;
    ncpu    : integer := 1;
    tbits   : integer := 30; -- timer bits (instruction trace time tag)
    tech    : integer := DEFMEMTECH; 
    irq     : integer := 0; 
    kbytes  : integer := 0
  );
  port (
    rst    : in  std_ulogic;
    clk    : in  std_ulogic;
    ahbmi  : in  ahb_mst_in_type;
    ahbsi  : in  ahb_slv_in_type;
    ahbso  : out ahb_slv_out_type;
    dbgi   : in l3_debug_out_vector(0 to NCPU-1);
    dbgo   : out l3_debug_in_vector(0 to NCPU-1);
    dsui   : in dsu_in_type;
    dsuo   : out dsu_out_type
  );
end; 

architecture rtl of dsu3 is

  signal  gnd, vcc : std_ulogic;

begin

  gnd <= '0'; vcc <= '1';
  
  x0 : dsu3x generic map (hindex, haddr, hmask, ncpu, tbits, tech, irq, kbytes, 0)
    port map (rst, gnd, clk, ahbmi, ahbsi, ahbso, dbgi, dbgo, dsui, dsuo, vcc);  
  
end;
