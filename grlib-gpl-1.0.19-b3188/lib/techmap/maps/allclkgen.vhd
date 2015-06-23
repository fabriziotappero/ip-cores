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
-- Entity: 	libclk
-- File:	libclk.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Clock generator interface package
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

package allclkgen is

component clkgen_virtex 
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    noclkfb  : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0);
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end component; 

component clkgen_virtex2 
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    noclkfb  : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0;
    clksel   : integer := 0);             -- enable clock select         
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type;
    clk1xu  : out std_ulogic;			-- unscaled clock
    clk2xu  : out std_ulogic);
end component; 

component clkgen_spartan3 
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    noclkfb  : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0;
    clksel   : integer := 0);             -- enable clock select         
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type;
    clk1xu  : out std_ulogic;			-- unscaled clock
    clk2xu  : out std_ulogic);
end component; 

component clkgen_virtex5 
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    noclkfb  : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0;
    clksel   : integer := 0);             -- enable clock select         
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type;
    clk1xu  : out std_ulogic;			-- unscaled clock
    clk2xu  : out std_ulogic);
end component; 

component clkgen_axcelerator 
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0);
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end component; 

component clkgen_altera_mf 
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0);      
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock    
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end component; 

component clkgen_cycloneiii 
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0);      
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock    
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end component; 

component clkgen_stratixiii
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    sdramen  : integer := 0;
    sdinvclk : integer := 0;
    pcien    : integer := 0;
    pcidll   : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000;
    clk2xen  : integer := 0);      
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    clk2x   : out std_logic;			-- double clock    
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
end component; 

component clkgen_rh_lib18t
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1);
  port (
    rst     : in  std_logic;
    clkin   : in  std_logic;
    clk     : out std_logic;
    sdclk   : out std_logic;			-- SDRAM clock
    clk2x   : out std_logic;
    clk4x   : out std_logic
    );
end component; 

component clkmul_virtex2
  generic ( clk_mul : integer := 2 ; clk_div : integer := 2);
  port (
    resetin : in  std_logic;
    clkin   : in  std_logic;
    clk     : out std_logic;
    resetout: out std_logic
  );
end component;

component clkand_unisim
  port(
    i      :  in  std_ulogic;
    en     :  in  std_ulogic;
    o      :  out std_ulogic
  );
end component;

component clkand_ut025crh
  port(
    i      :  in  std_ulogic;
    en     :  in  std_ulogic;
    o      :  out std_ulogic
  );
end component;

component clkmux_unisim
  port(
    i0, i1  :  in  std_ulogic;
    sel     :  in  std_ulogic;
    o       :  out std_ulogic
  );
end component;

  component altera_pll
    generic (
      clk_mul  : integer := 1; 
      clk_div  : integer := 1;
      clk_freq : integer := 25000;
      clk2xen  : integer := 0;          
      sdramen  : integer := 0
    );
    port (
      inclk0 : in  std_ulogic;
      c0     : out std_ulogic;
      c0_2x   : out std_ulogic;
      e0     : out std_ulogic;
      locked : out std_ulogic);
  end component;

  component clkgen_proasic3
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    clk_odiv : integer := 1;		-- output divider
    pcien    : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000);	-- clock frequency in KHz
  port (
    clkin   : in  std_ulogic;
    pciclkin: in  std_ulogic;
    clk     : out std_ulogic;			-- main clock
    sdclk   : out std_ulogic;			-- SDRAM clock
    pciclk  : out std_ulogic;
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type);
  end component; 

  component cyclone3_pll is
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    clk_freq : integer := 25000;
    clk2xen  : integer := 0;          
    sdramen  : integer := 0
  );
  port (
    inclk0  : in  std_ulogic;
    c0	    : out std_ulogic;
    c0_2x   : out std_ulogic;
    e0	    : out std_ulogic; 
    locked  : out std_ulogic);
  end component;

  component stratix3_pll
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    clk_freq : integer := 25000;
    clk2xen  : integer := 0;          
    sdramen  : integer := 0
  );
  port (
    inclk0  : in  std_ulogic;
    c0	    : out std_ulogic;
    c0_2x   : out std_ulogic;
    e0	    : out std_ulogic; 
    locked  : out std_ulogic);
  end component;

  component clkgen_dare
  port (
    clkin   : in  std_logic;
    clk     : out std_logic;			-- main clock
    clk2x   : out std_logic;			-- 2x clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type;
    clk4x   : out std_logic;			-- 4x clock
    clk1xu  : out std_logic;			-- unscaled 1X clock
    clk2xu  : out std_logic);			-- unscaled 2X clock
  end component; 
end;
