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
-- Entity: 	clkbuf_actel
-- File:	clkbuf_actel.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Clock buffer generator for Actel devices
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library proasic3;
use proasic3.clkint;
-- pragma translate_on

entity clkbuf_apa3 is
  generic(
    buftype :  integer range 0 to 3 := 0);
  port(
    i       :  in  std_ulogic;
    o       :  out std_ulogic
  );
end entity;

architecture rtl of clkbuf_apa3 is
  signal o2, no2, nin : std_ulogic;
  component clkint port(a : in std_ulogic; y : out std_ulogic); end component;
  attribute syn_maxfan : integer;
  attribute syn_maxfan of o2 : signal is 10000;
begin
  o <= o2;
  buf0 : if buftype = 0 generate 
    o2 <= i;
  end generate;
  buf1 : if buftype = 1 generate 
    buf : clkint port map(A => i, Y => o2);
  end generate;
  buf2 : if buftype = 2 generate 
    buf : clkint port map(A => i, Y => o2);
  end generate;
  buf3 : if buftype > 2 generate 
    nin <= not i;
    buf : clkint port map(A => nin, Y => no2);
    o2 <= not no2;
  end generate;
end architecture;
