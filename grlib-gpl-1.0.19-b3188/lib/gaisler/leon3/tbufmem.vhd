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
-- Entity: 	tbufmem
-- File:	tbufmem.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	128-bit trace buffer memory (CPU/AHB)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library gaisler;
use gaisler.libiu.all;
library techmap;
use techmap.gencomp.all;
library grlib;
use grlib.stdlib.all;

entity tbufmem is
  generic (
    tech   : integer := 0;
    tbuf   : integer := 0 -- trace buf size in kB (0 - no trace buffer)
    );
  port (
    clk : in std_ulogic;
    di  : in tracebuf_in_type;
    do  : out tracebuf_out_type);
end;

architecture rtl of tbufmem is

constant ADDRBITS : integer := 10 + log2(tbuf) - 4;
signal enable : std_logic_vector(1 downto 0);
  
begin

  enable <= di.enable & di.enable;
  mem0 : for i in 0 to 1 generate
    ram0 : syncram64 generic map (tech => tech, abits => addrbits)
      port map ( clk, di.addr(addrbits-1 downto 0), di.data(((i*64)+63) downto (i*64)),
                 do.data(((i*64)+63) downto (i*64)), enable ,di.write(i*2+1 downto i*2),
		 di.diag);
  end generate;
end;
  
