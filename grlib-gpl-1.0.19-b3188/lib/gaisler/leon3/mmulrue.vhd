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
-- Entity: 	mmulrue
-- File:	mmulrue.vhd
-- Author:	Konrad Eisele, Jiri Gaisler, Gaisler Research
-- Description:	MMU LRU logic
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
library gaisler;
use gaisler.libiu.all;
use gaisler.libcache.all;
use gaisler.leon3.all;
use gaisler.mmuconfig.all;
use gaisler.mmuiface.all;

entity mmulrue is
  generic (
    position : integer;
    entries  : integer := 8 );
  port (
    rst    : in std_logic;
    clk    : in std_logic;
    lruei  : in mmulrue_in_type;
    lrueo  : out mmulrue_out_type );
end mmulrue;

architecture rtl of mmulrue is

  constant entries_log : integer := log2(entries);  
  type lru_rtype is record
    pos      : std_logic_vector(entries_log-1 downto 0);
    movetop  : std_logic;
    -- pragma translate_off
    dummy  : std_logic;
    -- pragma translate_on
  end record;

  signal c,r   : lru_rtype;
begin  
  
  p0: process (rst, r, c, lruei)
    variable v : lru_rtype;
    variable ov : mmulrue_out_type;
  begin
    v := r; ov := mmulrue_out_none;
    -- #init

    if (r.movetop) = '1' then
      if (lruei.fromleft) = '0' then
        v.pos := lruei.left(entries_log-1 downto 0); 
        v.movetop := '0';
      end if;
    elsif (lruei.fromright) = '1' then
      v.pos := lruei.right(entries_log-1 downto 0);
      v.movetop := not lruei.clear;
    end if;

    if (lruei.touch and not lruei.clear) = '1' then  -- touch request
      if (v.pos = lruei.pos(entries_log-1 downto 0)) then     -- check
          v.movetop := '1';
      end if;
    end if;

    if ((rst) = '0') or (lruei.flush = '1') then
      v.pos := conv_std_logic_vector(position, entries_log);
      v.movetop := '0';
    end if;
    
    --# Drive signals
    ov.pos(entries_log-1 downto 0) := r.pos; 
    ov.movetop := r.movetop;
    lrueo <= ov; 
    
    c <= v;
  end process p0;

  p1: process (clk)
  begin if rising_edge(clk) then r <= c; end if;
  end process p1;

end rtl;








