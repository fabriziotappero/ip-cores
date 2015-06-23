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
-- entity of a bit-serial divider
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use work.marca_pkg.all;

entity divider is
  
  generic (
    width : integer := REG_WIDTH);

  port (
    clock    : in  std_logic;
    reset    : in  std_logic;
    trigger  : in  std_logic;
    denom    : in  std_logic_vector(width-1 downto 0);
    numer    : in  std_logic_vector(width-1 downto 0);
    exc      : out std_logic;
    busy     : out std_logic;
    quotient : out std_logic_vector(width-1 downto 0);
    remain   : out std_logic_vector(width-1 downto 0));

end divider;
