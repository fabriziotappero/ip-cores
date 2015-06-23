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
-- Entity: 	clkpad
-- File:	clkpad.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Clock pad with technology wrapper
------------------------------------------------------------------------------

library techmap;
library ieee;
use ieee.std_logic_1164.all;
use techmap.gencomp.all;
use techmap.allpads.all;

entity clkpad is
  generic (tech : integer := 0; level : integer := 0; 
	   voltage : integer := x33v; arch : integer := 0;
           hf : integer := 0);
  port (pad : in std_ulogic; o : out std_ulogic; rstn : in std_ulogic := '1'; lock : out std_ulogic);
end; 

architecture rtl of clkpad is
begin
  gen0 : if has_pads(tech) = 0 generate
    o <= to_X01(pad);
  end generate;
  xcv : if (tech = virtex) generate
    u0 : virtex_clkpad generic map (level, voltage, 0, 0) port map (pad, o, rstn);
  end generate;
  xcv2 : if (tech = virtex2) or (tech = spartan3) or (tech = virtex4) or (tech = spartan3e) or (tech = virtex5) generate
    u0 : virtex_clkpad generic map (level, voltage, arch, hf) port map (pad, o, rstn, lock);
  end generate;
  axc : if (tech = axcel) generate
    u0 : axcel_clkpad generic map (level, voltage) port map (pad, o);
  end generate;
  pa3 : if (tech = proasic) or (tech = apa3) generate
    u0 : apa3_clkpad generic map (level, voltage) port map (pad, o);
  end generate;
  atc : if (tech = atc18s) generate
    u0 : atc18_clkpad generic map (level, voltage) port map (pad, o);
  end generate;
  atcrh : if (tech = atc18rha) generate
    u0 : atc18rha_clkpad generic map (level, voltage) port map (pad, o);
  end generate;
  um : if (tech = umc) generate
    u0 : umc_inpad generic map (level, voltage) port map (pad, o);
  end generate;
  rhu : if (tech = rhumc) generate
    u0 : rhumc_inpad generic map (level, voltage) port map (pad, o);
  end generate;
  ihp : if (tech = ihp25) generate
    u0 : ihp25_clkpad generic map (level, voltage) port map (pad, o);
  end generate; 
  rh18t : if (tech = rhlib18t) generate
    u0 : rh_lib18t_inpad port map (pad, o);
  end generate;
  ut025 : if (tech = ut25) generate
    u0 : ut025crh_inpad port map (pad, o);
  end generate;
  pere  : if (tech = peregrine) generate
    u0 : peregrine_inpad port map (pad, o);
  end generate;
end;
