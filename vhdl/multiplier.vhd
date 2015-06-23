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
-- MARCA multiplier
-------------------------------------------------------------------------------
-- architecture for a bit-serial multiplier
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of multiplier is

signal reg_busy     : std_logic;
signal reg_operand1 : std_logic_vector(width-1 downto 0);
signal reg_operand2 : std_logic_vector(width-1 downto 0);
signal reg_product  : std_logic_vector(width downto 0);
signal reg_hotbit   : std_logic_vector(width-1 downto 0);

signal next_busy     : std_logic;
signal next_operand1 : std_logic_vector(width-1 downto 0);
signal next_operand2 : std_logic_vector(width-1 downto 0);
signal next_product  : std_logic_vector(width downto 0);
signal next_hotbit   : std_logic_vector(width-1 downto 0);

begin  -- behaviour

  busy     <= reg_busy;
  product  <= reg_product;
  
  syn_proc: process (clock, reset)
  begin  -- process sync
    
    if reset = RESET_ACTIVE then               -- asynchronous reset (active low)

      reg_busy      <= '0';
      reg_operand1  <= (others => '0');
      reg_operand2  <= (others => '0');
      reg_product   <= (others => '0');
      reg_hotbit    <= (others => '0');
      reg_hotbit(0) <= '1';
      
    elsif clock'event and clock = '1' then  -- rising clock edge

      if trigger = '1' then
        reg_operand1                 <= operand1;
        reg_operand2                 <= operand2;
        reg_product                  <= (others => '0');
        reg_hotbit(width-1)          <= '1';
        reg_hotbit(width-2 downto 0) <= (others => '0');
        reg_busy                     <= '1';
      else
        reg_operand1                  <= next_operand1;
        reg_operand2                  <= next_operand2;
        reg_product(width-1 downto 0) <= next_product(width-1 downto 0);
        -- sticky "carry"-bit
        reg_product(width)            <= reg_product(width) or next_product(width);
        reg_hotbit                    <= next_hotbit;
        reg_busy                      <= next_busy;
      end if;
      
    end if;
  end process syn_proc;

  compute: process (reg_operand1, reg_operand2, reg_product, reg_hotbit)
  begin  -- process compute

    next_operand1 <= reg_operand1(width-2 downto 0) & '0';
    next_operand2 <= '0' & reg_operand2(width-1 downto 1);
    next_hotbit   <= '0' & reg_hotbit(width-1 downto 1);

    if reg_hotbit(0) = '1' then
      next_hotbit <= reg_hotbit;
      next_busy <= '0';
    else
      next_busy <= '1';
    end if;

    if reg_operand2(0) = '1' then
      next_product <= std_logic_vector(unsigned(reg_product) + unsigned(reg_operand1(width-1 downto 0)));
    else
      next_product <= reg_product;
    end if;
    
  end process compute;
  
end behaviour;
