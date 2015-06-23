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
-- Entity: atactrl 
-- File: atactrl.vhd
-- Author:  Jiri Gaisler, Gaisler Research
-- Description: ATA controller
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library gaisler;
use gaisler.ata.all;

entity atactrl is
 generic (
   tech    : integer := 0;
   fdepth  : integer := 8;
   mhindex : integer := 0;
   shindex : integer := 0;
   haddr   : integer := 0;
   hmask   : integer := 16#ff0#;
   pirq    : integer := 0;
   mwdma   : integer := 0;
  
   TWIDTH : natural := 8;                      -- counter width
   
   -- PIO mode 0 settings (@100MHz clock)
   PIO_mode0_T1 : natural := 6;                -- 70ns
   PIO_mode0_T2 : natural := 28;               -- 290ns
   PIO_mode0_T4 : natural := 2;                -- 30ns
   PIO_mode0_Teoc : natural := 23              -- 240ns ==> T0 - T1 - T2 = 600 - 70 - 290 = 240
    
 );
 port (
   rst     : in  std_ulogic;
   arst    : in  std_ulogic;
   clk     : in  std_ulogic;
   ahbsi   : in  ahb_slv_in_type;
   ahbso   : out ahb_slv_out_type;
   ahbmi   : in  ahb_mst_in_type;
   ahbmo   : out ahb_mst_out_type;
   cfo     : out cf_out_type;
   atai    : in ata_in_type;
   atao    : out ata_out_type
 );
end; 


architecture rtl of atactrl is
begin

  dmaen : if mwdma  = 1 generate
   x0 : entity work.atactrl_dma generic map (tech, fdepth, mhindex, shindex, haddr, hmask, 
	pirq, TWIDTH, PIO_mode0_T1, PIO_mode0_T2, PIO_mode0_T4, PIO_mode0_Teoc)
        port map (rst, arst, clk, ahbsi, ahbso, ahbmi, ahbmo, cfo,
	atai.ddi, atai.iordy, atai.intrq, atao.rstn, atao.ddo, atao.oen,
	atao.da, atao.cs0, atao.cs1, atao.dior, atao.diow, atao.dmack, atai.dmarq);
  end generate;

  nodma : if mwdma /= 1 generate
   x0 : entity work.atactrl_nodma generic map (shindex, haddr, hmask, 
	pirq, TWIDTH, PIO_mode0_T1, PIO_mode0_T2, PIO_mode0_T4, PIO_mode0_Teoc)
        port map (rst, arst, clk, ahbsi, ahbso, cfo,
	atai.ddi, atai.iordy, atai.intrq, atao.rstn, atao.ddo, atao.oen,
	atao.da, atao.cs0, atao.cs1, atao.dior, atao.diow, atao.dmack);
        ahbmo <= ahbm_none;
  end generate;
end;

