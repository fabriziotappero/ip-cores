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
-- Entity: ata_inf 
-- File: ata_inf.vhd
-- Author:  Erik Jagres, Gaisler Research
-- Description: ATA components and signals
------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
library gaisler;
use gaisler.ata.all;
use gaisler.misc.all;

package ata_inf is

type slv_to_bm_type is record
   prd_belec: std_logic; 
   en       : std_logic; 
   dir      : std_logic;
   prdtb    : std_logic_vector(31 downto 0);
end record;
constant SLV_TO_BM_RESET_VECTOR : slv_to_bm_type := ('0','0','0',(others=>'0'));

type bm_to_slv_type is record
   err    : std_logic;
   done   : std_logic;
   cur_base : std_logic_vector(31 downto 0);
   cur_cnt : std_logic_vector(15 downto 0);
end record;
constant BM_TO_SLV_RESET_VECTOR : bm_to_slv_type := 
  ('0','0',(others=>'0'),(others=>'0'));


type bm_to_ctrl_type is record
  force_rdy : std_logic;
  sel : std_logic;
  ack : std_logic;
end record;

constant BM_TO_CTR_RESET_VECTOR :  bm_to_ctrl_type := ('0','0','0');

type ctrl_to_bm_type is record
  irq       : std_logic;
  ack       : std_logic;
  req       : std_logic;
  rx_empty  : std_logic;
  fifo_rdy  : std_logic;
  q         : std_logic_vector(31 downto 0);
  tip       : std_logic;
  rx_full : std_logic;
end record;

constant DMA_IN_RESET_VECTOR : ahb_dma_in_type :=
  ((others=>'0'),(others=>'0'),'0','0','0','0','0',"10");

type bmi_type is record
  fr_mst : ahb_dma_out_type;
  fr_slv : slv_to_bm_type;
  fr_ctr : ctrl_to_bm_type;
end record;

type bmo_type is record
  to_mst : ahb_dma_in_type;
  to_slv : bm_to_slv_type;
  to_ctr : bm_to_ctrl_type;
  d   : std_logic_vector(31 downto 0);
  we  : std_logic;
end record;
constant BMO_RESET_VECTOR : bmo_type :=
  (DMA_IN_RESET_VECTOR,BM_TO_SLV_RESET_VECTOR,BM_TO_CTR_RESET_VECTOR,(others=>'0'),'0');

end ata_inf;
