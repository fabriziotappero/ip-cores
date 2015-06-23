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
-- Entity: 	clkbuf_xilinx
-- File:	clkbuf_xilinx.vhd
-- Author:	Marko Isomaki, Jiri GAisler - Gaisler Research
-- Description:	Clock buffer generator for Xilinx devices
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BUFGMUX;
use unisim.BUFG;
use unisim.BUFGDLL;
-- pragma translate_on

entity clkbuf_xilinx is
  generic(
    buftype :  integer range 0 to 3 := 0);
  port(
    i       :  in  std_ulogic;
    o       :  out std_ulogic
  );
end entity;

architecture rtl of clkbuf_xilinx is
  component BUFGDLL port (O : out std_logic; I : in std_logic); end component;
  component BUFGMUX port (O : out std_logic; I0, I1, S : in std_logic); end component;
  component BUFG port (O : out std_logic; I : in std_logic); end component;
  signal gnd  : std_ulogic;
  signal x  : std_ulogic;
  attribute syn_noclockbuf : boolean;
  attribute syn_noclockbuf of x : signal is true;
begin
  gnd <= '0';
  buf0 : if (buftype = 0) or (buftype > 2) generate 
    x <= i; o <= x;
  end generate;
  buf1 : if buftype = 1 generate 
    buf : bufgmux port map(S => gnd, I0 => i, I1 => gnd, O => o);
  end generate;
  buf2 : if (buftype = 2) generate 
    buf : bufg port map(I => i, O => o);
  end generate;
  
end architecture;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BUFGMUX;
-- pragma translate_on

entity clkmux_xilinx is
  port(
    i0, i1  :  in  std_ulogic;
    sel     :  in  std_ulogic;
    o       :  out std_ulogic
  );
end entity;

architecture rtl of clkmux_xilinx is
  component BUFGMUX port (O : out std_logic; I0, I1, S : in std_logic); end component;
begin
  buf : bufgmux port map(S => sel, I0 => i0, I1 => i1, O => o);
end architecture;



