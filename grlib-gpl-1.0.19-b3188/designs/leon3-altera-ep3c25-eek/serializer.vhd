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
-- Entity:     serializer
-- File:       serializer.vhd
-- Author:     Jan Andersson - Gaisler Research AB
--             jan@gaisler.com
--
-- Description: Takes in three vectors and serializes them into one
--              output vector. Intended to be used to serialize
--              RGB VGA data.
-- 

library ieee;
use ieee.std_logic_1164.all;

entity serializer is
  generic (
    length : integer := 8             -- vector length
    );
  port (
    clk   : in  std_ulogic;
    sync  : in  std_ulogic;
    ivec0 : in  std_logic_vector((length-1) downto 0);
    ivec1 : in  std_logic_vector((length-1) downto 0);
    ivec2 : in  std_logic_vector((length-1) downto 0);
    ovec  : out std_logic_vector((length-1) downto 0)
    );
end entity serializer;

architecture rtl of serializer is

  type state_type is (vec0, vec1, vec2);
  type sreg_type is record
    state : state_type;
    sync  : std_logic_vector(1 downto 0);
  end record;

  signal r, rin : sreg_type;
  
begin  -- rtl

  comb: process (r, clk, sync, ivec0, ivec1, ivec2)
    variable v : sreg_type;
  begin  -- process comb
    v := r;

    v.sync := r.sync(0) & sync;
    
    case r.state is
      when vec0 =>
        ovec <= ivec0;
        v.state := vec1;
      when vec1 =>
        ovec <= ivec1;
        v.state := vec2;
      when vec2 =>
        ovec <= ivec2;
        v.state := vec0;
    end case;

    if (r.sync(0) xor sync) = '1' then
      v.state := vec1;
    end if;
    
    rin <= v;
  end process comb;

  reg: process (clk)
  begin  -- process reg
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process reg;
  
end rtl;
