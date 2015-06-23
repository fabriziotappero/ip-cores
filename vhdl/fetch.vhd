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
-- MARCA fetch stage
-------------------------------------------------------------------------------
-- architecture for the instruction-fetch pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

architecture behaviour of fetch is

component code_memory
  generic (
    init_file : string);
  port (
    clken   : in std_logic;
    clock   : in std_logic;
    address : in std_logic_vector (PADDR_WIDTH-1 downto 0);
    q       : out std_logic_vector (PDATA_WIDTH-1 downto 0));
end component;  
  
signal enable : std_logic;

signal address : std_logic_vector(PADDR_WIDTH-1 downto 0);
signal data    : std_logic_vector(PDATA_WIDTH-1 downto 0);
  
signal pc_reg  : std_logic_vector(REG_WIDTH-1 downto 0);
signal next_pc : std_logic_vector(REG_WIDTH-1 downto 0);

signal next_pc_out : std_logic_vector(REG_WIDTH-1 downto 0);

begin  -- behaviour

  enable <= not hold;
  pc_out <= pc_reg;
  
  code_memory_unit : code_memory
    generic map (
      init_file => "../vhdl/code.mif")
    port map (
      address   => address(PADDR_WIDTH-1 downto 0),
      clken     => enable,
      clock     => clock,
      q         => data);

  syn_proc: process (clock, reset)
  begin  -- process syn_proc
    if reset = RESET_ACTIVE then                 -- asynchronous reset (active low)
      pc_reg <= (others => '0');
    elsif clock'event and clock = '1' then  -- rising clock edge
      if hold = '0' then
        pc_reg <= next_pc;
      end if;
    end if;
  end process syn_proc;

  increment: process (pc_reg, pc_in, pcena, data)
  begin  -- process increment
    if pcena = '1' then
      next_pc <= pc_in;
    else
      -- "predict" hard branches
      if data(PDATA_WIDTH-1 downto PDATA_WIDTH-8) = OPC_PFX_C & OPC_BR then
        next_pc <= std_logic_vector(signed(pc_reg) + signed(data(7 downto 0)));
      else
        next_pc <= std_logic_vector(unsigned(pc_reg) + 1);
      end if;
    end if;
  end process increment;

  forward: process (pc_reg, pc_in, pcena, data, reset)
  begin  -- process forward
    if reset = RESET_ACTIVE then
      address <= (others => '0');
    else
      if pcena = '1' then
        address <= pc_in(PADDR_WIDTH-1 downto 0);
      else
        if data(PDATA_WIDTH-1 downto PDATA_WIDTH-8) = OPC_PFX_C & OPC_BR then
          address <= std_logic_vector(signed(pc_reg) + signed(data(7 downto 0)))(PADDR_WIDTH-1 downto 0);
        else
          address <= std_logic_vector(unsigned(pc_reg) + 1)(PADDR_WIDTH-1 downto 0);
        end if;
      end if;
    end if;
  end process forward;
  
  spread: process (data)
  begin  -- process spread
    src1 <= data(3 downto 0);
    src2 <= data(7 downto 4);
    dest <= data(11 downto 8);
    instr <= data;    
  end process spread;

end behaviour;
