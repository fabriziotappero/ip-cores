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
-- Entity:      gen_iddr_reg
-- File:        gen_iddr_reg.vhd
-- Author:      David Lindh, Jiri Gaisler - Gaisler Research
-- Description: Generic DDR input reg
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity gen_iddr_reg is
  port(
         Q1 : out std_ulogic;
         Q2 : out std_ulogic;
         C1 : in std_ulogic;
         C2 : in std_ulogic;
         CE : in std_ulogic;
         D : in std_ulogic;
         R : in std_ulogic;
         S : in std_ulogic
      );
end;
  
architecture rtl of gen_iddr_reg is
  signal preQ2 : std_ulogic;
   
begin

  ddrregp : process(R,C1)
  begin
    if R = '1' then Q1 <= '0'; Q2 <= '0';
    elsif rising_edge(C1) then Q1 <= D; Q2 <= preQ2; end if;
  end process;

  ddrregn : process(R,C1)
  begin
    if R = '1' then preQ2 <= '0';
    elsif falling_edge(C1) then preQ2 <= D; end if;
  end process;

end;

library ieee;
use ieee.std_logic_1164.all;

entity gen_oddr_reg is
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

architecture rtl of gen_oddr_reg is
begin

end;

