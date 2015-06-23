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

entity ahbjtag is
  generic (
    tech    : integer range 0 to NTECH := 0;
    hindex  : integer := 0;
    nsync : integer range 1 to 2 := 1;
    idcode : integer range 0 to 255 := 9;    
    manf   : integer range 0 to 2047 := 804;
    part   : integer range 0 to 65535 := 0;
    ver    : integer range 0 to 15 := 0;
    ainst   : integer range 0 to 255 := 2;
    dinst   : integer range 0 to 255 := 3;
    scantest : integer := 0);
  port (
    rst         : in  std_ulogic;
    clk         : in  std_ulogic;
    tck         : in  std_ulogic;
    tms         : in  std_ulogic;
    tdi         : in  std_ulogic;
    tdo         : out std_ulogic;
    ahbi        : in  ahb_mst_in_type;
    ahbo        : out ahb_mst_out_type;
    tapo_tck    : out std_ulogic;
    tapo_tdi    : out std_ulogic;
    tapo_inst   : out std_logic_vector(7 downto 0);
    tapo_rst    : out std_ulogic;
    tapo_capt   : out std_ulogic;
    tapo_shft   : out std_ulogic;
    tapo_upd    : out std_ulogic;    
    tapi_tdo    : in std_ulogic;
    trst        : in std_ulogic := '1';
    tdoen       : out std_ulogic
    );
end;      

architecture struct of ahbjtag is

  
constant REVISION : integer := 0;
constant TAPSEL   : integer := has_tapsel(tech);

signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
signal ltapi : tap_in_type;
signal ltapo : tap_out_type;
signal taprst : std_ulogic;

begin

  taprst <= trst and rst;
  
  ahbmst0 : ahbmst 
    generic map (hindex => hindex, venid => VENDOR_GAISLER, devid => GAISLER_AHBJTAG)
    port map (rst, clk, dmai, dmao, ahbi, ahbo);

  tap0 : tap generic map (tech => tech, irlen => 6, idcode => idcode, 
	manf => manf, part => part, ver => ver, scantest => scantest)
    port map (taprst, tck, tms, tdi, tdo, ltapo.tck, ltapo.tdi, ltapo.inst, ltapo.reset, ltapo.capt,  
              ltapo.shift, ltapo.upd, ltapo.asel, ltapo.dsel, ltapi.en, ltapi.tdo, tapi_tdo,
	      ahbi.testen, ahbi.testrst, tdoen);
  
  jtagcom0 : jtagcom generic map (isel => TAPSEL, nsync => nsync, ainst => ainst, dinst => dinst)
    port map (rst, clk, ltapo, ltapi, dmao, dmai);

  tapo_tck <= ltapo.tck; tapo_tdi <= ltapo.tdi; tapo_inst <= ltapo.inst;  
  tapo_rst <= ltapo.reset; tapo_capt <= ltapo.capt; tapo_shft <= ltapo.shift; 
  tapo_upd <= ltapo.upd;  

  
-- pragma translate_off
    bootmsg : report_version 
    generic map ("ahbjtag AHB Debug JTAG rev " & tost(REVISION));
-- pragma translate_on

end;
