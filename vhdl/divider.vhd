--  This file is part of the marca processor.
--  Copyright (C) 2007 Wolfgang Puffitsch

--  This program is free software; you can redistribute it and/or modify it
--  under the terms of the GNU Library General Public License as published
--  by the Free Software Foundation; either version 2, or (at your option)
--  any later version.

--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Library General Public License for more details.

--  You should have received a copy of the GNU Library General Public
--  License along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

-------------------------------------------------------------------------------
-- MARCA divider
-------------------------------------------------------------------------------
-- architecture for a bit-serial divider
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of divider is

signal reg_busy     : std_logic;
signal reg_denom    : std_logic_vector(2*width-2 downto 0);
signal reg_remain   : std_logic_vector(width-1 downto 0);
signal reg_quotient : std_logic_vector(width-1 downto 0);
signal reg_hotbit   : std_logic_vector(width-1 downto 0);

signal next_busy     : std_logic;
signal next_denom    : std_logic_vector(2*width-2 downto 0);
signal next_remain   : std_logic_vector(width-1 downto 0);
signal next_quotient : std_logic_vector(width-1 downto 0);
signal next_hotbit   : std_logic_vector(width-1 downto 0);

begin  -- behaviour

  busy     <= reg_busy;
  quotient <= reg_quotient;
  remain   <= reg_remain;
  
  syn_proc: process (clock, reset)
  begin  -- process sync
    
    if reset = RESET_ACTIVE then               -- asynchronous reset (active low)

      reg_busy      <= '0';
      reg_denom     <= (others => '0');
      reg_remain    <= (others => '0');
      reg_quotient  <= (others => '0');
      reg_hotbit    <= (others => '0');
      reg_hotbit(0) <= '1';
      
    elsif clock'event and clock = '1' then  -- rising clock edge

      if trigger = '1' then
        reg_denom(2*width-2 downto width-1) <= denom;
        reg_denom(width-2 downto 0)         <= (others => '0');
        reg_remain                          <= numer;
        reg_quotient                        <= (others => '0');
        reg_hotbit(width-1)                 <= '1';
        reg_hotbit(width-2 downto 0)        <= (others => '0');
        if zero(denom) = '1' then
          exc                               <= '1';
          reg_busy                          <= '0';
        else
          exc                               <= '0';
          reg_busy                          <= '1';
        end if;
      else
        reg_denom    <= next_denom;
        reg_remain   <= next_remain;
        reg_quotient <= next_quotient;
        reg_hotbit   <= next_hotbit;
        reg_busy     <= next_busy;
        exc          <= '0';
      end if;
      
    end if;
  end process syn_proc;

  compute: process (reg_denom, reg_remain, reg_quotient, reg_hotbit)
    variable tmp_remain : std_logic_vector(2*width-2 downto 0);
  begin  -- process compute

    next_denom    <= '0' & reg_denom(2*width-2 downto 1);
    next_remain   <= reg_remain;
    next_quotient <= reg_quotient;
    next_hotbit   <= '0' & reg_hotbit(width-1 downto 1);

    if reg_hotbit(0) = '1' then
      next_hotbit <= reg_hotbit;
      next_busy <= '0';
    else
      next_busy <= '1';
    end if;

    tmp_remain := std_logic_vector(resize(unsigned(reg_remain), 2*width-1) - unsigned(reg_denom));
    if tmp_remain(2*width-2) = '0' then
      next_remain <= tmp_remain(width-1 downto 0);
      next_quotient <= reg_quotient or reg_hotbit;
    end if;

  end process compute;
  
end behaviour;
