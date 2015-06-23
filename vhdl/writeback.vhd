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
-- MARCA write-back stage
-------------------------------------------------------------------------------
-- architecture of the write-back pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use work.marca_pkg.all;

architecture behaviour of writeback is

signal pcchg_reg : std_logic;
signal pc_reg : std_logic_vector(REG_WIDTH-1 downto 0);
signal dest_reg : std_logic_vector(REG_COUNT_LOG-1 downto 0);
signal result_reg : std_logic_vector(REG_WIDTH-1 downto 0);
signal target_reg : TARGET_SELECTOR;

begin  -- behaviour

  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then                 -- asynchronous reset (active low)
      pcchg_reg <= '0';
      pc_reg <= (others => '0');
      dest_reg <= (others => '0');
      result_reg <= (others => '0');
      target_reg <= TARGET_NONE;
    elsif clock'event and clock = '1' then  -- rising clock edge
      if hold = '0' then
        pcchg_reg <= pcchg;
        pc_reg <= pc_in;
        dest_reg <= dest_in;
        target_reg <= target;                
        result_reg <= result;
      end if;
    end if;
  end process syn_proc;

  dispatch: process (target_reg, pcchg_reg, pc_reg, result_reg, dest_reg)
  begin  -- process dispatch

    pcena <= '0';
    pc_out <= pc_reg;
    
    ena <= '0';
    dest_out <= dest_reg;
    val <= result_reg;
    
    case target_reg is
      
      when TARGET_REGISTER =>
        ena <= '1';
        
      when TARGET_PC =>
        if pcchg_reg = '1' then
          pcena <= '1';
          pc_out <= result_reg;
        end if;
        
      when TARGET_BOTH =>
        pcena <= '1';
        ena <= '1';

      when others => null;
    end case;

  end process dispatch;

end behaviour;
