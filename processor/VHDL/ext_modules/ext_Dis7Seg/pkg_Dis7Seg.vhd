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
-- Last update: 2011-03-20
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

use work.scarts_pkg.all;


-------------------------------------------------------------------------------
-- PACKAGE
-------------------------------------------------------------------------------

package pkg_dis7seg is

  type digit_t is record
    SegA   :  std_logic;
    SegB   :  std_logic;
    SegC   :  std_logic;
    SegD   :  std_logic;
    SegE   :  std_logic;
    SegF   :  std_logic;
    SegG   :  std_logic;
  end record;

  type digit_vector_t is array (natural range <>) of digit_t;
  
  component ext_Dis7Seg
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
  end component;


  function bin2digit (
    constant number : std_logic_vector(3 downto 0))
    return digit_t;


end pkg_dis7seg;



package body pkg_dis7seg is

  function bin2digit (
    constant number : std_logic_vector(3 downto 0))
    return digit_t is
    variable v : digit_t;
  begin

    case number is 
      when "0000" =>
        v.SegA   := '0';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '1';
      when "0001" =>
        v.SegA   := '1';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '1';
        v.SegE   := '1';
        v.SegF   := '1';
        v.SegG   := '1';
      when "0010" =>
        v.SegA   := '0';
        v.SegB   := '0';
        v.SegC   := '1';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '1';
        v.SegG   := '0';
      when "0011" =>
        v.SegA   := '0';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '1';
        v.SegF   := '1';
        v.SegG   := '0';
      when "0100" =>
        v.SegA   := '1';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '1';
        v.SegE   := '1';
        v.SegF   := '0';
        v.SegG   := '0';
      when "0101" =>
        v.SegA   := '0';
        v.SegB   := '1';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '1';
        v.SegF   := '0';
        v.SegG   := '0';
      when "0110" =>
        v.SegA   := '0';
        v.SegB   := '1';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '0';
      when "0111" =>
        v.SegA   := '0';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '1';
        v.SegE   := '1';
        v.SegF   := '1';
        v.SegG   := '1';
      when "1000" =>
        v.SegA   := '0';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '0';
      when "1001" =>
        v.SegA   := '0';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '1';
        v.SegF   := '0';
        v.SegG   := '0';
      when "1010" =>
        v.SegA   := '0';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '1';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '0';
      when "1011" =>
        v.SegA   := '1';
        v.SegB   := '1';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '0';
      when "1100" =>
        v.SegA   := '0';
        v.SegB   := '1';
        v.SegC   := '1';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '1';
      when "1101" =>
        v.SegA   := '1';
        v.SegB   := '0';
        v.SegC   := '0';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '1';
        v.SegG   := '0';
      when "1110" =>
        v.SegA   := '0';
        v.SegB   := '1';
        v.SegC   := '1';
        v.SegD   := '0';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '0';
      when "1111" =>
        v.SegA   := '0';
        v.SegB   := '1';
        v.SegC   := '1';
        v.SegD   := '1';
        v.SegE   := '0';
        v.SegF   := '0';
        v.SegG   := '0';
      when others =>
        v.SegA   := '1';
        v.SegB   := '1';
        v.SegC   := '1';
        v.SegD   := '1';
        v.SegE   := '1';
        v.SegF   := '1';
        v.SegG   := '0';
    end case;
    return v;
  end bin2digit;

end pkg_dis7seg;




-------------------------------------------------------------------------------
--                             END PACKAGE
------------------------------------------------------------------------------- 
