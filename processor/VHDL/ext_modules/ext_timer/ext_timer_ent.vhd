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
-- Title      : Timer Extension Module
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : ext_timer_ent.vhd
-- Author     : Martin Delvai
-- Company    : TU Wien - Institut fr technische Informatik
-- Created    : 2007-05-01
-- Last update: 2007-08-21
-- Platform   : Linux
-------------------------------------------------------------------------------
-- Description:
--
-------------------------------------------------------------------------------
-- Copyright (c) 2007 
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
USE work.pkg_basic.all;
use work.pkg_timer.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------


entity ext_timer is
  port(
    -- SCARTS Interface
    clk                     : IN  std_logic;
    extsel                  : in std_ulogic;
    exti                    : in  module_in_type;
    exto                    : out module_out_type
    -- Modul specific interface (= Pins) 
    );
end ext_timer;

----------------------------------------------------------------------------------
-- END ENTITY
----------------------------------------------------------------------------------


