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
-- MARCA interrupt unit
-------------------------------------------------------------------------------
-- architecture for the interrupt unit
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of intr is
  
type vectors is array (VEC_COUNT-1 downto 0) of std_logic_vector(REG_WIDTH-1 downto 0);
signal vecs, next_vecs : vectors;

signal ira, next_ira : std_logic_vector(REG_WIDTH-1 downto 0);

begin  -- behaviour

  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then            -- asynchronous reset (active low)
      vecs <= (others => (others => '0'));
      ira <= (others => '0');
    elsif clock'event and clock = '1' then  -- rising clock edge
      vecs <= next_vecs;
      ira <= next_ira;
    end if;
  end process syn_proc;

  compute: process (op, a, i, pc, vecs, ira, enable, trigger)
  begin  -- process compute

    next_vecs <= vecs;
    next_ira <= ira;

    exc    <= '0';
    pcchg  <= '0';
    result <= (others => '0');

    case op is
      when INTR_INTR =>
        if enable = '1' then
          pcchg  <= '1';
          result <= vecs(to_integer(unsigned(i)));
          next_ira <= std_logic_vector(unsigned(pc) + 1);
        end if;
      when INTR_RETI =>
        pcchg  <= '1';
        result <= ira;
      when INTR_SETIRA =>
        next_ira <= a;
      when INTR_GETIRA =>
        result <= ira;
      when INTR_STVEC =>
        next_vecs(to_integer(unsigned(i))) <= a;
      when INTR_LDVEC =>
        result <= vecs(to_integer(unsigned(i)));
      when others => null;
    end case;

    if enable = '1' then
      for v in VEC_COUNT-1 downto 1 loop
        if trigger(v) = '1' then
          exc <= '1';
          pcchg <= '1';
          result <= vecs(v);
          if v = EXC_ALU or v = EXC_MEM then
            -- don't repeat division by zero and ill memory access
            next_ira <= std_logic_vector(unsigned(pc) + 1);
          else
            -- repeat the instruction if interrupted
            next_ira <= pc;
          end if;
        end if;
      end loop;  
    end if;
    
  end process compute;
  
end behaviour;
