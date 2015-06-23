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
-- Entity: 	cache
-- File:	cache.vhd
-- Author:	Jiri Gaisler
-- Description:	Complete cache sub-system with controllers and rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library techmap;
use techmap.gencomp.all;
library gaisler;
use gaisler.libiu.all;
use gaisler.libcache.all;
use gaisler.mmuconfig.all;
use gaisler.mmuiface.all;
use gaisler.libmmu.all;

entity mmu_cache is
  generic (
    hindex    : integer              := 0;
    memtech   : integer range 0 to NTECH := 0;
    dsu       : integer range 0 to 1 := 0;
    icen      : integer range 0 to 1 := 0;
    irepl     : integer range 0 to 2 := 0;
    isets     : integer range 1 to 4 := 1;
    ilinesize : integer range 4 to 8 := 4;
    isetsize  : integer range 1 to 256 := 1;
    isetlock  : integer range 0 to 1 := 0;
    dcen      : integer range 0 to 1 := 0;
    drepl     : integer range 0 to 2 := 0;
    dsets     : integer range 1 to 4 := 1;
    dlinesize : integer range 4 to 8 := 4;
    dsetsize  : integer range 1 to 256 := 1;
    dsetlock  : integer range 0 to 1 := 0;
    dsnoop    : integer range 0 to 6 := 0;
    itlbnum   : integer range 2 to 64 := 8;
    dtlbnum   : integer range 2 to 64 := 8;
    tlb_type  : integer range 0 to 3 := 1;
    tlb_rep   : integer range 0 to 1 := 0;
    cached    : integer := 0;
    clk2x     : integer := 0;
    scantest  : integer := 0
  );
  port (
    rst   : in  std_ulogic;
    clk   : in  std_ulogic;
    ici   : in  icache_in_type;
    ico   : out icache_out_type;
    dci   : in  dcache_in_type;
    dco   : out dcache_out_type;
    ahbi  : in  ahb_mst_in_type;
    ahbo  : out ahb_mst_out_type;
    ahbsi : in  ahb_slv_in_type;
    ahbso  : in  ahb_slv_out_vector;            
    crami : out cram_in_type;
    cramo : in  cram_out_type;
    fpuholdn : in  std_ulogic;
    hclk, sclk : in std_ulogic;
    hclken : in std_ulogic
  );
end; 

architecture rtl of mmu_cache is

signal icol  : icache_out_type;
signal dcol  : dcache_out_type;
signal mcii : memory_ic_in_type;
signal mcio : memory_ic_out_type;
signal mcdi : memory_dc_in_type;
signal mcdo : memory_dc_out_type;

signal mcmmi  : memory_mm_in_type;
signal mcmmo  : memory_mm_out_type;

signal mmudci : mmudc_in_type;
signal mmudco : mmudc_out_type;
signal mmuici : mmuic_in_type;
signal mmuico : mmuic_out_type;

signal ahbsi2 : ahb_slv_in_type;
signal ahbi2 : ahb_mst_in_type;
signal ahbo2 : ahb_mst_out_type;

begin

-- instruction cache controller
  icache0 : mmu_icache 
      generic map (irepl=>irepl, isets=>isets, ilinesize=>ilinesize, isetsize=>isetsize, isetlock=>isetlock)
      port map ( rst, clk, ici, icol, dci, dcol, mcii, mcio, 
   		 crami.icramin, cramo.icramo, fpuholdn, mmudci, mmuici, mmuico);

-- data cache controller
  dcache0 : mmu_dcache 
      generic map (dsu=>dsu, drepl=>drepl, dsets=>dsets, dlinesize=>dlinesize, dsetsize=>dsetsize,  dsetlock=>dsetlock, dsnoop=>dsnoop,
            itlbnum=>itlbnum, dtlbnum=>dtlbnum, tlb_type=>tlb_type, memtech=>memtech, cached => cached)
      port map ( rst, clk, dci, dcol, icol, mcdi, mcdo, ahbsi2,
		 crami.dcramin, cramo.dcramo, fpuholdn, mmudci, mmudco, sclk);

-- AMBA AHB interface
  a0 : mmu_acache 
      generic map (hindex, ilinesize, cached, clk2x, scantest)
      port map (rst, clk, mcii, mcio, mcdi, mcdo, mcmmi, mcmmo, ahbi2, ahbo2, ahbso, hclken);

  -- MMU
  m0 : mmu
      generic map (memtech, itlbnum, dtlbnum, tlb_type, tlb_rep)
      port map (rst, clk, mmudci, mmudco, mmuici, mmuico, mcmmo, mcmmi);

  ico <= icol;
  dco <= dcol;


   clk2xgen: if clk2x /= 0 generate
     sync0 : clk2xsync generic map (hindex, clk2x)
       port map (rst, hclk, clk, ahbi, ahbi2, ahbo2, ahbo, ahbsi, ahbsi2, mcii, mcdi, mcdo, mcmmi.req, mcmmo.grant, hclken);
   end generate;
     
   noclk2x : if clk2x = 0 generate
     ahbsi2 <= ahbsi;
     ahbi2  <= ahbi;
     ahbo   <= ahbo2;
   end generate;

  
  
end ;

