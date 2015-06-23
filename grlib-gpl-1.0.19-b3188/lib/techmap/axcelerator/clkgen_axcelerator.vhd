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
-- Entity: 	clkgen_actel
-- File:	clkgen_actel.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Clock generator for Actel fpga
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library grlib;
use grlib.stdlib.all;
library axcelerator;
-- pragma translate_on
library techmap;
use techmap.gencomp.all;

entity clkgen_axcelerator is
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0);
  port (
    clkin   : in  std_ulogic;
    pciclkin: in  std_ulogic;
    clk     : out std_ulogic;			-- main clock
    clkn    : out std_ulogic;			-- inverted main clock
    sdclk   : out std_ulogic;			-- SDRAM clock
    pciclk  : out std_ulogic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end; 

architecture struct of clkgen_axcelerator is 
  component hclkbuf
  port( pad : in  std_logic; y   : out std_logic); end component; 
  component hclkbuf_pci
  port( pad : in  std_logic; y   : out std_logic); end component; 
signal clkint, pciclkint : std_ulogic;
begin

  c0 : if (PCIEN = 0) or (PCISYSCLK=0) generate
    u0 : hclkbuf port map (pad => clkin, y => clkint);
    clk <= clkint;
    clkn <= not clkint;
  end generate;

  c2 : if PCIEN/=0 generate
    c1 : if PCISYSCLK=1 generate
      clk <= pciclkint;
      clkn <= not pciclkint;
    end generate;
    u0 : hclkbuf_pci port map (pad => pciclkin, y => pciclkint);
    pciclk <= pciclkint;
  end generate;

  cgo.pcilock <= '1';
  cgo.clklock <= '1';
  sdclk <= '0';

-- pragma translate_off
  bootmsg : report_version 
  generic map (
    "clkgen_axcelerator" & ": using HCLKBUF as clock buffer");
-- pragma translate_on
end;

