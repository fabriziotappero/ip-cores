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
-- Package SC
-------------------------------------------------------------------------------
-- definitions for the SimpCon interface
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Wolfgang Puffitsch
-- Computer Architecture Lab, Group 3
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.marca_pkg.all;

package sc_pkg is

  -----------------------------------------------------------------------------
  -- general configuration
  -----------------------------------------------------------------------------
  constant SC_ADDR_WIDTH : integer := 2;
  constant SC_REG_WIDTH  : integer := 16;

  -----------------------------------------------------------------------------
  -- where to access SimCon modules
  -----------------------------------------------------------------------------
  constant SC_MIN_ADDR   : std_logic_vector := "1111111111111000";
  constant SC_MAX_ADDR   : std_logic_vector := "1111111111111111";
  
  -----------------------------------------------------------------------------
  -- records for simpler interfacing
  -----------------------------------------------------------------------------
  type SC_IN is record
                  address : std_logic_vector(SC_ADDR_WIDTH-1 downto 0);
                  wr      : std_logic;
                  wr_data : std_logic_vector(SC_REG_WIDTH-1 downto 0);
                  rd      : std_logic;
                end record;

  constant SC_IN_NULL : SC_IN := ((others => '0'), '0', (others => '0'), '0');
  
  type SC_OUT is record
                   rd_data : std_logic_vector(SC_REG_WIDTH-1 downto 0);
                   rdy_cnt : unsigned(1 downto 0);
                 end record;

  constant SC_OUT_NULL : SC_OUT := ((others => '0'), "00");

  -----------------------------------------------------------------------------
  -- output bits
  -----------------------------------------------------------------------------
  constant UART_TXD  : integer := 0;
  constant UART_NRTS : integer := 1;

  -----------------------------------------------------------------------------
  -- input bits
  -----------------------------------------------------------------------------
  constant UART_RXD  : integer := 0;
  constant UART_NCTS : integer := 1;

  -----------------------------------------------------------------------------
  -- interrupt numbers, >= 3
  -----------------------------------------------------------------------------
  constant UART_INTR : integer := 3;
  
  -----------------------------------------------------------------------------
  -- UART configuration
  -----------------------------------------------------------------------------
  constant UART_BASE_ADDR : std_logic_vector(REG_WIDTH-1 downto SC_ADDR_WIDTH+1) := "1111111111111";
  constant UART_BAUD_RATE : integer := 115200;
  
end sc_pkg;
