----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003 Gaisler Research, all rights reserved.
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.

--------------------------------------------------------------------------
-- Dummy model for the GR FPU/FPC
--------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
use work.leon_config.all;

entity grfpc is
port (
    rst    : in  std_logic;			
    clk    : in  std_logic;
    holdn  : in  std_logic;			
    xholdn : in  std_logic;			
    cpi    : in  cp_in_type;
    cpo    : out cp_out_type    
    );
end;


architecture rtl of grfpc is

component grfpcx
port (
  rst    : in  std_logic;			
  clk    : in  std_logic;
  holdn  : in  std_logic;			
  xholdn : in  std_logic;			
  cpi_flush : in  std_logic;			  
  cpi_exack   : in  std_logic;			  
  cpi_fdata     : in  std_logic_vector(31 downto 0);  
  cpi_frdy        : in  std_logic;                      
  cpi_dannul  : in  std_logic;			  
  cpi_dtrap   : in  std_logic;			  
  cpi_dcnt     : in  std_logic_vector(1 downto 0);     
  cpi_dinst     : in  std_logic_vector(31 downto 0);     
  cpi_ex_inst   : std_logic_vector(31 downto 0);     
  cpi_ex_pc     : std_logic_vector(31 downto PCLOW);     
  cpi_ex_annul  : std_logic;			      
  cpi_ex_cnt    : std_logic_vector(1 downto 0);      
  cpi_ex_ld     : std_logic;			      
  cpi_ex_pv     : std_logic;			      
  cpi_ex_rett   : std_logic;			      
  cpi_ex_trap   : std_logic;			      
  cpi_ex_tt     : std_logic_vector(5 downto 0);      
  cpi_ex_rd     : std_logic_vector(RABITS-1 downto 0); 
  cpi_me_inst   : std_logic_vector(31 downto 0);     
  cpi_me_pc     : std_logic_vector(31 downto PCLOW);     
  cpi_me_annul  : std_logic;			      
  cpi_me_cnt    : std_logic_vector(1 downto 0);      
  cpi_me_ld     : std_logic;			      
  cpi_me_pv     : std_logic;			      
  cpi_me_rett   : std_logic;			      
  cpi_me_trap   : std_logic;			      
  cpi_me_tt     : std_logic_vector(5 downto 0);      
  cpi_me_rd     : std_logic_vector(RABITS-1 downto 0); 
  cpi_wr_inst   : std_logic_vector(31 downto 0);     
  cpi_wr_pc     : std_logic_vector(31 downto PCLOW);     
  cpi_wr_annul  : std_logic;			      
  cpi_wr_cnt    : std_logic_vector(1 downto 0);      
  cpi_wr_ld     : std_logic;			      
  cpi_wr_pv     : std_logic;			      
  cpi_wr_rett   : std_logic;			      
  cpi_wr_trap   : std_logic;			      
  cpi_wr_tt     : std_logic_vector(5 downto 0);      
  cpi_wr_rd     : std_logic_vector(RABITS-1 downto 0); 
  cpi_lddata   : in  std_logic_vector(31 downto 0);     
  cpi_debug_daddr  : in  std_logic_vector(4 downto 0);
  cpi_debug_dread_fsr : in  std_logic;
  cpi_debug_dwrite_fsr : in  std_logic;  
  cpi_debug_denable  : in  std_logic;
  cpi_debug_dwrite   : in  std_logic;
  cpi_debug_ddata    : in  std_logic_vector(31 downto 0);

  cpo_data   : out  std_logic_vector(31 downto 0); 
  cpo_exc  	   : out  std_logic;			 
  cpo_cc        : out  std_logic_vector(1 downto 0);  
  cpo_ccv  	    : out  std_logic;			 
  cpo_holdn	    : out  std_logic;			 
  cpo_ldlock    : out  std_logic;			 

  cpo_debug_ddata    : out  std_logic_vector(63 downto 0);
  cpo_debug_wr_fp    : out  std_logic;
  cpo_debug_wr2_fp    : out  std_logic;
  cpo_debug_write_fpreg : out  std_logic_vector(1 downto 0);
  cpo_debug_write_fsr : out  std_logic;
  cpo_debug_fpreg    : out  std_logic_vector(3 downto 0);
  cpo_debug_op       : out  std_logic_vector(31 downto 0);
  cpo_debug_pc       : out  std_logic_vector(31 downto PCLOW)
    );
end component;


begin

  l1 : grfpcx port map (
  rst, clk, holdn, xholdn, cpi.flush, cpi.exack, cpi.fdata, 
  cpi.frdy, cpi.dannul, cpi.dtrap, cpi.dcnt, cpi.dinst, cpi.ex.inst, 
  cpi.ex.pc, cpi.ex.annul, cpi.ex.cnt, cpi.ex.ld, cpi.ex.pv, cpi.ex.rett, 
  cpi.ex.trap, cpi.ex.tt, cpi.ex.rd, cpi.me.inst, cpi.me.pc, cpi.me.annul, 
  cpi.me.cnt, cpi.me.ld, cpi.me.pv, cpi.me.rett, cpi.me.trap, cpi.me.tt, 
  cpi.me.rd, cpi.wr.inst, cpi.wr.pc, cpi.wr.annul, cpi.wr.cnt, cpi.wr.ld, 
  cpi.wr.pv, cpi.wr.rett, cpi.wr.trap, cpi.wr.tt, cpi.wr.rd, cpi.lddata, 
  cpi.debug.daddr, cpi.debug.dread_fsr, cpi.debug.dwrite_fsr, cpi.debug.denable, 
  cpi.debug.dwrite, cpi.debug.ddata, cpo.data, cpo.exc, cpo.cc, 
  cpo.ccv, cpo.holdn, cpo.ldlock, cpo.debug.ddata, 
  cpo.debug.wr_fp, cpo.debug.wr2_fp, cpo.debug.write_fpreg, cpo.debug.write_fsr, 
  cpo.debug.fpreg, cpo.debug.op, cpo.debug.pc);

 
end;

