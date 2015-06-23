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
-- Entity:      tap_xilinx
-- File:        tap_xilinx.vhd
-- Author:      Edvin Catovic - Gaisler Research
-- Description: Xilinx TAP controllers wrappers
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BSCAN_VIRTEX;
-- pragma translate_on

entity virtex_tap is
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end;

architecture rtl of virtex_tap is
  component BSCAN_VIRTEX
      port (CAPTURE : out STD_ULOGIC;
            DRCK1 : out STD_ULOGIC;
            DRCK2 : out STD_ULOGIC;
            RESET : out STD_ULOGIC;
            SEL1 : out STD_ULOGIC;
            SEL2 : out STD_ULOGIC;
            SHIFT : out STD_ULOGIC;
            TDI : out STD_ULOGIC;
            UPDATE : out STD_ULOGIC;
            TDO1 : in STD_ULOGIC;
            TDO2 : in STD_ULOGIC);
  end component;

  signal drck1, drck2, sel1, sel2 : std_ulogic;
  attribute dont_touch : boolean;
  attribute dont_touch of u0 : label is true;
begin  
  
  u0 : BSCAN_VIRTEX
    port map (
              DRCK1 => drck1,
              DRCK2 => drck2,
              RESET => tapo_rst,
              SEL1 => sel1,
              SEL2 => sel2,
              SHIFT => tapo_shft,
              TDI => tapo_tdi,
              UPDATE => tapo_upd,
              TDO1 => tapi_tdo1,
              TDO2 => tapi_tdo2);
  tapo_tck <= drck1 when sel1 = '1' else drck2;
  tapo_xsel1 <= sel1; tapo_xsel2 <= sel2; tapo_capt <= '0';
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BSCAN_VIRTEX2;
-- pragma translate_on

entity virtex2_tap is
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end;

architecture rtl of virtex2_tap is

  component BSCAN_VIRTEX2
      port (CAPTURE : out STD_ULOGIC;
            DRCK1 : out STD_ULOGIC;
            DRCK2 : out STD_ULOGIC;
            RESET : out STD_ULOGIC;
            SEL1 : out STD_ULOGIC;
            SEL2 : out STD_ULOGIC;
            SHIFT : out STD_ULOGIC;
            TDI : out STD_ULOGIC;
            UPDATE : out STD_ULOGIC;
            TDO1 : in STD_ULOGIC;
            TDO2 : in STD_ULOGIC);
  end component;

  signal drck1, drck2, sel1, sel2 : std_ulogic;
  attribute dont_touch : boolean;
  attribute dont_touch of u0 : label is true;

begin  
  
  u0 : BSCAN_VIRTEX2
    port map (CAPTURE => tapo_capt,
              DRCK1 => drck1,
              DRCK2 => drck2,
              RESET => tapo_rst,
              SEL1 => sel1,
              SEL2 => sel2,
              SHIFT => tapo_shft,
              TDI => tapo_tdi,
              UPDATE => tapo_upd,
              TDO1 => tapi_tdo1,
              TDO2 => tapi_tdo2);
  tapo_tck <= drck1 when sel1 = '1' else drck2;
  tapo_xsel1 <= sel1; tapo_xsel2 <= sel2; 
end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BSCAN_SPARTAN3;
-- pragma translate_on

entity spartan3_tap is
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end;

architecture rtl of spartan3_tap is

  component BSCAN_SPARTAN3
     port (CAPTURE : out STD_ULOGIC;
           DRCK1 : out STD_ULOGIC;
           DRCK2 : out STD_ULOGIC;
           RESET : out STD_ULOGIC;
           SEL1 : out STD_ULOGIC;
           SEL2 : out STD_ULOGIC;
           SHIFT : out STD_ULOGIC;
           TDI : out STD_ULOGIC;
           UPDATE : out STD_ULOGIC;
           TDO1 : in STD_ULOGIC;
           TDO2 : in STD_ULOGIC);
  end component;

  signal drck1, drck2, sel1, sel2 : std_ulogic;
  attribute dont_touch : boolean;
  attribute dont_touch of u0 : label is true;
begin
  
  u0 : BSCAN_SPARTAN3
    port map (CAPTURE => tapo_capt,
              DRCK1 => drck1,
              DRCK2 => drck2,
              RESET => tapo_rst,
              SEL1 => sel1,
              SEL2 => sel2,
              SHIFT => tapo_shft,
              TDI => tapo_tdi,
              UPDATE => tapo_upd,
              TDO1 => tapi_tdo1,
              TDO2 => tapi_tdo2);
  tapo_tck <=  drck1 when sel1 = '1' else drck2;
  tapo_xsel1 <= sel1; tapo_xsel2 <= sel2;

end;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BSCAN_VIRTEX4;
-- pragma translate_on

entity virtex4_tap is
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end;

architecture rtl of virtex4_tap is
  component BSCAN_VIRTEX4 generic ( JTAG_CHAIN : integer := 1);
     port ( CAPTURE : out std_ulogic;
	    DRCK : out std_ulogic;
	    RESET : out std_ulogic;
	    SEL : out std_ulogic;
	    SHIFT : out std_ulogic;
	    TDI : out std_ulogic;
	    UPDATE : out std_ulogic;
	    TDO : in std_ulogic);
  end component;

  signal drck1, drck2, sel1, sel2 : std_ulogic;
  signal capt1, capt2, rst1, rst2 : std_ulogic;
  signal shift1, shift2, tdi1, tdi2 : std_ulogic;
  signal update1, update2 : std_ulogic;
  attribute dont_touch : boolean;
  attribute dont_touch of u0 : label is true;
  attribute dont_touch of u1 : label is true;
  
begin
      
  u0 : BSCAN_VIRTEX4 
    generic map (JTAG_CHAIN => 1) 
    port map (
      CAPTURE => capt1, 
      DRCK => drck1,
      RESET => rst1, 
      SEL => sel1, 
      SHIFT => shift1, 
      TDI => tdi1, 
      UPDATE => update1,
      TDO => tapi_tdo1
      );

  u1 : BSCAN_VIRTEX4 
    generic map (JTAG_CHAIN => 2) 
    port map (
      CAPTURE => capt2, 
      DRCK => drck2,
      RESET => rst2, 
      SEL => sel2, 
      SHIFT => shift2, 
      TDI => tdi2, 
      UPDATE => update2,
      TDO => tapi_tdo2
      );  

  tapo_capt <= capt1 when sel1 = '1' else capt2;
  tapo_tck  <= drck1 when sel1 = '1' else drck2;
  tapo_rst  <= rst1 when sel1 = '1' else rst2;
  tapo_shft <= shift1 when sel1 = '1' else shift2;
  tapo_tdi  <= tdi1  when sel1 = '1' else tdi2;
  tapo_upd  <= update1 when sel1 ='1' else update2;
  tapo_xsel1 <= sel1; tapo_xsel2 <= sel2;
  
  
end;


library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library unisim;
use unisim.BSCAN_VIRTEX5;
-- pragma translate_on

entity virtex5_tap is
port (
     tapi_tdo1   : in std_ulogic;
     tapi_tdo2   : in std_ulogic;
     tapo_tck    : out std_ulogic;
     tapo_tdi    : out std_ulogic;
     tapo_rst    : out std_ulogic;
     tapo_capt   : out std_ulogic;
     tapo_shft   : out std_ulogic;
     tapo_upd    : out std_ulogic;
     tapo_xsel1  : out std_ulogic;
     tapo_xsel2  : out std_ulogic
    );
end;

architecture rtl of virtex5_tap is
  component BSCAN_VIRTEX5 generic ( JTAG_CHAIN : integer := 1);
     port ( CAPTURE : out std_ulogic;
	    DRCK : out std_ulogic;
	    RESET : out std_ulogic;
	    SEL : out std_ulogic;
	    SHIFT : out std_ulogic;
	    TDI : out std_ulogic;
	    UPDATE : out std_ulogic;
	    TDO : in std_ulogic);
  end component;

  signal drck1, drck2, sel1, sel2 : std_ulogic;
  signal capt1, capt2, rst1, rst2 : std_ulogic;
  signal shift1, shift2, tdi1, tdi2 : std_ulogic;
  signal update1, update2 : std_ulogic;
  attribute dont_touch : boolean;
  attribute dont_touch of u0 : label is true;
  attribute dont_touch of u1 : label is true;
  
begin
      
  u0 : BSCAN_VIRTEX5 
    generic map (JTAG_CHAIN => 1) 
    port map (
      CAPTURE => capt1, 
      DRCK => drck1,
      RESET => rst1, 
      SEL => sel1, 
      SHIFT => shift1, 
      TDI => tdi1, 
      UPDATE => update1,
      TDO => tapi_tdo1
      );

  u1 : BSCAN_VIRTEX5 
    generic map (JTAG_CHAIN => 2) 
    port map (
      CAPTURE => capt2, 
      DRCK => drck2,
      RESET => rst2, 
      SEL => sel2, 
      SHIFT => shift2, 
      TDI => tdi2, 
      UPDATE => update2,
      TDO => tapi_tdo2
      );  

  tapo_capt <= capt1 when sel1 = '1' else capt2;
  tapo_tck  <= drck1 when sel1 = '1' else drck2;
  tapo_rst  <= rst1 when sel1 = '1' else rst2;
  tapo_shft <= shift1 when sel1 = '1' else shift2;
  tapo_tdi  <= tdi1  when sel1 = '1' else tdi2;
  tapo_upd  <= update1 when sel1 ='1' else update2;
  tapo_xsel1 <= sel1; tapo_xsel2 <= sel2;
  
  
end;




