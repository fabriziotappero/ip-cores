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
-- Entity: 	mmulru
-- File:	mmulru.vhd
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

entity mmulru is
  generic (
    entries  : integer := 8
    );
    port (
    rst   : in std_logic;
    clk   : in std_logic;
    lrui  : in mmulru_in_type;
    lruo  : out mmulru_out_type 
    );
end mmulru;

architecture rtl of mmulru is

  constant entries_log : integer := log2(entries);  
  component mmulrue 
  generic (
    position : integer;
    entries  : integer := 8
    );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    lruei    : in mmulrue_in_type;
    lrueo    : out mmulrue_out_type 
  );
  end component;

  type lru_rtype is record
    bar   : std_logic_vector(1 downto 0);
    clear : std_logic_vector(M_ENT_MAX-1 downto 0);
    
    -- pragma translate_off
    reinit : std_logic;
    pos    : std_logic_vector(entries_log-1 downto 0);
    -- pragma translate_on
  end record;
  
  signal c,r   : lru_rtype;
  signal lruei : mmulruei_a (entries-1 downto 0);
  signal lrueo : mmulrueo_a (entries-1 downto 0);
begin  

  p0: process (rst, r, c, lrui, lrueo)
    variable v : lru_rtype;
    variable reinit : std_logic;
    variable v_lruei_clk : std_logic;
    variable pos : std_logic_vector(entries_log-1 downto 0);
    variable touch : std_logic;
  begin
    v := r;
    -- #init
    reinit := '0';
    v_lruei_clk := rst;
       
    --# eather element in luri or element 0 to top
    pos := lrui.pos(entries_log-1 downto 0);
    touch := lrui.touch;
    if (lrui.touchmin) = '1' then
      pos := lrueo(0).pos(entries_log-1 downto 0);
      touch := '1';
    end if;      
    for i in entries-1 downto 0 loop
      lruei(i).pos <= (others => '0');  -- this is really ugly ...
      lruei(i).left <= (others => '0');
      lruei(i).right <= (others => '0');
      lruei(i).pos(entries_log-1 downto 0)   <= pos;
      lruei(i).touch <= touch;
      lruei(i).clear <= r.clear((entries-1)-i);  -- reverse order
      lruei(i).flush <= lrui.flush;
    end loop;
    
    lruei(entries-1).fromleft  <= '0';
    lruei(entries-1).fromright <= lrueo(entries-2).movetop;
    lruei(entries-1).right(entries_log-1 downto 0)     <= lrueo(entries-2).pos(entries_log-1 downto 0);
    
    for i in entries-2 downto 1 loop
      lruei(i).left(entries_log-1 downto 0)      <= lrueo(i+1).pos(entries_log-1 downto 0);
      lruei(i).right(entries_log-1 downto 0)     <= lrueo(i-1).pos(entries_log-1 downto 0);
      lruei(i).fromleft  <= lrueo(i+1).movetop;
      lruei(i).fromright <= lrueo(i-1).movetop;
    end loop;
    
    lruei(0).fromleft <= lrueo(1).movetop;
    lruei(0).fromright  <= '0';
    lruei(0).left(entries_log-1 downto 0)     <= lrueo(1).pos(entries_log-1 downto 0);

    if not (r.bar = lrui.mmctrl1.bar) then
      reinit := '1';
    end if;
    -- pragma translate_off
    
    -- pragma translate_on
    if (rst) = '0' then
       v.bar := lrui.mmctrl1.bar;
       reinit := '1';
    end if;

    if (reinit) = '1' then
      v.bar := lrui.mmctrl1.bar;
      v.clear := (others => '0');
      case lrui.mmctrl1.bar is
        when "01"  => 
           v.clear(1 downto 0)  := "11";  -- reverse order
        when "10"  => 
           v.clear(2 downto 0)  := "111";  -- reverse order
        when "11"  => 
           v.clear(4 downto 0)  := "11111"; -- reverse order
        when others => 
           v.clear(0)  := '1'; 
      end case;
    end if;

    --# drive signals
      
    -- pragma translate_off
    v.reinit := reinit;
    v.pos    := pos;
    -- pragma translate_on
    
    lruo.pos  <= lrueo(0).pos;

    c <= v;
    
  end process p0;
  
  p1: process (clk)
  begin if rising_edge(clk) then r <= c; end if;
  end process p1;

  --# lru entries
  lrue0: for i in entries-1 downto 0 generate
    l1 : mmulrue
      generic map ( position => i,
                    entries => entries )
      port map (rst, clk, lruei(i), lrueo(i));
  end generate lrue0;

end rtl;
