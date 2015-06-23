-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Title      : 7 Segment Display Architecture
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_sysctrl_ent.vhd
-- Author     : Dipl. Ing. Martin Delvai
-- Company    : TU Wien - Institut fr technische Informatik
-- Created    : 2002-02-11
-- Last update: 2011-03-20
-- Platform   : SUN Solaris 
-------------------------------------------------------------------------------
-- Description:
--
-------------------------------------------------------------------------------
-- Copyright (c) 2002 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-02-11  1.0      delvai	Created
-------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- LIBRARY
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.scarts_pkg.all;

use work.pkg_dis7seg.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------

entity ext_Dis7Seg is
  generic (
    DIGIT_COUNT : integer range 1 to 8;
    MULTIPLEXED : integer range 0 to 1);
  port (
    clk        : IN  std_logic;
    extsel     : in   std_ulogic;
    exti       : in  module_in_type;
    exto       : out module_out_type;
    digits     : out digit_vector_t((DIGIT_COUNT-1) * (1-MULTIPLEXED) downto 0);
    DisEna     : OUT std_logic;
    PIN_select : OUT std_logic_vector(DIGIT_COUNT-1 downto 0));
end entity ext_Dis7Seg;

----------------------------------------------------------------------------------
-- END ENTITY
----------------------------------------------------------------------------------


