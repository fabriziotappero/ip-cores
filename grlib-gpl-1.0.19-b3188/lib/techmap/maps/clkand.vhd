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
-- Entity: 	clkand
-- File:	clkand.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Clock gating
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.gencomp.all;
use work.allclkgen.all;

entity clkand is
  generic( tech : integer := 0;
           ren  : integer range 0 to 1 := 0); -- registered enable
  port(
    i      :  in  std_ulogic;
    en     :  in  std_ulogic;
    o      :  out std_ulogic
  );
end entity;

architecture rtl of clkand is
signal eni : std_ulogic;
begin

  re : if ren = 1 generate
    renproc : process(i)
    begin
      if falling_edge(i) then eni <= en; end if;
    end process;
  end generate;

  ce : if ren = 0 generate eni <= en; end generate;
  
  xil : if (tech = virtex2) or (tech = spartan3) or (tech = spartan3e)
          or (tech = virtex4) or (tech = virtex5) generate
    clkgate : clkand_unisim port map(I => i, en => eni, O => o);
  end generate;

  ut : if (tech = ut25) generate
    clkgate : clkand_ut025crh port map(I => i, en => eni, O => o);
  end generate;

  gen : if has_clkand(tech) = 0 generate
    o <= i and eni;
  end generate;
end architecture;




