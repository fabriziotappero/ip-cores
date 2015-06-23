-- $Id: slvtypes.vhd 641 2015-02-01 22:12:15Z mueller $
--
-- Copyright 2007-2008 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Package Name:   slvtypes
-- Description:    Short names for std_logic types.
--                 This package simply defines short hands for the std_logic
--                 types. slbit and slv are just aliases for std_logic and
--                 std_logic_vector. slv<n> are subtype definitions for
--                 commonly used (n downto 0) vectors
--
-- Dependencies:   -
-- Tool versions:  ise 8.1-14.7; viv 2014.4; ghdl 0.18-0.31
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-08-24   162   1.0.4  add slv60 and 64
-- 2008-08-22   161   1.0.3  add slvnn_m subtypes from pdp11 package
-- 2008-03-24   129   1.0.2  add slv31
-- 2007-12-08   100   1.0.1  add slv1
-- 2007-06-02    44   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package slvtypes is

  subtype slbit is std_logic;                      -- bit
  subtype slv   is std_logic_vector;               -- vector

  subtype slv1  is std_logic_vector( 0 downto 0);  --  1 bit word
  subtype slv2  is std_logic_vector( 1 downto 0);  --  2 bit word
  subtype slv3  is std_logic_vector( 2 downto 0);  --  3 bit word
  subtype slv4  is std_logic_vector( 3 downto 0);  --  4 bit word
  subtype slv5  is std_logic_vector( 4 downto 0);  --  5 bit word
  subtype slv6  is std_logic_vector( 5 downto 0);  --  6 bit word
  subtype slv7  is std_logic_vector( 6 downto 0);  --  7 bit word
  subtype slv8  is std_logic_vector( 7 downto 0);  --  8 bit word
  subtype slv9  is std_logic_vector( 8 downto 0);  --  9 bit word
  subtype slv10 is std_logic_vector( 9 downto 0);  -- 10 bit word
  subtype slv11 is std_logic_vector(10 downto 0);  -- 11 bit word
  subtype slv12 is std_logic_vector(11 downto 0);  -- 12 bit word
  subtype slv13 is std_logic_vector(12 downto 0);  -- 13 bit word
  subtype slv14 is std_logic_vector(13 downto 0);  -- 14 bit word
  subtype slv15 is std_logic_vector(14 downto 0);  -- 15 bit word
  subtype slv16 is std_logic_vector(15 downto 0);  -- 16 bit word

  subtype slv17 is std_logic_vector(16 downto 0);  -- 17 bit word
  subtype slv18 is std_logic_vector(17 downto 0);  -- 18 bit word
  subtype slv19 is std_logic_vector(18 downto 0);  -- 19 bit word
  subtype slv20 is std_logic_vector(19 downto 0);  -- 20 bit word
  subtype slv21 is std_logic_vector(20 downto 0);  -- 21 bit word
  subtype slv22 is std_logic_vector(21 downto 0);  -- 22 bit word
  subtype slv23 is std_logic_vector(22 downto 0);  -- 23 bit word
  subtype slv24 is std_logic_vector(23 downto 0);  -- 24 bit word
  subtype slv31 is std_logic_vector(30 downto 0);  -- 31 bit word
  subtype slv32 is std_logic_vector(31 downto 0);  -- 32 bit word

  subtype slv60 is std_logic_vector(59 downto 0);  -- 59 bit word
  subtype slv64 is std_logic_vector(63 downto 0);  -- 63 bit word

  subtype slv8_1  is std_logic_vector(7 downto 1);   --  8 bit word, 1 lsb drop
  subtype slv9_2  is std_logic_vector(8 downto 2);   --  9 bit word, 2 lsb drop
  subtype slv13_1 is std_logic_vector(12 downto 1);  -- 13 bit word, 1 lsb drop
  subtype slv16_1 is std_logic_vector(15 downto 1);  -- 16 bit word, 1 lsb drop
  subtype slv18_1 is std_logic_vector(17 downto 1);  -- 18 bit word, 1 lsb drop
  subtype slv22_1 is std_logic_vector(21 downto 1);  -- 22 bit word, 1 lsb drop

end package slvtypes;
