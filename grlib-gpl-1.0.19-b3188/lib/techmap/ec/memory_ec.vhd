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
-- Entity:  various
-- File:    mem_ec_gen.vhd
-- Author:  Jiri Gaisler - Gaisler Research
-- Description: Memory generators for Lattice XP/EC/ECP RAM blocks
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.dp8ka;
-- pragma translate_on

entity EC_RAMB8_S1_S1 is
    port (
        DataInA: in  std_logic_vector(0 downto 0); 
        DataInB: in  std_logic_vector(0 downto 0); 
        AddressA: in  std_logic_vector(12 downto 0); 
        AddressB: in  std_logic_vector(12 downto 0); 
        ClockA: in  std_logic; 
        ClockB: in  std_logic; 
        ClockEnA: in  std_logic; 
        ClockEnB: in  std_logic; 
        WrA: in  std_logic; 
        WrB: in  std_logic; 
        QA: out  std_logic_vector(0 downto 0); 
        QB: out  std_logic_vector(0 downto 0));
end;

architecture Structure of EC_RAMB8_S1_S1 is
  COMPONENT dp8ka
  GENERIC(
        DATA_WIDTH_A : in Integer := 18;
        DATA_WIDTH_B : in Integer := 18;
        REGMODE_A    : String  := "NOREG";
        REGMODE_B    : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE_A   : String  := "000";
        CSDECODE_B   : String  := "000";
        WRITEMODE_A  : String  := "NORMAL";
        WRITEMODE_B  : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        dia0, dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8            : in std_logic := 'X';
        dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17    : in std_logic := 'X';
        ada0, ada1, ada2, ada3, ada4, ada5, ada6, ada7, ada8            : in std_logic := 'X';
        ada9, ada10, ada11, ada12                                       : in std_logic := 'X';
        cea, clka, wea, csa0, csa1, csa2, rsta                         : in std_logic := 'X';
        dib0, dib1, dib2, dib3, dib4, dib5, dib6, dib7, dib8            : in std_logic := 'X';
        dib9, dib10, dib11, dib12, dib13, dib14, dib15, dib16, dib17    : in std_logic := 'X';
        adb0, adb1, adb2, adb3, adb4, adb5, adb6, adb7, adb8            : in std_logic := 'X';
        adb9, adb10, adb11, adb12                                       : in std_logic := 'X';
        ceb, clkb, web, csb0, csb1, csb2, rstb                         : in std_logic := 'X';

        doa0, doa1, doa2, doa3, doa4, doa5, doa6, doa7, doa8            : out std_logic := 'X';
        doa9, doa10, doa11, doa12, doa13, doa14, doa15, doa16, doa17    : out std_logic := 'X';
        dob0, dob1, dob2, dob3, dob4, dob5, dob6, dob7, dob8            : out std_logic := 'X';
        dob9, dob10, dob11, dob12, dob13, dob14, dob15, dob16, dob17    : out std_logic := 'X'
  );
  END COMPONENT;

signal vcc, gnd : std_ulogic;
begin
  vcc <= '1'; gnd <= '0';
  u0: DP8KA
        generic map (CSDECODE_B=>"000", CSDECODE_A=>"000",
          WRITEMODE_B=>"NORMAL", WRITEMODE_A=>"NORMAL",
          GSR=>"DISABLED", RESETMODE=>"ASYNC", REGMODE_B=>"NOREG",
          REGMODE_A=>"NOREG", DATA_WIDTH_B=> 1, DATA_WIDTH_A=> 1)
        port map (CEA=>ClockEnA, CLKA=>ClockA, WEA=>WrA, CSA0=>gnd, 
            CSA1=>gnd, CSA2=>gnd, RSTA=>gnd, 
            CEB=>ClockEnB, CLKB=>ClockB, WEB=>WrB, CSB0=>gnd, 
            CSB1=>gnd, CSB2=>gnd, RSTB=>gnd, 
            DIA0=>gnd, DIA1=>gnd, DIA2=>gnd, 
            DIA3=>gnd, DIA4=>gnd, DIA5=>gnd, 
            DIA6=>gnd, DIA7=>gnd, DIA8=>gnd, 
            DIA9=>gnd, DIA10=>gnd, DIA11=>DataInA(0), 
            DIA12=>gnd, DIA13=>gnd, DIA14=>gnd, 
            DIA15=>gnd, DIA16=>gnd, DIA17=>gnd, 
            ADA0=>AddressA(0), ADA1=>AddressA(1), ADA2=>AddressA(2), 
            ADA3=>AddressA(3), ADA4=>AddressA(4), ADA5=>AddressA(5), 
            ADA6=>AddressA(6), ADA7=>AddressA(7), ADA8=>AddressA(8), 
            ADA9=>AddressA(9), ADA10=>AddressA(10), ADA11=>AddressA(11), 
            ADA12=>AddressA(12), DIB0=>gnd, DIB1=>gnd, 
            DIB2=>gnd, DIB3=>gnd, DIB4=>gnd, 
            DIB5=>gnd, DIB6=>gnd, DIB7=>gnd, 
            DIB8=>gnd, DIB9=>gnd, DIB10=>gnd, 
            DIB11=>DataInB(0), DIB12=>gnd, DIB13=>gnd, 
            DIB14=>gnd, DIB15=>gnd, DIB16=>gnd, 
            DIB17=>gnd, ADB0=>AddressB(0), ADB1=>AddressB(1), 
            ADB2=>AddressB(2), ADB3=>AddressB(3), ADB4=>AddressB(4), 
            ADB5=>AddressB(5), ADB6=>AddressB(6), ADB7=>AddressB(7), 
            ADB8=>AddressB(8), ADB9=>AddressB(9), ADB10=>AddressB(10), 
            ADB11=>AddressB(11), ADB12=>AddressB(12), DOA0=>QA(0),
            DOA1=>open, DOA2=>open, DOA3=>open, DOA4=>open, 
            DOA5=>open, DOA6=>open, DOA7=>open, DOA8=>open, 
            DOA9=>open, DOA10=>open, DOA11=>open, DOA12=>open, 
            DOA13=>open, DOA14=>open, DOA15=>open, DOA16=>open, 
            DOA17=>open, DOB0=>QB(0), DOB1=>open, DOB2=>open, 
            DOB3=>open, DOB4=>open, DOB5=>open, DOB6=>open, 
            DOB7=>open, DOB8=>open, DOB9=>open, DOB10=>open, 
            DOB11=>open, DOB12=>open, DOB13=>open, DOB14=>open, 
            DOB15=>open, DOB16=>open, DOB17=>open);
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.dp8ka;
-- pragma translate_on

entity EC_RAMB8_S2_S2 is
    port (
        DataInA: in  std_logic_vector(1 downto 0); 
        DataInB: in  std_logic_vector(1 downto 0); 
        AddressA: in  std_logic_vector(11 downto 0); 
        AddressB: in  std_logic_vector(11 downto 0); 
        ClockA: in  std_logic; 
        ClockB: in  std_logic; 
        ClockEnA: in  std_logic; 
        ClockEnB: in  std_logic; 
        WrA: in  std_logic; 
        WrB: in  std_logic; 
        QA: out  std_logic_vector(1 downto 0); 
        QB: out  std_logic_vector(1 downto 0));
end;

architecture Structure of EC_RAMB8_S2_S2 is
  COMPONENT dp8ka
  GENERIC(
        DATA_WIDTH_A : in Integer := 18;
        DATA_WIDTH_B : in Integer := 18;
        REGMODE_A    : String  := "NOREG";
        REGMODE_B    : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE_A   : String  := "000";
        CSDECODE_B   : String  := "000";
        WRITEMODE_A  : String  := "NORMAL";
        WRITEMODE_B  : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        dia0, dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8            : in std_logic := 'X';
        dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17    : in std_logic := 'X';
        ada0, ada1, ada2, ada3, ada4, ada5, ada6, ada7, ada8            : in std_logic := 'X';
        ada9, ada10, ada11, ada12                                       : in std_logic := 'X';
        cea, clka, wea, csa0, csa1, csa2, rsta                         : in std_logic := 'X';
        dib0, dib1, dib2, dib3, dib4, dib5, dib6, dib7, dib8            : in std_logic := 'X';
        dib9, dib10, dib11, dib12, dib13, dib14, dib15, dib16, dib17    : in std_logic := 'X';
        adb0, adb1, adb2, adb3, adb4, adb5, adb6, adb7, adb8            : in std_logic := 'X';
        adb9, adb10, adb11, adb12                                       : in std_logic := 'X';
        ceb, clkb, web, csb0, csb1, csb2, rstb                         : in std_logic := 'X';

        doa0, doa1, doa2, doa3, doa4, doa5, doa6, doa7, doa8            : out std_logic := 'X';
        doa9, doa10, doa11, doa12, doa13, doa14, doa15, doa16, doa17    : out std_logic := 'X';
        dob0, dob1, dob2, dob3, dob4, dob5, dob6, dob7, dob8            : out std_logic := 'X';
        dob9, dob10, dob11, dob12, dob13, dob14, dob15, dob16, dob17    : out std_logic := 'X'
  );
  END COMPONENT;

signal vcc, gnd : std_ulogic;
begin
  vcc <= '1'; gnd <= '0';
  u0: DP8KA
        generic map (CSDECODE_B=>"000", CSDECODE_A=>"000",
          WRITEMODE_B=>"NORMAL", WRITEMODE_A=>"NORMAL",
          GSR=>"DISABLED", RESETMODE=>"ASYNC", REGMODE_B=>"NOREG",
          REGMODE_A=>"NOREG", DATA_WIDTH_B=> 2, DATA_WIDTH_A=> 2)
        port map (CEA=>ClockEnA, CLKA=>ClockA, WEA=>WrA, CSA0=>gnd, 
            CSA1=>gnd, CSA2=>gnd, RSTA=>gnd, 
            CEB=>ClockEnB, CLKB=>ClockB, WEB=>WrB, CSB0=>gnd, 
            CSB1=>gnd, CSB2=>gnd, RSTB=>gnd, 
            DIA0=>gnd, DIA1=>DataInA(0), DIA2=>gnd, 
            DIA3=>gnd, DIA4=>gnd, DIA5=>gnd, 
            DIA6=>gnd, DIA7=>gnd, DIA8=>gnd, 
            DIA9=>gnd, DIA10=>gnd, DIA11=>DataInA(1), 
            DIA12=>gnd, DIA13=>gnd, DIA14=>gnd, 
            DIA15=>gnd, DIA16=>gnd, DIA17=>gnd, 
            ADA0=>vcc, ADA1=>AddressA(0), ADA2=>AddressA(1), 
            ADA3=>AddressA(2), ADA4=>AddressA(3), ADA5=>AddressA(4), 
            ADA6=>AddressA(6), ADA7=>AddressA(6), ADA8=>AddressA(7), 
            ADA9=>AddressA(8), ADA10=>AddressA(9), ADA11=>AddressA(10), 
            ADA12=>AddressA(11), DIB0=>gnd, DIB1=>DataInB(0), 
            DIB2=>gnd, DIB3=>gnd, DIB4=>gnd, 
            DIB5=>gnd, DIB6=>gnd, DIB7=>gnd, 
            DIB8=>gnd, DIB9=>gnd, DIB10=>gnd, 
            DIB11=>DataInB(1), DIB12=>gnd, DIB13=>gnd, 
            DIB14=>gnd, DIB15=>gnd, DIB16=>gnd, 
            DIB17=>gnd, ADB0=>vcc, ADB1=>AddressB(0), 
            ADB2=>AddressB(1), ADB3=>AddressB(2), ADB4=>AddressB(3), 
            ADB5=>AddressB(4), ADB6=>AddressB(5), ADB7=>AddressB(6), 
            ADB8=>AddressB(7), ADB9=>AddressB(8), ADB10=>AddressB(9), 
            ADB11=>AddressB(10), ADB12=>AddressB(11), DOA0=>QA(1), 
            DOA1=>QA(0), DOA2=>open, DOA3=>open, DOA4=>open, 
            DOA5=>open, DOA6=>open, DOA7=>open, DOA8=>open, 
            DOA9=>open, DOA10=>open, DOA11=>open, DOA12=>open, 
            DOA13=>open, DOA14=>open, DOA15=>open, DOA16=>open, 
            DOA17=>open, DOB0=>QB(1), DOB1=>QB(0), DOB2=>open, 
            DOB3=>open, DOB4=>open, DOB5=>open, DOB6=>open, 
            DOB7=>open, DOB8=>open, DOB9=>open, DOB10=>open, 
            DOB11=>open, DOB12=>open, DOB13=>open, DOB14=>open, 
            DOB15=>open, DOB16=>open, DOB17=>open);
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.dp8ka;
-- pragma translate_on

entity EC_RAMB8_S4_S4 is
    port (
        DataInA: in  std_logic_vector(3 downto 0); 
        DataInB: in  std_logic_vector(3 downto 0); 
        AddressA: in  std_logic_vector(10 downto 0); 
        AddressB: in  std_logic_vector(10 downto 0); 
        ClockA: in  std_logic; 
        ClockB: in  std_logic; 
        ClockEnA: in  std_logic; 
        ClockEnB: in  std_logic; 
        WrA: in  std_logic; 
        WrB: in  std_logic; 
        QA: out  std_logic_vector(3 downto 0); 
        QB: out  std_logic_vector(3 downto 0));
end;

architecture Structure of EC_RAMB8_S4_S4 is
  COMPONENT dp8ka
  GENERIC(
        DATA_WIDTH_A : in Integer := 18;
        DATA_WIDTH_B : in Integer := 18;
        REGMODE_A    : String  := "NOREG";
        REGMODE_B    : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE_A   : String  := "000";
        CSDECODE_B   : String  := "000";
        WRITEMODE_A  : String  := "NORMAL";
        WRITEMODE_B  : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        dia0, dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8            : in std_logic := 'X';
        dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17    : in std_logic := 'X';
        ada0, ada1, ada2, ada3, ada4, ada5, ada6, ada7, ada8            : in std_logic := 'X';
        ada9, ada10, ada11, ada12                                       : in std_logic := 'X';
        cea, clka, wea, csa0, csa1, csa2, rsta                         : in std_logic := 'X';
        dib0, dib1, dib2, dib3, dib4, dib5, dib6, dib7, dib8            : in std_logic := 'X';
        dib9, dib10, dib11, dib12, dib13, dib14, dib15, dib16, dib17    : in std_logic := 'X';
        adb0, adb1, adb2, adb3, adb4, adb5, adb6, adb7, adb8            : in std_logic := 'X';
        adb9, adb10, adb11, adb12                                       : in std_logic := 'X';
        ceb, clkb, web, csb0, csb1, csb2, rstb                         : in std_logic := 'X';

        doa0, doa1, doa2, doa3, doa4, doa5, doa6, doa7, doa8            : out std_logic := 'X';
        doa9, doa10, doa11, doa12, doa13, doa14, doa15, doa16, doa17    : out std_logic := 'X';
        dob0, dob1, dob2, dob3, dob4, dob5, dob6, dob7, dob8            : out std_logic := 'X';
        dob9, dob10, dob11, dob12, dob13, dob14, dob15, dob16, dob17    : out std_logic := 'X'
  );
  END COMPONENT;

signal vcc, gnd : std_ulogic;
begin
  vcc <= '1'; gnd <= '0';
  u0: DP8KA
        generic map (CSDECODE_B=>"000", CSDECODE_A=>"000",
          WRITEMODE_B=>"NORMAL", WRITEMODE_A=>"NORMAL",
          GSR=>"DISABLED", RESETMODE=>"ASYNC", REGMODE_B=>"NOREG",
          REGMODE_A=>"NOREG", DATA_WIDTH_B=> 4, DATA_WIDTH_A=> 4)
        port map (CEA=>ClockEnA, CLKA=>ClockA, WEA=>WrA, CSA0=>gnd, 
            CSA1=>gnd, CSA2=>gnd, RSTA=>gnd, 
            CEB=>ClockEnB, CLKB=>ClockB, WEB=>WrB, CSB0=>gnd, 
            CSB1=>gnd, CSB2=>gnd, RSTB=>gnd, 
            DIA0=>DataInA(0), DIA1=>DataInA(1), DIA2=>DataInA(2), 
            DIA3=>DataInA(3), DIA4=>gnd, DIA5=>gnd, 
            DIA6=>gnd, DIA7=>gnd, DIA8=>gnd, 
            DIA9=>gnd, DIA10=>gnd, DIA11=>gnd, 
            DIA12=>gnd, DIA13=>gnd, DIA14=>gnd, 
            DIA15=>gnd, DIA16=>gnd, DIA17=>gnd, 
            ADA0=>vcc, ADA1=>vcc, ADA2=>AddressA(0), 
            ADA3=>AddressA(1), ADA4=>AddressA(2), ADA5=>AddressA(3), 
            ADA6=>AddressA(4), ADA7=>AddressA(5), ADA8=>AddressA(6), 
            ADA9=>AddressA(7), ADA10=>AddressA(8), ADA11=>AddressA(9), 
            ADA12=>AddressA(10), DIB0=>DataInB(0), DIB1=>DataInB(1), 
            DIB2=>DataInB(2), DIB3=>DataInB(3), DIB4=>gnd, 
            DIB5=>gnd, DIB6=>gnd, DIB7=>gnd, 
            DIB8=>gnd, DIB9=>gnd, DIB10=>gnd, 
            DIB11=>gnd, DIB12=>gnd, DIB13=>gnd, 
            DIB14=>gnd, DIB15=>gnd, DIB16=>gnd, 
            DIB17=>gnd, ADB0=>vcc, ADB1=>vcc, 
            ADB2=>AddressB(0), ADB3=>AddressB(1), ADB4=>AddressB(2), 
            ADB5=>AddressB(3), ADB6=>AddressB(4), ADB7=>AddressB(5), 
            ADB8=>AddressB(6), ADB9=>AddressB(7), ADB10=>AddressB(8), 
            ADB11=>AddressB(9), ADB12=>AddressB(10), DOA0=>QA(0), 
            DOA1=>QA(1), DOA2=>QA(2), DOA3=>QA(3), DOA4=>open, 
            DOA5=>open, DOA6=>open, DOA7=>open, DOA8=>open, 
            DOA9=>open, DOA10=>open, DOA11=>open, DOA12=>open, 
            DOA13=>open, DOA14=>open, DOA15=>open, DOA16=>open, 
            DOA17=>open, DOB0=>QB(0), DOB1=>QB(1), DOB2=>QB(2), 
            DOB3=>QB(3), DOB4=>open, DOB5=>open, DOB6=>open, 
            DOB7=>open, DOB8=>open, DOB9=>open, DOB10=>open, 
            DOB11=>open, DOB12=>open, DOB13=>open, DOB14=>open, 
            DOB15=>open, DOB16=>open, DOB17=>open);
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.dp8ka;
-- pragma translate_on

entity EC_RAMB8_S9_S9 is
    port (
        DataInA: in  std_logic_vector(8 downto 0); 
        DataInB: in  std_logic_vector(8 downto 0); 
        AddressA: in  std_logic_vector(9 downto 0); 
        AddressB: in  std_logic_vector(9 downto 0); 
        ClockA: in  std_logic; 
        ClockB: in  std_logic; 
        ClockEnA: in  std_logic; 
        ClockEnB: in  std_logic; 
        WrA: in  std_logic; 
        WrB: in  std_logic; 
        QA: out  std_logic_vector(8 downto 0); 
        QB: out  std_logic_vector(8 downto 0));
end;

architecture Structure of EC_RAMB8_S9_S9 is
  COMPONENT dp8ka
  GENERIC(
        DATA_WIDTH_A : in Integer := 18;
        DATA_WIDTH_B : in Integer := 18;
        REGMODE_A    : String  := "NOREG";
        REGMODE_B    : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE_A   : String  := "000";
        CSDECODE_B   : String  := "000";
        WRITEMODE_A  : String  := "NORMAL";
        WRITEMODE_B  : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        dia0, dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8            : in std_logic := 'X';
        dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17    : in std_logic := 'X';
        ada0, ada1, ada2, ada3, ada4, ada5, ada6, ada7, ada8            : in std_logic := 'X';
        ada9, ada10, ada11, ada12                                       : in std_logic := 'X';
        cea, clka, wea, csa0, csa1, csa2, rsta                         : in std_logic := 'X';
        dib0, dib1, dib2, dib3, dib4, dib5, dib6, dib7, dib8            : in std_logic := 'X';
        dib9, dib10, dib11, dib12, dib13, dib14, dib15, dib16, dib17    : in std_logic := 'X';
        adb0, adb1, adb2, adb3, adb4, adb5, adb6, adb7, adb8            : in std_logic := 'X';
        adb9, adb10, adb11, adb12                                       : in std_logic := 'X';
        ceb, clkb, web, csb0, csb1, csb2, rstb                         : in std_logic := 'X';

        doa0, doa1, doa2, doa3, doa4, doa5, doa6, doa7, doa8            : out std_logic := 'X';
        doa9, doa10, doa11, doa12, doa13, doa14, doa15, doa16, doa17    : out std_logic := 'X';
        dob0, dob1, dob2, dob3, dob4, dob5, dob6, dob7, dob8            : out std_logic := 'X';
        dob9, dob10, dob11, dob12, dob13, dob14, dob15, dob16, dob17    : out std_logic := 'X'
  );
  END COMPONENT;

signal vcc, gnd : std_ulogic;
begin
  vcc <= '1'; gnd <= '0';
  u0: DP8KA
        generic map (CSDECODE_B=>"000", CSDECODE_A=>"000",
          WRITEMODE_B=>"NORMAL", WRITEMODE_A=>"NORMAL",
          GSR=>"DISABLED", RESETMODE=>"ASYNC", REGMODE_B=>"NOREG",
          REGMODE_A=>"NOREG", DATA_WIDTH_B=> 9, DATA_WIDTH_A=> 9)
        port map (CEA=>ClockEnA, CLKA=>ClockA, WEA=>WrA, CSA0=>gnd, 
            CSA1=>gnd, CSA2=>gnd, RSTA=>gnd, 
            CEB=>ClockEnB, CLKB=>ClockB, WEB=>WrB, CSB0=>gnd, 
            CSB1=>gnd, CSB2=>gnd, RSTB=>gnd, 
            DIA0=>DataInA(0), DIA1=>DataInA(1), DIA2=>DataInA(2), 
            DIA3=>DataInA(3), DIA4=>DataInA(4), DIA5=>DataInA(5), 
            DIA6=>DataInA(6), DIA7=>DataInA(7), DIA8=>DataInA(8), 
            DIA9=>gnd, DIA10=>gnd, DIA11=>gnd, 
            DIA12=>gnd, DIA13=>gnd, DIA14=>gnd, 
            DIA15=>gnd, DIA16=>gnd, DIA17=>gnd, 
            ADA0=>vcc, ADA1=>vcc, ADA2=>gnd, 
            ADA3=>AddressA(0), ADA4=>AddressA(1), ADA5=>AddressA(2), 
            ADA6=>AddressA(3), ADA7=>AddressA(4), ADA8=>AddressA(5), 
            ADA9=>AddressA(6), ADA10=>AddressA(7), ADA11=>AddressA(8), 
            ADA12=>AddressA(9), DIB0=>DataInB(0), DIB1=>DataInB(1), 
            DIB2=>DataInB(2), DIB3=>DataInB(3), DIB4=>DataInB(4), 
            DIB5=>DataInB(5), DIB6=>DataInB(6), DIB7=>DataInB(7), 
            DIB8=>DataInB(8), DIB9=>gnd, DIB10=>gnd, 
            DIB11=>gnd, DIB12=>gnd, DIB13=>gnd, 
            DIB14=>gnd, DIB15=>gnd, DIB16=>gnd, 
            DIB17=>gnd, ADB0=>vcc, ADB1=>vcc, 
            ADB2=>gnd, ADB3=>AddressB(0), ADB4=>AddressB(1), 
            ADB5=>AddressB(2), ADB6=>AddressB(3), ADB7=>AddressB(4), 
            ADB8=>AddressB(5), ADB9=>AddressB(6), ADB10=>AddressB(7), 
            ADB11=>AddressB(8), ADB12=>AddressB(9), DOA0=>QA(0), 
            DOA1=>QA(1), DOA2=>QA(2), DOA3=>QA(3), DOA4=>QA(4), 
            DOA5=>QA(5), DOA6=>QA(6), DOA7=>QA(7), DOA8=>QA(8), 
            DOA9=>open, DOA10=>open, DOA11=>open, DOA12=>open, 
            DOA13=>open, DOA14=>open, DOA15=>open, DOA16=>open, 
            DOA17=>open, DOB0=>QB(0), DOB1=>QB(1), DOB2=>QB(2), 
            DOB3=>QB(3), DOB4=>QB(4), DOB5=>QB(5), DOB6=>QB(6), 
            DOB7=>QB(7), DOB8=>QB(8), DOB9=>open, DOB10=>open, 
            DOB11=>open, DOB12=>open, DOB13=>open, DOB14=>open, 
            DOB15=>open, DOB16=>open, DOB17=>open);
end;


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.dp8ka;
-- pragma translate_on

entity EC_RAMB8_S18_S18 is
    port (
        DataInA: in  std_logic_vector(17 downto 0); 
        DataInB: in  std_logic_vector(17 downto 0); 
        AddressA: in  std_logic_vector(8 downto 0); 
        AddressB: in  std_logic_vector(8 downto 0); 
        ClockA: in  std_logic; 
        ClockB: in  std_logic; 
        ClockEnA: in  std_logic; 
        ClockEnB: in  std_logic; 
        WrA: in  std_logic; 
        WrB: in  std_logic; 
        QA: out  std_logic_vector(17 downto 0); 
        QB: out  std_logic_vector(17 downto 0));
end;

architecture Structure of EC_RAMB8_S18_S18 is
  COMPONENT dp8ka
  GENERIC(
        DATA_WIDTH_A : in Integer := 18;
        DATA_WIDTH_B : in Integer := 18;
        REGMODE_A    : String  := "NOREG";
        REGMODE_B    : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE_A   : String  := "000";
        CSDECODE_B   : String  := "000";
        WRITEMODE_A  : String  := "NORMAL";
        WRITEMODE_B  : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        dia0, dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8            : in std_logic := 'X';
        dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17    : in std_logic := 'X';
        ada0, ada1, ada2, ada3, ada4, ada5, ada6, ada7, ada8            : in std_logic := 'X';
        ada9, ada10, ada11, ada12                                       : in std_logic := 'X';
        cea, clka, wea, csa0, csa1, csa2, rsta                         : in std_logic := 'X';
        dib0, dib1, dib2, dib3, dib4, dib5, dib6, dib7, dib8            : in std_logic := 'X';
        dib9, dib10, dib11, dib12, dib13, dib14, dib15, dib16, dib17    : in std_logic := 'X';
        adb0, adb1, adb2, adb3, adb4, adb5, adb6, adb7, adb8            : in std_logic := 'X';
        adb9, adb10, adb11, adb12                                       : in std_logic := 'X';
        ceb, clkb, web, csb0, csb1, csb2, rstb                         : in std_logic := 'X';

        doa0, doa1, doa2, doa3, doa4, doa5, doa6, doa7, doa8            : out std_logic := 'X';
        doa9, doa10, doa11, doa12, doa13, doa14, doa15, doa16, doa17    : out std_logic := 'X';
        dob0, dob1, dob2, dob3, dob4, dob5, dob6, dob7, dob8            : out std_logic := 'X';
        dob9, dob10, dob11, dob12, dob13, dob14, dob15, dob16, dob17    : out std_logic := 'X'
  );
  END COMPONENT;

signal vcc, gnd : std_ulogic;
begin
  vcc <= '1'; gnd <= '0';
  u0: DP8KA
        generic map (CSDECODE_B=>"000", CSDECODE_A=>"000",
          WRITEMODE_B=>"NORMAL", WRITEMODE_A=>"NORMAL",
          GSR=>"DISABLED", RESETMODE=>"ASYNC", REGMODE_B=>"NOREG",
          REGMODE_A=>"NOREG", DATA_WIDTH_B=> 18, DATA_WIDTH_A=> 18)
        port map (CEA=>ClockEnA, CLKA=>ClockA, WEA=>WrA, CSA0=>gnd, 
            CSA1=>gnd, CSA2=>gnd, RSTA=>gnd, 
            CEB=>ClockEnB, CLKB=>ClockB, WEB=>WrB, CSB0=>gnd, 
            CSB1=>gnd, CSB2=>gnd, RSTB=>gnd, 
            DIA0=>DataInA(0), DIA1=>DataInA(1), DIA2=>DataInA(2), 
            DIA3=>DataInA(3), DIA4=>DataInA(4), DIA5=>DataInA(5), 
            DIA6=>DataInA(6), DIA7=>DataInA(7), DIA8=>DataInA(8), 
            DIA9=>DataInA(9), DIA10=>DataInA(10), DIA11=>DataInA(11), 
            DIA12=>DataInA(12), DIA13=>DataInA(13), DIA14=>DataInA(14), 
            DIA15=>DataInA(15), DIA16=>DataInA(16), DIA17=>DataInA(17), 
            ADA0=>vcc, ADA1=>vcc, ADA2=>gnd, 
            ADA3=>gnd, ADA4=>AddressA(0), ADA5=>AddressA(1), 
            ADA6=>AddressA(2), ADA7=>AddressA(3), ADA8=>AddressA(4), 
            ADA9=>AddressA(5), ADA10=>AddressA(6), ADA11=>AddressA(7), 
            ADA12=>AddressA(8), DIB0=>DataInB(0), DIB1=>DataInB(1), 
            DIB2=>DataInB(2), DIB3=>DataInB(3), DIB4=>DataInB(4), 
            DIB5=>DataInB(5), DIB6=>DataInB(6), DIB7=>DataInB(7), 
            DIB8=>DataInB(8), DIB9=>DataInB(9), DIB10=>DataInB(10), 
            DIB11=>DataInB(11), DIB12=>DataInB(12), DIB13=>DataInB(13), 
            DIB14=>DataInB(14), DIB15=>DataInB(15), DIB16=>DataInB(16), 
            DIB17=>DataInB(17), ADB0=>vcc, ADB1=>vcc, 
            ADB2=>gnd, ADB3=>gnd, ADB4=>AddressB(0), 
            ADB5=>AddressB(1), ADB6=>AddressB(2), ADB7=>AddressB(3), 
            ADB8=>AddressB(4), ADB9=>AddressB(5), ADB10=>AddressB(6), 
            ADB11=>AddressB(7), ADB12=>AddressB(8), DOA0=>QA(0), 
            DOA1=>QA(1), DOA2=>QA(2), DOA3=>QA(3), DOA4=>QA(4), 
            DOA5=>QA(5), DOA6=>QA(6), DOA7=>QA(7), DOA8=>QA(8), 
            DOA9=>QA(9), DOA10=>QA(10), DOA11=>QA(11), DOA12=>QA(12), 
            DOA13=>QA(13), DOA14=>QA(14), DOA15=>QA(15), DOA16=>QA(16), 
            DOA17=>QA(17), DOB0=>QB(0), DOB1=>QB(1), DOB2=>QB(2), 
            DOB3=>QB(3), DOB4=>QB(4), DOB5=>QB(5), DOB6=>QB(6), 
            DOB7=>QB(7), DOB8=>QB(8), DOB9=>QB(9), DOB10=>QB(10), 
            DOB11=>QB(11), DOB12=>QB(12), DOB13=>QB(13), DOB14=>QB(14), 
            DOB15=>QB(15), DOB16=>QB(16), DOB17=>QB(17));
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.sp8ka;
-- pragma translate_on

entity EC_RAMB8_S1 is
  port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (12 downto 0);
   data : in std_logic_vector (0 downto 0);
   q : out std_logic_vector (0 downto 0));
end;
architecture behav of EC_RAMB8_S1 is
  COMPONENT sp8ka
  GENERIC(
        DATA_WIDTH   : in Integer := 18;
        REGMODE      : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE     : String  := "000";
        WRITEMODE    : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        di0, di1, di2, di3, di4, di5, di6, di7, di8            : in std_logic := 'X';
        di9, di10, di11, di12, di13, di14, di15, di16, di17    : in std_logic := 'X';
        ad0, ad1, ad2, ad3, ad4, ad5, ad6, ad7, ad8            : in std_logic := 'X';
        ad9, ad10, ad11, ad12                                  : in std_logic := 'X';
        ce, clk, we, cs0, cs1, cs2, rst                        : in std_logic := 'X';

        do0, do1, do2, do3, do4, do5, do6, do7, do8            : out std_logic := 'X';
        do9, do10, do11, do12, do13, do14, do15, do16, do17    : out std_logic := 'X'
  );
  END COMPONENT;
signal vcc, gnd : std_ulogic;
begin

  vcc <= '1'; gnd <= '0';
    u0: SP8KA
        generic map (CSDECODE=>"000", GSR=>"DISABLED",
           WRITEMODE=>"WRITETHROUGH", RESETMODE=>"ASYNC",
           REGMODE=>"NOREG", DATA_WIDTH=> 1)
        port map (CE=>En, CLK=>Clk, WE=>WE, CS0=>gnd, 
            CS1=>gnd, CS2=>gnd, RST=>gnd, DI0=>gnd, 
            DI1=>gnd, DI2=>gnd, DI3=>gnd, DI4=>gnd, 
            DI5=>gnd, DI6=>gnd, DI7=>gnd, DI8=>gnd, 
            DI9=>gnd, DI10=>gnd, DI11=>Data(0), 
            DI12=>gnd, DI13=>gnd, DI14=>gnd, 
            DI15=>gnd, DI16=>gnd, DI17=>gnd, 
            AD0=>Address(0), AD1=>Address(1), AD2=>Address(2), 
            AD3=>Address(3), AD4=>Address(4), AD5=>Address(5), 
            AD6=>Address(6), AD7=>Address(7), AD8=>Address(8), 
            AD9=>Address(9), AD10=>Address(10), AD11=>Address(11), 
            AD12=>Address(12), DO0=>Q(0), DO1=>open, DO2=>open, DO3=>open, 
            DO4=>open, DO5=>open, DO6=>open, DO7=>open, DO8=>open, 
            DO9=>open, DO10=>open, DO11=>open, DO12=>open, DO13=>open, 
            DO14=>open, DO15=>open, DO16=>open, DO17=>open);
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.sp8ka;
-- pragma translate_on

entity EC_RAMB8_S2 is
  port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (11 downto 0);
   data : in std_logic_vector (1 downto 0);
   q : out std_logic_vector (1 downto 0));
end;
architecture behav of EC_RAMB8_S2 is
  COMPONENT sp8ka
  GENERIC(
        DATA_WIDTH   : in Integer := 18;
        REGMODE      : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE     : String  := "000";
        WRITEMODE    : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        di0, di1, di2, di3, di4, di5, di6, di7, di8            : in std_logic := 'X';
        di9, di10, di11, di12, di13, di14, di15, di16, di17    : in std_logic := 'X';
        ad0, ad1, ad2, ad3, ad4, ad5, ad6, ad7, ad8            : in std_logic := 'X';
        ad9, ad10, ad11, ad12                                  : in std_logic := 'X';
        ce, clk, we, cs0, cs1, cs2, rst                        : in std_logic := 'X';

        do0, do1, do2, do3, do4, do5, do6, do7, do8            : out std_logic := 'X';
        do9, do10, do11, do12, do13, do14, do15, do16, do17    : out std_logic := 'X'
  );
  END COMPONENT;
signal vcc, gnd : std_ulogic;
begin

  vcc <= '1'; gnd <= '0';
    u0: SP8KA
        generic map (CSDECODE=>"000", GSR=>"DISABLED",
           WRITEMODE=>"WRITETHROUGH", RESETMODE=>"ASYNC",
           REGMODE=>"NOREG", DATA_WIDTH=> 2)
        port map (CE=>En, CLK=>Clk, WE=>WE, CS0=>gnd, 
            CS1=>gnd, CS2=>gnd, RST=>gnd, DI0=>gnd, 
            DI1=>Data(0), DI2=>gnd, DI3=>gnd, DI4=>gnd, 
            DI5=>gnd, DI6=>gnd, DI7=>gnd, DI8=>gnd, 
            DI9=>gnd, DI10=>gnd, DI11=>Data(1), 
            DI12=>gnd, DI13=>gnd, DI14=>gnd, 
            DI15=>gnd, DI16=>gnd, DI17=>gnd, 
            AD0=>gnd, AD1=>Address(0), AD2=>Address(1), 
            AD3=>Address(2), AD4=>Address(3), AD5=>Address(4), 
            AD6=>Address(5), AD7=>Address(6), AD8=>Address(7), 
            AD9=>Address(8), AD10=>Address(9), AD11=>Address(10), 
            AD12=>Address(11), DO0=>Q(1), DO1=>Q(0), DO2=>open, DO3=>open, 
            DO4=>open, DO5=>open, DO6=>open, DO7=>open, DO8=>open, 
            DO9=>open, DO10=>open, DO11=>open, DO12=>open, DO13=>open, 
            DO14=>open, DO15=>open, DO16=>open, DO17=>open);
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.sp8ka;
-- pragma translate_on

entity EC_RAMB8_S4 is
  port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (10 downto 0);
   data : in std_logic_vector (3 downto 0);
   q : out std_logic_vector (3 downto 0));
end;
architecture behav of EC_RAMB8_S4 is
  COMPONENT sp8ka
  GENERIC(
        DATA_WIDTH   : in Integer := 18;
        REGMODE      : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE     : String  := "000";
        WRITEMODE    : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        di0, di1, di2, di3, di4, di5, di6, di7, di8            : in std_logic := 'X';
        di9, di10, di11, di12, di13, di14, di15, di16, di17    : in std_logic := 'X';
        ad0, ad1, ad2, ad3, ad4, ad5, ad6, ad7, ad8            : in std_logic := 'X';
        ad9, ad10, ad11, ad12                                  : in std_logic := 'X';
        ce, clk, we, cs0, cs1, cs2, rst                        : in std_logic := 'X';

        do0, do1, do2, do3, do4, do5, do6, do7, do8            : out std_logic := 'X';
        do9, do10, do11, do12, do13, do14, do15, do16, do17    : out std_logic := 'X'
  );
  END COMPONENT;
signal vcc, gnd : std_ulogic;
begin

  vcc <= '1'; gnd <= '0';
    u0: SP8KA
        generic map (CSDECODE=>"000", GSR=>"DISABLED",
           WRITEMODE=>"WRITETHROUGH", RESETMODE=>"ASYNC",
           REGMODE=>"NOREG", DATA_WIDTH=> 4)
        port map (CE=>En, CLK=>Clk, WE=>WE, CS0=>gnd, 
            CS1=>gnd, CS2=>gnd, RST=>gnd, DI0=>Data(0), 
            DI1=>Data(1), DI2=>Data(2), DI3=>Data(3), DI4=>gnd, 
            DI5=>gnd, DI6=>gnd, DI7=>gnd, DI8=>gnd, 
            DI9=>gnd, DI10=>gnd, DI11=>gnd, 
            DI12=>gnd, DI13=>gnd, DI14=>gnd, 
            DI15=>gnd, DI16=>gnd, DI17=>gnd, 
            AD0=>gnd, AD1=>gnd, AD2=>Address(0), 
            AD3=>Address(1), AD4=>Address(2), AD5=>Address(3), 
            AD6=>Address(4), AD7=>Address(5), AD8=>Address(6), 
            AD9=>Address(7), AD10=>Address(8), AD11=>Address(9), 
            AD12=>Address(10), DO0=>Q(0), DO1=>Q(1), DO2=>Q(2), DO3=>Q(3), 
            DO4=>open, DO5=>open, DO6=>open, DO7=>open, DO8=>open, 
            DO9=>open, DO10=>open, DO11=>open, DO12=>open, DO13=>open, 
            DO14=>open, DO15=>open, DO16=>open, DO17=>open);
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.sp8ka;
-- pragma translate_on

entity EC_RAMB8_S9 is
  port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (9 downto 0);
   data : in std_logic_vector (8 downto 0);
   q : out std_logic_vector (8 downto 0));
end;
architecture behav of EC_RAMB8_S9 is
  COMPONENT sp8ka
  GENERIC(
        DATA_WIDTH   : in Integer := 18;
        REGMODE      : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE     : String  := "000";
        WRITEMODE    : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        di0, di1, di2, di3, di4, di5, di6, di7, di8            : in std_logic := 'X';
        di9, di10, di11, di12, di13, di14, di15, di16, di17    : in std_logic := 'X';
        ad0, ad1, ad2, ad3, ad4, ad5, ad6, ad7, ad8            : in std_logic := 'X';
        ad9, ad10, ad11, ad12                                  : in std_logic := 'X';
        ce, clk, we, cs0, cs1, cs2, rst                        : in std_logic := 'X';

        do0, do1, do2, do3, do4, do5, do6, do7, do8            : out std_logic := 'X';
        do9, do10, do11, do12, do13, do14, do15, do16, do17    : out std_logic := 'X'
  );
  END COMPONENT;
signal vcc, gnd : std_ulogic;
begin

  vcc <= '1'; gnd <= '0';
    u0: SP8KA
        generic map (CSDECODE=>"000", GSR=>"DISABLED",
           WRITEMODE=>"WRITETHROUGH", RESETMODE=>"ASYNC",
           REGMODE=>"NOREG", DATA_WIDTH=> 9)
        port map (CE=>En, CLK=>Clk, WE=>WE, CS0=>gnd, 
            CS1=>gnd, CS2=>gnd, RST=>gnd, DI0=>Data(0), 
            DI1=>Data(1), DI2=>Data(2), DI3=>Data(3), DI4=>Data(4), 
            DI5=>Data(5), DI6=>Data(6), DI7=>Data(7), DI8=>Data(8), 
            DI9=>gnd, DI10=>gnd, DI11=>gnd, 
            DI12=>gnd, DI13=>gnd, DI14=>gnd, 
            DI15=>gnd, DI16=>gnd, DI17=>gnd, 
            AD0=>gnd, AD1=>gnd, AD2=>gnd, 
            AD3=>Address(0), AD4=>Address(1), AD5=>Address(2), 
            AD6=>Address(3), AD7=>Address(4), AD8=>Address(5), 
            AD9=>Address(6), AD10=>Address(7), AD11=>Address(8), 
            AD12=>Address(9), DO0=>Q(0), DO1=>Q(1), DO2=>Q(2), DO3=>Q(3), 
            DO4=>Q(4), DO5=>Q(5), DO6=>Q(6), DO7=>Q(7), DO8=>Q(8), 
            DO9=>open, DO10=>open, DO11=>open, DO12=>open, DO13=>open, 
            DO14=>open, DO15=>open, DO16=>open, DO17=>open);
end;


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.sp8ka;
-- pragma translate_on

entity EC_RAMB8_S18 is
  port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (8 downto 0);
   data : in std_logic_vector (17 downto 0);
   q : out std_logic_vector (17 downto 0));
end;
architecture behav of EC_RAMB8_S18 is
  COMPONENT sp8ka
  GENERIC(
        DATA_WIDTH   : in Integer := 18;
        REGMODE      : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE     : String  := "000";
        WRITEMODE    : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        di0, di1, di2, di3, di4, di5, di6, di7, di8            : in std_logic := 'X';
        di9, di10, di11, di12, di13, di14, di15, di16, di17    : in std_logic := 'X';
        ad0, ad1, ad2, ad3, ad4, ad5, ad6, ad7, ad8            : in std_logic := 'X';
        ad9, ad10, ad11, ad12                                  : in std_logic := 'X';
        ce, clk, we, cs0, cs1, cs2, rst                        : in std_logic := 'X';

        do0, do1, do2, do3, do4, do5, do6, do7, do8            : out std_logic := 'X';
        do9, do10, do11, do12, do13, do14, do15, do16, do17    : out std_logic := 'X'
  );
  END COMPONENT;
signal vcc, gnd : std_ulogic;
begin

  vcc <= '1'; gnd <= '0';
    u0: SP8KA
        generic map (CSDECODE=>"000", GSR=>"DISABLED",
           WRITEMODE=>"WRITETHROUGH", RESETMODE=>"ASYNC",
           REGMODE=>"NOREG", DATA_WIDTH=> 18)
        port map (CE=>En, CLK=>Clk, WE=>WE, CS0=>gnd, 
            CS1=>gnd, CS2=>gnd, RST=>gnd, DI0=>Data(0), 
            DI1=>Data(1), DI2=>Data(2), DI3=>Data(3), DI4=>Data(4), 
            DI5=>Data(5), DI6=>Data(6), DI7=>Data(7), DI8=>Data(8), 
            DI9=>Data(9), DI10=>Data(10), DI11=>Data(11), 
            DI12=>Data(12), DI13=>Data(13), DI14=>Data(14), 
            DI15=>Data(15), DI16=>Data(16), DI17=>Data(17), 
            AD0=>gnd, AD1=>gnd, AD2=>gnd, 
            AD3=>gnd, AD4=>Address(0), AD5=>Address(1), 
            AD6=>Address(2), AD7=>Address(3), AD8=>Address(4), 
            AD9=>Address(5), AD10=>Address(6), AD11=>Address(7), 
            AD12=>Address(8), DO0=>Q(0), DO1=>Q(1), DO2=>Q(2), DO3=>Q(3), 
            DO4=>Q(4), DO5=>Q(5), DO6=>Q(6), DO7=>Q(7), DO8=>Q(8), 
            DO9=>Q(9), DO10=>Q(10), DO11=>Q(11), DO12=>Q(12), DO13=>Q(13), 
            DO14=>Q(14), DO15=>Q(15), DO16=>Q(16), DO17=>Q(17));
end;


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library ec;
use ec.dp8ka;
-- pragma translate_on

entity EC_RAMB8_S36 is
  port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (7 downto 0);
   data : in std_logic_vector (35 downto 0);
   q : out std_logic_vector (35 downto 0));
end;
architecture behav of EC_RAMB8_S36 is
  COMPONENT dp8ka
  GENERIC(
        DATA_WIDTH_A : in Integer := 18;
        DATA_WIDTH_B : in Integer := 18;
        REGMODE_A    : String  := "NOREG";
        REGMODE_B    : String  := "NOREG";
        RESETMODE    : String  := "ASYNC";
        CSDECODE_A   : String  := "000";
        CSDECODE_B   : String  := "000";
        WRITEMODE_A  : String  := "NORMAL";
        WRITEMODE_B  : String  := "NORMAL";
        GSR : String  := "ENABLED";
        initval_00 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_01 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_02 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_03 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_04 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_05 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_06 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_07 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_08 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_09 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_0f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_10 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_11 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_12 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_13 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_14 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_15 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_16 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_17 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_18 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_19 : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1a : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1b : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1c : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1d : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1e : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
        initval_1f : string := "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000"
  );
  PORT(
        dia0, dia1, dia2, dia3, dia4, dia5, dia6, dia7, dia8            : in std_logic := 'X';
        dia9, dia10, dia11, dia12, dia13, dia14, dia15, dia16, dia17    : in std_logic := 'X';
        ada0, ada1, ada2, ada3, ada4, ada5, ada6, ada7, ada8            : in std_logic := 'X';
        ada9, ada10, ada11, ada12                                       : in std_logic := 'X';
        cea, clka, wea, csa0, csa1, csa2, rsta                         : in std_logic := 'X';
        dib0, dib1, dib2, dib3, dib4, dib5, dib6, dib7, dib8            : in std_logic := 'X';
        dib9, dib10, dib11, dib12, dib13, dib14, dib15, dib16, dib17    : in std_logic := 'X';
        adb0, adb1, adb2, adb3, adb4, adb5, adb6, adb7, adb8            : in std_logic := 'X';
        adb9, adb10, adb11, adb12                                       : in std_logic := 'X';
        ceb, clkb, web, csb0, csb1, csb2, rstb                         : in std_logic := 'X';

        doa0, doa1, doa2, doa3, doa4, doa5, doa6, doa7, doa8            : out std_logic := 'X';
        doa9, doa10, doa11, doa12, doa13, doa14, doa15, doa16, doa17    : out std_logic := 'X';
        dob0, dob1, dob2, dob3, dob4, dob5, dob6, dob7, dob8            : out std_logic := 'X';
        dob9, dob10, dob11, dob12, dob13, dob14, dob15, dob16, dob17    : out std_logic := 'X'
  );
  END COMPONENT;

signal vcc, gnd : std_ulogic;
begin

  vcc <= '1'; gnd <= '0';

    u0: DP8KA
        generic map (CSDECODE_B=>"000", CSDECODE_A=>"000",
           WRITEMODE_B=>"NORMAL", WRITEMODE_A=>"NORMAL", GSR=>"DISABLED",
           RESETMODE=>"ASYNC", REGMODE_B=>"NOREG", REGMODE_A=>"NOREG",
           DATA_WIDTH_B=> 18, DATA_WIDTH_A=> 18)
        port map (CEA => en, CLKA => clk, WEA => we, CSA0 => gnd, 
            CSA1=>gnd, CSA2=>gnd, RSTA=> gnd, CEB=> en, 
            CLKB=> clk, WEB=> we, CSB0=>gnd, CSB1=>gnd, 
            CSB2=>gnd, RSTB=>gnd, DIA0=>Data(0), DIA1=>Data(1), 
            DIA2=>Data(2), DIA3=>Data(3), DIA4=>Data(4), DIA5=>Data(5), 
            DIA6=>Data(6), DIA7=>Data(7), DIA8=>Data(8), DIA9=>Data(9), 
            DIA10=>Data(10), DIA11=>Data(11), DIA12=>Data(12), 
            DIA13=>Data(13), DIA14=>Data(14), DIA15=>Data(15), 
            DIA16=>Data(16), DIA17=>Data(17), ADA0=>vcc, 
            ADA1=>vcc, ADA2=>vcc, ADA3=>vcc, 
            ADA4=>Address(0), ADA5=>Address(1), ADA6=>Address(2), 
            ADA7=>Address(3), ADA8=>Address(4), ADA9=>Address(5), 
            ADA10=>Address(6), ADA11=>Address(7), ADA12=>gnd, 
            DIB0=>Data(18), DIB1=>Data(19), DIB2=>Data(20), 
            DIB3=>Data(21), DIB4=>Data(22), DIB5=>Data(23), 
            DIB6=>Data(24), DIB7=>Data(25), DIB8=>Data(26), 
            DIB9=>Data(27), DIB10=>Data(28), DIB11=>Data(29), 
            DIB12=>Data(30), DIB13=>Data(31), DIB14=>Data(32), 
            DIB15=>Data(33), DIB16=>Data(34), DIB17=>Data(35), 
            ADB0=>vcc, ADB1=>vcc, ADB2=>gnd, 
            ADB3=>gnd, ADB4=>Address(0), ADB5=>Address(1), 
            ADB6=>Address(2), ADB7=>Address(3), ADB8=>Address(4), 
            ADB9=>Address(5), ADB10=>Address(6), ADB11=>Address(7), 
            ADB12=>vcc, DOA0=>Q(0), DOA1=>Q(1), DOA2=>Q(2), 
            DOA3=>Q(3), DOA4=>Q(4), DOA5=>Q(5), DOA6=>Q(6), DOA7=>Q(7), 
            DOA8=>Q(8), DOA9=>Q(9), DOA10=>Q(10), DOA11=>Q(11), 
            DOA12=>Q(12), DOA13=>Q(13), DOA14=>Q(14), DOA15=>Q(15), 
            DOA16=>Q(16), DOA17=>Q(17), DOB0=>Q(18), DOB1=>Q(19), 
            DOB2=>Q(20), DOB3=>Q(21), DOB4=>Q(22), DOB5=>Q(23), 
            DOB6=>Q(24), DOB7=>Q(25), DOB8=>Q(26), DOB9=>Q(27), 
            DOB10=>Q(28), DOB11=>Q(29), DOB12=>Q(30), DOB13=>Q(31), 
            DOB14=>Q(32), DOB15=>Q(33), DOB16=>Q(34), DOB17=>Q(35));
end;

library ieee;
use ieee.std_logic_1164.all;
library techmap;

entity ec_syncram is
  generic (abits : integer := 9; dbits : integer := 32);
  port (
    clk     : in  std_ulogic;
    address : in  std_logic_vector (abits -1 downto 0);
    datain  : in  std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in  std_ulogic;
    write   : in  std_ulogic
    );
end;

architecture behav of ec_syncram is
  component EC_RAMB8_S1 port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (12 downto 0);
   data : in std_logic_vector (0 downto 0);
   q : out std_logic_vector (0 downto 0));
  end component;
  component EC_RAMB8_S2 port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (11 downto 0);
   data : in std_logic_vector (1 downto 0);
   q : out std_logic_vector (1 downto 0));
  end component;
  component EC_RAMB8_S4 port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (10 downto 0);
   data : in std_logic_vector (3 downto 0);
   q : out std_logic_vector (3 downto 0));
  end component;
  component EC_RAMB8_S9 port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (9 downto 0);
   data : in std_logic_vector (8 downto 0);
   q : out std_logic_vector (8 downto 0));
  end component;
  component EC_RAMB8_S18 port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (8 downto 0);
   data : in std_logic_vector (17 downto 0);
   q : out std_logic_vector (17 downto 0));
  end component;
  component EC_RAMB8_S36 port (
   clk, en, we : in std_ulogic;
   address : in std_logic_vector (7 downto 0);
   data : in std_logic_vector (35 downto 0);
   q : out std_logic_vector (35 downto 0));
  end component;

constant DMAX : integer := dbits+36;
constant AMAX : integer := 13;
signal gnd : std_ulogic;
signal do, di : std_logic_vector(DMAX downto 0);
signal xa, ya : std_logic_vector(AMAX downto 0);
begin
  gnd <= '0'; dataout <= do(dbits-1 downto 0); di(dbits-1 downto 0) <= datain; 
  di(DMAX downto dbits) <= (others => '0'); xa(abits-1 downto 0) <= address; 
  xa(AMAX downto abits) <= (others => '0'); ya(abits-1 downto 0) <= address; 
  ya(AMAX downto abits) <= (others => '1');

  a8 : if (abits <= 8) generate
    x : for i in 0 to ((dbits-1)/36) generate
      r : EC_RAMB8_S36 port map ( clk, enable, write, xa(7 downto 0), 
	di((i+1)*36-1 downto i*36), do((i+1)*36-1 downto i*36));
    end generate;
  end generate;

  a9 : if (abits = 9) generate
    x : for i in 0 to ((dbits-1)/18) generate
      r : EC_RAMB8_S18 port map ( clk, enable, write, xa(8 downto 0), 
	di((i+1)*18-1 downto i*18), do((i+1)*18-1 downto i*18));
    end generate;
  end generate;

  a10 : if (abits = 10) generate
    x : for i in 0 to ((dbits-1)/9) generate
      r : EC_RAMB8_S9 port map ( clk, enable, write, xa(9 downto 0), 
	di((i+1)*9-1 downto i*9), do((i+1)*9-1 downto i*9));
    end generate;
  end generate;

  a11 : if (abits = 11) generate
    x : for i in 0 to ((dbits-1)/4) generate
      r : EC_RAMB8_S4 port map ( clk, enable, write, xa(10 downto 0), 
	di((i+1)*4-1 downto i*4), do((i+1)*4-1 downto i*4));
    end generate;
  end generate;

  a12 : if (abits = 12) generate
    x : for i in 0 to ((dbits-1)/2) generate
      r : EC_RAMB8_S2 port map ( clk, enable, write, xa(11 downto 0), 
	di((i+1)*2-1 downto i*2), do((i+1)*2-1 downto i*2));
    end generate;
  end generate;

  a13 : if (abits = 13) generate
    x : for i in 0 to ((dbits-1)/1) generate
      r : EC_RAMB8_S1 port map ( clk, enable, write, xa(12 downto 0), 
	di((i+1)*1-1 downto i*1), do((i+1)*1-1 downto i*1));
    end generate;
  end generate;

  -- pragma translate_off
  unsup : if (abits > 13) generate
    x : process
    begin
      assert false
        report "Lattice EC syncram mapper: unsupported memory configuration!"
        severity failure;
      wait;
    end process;
  end generate;
  -- pragma translate_on

end;



library ieee;
use ieee.std_logic_1164.all;
library techmap;

entity ec_syncram_dp is
  generic (
    abits : integer := 4; dbits : integer := 32
    );
  port (
    clk1     : in  std_ulogic;
    address1 : in  std_logic_vector((abits -1) downto 0);
    datain1  : in  std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in  std_ulogic;
    write1   : in  std_ulogic;
    clk2     : in  std_ulogic;
    address2 : in  std_logic_vector((abits -1) downto 0);
    datain2  : in  std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in  std_ulogic;
    write2   : in  std_ulogic);
end;

architecture behav of ec_syncram_dp is
  component EC_RAMB8_S1_S1 is port (
    DataInA, DataInB: in  std_logic_vector(0 downto 0); 
    AddressA, AddressB: in  std_logic_vector(12 downto 0); 
    ClockA, ClockB: in  std_logic; 
    ClockEnA, ClockEnB: in  std_logic; 
    WrA, WrB: in  std_logic; 
    QA, QB: out  std_logic_vector(0 downto 0));
  end component;
  component EC_RAMB8_S2_S2 is port (
    DataInA, DataInB: in  std_logic_vector(1 downto 0); 
    AddressA, AddressB: in  std_logic_vector(11 downto 0); 
    ClockA, ClockB: in  std_logic; 
    ClockEnA, ClockEnB: in  std_logic; 
    WrA, WrB: in  std_logic; 
    QA, QB: out  std_logic_vector(1 downto 0));
  end component;
  component EC_RAMB8_S4_S4 is port (
    DataInA, DataInB: in  std_logic_vector(3 downto 0); 
    AddressA, AddressB: in  std_logic_vector(10 downto 0); 
    ClockA, ClockB: in  std_logic; 
    ClockEnA, ClockEnB: in  std_logic; 
    WrA, WrB: in  std_logic; 
    QA, QB: out  std_logic_vector(3 downto 0));
  end component;
  component EC_RAMB8_S9_S9 is port (
    DataInA, DataInB: in  std_logic_vector(8 downto 0); 
    AddressA, AddressB: in  std_logic_vector(9 downto 0); 
    ClockA, ClockB: in  std_logic; 
    ClockEnA, ClockEnB: in  std_logic; 
    WrA, WrB: in  std_logic; 
    QA, QB: out  std_logic_vector(8 downto 0));
  end component;
  component EC_RAMB8_S18_S18 is port (
    DataInA, DataInB: in  std_logic_vector(17 downto 0); 
    AddressA, AddressB: in  std_logic_vector(8 downto 0); 
    ClockA, ClockB: in  std_logic; 
    ClockEnA, ClockEnB: in  std_logic; 
    WrA, WrB: in  std_logic; 
    QA, QB: out  std_logic_vector(17 downto 0));
  end component;
constant DMAX : integer := dbits+18;
constant AMAX : integer := 13;
signal gnd, vcc : std_ulogic;
signal do1, do2, di1, di2 : std_logic_vector(DMAX downto 0);
signal addr1, addr2 : std_logic_vector(AMAX downto 0);
begin
  gnd <= '0'; vcc <= '1';
  dataout1 <= do1(dbits-1 downto 0); dataout2 <= do2(dbits-1 downto 0);
  di1(dbits-1 downto 0) <= datain1; di1(DMAX downto dbits) <= (others => '0');
  di2(dbits-1 downto 0) <= datain2; di2(DMAX downto dbits) <= (others => '0');
  addr1(abits-1 downto 0) <= address1; addr1(AMAX downto abits) <= (others => '0');
  addr2(abits-1 downto 0) <= address2; addr2(AMAX downto abits) <= (others => '0');

  a9 : if abits <= 9 generate
    x : for i in 0 to ((dbits-1)/18) generate
      r0 : EC_RAMB8_S18_S18 port map (
	di1((i+1)*18-1 downto i*18), di2((i+1)*18-1 downto i*18),
	addr1(8 downto 0), addr2(8 downto 0), clk1, clk2,
  	enable1, enable2, write1, write2,
	do1((i+1)*18-1 downto i*18), do2((i+1)*18-1 downto i*18));
    end generate;
  end generate;
  a10 : if abits = 10 generate
    x : for i in 0 to ((dbits-1)/9) generate
      r0 : EC_RAMB8_S9_S9 port map (
	di1((i+1)*9-1 downto i*9), di2((i+1)*9-1 downto i*9),
	addr1(9 downto 0), addr2(9 downto 0), clk1, clk2,
  	enable1, enable2, write1, write2,
	do1((i+1)*9-1 downto i*9), do2((i+1)*9-1 downto i*9));
    end generate;
  end generate;
  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r0 : EC_RAMB8_S4_S4 port map (
	di1((i+1)*4-1 downto i*4), di2((i+1)*4-1 downto i*4),
	addr1(10 downto 0), addr2(10 downto 0), clk1, clk2,
  	enable1, enable2, write1, write2,
	do1((i+1)*4-1 downto i*4), do2((i+1)*4-1 downto i*4));
    end generate;
  end generate;
  a12 : if abits = 12 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r0 : EC_RAMB8_S2_S2 port map (
	di1((i+1)*2-1 downto i*2), di2((i+1)*2-1 downto i*2),
	addr1(11 downto 0), addr2(11 downto 0), clk1, clk2,
  	enable1, enable2, write1, write2,
	do1((i+1)*2-1 downto i*2), do2((i+1)*2-1 downto i*2));
    end generate;
  end generate;
  a13 : if abits = 13 generate
    x : for i in 0 to ((dbits-1)/1) generate
      r0 : EC_RAMB8_S1_S1 port map (
	di1((i+1)*1-1 downto i*1), di2((i+1)*1-1 downto i*1),
	addr1(12 downto 0), addr2(12 downto 0), clk1, clk2,
  	enable1, enable2, write1, write2,
	do1((i+1)*1-1 downto i*1), do2((i+1)*1-1 downto i*1));
    end generate;
  end generate;

  -- pragma translate_off
  unsup : if (abits > 13) generate
    x : process
    begin
      assert false
        report "Lattice EC syncram_dp: unsupported memory configuration!"
        severity failure;
      wait;
    end process;
  end generate;
  -- pragma translate_on

end;

