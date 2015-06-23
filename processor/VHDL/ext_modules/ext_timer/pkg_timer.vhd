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
-- Last update: 2007-08-21
-- Platform   : SUN Solaris
-------------------------------------------------------------------------------
-- Description:
-- Deklarationen und Konstanten r die 7 Segment Anzeige
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

package pkg_timer is


-------------------------------------------------------------------------------
--                             CONSTANT
-------------------------------------------------------------------------------  

constant STATUS_C : integer := 1;
constant IINT  : integer := 4;
constant CINT  : integer := 0;
constant CONFIG_C : integer := 3;
constant START_I  : integer := 7;
constant STOP_I  : integer := 6;
constant MCC  : integer := 5;
constant IMI  : integer := 4;
constant START_C  : integer := 3;
constant STOP_C  : integer := 2;
constant MCI  : integer := 1;
constant CMI  : integer := 0;

constant CLK_CNT_0 : integer := 4;
constant CLK_CNT_1 : integer := 5;
constant CLK_CNT_2 : integer := 6;
constant CLK_CNT_3 : integer := 7;

constant CLK_MATCH_0 : integer := 8;
constant CLK_MATCH_1 : integer := 9;
constant CLK_MATCH_2 : integer := 10;
constant CLK_MATCH_3 : integer := 11 ;

constant INST_CNT_0 : integer := 12;
constant INST_CNT_1 : integer := 13;
constant INST_CNT_2 : integer := 14;
constant INST_CNT_3 : integer := 15;

constant INST_MATCH_0 : integer := 16;
constant INST_MATCH_1 : integer := 17;
constant INST_MATCH_2 : integer := 18;
constant INST_MATCH_3 : integer := 19 ;

 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                             COMPONENT
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  component ext_timer 
    port (
      clk     : IN  std_logic;
      extsel  : in  std_ulogic;
      exti    : in  module_in_type;
      exto    : out module_out_type
      );
  end component;
  

end pkg_timer;
-------------------------------------------------------------------------------
--                             END PACKAGE
------------------------------------------------------------------------------- 
