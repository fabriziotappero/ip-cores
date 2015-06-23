



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003  Gaisler Research
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	cache
-- File:	cache.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Complete cache sub-system with controllers and rams
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.amba.all;
use work.leon_iface.all;
use work.mmuconfig.all;

entity mmu_cache is
  port (
    rst   : in  std_logic;
    clk   : in  clk_type;
    ici   : in  icache_in_type;
    ico   : out icache_out_type;
    dci   : in  dcache_in_type;
    dco   : out dcache_out_type;
    iuo   : in  iu_out_type;		
    apbi  : in  apb_slv_in_type;
    apbo  : out apb_slv_out_type;
    ahbi  : in  ahb_mst_in_type;
    ahbo  : out ahb_mst_out_type;
    ahbsi : in  ahb_slv_in_type;
    crami : out cram_in_type;
    cramo : in  cram_out_type;
    fpuholdn : in  std_logic
  );
end; 

architecture rtl of mmu_cache is

component mmu_acache
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    mcii   : in  memory_ic_in_type;
    mcio   : out memory_ic_out_type;
    mcdi   : in  memory_dc_in_type;
    mcdo   : out memory_dc_out_type;
    mcmmi  : in  memory_mm_in_type;
    mcmmo  : out memory_mm_out_type;
    iuo    : in  iu_out_type;		
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type
  );
end component;

component mmu_dcache
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    dci    : in  dcache_in_type;
    dco    : out dcache_out_type;
    ico    : in  icache_out_type;
    mcdi   : out memory_dc_in_type;
    mcdo   : in  memory_dc_out_type;
    ahbsi : in  ahb_slv_in_type;
    dcrami : out dcram_in_type;
    dcramo : in  dcram_out_type;
    fpuholdn : in  std_logic;
    mmudci : out mmudc_in_type;
    mmudco : in mmudc_out_type
);
end component; 

component mmu_icache
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    ici    : in  icache_in_type;
    ico    : out icache_out_type;
    dci    : in  dcache_in_type;
    dco    : in  dcache_out_type;
    mcii   : out memory_ic_in_type;
    mcio   : in  memory_ic_out_type;
    icrami : out icram_in_type;
    icramo : in  icram_out_type;
    fpuholdn : in  std_logic;
    mmudci : in  mmudc_in_type;
    mmuici : out mmuic_in_type;
    mmuico : in mmuic_out_type
);
end component; 

component mmu 
  port (
    rst  : in std_logic;
    clk  : in clk_type;
    
    mmudci : in mmudc_in_type;
    mmudco : out mmudc_out_type;
    mmuici : in mmuic_in_type;
    mmuico : out mmuic_out_type;
    
    mcmmo  : in  memory_mm_out_type;
    mcmmi  : out memory_mm_in_type
    );
end component;

signal dcol : dcache_out_type;
signal mcdi : memory_dc_in_type;
signal mcdo : memory_dc_out_type;
signal icol : icache_out_type;
signal mcii : memory_ic_in_type;
signal mcio : memory_ic_out_type;

signal mcmmi  : memory_mm_in_type;
signal mcmmo  : memory_mm_out_type;
signal mmudci : mmudc_in_type;
signal mmudco : mmudc_out_type;
signal mmuici : mmuic_in_type;
signal mmuico : mmuic_out_type;

begin

-- instruction cache controller
  icache0 : mmu_icache port map ( rst, clk, ici, icol, dci, dcol, mcii, mcio, 
   			      crami.icramin, cramo.icramout, fpuholdn,
                              mmudci, mmuici, mmuico);

-- data cache controller
  dcache0 : mmu_dcache port map ( rst, clk, dci, dcol, icol, mcdi, mcdo, ahbsi,
			      crami.dcramin, cramo.dcramout, fpuholdn,
                              mmudci, mmudco);

-- AMBA AHB interface
  a0 : mmu_acache port map (rst, clk, mcii, mcio, mcdi, mcdo, mcmmi, mcmmo, 
			iuo, apbi, apbo, ahbi, ahbo);

-- MMU
    m0: mmu port map (rst, clk, mmudci, mmudco, mmuici, mmuico, mcmmo, mcmmi);
  
  ico <= icol;
  dco <= dcol;

end ;

