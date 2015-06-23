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
-- Last update: 2011-03-17
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
use work.scarts_conf.all;
use work.pkg_scarts.all;



-------------------------------------------------------------------------------
-- PACKAGE
-------------------------------------------------------------------------------

package pkg_breakpoint is


-------------------------------------------------------------------------------
--                             CONSTANT
-------------------------------------------------------------------------------  



 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                             COMPONENT
-------------------------------------------------------------------------------  
-------------------------------------------------------------------------------

  component ext_breakpoint
    generic (
      CONF : scarts_conf_type);
    port (
      clk              : IN  std_logic;
      extsel           : in  std_ulogic;
      exti             : in  module_in_type;
      exto             : out module_out_type;
      -- Modul specific interface (= Pins)
      debugo_wdata     : in  INSTR;
      debugo_waddr     : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
      debugo_wen       : in  std_ulogic;
      debugo_raddr     : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
      debugo_rdata     : in  INSTR;
      debugo_read_en   : in  std_ulogic;    
      debugo_hi_addr   : in  std_logic_vector(CONF.word_size-1 downto 15);   
      debugi_rdata     : out INSTR;   
      watchpoint_act   : in std_ulogic);
    end component;
  

end pkg_breakpoint;
-------------------------------------------------------------------------------
--                             END PACKAGE
------------------------------------------------------------------------------- 
