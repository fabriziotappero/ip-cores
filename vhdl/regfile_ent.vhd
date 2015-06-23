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
-- entity of the instruction-decode pipeline stage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use work.marca_pkg.all;

entity regfile is
  
  port (
    clock    : in  std_logic;
    reset    : in  std_logic;
    hold     : in  std_logic;
    rd1_addr : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    rd2_addr : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    rd1_val  : out std_logic_vector(REG_WIDTH-1 downto 0);
    rd2_val  : out std_logic_vector(REG_WIDTH-1 downto 0);
    wr_ena   : in  std_logic;
    wr_addr  : in  std_logic_vector(REG_COUNT_LOG-1 downto 0);
    wr_val   : in  std_logic_vector(REG_WIDTH-1 downto 0));

end regfile;
