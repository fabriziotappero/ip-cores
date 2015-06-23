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
-- Entity:      ddr_ireg
-- File:        ddr_ireg.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: DDR input reg with tech selection
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
use techmap.allddr.all;

entity ddr_ireg is
generic ( tech : integer);
port ( Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic);
end;
  
architecture rtl of ddr_ireg is
begin

  inf : if not(tech = virtex4 or tech = virtex2 or tech = spartan3
	or (tech = virtex5)) generate
    inf0 : gen_iddr_reg port map (Q1, Q2, C1, C2, CE, D, R, S);
  end generate;

  xil : if tech = virtex4 or tech = virtex2 or tech = spartan3 
	or (tech = virtex5) generate
    xil0 : unisim_iddr_reg generic map (tech) port map (Q1, Q2, C1, C2, CE, D, R, S);
  end generate;
      
end architecture;
