



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
-- Package:     debug
-- File:        debug.vhd
-- Author:      Jiri Gaisler - ESA/ESTEC
-- Description: This package implements a SPARC disassembler and LEON
--		trace function.
------------------------------------------------------------------------------  
-- Version control:
-- 17-12-1998:  : First implemetation
-- 27-08-1999:  : Moved trace function from iu 
-- 26-09-1999:  : Release 1.0
------------------------------------------------------------------------------  

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_unsigned."+";
use IEEE.Std_Logic_arith.all;
use IEEE.std_logic_unsigned.conv_integer;
use work.leon_target.all;
use work.leon_config.all;
use work.sparcv8.all;
use work.leon_iface.all;
use STD.TEXTIO.all;

package debug is

type debug_info is record
  op 	: std_logic_vector(31 downto 0);
  pc 	: std_logic_vector(31 downto 0);
end record;

type base_type is (hex, dec);

subtype nibble is std_logic_vector(3 downto 0);

function disas(insn : debug_info) return string;

procedure trace(signal debug : in iu_debug_out_type; DISASS : boolean);

function tost(v:std_logic_vector) return string;
function tostd(v:std_logic_vector) return string;
function tosth(v:std_logic_vector) return string;
function tostf(v:std_logic_vector) return string;
--function tostring(n:integer) return string;
function tostrd(n:integer) return string;
procedure print(s : string);

end debug;

package body debug is

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

type carr is array (0 to 9) of character;
constant darr : carr := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
function tostd(v:std_logic_vector) return string is
variable s : string(1 to 2);
variable val : integer;
begin
  val := conv_integer(v); s(1) := darr(val / 10); s(2) := darr(val mod 10);
  return(s);
end;

function tosth(v:std_logic_vector) return string is
constant vlen : natural := v'length; --'
constant slen : natural := (vlen+3)/4;
variable vv : std_logic_vector(vlen-1 downto 0);
variable s : string(1 to slen);
begin
  vv := v;
  for i in slen downto 1 loop
    s(i) := tohex(vv(3 downto 0));
    vv(vlen-5 downto 0) := vv(vlen-1 downto 4);
  end loop;
  return(s);
end;

function tostf(v:std_logic_vector) return string is
constant vlen : natural := v'length; --'
constant slen : natural := (vlen+3)/4;
variable vv : std_logic_vector(vlen-1 downto 0);
variable s : string(1 to slen);
begin
  vv := v;
  for i in slen downto 1 loop
    s(i) := tohex(vv(3 downto 0));
    vv(vlen-5 downto 0) := vv(vlen-1 downto 4);
  end loop;
  return("0x" & s);
end;

function tost(v:std_logic_vector) return string is
constant vlen : natural := v'length; --'
constant slen : natural := (vlen+3)/4;
variable vv : std_logic_vector(0 to slen*4-1) := (others => '0');
variable s : string(1 to slen);
variable nz : boolean := true;
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

--function tostring(n:integer) return string is
--variable len : natural := 1;
--variable tmp : string(1 to 32);
--variable v : integer := n;
--begin
--  for i in 31 downto 0 loop 
--    if v>(2**i) then 
--      tmp(i) := '1'; v := v - (2**i);
--      if i>len then len := i; end if;
--    else 
--      tmp(i) := '0';
--    end if;
--  end loop;
--  return(tmp(32-len to 32));
--end;

function tostrd(n:integer) return string is
variable len : integer := 0;
variable tmp : string(10 downto 1);
variable v : integer := n;
begin
  for i in 0 to 9 loop 
     tmp(i+1) := darr(v mod 10);
     if tmp(i+1) /= '0'  then
        len := i;
     end if;
     v := v/10;
  end loop;
  return(tmp(len+1 downto 1));
end;

function regdec(v : std_logic_vector) return string is
  variable t : std_logic_vector(4 downto 0);
  variable rt : character;
  begin
    t := v;
    case t(4 downto 3) is
    when "00" => rt := 'g';
    when "01" => rt := 'o';
    when "10" => rt := 'l';
    when "11" => rt := 'i';
    when others => rt := 'X';
    end case;
    if v(4 downto 0) = "11110" then
      return("%fp");
    elsif v(4 downto 0) = "01110" then
      return("%sp");
    else
      return('%' & rt & tost('0' & t(2 downto 0)));
    end if;
end;

function simm13dec(insn : debug_info; base : base_type; merge : boolean) return string is
  variable simm : std_logic_vector(12 downto 0) := insn.op(12 downto 0);
  variable rs1 : std_logic_vector(4 downto 0)   := insn.op(18 downto 14);
  variable i : std_logic := insn.op(13);
  variable sig : character;
  variable fill : std_logic_vector(31 downto 13) := (others => simm(12));
begin
  if i = '0' then
    return("");
  else
    if (simm(12) = '1') and (base = dec) then
      sig := '-'; simm := (not simm) + 1;
    else
      sig := '+';
    end if;
    if base = dec then
      if merge then
        if rs1 = "00000" then
          return(tost(simm)); 
        else
          return(sig & tost(simm)); 
        end if;
      else
        if rs1 = "00000" then
          return(tost(simm)); 
        else
	  if sig = '-' then
            return(", " & sig & tost(simm)); 
	  else
            return(", " & tost(simm)); 
	  end if;
        end if;
      end if;
    else
      if rs1 = "00000" then
        if simm(12) = '1' then return(tost(fill & simm)); 
	else return(tost(simm)); end if;
      else
        if simm(12) = '1' then return(", " & tost(fill & simm)); 
	else return(", " & tost(simm)); end if;
      end if;
    end if;
  end if;
end;

function freg2(insn : debug_info) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_logic;
begin
  rs2   := insn.op(4 downto 0);
  rd    := insn.op(29 downto 25);
  return("%f" & tostd(rs2) & 
	 ", %f" & tostd(rd));
end;

function creg3(insn : debug_info) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_logic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  rd    := insn.op(29 downto 25);
  return("%c" & tostd(rs1) & ", %c" & tostd(rs2) & ", %c" & tostd(rd));
end;

function freg3(insn : debug_info) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_logic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  rd    := insn.op(29 downto 25);
  return("%f" & tostd(rs1) & ", %f" & tostd(rs2) & ", %f" & tostd(rd));
end;

function fregc(insn : debug_info) return string is
  variable rs1, rs2 : std_logic_vector(4 downto 0);
  variable i : std_logic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  return("%f" & tostd(rs1) & ", %f" & tostd(rs2));
end;

function regimm(insn : debug_info; base : base_type; merge : boolean) return string is
  variable rs1, rs2 : std_logic_vector(4 downto 0);
  variable i : std_logic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  i     := insn.op(13);
  if i = '0' then
    if (rs1 = "00000") then
      if (rs2 = "00000") then
    	return("0");
      else
    	return(regdec(rs2));
      end if;
    else
      if (rs2 = "00000") then
        return(regdec(rs1));
      elsif merge then
        return(regdec(rs1) & " + " & regdec(rs2));
      else
        return(regdec(rs1) & ", " & regdec(rs2));
      end if;
    end if;
  else
    if (rs1 = "00000") then
      return(simm13dec(insn, base, merge));
    elsif insn.op(12 downto 0) = "0000000000000" then
      return(regdec(rs1));
    else
      return(regdec(rs1) & simm13dec(insn, base, merge));
    end if;
  end if;
end;

function regres(insn : debug_info; base : base_type) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_logic;
begin
  rd    := insn.op(29 downto 25);
  return(regimm(insn, base,false) & ", " & regdec(rd ));
end;


function branchop(insn : debug_info) return string is
  variable simm : std_logic_vector(31 downto 0);
begin
  case insn.op(28 downto 25) is
  when "0000" => return("n");
  when "0001" => return("e");
  when "0010" => return("le");
  when "0011" => return("l");
  when "0100" => return("lue");
  when "0101" => return("cs");
  when "0110" => return("neg");
  when "0111" => return("vs");
  when "1000" => return("a");
  when "1001" => return("ne");
  when "1010" => return("g");
  when "1011" => return("ge");
  when "1100" => return("gu");
  when "1101" => return("cc");
  when "1110" => return("pos");
  when "1111" => return("vc");
  when others => return("XXX");
  end case;
end;

function fbranchop(insn : debug_info) return string is
  variable simm : std_logic_vector(31 downto 0);
begin
  case insn.op(28 downto 25) is
  when "0000" => return("n");
  when "0001" => return("ne");
  when "0010" => return("lg");
  when "0011" => return("ul");
  when "0100" => return("l");
  when "0101" => return("ug");
  when "0110" => return("g");
  when "0111" => return("u");
  when "1000" => return("a");
  when "1001" => return("e");
  when "1010" => return("ue");
  when "1011" => return("ge");
  when "1100" => return("uge");
  when "1101" => return("le");
  when "1110" => return("ule");
  when "1111" => return("o");
  when others => return("XXX");
  end case;
end;

function ldparcp(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & ", " & "%c" & tost(rd));
end;

function ldparf(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & ", " & "%f" & tostd(rd));
end;

function ldpar(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & ", " & regdec(rd));
end;
function ldpara(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & " " & tost(insn.op(12 downto 5)) & ", " & regdec(rd));
end;
function stparc(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  if rd = "00000" then
    return("[" & regimm(insn,dec,true) & "]");
  else
    return(regdec(rd) & ", [" & regimm(insn,dec,true) & "]");
  end if;
end;
function stparcp(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return("%c" & tost(rd) & ", [" & regimm(insn,dec,true) & "]");
end;
function stparf(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return("%f" & tostd(rd) & ", [" & regimm(insn,dec,true) & "]");
end;
function stpar(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return(regdec(rd) & ", [" & regimm(insn,dec,true) & "]");
end;
function stpara(insn : debug_info; rd : std_logic_vector; base : base_type) return string is
begin
  return(regdec(rd) & ", [" & regimm(insn,dec,true) & "]" & " " & tost(insn.op(12 downto 5)));
end;

function disas(insn : debug_info) return string is
  constant STMAX  : natural := 9;
  constant bl2	  : string(1 to  2) := (others => ' ');
  constant bb 	  : string(1 to (4)) := (others => ' ');
  variable op     : std_logic_vector(1 downto 0);
  variable op2    : std_logic_vector(2 downto 0);
  variable op3    : std_logic_vector(5 downto 0);
  variable opf    : std_logic_vector(8 downto 0);
  variable cond   : std_logic_vector(3 downto 0);
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable addr   : std_logic_vector(31 downto 0);
  variable annul  : std_logic;
  variable i      : std_logic;
  variable simm : std_logic_vector(12 downto 0);

  variable disen      : boolean := true;

begin

  if disen then

    op    := insn.op(31 downto 30);
    op2   := insn.op(24 downto 22);

    op3   := insn.op(24 downto 19);
    opf   := insn.op(13 downto 5);
    cond  := insn.op(28 downto 25);
    annul := insn.op(29);
    rs1   := insn.op(18 downto 14);
    rs2   := insn.op(4 downto 0);
    rd    := insn.op(29 downto 25);
    i     := insn.op(13);
    simm  := insn.op(12 downto 0);

    case op is
    when CALL => 
      addr := insn.pc + (insn.op(29 downto 0) & "00");
      return(tostf(insn.pc) & bb & "call" & bl2 & tost(addr));
    when FMT2 =>
      case op2 is
      when UNIMP => return(tostf(insn.pc) & bb & "unimp");
      when SETHI =>
	if rd = "00000" then
          return(tostf(insn.pc) & bb & "nop");
	else
          return(tostf(insn.pc) & bb & "sethi" & bl2 & "%hi(" &
		tost(insn.op(21 downto 0) & "0000000000") & "), " & regdec(rd));
	end if;
      when BICC | FBFCC => 
        addr(31 downto 24) := (others => '0');
        addr(1 downto 0) := (others => '0');
        addr(23 downto 2) := insn.op(21 downto 0);
        if addr(23) = '1' then
          addr(31 downto 24) := (others => '1');
        else
          addr(31 downto 24) := (others => '0');
        end if;
        addr := addr + insn.pc;
	if op2 = BICC then
          if insn.op(29) = '1' then
            return(tostf(insn.pc) & bb & 'b' & branchop(insn) & ",a" & bl2 & 
		tost(addr));
          else
            return(tostf(insn.pc) & bb & 'b' & branchop(insn) & bl2 & 
		tost(addr));
	  end if;
	else
          if insn.op(29) = '1' then
            return(tostf(insn.pc) & bb & "fb" & fbranchop(insn) & ",a" & bl2 & 
		tost(addr));
          else
            return(tostf(insn.pc) & bb & "fb" & fbranchop(insn) & bl2 & 
		tost(addr));
	  end if;
	end if;
--      when CBCCC => cptrap := '1';
      when others => return(tostf(insn.pc) & bb & "unknown opcode: " & tost(insn.op));
      end case;
    when FMT3 =>
      case op3 is
      when IAND => return(tostf(insn.pc) & bb & "and" & bl2 & regres(insn,hex));
      when IADD => return(tostf(insn.pc) & bb & "add" & bl2 & regres(insn,dec));
      when IOR  => 
	if ((i = '0') and (rs1 = "00000") and (rs2 = "00000")) then
	  return(tostf(insn.pc) & bb & "clr" & bl2 & regdec(rd));
	elsif ((i = '1') and (simm = "0000000000000")) or (rs1 = "00000") then
	  return(tostf(insn.pc) & bb & "mov" & bl2 & regres(insn,hex));
	else
	  return(tostf(insn.pc) & bb & "or " & bl2 & regres(insn,hex));
	end if;
      when IXOR => return(tostf(insn.pc) & bb & "xor" & bl2 & regres(insn,hex));
      when ISUB => return(tostf(insn.pc) & bb & "sub" & bl2 & regres(insn,dec));
      when ANDN => return(tostf(insn.pc) & bb & "andn" & bl2 & regres(insn,hex));
      when ORN  => return(tostf(insn.pc) & bb & "orn" & bl2 & regres(insn,hex));
      when IXNOR =>
	if ((i = '0') and ((rs1 = rd) or (rs2 = "00000"))) then
	  return(tostf(insn.pc) & bb & "not" & bl2 & regdec(rd));
	else
	  return(tostf(insn.pc) & bb & "xnor" & bl2 & regdec(rd));
	end if;
      when ADDX => return(tostf(insn.pc) & bb & "addx" & bl2 & regres(insn,dec));
      when SUBX => return(tostf(insn.pc) & bb & "subx" & bl2 & regres(insn,dec));
      when ADDCC => return(tostf(insn.pc) & bb & "addcc" & bl2 & regres(insn,dec));
      when ANDCC => return(tostf(insn.pc) & bb & "andcc" & bl2 & regres(insn,hex));
      when ORCC => return(tostf(insn.pc) & bb & "orcc" & bl2 & regres(insn,hex));
      when XORCC => return(tostf(insn.pc) & bb & "xorcc" & bl2 & regres(insn,hex));
      when SUBCC => return(tostf(insn.pc) & bb & "subcc" & bl2 & regres(insn,dec));
      when ANDNCC => return(tostf(insn.pc) & bb & "andncc" & bl2 & regres(insn,hex));
      when ORNCC => return(tostf(insn.pc) & bb & "orncc" & bl2 & regres(insn,hex));
      when XNORCC => return(tostf(insn.pc) & bb & "xnorcc" & bl2 & regres(insn,hex));
      when ADDXCC => return(tostf(insn.pc) & bb & "addxcc" & bl2 & regres(insn,hex));
      when UMAC   => return(tostf(insn.pc) & bb & "umac" & bl2 & regres(insn,dec));
      when SMAC   => return(tostf(insn.pc) & bb & "smac" & bl2 & regres(insn,dec));
      when UMUL   => return(tostf(insn.pc) & bb & "umul" & bl2 & regres(insn,dec));
      when SMUL   => return(tostf(insn.pc) & bb & "smul" & bl2 & regres(insn,dec));
      when UMULCC => return(tostf(insn.pc) & bb & "umulcc" & bl2 & regres(insn,dec));
      when SMULCC => return(tostf(insn.pc) & bb & "smulcc" & bl2 & regres(insn,dec));
      when SUBXCC => return(tostf(insn.pc) & bb & "subxcc" & bl2 & regres(insn,dec));
      when UDIV   => return(tostf(insn.pc) & bb & "udiv" & bl2 & regres(insn,dec));
      when SDIV   => return(tostf(insn.pc) & bb & "sdiv" & bl2 & regres(insn,dec));
      when UDIVCC => return(tostf(insn.pc) & bb & "udivcc" & bl2 & regres(insn,dec));
      when SDIVCC => return(tostf(insn.pc) & bb & "sdivcc" & bl2 & regres(insn,dec));
      when TADDCC => return(tostf(insn.pc) & bb & "taddcc" & bl2 & regres(insn,dec));
      when TSUBCC => return(tostf(insn.pc) & bb & "tsubcc" & bl2 & regres(insn,dec));
      when TADDCCTV => return(tostf(insn.pc) & bb & "taddcctv" & bl2 & regres(insn,dec));
      when TSUBCCTV => return(tostf(insn.pc) & bb & "tsubcctv" & bl2 & regres(insn,dec));
      when MULSCC => return(tostf(insn.pc) & bb & "mulscc" & bl2 & regres(insn,dec));
      when ISLL => return(tostf(insn.pc) & bb & "sll" & bl2 & regres(insn,dec));
      when ISRL => return(tostf(insn.pc) & bb & "srl" & bl2 & regres(insn,dec));
      when ISRA => return(tostf(insn.pc) & bb & "sra" & bl2 & regres(insn,dec));
      when RDY  => 
        if rs1 /= "00000" then
	  return(tostf(insn.pc) & bb & "mov" & bl2 & "%asr" &
	         tost(rs1) & ", " & regdec(rd));
	else
	  return(tostf(insn.pc) & bb & "mov" & bl2 & "%y, " & regdec(rd));
        end if;
      when RDPSR  => return(tostf(insn.pc) & bb & "mov" & bl2 & "%psr, " & regdec(rd));
      when RDWIM  => return(tostf(insn.pc) & bb & "mov" & bl2 & "%wim, " & regdec(rd));
      when RDTBR  => return(tostf(insn.pc) & bb & "mov" & bl2 & "%tbr, " & regdec(rd));
      when WRY  =>
	if (rs1 = "00000") or (rs2 = "00000") then
          if rd /= "00000" then
	    return(tostf(insn.pc) & bb & "mov" & bl2
	         & regimm(insn,hex,false) & ", %asr" & tost(rd));
	  else
	    return(tostf(insn.pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %y");
	  end if;
	else
          if rd /= "00000" then
	    return(tostf(insn.pc) & bb & "wr " & bl2 & "%asr" 
	         & regimm(insn,hex,false) & ", %asr" & tost(rd));
	  else
	    return(tostf(insn.pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %y");
	  end if;
	end if;
      when WRPSR  =>
	if (rs1 = "00000") or (rs2 = "00000") then
	  return(tostf(insn.pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %psr");
	else
	  return(tostf(insn.pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %psr");
	end if;
      when WRWIM  =>
	if (rs1 = "00000") or (rs2 = "00000") then
	  return(tostf(insn.pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %wim");
	else
	  return(tostf(insn.pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %wim");
	end if;
      when WRTBR  =>
	if (rs1 = "00000") or (rs2 = "00000") then
	  return(tostf(insn.pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %tbr");
	else
	  return(tostf(insn.pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %tbr");
	end if;
      when JMPL => 
	if (rd = "00000") then
	  if (i = '1') and (simm = "0000000001000") then
	    if (rs1 = "11111") then
	      return(tostf(insn.pc) & bb & "ret");
	    elsif (rs1 = "01111") then
	      return(tostf(insn.pc) & bb & "retl");
	    else
	      return(tostf(insn.pc) & bb & "jmp" & bl2 & regimm(insn,dec,true));
	    end if;
	  else
	    return(tostf(insn.pc) & bb & "jmp" & bl2 & regimm(insn,dec,true));
	  end if;
	else
	  return(tostf(insn.pc) & bb & "jmpl" & bl2 & regres(insn,dec));
	end if;
      when TICC => 
        return(tostf(insn.pc) & bb & 't' & branchop(insn) & bl2 & regimm(insn,hex,false));
      when FLUSH => 
        return(tostf(insn.pc) & bb & "flush" & bl2 & regimm(insn,hex,false));
      when RETT => 
        return(tostf(insn.pc) & bb & "rett" & bl2 & regimm(insn,dec,false));
      when RESTORE => 
	if (rd = "00000") then
	  return(tostf(insn.pc) & bb & "restore");
	else
	  return(tostf(insn.pc) & bb & "restore" & bl2 & regres(insn,hex));
	end if;
      when SAVE => 
	if (rd = "00000") then
	  return(tostf(insn.pc) & bb & "save");
	else
	  return(tostf(insn.pc) & bb & "save" & bl2 & regres(insn,dec));
	end if;
      when FPOP1 => 
        case opf is
	when FITOS => return(tostf(insn.pc) & bb & "fitos" & bl2 & freg2(insn));
	when FITOD => return(tostf(insn.pc) & bb & "fitod" & bl2 & freg2(insn));
        when FSTOI => return(tostf(insn.pc) & bb & "fstoi" & bl2 & freg2(insn));                                            
	when FDTOI => return(tostf(insn.pc) & bb & "fdtoi" & bl2 & freg2(insn));
	when FSTOD => return(tostf(insn.pc) & bb & "fstod" & bl2 & freg2(insn));
	when FDTOS => return(tostf(insn.pc) & bb & "fdtos" & bl2 & freg2(insn));
	when FMOVS => return(tostf(insn.pc) & bb & "fmovs" & bl2 & freg2(insn));
	when FNEGS => return(tostf(insn.pc) & bb & "fnegs" & bl2 & freg2(insn));
	when FABSS => return(tostf(insn.pc) & bb & "fabss" & bl2 & freg2(insn));
	when FSQRTS => return(tostf(insn.pc) & bb & "fsqrts" & bl2 & freg2(insn));
	when FSQRTD => return(tostf(insn.pc) & bb & "fsqrtd" & bl2 & freg2(insn));
	when FADDS => return(tostf(insn.pc) & bb & "fadds" & bl2 & freg3(insn));
	when FADDD => return(tostf(insn.pc) & bb & "faddd" & bl2 & freg3(insn));
	when FSUBS => return(tostf(insn.pc) & bb & "fsubs" & bl2 & freg3(insn));
	when FSUBD => return(tostf(insn.pc) & bb & "fsubd" & bl2 & freg3(insn));
	when FMULS => return(tostf(insn.pc) & bb & "fmuls" & bl2 & freg3(insn));
	when FMULD => return(tostf(insn.pc) & bb & "fmuld" & bl2 & freg3(insn));
	when FSMULD => return(tostf(insn.pc) & bb & "fsmuld" & bl2 & freg3(insn));
	when FDIVS => return(tostf(insn.pc) & bb & "fdivs" & bl2 & freg3(insn));
	when FDIVD => return(tostf(insn.pc) & bb & "fdivd" & bl2 & freg3(insn));
        when others => return(tostf(insn.pc) & bb & "unknown Fopcode: " & tost(insn.op));
	end case;
      when FPOP2 => 
        case opf is
	when FCMPS => return(tostf(insn.pc) & bb & "fcmps" & bl2 & fregc(insn));
	when FCMPD => return(tostf(insn.pc) & bb & "fcmpd" & bl2 & fregc(insn));
	when FCMPES => return(tostf(insn.pc) & bb & "fcmpes" & bl2 & fregc(insn));
	when FCMPED => return(tostf(insn.pc) & bb & "fcmped" & bl2 & fregc(insn));
        when others => return(tostf(insn.pc) & bb & "unknown Fopcode: " & tost(insn.op));
	end case;
      when CPOP1 => 
	return(tostf(insn.pc) & bb & "cpop1" & bl2 & tost("000"&opf) & ", " &creg3(insn));
      when CPOP2 => 
	return(tostf(insn.pc) & bb & "cpop2" & bl2 & tost("000"&opf) & ", " &creg3(insn));
      when others => return(tostf(insn.pc) & bb & "unknown opcode: " & tost(insn.op));
      end case;
    when LDST =>
      case op3 is
      when STC => 
	return(tostf(insn.pc) & bb & "st" & bl2 & stparcp(insn, rd, dec));
      when STF => 
	return(tostf(insn.pc) & bb & "st" & bl2 & stparf(insn, rd, dec));
      when ST => 
	if rd = "00000" then
	  return(tostf(insn.pc) & bb & "clr" & bl2 & stparc(insn, rd, dec));
	else
	  return(tostf(insn.pc) & bb & "st" & bl2 & stpar(insn, rd, dec));
	end if;
      when STB => 
	if rd = "00000" then
	  return(tostf(insn.pc) & bb & "clrb" & bl2 & stparc(insn, rd, dec));
	else
	  return(tostf(insn.pc) & bb & "stb" & bl2 & stpar(insn, rd, dec));
	end if;
      when STH => 
	if rd = "00000" then
	  return(tostf(insn.pc) & bb & "clrh" & bl2 & stparc(insn, rd, dec));
	else
	  return(tostf(insn.pc) & bb & "sth" & bl2 & stpar(insn, rd, dec));
	end if;
      when STDC => 
	return(tostf(insn.pc) & bb & "std" & bl2 & stparcp(insn, rd, dec));
      when STDF => 
	return(tostf(insn.pc) & bb & "std" & bl2 & stparf(insn, rd, dec));
      when STCSR => 
	return(tostf(insn.pc) & bb & "st" & bl2 & "%csr, [" & regimm(insn,dec,true) & "]");
      when STFSR => 
	return(tostf(insn.pc) & bb & "st" & bl2 & "%fsr, [" & regimm(insn,dec,true) & "]");
      when STDCQ => 
	return(tostf(insn.pc) & bb & "std" & bl2 & "%cq, [" & regimm(insn,dec,true) & "]");
      when STDFQ => 
	return(tostf(insn.pc) & bb & "std" & bl2 & "%fq, [" & regimm(insn,dec,true) & "]");
      when ISTD => 
	return(tostf(insn.pc) & bb & "std" & bl2 & stpar(insn, rd, dec));
      when STA => 
	return(tostf(insn.pc) & bb & "sta" & bl2 & stpara(insn, rd, dec));
      when STBA => 
	return(tostf(insn.pc) & bb & "stba" & bl2 & stpara(insn, rd, dec));
      when STHA => 
	return(tostf(insn.pc) & bb & "stha" & bl2 & stpara(insn, rd, dec));
      when STDA => 
	return(tostf(insn.pc) & bb & "stda" & bl2 & stpara(insn, rd, dec));
      when LDC => 
	return(tostf(insn.pc) & bb & "ld" & bl2 & ldparcp(insn, rd, dec));
      when LDF => 
	return(tostf(insn.pc) & bb & "ld" & bl2 & ldparf(insn, rd, dec));
      when LDCSR => 
	return(tostf(insn.pc) & bb & "ld" & bl2 & "[" & regimm(insn,dec,true) & "]" & ", %csr");
      when LDFSR => 
	return(tostf(insn.pc) & bb & "ld" & bl2 & "[" & regimm(insn,dec,true) & "]" & ", %fsr");
      when LD => 
	return(tostf(insn.pc) & bb & "ld" & bl2 & ldpar(insn, rd, dec));
      when LDUB => 
	return(tostf(insn.pc) & bb & "ldub" & bl2 & ldpar(insn, rd, dec));
      when LDUH => 
	return(tostf(insn.pc) & bb & "lduh" & bl2 & ldpar(insn, rd, dec));
      when LDDC => 
	return(tostf(insn.pc) & bb & "ldd" & bl2 & ldparcp(insn, rd, dec));
      when LDDF => 
	return(tostf(insn.pc) & bb & "ldd" & bl2 & ldparf(insn, rd, dec));
      when LDD => 
	return(tostf(insn.pc) & bb & "ldd" & bl2 & ldpar(insn, rd, dec));
      when LDSB => 
	return(tostf(insn.pc) & bb & "ldsb" & bl2 & ldpar(insn, rd, dec));
      when LDSH => 
	return(tostf(insn.pc) & bb & "ldsh" & bl2 & ldpar(insn, rd, dec));
      when LDSTUB => 
	return(tostf(insn.pc) & bb & "ldstub" & bl2 & ldpar(insn, rd, dec));
      when SWAP   => 
	return(tostf(insn.pc) & bb & "swap" & bl2 & ldpar(insn, rd, dec));
      when LDA => 
	return(tostf(insn.pc) & bb & "lda" & bl2 & ldpara(insn, rd, dec));
      when LDUBA => 
	return(tostf(insn.pc) & bb & "lduba" & bl2 & ldpara(insn, rd, dec));
      when LDUHA => 
	return(tostf(insn.pc) & bb & "lduha" & bl2 & ldpara(insn, rd, dec));
      when LDDA => 
	return(tostf(insn.pc) & bb & "ldda" & bl2 & ldpara(insn, rd, dec));
      when LDSBA => 
	return(tostf(insn.pc) & bb & "ldsba" & bl2 & ldpara(insn, rd, dec));
      when LDSHA => 
	return(tostf(insn.pc) & bb & "ldsha" & bl2 & ldpara(insn, rd, dec));
      when LDSTUBA => 
	return(tostf(insn.pc) & bb & "ldstuba" & bl2 & ldpara(insn, rd, dec));
      when SWAPA   => 
	return(tostf(insn.pc) & bb & "swapa" & bl2 & ldpara(insn, rd, dec));

      when others => return(tostf(insn.pc) & bb & "unknown opcode: " & tost(insn.op));
      end case;
    when others => return(tostf(insn.pc) & bb & "unknown opcode: " & tost(insn.op));
    end case;

  end if;
end;

procedure print(s : string) is
    variable L1 : line;
begin
  L1:= new string'(s);	--'
--  write(L1, s);
  writeline(output,L1);
end;

procedure trace(signal debug : in iu_debug_out_type; DISASS : boolean) is
  variable insn    : debug_info;
  variable wr_annul : std_logic;    
begin
  if DEBUGFPU and (FPIFTYPE = parallel) and (FPCORE = grfpu) then
    wr_annul := debug.wr.annul or debug.fpdbg.wr_fp;
  else
    wr_annul := debug.wr.annul;
  end if;  
  if DISASS or DEBUGFPU then
    if (debug.rst = '1') and debug.clk'event and (debug.clk = '1') and ((debug.holdn = '1')) then --'
      insn.op := debug.wr.inst;
      insn.pc := debug.wr.pc(31 downto 2) & "00";
      if (((not wr_annul) and debug.wr.pv) = '1') and
	not (DEBUG_UNIT and (debug.vdmode = '1'))
      then
	if DISASS then
          if debug.trap = '1' then
	    print (disas(insn) & "  (trapped, tt = " & tostf(debug.tt) & ")");

	  else
	    print (disas(insn));
	  end if;
	end if;
      end if;
      if wr_annul = '0' then
	if DEBUGIURF then
	  if (debug.write_reg = '1') then
	    print(tostf(insn.pc) & ": %r" & tost(debug.wr.rd) & " = " & tost(debug.result));
	  end if;
	end if;
	if DEBUGFPU and (FPIFTYPE = serial) then
	  if (debug.write_reg = '1') and (debug.wr.rd(7 downto 5) = "100") then
	    print(tosth(insn.pc) & ": %f" & tostd(debug.wr.rd(4 downto 0)) &
		" = " & tosth(debug.result));
	  end if;
	end if;
      end if;
      if (DEBUGFPU or DISASS) and (FPIFTYPE = parallel) and (FPCORE = grfpu) then
        insn.op := debug.fpdbg.op;
        insn.pc := debug.fpdbg.pc(31 downto 2) & "00";
        if debug.fpdbg.wr2_fp = '1' then
          if DISASS then
            print(disas(insn));
          end if;
          if DEBUGFPU then 
            if debug.fpdbg.write_fpreg(0) = '1' then
              print(tostf(insn.pc) & ": %f" & tostd(debug.fpdbg.fpreg & '0') & " = " & tostf(debug.fpdbg.ddata(63 downto 32)));
            end if;
            if debug.fpdbg.write_fpreg(1) = '1' then
              print(tostf(insn.pc) & ": %f" & tostd(debug.fpdbg.fpreg & '1') & " = " & tostf(debug.fpdbg.ddata(31 downto 0)));
            end if;
            if debug.fpdbg.write_fsr = '1' then
              print(tostf(insn.pc) & ": %fsr" & " = " & tostf(debug.fpdbg.ddata(63 downto 32)));
            end if;
          end if;
        end if;
      end if;      
    end if;
  end if;
end;

end debug;
