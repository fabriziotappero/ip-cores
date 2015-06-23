



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
-- Entity: 	proc
-- File:	proc.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	This unit contains the integer unit, cache memory,
--		clock/reset generation and (optinally) FPU.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_config.all;
use work.mmuconfig.all;
use work.leon_iface.all;
use work.amba.all;
use work.fpulib.all;
use work.tech_map.all;

entity proc is
  port (
    rst    : in  std_logic;
    clk    : in  clk_type;			-- main clock
    clkn   : in  clk_type;			-- inverted main clock
    apbi   : in  apb_slv_in_type;
    apbo   : out apb_slv_out_type;
    ahbi   : in  ahb_mst_in_type;
    ahbo   : out ahb_mst_out_type;
    ahbsi  : in  ahb_slv_in_type;
    iui    : in  iu_in_type;
    iuo    : out iu_out_type
  );
end; 

architecture rtl of proc is

component iu
port (
    rst    : in  std_logic;
    clk    : in  clk_type;		
    holdn  : in  std_logic;		
    ici    : out icache_in_type;		-- icache input
    ico    : in  icache_out_type;		-- icache output
    dci    : out dcache_in_type;		-- dcache input
    dco    : in  dcache_out_type;		-- dcache output
    fpui   : out fpu_in_type;			-- FPU input
    fpuo   : in  fpu_out_type;			-- FPU output
    iui    : in  iu_in_type;			-- system input
    iuo    : out iu_out_type;			-- system output
    rfi    : out rf_in_type;			-- register-file input
    rfo    : in rf_out_type;			-- register-file output
    cpi    : out cp_in_type;			-- CP input
    cpo    : in  cp_out_type;			-- CP output
    fpi    : out cp_in_type;			-- FP input
    fpo    : in  cp_out_type			-- FP output
);
end component;

component cache
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
end component; 

component mmu_cache
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
end component; 

component cp
port (
    rst    : in  std_logic;			-- Reset
    clk    : in  clk_type;			-- main clock	
    iuclk  : in  clk_type;			-- gated IU clock
    holdn  : in  std_logic;			-- pipeline hold
    cpi    : in  cp_in_type;
    cpo    : out cp_out_type
  );
end component;

component cachemem 
  port (
    	clk   : in  clk_type;
	crami : in  cram_in_type;
	cramo : out cram_out_type
  );
end component;

signal ici : icache_in_type;
signal ico : icache_out_type;
signal dci : dcache_in_type;
signal dco : dcache_out_type;

signal fpui : fpu_in_type;
signal fpuo : fpu_out_type;
signal cpi, fpi : cp_in_type;
signal cpo, fpo : cp_out_type;
signal holdn, pholdn, xholdn : std_logic;
signal iuol : iu_out_type;		
signal rfi : rf_in_type;			-- register-file input
signal rfo : rf_out_type;			-- register-file output
signal crami : cram_in_type;
signal cramo : cram_out_type;



begin

  holdn <= ico.hold and dco.hold and fpui.fpuholdn and cpo.holdn and fpo.holdn;
  pholdn <= fpui.fpuholdn and cpo.holdn and fpo.holdn;
  xholdn <= cpo.holdn and dco.hold and ico.hold;
  iuo <= iuol;

-- integer unit and register file

  iu0 : iu  port map (rst, clk, holdn, ici, ico, dci, dco, fpui, fpuo, 
	iui, iuol, rfi, rfo, cpi, cpo, fpi, fpo);

  rf0 : regfile_iu generic map (RFIMPTYPE, RABITS, RDBITS, IREGNUM)
       port map (rst, clk, clkn, rfi, rfo);

-- cache controller and memories

  cx : if not M_EN generate
    c0 : cache port map (rst, clk, ici, ico, dci, dco, iuol, 
	apbi, apbo, ahbi, ahbo, ahbsi, crami, cramo, pholdn);
  end generate;

  m0 : if M_EN generate
    c0 : mmu_cache port map (rst, clk, ici, ico, dci, dco, iuol, 
	apbi, apbo, ahbi, ahbo, ahbsi, crami, cramo, pholdn);
  end generate;

  cmem0 : cachemem port map (clk, crami, cramo);

-- serial floating-point co-processor (optional)
  
  fpsopt : if (FPIFTYPE = serial) generate
    fpu0 : fpu_core port map (clk, fpui, fpuo); -- Meiko/LTH serial
  end generate;

-- parallel floating-point co-processor (optional)
  
  fppopt : if (FPIFTYPE = parallel) generate
    fpc0 : if (FPCORE = grfpu) generate	-- GR FPU/FPC
      grfpc0 : grfpc port map (rst, clk, holdn, xholdn, fpi, fpo);
    end generate;
    fp1eu0 : if (FPCORE /= grfpu) generate 	-- Meiko/LTH parallel
      fp0 : fp1eu port map (rst, clk, holdn, xholdn, fpi, fpo);
    end generate;
  end generate;

  nofpc : if (FPIFTYPE /= parallel)  generate
    fpo.holdn <= '1';
    fpo.ldlock <= '0';
    fpo.ccv <= '1';
  end generate;

-- co-processor (optional)

  cpopt : if CPEN generate
    cp0 : fp1eu port map (rst, clk, holdn, xholdn, cpi, cpo);
  end generate;

  nocp : if not CPEN generate
    cpo.holdn <= '1';
    cpo.ldlock <= '0';
  end generate;
end ;

