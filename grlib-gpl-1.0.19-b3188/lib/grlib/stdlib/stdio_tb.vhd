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

library  Std;
use      Std.Standard.all;
use      Std.TextIO.all;

library  IEEE;
use      IEEE.Std_Logic_1164.all;

library  GRLIB;
use      GRLIB.StdIO.all;

entity StdIO_TB is
end entity StdIO_TB;

architecture Behavioural of StdIO_TB is
begin
   process
      variable LW:      Line;
      variable LR:      Line;

      file     WFile:   Text;
      file     RFile:   Text;

      constant SUL:     Std_ULogic        := 'H';
      constant SL:      Std_Logic         := 'L';

      constant SULV1:   Std_ULogic_Vector := "1";
      constant SULV2:   Std_ULogic_Vector := "10";
      constant SULV3:   Std_ULogic_Vector := "011";
      constant SULV4:   Std_ULogic_Vector := "0100";
      constant SULV5:   Std_ULogic_Vector := "00101";
      constant SULV6:   Std_ULogic_Vector := "000110";
      constant SULV7:   Std_ULogic_Vector := "0000111";
      constant SULV8:   Std_ULogic_Vector := "00001000";
      constant SULV9:   Std_ULogic_Vector := "000001001";

      constant SULVA:   Std_ULogic_Vector := "00000001001000110100010101100111";
      constant SULVB:   Std_ULogic_Vector := "10001001101010111100110111101111";

      variable SULVC:   Std_ULogic_Vector(0 to 3);
      variable SULVD:   Std_ULogic_Vector(0 to 7);
      variable SULVE:   Std_ULogic_Vector(0 to 15);
      variable SULVF:   Std_ULogic_Vector(0 to 16);

      constant SLVA:    Std_Logic_Vector  := "00000001001000110100010101100111";
      constant SLVB:    Std_Logic_Vector  := "10001001101010111100110111101111";
      variable SLVC:    Std_Logic_Vector(0 to 7);
      variable SLVD:    Std_Logic_Vector(0 to 15);

   begin
      Write(LW, SUL);
      WriteLine(Output, LW);
      Write(LW, SL);
      WriteLine(Output, LW);

      HWrite(LW, SULV1);
      WriteLine(Output, LW);
      HWrite(LW, SULV2);
      WriteLine(Output, LW);
      HWrite(LW, SULV3);
      WriteLine(Output, LW);
      HWrite(LW, SULV4);
      WriteLine(Output, LW);
      HWrite(LW, SULV5);
      WriteLine(Output, LW);
      HWrite(LW, SULV6);
      WriteLine(Output, LW);
      HWrite(LW, SULV7);
      WriteLine(Output, LW);
      HWrite(LW, SULV8);
      WriteLine(Output, LW);
      HWrite(LW, SULV9);
      WriteLine(Output, LW);
      HWrite(LW, SULVA);
      WriteLine(Output, LW);
      HWrite(LW, SULVB);
      WriteLine(Output, LW);

      File_Open(WFile, "file.txt", Write_Mode);
      HWrite(LW, SULVA);
      WriteLine(WFile, LW);
      HWrite(LW, SULVB);
      WriteLine(WFile, LW);
      HWrite(LW, SULVA);
      WriteLine(WFile, LW);
      HWrite(LW, SULVB);
      WriteLine(WFile, LW);
      HWrite(LW, SLVA);
      WriteLine(WFile, LW);
      HWrite(LW, SLVB);
      WriteLine(WFile, LW);
      File_Close(WFile);


      File_Open(RFile, "file.txt", Read_Mode);
      ReadLine(RFile, LR);
      HRead(LR, SULVC);
      HWrite(LW, SULVC);
      WriteLine(Output, LW);

      ReadLine(RFile, LR);
      HRead(LR, SULVD);
      HWrite(LW, SULVD);
      WriteLine(Output, LW);

      ReadLine(RFile, LR);
      HRead(LR, SULVE);
      HWrite(LW, SULVE);
      WriteLine(Output, LW);

      ReadLine(RFile, LR);
      HRead(LR, SULVF);
      HWrite(LW, SULVF);
      WriteLine(Output, LW);

      ReadLine(RFile, LR);
      HRead(LR, SLVC);
      HWrite(LW, SLVC);
      WriteLine(Output, LW);

      ReadLine(RFile, LR);
      HRead(LR, SLVD);
      HWrite(LW, SLVD);
      WriteLine(Output, LW);

      File_Close(RFile);
      wait;
   end process;

end architecture Behavioural;
