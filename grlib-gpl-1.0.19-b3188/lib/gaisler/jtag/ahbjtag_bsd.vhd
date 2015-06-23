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
-- Entity:      ahbjtag
-- File:        ahbjtag.vhd
-- Author:      Edvin Catovic, Jiri Gaisler - Gaisler Research
-- Description: JTAG communication link with AHB master interface
------------------------------------------------------------------------------  

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.misc.all;
use gaisler.libjtagcom.all;
use gaisler.jtag.all;

entity ahbjtag_bsd is
  generic (
    tech    : integer range 0 to NTECH := 0;
    hindex  : integer := 0;
    nsync : integer range 1 to 2 := 1;
    ainst   : integer range 0 to 255 := 2;
    dinst   : integer range 0 to 255 := 3);
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    ahbi        : in  ahb_mst_in_type;
    ahbo        : out ahb_mst_out_type;
    asel        : in  std_ulogic;
    dsel        : in  std_ulogic;
    tck         : in  std_ulogic;
    regi        : in  std_ulogic;
    shift       : in std_ulogic;
    rego        : out  std_ulogic        
    );
end;      

architecture struct of ahbjtag_bsd is

  
constant REVISION : integer := 0;

signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
signal ltapi : tap_in_type;
signal ltapo : tap_out_type;

begin
  
  ahbmst0 : ahbmst 
    generic map (hindex => hindex, venid => VENDOR_GAISLER, devid => GAISLER_AHBJTAG)
    port map (rst, clk, dmai, dmao, ahbi, ahbo);
  
  jtagcom0 : jtagcom generic map (isel => 1, nsync => nsync, ainst => ainst, dinst => dinst)
    port map (rst, clk, ltapo, ltapi, dmao, dmai);

  ltapo.asel  <= asel;
  ltapo.dsel  <= dsel;
  ltapo.tck   <= tck;
  ltapo.tdi   <= regi;
  ltapo.shift <= shift;
  ltapo.reset <= '0';
  ltapo.inst  <= (others => '0');
  rego <= ltapi.tdo;
  
-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbjtag AHB Debug JTAG rev " & tost(REVISION));
-- pragma translate_on

end;
