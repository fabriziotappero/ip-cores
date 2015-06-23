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
-- Title      : Extension Module: miniUART
-- Project    : HW/SW-Codesign
-------------------------------------------------------------------------------
-- File       : ext_miniUART_ent.vhd
-- Author     : Delvai Martin 
-- Company    : TU Wien - Institut für Technische Informatik
-- Created    : 2005-03-10
-- Last update: 2007-05-02
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LIBRARY
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.pkg_basic.all;

----------------------------------------------------------------------------------
-- ENTITY
----------------------------------------------------------------------------------
ENTITY ext_miniUART IS
        --pragma template
 -- generic (
 --   GWORD_CFG   : integer := 1);
--          MINIUART_BASE : integer := 51;
--          MINIUART_INT  : integer := 9);
  
 	PORT(   ---------------------------------------------------------------
                -- Generic Ports
                ---------------------------------------------------------------
                clk           : IN  std_logic; 	
                extsel        : in  std_logic;
                exti          : in  module_in_type;
                exto          : out module_out_type;
                ---------------------------------------------------------------
                -- Module Specific Ports
                ---------------------------------------------------------------
                RxD           : IN std_logic;  -- Empfangsleitung
                TxD           : OUT std_logic 
                );
END ext_miniUART;

----------------------------------------------------------------------------------
-- END ENTITY
----------------------------------------------------------------------------------

