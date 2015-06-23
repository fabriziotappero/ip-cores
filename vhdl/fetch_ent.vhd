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
-- entity definition for the instruction-fetch pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use work.marca_pkg.all;

entity fetch is
  
  port (
    clock   : in  std_logic;
    reset   : in  std_logic;

    hold    : in  std_logic;
    
    pcena   : in  std_logic;
    pc_in   : in  std_logic_vector(REG_WIDTH-1 downto 0);
    pc_out  : out std_logic_vector(REG_WIDTH-1 downto 0);

    src1    : out std_logic_vector(REG_COUNT_LOG-1 downto 0);
    src2    : out std_logic_vector(REG_COUNT_LOG-1 downto 0);
    dest    : out std_logic_vector(REG_COUNT_LOG-1 downto 0);
    instr   : out std_logic_vector(PDATA_WIDTH-1 downto 0));

end fetch;
