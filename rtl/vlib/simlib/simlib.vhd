-- $Id: simlib.vhd 599 2014-10-25 13:43:56Z mueller $
--
-- Copyright 2006-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    simlib - sim
-- Description:    Support routines for test benches
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.31
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2014-10-25   599   2.1.1  add wait_* procedures; writeoptint: no dat clear
-- 2014-10-18   597   2.1    add simfifo_*, writetrace procedures
-- 2014-09-06   591   2.0.1  add readint_ea() with range check
-- 2011-12-23   444   2.0    drop CLK_CYCLE from simclk,simclkv; use integer for
--                           simclkcnt(CLK_CYCLE),writetimestamp(clkcyc);
-- 2011-11-18   427   1.3.8  now numeric_std clean
-- 2010-12-22   346   1.3.7  rename readcommand -> readdotcomm
-- 2010-11-13   338   1.3.6  add simclkcnt; xx.x ns time in writetimestamp()
-- 2008-03-24   129   1.3.5  CLK_CYCLE now 31 bits
-- 2008-03-02   121   1.3.4  added readempty (to discard rest of line)
-- 2007-12-27   106   1.3.3  added simclk2v
-- 2007-12-15   101   1.3.2  add read_ea(time), readtagval[_ea](std_logic)
-- 2007-10-12    88   1.3.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-28    76   1.3    added writehex and writegen
-- 2007-08-10    72   1.2.2  remove entity simclk, put into separate source
-- 2007-08-03    71   1.2.1  readgen, readtagval, readtagval2: add base arg
-- 2007-07-29    70   1.2    readtagval2: add tag=- support; add readword_ea,
--                           readoptchar, writetimestamp
-- 2007-07-28    69   1.1.1  rename readrest -> testempty; add readgen
--                           use readgen in readtagval() and readtagval2()
-- 2007-07-22    68   1.1    add readrest, readtagval, readtagval2
-- 2007-06-30    62   1.0.1  remove clock_period ect constant defs
-- 2007-06-14    56   1.0    Initial version (renamed from pdp11_sim.vhd)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;

package simlib is

constant null_char : character := character'val(0);            -- '\0'
constant null_string : string(1 to 1) := (others=>null_char);  -- "\0"
  
procedure readwhite(                    -- read over white space
  L: inout line);                       -- line

procedure readoct(                      -- read slv in octal base (arb. length)
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean);                   -- success flag

procedure readhex(                      -- read slv in hex base (arb. length)
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean);                   -- success flag

procedure readgen(                      -- read slv generic base
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean;                    -- success flag
  base: in integer:= 2);                -- default base

procedure readcomment(
  L: inout line;
  good: out boolean);

procedure readdotcomm(
  L: inout line;
  name: out string;
  good: out boolean);

procedure readword(
  L: inout line;
  name: out string;
  good: out boolean);

procedure readoptchar(
  L: inout line;
  char: in character;
  good: out boolean);

procedure readempty(
  L: inout line);

procedure testempty(
  L: inout line;
  good: out boolean);

procedure testempty_ea(
  L: inout line);

procedure read_ea(
  L: inout line;
  value: out integer);
procedure read_ea(
  L: inout line;
  value: out time);

procedure readint_ea(
  L: inout line;
  value: out integer;
  imin : in integer := integer'low;
  imax : in integer := integer'high);

procedure read_ea(
  L: inout line;
  value: out std_logic);
procedure read_ea(
  L: inout line;
  value: out std_logic_vector);

procedure readoct_ea(
  L: inout line;
  value: out std_logic_vector);

procedure readhex_ea(
  L: inout line;
  value: out std_logic_vector);

procedure readgen_ea(
  L: inout line;
  value: out std_logic_vector;
  base: in integer:= 2);

procedure readword_ea(
  L: inout line;
  name: out string);

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2);
procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  base: in integer:= 2);

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic;
  good: out boolean);
procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic);

procedure readtagval2(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2);
procedure readtagval2_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  base: in integer:= 2);

procedure writeoct(                     -- write slv in octal base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0);                  -- field width

procedure writehex(                     -- write slv in hex base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0);                  -- field width

procedure writegen(                     -- write slv in generic base (arb. lth)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0;                   -- field width
  base: in integer:= 2);                -- default base

procedure writetimestamp(               -- write time stamp
  L: inout line;                        -- line
  str : in string := null_string);      -- 1st string field

procedure writetimestamp(               -- write time stamp w/ clk cycle
  L: inout line;                        -- line
  clkcyc: in integer;                   -- cycle number
  str : in string := null_string);      -- 1st string field

procedure writeoptint(                  -- write int if > 0
  L: inout line;                        -- line
  str : in string;                      -- string
  dat : in integer;                     -- int value
  field: in width:=0);                  -- field width

procedure writetrace(                   -- debug trace - plain
  str : in string);                     -- string
procedure writetrace(                   -- debug trace - int
  str : in string;                      -- string
  dat : in integer);                    -- value
procedure writetrace(                   -- debug trace - slbit
  str : in string;                      -- string
  dat : in slbit);                      -- value
procedure writetrace(                   -- debug trace - slv
  str : in string;                      -- string
  dat : in slv);                        -- value
  
type clock_dsc is record                -- clock descriptor
  period : time;                        -- clock period
  hold   : time;                        -- hold time  = clock yo stim time
  setup  : time;                        -- setup time = moni to clock time
end record;

procedure wait_nextstim(                -- wait for next stim time
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc;      -- clock descriptor
  constant cnt : in positive := 1);     -- number of cycles to wait

procedure wait_nextmoni(                -- wait for next moni time
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc;      -- clock descriptor
  constant cnt : in positive := 1);     -- number of cycles to wait

procedure wait_stim2moni(               -- wait from stim to moni time
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc);     -- clock descriptor

procedure wait_untilsignal(             -- wait until signal
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc;      -- clock descriptor
  signal sig : in slbit;                -- signal
  constant val : in slbit;              -- value
  variable cnt : out natural);          -- cycle count

type simfifo_type is array (natural range <>, natural range<>) of std_logic;

procedure simfifo_put(                  -- add item to simfifo
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  din : in std_logic_vector;            -- element to add
  val : in slbit := '1');               -- valid flag

procedure simfifo_get(                  -- get item from simfifo
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  dout: out std_logic_vector);          -- element retrieved

procedure simfifo_writetest(            -- test value against simfifo and write
  L: inout line;                        -- line
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  dat : in std_logic_vector);           -- data to test

procedure simfifo_dump(                 -- dump simfifo
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  str : in string := null_string);      -- header text

-- ----------------------------------------------------------------------------

component simclk is                   -- test bench clock generator
  generic (
    PERIOD : time := 20 ns;           -- clock period
    OFFSET : time := 200 ns);         -- clock offset (first up transition)
  port (
    CLK  : out slbit;                 -- clock
    CLK_STOP : in slbit               -- clock stop trigger
  );
end component;

component simclkv is                  -- test bench clock generator
                                      --  with variable periods
  port (
    CLK  : out slbit;                 -- clock
    CLK_PERIOD : in time;             -- clock period
    CLK_HOLD : in slbit;              -- if 1, hold clocks in 0 state
    CLK_STOP : in slbit               -- clock stop trigger
  );
end component;

component simclkcnt is                -- test bench system clock cycle counter
  port (
    CLK  : in slbit;                  -- clock
    CLK_CYCLE  : out integer          -- clock cycle number
  );
end component;

end package simlib;

-- ----------------------------------------------------------------------------

package body simlib is

procedure readwhite(                  -- read over white space
  L: inout line) is                   -- line
  variable ch : character;
begin
  while L'length>0 loop
    ch := L(L'left);
    exit when (ch/=' ' and ch/=HT);
    read(L,ch);
  end loop;
  
end procedure readwhite;
  
-- -------------------------------------

procedure readoct(                      -- read slv in octal base (arb. length)
  L: inout line;                        -- line 
  value: out std_logic_vector;          -- value to be read
  good: out boolean) is                 -- success flag
  
  variable nibble : std_logic_vector(2 downto 0);
  variable sum : std_logic_vector(31 downto 0);
  variable ndig : integer;              -- number of digits
  variable ok : boolean;
  variable ichar : character;
  
begin
  
  assert not value'ascending(1)
    report "readoct called with ascending range"
    severity failure;
  assert value'length<=32
    report "readoct called with value'length > 32"
    severity failure; 
  
  readwhite(L);
  
  ndig := 0;
  sum := (others=>'U');
  
  while L'length>0 loop
    ok := true;
    case L(L'left) is
      when '0' => nibble := "000";
      when '1' => nibble := "001";
      when '2' => nibble := "010";
      when '3' => nibble := "011";
      when '4' => nibble := "100";
      when '5' => nibble := "101";
      when '6' => nibble := "110";
      when '7' => nibble := "111";
      when 'u'|'U' => nibble := "UUU";
      when 'x'|'X' => nibble := "XXX";
      when 'z'|'Z' => nibble := "ZZZ";
      when '-' => nibble := "---";
      when others => ok := false;
    end case;
    
    exit when not ok;
    read(L,ichar);
    ndig := ndig + 1;
    sum(sum'left downto 3) := sum(sum'left-3 downto 0);
    sum(2 downto 0) := nibble;
  end loop;
  
  ok := ndig>0;
  value := sum(value'range);
  good := ok;
  
end procedure readoct;

-- -------------------------------------

procedure readhex(                      -- read slv in hex base (arb. length)
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean) is                 -- success flag
  
  variable nibble : std_logic_vector(3 downto 0);
  variable sum : std_logic_vector(31 downto 0);
  variable ndig : integer;              -- number of digits
  variable ok : boolean;
  variable ichar : character;
  
begin
  
  assert not value'ascending(1)
    report "readhex called with ascending range"
    severity failure;
  assert value'length<=32
    report "readhex called with value'length > 32"
    severity failure; 
    
  readwhite(L);
  
  ndig := 0;
  sum := (others=>'U');
  
  while L'length>0 loop
    ok := true;
    case L(L'left) is
      when '0'     => nibble := "0000";
      when '1'     => nibble := "0001";
      when '2'     => nibble := "0010";
      when '3'     => nibble := "0011";
      when '4'     => nibble := "0100";
      when '5'     => nibble := "0101";
      when '6'     => nibble := "0110";
      when '7'     => nibble := "0111";
      when '8'     => nibble := "1000";
      when '9'     => nibble := "1001";
      when 'a'|'A' => nibble := "1010";
      when 'b'|'B' => nibble := "1011";
      when 'c'|'C' => nibble := "1100";
      when 'd'|'D' => nibble := "1101";
      when 'e'|'E' => nibble := "1110";
      when 'f'|'F' => nibble := "1111";
      when 'u'|'U' => nibble := "UUUU";
      when 'x'|'X' => nibble := "XXXX";
      when 'z'|'Z' => nibble := "ZZZZ";
      when '-'     => nibble := "----";
      when others  => ok := false;
    end case;
    
    exit when not ok;
    read(L,ichar);
    ndig := ndig + 1;
    sum(sum'left downto 4) := sum(sum'left-4 downto 0);
    sum(3 downto 0) := nibble;
  end loop;
  
  ok := ndig>0;
  value := sum(value'range);
  good := ok;
  
end procedure readhex;

-- -------------------------------------

procedure readgen(                    -- read slv generic base
  L: inout line;                      -- line
  value: out std_logic_vector;        -- value to be read
  good: out boolean;                  -- success flag
  base: in integer := 2) is           -- default base
  
  variable nibble : std_logic_vector(3 downto 0);
  variable sum : std_logic_vector(31 downto 0);
  variable lbase : integer;           -- local base
  variable cbase : integer;           -- current base
  variable ok : boolean;
  variable ivalue : integer;
  variable ichar : character;

begin
  
  assert not value'ascending(1)
    report "readgen called with ascending range"
    severity failure;
  assert value'length<=32
    report "readgen called with value'length > 32"
    severity failure;
  assert base=2 or base=8 or base=10 or base=16
    report "readgen base not 2,8,10, or 16"
    severity failure;
    
  readwhite(L);
  
  cbase := base;
  lbase := 0;
  ok := true;
  
  if L'length >= 2 then
    if L(L'left+1) = '"' then
      case L(L'left) is
        when 'b'|'B' => lbase :=  2;
        when 'o'|'O' => lbase :=  8;
        when 'd'|'D' => lbase := 10;
        when 'x'|'X' => lbase := 16;
        when others => ok := false;
      end case;
    end if;
    if lbase /= 0 then
      read(L, ichar);
      read(L, ichar);
      cbase := lbase;
    end if;
  end if;

  if ok then
    case cbase is
      when  2 => read(L, value, ok);
      when  8 => readoct(L, value, ok);
      when 16 => readhex(L, value, ok);
      when 10 =>
        read(L, ivalue, ok);
        -- the following if allows to enter negative integers, e.g. -1 for all-1
        if ivalue >= 0 then
          value := slv(to_unsigned(ivalue, value'length));
        else
          value := slv(to_signed(ivalue, value'length));
        end if;
      when others => null;
    end case;
  end if;
  
  if ok and lbase/=0 then
    if L'length>0 and  L(L'left)='"' then
      read(L, ichar);
    else
      ok := false;
    end if;
  end if;

  good := ok;
    
end procedure readgen;

-- -------------------------------------
  
procedure readcomment(
  L: inout line;
  good: out boolean) is
  variable ichar : character;
begin
  
  readwhite(L);
  
  good := true;
  if L'length > 0 then
    good := false;
    if L(L'left) = '#' then
      good := true;
    elsif L(L'left) = 'C' then
      good := true;
      writeline(output, L);
    end if;
  end if;
  
end procedure readcomment;

-- -------------------------------------
  
procedure readdotcomm(
  L: inout line;
  name: out string;
  good: out boolean) is
begin

  for i in name'range loop
    name(i) := ' ';
  end loop;
  good := false;
  
  if L'length>0 and L(L'left)='.' then
    readword(L, name, good);
  end if;
  
end procedure readdotcomm;
  
-- -------------------------------------
  
procedure readword(
  L: inout line;
  name: out string;
  good: out boolean) is

  variable ichar : character;
  variable ind : integer;

begin

  assert name'ascending(1)
    report "readword called with descending range for name"
    severity failure;

  readwhite(L);
  
  for i in name'range loop
    name(i) := ' ';
  end loop;
  ind := name'left;
  
  while L'length>0 and ind<=name'right loop
    ichar := L(L'left);
    exit when ichar=' ' or ichar=',' or ichar='|';
    read(L,ichar);
    name(ind) := ichar;
    ind := ind + 1;
  end loop;

  good := ind /= name'left;             -- ok if one non-blank found
  
end procedure readword;

-- -------------------------------------

procedure readoptchar(
  L: inout line;
  char: in character;
  good: out boolean) is

  variable ichar : character;

begin

  good := false;
  if L'length > 0 then
    if L(L'left) = char then
      read(L, ichar);
      good := true;
    end if;
  end if;
  
end procedure readoptchar;

-- -------------------------------------
  
procedure readempty(
  L: inout line) is

  variable ch : character;

begin

  while L'length>0 loop               -- anything left ?
    read(L,ch);                         -- read and discard it
  end loop;
  
end procedure readempty;

-- -------------------------------------
  
procedure testempty(
  L: inout line;
  good: out boolean) is

begin

  readwhite(L);                       -- discard white space
  good := true;                       -- good if now empty
  
  if L'length > 0 then                -- anything left ?
    good := false;                    -- assume bad
    if L'length >= 2 and              -- check for "--"
      L(L'left)='-' and L(L'left+1)='-' then
      good := true;                   -- in that case comment -> good
    end if;
  end if;
  
end procedure testempty;

-- -------------------------------------

procedure testempty_ea(
  L: inout line) is

  variable ok : boolean := false;

begin

  testempty(L, ok);
  assert ok report "extra chars in """ & L.all & """" severity failure;
  
end procedure testempty_ea;

-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out integer) is

  variable ok : boolean := false;

begin
  
  read(L, value, ok);
  assert ok report "read(integer) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;

-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out time) is

  variable ok : boolean := false;

begin
  
  read(L, value, ok);
  assert ok report "read(time) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;

-- -------------------------------------

procedure readint_ea(
  L: inout line;
  value: out integer;
  imin : in integer := integer'low;
  imax : in integer := integer'high) is

  variable dat : integer := 0;
  
begin
  
  read_ea(L, dat);
  assert dat>=imin and dat<=imax
    report "readint_ea range check: " &
            integer'image(dat) & " not in " &
            integer'image(imin) & ":" & integer'image(imax)
    severity failure;
  value := dat;
end procedure readint_ea;

-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out std_logic) is

  variable ok : boolean := false;

begin
  
  read(L, value, ok);
  assert ok report "read(std_logic) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;
  
-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out std_logic_vector) is

  variable ok : boolean := false;

begin
    
  read(L, value, ok);
  assert ok report "read(std_logic_vector) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;
  
-- -------------------------------------

procedure readoct_ea(
  L: inout line;
  value: out std_logic_vector) is

  variable ok : boolean := false;

begin
  
  readoct(L, value, ok);
  assert ok report "readoct() conversion error in """ &
                   L.all & """" severity failure;
  
end procedure readoct_ea;
  
-- -------------------------------------

procedure readhex_ea(
  L: inout line;
  value: out std_logic_vector) is

  variable ok : boolean := false;

begin
  
  readhex(L, value, ok);
  assert ok report "readhex() conversion error in """ &
                   L.all & """" severity failure;
  
end procedure readhex_ea;
  
-- -------------------------------------

procedure readgen_ea(
  L: inout line;
  value: out std_logic_vector;
  base: in integer := 2) is

  variable ok : boolean := false;

begin
  
  readgen(L, value, ok, base);
  assert ok report "readgen() conversion error in """ &
                   L.all & """" severity failure;
  
end procedure readgen_ea;

-- -------------------------------------

procedure readword_ea(
  L: inout line;
  name: out string) is

  variable ok : boolean := false;

begin
    
  readword(L, name, ok);
  assert ok report "readword() read error in """ &
                   L.all & """" severity failure;
  
end procedure readword_ea;
  
-- -------------------------------------

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2) is
  
  variable itag : string(tag'range);
  variable ichar : character;
  variable imatch : boolean;
  
begin
  
  readwhite(L);
  
  for i in val'range loop
    val(i) := '0';
  end loop;
  good := true;
  imatch := false;
  
  if L'length > tag'length then
    imatch := L(L'left to L'left+tag'length-1) = tag and
              L(L'left+tag'length) = '=';
    if imatch then
      read(L, itag);
      read(L, ichar);
      readgen(L, val, good, base);
    end if;
  end if;
  match := imatch;
  
end procedure readtagval;

-- -------------------------------------

procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  base: in integer:= 2) is

  variable ok : boolean := false;

begin
  readtagval(L, tag, match, val, ok, base);
  assert ok report "readtagval(std_logic_vector) conversion error in """ &
                   L.all & """" severity failure;
end procedure readtagval_ea;
    
-- -------------------------------------

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic;
  good: out boolean) is
  
  variable itag : string(tag'range);
  variable ichar : character;
  variable imatch : boolean;
  
begin
  
  readwhite(L);
  
  val := '0';
  good := true;
  imatch := false;
  
  if L'length > tag'length then
    imatch := L(L'left to L'left+tag'length-1) = tag and
              L(L'left+tag'length) = '=';
    if imatch then
      read(L, itag);
      read(L, ichar);
      read(L, val, good);
    end if;
  end if;
  match := imatch;
  
end procedure readtagval;

-- -------------------------------------

procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic) is

  variable ok : boolean := false;

begin
  readtagval(L, tag, match, val, ok);
  assert ok report "readtagval(std_logic) conversion error in """ &
                   L.all & """" severity failure;
end procedure readtagval_ea;
    
-- -------------------------------------

procedure readtagval2(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2) is
  
  variable itag : string(tag'range);
  variable imatch : boolean;
  variable igood : boolean;
  variable ichar : character;
  variable ok : boolean;
  
begin

  readwhite(L);

  for i in val1'range loop            -- zero val1
    val1(i) := '0';
  end loop;
  for i in val2'range loop            -- zero val2
    val2(i) := '0';
  end loop;
  igood := true;
  imatch := false;
    
  if L'length > tag'length then       -- check for tag
    imatch := L(L'left to L'left+tag'length-1) = tag and
              L(L'left+tag'length) = '=';

    if imatch then                      -- if found
      read(L, itag);                    -- remove tag
      read(L, ichar);                   -- remove =
      
      igood := false;
      readoptchar(L, '-', ok);          -- check for tag=-
      if ok then
        for i in val2'range loop        -- set mask to all 1 (ignore)
          val2(i) := '1';
        end loop;
        igood := true;
      else                              -- here if tag=bit[,bit]
        readgen(L, val1, igood, base);  -- read val1
        if igood then
          readoptchar(L, ',', ok);      -- check(and remove) ,
          if ok then
            readgen(L, val2, igood, base); -- and read val2
          end if;
        end if;
      end if;
    end if;
  end if;
    
  match := imatch;
  good := igood;
  
end procedure readtagval2;

-- -------------------------------------

procedure readtagval2_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  base: in integer:= 2) is

  variable ok : boolean := false;

begin
  readtagval2(L, tag, match, val1, val2, ok, base);
  assert ok report "readtagval2() conversion error in """ &
                   L.all & """" severity failure;
end procedure readtagval2_ea;
    
-- -------------------------------------

procedure writeoct(                     -- write slv in octal base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0) is                -- field width
  
  variable nbit : integer;              -- number of bits
  variable ndig : integer;              -- number of digits
  variable iwidth : integer;
  variable ioffset : integer;
  variable nibble : std_logic_vector(2 downto 0);
  variable ochar : character;
  
begin
  
  assert not value'ascending(1)
    report "writeoct called with ascending range"
    severity failure;
  
  nbit := value'length(1);
  ndig := (nbit+2)/3;
  iwidth := nbit mod 3;
  if iwidth = 0 then
    iwidth := 3;
  end if;
  ioffset := value'left(1) - iwidth+1;
  if justified=right and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
  for i in 0 to ndig-1 loop
    nibble := "000";
    nibble(iwidth-1 downto 0) := value(ioffset+iwidth-1 downto ioffset);
    ochar := ' ';
    for i in nibble'range loop
      case nibble(i) is
        when 'U' => ochar := 'U';
        when 'X' => ochar := 'X';
        when 'Z' => ochar := 'Z';
        when '-' => ochar := '-';
        when others => null;
      end case;
    end loop;  -- i
    if ochar = ' ' then
      write(L,to_integer(unsigned(nibble)));
    else
      write(L,ochar);
    end if;
    iwidth := 3;
    ioffset := ioffset - 3;
  end loop;  -- i
  if justified=left and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
end procedure writeoct;

-- -------------------------------------

procedure writehex(                     -- write slv in hex base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0) is                -- field width
  
  variable nbit : integer;              -- number of bits
  variable ndig : integer;              -- number of digits
  variable iwidth : integer;
  variable ioffset : integer;
  variable nibble : std_logic_vector(3 downto 0);
  variable ochar : character;
  variable hextab : string(1 to 16) := "0123456789abcdef";
  
begin
  
  assert not value'ascending(1)
    report "writehex called with ascending range"
    severity failure;
  
  nbit := value'length(1);
  ndig := (nbit+3)/4;
  iwidth := nbit mod 4;
  if iwidth = 0 then
    iwidth := 4;
  end if;
  ioffset := value'left(1) - iwidth+1;
  if justified=right and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
  for i in 0 to ndig-1 loop
    nibble := "0000";
    nibble(iwidth-1 downto 0) := value(ioffset+iwidth-1 downto ioffset);
    ochar := ' ';
    for i in nibble'range loop
      case nibble(i) is
        when 'U' => ochar := 'U';
        when 'X' => ochar := 'X';
        when 'Z' => ochar := 'Z';
        when '-' => ochar := '-';
        when others => null;
      end case;
    end loop;  -- i
    if ochar = ' ' then
      write(L,hextab(to_integer(unsigned(nibble))+1));
    else
      write(L,ochar);
    end if;
    iwidth := 4;
    ioffset := ioffset - 4;
  end loop;  -- i
  if justified=left and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
end procedure writehex;

-- -------------------------------------

procedure writegen(                     -- write slv in generic base (arb. lth)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0;                   -- field width
  base: in integer:=2) is               -- default base

begin

  case base is
    when  2 => write(L, value, justified, field);
    when  8 => writeoct(L, value, justified, field);
    when 16 => writehex(L, value, justified, field);
    when others => report "writegen base not 2,8, or 16"
                     severity failure;
  end case;
  
end procedure writegen;

-- -------------------------------------

procedure writetimestamp(
  L: inout line;
  str : in string := null_string) is

  variable t_nsec  : integer := 0;
  variable t_psec  : integer := 0;
  variable t_dnsec : integer := 0;

begin

  t_nsec  := now / 1 ns;
  t_psec  := (now - t_nsec * 1 ns) / 1 ps;
  t_dnsec := t_psec/100;
  
  write(L, t_nsec, right, 8);
  write(L,'.');
  write(L, t_dnsec, right, 1);
  write(L, string'(" ns"));
  
  if str /= null_string then
    write(L, str);
  end if;

end procedure writetimestamp;

-- -------------------------------------

procedure writetimestamp(
  L: inout line;
  clkcyc: in integer;
  str: in string := null_string) is


begin

  writetimestamp(L);
  write(L, clkcyc, right, 7);
  if str /= null_string then
    write(L, str);
  end if;

end procedure writetimestamp;

-- -------------------------------------

procedure writeoptint(                  -- write int if > 0
  L: inout line;                        -- line
  str : in string;                      -- string
  dat : in integer;                     -- int value
  field: in width:=0) is                -- field width

begin

  if dat > 0 then
    write(L, str);
    write(L, dat, right, field);
  end if;

end procedure writeoptint;

-- -------------------------------------

procedure writetrace(                   -- debug trace - plain
  str: in string) is                    -- string

  variable oline : line;

begin

  writetimestamp(oline, " ++ ");
  write(oline, str);
  writeline(output, oline);

end procedure writetrace;

-- -------------------------------------

procedure writetrace(                   -- debug trace - int
  str: in string;                       -- string
  dat : in integer) is                  -- value

  variable oline : line;

begin

  writetimestamp(oline, " ++ ");
  write(oline, str);
  write(oline, dat);
  writeline(output, oline);

end procedure writetrace;

-- -------------------------------------

procedure writetrace(                   -- debug trace - slbit
  str: in string;                       -- string
  dat : in slbit) is                    -- value

  variable oline : line;

begin

  writetimestamp(oline, " ++ ");
  write(oline, str);
  write(oline, dat);
  writeline(output, oline);

end procedure writetrace;

-- -------------------------------------

procedure writetrace(                   -- debug trace - slv
  str: in string;                       -- string
  dat : in slv) is                      -- value

  variable oline : line;

begin

  writetimestamp(oline, " ++ ");
  write(oline, str);
  write(oline, dat);
  writeline(output, oline);

end procedure writetrace;

-- -------------------------------------

procedure wait_nextstim(                -- wait for next stim time
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc;      -- clock descriptor
  constant cnt : in positive := 1) is   -- number of cycles to wait

begin

  for i in 1 to cnt loop
    wait until rising_edge(clk);
    wait for clk_dsc.hold;
  end loop;  -- i

end procedure wait_nextstim;

-- -------------------------------------

procedure wait_nextmoni(                -- wait for next moni time
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc;      -- clock descriptor
  constant cnt : in positive := 1) is   -- number of cycles to wait

begin

  for i in 1 to cnt loop
    wait until rising_edge(clk);
    wait for clk_dsc.period - clk_dsc.setup;
  end loop;  -- i

end procedure wait_nextmoni;

-- -------------------------------------

procedure wait_stim2moni(               -- wait from stim to moni time
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc) is   -- clock descriptor

begin

  wait for clk_dsc.period - clk_dsc.hold - clk_dsc.setup;

end procedure wait_stim2moni;

-- -------------------------------------

procedure wait_untilsignal(             -- wait until signal
  signal clk : in slbit;                -- clock
  constant clk_dsc : in clock_dsc;      -- clock descriptor
  signal sig : in slbit;                -- signal
  constant val : in slbit;              -- value
  variable cnt : out natural) is        -- cycle count

  variable cnt_l : natural := 0;
begin

  cnt_l := 0;
  while val /= sig loop
    wait_nextmoni(clk, clk_dsc);
    cnt_l := cnt_l + 1;
  end loop;
  cnt := cnt_l;
  
end procedure wait_untilsignal;

-- -------------------------------------

procedure simfifo_put(                  -- add item to simfifo
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  din : in std_logic_vector;            -- element to add
  val : in slbit := '1') is             -- valid flag

  variable din_imax : integer := din'length-1;
begin

  if val = '0' then
    return;
  end if;
  
  assert cnt < arr'high(1)
    report "simfifo_put: fifo full"
    severity failure;
  assert arr'length(2) = din'length and
         arr'ascending(2) = din'ascending
    report "simfifo_put: arr,din range mismatch"
    severity failure;

  for i in 0 to din_imax loop
    arr(cnt, arr'low(2)+i) := din(din'low+i);
  end loop;  -- i
  cnt := cnt + 1;
  
end procedure simfifo_put;

-- -------------------------------------

procedure simfifo_get(                  -- get item from simfifo
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  dout : out std_logic_vector) is       -- element retrieved

  variable dout_imax : integer := dout'length-1;
begin

  assert cnt > 0
    report "simfifo_put: fifo empty"
    severity failure;
  assert arr'length(2) = dout'length and
         arr'ascending(2) = dout'ascending
    report "simfifo_put: arr,din range mismatch"
    severity failure;

  for i in 0 to dout_imax loop
    dout(dout'low+i) := arr(0, arr'low(2)+i);
  end loop;  -- i
  cnt := cnt - 1;
  if cnt > 0 then
    for i in 1 to cnt loop
      for j in 0 to dout_imax loop
        arr(i-1, arr'low(2)+j) := arr(i, arr'low(2)+j);
      end loop;  -- j
    end loop;  -- i
  end if;
  
end procedure simfifo_get;

-- -------------------------------------

procedure simfifo_writetest(            -- test value against simfifo and write
  L: inout line;                        -- line
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  dat : in std_logic_vector) is         -- data to test

  variable refdata : slv(dat'range);
  
begin

  if cnt = 0 then
    write(L, string'("  FAIL: UNEXPECTED"));
  else
    simfifo_get(cnt, arr, refdata);
    write(L, string'("  CHECK: "));
    if dat = refdata then
      write(L, string'("OK"));
    else
      write(L, string'("FAIL, EXP= "));
      write(L, refdata);
    end if;
  end if;

end procedure simfifo_writetest;

-- -------------------------------------

procedure simfifo_dump(                 -- dump simfifo
  cnt : inout natural;                  -- fifo element count
  arr : inout simfifo_type;             -- fifo data array
  str: in string := null_string) is     -- header text

  variable oline : line;
  variable data : slv(arr'range(2));
  
begin

  writetimestamp(oline, " ++ ");
  if str /= null_string then
    write(oline, str);
  end if;
  write(oline, string'("  cnt= "));
  write(oline, cnt);
  write(oline, string'("  of "));
  write(oline, arr'high(1));
  write(oline, string'("; drange="));
  write(oline, arr'left(2));
  if arr'ascending(2) then
    write(oline, string'(" to "));
  else
    write(oline, string'(" downto "));
  end if;
  write(oline, arr'right(2));
  writeline(output, oline);

  if cnt > 0 then
    for i in 0 to cnt-1 loop
      for j in data'range loop
        data(j) := arr(i,j);
      end loop;  -- j
      write(oline, string'("               - "));
      write(oline, i, right, 2); 
      write(oline, string'(" "));
      write(oline, data);
      writeline(output, oline);
    end loop;  -- i
  end if;

end procedure simfifo_dump;

end package body simlib;

