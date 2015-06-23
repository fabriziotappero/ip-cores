------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Package: 	sparc_disas
-- File:	sparc_disas.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	SPARC disassembler according to SPARC V8 manual 
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.stdlib.all;
use grlib.sparc.all;
use std.textio.all;

package sparc_disas is
  function tostf(v:std_logic_vector) return string;
  procedure print_insn(ndx: integer; pc, op, res : std_logic_vector(31 downto 0); 
	valid, trap, wr, rest : boolean);
  procedure print_fpinsn(ndx: integer; pc, op : std_logic_vector(31 downto 0);
                       res : std_logic_vector(63 downto 0);
                       dpres, valid, trap, wr : boolean);
  function ins2st(pc, op : std_logic_vector(31 downto 0)) return string;
end;

package body sparc_disas is

type base_type is (hex, dec);
subtype nibble is std_logic_vector(3 downto 0);
type pc_op_type is record
  pc, op : std_logic_vector(31 downto 0);
end record;

function tostd(v:std_logic_vector) return string;
function tosth(v:std_logic_vector) return string;
function tostrd(n:integer) return string;
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

function ireg2st(v : std_logic_vector) return string is
  variable ctmp : character;
  variable reg : std_logic_vector(4 downto 0);
  begin
    reg := v;
    case reg(4 downto 3) is
    when "00" => ctmp := 'g'; when "01" => ctmp := 'o';
    when "10" => ctmp := 'l'; when "11" => ctmp := 'i';
    when others => ctmp := 'X';
    end case;
    if v(4 downto 0) = "11110" then return("%fp");
    elsif v(4 downto 0) = "01110" then return("%sp");
    else return('%' & ctmp & tost('0' & reg(2 downto 0))); end if;
end;

function simm13dec(insn : pc_op_type; base : base_type; merge : boolean) return string is
  variable simm : std_logic_vector(12 downto 0) := insn.op(12 downto 0);
  variable rs1 : std_logic_vector(4 downto 0)   := insn.op(18 downto 14);
  variable i : std_ulogic := insn.op(13);
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

function freg2(insn : pc_op_type) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_ulogic;
begin
  rs2   := insn.op(4 downto 0);
  rd    := insn.op(29 downto 25);
  return("%f" & tostd(rs2) & 
	 ", %f" & tostd(rd));
end;

function creg3(insn : pc_op_type) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_ulogic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  rd    := insn.op(29 downto 25);
  return("%c" & tostd(rs1) & ", %c" & tostd(rs2) & ", %c" & tostd(rd));
end;

function freg3(insn : pc_op_type) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_ulogic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  rd    := insn.op(29 downto 25);
  return("%f" & tostd(rs1) & ", %f" & tostd(rs2) & ", %f" & tostd(rd));
end;

function fregc(insn : pc_op_type) return string is
  variable rs1, rs2 : std_logic_vector(4 downto 0);
  variable i : std_ulogic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  return("%f" & tostd(rs1) & ", %f" & tostd(rs2));
end;

function regimm(insn : pc_op_type; base : base_type; merge : boolean) return string is
  variable rs1, rs2 : std_logic_vector(4 downto 0);
  variable i : std_ulogic;
begin
  rs1   := insn.op(18 downto 14);
  rs2   := insn.op(4 downto 0);
  i     := insn.op(13);
  if i = '0' then
    if (rs1 = "00000") then
      if (rs2 = "00000") then return("0");
      else return(ireg2st(rs2)); end if;
    else
      if (rs2 = "00000") then return(ireg2st(rs1));
      elsif merge then return(ireg2st(rs1) & " + " & ireg2st(rs2));
      else return(ireg2st(rs1) & ", " & ireg2st(rs2)); end if;
    end if;
  else
    if (rs1 = "00000") then return(simm13dec(insn, base, merge));
    elsif insn.op(12 downto 0) = "0000000000000" then return(ireg2st(rs1));
    else return(ireg2st(rs1) & simm13dec(insn, base, merge)); end if;
  end if;
end;

function regres(insn : pc_op_type; base : base_type) return string is
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable i : std_ulogic;
begin
  rd    := insn.op(29 downto 25);
  return(regimm(insn, base,false) & ", " & ireg2st(rd ));
end;

function branchop(insn : pc_op_type) return string is
  variable simm : std_logic_vector(31 downto 0);
begin
  case insn.op(28 downto 25) is
  when "0000" => return("n");
  when "0001" => return("e");
  when "0010" => return("le");
  when "0011" => return("l");
  when "0100" => return("leu");
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

function fbranchop(insn : pc_op_type) return string is
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

function ldparcp(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & ", " & "%c" & tost(rd));
end;

function ldparf(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & ", " & "%f" & tostd(rd));
end;

function ldpar(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & ", " & ireg2st(rd));
end;
function ldpara(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return("[" & regimm(insn,dec,true) & "]" & " " & tost(insn.op(12 downto 5)) & ", " & ireg2st(rd));
end;
function stparc(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  if rd = "00000" then
    return("[" & regimm(insn,dec,true) & "]");
  else
    return(ireg2st(rd) & ", [" & regimm(insn,dec,true) & "]");
  end if;
end;
function stparcp(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return("%c" & tost(rd) & ", [" & regimm(insn,dec,true) & "]");
end;
function stparf(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return("%f" & tostd(rd) & ", [" & regimm(insn,dec,true) & "]");
end;
function stpar(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return(ireg2st(rd) & ", [" & regimm(insn,dec,true) & "]");
end;
function stpara(insn : pc_op_type; rd : std_logic_vector; base : base_type) return string is
begin
  return(ireg2st(rd) & ", [" & regimm(insn,dec,true) & "]" & " " & tost(insn.op(12 downto 5)));
end;

function ins2st(pc, op : std_logic_vector(31 downto 0)) return string is
  constant STMAX  : natural := 9;
  constant bl2	  : string(1 to 2) := (others => ' ');
  constant bb 	  : string(1 to 4) := (others => ' ');
  variable op1    : std_logic_vector(1 downto 0);
  variable op2    : std_logic_vector(2 downto 0);
  variable op3    : std_logic_vector(5 downto 0);
  variable opf    : std_logic_vector(8 downto 0);
  variable cond   : std_logic_vector(3 downto 0);
  variable rs1, rs2, rd : std_logic_vector(4 downto 0);
  variable addr   : std_logic_vector(31 downto 0);
  variable annul  : std_ulogic;
  variable i      : std_ulogic;
  variable simm : std_logic_vector(12 downto 0);
  variable insn	: pc_op_type;

begin

    op1   := op(31 downto 30);
    op2   := op(24 downto 22);
    op3   := op(24 downto 19);
    opf   := op(13 downto 5);
    cond  := op(28 downto 25);
    annul := op(29);
    rs1   := op(18 downto 14);
    rs2   := op(4 downto 0);
    rd    := op(29 downto 25);
    i     := op(13);
    simm  := op(12 downto 0);
    insn.op := op;
    insn.pc := pc;

    case op1 is
    when CALL => 
      addr := pc + (op(29 downto 0) & "00");
      return(tostf(pc) & bb & "call" & bl2 & tost(addr));
    when FMT2 =>
      case op2 is
      when SETHI =>
	if rd = "00000" then
          return(tostf(pc) & bb & "nop");
	else
          return(tostf(pc) & bb & "sethi" & bl2 & "%hi(" &
		tost(op(21 downto 0) & "0000000000") & "), " & ireg2st(rd));
	end if;
      when BICC | FBFCC => 
        addr(31 downto 24) := (others => '0');
        addr(1 downto 0) := (others => '0');
        addr(23 downto 2) := op(21 downto 0);
        if addr(23) = '1' then
          addr(31 downto 24) := (others => '1');
        else
          addr(31 downto 24) := (others => '0');
        end if;
        addr := addr + pc;
	if op2 = BICC then
          if op(29) = '1' then
            return(tostf(pc) & bb & 'b' & branchop(insn) & ",a" & bl2 & 
		tost(addr));
          else
            return(tostf(pc) & bb & 'b' & branchop(insn) & bl2 & 
		tost(addr));
	  end if;
	else
          if op(29) = '1' then
            return(tostf(pc) & bb & "fb" & fbranchop(insn) & ",a" & bl2 & 
		tost(addr));
          else
            return(tostf(pc) & bb & "fb" & fbranchop(insn) & bl2 & 
		tost(addr));
	  end if;
	end if;
--      when CBCCC => cptrap := '1';
      when others => return(tostf(pc) & bb & "unimp");
      end case;
    when FMT3 =>
      case op3 is
      when IAND => return(tostf(pc) & bb & "and" & bl2 & regres(insn,hex));
      when IADD => return(tostf(pc) & bb & "add" & bl2 & regres(insn,dec));
      when IOR  => 
	if ((i = '0') and (rs1 = "00000") and (rs2 = "00000")) then
	  return(tostf(pc) & bb & "clr" & bl2 & ireg2st(rd));
	elsif ((i = '1') and (simm = "0000000000000")) or (rs1 = "00000") then
	  return(tostf(pc) & bb & "mov" & bl2 & regres(insn,hex));
	else
	  return(tostf(pc) & bb & "or " & bl2 & regres(insn,hex));
	end if;
      when IXOR => return(tostf(pc) & bb & "xor" & bl2 & regres(insn,hex));
      when ISUB => return(tostf(pc) & bb & "sub" & bl2 & regres(insn,dec));
      when ANDN => return(tostf(pc) & bb & "andn" & bl2 & regres(insn,hex));
      when ORN  => return(tostf(pc) & bb & "orn" & bl2 & regres(insn,hex));
      when IXNOR =>
	if ((i = '0') and ((rs1 = rd) or (rs2 = "00000"))) then
	  return(tostf(pc) & bb & "not" & bl2 & ireg2st(rd));
	else
	  return(tostf(pc) & bb & "xnor" & bl2 & ireg2st(rd));
	end if;
      when ADDX => return(tostf(pc) & bb & "addx" & bl2 & regres(insn,dec));
      when SUBX => return(tostf(pc) & bb & "subx" & bl2 & regres(insn,dec));
      when ADDCC => return(tostf(pc) & bb & "addcc" & bl2 & regres(insn,dec));
      when ANDCC => return(tostf(pc) & bb & "andcc" & bl2 & regres(insn,hex));
      when ORCC => return(tostf(pc) & bb & "orcc" & bl2 & regres(insn,hex));
      when XORCC => return(tostf(pc) & bb & "xorcc" & bl2 & regres(insn,hex));
      when SUBCC => return(tostf(pc) & bb & "subcc" & bl2 & regres(insn,dec));
      when ANDNCC => return(tostf(pc) & bb & "andncc" & bl2 & regres(insn,hex));
      when ORNCC => return(tostf(pc) & bb & "orncc" & bl2 & regres(insn,hex));
      when XNORCC => return(tostf(pc) & bb & "xnorcc" & bl2 & regres(insn,hex));
      when ADDXCC => return(tostf(pc) & bb & "addxcc" & bl2 & regres(insn,hex));
      when UMAC   => return(tostf(pc) & bb & "umac" & bl2 & regres(insn,dec));
      when SMAC   => return(tostf(pc) & bb & "smac" & bl2 & regres(insn,dec));
      when UMUL   => return(tostf(pc) & bb & "umul" & bl2 & regres(insn,dec));
      when SMUL   => return(tostf(pc) & bb & "smul" & bl2 & regres(insn,dec));
      when UMULCC => return(tostf(pc) & bb & "umulcc" & bl2 & regres(insn,dec));
      when SMULCC => return(tostf(pc) & bb & "smulcc" & bl2 & regres(insn,dec));
      when SUBXCC => return(tostf(pc) & bb & "subxcc" & bl2 & regres(insn,dec));
      when UDIV   => return(tostf(pc) & bb & "udiv" & bl2 & regres(insn,dec));
      when SDIV   => return(tostf(pc) & bb & "sdiv" & bl2 & regres(insn,dec));
      when UDIVCC => return(tostf(pc) & bb & "udivcc" & bl2 & regres(insn,dec));
      when SDIVCC => return(tostf(pc) & bb & "sdivcc" & bl2 & regres(insn,dec));
      when TADDCC => return(tostf(pc) & bb & "taddcc" & bl2 & regres(insn,dec));
      when TSUBCC => return(tostf(pc) & bb & "tsubcc" & bl2 & regres(insn,dec));
      when TADDCCTV => return(tostf(pc) & bb & "taddcctv" & bl2 & regres(insn,dec));
      when TSUBCCTV => return(tostf(pc) & bb & "tsubcctv" & bl2 & regres(insn,dec));
      when MULSCC => return(tostf(pc) & bb & "mulscc" & bl2 & regres(insn,dec));
      when ISLL => return(tostf(pc) & bb & "sll" & bl2 & regres(insn,dec));
      when ISRL => return(tostf(pc) & bb & "srl" & bl2 & regres(insn,dec));
      when ISRA => return(tostf(pc) & bb & "sra" & bl2 & regres(insn,dec));
      when RDY  => 
        if rs1 /= "00000" then
	  return(tostf(pc) & bb & "mov" & bl2 & "%asr" &
	         tostd(rs1) & ", " & ireg2st(rd));
	else
	  return(tostf(pc) & bb & "mov" & bl2 & "%y, " & ireg2st(rd));
        end if;
      when RDPSR  => return(tostf(pc) & bb & "mov" & bl2 & "%psr, " & ireg2st(rd));
      when RDWIM  => return(tostf(pc) & bb & "mov" & bl2 & "%wim, " & ireg2st(rd));
      when RDTBR  => return(tostf(pc) & bb & "mov" & bl2 & "%tbr, " & ireg2st(rd));
      when WRY  =>
	if (rs1 = "00000") or (rs2 = "00000") then
          if rd /= "00000" then
	    return(tostf(pc) & bb & "mov" & bl2
	         & regimm(insn,hex,false) & ", %asr" & tostd(rd));
	  else
	    return(tostf(pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %y");
	  end if;
	else
          if rd /= "00000" then
	    return(tostf(pc) & bb & "wr " & bl2 & "%asr" 
	         & regimm(insn,hex,false) & ", %asr" & tostd(rd));
	  else
	    return(tostf(pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %y");
	  end if;
	end if;
      when WRPSR  =>
	if (rs1 = "00000") or (rs2 = "00000") then
	  return(tostf(pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %psr");
	else
	  return(tostf(pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %psr");
	end if;
      when WRWIM  =>
	if (rs1 = "00000") or (rs2 = "00000") then
	  return(tostf(pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %wim");
	else
	  return(tostf(pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %wim");
	end if;
      when WRTBR  =>
	if (rs1 = "00000") or (rs2 = "00000") then
	  return(tostf(pc) & bb & "mov" & bl2 & regimm(insn,hex,false) & ", %tbr");
	else
	  return(tostf(pc) & bb & "wr " & bl2 & regimm(insn,hex,false) & ", %tbr");
	end if;
      when JMPL => 
	if (rd = "00000") then
	  if (i = '1') and (simm = "0000000001000") then
	    if (rs1 = "11111") then return(tostf(pc) & bb & "ret");
	    elsif (rs1 = "01111") then return(tostf(pc) & bb & "retl");
	    else return(tostf(pc) & bb & "jmp" & bl2 & regimm(insn,dec,true));
	    end if;
	  else return(tostf(pc) & bb & "jmp" & bl2 & regimm(insn,dec,true));
	  end if;
	else return(tostf(pc) & bb & "jmpl" & bl2 & regres(insn,dec));
	end if;
      when TICC => 
        return(tostf(pc) & bb & 't' & branchop(insn) & bl2 & regimm(insn,hex,false));
      when FLUSH => 
        return(tostf(pc) & bb & "flush" & bl2 & regimm(insn,hex,false));
      when RETT => 
        return(tostf(pc) & bb & "rett" & bl2 & regimm(insn,dec,true));
      when RESTORE => 
	if (rd = "00000") then
	  return(tostf(pc) & bb & "restore");
	else
	  return(tostf(pc) & bb & "restore" & bl2 & regres(insn,hex));
	end if;
      when SAVE => 
	if (rd = "00000") then return(tostf(pc) & bb & "save");
	else return(tostf(pc) & bb & "save" & bl2 & regres(insn,dec)); end if;
      when FPOP1 => 
        case opf is
	when FITOS => return(tostf(pc) & bb & "fitos" & bl2 & freg2(insn));
	when FITOD => return(tostf(pc) & bb & "fitod" & bl2 & freg2(insn));
	when FSTOI => return(tostf(pc) & bb & "fstoi" & bl2 & freg2(insn));                      
	when FDTOI => return(tostf(pc) & bb & "fdtoi" & bl2 & freg2(insn));                      
	when FSTOD => return(tostf(pc) & bb & "fstod" & bl2 & freg2(insn));
	when FDTOS => return(tostf(pc) & bb & "fdtos" & bl2 & freg2(insn));
	when FMOVS => return(tostf(pc) & bb & "fmovs" & bl2 & freg2(insn));
	when FNEGS => return(tostf(pc) & bb & "fnegs" & bl2 & freg2(insn));
	when FABSS => return(tostf(pc) & bb & "fabss" & bl2 & freg2(insn));
	when FSQRTS => return(tostf(pc) & bb & "fsqrts" & bl2 & freg2(insn));
	when FSQRTD => return(tostf(pc) & bb & "fsqrtd" & bl2 & freg2(insn));
	when FADDS => return(tostf(pc) & bb & "fadds" & bl2 & freg3(insn));
	when FADDD => return(tostf(pc) & bb & "faddd" & bl2 & freg3(insn));
	when FSUBS => return(tostf(pc) & bb & "fsubs" & bl2 & freg3(insn));
	when FSUBD => return(tostf(pc) & bb & "fsubd" & bl2 & freg3(insn));
	when FMULS => return(tostf(pc) & bb & "fmuls" & bl2 & freg3(insn));
	when FMULD => return(tostf(pc) & bb & "fmuld" & bl2 & freg3(insn));
	when FSMULD => return(tostf(pc) & bb & "fsmuld" & bl2 & freg3(insn));
	when FDIVS => return(tostf(pc) & bb & "fdivs" & bl2 & freg3(insn));
	when FDIVD => return(tostf(pc) & bb & "fdivd" & bl2 & freg3(insn));
        when others => return(tostf(pc) & bb & "unknown FOP1: " & tost(op));
	end case;
      when FPOP2 => 
        case opf is
	when FCMPS => return(tostf(pc) & bb & "fcmps" & bl2 & fregc(insn));
	when FCMPD => return(tostf(pc) & bb & "fcmpd" & bl2 & fregc(insn));
	when FCMPES => return(tostf(pc) & bb & "fcmpes" & bl2 & fregc(insn));
	when FCMPED => return(tostf(pc) & bb & "fcmped" & bl2 & fregc(insn));
        when others => return(tostf(pc) & bb & "unknown FOP2: " & tost(insn.op));
	end case;
      when CPOP1 => 
	return(tostf(pc) & bb & "cpop1" & bl2 & tost("000"&opf) & ", " &creg3(insn));
      when CPOP2 => 
	return(tostf(pc) & bb & "cpop2" & bl2 & tost("000"&opf) & ", " &creg3(insn));
      when others => return(tostf(pc) & bb & "unknown opcode: " & tost(insn.op));
      end case;
    when LDST =>
      case op3 is
      when STC => 
	return(tostf(pc) & bb & "st" & bl2 & stparcp(insn, rd, dec));
      when STF => 
	return(tostf(pc) & bb & "st" & bl2 & stparf(insn, rd, dec));
      when ST => 
	if rd = "00000" then
	  return(tostf(pc) & bb & "clr" & bl2 & stparc(insn, rd, dec));
	else
	  return(tostf(pc) & bb & "st" & bl2 & stpar(insn, rd, dec));
	end if;
      when STB => 
	if rd = "00000" then
	  return(tostf(pc) & bb & "clrb" & bl2 & stparc(insn, rd, dec));
	else
	  return(tostf(pc) & bb & "stb" & bl2 & stpar(insn, rd, dec));
	end if;
      when STH => 
	if rd = "00000" then
	  return(tostf(pc) & bb & "clrh" & bl2 & stparc(insn, rd, dec));
	else
	  return(tostf(pc) & bb & "sth" & bl2 & stpar(insn, rd, dec));
	end if;
      when STDC => 
	return(tostf(pc) & bb & "std" & bl2 & stparcp(insn, rd, dec));
      when STDF => 
	return(tostf(pc) & bb & "std" & bl2 & stparf(insn, rd, dec));
      when STCSR => 
	return(tostf(pc) & bb & "st" & bl2 & "%csr, [" & regimm(insn,dec,true) & "]");
      when STFSR => 
	return(tostf(pc) & bb & "st" & bl2 & "%fsr, [" & regimm(insn,dec,true) & "]");
      when STDCQ => 
	return(tostf(pc) & bb & "std" & bl2 & "%cq, [" & regimm(insn,dec,true) & "]");
      when STDFQ => 
	return(tostf(pc) & bb & "std" & bl2 & "%fq, [" & regimm(insn,dec,true) & "]");
      when ISTD => 
	return(tostf(pc) & bb & "std" & bl2 & stpar(insn, rd, dec));
      when STA => 
	return(tostf(pc) & bb & "sta" & bl2 & stpara(insn, rd, dec));
      when STBA => 
	return(tostf(pc) & bb & "stba" & bl2 & stpara(insn, rd, dec));
      when STHA => 
	return(tostf(pc) & bb & "stha" & bl2 & stpara(insn, rd, dec));
      when STDA => 
	return(tostf(pc) & bb & "stda" & bl2 & stpara(insn, rd, dec));
      when LDC => 
	return(tostf(pc) & bb & "ld" & bl2 & ldparcp(insn, rd, dec));
      when LDF => 
	return(tostf(pc) & bb & "ld" & bl2 & ldparf(insn, rd, dec));
      when LDCSR => 
	return(tostf(pc) & bb & "ld" & bl2 & "[" & regimm(insn,dec,true) & "]" & ", %csr");
      when LDFSR => 
	return(tostf(pc) & bb & "ld" & bl2 & "[" & regimm(insn,dec,true) & "]" & ", %fsr");
      when LD => 
	return(tostf(pc) & bb & "ld" & bl2 & ldpar(insn, rd, dec));
      when LDUB => 
	return(tostf(pc) & bb & "ldub" & bl2 & ldpar(insn, rd, dec));
      when LDUH => 
	return(tostf(pc) & bb & "lduh" & bl2 & ldpar(insn, rd, dec));
      when LDDC => 
	return(tostf(pc) & bb & "ldd" & bl2 & ldparcp(insn, rd, dec));
      when LDDF => 
	return(tostf(pc) & bb & "ldd" & bl2 & ldparf(insn, rd, dec));
      when LDD => 
	return(tostf(pc) & bb & "ldd" & bl2 & ldpar(insn, rd, dec));
      when LDSB => 
	return(tostf(pc) & bb & "ldsb" & bl2 & ldpar(insn, rd, dec));
      when LDSH => 
	return(tostf(pc) & bb & "ldsh" & bl2 & ldpar(insn, rd, dec));
      when LDSTUB => 
	return(tostf(pc) & bb & "ldstub" & bl2 & ldpar(insn, rd, dec));
      when SWAP   => 
	return(tostf(pc) & bb & "swap" & bl2 & ldpar(insn, rd, dec));
      when LDA => 
	return(tostf(pc) & bb & "lda" & bl2 & ldpara(insn, rd, dec));
      when LDUBA => 
	return(tostf(pc) & bb & "lduba" & bl2 & ldpara(insn, rd, dec));
      when LDUHA => 
	return(tostf(pc) & bb & "lduha" & bl2 & ldpara(insn, rd, dec));
      when LDDA => 
	return(tostf(pc) & bb & "ldda" & bl2 & ldpara(insn, rd, dec));
      when LDSBA => 
	return(tostf(pc) & bb & "ldsba" & bl2 & ldpara(insn, rd, dec));
      when LDSHA => 
	return(tostf(pc) & bb & "ldsha" & bl2 & ldpara(insn, rd, dec));
      when LDSTUBA => 
	return(tostf(pc) & bb & "ldstuba" & bl2 & ldpara(insn, rd, dec));
      when SWAPA   => 
	return(tostf(pc) & bb & "swapa" & bl2 & ldpara(insn, rd, dec));

      when others => return(tostf(pc) & bb & "unknown opcode: " & tost(op));
      end case;
    when others => return(tostf(pc) & bb & "unknown opcode: " & tost(op));
    end case;
end;

procedure print_insn(ndx: integer; pc, op, res : std_logic_vector(31 downto 0);
	 valid, trap, wr, rest : boolean) is
variable t : integer;
begin
  if valid then
    t := now / 1 ns;
    if trap then print (tost(t) & " cpu" & tost(ndx) &": " & ins2st(pc, op) & "  (trapped)");
    elsif rest then print (tost(t) & " cpu" & tost(ndx) &": " & ins2st(pc, op) & "  (restart)");
    elsif wr then print (tost(t) & " cpu" & tost(ndx) & ": " & ins2st(pc, op) & "  [" & tost(res) & "]");
    else print (tost(t) & " cpu" & tost(ndx) & ": " & ins2st(pc, op)); end if;
  end if;
end;

procedure print_fpinsn(ndx: integer; pc, op : std_logic_vector(31 downto 0);
                       res : std_logic_vector(63 downto 0);
                       dpres, valid, trap, wr : boolean) is
variable t : integer;
begin
  if valid then
    t := now / 1 ns;
    if trap then print (tost(t) & " cpu" & tost(ndx) &": " & ins2st(pc, op) & "  (trapped)");
    elsif wr then
      if dpres then print (tost(t) & " cpu" & tost(ndx) & ": " & ins2st(pc, op) & "  [" & tost(res) & "]");
      else print (tost(t) & " cpu" & tost(ndx) & ": " & ins2st(pc, op) & "  [" & tost(res(63 downto 32)) & "]"); end if;
    else print (tost(t) & " cpu" & tost(ndx) & ": " & ins2st(pc, op)); end if;
  end if;
end;

end;
-- pragma translate_on
