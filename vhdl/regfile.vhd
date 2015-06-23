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
-- MARCA decode stage
-------------------------------------------------------------------------------
-- architecture for the instruction-decode pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of regfile is

type registers is array (REG_COUNT-1 downto 0) of std_logic_vector(REG_WIDTH-1 downto 0);
  
signal regs, next_regs : registers;
  
begin  -- behaviour

  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then                 -- asynchronous reset (active low)
      regs <= (others => (others => '0'));
    elsif clock'event and clock = '1' then  -- rising clock edge
      if hold = '0' then
        regs <= next_regs;
      end if;
    end if;
  end process syn_proc;
  
  forward: process(rd1_addr, rd2_addr, wr_ena, wr_addr, wr_val, regs)
  begin  -- process forward

    next_regs <= regs;
    
    if wr_ena = '1' then
      next_regs(to_integer(unsigned(wr_addr))) <= wr_val;
    end if;

    if rd1_addr /= wr_addr or wr_ena = '0' then
      rd1_val <= regs(to_integer(unsigned(rd1_addr)));
    else
      rd1_val <= wr_val;
    end if;

    if rd2_addr /= wr_addr or wr_ena = '0' then
      rd2_val <= regs(to_integer(unsigned(rd2_addr)));
    else
      rd2_val <= wr_val;
    end if;

  end process forward;

end behaviour;
