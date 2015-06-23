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
-- Entity: 	grfpwx
-- File:	grfpwx.vhd
-- Author:	Edvin Catovic - Gaisler Research
-- Description:	GRFPU/GRFPC wrapper and FP register file
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
library gaisler;
use gaisler.leon3.all;
library techmap;
use techmap.gencomp.all;
use techmap.netcomp.all;

entity grfpwx is
  generic (fabtech  : integer := 0;
           memtech  : integer := 0;           
           mul      : integer range 0 to 2 := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 2 := 0;           
           disas    : integer range 0 to 2 := 0;
           netlist  : integer              := 0;
           index    : integer              := 0);
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi    : in  fpc_in_type;
    cpo    : out fpc_out_type
    );
end;

architecture rtl of grfpwx is

  component grfpw
  generic (fabtech  : integer := 0;
           memtech  : integer := 0;                                 
           mul      : integer range 0 to 2 := 0;
           pclow    : integer range 0 to 2 := 2;
           dsu      : integer range 0 to 1 := 0;           
           disas    : integer range 0 to 2 := 0;
           index    : integer range 0 to 2 := 0
           );
  port (
    rst    : in  std_ulogic;			-- Reset
    clk    : in  std_ulogic;
    holdn  : in  std_ulogic;			-- pipeline hold
    cpi_flush  	: in std_ulogic;			  -- pipeline flush
    cpi_exack    	: in std_ulogic;			  -- FP exception acknowledge
    cpi_a_rs1  	: in std_logic_vector(4 downto 0);
    cpi_d_pc    : in std_logic_vector(31 downto 0);
    cpi_d_inst  : in std_logic_vector(31 downto 0);
    cpi_d_cnt   : in std_logic_vector(1 downto 0);
    cpi_d_trap  : in std_ulogic;
    cpi_d_annul : in std_ulogic;
    cpi_d_pv    : in std_ulogic;
    cpi_a_pc    : in std_logic_vector(31 downto 0);
    cpi_a_inst  : in std_logic_vector(31 downto 0);
    cpi_a_cnt   : in std_logic_vector(1 downto 0);
    cpi_a_trap  : in std_ulogic;
    cpi_a_annul : in std_ulogic;
    cpi_a_pv    : in std_ulogic;
    cpi_e_pc    : in std_logic_vector(31 downto 0);
    cpi_e_inst  : in std_logic_vector(31 downto 0);
    cpi_e_cnt   : in std_logic_vector(1 downto 0);
    cpi_e_trap  : in std_ulogic;
    cpi_e_annul : in std_ulogic;
    cpi_e_pv    : in std_ulogic;
    cpi_m_pc    : in std_logic_vector(31 downto 0);
    cpi_m_inst  : in std_logic_vector(31 downto 0);
    cpi_m_cnt   : in std_logic_vector(1 downto 0);
    cpi_m_trap  : in std_ulogic;
    cpi_m_annul : in std_ulogic;
    cpi_m_pv    : in std_ulogic;
    cpi_x_pc    : in std_logic_vector(31 downto 0);
    cpi_x_inst  : in std_logic_vector(31 downto 0);
    cpi_x_cnt   : in std_logic_vector(1 downto 0);
    cpi_x_trap  : in std_ulogic;
    cpi_x_annul : in std_ulogic;
    cpi_x_pv    : in std_ulogic;    
    cpi_lddata        : in std_logic_vector(31 downto 0);     -- load data
    cpi_dbg_enable : in std_ulogic;
    cpi_dbg_write  : in std_ulogic;
    cpi_dbg_fsr    : in std_ulogic;                            -- FSR access
    cpi_dbg_addr   : in std_logic_vector(4 downto 0);
    cpi_dbg_data   : in std_logic_vector(31 downto 0);

    cpo_data          : out std_logic_vector(31 downto 0); -- store data
    cpo_exc  	        : out std_logic;			 -- FP exception
    cpo_cc           : out std_logic_vector(1 downto 0);  -- FP condition codes
    cpo_ccv  	       : out std_ulogic;			 -- FP condition codes valid
    cpo_ldlock       : out std_logic;			 -- FP pipeline hold
    cpo_holdn         : out std_ulogic;
    cpo_dbg_data     : out std_logic_vector(31 downto 0);

    rfi1_rd1addr 	: out std_logic_vector(3 downto 0); 
    rfi1_rd2addr 	: out std_logic_vector(3 downto 0); 
    rfi1_wraddr 	: out std_logic_vector(3 downto 0); 
    rfi1_wrdata 	: out std_logic_vector(31 downto 0);
    rfi1_ren1        : out std_ulogic;			   
    rfi1_ren2        : out std_ulogic;			   
    rfi1_wren        : out std_ulogic;			   
    
    rfi2_rd1addr 	: out std_logic_vector(3 downto 0); 
    rfi2_rd2addr 	: out std_logic_vector(3 downto 0); 
    rfi2_wraddr 	: out std_logic_vector(3 downto 0); 
    rfi2_wrdata 	: out std_logic_vector(31 downto 0);
    rfi2_ren1        : out std_ulogic;
    rfi2_ren2        : out std_ulogic;			        
    rfi2_wren        : out std_ulogic;

    rfo1_data1    	: in std_logic_vector(31 downto 0);
    rfo1_data2    	: in std_logic_vector(31 downto 0);
    
    rfo2_data1    	: in std_logic_vector(31 downto 0);
    rfo2_data2    	: in std_logic_vector(31 downto 0)
    );
  end component;

  signal rfi1, rfi2  : fp_rf_in_type;
  signal rfo1, rfo2  : fp_rf_out_type;

begin

  x0 : if netlist = 0 generate
   grfpw0 : grfpw generic map (fabtech, memtech, mul, pclow, dsu, disas, index)
   port map (
    rst          ,
    clk          ,
    holdn        , 
    cpi.flush    ,
    cpi.exack    ,
    cpi.a_rs1    ,
    cpi.d.pc     ,
    cpi.d.inst   ,
    cpi.d.cnt    ,
    cpi.d.trap   ,
    cpi.d.annul  ,
    cpi.d.pv     ,
    cpi.a.pc     ,
    cpi.a.inst   ,
    cpi.a.cnt    ,
    cpi.a.trap   ,
    cpi.a.annul  ,
    cpi.a.pv     ,
    cpi.e.pc     ,
    cpi.e.inst   ,
    cpi.e.cnt    ,
    cpi.e.trap   ,
    cpi.e.annul  ,
    cpi.e.pv     ,
    cpi.m.pc     ,
    cpi.m.inst   ,
    cpi.m.cnt    ,
    cpi.m.trap   ,
    cpi.m.annul  ,
    cpi.m.pv     ,
    cpi.x.pc     ,
    cpi.x.inst   ,
    cpi.x.cnt    ,
    cpi.x.trap   ,
    cpi.x.annul  ,
    cpi.x.pv     ,
    cpi.lddata   ,
    cpi.dbg.enable  ,
    cpi.dbg.write   ,
    cpi.dbg.fsr     ,
    cpi.dbg.addr    ,
    cpi.dbg.data    ,

    cpo.data        ,
    cpo.exc  	    ,
    cpo.cc          ,
    cpo.ccv  	    ,
    cpo.ldlock      ,
    cpo.holdn       ,
    cpo.dbg.data    ,

    rfi1.rd1addr    ,
    rfi1.rd2addr     ,
    rfi1.wraddr      ,
    rfi1.wrdata      ,
    rfi1.ren1        ,
    rfi1.ren2        ,
    rfi1.wren        ,


    rfi2.rd1addr     ,
    rfi2.rd2addr     ,
    rfi2.wraddr       ,
    rfi2.wrdata       ,
    rfi2.ren1         ,
    rfi2.ren2         ,
    rfi2.wren         ,

    rfo1.data1        ,
    rfo1.data2        ,
    rfo2.data1        ,
    rfo2.data2        
    );
  end generate;  

  x1 : if netlist = 1 generate
   grfpw0 : grfpw_net generic map (fabtech, pclow, dsu, disas)
   port map (
    rst          ,
    clk          ,
    holdn        , 
    cpi.flush    ,
    cpi.exack    ,
    cpi.a_rs1    ,
    cpi.d.pc     ,
    cpi.d.inst   ,
    cpi.d.cnt    ,
    cpi.d.trap   ,
    cpi.d.annul  ,
    cpi.d.pv     ,
    cpi.a.pc     ,
    cpi.a.inst   ,
    cpi.a.cnt    ,
    cpi.a.trap   ,
    cpi.a.annul  ,
    cpi.a.pv     ,
    cpi.e.pc     ,
    cpi.e.inst   ,
    cpi.e.cnt    ,
    cpi.e.trap   ,
    cpi.e.annul  ,
    cpi.e.pv     ,
    cpi.m.pc     ,
    cpi.m.inst   ,
    cpi.m.cnt    ,
    cpi.m.trap   ,
    cpi.m.annul  ,
    cpi.m.pv     ,
    cpi.x.pc     ,
    cpi.x.inst   ,
    cpi.x.cnt    ,
    cpi.x.trap   ,
    cpi.x.annul  ,
    cpi.x.pv     ,
    cpi.lddata   ,
    cpi.dbg.enable  ,
    cpi.dbg.write   ,
    cpi.dbg.fsr     ,
    cpi.dbg.addr    ,
    cpi.dbg.data    ,

    cpo.data        ,
    cpo.exc  	    ,
    cpo.cc          ,
    cpo.ccv  	    ,
    cpo.ldlock      ,
    cpo.holdn       ,
    cpo.dbg.data    ,

    rfi1.rd1addr    ,
    rfi1.rd2addr     ,
    rfi1.wraddr      ,
    rfi1.wrdata      ,
    rfi1.ren1        ,
    rfi1.ren2        ,
    rfi1.wren        ,


    rfi2.rd1addr     ,
    rfi2.rd2addr     ,
    rfi2.wraddr       ,
    rfi2.wrdata       ,
    rfi2.ren1         ,
    rfi2.ren2         ,
    rfi2.wren         ,

    rfo1.data1        ,
    rfo1.data2        ,
    rfo2.data1        ,
    rfo2.data2        
    );
  end generate;  
   
   rf1 : regfile_3p generic map (memtech, 4, 32, 1, 16)
     port map (clk, rfi1.wraddr, rfi1.wrdata, rfi1.wren, clk, rfi1.rd1addr, rfi1.ren1, rfo1.data1,
               rfi1.rd2addr, rfi1.ren2, rfo1.data2);

   rf2 : regfile_3p generic map (memtech, 4, 32, 1, 16)
     port map (clk, rfi2.wraddr, rfi2.wrdata, rfi2.wren, clk, rfi2.rd1addr, rfi2.ren1, rfo2.data1,
               rfi2.rd2addr, rfi2.ren2, rfo2.data2);
   
end;
