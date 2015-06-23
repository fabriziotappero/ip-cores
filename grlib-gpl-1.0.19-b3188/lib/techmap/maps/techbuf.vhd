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
-- Entity: 	genclkbuf
-- File:	genclkbuf.vhd
-- Author:	Jiri Gaisler, Marko Isomaki - Gaisler Research
-- Description:	Hard buffers with tech wrapper
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library techmap;
use techmap.gencomp.all;

entity techbuf is
  generic(
    buftype  :  integer range 0 to 4 := 0; 
    tech     :  integer range 0 to NTECH := inferred);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end entity;

architecture rtl of techbuf is
component clkbuf_apa3 is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_actel is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_xilinx is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;
component clkbuf_ut025crh is generic( buftype :  integer range 0 to 3 := 0);
  port( i :  in  std_ulogic; o :  out std_ulogic);
end component;

begin
  gen : if has_techbuf(tech) = 0 generate
    o <= i;
  end generate;
  pa3 : if (tech = apa3) generate
    axc : clkbuf_apa3 generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  axc : if (tech = axcel) generate
    axc : clkbuf_actel generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  xil : if (tech = virtex) or (tech = virtex2) or (tech = spartan3) or (tech = virtex4) or 
	(tech = spartan3e) or (tech = virtex5) generate
    xil : clkbuf_xilinx generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
  ut  : if (tech = ut25) generate
    axc : clkbuf_ut025crh generic map (buftype => buftype) port map(i => i, o => o);
  end generate;
end architecture;
