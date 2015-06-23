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
-- Title      : Package Extension-Module
-- Project    : SCARTS - Scalable Processor for Embedded Applications in
--              Realtime Environment
-------------------------------------------------------------------------------
-- File       : pkg_display.vhd
-- Author     : Dipl. Ing. Martin Delvai
-- Company    : TU Wien - Institut fr Technische Informatik
-- Created    : 2002-02-11
-- Last update: 2009-04-29
-- Platform   : SUN Solaris
-------------------------------------------------------------------------------
-- Description:
-- Package for counter module
-------------------------------------------------------------------------------
-- Copyright (c) 2002 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2002-02-11  1.0      delvai	Created
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- LIBRARIES
-------------------------------------------------------------------------------

LIBRARY IEEE;
use IEEE.std_logic_1164.all;

use work.pkg_basic.all;


-------------------------------------------------------------------------------
-- PACKAGE
-------------------------------------------------------------------------------

package pkg_counter is


-------------------------------------------------------------------------------
--                             CONSTANT
-------------------------------------------------------------------------------  

constant MY_CONFIGREG : natural := 3;
constant CMD_COUNT : natural := 0;
constant CMD_CLEAR : natural := 1;

 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                             COMPONENT
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------
    component ext_counter
      port (
        clk        : IN  std_logic;
        extsel     : in   std_ulogic;
        exti       : in  module_in_type;
        exto       : out module_out_type);
    end component;
  
   


end pkg_counter;
-------------------------------------------------------------------------------
--                             END PACKAGE
------------------------------------------------------------------------------- 
