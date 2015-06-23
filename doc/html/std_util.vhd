-- <File header>
-- Project
--    pAVR (pipelined AVR) is an 8 bit RISC controller, compatible with Atmel's
--    AVR core, but about 3x faster in terms of both clock frequency and MIPS.
--    The increase in speed comes from a relatively deep pipeline. The original
--    AVR core has only two pipeline stages (fetch and execute), while pAVR has
--    6 pipeline stages:
--       1. PM    (read Program Memory)
--       2. INSTR (load Instruction)
--       3. RFRD  (decode Instruction and read Register File)
--       4. OPS   (load Operands)
--       5. ALU   (execute ALU opcode or access Unified Memory)
--       6. RFWR  (write Register File)
-- Version
--    0.32
-- Date
--    2002 August 07
-- Author
--    Doru Cuturela, doruu@yahoo.com
-- License
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-- </File header>



-- <File info>
-- This file contains:
--    - Type conversion routines ofted used throughout the other source files in
--       this project
--    - Basic arithmetic functions
--       *** Multiplication is not yet defined! It will be defined here.
--    - Sign and zero-extend functions
--    - Vector comparision function
-- </File info>



-- <File body>
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;



package std_util is
   function std_logic_vector_to_int(vec: std_logic_vector) return integer;
   function std_logic_vector_to_nat(vec: std_logic_vector) return natural;
   function int_to_std_logic_vector(i, len: integer) return std_logic_vector;

   function "+"(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;
   function "+"(a: std_logic_vector; b: integer) return std_logic_vector;
   function "-"(a: std_logic_vector; b: std_logic_vector) return std_logic_vector;
   function "-"(a: std_logic_vector; b: integer) return std_logic_vector;

   function sign_extend(a: std_logic_vector; wxtd: natural) return std_logic_vector;
   function zero_extend(a: std_logic_vector; wxtd: natural) return std_logic_vector;

   function cmp_std_logic_vector(a: std_logic_vector; b: std_logic_vector) return std_logic;
end;



package body std_util is

   function std_logic_vector_to_int(vec: std_logic_vector) return integer is
      variable i: integer;
   begin
      i := conv_integer(vec);
      return(i);
   end;


   function std_logic_vector_to_nat(vec: std_logic_vector) return natural is
      variable tmp: std_logic_vector(vec'length downto 0);
      variable n: natural;
   begin
      assert (vec'length < 32)
         report "Error: vector length > 31 in function `std_logic_vector_to_nat'."
         severity failure;
      tmp := '0' & vec;
      n := conv_integer(tmp);
      return(n);
   end;


   function int_to_std_logic_vector(i, len: integer) return std_logic_vector is
      variable r: std_logic_vector(len - 1 downto 0);
      variable r1: std_logic_vector(len downto 0);
   begin
      r1 := conv_std_logic_vector(i, len + 1);
      r := r1(len - 1 downto 0);
      return(r);
   end;


   function "+"(a: std_logic_vector; b: std_logic_vector) return std_logic_vector is
   begin
      return(signed(a) + signed(b));
   end;


   function "+"(a: std_logic_vector; b: integer) return std_logic_vector is
   begin
      return(signed(a) + b);
   end;


   function "-"(a: std_logic_vector; b: std_logic_vector) return std_logic_vector is
   begin
      return(signed(a) - signed(b));
   end;


   function "-"(a: std_logic_vector; b: integer) return std_logic_vector is
   begin
      return (signed(a) - b);
   end;


   function sign_extend(a: std_logic_vector; wxtd: natural) return std_logic_vector is
      variable r: std_logic_vector(wxtd - 1 downto 0);
   begin
      assert (a'length <= wxtd)
         report "Error: vector length > extended vector length in function `sign_extend'."
         severity failure;
      for i in 0 to a'length-1 loop
         r(i) := a(i);
      end loop;
      for i in a'length to wxtd - 1 loop
         r(i) := a(a'length - 1);
      end loop;
      return r;
   end;


   function zero_extend(a: std_logic_vector; wxtd: natural) return std_logic_vector is
      variable r: std_logic_vector(wxtd - 1 downto 0);
   begin
      assert (a'length <= wxtd)
         report "Error: vector length > extended vector length in function `sign_extend'."
         severity failure;
      for i in 0 to a'length-1 loop
         r(i) := a(i);
      end loop;
      for i in a'length to wxtd - 1 loop
         r(i) := '0';
      end loop;
      return r;
   end;


   function cmp_std_logic_vector(a: std_logic_vector; b: std_logic_vector) return std_logic is
      variable r: std_logic;
   begin
      assert (a'length = b'length)
         report "Error: vectors don't have the same length in function `cmp_std_logic_vector'."
         severity failure;
      r := '1';
      for i in 0 to a'length - 1 loop
         if (a(i) /= b(i)) then
            r := '0';
         end if;
      end loop;
      return r;
   end;

end;
-- </File body>
