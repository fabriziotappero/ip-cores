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
--------------------------------------------------------------------------------
-- Package:       StdIO
-- File:          stdio.vhd
-- Author:        Gaisler Research
-- Description:   Package for common I/O functions
--------------------------------------------------------------------------------

-- pragma translate_off
library  Std;
use      Std.Standard.all;
use      Std.TextIO.all;

library  IEEE;
use      IEEE.Std_Logic_1164.all;
-- pragma translate_on

package StdIO is

-- pragma translate_off
   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_ULogic_Vector;
      variable GOOD:       out   Boolean);

   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_ULogic_Vector);

   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_Logic_Vector;
      variable GOOD:       out   Boolean);

   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_Logic_Vector);

   procedure HWrite(
      variable L:          inout Line;
      constant VALUE:      in    Std_ULogic_Vector;
      constant JUSTIFIED:  in    SIDE  := RIGHT;
      constant FIELD:      in    WIDTH := 0);

   procedure HWrite(
      variable L:          inout Line;
      constant VALUE:      in    Std_Logic_Vector;
      constant JUSTIFIED:  in    SIDE  := RIGHT;
      constant FIELD:      in    WIDTH := 0);

   procedure Write(
      variable L:          inout Line;
      constant VALUE:      in    Std_ULogic;
      constant JUSTIFIED:  in    SIDE  := RIGHT;
      constant FIELD:      in    WIDTH := 0);
-- pragma translate_on

end package StdIO;

package body StdIO is
-- pragma translate_off

   function ToChar(N: Std_ULogic_Vector(0 to 3)) return Character is
   begin
     case N is
        when "0000"  => return('0');
        when "0001"  => return('1');
        when "0010"  => return('2');
        when "0011"  => return('3');
        when "0100"  => return('4');
        when "0101"  => return('5');
        when "0110"  => return('6');
        when "0111"  => return('7');
        when "1000"  => return('8');
        when "1001"  => return('9');
        when "1010"  => return('A');
        when "1011"  => return('B');
        when "1100"  => return('C');
        when "1101"  => return('D');
        when "1110"  => return('E');
        when "1111"  => return('F');
        when others  => return('X');
     end case;
   end ToChar;

   function FromChar(C: Character) return Std_ULogic_Vector is
      variable R:       Std_ULogic_Vector(0 to 3);
   begin
      case C is
         when '0'    => R := "0000";
         when '1'    => R := "0001";
         when '2'    => R := "0010";
         when '3'    => R := "0011";
         when '4'    => R := "0100";
         when '5'    => R := "0101";
         when '6'    => R := "0110";
         when '7'    => R := "0111";
         when '8'    => R := "1000";
         when '9'    => R := "1001";

         when 'A'    => R := "1010";
         when 'B'    => R := "1011";
         when 'C'    => R := "1100";
         when 'D'    => R := "1101";
         when 'E'    => R := "1110";
         when 'F'    => R := "1111";

         when 'a'    => R := "1010";
         when 'b'    => R := "1011";
         when 'c'    => R := "1100";
         when 'd'    => R := "1101";
         when 'e'    => R := "1110";
         when 'f'    => R := "1111";
         when others => R := "XXXX";
      end case;
   return R;
   end FromChar;

   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_ULogic_Vector;
      variable GOOD:       out   Boolean) is

      variable B:                Boolean;
      variable C:                Character;
      constant SL:               Integer := VALUE'Length;
      variable SV:               Std_ULogic_Vector(0 to SL-1);
      variable S:                String(1 to SL/4-1);
   begin
      if VALUE'Length mod 4 /= 0 then
         GOOD     := False;
         SV       := (others => 'X');
         VALUE    := SV;
         return;
      end if;

      loop
         Read(L, C, B);
         exit when ((C /= ' ') and (C /= CR) and (C /= HT)) or (not B);
      end loop;

      SV(0 to 3) := FromChar(C);
      if Is_X(SV(0 to 3)) or (not B) then
         GOOD     := False;
         SV       := (others => 'X');
         VALUE    := SV;
         return;
      end if;

      Read(L, S, B);
      if not B then
         GOOD     := False;
         SV       := (others => 'X');
         VALUE    := SV;
         return;
      end if;

      for i in 1 to SL/4-1 loop
         SV(4*i to 4*i+3) := FromChar(S(i));
         if Is_X(SV(4*i to 4*i+3)) then
            GOOD     := False;
            SV       := (others => 'X');
            VALUE    := SV;
            return;
         end if;
      end loop;
      GOOD        := True;
      VALUE       := SV;
   end HRead;

   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_ULogic_Vector) is
      variable GOOD:             Boolean;
   begin
      HRead(L, VALUE, GOOD);
      assert GOOD
         report "HREAD: access incorrect";
   end HRead;

   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_Logic_Vector;
      variable GOOD:       out   Boolean) is
      variable V:                Std_ULogic_Vector(0 to Value'Length-1);
   begin
      HRead(L, V, GOOD);
      VALUE := Std_Logic_Vector(V);
   end HRead;

   procedure HRead(
      variable L:          inout Line;
      variable VALUE:      out   Std_Logic_Vector) is
      variable GOOD:             Boolean;
      variable V:                Std_ULogic_Vector(0 to Value'Length-1);
   begin
      HRead(L, V, GOOD);
      VALUE := Std_Logic_Vector(V);
      assert GOOD
         report "HREAD: access incorrect";
   end HRead;

   procedure HWrite(
      variable L:          inout Line;
      constant VALUE:      in    Std_ULogic_Vector;
      constant JUSTIFIED:  in    SIDE     := RIGHT;
      constant FIELD:      in    WIDTH    := 0) is

      constant PL:               Integer  := 4-(VALUE'Length mod 4);
      constant PV:               Std_ULogic_Vector(1 to PL) := (others => '0');
      constant TL:               Integer  := PL + VALUE'Length;
      constant TV:               Std_ULogic_Vector(0 to TL-1) := PV & Value;
      variable S:                String(1 to TL/4);
   begin
      if PL /= 4 then
         for i in 0 to TL/4 -1 loop
            S(i+1) :=  ToChar(TV(4*i to 4*i+3));
         end loop;
         Write(L, S(1 to TL/4), JUSTIFIED, FIELD);
      else
         for i in 1 to TL/4 -1 loop
            S(i+1) :=  ToChar(TV(4*i to 4*i+3));
         end loop;
         Write(L, S(2 to TL/4), JUSTIFIED, FIELD);
      end if;
   end HWrite;

   procedure HWrite(
      variable L:          inout Line;
      constant VALUE:      in    Std_Logic_Vector;
      constant JUSTIFIED:  in    SIDE  := RIGHT;
      constant FIELD:      in    WIDTH := 0) is
   begin
      HWrite(L, Std_ULogic_Vector(VALUE), JUSTIFIED, FIELD);
   end HWrite;

   procedure Write(
      variable L:          inout Line;
      constant VALUE:      in    Std_ULogic;
      constant JUSTIFIED:  in    SIDE  := RIGHT;
      constant FIELD:      in    WIDTH := 0) is

   type     Char_Array  is array (Std_ULogic) of Character;
      constant ToChar:           Char_Array := "UX01ZWLH-";
   begin
      Write(L, ToChar(VALUE), JUSTIFIED, FIELD);
   end Write;

-- pragma translate_on
end package body StdIO;
