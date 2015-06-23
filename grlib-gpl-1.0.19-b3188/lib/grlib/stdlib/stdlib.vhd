------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2006, Gaisler Research AB - all rights reserved.
--
-- ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
-- ACCORDANCE WITH THE GAISLER LICENSE AGREEMENT AND MUST BE APPROVED 
-- IN ADVANCE IN WRITING. 
-----------------------------------------------------------------------------
-- Package: 	stdlib
-- File:	stdlib.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Package for common VHDL functions
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- pragma translate_off
use std.textio.all;
-- pragma translate_on
library grlib;
use grlib.version.all;

package stdlib is

constant LIBVHDL_VERSION : integer := grlib_version;
constant LIBVHDL_BUILD : integer := grlib_build;
-- pragma translate_off
constant LIBVHDL_DATE : string := grlib_date;
-- pragma translate_on
constant zero32 : std_logic_vector(31 downto 0) := (others => '0');
constant zero64 : std_logic_vector(63 downto 0) := (others => '0');
constant one32  : std_logic_vector(31 downto 0) := (others => '1');

type log2arr is array(0 to 512) of integer;
constant log2   : log2arr := (
0,0,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
  6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  others => 9);
constant log2x  : log2arr := (
0,1,1,2,2,3,3,3,3,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,
  6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,
  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,
  others => 9);

function decode(v : std_logic_vector) return std_logic_vector;
function genmux(s,v : std_logic_vector) return std_ulogic;
function xorv(d : std_logic_vector) return std_ulogic;
function orv(d : std_logic_vector) return std_ulogic;
function andv(d : std_logic_vector) return std_ulogic;
function notx(d : std_logic_vector) return boolean;
function notx(d : std_ulogic) return boolean;
function "-" (d : std_logic_vector; i : integer) return std_logic_vector;
function "-" (i : integer; d : std_logic_vector) return std_logic_vector;
function "+" (d : std_logic_vector; i : integer) return std_logic_vector;
function "+" (i : integer; d : std_logic_vector) return std_logic_vector;
function "-" (d : std_logic_vector; i : std_ulogic) return std_logic_vector;
function "+" (d : std_logic_vector; i : std_ulogic) return std_logic_vector;
function "-" (a, b : std_logic_vector) return std_logic_vector;
function "+" (a, b : std_logic_vector) return std_logic_vector;
function "*" (a, b : std_logic_vector) return std_logic_vector;
function signed_mul (a, b : std_logic_vector) return std_logic_vector;
--function ">" (a, b : std_logic_vector) return boolean;
function "<" (i : integer; b : std_logic_vector) return boolean;
function conv_integer(v : std_logic_vector) return integer;
function conv_integer(v : std_logic) return integer;
function conv_std_logic_vector(i : integer; w : integer) return std_logic_vector;
function conv_std_logic_vector_signed(i : integer; w : integer) return std_logic_vector;
function conv_std_logic(b : boolean) return std_ulogic;

-- Reporting and diagnostics

-- pragma translate_off

function tost(v:std_logic_vector) return string;
function tost(v:std_logic) return string;
function tost(i : integer) return string;
procedure print(s : string);

component report_version
  generic (msg1, msg2, msg3, msg4 : string := ""; mdel : integer := 4);
end component;

-- pragma translate_on

end;

package body stdlib is

function notx(d : std_logic_vector) return boolean is
variable res : boolean;
begin
  res := true;
-- pragma translate_off
  res := not is_x(d);
-- pragma translate_on
  return (res);
end;

function notx(d : std_ulogic) return boolean is
variable res : boolean;
begin
  res := true;
-- pragma translate_off
  res := not is_x(d);
-- pragma translate_on
  return (res);
end;

-- generic decoder

function decode(v : std_logic_vector) return std_logic_vector is
variable res : std_logic_vector((2**v'length)-1 downto 0);
variable i : integer range res'range;
begin
  res := (others => '0'); i := 0;
  if notx(v) then i := to_integer(unsigned(v)); end if;
  res(i) := '1';
  return(res);
end;

-- generic multiplexer

function genmux(s,v : std_logic_vector) return std_ulogic is
variable res : std_logic_vector(v'length-1 downto 0);
variable i : integer range res'range;
begin
  res := v; i := 0;
  if notx(s) then i := to_integer(unsigned(s)); end if;
  return(res(i));
end;

-- vector XOR

function xorv(d : std_logic_vector) return std_ulogic is
variable tmp : std_ulogic;
begin
  tmp := '0';
  for i in d'range loop tmp := tmp xor d(i); end loop;
  return(tmp);
end;

-- vector OR

function orv(d : std_logic_vector) return std_ulogic is
variable tmp : std_ulogic;
begin
  tmp := '0';
  for i in d'range loop tmp := tmp or d(i); end loop;
  return(tmp);
end;

-- vector AND

function andv(d : std_logic_vector) return std_ulogic is
variable tmp : std_ulogic;
begin
  tmp := '1';
  for i in d'range loop tmp := tmp and d(i); end loop;
  return(tmp);
end;

-- unsigned multiplication

function "*" (a, b : std_logic_vector) return std_logic_vector is
variable z : std_logic_vector(a'length+b'length-1 downto 0);
begin
  if notx(a&b) then
    return(std_logic_vector(unsigned(a) * unsigned(b)));
-- pragma translate_off
  else
     z := (others =>'X'); return(z);
-- pragma translate_on
  end if;
end;

-- signed multiplication

function signed_mul (a, b : std_logic_vector) return std_logic_vector is
variable z : std_logic_vector(a'length+b'length-1 downto 0);
begin
  if notx(a&b) then
    return(std_logic_vector(signed(a) * signed(b)));
-- pragma translate_off
  else
     z := (others =>'X'); return(z);
-- pragma translate_on
  end if;
end;

-- unsigned addition

function "+" (a, b : std_logic_vector) return std_logic_vector is
variable x : std_logic_vector(a'length-1 downto 0);
variable y : std_logic_vector(b'length-1 downto 0);
begin
  if notx(a&b) then
    return(std_logic_vector(unsigned(a) + unsigned(b)));
-- pragma translate_off
  else
     x := (others =>'X'); y := (others =>'X');
     if (x'length > y'length) then return(x); else return(y); end if;
-- pragma translate_on
  end if;
end;

function "+" (i : integer; d : std_logic_vector) return std_logic_vector is
variable x : std_logic_vector(d'length-1 downto 0);
begin
  if notx(d) then
    return(std_logic_vector(unsigned(d) + i));
-- pragma translate_off
  else x := (others =>'X'); return(x);
-- pragma translate_on
  end if;
end;

function "+" (d : std_logic_vector; i : integer) return std_logic_vector is
variable x : std_logic_vector(d'length-1 downto 0);
begin
  if notx(d) then
    return(std_logic_vector(unsigned(d) + i));
-- pragma translate_off
  else x := (others =>'X'); return(x);
-- pragma translate_on
  end if;
end;

function "+" (d : std_logic_vector; i : std_ulogic) return std_logic_vector is
variable x : std_logic_vector(d'length-1 downto 0);
variable y : std_logic_vector(0 downto 0);
begin
  y(0) := i;
  if notx(d) then
    return(std_logic_vector(unsigned(d) + unsigned(y)));
-- pragma translate_off
  else x := (others =>'X'); return(x); 
-- pragma translate_on
  end if;
end;

-- unsigned subtraction

function "-" (a, b : std_logic_vector) return std_logic_vector is
variable x : std_logic_vector(a'length-1 downto 0);
variable y : std_logic_vector(b'length-1 downto 0);
begin
  if notx(a&b) then
    return(std_logic_vector(unsigned(a) - unsigned(b)));
-- pragma translate_off
  else
     x := (others =>'X'); y := (others =>'X');
     if (x'length > y'length) then return(x); else return(y); end if; 
-- pragma translate_on
  end if;
end;

function "-" (d : std_logic_vector; i : integer) return std_logic_vector is
variable x : std_logic_vector(d'length-1 downto 0);
begin
  if notx(d) then
    return(std_logic_vector(unsigned(d) - i));
-- pragma translate_off
  else x := (others =>'X'); return(x); 
-- pragma translate_on
  end if;
end;

function "-" (i : integer; d : std_logic_vector) return std_logic_vector is
variable x : std_logic_vector(d'length-1 downto 0);
begin
  if notx(d) then
    return(std_logic_vector(i - unsigned(d)));
-- pragma translate_off
  else x := (others =>'X'); return(x); 
-- pragma translate_on
  end if;
end;

function "-" (d : std_logic_vector; i : std_ulogic) return std_logic_vector is
variable x : std_logic_vector(d'length-1 downto 0);
variable y : std_logic_vector(0 downto 0);
begin
  y(0) := i;
  if notx(d) then
    return(std_logic_vector(unsigned(d) - unsigned(y)));
-- pragma translate_off
  else x := (others =>'X'); return(x); 
-- pragma translate_on
  end if;
end;

function ">=" (a, b : std_logic_vector) return boolean is
begin
  return(unsigned(a) >= unsigned(b));
end;

function "<" (i : integer; b : std_logic_vector) return boolean is
begin
  return( i < to_integer(unsigned(b)));
end;

function ">" (a, b : std_logic_vector) return boolean is
begin
  return(unsigned(a) > unsigned(b));
end;

function conv_integer(v : std_logic_vector) return integer is
begin
  if notx(v) then return(to_integer(unsigned(v)));
  else return(0); end if;
end;

function conv_integer(v : std_logic) return integer is
begin
  if notx(v) then
    if v = '1' then return(1);
    else return(0); end if;
  else return(0); end if;
end;

function conv_std_logic_vector(i : integer; w : integer) return std_logic_vector is
variable tmp : std_logic_vector(w-1 downto 0);
begin
  tmp := std_logic_vector(to_unsigned(i, w));
  return(tmp);
end;

function conv_std_logic_vector_signed(i : integer; w : integer) return std_logic_vector is
variable tmp : std_logic_vector(w-1 downto 0);
begin
  tmp := std_logic_vector(to_signed(i, w));
  return(tmp);
end;

function conv_std_logic(b : boolean) return std_ulogic is
begin
  if b then return('1'); else return('0'); end if;
end;

-- pragma translate_off
subtype nibble is std_logic_vector(3 downto 0);

function todec(i:integer) return character is
begin
  case i is
  when 0 => return('0');
  when 1 => return('1');
  when 2 => return('2');
  when 3 => return('3');
  when 4 => return('4');
  when 5 => return('5');
  when 6 => return('6');
  when 7 => return('7');
  when 8 => return('8');
  when 9 => return('9');
  when others => return('0');
  end case;
end;

function tohex(n:nibble) return character is
begin
  case n is
  when "0000" => return('0');
  when "0001" => return('1');
  when "0010" => return('2');
  when "0011" => return('3');
  when "0100" => return('4');
  when "0101" => return('5');
  when "0110" => return('6');
  when "0111" => return('7');
  when "1000" => return('8');
  when "1001" => return('9');
  when "1010" => return('a');
  when "1011" => return('b');
  when "1100" => return('c');
  when "1101" => return('d');
  when "1110" => return('e');
  when "1111" => return('f');
  when others => return('X');
  end case;
end;

function tost(v:std_logic_vector) return string is
constant vlen : natural := v'length; --'
constant slen : natural := (vlen+3)/4;
variable vv : std_logic_vector(0 to slen*4-1) := (others => '0');
variable s : string(1 to slen);
variable nz : boolean := false;
variable index : integer := -1;
begin
  vv(slen*4-vlen to slen*4-1) := v;
  for i in 0 to slen-1 loop
    if (vv(i*4 to i*4+3) = "0000") and nz and (i /= (slen-1)) then
      index := i;
    else
      nz := false;
      s(i+1) := tohex(vv(i*4 to i*4+3));
    end if;
  end loop;
  if ((index +2) = slen) then return(s(slen to slen));
  else return(string'("0x") & s(index+2 to slen)); end if; --'
end;

function tost(v:std_logic) return string is
begin
  if to_x01(v) = '1' then return("1"); else return("0"); end if;
end;

function tost(i : integer) return string is
variable L : line;
variable s, x : string(1 to 128);
variable n, tmp : integer := 0;
begin
  tmp := i;
  loop
    s(128-n) := todec(tmp mod 10);
    tmp := tmp / 10;
    n := n+1;
    if tmp = 0 then exit; end if;
  end loop;
  x(1 to n) := s(129-n to 128);
  return(x(1 to n));
end;

procedure print(s : string) is
    variable L : line;
begin
  L := new string'(s); writeline(output, L);
end;

-- pragma translate_on
end;


