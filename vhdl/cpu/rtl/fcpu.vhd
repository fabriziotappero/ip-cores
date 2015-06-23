--------------------------------------------------------------------------------
-- MIPS™ I CPU - Functions                                                    --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mips1.all;
use work.tcpu.all;

package fcpu is

   -----------------------------------------------------------------------------
   -- ALU                                                                     --
   -----------------------------------------------------------------------------
   function addsub (l,r : std_logic_vector; op : alu_op_t)
      return std_logic_vector;
   function fslt (l,r : std_logic_vector) return std_logic_vector;
   function fsltu (l,r : std_logic_vector) return std_logic_vector;
   function fsll (l,s : std_logic_vector) return std_logic_vector;
   function fsrl (l,s : std_logic_vector) return std_logic_vector;
   function fsra (l,s : std_logic_vector) return std_logic_vector;

   -----------------------------------------------------------------------------
   -- Extend                                                                  --
   -----------------------------------------------------------------------------
   function zext (a : std_logic_vector; l : integer) return std_logic_vector;
   function sext (a : std_logic_vector; l : integer) return std_logic_vector;

   -----------------------------------------------------------------------------
   -- Decode                                                                  --
   -----------------------------------------------------------------------------
   function link (v_i : de_t) return de_t;
   function load (v_i : de_t) return de_t;
   function store (v_i : de_t) return de_t;
   function simm (v_i : de_t) return de_t;
   function zimm (v_i : de_t) return de_t;

   -----------------------------------------------------------------------------
   -- Clear Pipeline                                                          --
   -----------------------------------------------------------------------------
   function clear (v_i : fe_t) return fe_t;
   function clear (v_i : de_t) return de_t;
   function clear (v_i : ex_t) return ex_t;
   function clear (v_i : me_t) return me_t;

   -----------------------------------------------------------------------------
   -- Co-Processor 0                                                          --
   -----------------------------------------------------------------------------
   function clear (v_i : cp0_t) return cp0_t;
   function push_ie(v_i : cp0_t) return cp0_t;
   function pop_ie(v_i : cp0_t) return cp0_t;
   --function set_sr(v_i : cp0_t; v_j : comb_cp0_t) return cp0_t;
   function get_sr(v_i : cp0_t) return std_logic_vector;
end fcpu;

package body fcpu is

   -----------------------------------------------------------------------------
   -- Adder/Subtractor (signed)                                               --
   -----------------------------------------------------------------------------
   -- Compound Adder/Subtractor (saves LUTs).
   function addsub (l,r : std_logic_vector; op : alu_op_t)
   return std_logic_vector is
   begin
      case op is
         when ADD | ADDU => return std_logic_vector(signed(l) + signed(r));
         when others     => return std_logic_vector(signed(l) - signed(r));
      end case;
   end addsub;

   -----------------------------------------------------------------------------
   -- Set Less Than Functions                                                 --
   -----------------------------------------------------------------------------
   function fslt (l,r : std_logic_vector) return std_logic_vector is
      variable o : std_logic_vector(l'length-1 downto 0) := (others => '0');
   begin
      if signed(l) < signed(r) then o(0) := '1'; end if;
      return o;
   end fslt;

   function fsltu (l,r : std_logic_vector) return std_logic_vector is
      variable o : std_logic_vector(l'length-1 downto 0) := (others => '0');
   begin
      if unsigned(l) < unsigned(r) then o(0) := '1'; end if;
      return o;
   end fsltu;

   -----------------------------------------------------------------------------
   -- Shift (Left, Right Logic, Right Arithmetic)                             --
   -----------------------------------------------------------------------------
   function fsll (l,s : std_logic_vector) return std_logic_vector is
      variable sh : natural range 0 to l'length-1;
   begin
      sh := to_integer(unsigned(s));
      return std_logic_vector(shift_left(unsigned(l), sh));
   end fsll;

   function fsrl (l,s : std_logic_vector) return std_logic_vector is
      variable sh : natural range 0 to l'length-1;
   begin
      sh := to_integer(unsigned(s));
      return std_logic_vector(shift_right(unsigned(l), sh));
   end fsrl;

   function fsra (l,s : std_logic_vector) return std_logic_vector is
      variable sh : natural range 0 to l'length-1;
   begin
      sh := to_integer(unsigned(s));
      return std_logic_vector(shift_right(signed(l), sh));
   end fsra;

   -----------------------------------------------------------------------------
   -- Extend                                                                  --
   -----------------------------------------------------------------------------
   -- Zero extend vector.
   function zext (a : std_logic_vector; l : integer) return std_logic_vector is
   begin
      return std_logic_vector(resize(unsigned(a), l));
   end zext;

   -- Sign extend vector.
   function sext (a : std_logic_vector; l : integer) return std_logic_vector is
   begin
      return std_logic_vector(resize(signed(a), l));
   end sext;

   -----------------------------------------------------------------------------
   -- Decode                                                                  --
   -----------------------------------------------------------------------------
   -- JAL, JRAL, BGEZAL, BLTZAL operations.
   function link (v_i : de_t) return de_t is
      variable v : de_t := v_i;
   begin
      v.ec.alu.op    := ADDU;
      v.ec.alu.src.a := ADD_4;
      v.ec.alu.src.b := PC;
      v.wc.we        := '1';
      return v;
   end link;

   -- Memory load operation setter.
   function load (v_i : de_t) return de_t is
      variable v : de_t := v_i;
   begin
      v.ec.wbr       := RT;
      v.ec.alu.op    := ADDU;
      v.ec.alu.src.b := SIGN;
      v.mc.src       := MEM;
      v.wc.we        := '1';
      return v;
   end load;

   -- Memory store operation setter.
   function store (v_i : de_t) return de_t is
      variable v : de_t := v_i;
   begin
      v.ec.alu.op    := ADDU;
      v.ec.alu.src.b := SIGN;
      v.mc.mem.we    := '1';
      return v;
   end store;

   -- Sign immediate operation setter.
   function simm (v_i : de_t) return de_t is
      variable v : de_t := v_i;
   begin
      v.ec.wbr       := RT;
      v.ec.alu.src.b := SIGN;
      v.wc.we        := '1';
      return v;
   end simm;

   -- Zero immediate operation setter.
   function zimm (v_i : de_t) return de_t is
      variable v : de_t := v_i;
   begin
      v.ec.wbr       := RT;
      v.ec.alu.src.b := ZERO;
      v.wc.we        := '1';
      return v;
   end zimm;

   -----------------------------------------------------------------------------
   -- Clear Pipeline                                                          --
   -----------------------------------------------------------------------------
   function clear (v_i : fe_t) return fe_t is
      variable v : fe_t := v_i;
   begin
      v.pc := (others => '0');
      return v;
   end clear;

   function clear (v_i : de_t) return de_t is
      variable v : de_t := v_i;
   begin
      v.cc.mtsr    := false;
      v.cc.rfe     := false;
      v.ec.jmp.op  := NOP;
      v.mc.mem.we  := '0';
      v.mc.mem.byt := NONE;
      v.wc.we      := '0';
      return v;
   end clear;

   function clear (v_i : ex_t) return ex_t is
      variable v : ex_t := v_i;
   begin
      v.f.jmp      := '0';
      v.mc.mem.we  := '0';
      v.mc.mem.byt := NONE;
      v.wc.we      := '0';
      return v;
   end clear;

   function clear (v_i : me_t) return me_t is
      variable v : me_t := v_i;
   begin
      v.wc.we := '0';
      return v;
   end clear;

   -----------------------------------------------------------------------------
   -- Co-Processor 0                                                          --
   -----------------------------------------------------------------------------
   -- Clear CP0 status register.
   function clear (v_i : cp0_t) return cp0_t is
      variable v : cp0_t := v_i;
   begin
      v.sr.im  := x"00";
      v.sr.iec := '0';
      v.sr.iep := '0';
      v.sr.ieo := '0';
      return v;
   end clear;

   -- Push interrupt enable stack.
   function push_ie(v_i : cp0_t) return cp0_t is
      variable v : cp0_t := v_i;
   begin
      v.sr.ieo := v_i.sr.iep;
      v.sr.iep := v_i.sr.iec;
      v.sr.iec := '0';
      return v;
   end push_ie;

   -- Pop interrupt enable stack.
   function pop_ie(v_i : cp0_t) return cp0_t is
      variable v : cp0_t := v_i;
   begin
      v.sr.iec := v_i.sr.iep;
      v.sr.iep := v_i.sr.ieo;
      return v;
   end pop_ie;

   -- Get status register.
   function get_sr(v_i : cp0_t) return std_logic_vector is
      variable v : std_logic_vector(31 downto 0) := (others => '0');
   begin
      v(15 downto 8) := v_i.sr.im;
      v(0)           := v_i.sr.iec;
      v(2)           := v_i.sr.iep;
      v(4)           := v_i.sr.ieo;
      return v;
   end get_sr;

end fcpu;