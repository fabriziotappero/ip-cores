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
-- Entity:      ddr_oreg
-- File:        ddr_oreg.vhd
-- Author:      Jiri Gaisler - Gaisler Research
-- Description: DDR output reg with tech selection
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;
use techmap.allddr.all;

entity ddr_oreg is generic ( tech : integer);
  port
    ( Q : out std_ulogic;
      C1 : in std_ulogic;
      C2 : in std_ulogic;
      CE : in std_ulogic;
      D1 : in std_ulogic;
      D2 : in std_ulogic;
      R : in std_ulogic;
      S : in std_ulogic);
end;

architecture rtl of ddr_oreg is
begin

  inf : if not (tech = lattice or tech = virtex4 or tech = virtex2 or tech = spartan3 
	or (tech = virtex5)) generate
    inf0 : gen_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  lat : if tech = lattice generate
    lat0 : ec_oddr_reg port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

  xil : if tech = virtex4 or tech = virtex2 or tech = spartan3
	or (tech = virtex5) generate
    xil0 : unisim_oddr_reg generic map (tech)
	port map (Q, C1, C2, CE, D1, D2, R, S);
  end generate;

end;
