



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	macro
-- File:	macro.vhd
-- Author:	Jiri Gaisler - ESA/ESTEC
-- Description:	some common macro functions
------------------------------------------------------------------------------
-- Version control:
-- 29-11-1997:	First implemetation
-- 26-09-1999:	Release 1.0
------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_target.all;
use work.leon_config.all;
use work.leon_iface.all;

package macro is

constant zero32 : std_Logic_vector(31 downto 0) := (others => '0');

function decode(v : std_logic_vector) return std_logic_vector;
function genmux(s,v : std_logic_vector) return std_logic;
function xorv(d : std_logic_vector) return std_logic;
function orv(d : std_logic_vector) return std_logic;

-- 3-way set permutations
-- s012 => set 0 - least recently used
--         set 2 - most recently used
constant s012 : std_logic_vector(2 downto 0) := "000";
constant s021 : std_logic_vector(2 downto 0) := "001";
constant s102 : std_logic_vector(2 downto 0) := "010";
constant s120 : std_logic_vector(2 downto 0) := "011";
constant s201 : std_logic_vector(2 downto 0) := "100";
constant s210 : std_logic_vector(2 downto 0) := "101";


-- 4-way set permutations
-- s0123 => set 0 - least recently used
--          set 3 - most recently used
constant s0123 : std_logic_vector(4 downto 0) := "00000";
constant s0132 : std_logic_vector(4 downto 0) := "00001";
constant s0213 : std_logic_vector(4 downto 0) := "00010";
constant s0231 : std_logic_vector(4 downto 0) := "00011";
constant s0312 : std_logic_vector(4 downto 0) := "00100";
constant s0321 : std_logic_vector(4 downto 0) := "00101";
constant s1023 : std_logic_vector(4 downto 0) := "00110";
constant s1032 : std_logic_vector(4 downto 0) := "00111";
constant s1203 : std_logic_vector(4 downto 0) := "01000";
constant s1230 : std_logic_vector(4 downto 0) := "01001";
constant s1302 : std_logic_vector(4 downto 0) := "01010";
constant s1320 : std_logic_vector(4 downto 0) := "01011";
constant s2013 : std_logic_vector(4 downto 0) := "01100";
constant s2031 : std_logic_vector(4 downto 0) := "01101";
constant s2103 : std_logic_vector(4 downto 0) := "01110";
constant s2130 : std_logic_vector(4 downto 0) := "01111";
constant s2301 : std_logic_vector(4 downto 0) := "10000";
constant s2310 : std_logic_vector(4 downto 0) := "10001";
constant s3012 : std_logic_vector(4 downto 0) := "10010";
constant s3021 : std_logic_vector(4 downto 0) := "10011";
constant s3102 : std_logic_vector(4 downto 0) := "10100";
constant s3120 : std_logic_vector(4 downto 0) := "10101";
constant s3201 : std_logic_vector(4 downto 0) := "10110";
constant s3210 : std_logic_vector(4 downto 0) := "10111";

type lru_3set_table_vector_type is array(0 to 2) of std_logic_vector(2 downto 0);
type lru_3set_table_type is array (0 to 7) of lru_3set_table_vector_type;

constant lru_3set_table : lru_3set_table_type :=
  ( (s120, s021, s012),                   -- s012
    (s210, s021, s012),                   -- s021
    (s120, s021, s102),                   -- s102
    (s120, s201, s102),                   -- s120
    (s210, s201, s012),                   -- s201
    (s210, s201, s102),                   -- s210
    (s210, s201, s102),                   -- dummy
    (s210, s201, s102)                    -- dummy
  );
  
type lru_4set_table_vector_type is array(0 to 3) of std_logic_vector(4 downto 0);
type lru_4set_table_type is array(0 to 31) of lru_4set_table_vector_type;

constant lru_4set_table : lru_4set_table_type :=
  ( (s1230, s0231, s0132, s0123),       -- s0123
    (s1320, s0321, s0132, s0123),       -- s0132
    (s2130, s0231, s0132, s0213),       -- s0213
    (s2310, s0231, s0312, s0213),       -- s0231
    (s3120, s0321, s0312, s0123),       -- s0312    
    (s3210, s0321, s0312, s0213),       -- s0321
    (s1230, s0231, s1032, s1023),       -- s1023
    (s1320, s0321, s1032, s1023),       -- s1032
    (s1230, s2031, s1032, s1203),       -- s1203
    (s1230, s2301, s1302, s1203),       -- s1230
    (s1320, s3021, s1302, s1023),       -- s1302
    (s1320, s3201, s1302, s1203),       -- s1320
    (s2130, s2031, s0132, s2013),       -- s2013
    (s2310, s2031, s0312, s2013),       -- s2031
    (s2130, s2031, s1032, s2103),       -- s2103
    (s2130, s2301, s1302, s2103),       -- s2130      
    (s2310, s2301, s3012, s2013),       -- s2301
    (s2310, s2301, s3102, s2103),       -- s2310
    (s3120, s3021, s3012, s0123),       -- s3012
    (s3210, s3021, s3012, s0213),       -- s3021
    (s3120, s3021, s3102, s1023),       -- s3102
    (s3120, s3201, s3102, s1203),       -- s3120
    (s3210, s3201, s3012, s2013),       -- s3201
    (s3210, s3201, s3102, s2103),       -- s3210
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103),        -- dummy
    (s3210, s3201, s3102, s2103)         -- dummy
  );

type lru3_repl_table_single_type is array(0 to 2) of integer range 0 to 2;
type lru3_repl_table_type is array(0 to 7) of lru3_repl_table_single_type;

constant lru3_repl_table : lru3_repl_table_type :=
  ( (0, 1, 2),      -- s012
    (0, 2, 2),      -- s021
    (1, 1, 2),      -- s102
    (1, 1, 2),      -- s120
    (2, 2, 2),      -- s201
    (2, 2, 2),      -- s210
    (2, 2, 2),      -- dummy
    (2, 2, 2)       -- dummy
  );

type lru4_repl_table_single_type is array(0 to 3) of integer range 0 to 3;
type lru4_repl_table_type is array(0 to 31) of lru4_repl_table_single_type;

constant lru4_repl_table : lru4_repl_table_type :=
  ( (0, 1, 2, 3), -- s0123
    (0, 1, 3, 3), -- s0132
    (0, 2, 2, 3), -- s0213
    (0, 2, 2, 3), -- s0231
    (0, 3, 3, 3), -- s0312
    (0, 3, 3, 3), -- s0321
    (1, 1, 2, 3), -- s1023
    (1, 1, 3, 3), -- s1032
    (1, 1, 2, 3), -- s1203
    (1, 1, 2, 3), -- s1230
    (1, 1, 3, 3), -- s1302
    (1, 1, 3, 3), -- s1320
    (2, 2, 2, 3), -- s2013
    (2, 2, 2, 3), -- s2031
    (2, 2, 2, 3), -- s2103
    (2, 2, 2, 3), -- s2130
    (2, 2, 2, 3), -- s2301
    (2, 2, 2, 3), -- s2310
    (3, 3, 3, 3), -- s3012
    (3, 3, 3, 3), -- s3021
    (3, 3, 3, 3), -- s3102
    (3, 3, 3, 3), -- s3120
    (3, 3, 3, 3), -- s3201
    (3, 3, 3, 3), -- s3210
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0), -- dummy
    (0, 0, 0, 0)  -- dummy
  );

function is_cacheable(haddr : std_logic_vector(31 downto 24)) return std_logic;

end;

package body macro is

-- generic decoder

function decode(v : std_logic_vector) return std_logic_vector is
variable res : std_logic_vector((2**v'length)-1 downto 0); --'
variable i : natural;
begin
  res := (others => '0');
-- pragma translate_off
  i := 0;
  if not is_x(v) then
-- pragma translate_on
    i := conv_integer(unsigned(v));
    res(i) := '1';
-- pragma translate_off
  else
    res := (others => 'X');
  end if;
-- pragma translate_on
  return(res);
end;

-- generic multiplexer

function genmux(s,v : std_logic_vector) return std_logic is
variable res : std_logic_vector(v'length-1 downto 0); --'
variable i : integer;
begin
  res := v;
-- pragma translate_off
  i := 0;
  if not is_x(s) then
-- pragma translate_on
    i := conv_integer(unsigned(s));
-- pragma translate_off
  else
    res := (others => 'X');
  end if;
-- pragma translate_on
  return(res(i));
end;

-- vector XOR

function xorv(d : std_logic_vector) return std_logic is
variable tmp : std_logic;
begin
  tmp := '0';
  for i in d'range loop tmp := tmp xor d(i); end loop; --'
  return(tmp);
end;

-- vector OR

function orv(d : std_logic_vector) return std_logic is
variable tmp : std_logic;
begin
  tmp := '0';
  for i in d'range loop tmp := tmp or d(i); end loop; --'
  return(tmp);
end;


function is_cacheable(haddr : std_logic_vector(31 downto 24)) return std_logic is
variable hcache : std_logic;
begin
--  hcache := '0';
--  for i in PROC_CACHETABLE'range loop	--'
--    if (haddr(31 downto 32-PROC_CACHE_ADDR_MSB) >= PROC_CACHETABLE(i).firstaddr) and
--      (haddr(31 downto 32-PROC_CACHE_ADDR_MSB) < PROC_CACHETABLE(i).lastaddr) 
--    then hcache := '1';  end if;
--  end loop;
--  return(hcache);

  if (haddr(31) = '0') and (haddr(30 downto 29) /= "01") then hcache := '1';
  else hcache := '0'; end if;
  return(hcache);
end;


end;


