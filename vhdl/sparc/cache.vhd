



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
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
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	Complete cache sub-system with controllers and rams
------------------------------------------------------------------------------
-- Version control:
-- 17-02-1999:	First implemetation
-- 26-09-1999:	Release 1.0
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.amba.all;
use work.leon_iface.all;

entity cache is
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

architecture rtl of cache is

component acache
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;
    mcii   : in  memory_ic_in_type;
    mcio   : out memory_ic_out_type;
    mcdi   : in  memory_dc_in_type;
    mcdo   : out memory_dc_out_type;
    iuo    : in  iu_out_type;		
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type
  );
end component;

component dcache
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
    fpuholdn : in  std_logic
);
end component; 

component icache
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
    fpuholdn : in  std_logic
);
end component; 

signal icol  : icache_out_type;
signal dcol  : dcache_out_type;
signal mcii : memory_ic_in_type;
signal mcio : memory_ic_out_type;
signal mcdi : memory_dc_in_type;
signal mcdo : memory_dc_out_type;

begin

-- instruction cache controller
  icache0 : icache port map ( rst, clk, ici, icol, dci, dcol, mcii, mcio, 
   			      crami.icramin, cramo.icramout, fpuholdn);

-- data cache controller
  dcache0 : dcache port map ( rst, clk, dci, dcol, icol, mcdi, mcdo, ahbsi,
			      crami.dcramin, cramo.dcramout, fpuholdn);

-- AMBA AHB interface
  a0 : acache port map (rst, clk, mcii, mcio, mcdi, mcdo, iuo, apbi, apbo,
		        ahbi, ahbo);

  ico <= icol;
  dco <= dcol;

end ;

