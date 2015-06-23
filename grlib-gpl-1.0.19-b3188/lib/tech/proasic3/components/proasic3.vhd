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
-- Package: 	components
-- File:	components.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Actel proasic3 RAM component declarations
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.VITAL_Timing.all;

package components is

-- Proasic3 rams

  component RAM4K9
    generic (abits : integer range 9 to 12 := 9);
    port(
	ADDRA0, ADDRA1, ADDRA2, ADDRA3, ADDRA4, ADDRA5, ADDRA6, ADDRA7,
	ADDRA8, ADDRA9, ADDRA10, ADDRA11 : in std_logic;
	ADDRB0, ADDRB1, ADDRB2, ADDRB3, ADDRB4, ADDRB5, ADDRB6, ADDRB7,
	ADDRB8, ADDRB9, ADDRB10, ADDRB11 : in std_logic;
	BLKA, WENA, PIPEA, WMODEA, WIDTHA0, WIDTHA1, WENB, BLKB,
	PIPEB, WMODEB, WIDTHB1, WIDTHB0 : in std_logic;
	DINA0, DINA1, DINA2, DINA3, DINA4, DINA5, DINA6, DINA7, DINA8 : in std_logic;
	DINB0, DINB1, DINB2, DINB3, DINB4, DINB5, DINB6, DINB7, DINB8 : in std_logic;
	RESET, CLKA, CLKB : in std_logic; 
	DOUTA0, DOUTA1, DOUTA2, DOUTA3, DOUTA4, DOUTA5, DOUTA6, DOUTA7, DOUTA8 : out std_logic;
	DOUTB0, DOUTB1, DOUTB2, DOUTB3, DOUTB4, DOUTB5, DOUTB6, DOUTB7, DOUTB8 : out std_logic
    );
  end component;

  component RAM512X18
    port(
      RADDR8, RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
      WADDR8, WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
      WD17, WD16, WD15, WD14, WD13, WD12, WD11, WD10, WD9, 
      WD8, WD7, WD6, WD5, WD4, WD3, WD2, WD1, WD0 : in std_logic;
      REN, WEN, RESET, RW0, RW1, WW1, WW0, PIPE, RCLK, WCLK : in std_logic;
      RD17, RD16, RD15, RD14, RD13, RD12, RD11, RD10, RD9, 
      RD8, RD7, RD6, RD5, RD4, RD3, RD2, RD1, RD0 : out std_logic
    );
  end component;

  component PLL
  generic(
     VCOFREQUENCY      :  Real    := 0.0;
     f_CLKA_LOCK       :  Integer := 3; -- Number of CLKA pulses after which LOCK is raised

     TimingChecksOn    :  Boolean          := True;
     InstancePath      :  String           := "*";
     Xon               :  Boolean          := False;
     MsgOn             :  Boolean          := True;

     tipd_CLKA         :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_EXTFB        :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_POWERDOWN    :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OADIV0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OADIV1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OADIV2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OADIV3       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OADIV4       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OAMUX0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OAMUX1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OAMUX2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLA0      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLA1      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLA2      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLA3      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLA4      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBDIV0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBDIV1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBDIV2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBDIV3       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBDIV4       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBMUX0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBMUX1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OBMUX2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYB0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYB1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYB2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYB3       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYB4       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLB0      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLB1      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLB2      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLB3      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLB4      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCDIV0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCDIV1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCDIV2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCDIV3       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCDIV4       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCMUX0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCMUX1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_OCMUX2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYC0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYC1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYC2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYC3       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYYC4       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLC0      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLC1      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLC2      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLC3      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_DLYGLC4      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FINDIV0      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FINDIV1      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FINDIV2      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FINDIV3      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FINDIV4      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FINDIV5      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FINDIV6      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDIV0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDIV1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDIV2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDIV3       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDIV4       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDIV5       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDIV6       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDLY0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDLY1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDLY2       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDLY3       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBDLY4       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBSEL0       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_FBSEL1       :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_XDLYSEL      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_VCOSEL0      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_VCOSEL1      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );
     tipd_VCOSEL2      :  VitalDelayType01 := ( 0.000 ns,0.000 ns );

     tpd_CLKA_GLA      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_EXTFB_GLA     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_POWERDOWN_GLA :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_CLKA_GLB      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_EXTFB_GLB     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_POWERDOWN_GLB :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_CLKA_GLC      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_EXTFB_GLC     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_POWERDOWN_GLC :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_CLKA_YB       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_EXTFB_YB      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_POWERDOWN_YB  :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_CLKA_YC       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_EXTFB_YC      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_POWERDOWN_YC  :  VitalDelayType01 := ( 0.100 ns, 0.100 ns);
     tpd_CLKA_LOCK     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns));


  port (
     CLKA         :  in    STD_ULOGIC;
     EXTFB        :  in    STD_ULOGIC;
     POWERDOWN    :  in    STD_ULOGIC;
     OADIV0       :  in    STD_ULOGIC;
     OADIV1       :  in    STD_ULOGIC;
     OADIV2       :  in    STD_ULOGIC;
     OADIV3       :  in    STD_ULOGIC;
     OADIV4       :  in    STD_ULOGIC;
     OAMUX0       :  in    STD_ULOGIC;
     OAMUX1       :  in    STD_ULOGIC;
     OAMUX2       :  in    STD_ULOGIC;
     DLYGLA0      :  in    STD_ULOGIC;
     DLYGLA1      :  in    STD_ULOGIC;
     DLYGLA2      :  in    STD_ULOGIC;
     DLYGLA3      :  in    STD_ULOGIC;
     DLYGLA4      :  in    STD_ULOGIC;
     OBDIV0       :  in    STD_ULOGIC;
     OBDIV1       :  in    STD_ULOGIC;
     OBDIV2       :  in    STD_ULOGIC;
     OBDIV3       :  in    STD_ULOGIC;
     OBDIV4       :  in    STD_ULOGIC;
     OBMUX0       :  in    STD_ULOGIC;
     OBMUX1       :  in    STD_ULOGIC;
     OBMUX2       :  in    STD_ULOGIC;
     DLYYB0       :  in    STD_ULOGIC;
     DLYYB1       :  in    STD_ULOGIC;
     DLYYB2       :  in    STD_ULOGIC;
     DLYYB3       :  in    STD_ULOGIC;
     DLYYB4       :  in    STD_ULOGIC;
     DLYGLB0      :  in    STD_ULOGIC;
     DLYGLB1      :  in    STD_ULOGIC;
     DLYGLB2      :  in    STD_ULOGIC;
     DLYGLB3      :  in    STD_ULOGIC;
     DLYGLB4      :  in    STD_ULOGIC;
     OCDIV0       :  in    STD_ULOGIC;
     OCDIV1       :  in    STD_ULOGIC;
     OCDIV2       :  in    STD_ULOGIC;
     OCDIV3       :  in    STD_ULOGIC;
     OCDIV4       :  in    STD_ULOGIC;
     OCMUX0       :  in    STD_ULOGIC;
     OCMUX1       :  in    STD_ULOGIC;
     OCMUX2       :  in    STD_ULOGIC;
     DLYYC0       :  in    STD_ULOGIC;
     DLYYC1       :  in    STD_ULOGIC;
     DLYYC2       :  in    STD_ULOGIC;
     DLYYC3       :  in    STD_ULOGIC;
     DLYYC4       :  in    STD_ULOGIC;
     DLYGLC0      :  in    STD_ULOGIC;
     DLYGLC1      :  in    STD_ULOGIC;
     DLYGLC2      :  in    STD_ULOGIC;
     DLYGLC3      :  in    STD_ULOGIC;
     DLYGLC4      :  in    STD_ULOGIC;
     FINDIV0      :  in    STD_ULOGIC;
     FINDIV1      :  in    STD_ULOGIC;
     FINDIV2      :  in    STD_ULOGIC;
     FINDIV3      :  in    STD_ULOGIC;
     FINDIV4      :  in    STD_ULOGIC;
     FINDIV5      :  in    STD_ULOGIC;
     FINDIV6      :  in    STD_ULOGIC;
     FBDIV0       :  in    STD_ULOGIC;
     FBDIV1       :  in    STD_ULOGIC;
     FBDIV2       :  in    STD_ULOGIC;
     FBDIV3       :  in    STD_ULOGIC;
     FBDIV4       :  in    STD_ULOGIC;
     FBDIV5       :  in    STD_ULOGIC;
     FBDIV6       :  in    STD_ULOGIC;
     FBDLY0       :  in    STD_ULOGIC;
     FBDLY1       :  in    STD_ULOGIC;
     FBDLY2       :  in    STD_ULOGIC;
     FBDLY3       :  in    STD_ULOGIC;
     FBDLY4       :  in    STD_ULOGIC;
     FBSEL0       :  in    STD_ULOGIC;
     FBSEL1       :  in    STD_ULOGIC;
     XDLYSEL      :  in    STD_ULOGIC;
     VCOSEL0      :  in    STD_ULOGIC;
     VCOSEL1      :  in    STD_ULOGIC;
     VCOSEL2      :  in    STD_ULOGIC;
     GLA          :  out   STD_ULOGIC;
     LOCK         :  out   STD_ULOGIC;
     GLB          :  out   STD_ULOGIC;
     YB           :  out   STD_ULOGIC;
     GLC          :  out   STD_ULOGIC;
     YC           :  out   STD_ULOGIC);
  end component;

  component CLKBUF port(Y : out std_logic; PAD : in std_logic); end component;
  component CLKBUF_LVCMOS18 port(Y : out std_logic; PAD : in std_logic); end component;
  component CLKBUF_LVCMOS25 port(Y : out std_logic; PAD : in std_logic); end component;
  component CLKBUF_LVCMOS33 port(Y : out std_logic; PAD : in std_logic); end component;
  component CLKBUF_LVCMOS5 port(Y : out std_logic; PAD : in std_logic); end component;
  component CLKBUF_PCI port(Y : out std_logic; PAD : in std_logic); end component;
  component CLKINT port( A : in std_logic; Y :out std_logic); end component;
  component PLLINT port( A : in std_logic; Y :out std_logic); end component;

 component UJTAG
   port(
      UTDO           :  in    STD_ULOGIC;
      TMS            :  in    STD_ULOGIC;
      TDI            :  in    STD_ULOGIC;
      TCK            :  in    STD_ULOGIC;
      TRSTB          :  in    STD_ULOGIC;
      UIREG0         :  out   STD_ULOGIC;
      UIREG1         :  out   STD_ULOGIC;
      UIREG2         :  out   STD_ULOGIC;
      UIREG3         :  out   STD_ULOGIC;
      UIREG4         :  out   STD_ULOGIC;
      UIREG5         :  out   STD_ULOGIC;
      UIREG6         :  out   STD_ULOGIC;
      UIREG7         :  out   STD_ULOGIC;
      UTDI           :  out   STD_ULOGIC;
      URSTB          :  out   STD_ULOGIC;
      UDRCK          :  out   STD_ULOGIC;
      UDRCAP         :  out   STD_ULOGIC;
      UDRSH          :  out   STD_ULOGIC;
      UDRUPD         :  out   STD_ULOGIC;
      TDO            :  out   STD_ULOGIC);
 end component;
  
end;

library ieee;
use ieee.std_logic_1164.all;
entity PLLINT is port(Y : out std_logic; A : in std_logic); end;
architecture rtl of PLLINT is begin Y <= A; end;

library ieee;
use ieee.std_logic_1164.all;
entity CLKINT is port(Y : out std_logic; A : in std_logic); end;
architecture rtl of CLKINT is begin Y <= A; end;

library ieee;
use ieee.std_logic_1164.all;
entity CLKBUF is port(Y : out std_logic; PAD : in std_logic); end;
architecture rtl of CLKBUF is begin Y <= PAD; end;

library ieee;
use ieee.std_logic_1164.all;
entity CLKBUF_PCI is port(Y : out std_logic; PAD : in std_logic); end;
architecture rtl of CLKBUF_PCI is begin Y <= PAD; end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM4K9 is generic (abits : integer range 9 to 12 := 9);
    port(
	ADDRA0, ADDRA1, ADDRA2, ADDRA3, ADDRA4, ADDRA5, ADDRA6, ADDRA7,
	ADDRA8, ADDRA9, ADDRA10, ADDRA11 : in std_logic;
	ADDRB0, ADDRB1, ADDRB2, ADDRB3, ADDRB4, ADDRB5, ADDRB6, ADDRB7,
	ADDRB8, ADDRB9, ADDRB10, ADDRB11 : in std_logic;
	BLKA, WENA, PIPEA, WMODEA, WIDTHA0, WIDTHA1, WENB, BLKB,
	PIPEB, WMODEB, WIDTHB1, WIDTHB0 : in std_logic;
	DINA0, DINA1, DINA2, DINA3, DINA4, DINA5, DINA6, DINA7, DINA8 : in std_logic;
	DINB0, DINB1, DINB2, DINB3, DINB4, DINB5, DINB6, DINB7, DINB8 : in std_logic;
	RESET, CLKA, CLKB : in std_logic; 
	DOUTA0, DOUTA1, DOUTA2, DOUTA3, DOUTA4, DOUTA5, DOUTA6, DOUTA7, DOUTA8 : out std_logic;
	DOUTB0, DOUTB1, DOUTB2, DOUTB3, DOUTB4, DOUTB5, DOUTB6, DOUTB7, DOUTB8 : out std_logic
    );
end ;

architecture sim of RAM4K9 is
  type dwarrtype is array (9 to 12) of integer;
  constant dwarr : dwarrtype := (9, 4, 2, 1);
  constant dwidth : integer := dwarr(abits);
  subtype memword is std_logic_vector(dwidth-1 downto 0);
  type memtype is array (0 to 2**abits-1) of memword;
begin
  p1 : process(CLKA, CLKB, RESET)
  variable mem : memtype;
  variable ra, rb : std_logic_vector(11 downto 0);
  variable da, db : std_logic_vector(8 downto 0);
  variable qa, qb : std_logic_vector(8 downto 0);
  variable qal, qbl : std_logic_vector(8 downto 0);
  variable qao, qbo : std_logic_vector(8 downto 0);
  begin
   if rising_edge(CLKA) then
     ra := ADDRA11 & ADDRA10 & ADDRA9 & ADDRA8 & ADDRA7 & ADDRA6 & ADDRA5 &
	ADDRA4 & ADDRA3 & ADDRA2 & ADDRA1 & ADDRA0;
     da := DINA8 & DINA7 & DINA6 & DINA5 & DINA4 & DINA3 & DINA2 & 
	DINA1 & DINA0;
      if BLKA = '0' then 
        if not (is_x (ra(abits-1 downto 0))) then 
          qa(dwidth-1 downto 0) := mem(to_integer(unsigned(ra(abits-1 downto 0))));
        else qa := (others => 'X'); end if;
	if WENA = '0' and not (is_x (ra(abits-1 downto 0))) then
	  mem(to_integer(unsigned(ra(abits-1 downto 0)))) := da(dwidth-1 downto 0);
	  if WMODEA = '1' then qa := da(dwidth-1 downto 0); end if;
        end if;
      elsif is_x(BLKA) then qa := (others => 'X'); end if;
      if PIPEA = '1' then qao := qal; else qao := qa; end if;
      qal := qa;
   end if;
   if reset = '0' then qao := (others => '0'); end if;
   (DOUTA8, DOUTA7, DOUTA6, DOUTA5, DOUTA4, DOUTA3, DOUTA2, 
	DOUTA1, DOUTA0) <= qao;
   if rising_edge(CLKB) then
     rb := ADDRB11 & ADDRB10 & ADDRB9 & ADDRB8 & ADDRB7 & ADDRB6 & ADDRB5 &
	ADDRB4 & ADDRB3 & ADDRB2 & ADDRB1 & ADDRB0;
     db := DINB8 & DINB7 & DINB6 & DINB5 & DINB4 & DINB3 & DINB2 & 
	DINB1 & DINB0;
      if BLKB = '0' then 
        if not (is_x (rb(abits-1 downto 0))) then 
          qb(dwidth-1 downto 0) := mem(to_integer(unsigned(rb(abits-1 downto 0))));
        else qb := (others => 'X'); end if;
	if WENB = '0' and not (is_x (rb(abits-1 downto 0))) then
	  mem(to_integer(unsigned(rb(abits-1 downto 0)))) := db(dwidth-1 downto 0);
	  if WMODEB = '1' then qb := db(dwidth-1 downto 0); end if;
        end if;
      elsif is_x(BLKB) then qb := (others => 'X'); end if;
      if PIPEB = '1' then qbo := qbl; else qbo := qb; end if;
      qbl := qb;
   end if;
   if reset = '0' then qbo := (others => '0'); end if;
   (DOUTB8, DOUTB7, DOUTB6, DOUTB5, DOUTB4, DOUTB3, DOUTB2, 
	DOUTB1, DOUTB0) <= qbo;
  end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM512X18 is 
    port(
      RADDR8, RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
      WADDR8, WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
      WD17, WD16, WD15, WD14, WD13, WD12, WD11, WD10, WD9, 
      WD8, WD7, WD6, WD5, WD4, WD3, WD2, WD1, WD0 : in std_logic;
      REN, WEN, RESET, RW0, RW1, WW1, WW0, PIPE, RCLK, WCLK : in std_logic;
      RD17, RD16, RD15, RD14, RD13, RD12, RD11, RD10, RD9, 
      RD8, RD7, RD6, RD5, RD4, RD3, RD2, RD1, RD0 : out std_logic
    );
end ;

architecture sim of RAM512X18 is
  constant abits : integer := 8;
  constant dwidth : integer := 18;
  subtype memword is std_logic_vector(dwidth-1 downto 0);
  type memtype is array (0 to 2**abits-1) of memword;
begin
  p1 : process(RCLK, WCLK, RESET)
  variable mem : memtype;
  variable ra, rb  : std_logic_vector(8 downto 0);
  variable da  : std_logic_vector(17 downto 0);
  variable qb  : std_logic_vector(17 downto 0);
  variable qbl : std_logic_vector(17 downto 0);
  variable qbo : std_logic_vector(17 downto 0);
  begin
   if rising_edge(WCLK) then
     ra :=  '0' & WADDR7 & WADDR6 & WADDR5 &
	WADDR4 & WADDR3 & WADDR2 & WADDR1 & WADDR0;
     da := WD17 & WD16 & WD15 & WD14 & WD13 & WD12 & WD11 & 
	Wd10 & WD9 & WD8 & WD7 & WD6 & WD5 & WD4 & WD3 & WD2 & 
	WD1 & WD0;
     if WEN = '0' and not (is_x (ra(abits-1 downto 0))) then
       mem(to_integer(unsigned(ra(abits-1 downto 0)))) := da(dwidth-1 downto 0);
     end if;
   end if;
   if rising_edge(RCLK) then
     rb :=  '0' & RADDR7 & RADDR6 & RADDR5 &
	RADDR4 & RADDR3 & RADDR2 & RADDR1 & RADDR0;
      if REN = '0' then 
        if not (is_x (rb(abits-1 downto 0))) then 
          qb := mem(to_integer(unsigned(rb(abits-1 downto 0))));
        else qb := (others => 'X'); end if;
      elsif is_x(REN) then qb := (others => 'X'); end if;
      if PIPE = '1' then qbo := qbl; else qbo := qb; end if;
      qbl := qb;
   end if;
   if RESET = '0' then qbo := (others => '0'); end if;
   (RD17, RD16, RD15, RD14, RD13, RD12, RD11, RD10, RD9,
      RD8, RD7, RD6, RD5, RD4, RD3, RD2, RD1, RD0) <= qbo;
  end process;
end;

library IEEE;
use IEEE.std_logic_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

-- entity declaration --
entity PLLPRIM is
  generic (
    VCOFREQUENCY       :  Real    := 0.0;
    f_CLKA_LOCK        :  Integer := 3; -- Number of CLKA pulses after which LOCK is raised

    TimingChecksOn     :  Boolean          := True;
    InstancePath       :  String           := "*";
    Xon                :  Boolean          := False;
    MsgOn              :  Boolean          := True;
    EMULATED_SYSTEM_DELAY :  Time          := 2.290 ns; -- Delay Tap Additional CLK delay
    IN_DIV_DELAY       :  Time             := 0.335 ns; -- Input Divider intrinsic delay
    OUT_DIV_DELAY      :  Time             := 0.770 ns; -- Output Divider intrinsic delay
    MUX_DELAY          :  Time             := 1.200 ns; -- MUXA/MUXB/MUXC intrinsic delay
    IN_DELAY_BYP1      :  Time             := 1.523 ns; -- Input delay for CLKDIVDLY bypass mode
    BYP_MUX_DELAY      :  Time             := 0.040 ns; -- Bypass MUX intrinsic delay, not used for Ys
    GL_DRVR_DELAY      :  Time             := 0.060 ns; -- Global Driver intrinsic delay
    Y_DRVR_DELAY       :  Time             := 0.285 ns; -- Y Driver intrinsic delay
    FB_MUX_DELAY       :  Time             := 0.145 ns; -- FBSEL MUX intrinsic delay
    X_MUX_DELAY        :  Time             := 0.625 ns; -- XDLYSEL MUX intrinsic delay
    FIN_LOCK_DELAY     :  Time             := 0.300 ns; -- FIN to LOCK propagation delay
    LOCK_OUT_DELAY     :  Time             := 0.120 ns; -- LOCK to OUT propagation delay
    PROG_INIT_DELAY     : Time             := 0.535 ns;
    PROG_STEP_INCREMENT : Time             := 0.200 ns;
    BYP0_CLK_GL         : Time             := 0.200 ns; -- Intrinsic delay for CLKDLY bypass mode
    CLKA_TO_REF_DELAY  : Time              := 0.395 ns;
    
    tipd_DYNSYNC       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_CLKA          :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_EXTFB         :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_POWERDOWN     :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_CLKB          :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_CLKC          :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIVRST      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIVHALF     :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV3        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV4        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OAMUX0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OAMUX1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OAMUX2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIVRST      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIVHALF     :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV3        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV4        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBMUX0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBMUX1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBMUX2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB3        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB4        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIVRST      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIVHALF     :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV3        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV4        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCMUX0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCMUX1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCMUX2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC3        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC4        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV5       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV6       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV3        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV4        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV5        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV6        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY2        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY3        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY4        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBSEL0        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBSEL1        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_XDLYSEL       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_VCOSEL0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_VCOSEL1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_VCOSEL2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );

    tpd_CLKA_GLA       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_GLA      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_GLA  :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_GLB       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_GLB      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_GLB  :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_GLC       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_GLC      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_GLC  :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_YB        :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_YB       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_YB   :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_YC        :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_YC       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_YC   :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_LOCK      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_LOCK     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_LOCK :  VitalDelayType01 := ( 0.100 ns, 0.100 ns )
   );

  port (
    DYNSYNC      : in    std_ulogic;
    CLKA         : in    std_ulogic;
    EXTFB        : in    std_ulogic;
    POWERDOWN    : in    std_ulogic;
    CLKB         : in    std_ulogic;
    CLKC         : in    std_ulogic;
    OADIVRST     : in    std_ulogic;
    OADIVHALF    : in    std_ulogic;
    OADIV0       : in    std_ulogic;
    OADIV1       : in    std_ulogic;
    OADIV2       : in    std_ulogic;
    OADIV3       : in    std_ulogic;
    OADIV4       : in    std_ulogic;
    OAMUX0       : in    std_ulogic;
    OAMUX1       : in    std_ulogic;
    OAMUX2       : in    std_ulogic;
    DLYGLA0      : in    std_ulogic;
    DLYGLA1      : in    std_ulogic;
    DLYGLA2      : in    std_ulogic;
    DLYGLA3      : in    std_ulogic;
    DLYGLA4      : in    std_ulogic;
    OBDIVRST     : in    std_ulogic;
    OBDIVHALF    : in    std_ulogic;
    OBDIV0       : in    std_ulogic;
    OBDIV1       : in    std_ulogic;
    OBDIV2       : in    std_ulogic;
    OBDIV3       : in    std_ulogic;
    OBDIV4       : in    std_ulogic;
    OBMUX0       : in    std_ulogic;
    OBMUX1       : in    std_ulogic;
    OBMUX2       : in    std_ulogic;
    DLYYB0       : in    std_ulogic;
    DLYYB1       : in    std_ulogic;
    DLYYB2       : in    std_ulogic;
    DLYYB3       : in    std_ulogic;
    DLYYB4       : in    std_ulogic;
    DLYGLB0      : in    std_ulogic;
    DLYGLB1      : in    std_ulogic;
    DLYGLB2      : in    std_ulogic;
    DLYGLB3      : in    std_ulogic;
    DLYGLB4      : in    std_ulogic;
    OCDIVRST     : in    std_ulogic;
    OCDIVHALF    : in    std_ulogic;
    OCDIV0       : in    std_ulogic;
    OCDIV1       : in    std_ulogic;
    OCDIV2       : in    std_ulogic;
    OCDIV3       : in    std_ulogic;
    OCDIV4       : in    std_ulogic;
    OCMUX0       : in    std_ulogic;
    OCMUX1       : in    std_ulogic;
    OCMUX2       : in    std_ulogic;
    DLYYC0       : in    std_ulogic;
    DLYYC1       : in    std_ulogic;
    DLYYC2       : in    std_ulogic;
    DLYYC3       : in    std_ulogic;
    DLYYC4       : in    std_ulogic;
    DLYGLC0      : in    std_ulogic;
    DLYGLC1      : in    std_ulogic;
    DLYGLC2      : in    std_ulogic;
    DLYGLC3      : in    std_ulogic;
    DLYGLC4      : in    std_ulogic;
    FINDIV0      : in    std_ulogic;
    FINDIV1      : in    std_ulogic;
    FINDIV2      : in    std_ulogic;
    FINDIV3      : in    std_ulogic;
    FINDIV4      : in    std_ulogic;
    FINDIV5      : in    std_ulogic;
    FINDIV6      : in    std_ulogic;
    FBDIV0       : in    std_ulogic;
    FBDIV1       : in    std_ulogic;
    FBDIV2       : in    std_ulogic;
    FBDIV3       : in    std_ulogic;
    FBDIV4       : in    std_ulogic;
    FBDIV5       : in    std_ulogic;
    FBDIV6       : in    std_ulogic;
    FBDLY0       : in    std_ulogic;
    FBDLY1       : in    std_ulogic;
    FBDLY2       : in    std_ulogic;
    FBDLY3       : in    std_ulogic;
    FBDLY4       : in    std_ulogic;
    FBSEL0       : in    std_ulogic;
    FBSEL1       : in    std_ulogic;
    XDLYSEL      : in    std_ulogic;
    VCOSEL0      : in    std_ulogic;
    VCOSEL1      : in    std_ulogic;
    VCOSEL2      : in    std_ulogic;
    GLA          : out   std_ulogic;
    LOCK         : out   std_ulogic;
    GLB          : out   std_ulogic;
    YB           : out   std_ulogic;
    GLC          : out   std_ulogic;
    YC           : out   std_ulogic
   );

  attribute VITAL_LEVEL0 of PLLPRIM : entity is TRUE;
end PLLPRIM;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
architecture VITAL_ACT of PLLPRIM is
attribute VITAL_LEVEL1 of VITAL_ACT : architecture is FALSE;

  signal DYNSYNC_ipd            : std_ulogic;
  signal CLKA_ipd               : std_ulogic;
  signal EXTFB_ipd              : std_ulogic;
  signal POWERDOWN_ipd          : std_ulogic;
  signal CLKB_ipd               : std_ulogic;
  signal CLKC_ipd               : std_ulogic;
  signal OADIVRST_ipd           : std_ulogic;
  signal OADIVHALF_ipd          : std_ulogic;
  signal OADIV0_ipd             : std_ulogic;
  signal OADIV1_ipd             : std_ulogic;
  signal OADIV2_ipd             : std_ulogic;
  signal OADIV3_ipd             : std_ulogic;
  signal OADIV4_ipd             : std_ulogic;
  signal OAMUX0_ipd             : std_ulogic;
  signal OAMUX1_ipd             : std_ulogic;
  signal OAMUX2_ipd             : std_ulogic;
  signal DLYGLA0_ipd            : std_ulogic;
  signal DLYGLA1_ipd            : std_ulogic;
  signal DLYGLA2_ipd            : std_ulogic;
  signal DLYGLA3_ipd            : std_ulogic;
  signal DLYGLA4_ipd            : std_ulogic;
  signal OBDIVRST_ipd           : std_ulogic;
  signal OBDIVHALF_ipd          : std_ulogic;
  signal OBDIV0_ipd             : std_ulogic;
  signal OBDIV1_ipd             : std_ulogic;
  signal OBDIV2_ipd             : std_ulogic;
  signal OBDIV3_ipd             : std_ulogic;
  signal OBDIV4_ipd             : std_ulogic;
  signal OBMUX0_ipd             : std_ulogic;
  signal OBMUX1_ipd             : std_ulogic;
  signal OBMUX2_ipd             : std_ulogic;
  signal DLYYB0_ipd             : std_ulogic;
  signal DLYYB1_ipd             : std_ulogic;
  signal DLYYB2_ipd             : std_ulogic;
  signal DLYYB3_ipd             : std_ulogic;
  signal DLYYB4_ipd             : std_ulogic;
  signal DLYGLB0_ipd            : std_ulogic;
  signal DLYGLB1_ipd            : std_ulogic;
  signal DLYGLB2_ipd            : std_ulogic;
  signal DLYGLB3_ipd            : std_ulogic;
  signal DLYGLB4_ipd            : std_ulogic;
  signal OCDIVRST_ipd           : std_ulogic;
  signal OCDIVHALF_ipd          : std_ulogic;
  signal OCDIV0_ipd             : std_ulogic;
  signal OCDIV1_ipd             : std_ulogic;
  signal OCDIV2_ipd             : std_ulogic;
  signal OCDIV3_ipd             : std_ulogic;
  signal OCDIV4_ipd             : std_ulogic;
  signal OCMUX0_ipd             : std_ulogic;
  signal OCMUX1_ipd             : std_ulogic;
  signal OCMUX2_ipd             : std_ulogic;
  signal DLYYC0_ipd             : std_ulogic;
  signal DLYYC1_ipd             : std_ulogic;
  signal DLYYC2_ipd             : std_ulogic;
  signal DLYYC3_ipd             : std_ulogic;
  signal DLYYC4_ipd             : std_ulogic;
  signal DLYGLC0_ipd            : std_ulogic;
  signal DLYGLC1_ipd            : std_ulogic;
  signal DLYGLC2_ipd            : std_ulogic;
  signal DLYGLC3_ipd            : std_ulogic;
  signal DLYGLC4_ipd            : std_ulogic;
  signal FINDIV0_ipd            : std_ulogic;
  signal FINDIV1_ipd            : std_ulogic;
  signal FINDIV2_ipd            : std_ulogic;
  signal FINDIV3_ipd            : std_ulogic;
  signal FINDIV4_ipd            : std_ulogic;
  signal FINDIV5_ipd            : std_ulogic;
  signal FINDIV6_ipd            : std_ulogic;
  signal FBDIV0_ipd             : std_ulogic;
  signal FBDIV1_ipd             : std_ulogic;
  signal FBDIV2_ipd             : std_ulogic;
  signal FBDIV3_ipd             : std_ulogic;
  signal FBDIV4_ipd             : std_ulogic;
  signal FBDIV5_ipd             : std_ulogic;
  signal FBDIV6_ipd             : std_ulogic;
  signal FBDLY0_ipd             : std_ulogic;
  signal FBDLY1_ipd             : std_ulogic;
  signal FBDLY2_ipd             : std_ulogic;
  signal FBDLY3_ipd             : std_ulogic;
  signal FBDLY4_ipd             : std_ulogic;
  signal FBSEL0_ipd             : std_ulogic;
  signal FBSEL1_ipd             : std_ulogic;
  signal XDLYSEL_ipd            : std_ulogic;
  signal VCOSEL0_ipd            : std_ulogic;
  signal VCOSEL1_ipd            : std_ulogic;
  signal VCOSEL2_ipd            : std_ulogic;

  signal AOUT                   : std_logic := 'X';
  signal BOUT                   : std_logic := 'X';
  signal COUT                   : std_logic := 'X';

  signal PLLCLK                 : std_logic := 'X';      -- PLL Core Output Clock 
                                                         -- with DIVN and DIVM applied
  signal CLKA_period            : Time      := 0.000 ns; -- Current CLKA period

  signal PLLCLK_pw              : Time      := 10.0 ns; -- PLLCLK pulse width
  signal PLLCLK_period          : Time      := 10.0 ns;

  signal DIVN                   : Integer := 1; -- Divide by N divisor - range 1 to 128
  signal DIVM                   : Integer := 1; -- Multiply by M multiplier - range 1 to 128
  signal DIVU                   : Integer := 1; -- Divide by U divisor - range 1 to 32
  signal DIVV                   : Integer := 1; -- Divide by V divisor - range 1 to 32
  signal DIVW                   : Integer := 1; -- Divide by W divisor - range 1 to 32
  signal fb_loop_div            : Integer := 1; -- Total division of feedback loop

  signal halveA                 : std_logic := 'X';
  signal halveB                 : std_logic := 'X';
  signal halveC                 : std_logic := 'X';

  signal CLKA2X                 : std_logic := 'X';
  signal CLKB2X                 : std_logic := 'X';
  signal CLKC2X                 : std_logic := 'X';

  signal UIN                    : std_logic := 'X'; -- Output of MUXA
  signal VIN                    : std_logic := 'X'; -- Output of MUXB
  signal WIN                    : std_logic := 'X'; -- Output of MUXC

  signal FBDELAY                : Time := 0.000 ns; -- Feedback delay
  signal DTDELAY                : Time := 0.000 ns; -- Delay Tap delay
  signal PLLDELAY               : Time := 0.000 ns; -- Sum of Feedback and Delay Tap delays
  signal YBDELAY                : Time := 0.000 ns; -- Additional Global B Delay
  signal GLBDELAY               : Time := 0.000 ns; -- Additional Global B Delay
  signal YCDELAY                : Time := 0.000 ns; -- Additional Global C Delay
  signal GLCDELAY               : Time := 0.000 ns; -- Additional Global C Delay
  signal GLADELAY               : Time := 0.000 ns; -- Additional Global A Delay

  signal FBSEL                  : std_logic_vector( 1 downto 0 ) := "XX";
  signal FBSEL_illegal          : Boolean := False; -- True when FBSEL = 00

  signal OAMUX_config           : integer := -1;
  signal OBMUX_config           : integer := -1;
  signal OCMUX_config           : integer := -1;

  signal internal_lock          : boolean   := false;
  signal fin_period             : Time      := 0.000 ns;
  signal extfbin_fin_drift      : time      := 0 ps;
  signal locked                 : std_logic := '0'; -- 1 when PLL is externally locked as well as internally locked
  signal locked_vco0_edges      : integer   := -1;
  signal vco0_divu              : std_logic := '0';
  signal vco0_divv              : std_logic := '0';
  signal vco0_divw              : std_logic := '0';
  signal fin                    : std_logic := '0';
  signal CLKA_period_stable     : boolean   := false;

  signal using_EXTFB            : std_logic := 'X';
  signal EXTFB_delay_dtrmd      : Boolean   := false;
  signal calibrate_EXTFB_delay  : std_logic := '0';
  signal GLA_free_running       : std_logic := '1';
  signal AOUT_using_EXTFB       : std_logic := '1';
  signal GLA_pw                 : time      := 10.0 ns; -- Only used for external feedback
  signal GLA_EXTFB_rise_dly     : time      := 0.0 ns;  -- Only meaningful for external feedback
  signal GLA_EXTFB_fall_dly     : time      := 0.0 ns;  -- Only meaningful for external feedback
  signal EXTFB_period           : time      := 20.0 ns;  -- Only meaningful for external feedback
  signal expected_EXTFB         : std_logic := 'X';
  signal external_dly_correct   : std_logic := 'X';

  signal gla_muxed_delay        : time      := 0.000 ns;
  signal glb_muxed_delay        : time      := 0.000 ns;
  signal glc_muxed_delay        : time      := 0.000 ns;

  signal internal_fb_delay      : time      := 0.000 ns;
  signal external_fb_delay      : time      := 0.000 ns;
  signal normalized_fb_delay    : time      := 0.000 ns; -- Sum of all delays in the feedback loop from VCO to FBIN normalized to be less than or equal to fin period so that no negative delay assignments are made.

  signal CLKA_2_GLA_dly         : time      := 0.000 ns;
  signal CLKA_2_GLA_bypass0_dly : time      := 0.000 ns;
  signal CLKA_2_GLA_bypass1_dly : time      := 0.000 ns;
  signal CLKA_2_GLB_dly         : time      := 0.000 ns;
  signal CLKB_2_GLB_bypass0_dly : time      := 0.000 ns;
  signal CLKB_2_GLB_bypass1_dly : time      := 0.000 ns;
  signal CLKA_2_YB_dly          : time      := 0.000 ns;
  signal CLKB_2_YB_bypass1_dly  : time      := 0.000 ns;
  signal CLKA_2_GLC_dly         : time      := 0.000 ns;
  signal CLKC_2_GLC_bypass0_dly : time      := 0.000 ns;
  signal CLKC_2_GLC_bypass1_dly : time      := 0.000 ns;
  signal CLKA_2_YC_dly          : time      := 0.000 ns;
  signal CLKC_2_YC_bypass1_dly  : time      := 0.000 ns;
  signal CLKA_2_LOCK_dly        : time      := 0.000 ns;


  -- Use this instead of CONV_INTEGER to avoid ambiguous warnings
  function ulogic2int(
    vec  : std_ulogic_vector )
    return integer is
    variable result : integer;
    variable i : integer;
  begin
    result := 0;
    for i in vec'range loop
      result := result * 2;
      if vec(i) = '1' then
        result := result + 1;
      end if;
    end loop;
    return result;
  end function ulogic2int;

  function output_mux_delay( 
    outmux      : integer;
    vcobit2     : std_logic;
    vcobit1     : std_logic;
    fbdly_delay : time;
    vco_pw      : time )
    return time is
    variable result : time;
  begin
     case outmux is
        when 1  => result := IN_DELAY_BYP1;
        when 2  => result := MUX_DELAY + fbdly_delay;
        when 5  => if ( ( vcobit2 = '1') and ( vcobit1 = '1') ) then
                         result := MUX_DELAY + ( vco_pw / 2.0 );
                       else
                         result := MUX_DELAY + ( vco_pw * 1.5 );
                       end if;
        when 6  => result := MUX_DELAY + vco_pw;
        when 7  => if ( ( vcobit2 = '1') and ( vcobit1 = '1') ) then
                         result := MUX_DELAY + ( vco_pw * 1.5 );
                       else
                         result := MUX_DELAY + ( vco_pw / 2.0 );
                       end if;
        when others => result := MUX_DELAY;
     end case;
     return result;
  end function output_mux_delay;


  function output_mux_driver( 
    outmux      : integer;
    halved      : std_logic;
    bypass      : std_logic;
    bypass2x    : std_logic;
    vco         : std_logic )
    return std_logic is
    variable result : std_logic;
  begin
     case outmux is
        when 1  => if ( '1' = halved ) then
                          result := bypass2x;
                       elsif ( '0' = halved ) then
                          result := bypass;
                       else
                          result := 'X';
                       end if;
        when 2  => result := vco;
        when 4  => result := vco;
        when 5  => result := vco;
        when 6  => result := vco;
        when 7  => result := vco;
        when others => result := 'X';
     end case;
     return result;
  end function output_mux_driver;

  begin

    ---------------------
    --  INPUT PATH DELAYs
    ---------------------
    WireDelay : block

    begin

      VitalWireDelay ( DYNSYNC_ipd,   DYNSYNC,   tipd_DYNSYNC   );
      VitalWireDelay ( CLKA_ipd,      CLKA,      tipd_CLKA      );
      VitalWireDelay ( EXTFB_ipd,     EXTFB,     tipd_EXTFB     );
      VitalWireDelay ( POWERDOWN_ipd, POWERDOWN, tipd_POWERDOWN );
      VitalWireDelay ( CLKB_ipd,      CLKB,      tipd_CLKB      );
      VitalWireDelay ( CLKC_ipd,      CLKC,      tipd_CLKC      );
      VitalWireDelay ( OADIVRST_ipd,  OADIVRST,  tipd_OADIVRST  );
      VitalWireDelay ( OADIVHALF_ipd, OADIVHALF, tipd_OADIVHALF );
      VitalWireDelay ( OADIV0_ipd,    OADIV0,    tipd_OADIV0    );
      VitalWireDelay ( OADIV1_ipd,    OADIV1,    tipd_OADIV1    );
      VitalWireDelay ( OADIV2_ipd,    OADIV2,    tipd_OADIV2    );
      VitalWireDelay ( OADIV3_ipd,    OADIV3,    tipd_OADIV3    );
      VitalWireDelay ( OADIV4_ipd,    OADIV4,    tipd_OADIV4    );
      VitalWireDelay ( OAMUX0_ipd,    OAMUX0,    tipd_OAMUX0    );
      VitalWireDelay ( OAMUX1_ipd,    OAMUX1,    tipd_OAMUX1    );
      VitalWireDelay ( OAMUX2_ipd,    OAMUX2,    tipd_OAMUX2    );
      VitalWireDelay ( DLYGLA0_ipd,   DLYGLA0,   tipd_DLYGLA0   );
      VitalWireDelay ( DLYGLA1_ipd,   DLYGLA1,   tipd_DLYGLA1   );
      VitalWireDelay ( DLYGLA2_ipd,   DLYGLA2,   tipd_DLYGLA2   );
      VitalWireDelay ( DLYGLA3_ipd,   DLYGLA3,   tipd_DLYGLA3   );
      VitalWireDelay ( DLYGLA4_ipd,   DLYGLA4,   tipd_DLYGLA4   );
      VitalWireDelay ( OBDIVRST_ipd,  OBDIVRST,  tipd_OBDIVRST  );
      VitalWireDelay ( OBDIVHALF_ipd, OBDIVHALF, tipd_OBDIVHALF );
      VitalWireDelay ( OBDIV0_ipd,    OBDIV0,    tipd_OBDIV0    );
      VitalWireDelay ( OBDIV1_ipd,    OBDIV1,    tipd_OBDIV1    );
      VitalWireDelay ( OBDIV2_ipd,    OBDIV2,    tipd_OBDIV2    );
      VitalWireDelay ( OBDIV3_ipd,    OBDIV3,    tipd_OBDIV3    );
      VitalWireDelay ( OBDIV4_ipd,    OBDIV4,    tipd_OBDIV4    );
      VitalWireDelay ( OBMUX0_ipd,    OBMUX0,    tipd_OBMUX0    );
      VitalWireDelay ( OBMUX1_ipd,    OBMUX1,    tipd_OBMUX1    );
      VitalWireDelay ( OBMUX2_ipd,    OBMUX2,    tipd_OBMUX2    );
      VitalWireDelay ( DLYYB0_ipd,    DLYYB0,    tipd_DLYYB0    );
      VitalWireDelay ( DLYYB1_ipd,    DLYYB1,    tipd_DLYYB1    );
      VitalWireDelay ( DLYYB2_ipd,    DLYYB2,    tipd_DLYYB2    );
      VitalWireDelay ( DLYYB3_ipd,    DLYYB3,    tipd_DLYYB3    );
      VitalWireDelay ( DLYYB4_ipd,    DLYYB4,    tipd_DLYYB4    );
      VitalWireDelay ( DLYGLB0_ipd,   DLYGLB0,   tipd_DLYGLB0   );
      VitalWireDelay ( DLYGLB1_ipd,   DLYGLB1,   tipd_DLYGLB1   );
      VitalWireDelay ( DLYGLB2_ipd,   DLYGLB2,   tipd_DLYGLB2   );
      VitalWireDelay ( DLYGLB3_ipd,   DLYGLB3,   tipd_DLYGLB3   );
      VitalWireDelay ( DLYGLB4_ipd,   DLYGLB4,   tipd_DLYGLB4   );
      VitalWireDelay ( OCDIVRST_ipd,  OCDIVRST,  tipd_OCDIVRST  );
      VitalWireDelay ( OCDIVHALF_ipd, OCDIVHALF, tipd_OCDIVHALF );
      VitalWireDelay ( OCDIV0_ipd,    OCDIV0,    tipd_OCDIV0    );
      VitalWireDelay ( OCDIV1_ipd,    OCDIV1,    tipd_OCDIV1    );
      VitalWireDelay ( OCDIV2_ipd,    OCDIV2,    tipd_OCDIV2    );
      VitalWireDelay ( OCDIV3_ipd,    OCDIV3,    tipd_OCDIV3    );
      VitalWireDelay ( OCDIV4_ipd,    OCDIV4,    tipd_OCDIV4    );
      VitalWireDelay ( OCMUX0_ipd,    OCMUX0,    tipd_OCMUX0    );
      VitalWireDelay ( OCMUX1_ipd,    OCMUX1,    tipd_OCMUX1    );
      VitalWireDelay ( OCMUX2_ipd,    OCMUX2,    tipd_OCMUX2    );
      VitalWireDelay ( DLYYC0_ipd,    DLYYC0,    tipd_DLYYC0    );
      VitalWireDelay ( DLYYC1_ipd,    DLYYC1,    tipd_DLYYC1    );
      VitalWireDelay ( DLYYC2_ipd,    DLYYC2,    tipd_DLYYC2    );
      VitalWireDelay ( DLYYC3_ipd,    DLYYC3,    tipd_DLYYC3    );
      VitalWireDelay ( DLYYC4_ipd,    DLYYC4,    tipd_DLYYC4    );
      VitalWireDelay ( DLYGLC0_ipd,   DLYGLC0,   tipd_DLYGLC0   );
      VitalWireDelay ( DLYGLC1_ipd,   DLYGLC1,   tipd_DLYGLC1   );
      VitalWireDelay ( DLYGLC2_ipd,   DLYGLC2,   tipd_DLYGLC2   );
      VitalWireDelay ( DLYGLC3_ipd,   DLYGLC3,   tipd_DLYGLC3   );
      VitalWireDelay ( DLYGLC4_ipd,   DLYGLC4,   tipd_DLYGLC4   );
      VitalWireDelay ( FINDIV0_ipd,   FINDIV0,   tipd_FINDIV0   );
      VitalWireDelay ( FINDIV1_ipd,   FINDIV1,   tipd_FINDIV1   );
      VitalWireDelay ( FINDIV2_ipd,   FINDIV2,   tipd_FINDIV2   );
      VitalWireDelay ( FINDIV3_ipd,   FINDIV3,   tipd_FINDIV3   );
      VitalWireDelay ( FINDIV4_ipd,   FINDIV4,   tipd_FINDIV4   );
      VitalWireDelay ( FINDIV5_ipd,   FINDIV5,   tipd_FINDIV5   );
      VitalWireDelay ( FINDIV6_ipd,   FINDIV6,   tipd_FINDIV6   );
      VitalWireDelay ( FBDIV0_ipd,    FBDIV0,    tipd_FBDIV0    );
      VitalWireDelay ( FBDIV1_ipd,    FBDIV1,    tipd_FBDIV1    );
      VitalWireDelay ( FBDIV2_ipd,    FBDIV2,    tipd_FBDIV2    );
      VitalWireDelay ( FBDIV3_ipd,    FBDIV3,    tipd_FBDIV3    );
      VitalWireDelay ( FBDIV4_ipd,    FBDIV4,    tipd_FBDIV4    );
      VitalWireDelay ( FBDIV5_ipd,    FBDIV5,    tipd_FBDIV5    );
      VitalWireDelay ( FBDIV6_ipd,    FBDIV6,    tipd_FBDIV6    );
      VitalWireDelay ( FBDLY0_ipd,    FBDLY0,    tipd_FBDLY0    );
      VitalWireDelay ( FBDLY1_ipd,    FBDLY1,    tipd_FBDLY1    );
      VitalWireDelay ( FBDLY2_ipd,    FBDLY2,    tipd_FBDLY2    );
      VitalWireDelay ( FBDLY3_ipd,    FBDLY3,    tipd_FBDLY3    );
      VitalWireDelay ( FBDLY4_ipd,    FBDLY4,    tipd_FBDLY4    );
      VitalWireDelay ( FBSEL0_ipd,    FBSEL0,    tipd_FBSEL0    );
      VitalWireDelay ( FBSEL1_ipd,    FBSEL1,    tipd_FBSEL1    );
      VitalWireDelay ( XDLYSEL_ipd,   XDLYSEL,   tipd_XDLYSEL   );
      VitalWireDelay ( VCOSEL0_ipd,   VCOSEL0,   tipd_VCOSEL0   );
      VitalWireDelay ( VCOSEL1_ipd,   VCOSEL1,   tipd_VCOSEL1   );
      VitalWireDelay ( VCOSEL2_ipd,   VCOSEL2,   tipd_VCOSEL2   );
 
    end block WireDelay;

    -- #########################################################
    -- # Behavior Section
    -- #########################################################

    OAMUX_config <= ulogic2int( OAMUX2_ipd & OAMUX1_ipd & OAMUX0_ipd );
    OBMUX_config <= ulogic2int( OBMUX2_ipd & OBMUX1_ipd & OBMUX0_ipd );
    OCMUX_config <= ulogic2int( OCMUX2_ipd & OCMUX1_ipd & OCMUX0_ipd );
    FBSEL <= TO_X01( FBSEL1_ipd & FBSEL0_ipd );

    CLKA_2_GLA_dly         <= CLKA_TO_REF_DELAY + IN_DIV_DELAY + fin_period - normalized_fb_delay + gla_muxed_delay + OUT_DIV_DELAY + BYP_MUX_DELAY + GLADELAY + GL_DRVR_DELAY;
    CLKA_2_GLA_bypass0_dly <= BYP0_CLK_GL + GLADELAY;
    CLKA_2_GLA_bypass1_dly <= gla_muxed_delay + OUT_DIV_DELAY + BYP_MUX_DELAY + GLADELAY + GL_DRVR_DELAY;

    CLKA_2_GLB_dly         <= CLKA_TO_REF_DELAY + IN_DIV_DELAY + fin_period - normalized_fb_delay + glb_muxed_delay + OUT_DIV_DELAY + BYP_MUX_DELAY + GLBDELAY + GL_DRVR_DELAY;
    CLKB_2_GLB_bypass0_dly <= BYP0_CLK_GL + GLBDELAY;
    CLKB_2_GLB_bypass1_dly <= glb_muxed_delay + OUT_DIV_DELAY + BYP_MUX_DELAY + GLBDELAY + GL_DRVR_DELAY;
    CLKA_2_YB_dly          <= CLKA_TO_REF_DELAY + IN_DIV_DELAY + fin_period - normalized_fb_delay + glb_muxed_delay + OUT_DIV_DELAY + YBDELAY + Y_DRVR_DELAY;
    CLKB_2_YB_bypass1_dly  <= glb_muxed_delay + OUT_DIV_DELAY + YBDELAY + Y_DRVR_DELAY;

    CLKA_2_GLC_dly         <= CLKA_TO_REF_DELAY + IN_DIV_DELAY + fin_period - normalized_fb_delay + glc_muxed_delay + OUT_DIV_DELAY + BYP_MUX_DELAY + GLCDELAY + GL_DRVR_DELAY;
    CLKC_2_GLC_bypass0_dly <= BYP0_CLK_GL + GLCDELAY;
    CLKC_2_GLC_bypass1_dly <= glc_muxed_delay + OUT_DIV_DELAY + BYP_MUX_DELAY + GLCDELAY + GL_DRVR_DELAY;
    CLKA_2_YC_dly          <= CLKA_TO_REF_DELAY + IN_DIV_DELAY + fin_period - normalized_fb_delay + glc_muxed_delay + OUT_DIV_DELAY + YCDELAY + Y_DRVR_DELAY;
    CLKC_2_YC_bypass1_dly  <= glc_muxed_delay + OUT_DIV_DELAY + YCDELAY + Y_DRVR_DELAY;

    CLKA_2_LOCK_dly        <= CLKA_TO_REF_DELAY + IN_DIV_DELAY + fin_period - normalized_fb_delay + LOCK_OUT_DELAY;

    delay_LOCK: process( locked )
    begin
       if ( '1' = locked ) then
          LOCK <= transport locked after CLKA_2_LOCK_dly;
       else
          LOCK <= locked;
       end if;
    end process delay_LOCK;

    Deskew : process ( XDLYSEL_ipd )
      variable DelayVal             : Time := 0.000 ns;
    begin
      if (XDLYSEL_ipd = '1') then
        DelayVal := EMULATED_SYSTEM_DELAY;
      else
        DelayVal := 0.0 ns;
      end if;
      DTDELAY <= DelayVal;
    end process Deskew;

    GetFBDelay : process ( FBDLY0_ipd, FBDLY1_ipd, FBDLY2_ipd, FBDLY3_ipd, FBDLY4_ipd )
      variable step : integer;
    begin
      step := ulogic2int( FBDLY4_ipd & FBDLY3_ipd & FBDLY2_ipd & FBDLY1_ipd & FBDLY0_ipd );
      FBDELAY <= ( step * PROG_STEP_INCREMENT ) + PROG_INIT_DELAY;
    end process GetFBDelay;

    GetGLBDelay : process ( DLYGLB0_ipd, DLYGLB1_ipd, DLYGLB2_ipd, DLYGLB3_ipd, DLYGLB4_ipd )
      variable step : integer;
    begin
      step := ulogic2int( DLYGLB4_ipd & DLYGLB3_ipd & DLYGLB2_ipd & DLYGLB1_ipd & DLYGLB0_ipd );
      if ( step = 0 ) then
        GLBDELAY <= 0.0 ns;
      else
        GLBDELAY <= ( step * PROG_STEP_INCREMENT ) + PROG_INIT_DELAY;
      end if;
    end process GetGLBDelay;

    GetYBDelay : process ( DLYYB0_ipd, DLYYB1_ipd, DLYYB2_ipd, DLYYB3_ipd, DLYYB4_ipd )
      variable step : integer;
    begin
      step := ulogic2int( DLYYB4_ipd & DLYYB3_ipd & DLYYB2_ipd & DLYYB1_ipd & DLYYB0_ipd );
      YBDELAY <= ( step * PROG_STEP_INCREMENT ) + PROG_INIT_DELAY;
    end process GetYBDelay;

    GetGLCDelay : process ( DLYGLC0_ipd, DLYGLC1_ipd, DLYGLC2_ipd, DLYGLC3_ipd, DLYGLC4_ipd )
      variable step : integer;
    begin
      step := ulogic2int( DLYGLC4_ipd & DLYGLC3_ipd & DLYGLC2_ipd & DLYGLC1_ipd & DLYGLC0_ipd );
      if ( step = 0 ) then
        GLCDELAY <= 0.0 ns;
      else
        GLCDELAY <= ( step * PROG_STEP_INCREMENT ) + PROG_INIT_DELAY;
      end if;
    end process GetGLCDelay;

    GetYCDelay : process ( DLYYC0_ipd, DLYYC1_ipd, DLYYC2_ipd, DLYYC3_ipd, DLYYC4_ipd )
      variable step : integer;
    begin
      step := ulogic2int( DLYYC4_ipd & DLYYC3_ipd & DLYYC2_ipd & DLYYC1_ipd & DLYYC0_ipd );
      YCDELAY <= ( step * PROG_STEP_INCREMENT ) + PROG_INIT_DELAY;
    end process GetYCDelay;

    GetGLADelay : process ( DLYGLA0_ipd, DLYGLA1_ipd, DLYGLA2_ipd, DLYGLA3_ipd, DLYGLA4_ipd )
      variable step : integer;
    begin
      step := ulogic2int( DLYGLA4_ipd & DLYGLA3_ipd & DLYGLA2_ipd & DLYGLA1_ipd & DLYGLA0_ipd );
      if ( step = 0 ) then
        GLADELAY <= 0.0 ns;
      else
        GLADELAY <= ( step * PROG_STEP_INCREMENT ) + PROG_INIT_DELAY;
      end if;
    end process GetGLADelay;

    DIVM <= ulogic2int( FBDIV6_ipd & FBDIV5_ipd & FBDIV4_ipd & FBDIV3_ipd & 
                        FBDIV2_ipd & FBDIV1_ipd & FBDIV0_ipd ) + 1;

    DIVN <= ulogic2int( FINDIV6_ipd & FINDIV5_ipd & FINDIV4_ipd & FINDIV3_ipd & 
                        FINDIV2_ipd & FINDIV1_ipd & FINDIV0_ipd ) + 1;

    DIVU <= ulogic2int( OADIV4_ipd & OADIV3_ipd & OADIV2_ipd & OADIV1_ipd & OADIV0_ipd ) + 1;

    DIVV <= ulogic2int( OBDIV4_ipd & OBDIV3_ipd & OBDIV2_ipd & OBDIV1_ipd & OBDIV0_ipd ) + 1;

    DIVW <= ulogic2int( OCDIV4_ipd & OCDIV3_ipd & OCDIV2_ipd & OCDIV1_ipd & OCDIV0_ipd ) + 1;

    check_OADIVHALF : process
    begin
       wait on OADIVHALF_ipd, DIVU, OAMUX_config;
       if ( '1' = TO_X01( OADIVHALF_ipd ) ) then
         if ( 1 /= OAMUX_config ) then
            assert false
               report "Illegal configuration.  OADIVHALF can only be used when OAMUX = 001. OADIVHALF ignored."
               severity warning;
            halveA <= '0';
         elsif ( ( DIVU < 3 ) or ( DIVU > 29 ) or ( ( DIVU mod 2 ) /= 1 ) ) then
            assert false
               report "Illegal configuration. Only even OADIV values from 2 to 28 (inclusive) are allowed with OADIVHALF."
               severity warning;
            halveA <= 'X';
         else
            halveA <= '1';
         end if;
       elsif ( OADIVHALF_ipd'event and ( 'X' = TO_X01( OADIVHALF_ipd ) ) ) then
          assert false
             report "OADIVHALF unknown."
             severity warning;
          halveA <= 'X';
       else
          halveA <= '0';
       end if;
    end process check_OADIVHALF;

    check_OBDIVHALF : process
    begin
       wait on OBDIVHALF_ipd, DIVV, OBMUX_config;
       if ( '1' = TO_X01( OBDIVHALF_ipd ) ) then
         if ( 1 /= OBMUX_config ) then
            assert false
               report "Illegal configuration.  OBDIVHALF can only be used when OBMUX = 001. OBDIVHALF ignored."
               severity warning;
            halveB <= '0';
         elsif ( ( DIVV < 3 ) or ( DIVV > 29 ) or ( ( DIVV mod 2 ) /= 1 ) ) then
            assert false
               report "Illegal configuration. Only even OBDIV values from 2 to 28 (inclusive) are allowed with OBDIVHALF."
               severity warning;
            halveB <= 'X';
         else
            halveB <= '1';
         end if;
       elsif ( OBDIVHALF_ipd'event and ( 'X' = TO_X01( OBDIVHALF_ipd ) ) ) then
          assert false
             report "OBDIVHALF unknown."
             severity warning;
          halveB <= 'X';
       else
          halveB <= '0';
       end if;
    end process check_OBDIVHALF;

    check_OCDIVHALF : process
    begin
       wait on OCDIVHALF_ipd, DIVW, OCMUX_config;
       if ( '1' = TO_X01( OCDIVHALF_ipd ) ) then
         if ( 1 /= OCMUX_config ) then
            assert false
               report "Illegal configuration.  OCDIVHALF can only be used when OCMUX = 001. OCDIVHALF ignored."
               severity warning;
            halveC <= '0';
         elsif ( ( DIVW < 3 ) or ( DIVW > 29 ) or ( ( DIVW mod 2 ) /= 1 ) ) then
            assert false
               report "Illegal configuration. Only even OCDIV values from 2 to 28 (inclusive) are allowed with OCDIVHALF."
               severity warning;
            halveC <= 'X';
         else
            halveC <= '1';
         end if;
       elsif ( OCDIVHALF_ipd'event and ( 'X' = TO_X01( OCDIVHALF_ipd ) ) ) then
          assert false
             report "OCDIVHALF unknown."
             severity warning;
          halveC <= 'X';
       else
          halveC <= '0';
       end if;
    end process check_OCDIVHALF;

    gla_muxed_delay <= output_mux_delay( OAMUX_config, VCOSEL2_ipd, VCOSEL1_ipd, FBDELAY, PLLCLK_pw );
    glb_muxed_delay <= output_mux_delay( OBMUX_config, VCOSEL2_ipd, VCOSEL1_ipd, FBDELAY, PLLCLK_pw );
    glc_muxed_delay <= output_mux_delay( OCMUX_config, VCOSEL2_ipd, VCOSEL1_ipd, FBDELAY, PLLCLK_pw );

    get_internal_fb_dly : process( FBSEL, FBDELAY, DTDELAY, fin_period )
       variable fb_delay : time;
    begin
       fb_delay := IN_DIV_DELAY + X_MUX_DELAY + DTDELAY + FB_MUX_DELAY;
       if ( "10" = FBSEL ) then
         fb_delay := fb_delay + FBDELAY;
       end if;
       internal_fb_delay <= fb_delay;
    end process get_internal_fb_dly;

    external_fb_delay <= IN_DIV_DELAY + X_MUX_DELAY + DTDELAY + FB_MUX_DELAY + GL_DRVR_DELAY + GLADELAY + BYP_MUX_DELAY + OUT_DIV_DELAY + gla_muxed_delay + GLA_EXTFB_rise_dly;

    normalize_fb_dly : process( using_EXTFB, internal_fb_delay, external_fb_delay, fin_period )
       variable norm : time;
    begin
       if ( using_EXTFB = '1' ) then
          norm := external_fb_delay;
       else
          norm := internal_fb_delay;
       end if;
       if ( 0 ns >= fin_period ) then
          norm := 0 ns;
       else
         while ( norm > fin_period ) loop
            norm := norm - fin_period;
         end loop;
       end if;
       normalized_fb_delay <= norm;
    end process normalize_fb_dly;

    check_FBSEL : process
    begin
      wait on FBSEL, OAMUX_config, OBMUX_config, OCMUX_config, DIVM, DIVU, DIVN, CLKA_period_stable, PLLCLK_period, external_fb_delay;
      if ( IS_X( FBSEL ) ) then
         FBSEL_illegal <= true;
         assert ( not FBSEL'event )
            report "Warning: FBSEL is unknown." 
            severity Warning;
      elsif ( "00" = FBSEL ) then -- Grounded.
         FBSEL_illegal <= true;
         assert ( not FBSEL'event )
            report "Warning: Illegal FBSEL configuration 00." 
            severity Warning;
      elsif ( "11" = FBSEL ) then -- External feedback
         if ( 2 > OAMUX_config ) then
            FBSEL_illegal <= true;
            assert  ( not ( FBSEL'event or OAMUX_config'event ) )
               report "Illegal configuration. GLA cannot be in bypass mode (OAMUX = 000 or OAMUX = 001) when using external feedback (FBSEL = 11)." 
               severity Warning;
         elsif ( DIVM < 5 ) then
            FBSEL_illegal <= true;
            assert ( not ( FBSEL'event or DIVM'event ) )
               report "Error: FBDIV must be greater than 4 when using external feedback (FBSEL = 11)."
               severity Error;
         elsif ( ( DIVM * DIVU ) > 232 ) then
            FBSEL_illegal <= true;
            assert ( not ( FBSEL'event or DIVM'event or DIVU'event ) )
               report "Error: Product of FBDIV and OADIV must be less than 233 when using external feedback (FBSEL = 11)."
               severity Error;
         elsif ( ( DIVN mod DIVU ) /= 0 ) then
            FBSEL_illegal <= true;
            assert ( not ( FBSEL'event or DIVN'event or DIVU'event ) )
               report "Error: Division factor FINDIV must be a multiple of OADIV when using external feedback (FBSEL = 11)."
               severity Error;
         elsif ( CLKA_period_stable and EXTFB_delay_dtrmd and
                 ( ( 1 < OBMUX_config ) or ( 1 < OCMUX_config ) ) and
                 ( ( external_fb_delay >= CLKA_period ) or ( external_fb_delay >= PLLCLK_period ) ) ) then
            FBSEL_illegal <= true;
            assert ( not ( FBSEL'event or CLKA_period_stable'event or external_fb_delay'event or PLLCLK_period'event ) )
              report "Error: Total sum of delays in the feedback path must be less than 1 VCO period AND less than 1 CLKA period when V and/or W dividers when using external feedback (FBSEL = 11)."
               severity Error;
         else
            FBSEL_illegal <= false;
         end if;
      else
         FBSEL_illegal <= false;
      end if;
    end process check_FBSEL;

    -- Mimicing silicon - no need for a 50/50 duty cycle and this way fin only changes on rising edge of CLKA (except when DIVN is 1)
    gen_fin: process
      variable num_CLKA_re   : integer;
    begin
       wait until rising_edge( CLKA_ipd );
       fin <= '1';
       num_CLKA_re := 0;
       while ( 'X' /= TO_X01( CLKA_ipd ) ) loop
          wait on CLKA_ipd;
          if ( 1 = DIVN )then
             fin <= CLKA_ipd;
          elsif ( '1' = CLKA_ipd ) then
             num_CLKA_re := num_CLKA_re + 1;
             if ( ( num_CLKA_re mod DIVN  ) = 0 ) then
                fin <= '1';
                num_CLKA_re := 0;
             elsif ( ( num_CLKA_re mod DIVN ) = 1 ) then
                fin <= '0';
             end if;
          end if;
       end loop;
    end process gen_fin;

    GetCLKAPeriod : process ( CLKA_ipd, POWERDOWN_ipd, FBSEL_illegal, normalized_fb_delay, DIVN, DIVM, locked_vco0_edges, external_dly_correct )
      -- locked_vco0_edges is in the sensitivity list so that we periodically check for CLKA stopped
      variable re                 : Time :=  0.000 ns; -- Current CLKA rising edge
      variable CLKA_num_re_stable : Integer := -1;   -- Number of CLKA rising edges that PLL config stable
    begin
      if (( TO_X01( POWERDOWN_ipd ) = '1' ) and ( FBSEL_illegal = False ))  then
        if ( normalized_fb_delay'event or DIVN'event or DIVM'event or
             ( ( '1' = using_EXTFB ) and ( '1' /= external_dly_correct ) ) ) then
          internal_lock <= false;
          CLKA_num_re_stable := -1;
        end if;
        if ( CLKA_ipd'event and ( '1' = TO_X01( CLKA_ipd ) ) ) then
           if ( CLKA_period /= ( NOW - re ) ) then
              CLKA_period <= ( NOW - re );
              CLKA_num_re_stable := -1;
              internal_lock <= false;
              CLKA_period_stable <= false;
           else
              if ( f_CLKA_LOCK > CLKA_num_re_stable ) then
                 CLKA_num_re_stable := CLKA_num_re_stable + 1;
              elsif ( f_CLKA_LOCK = CLKA_num_re_stable ) then
                 internal_lock <=  true;
              end if;
              CLKA_period_stable <= true;
           end if;
           re := NOW;
        elsif ( CLKA_period < ( NOW - re ) ) then
           CLKA_num_re_stable := -1;
           internal_lock <= false;
           CLKA_period_stable <= false;
        end if;
      else
        CLKA_num_re_stable := -1;
        internal_lock <= false;
        CLKA_period_stable <= false;
      end if;
    end process GetCLKAPeriod;

    fin_period         <= CLKA_period * DIVN;

    GLA_pw             <= PLLCLK_pw * DIVU;

    extfbin_fin_drift  <= ( GLA_pw * DIVM * 2.0 ) - fin_period;

    PLLCLK_period      <= fin_period / real( fb_loop_div );

    PLLCLK_pw          <= PLLCLK_period / 2.0;

    calc_fb_loop_div : process( DIVM, DIVU, using_EXTFB )
    begin
       if ( using_EXTFB  = '1' ) then
           fb_loop_div <= DIVM * DIVU; 
       else
           fb_loop_div <= DIVM;
       end if;
    end process calc_fb_loop_div;

    sync_pll : process( fin, internal_lock, DYNSYNC )
    begin
       if ( not( internal_lock ) or ( '1' = DYNSYNC ) ) then
          locked <= '0';
       elsif ( rising_edge( fin ) ) then
          locked <= '1';
       end if;
    end process sync_pll;

    count_locked_vco0_edges: process( locked, locked_vco0_edges )
    begin
       if ( locked'event ) then
          if ( locked = '1' ) then
            locked_vco0_edges <= 0;
          else
            locked_vco0_edges <= -1;
          end if;
       elsif ( locked = '1' ) then
          if ( ( locked_vco0_edges mod( DIVU * DIVV * DIVW * DIVM * 2 ) ) = 0 ) then
             locked_vco0_edges <= 1 after PLLCLK_pw;
          else
             locked_vco0_edges <= ( locked_vco0_edges + 1 ) after PLLCLK_pw;
          end if;
       end if;
    end process count_locked_vco0_edges;

    gen_vco0_div: process( locked_vco0_edges )
    begin
       if ( locked_vco0_edges = -1 ) then
          vco0_divu <= '0';
          vco0_divv <= '0';
          vco0_divw <= '0';
       else 
         if ( ( locked_vco0_edges mod DIVU ) = 0 ) then
           vco0_divu <= not vco0_divu;
         end if;
         if ( ( locked_vco0_edges mod DIVV ) = 0 ) then
           vco0_divv <= not vco0_divv;
         end if;
         if ( ( locked_vco0_edges mod DIVW ) = 0 ) then
           vco0_divw <= not vco0_divw;
         end if;
       end if;
    end process gen_vco0_div;

    UIN <= output_mux_driver(  OAMUX_config, halveA, CLKA_ipd, CLKA2X, vco0_divu );
    VIN <= output_mux_driver(  OBMUX_config, halveB, CLKB_ipd, CLKB2X, vco0_divv );
    WIN <= output_mux_driver(  OCMUX_config, halveC, CLKC_ipd, CLKC2X, vco0_divw );

    double_CLKA: process( CLKA_ipd )
       variable re      : Time := 0 ns;
       variable prev_re : Time := 0 ns;
       variable period  : Time := 0 ns;
    begin
       if ( TO_X01( CLKA_ipd ) = '1' ) then
         prev_re := re;
         re := NOW;
         period := re - prev_re;
         if ( period > 0 ns ) then
            CLKA2X <= '1';
            CLKA2X <= transport '0' after ( period / 4.0 );
            CLKA2X <= transport '1' after ( period / 2.0 );
            CLKA2X <= transport '0' after ( period * 3.0 / 4.0 );
         end if;
       end if;
    end process double_CLKA;

    double_CLKB: process( CLKB_ipd )
       variable re      : Time := 0 ns;
       variable prev_re : Time := 0 ns;
       variable period  : Time := 0 ns;
    begin
       if ( TO_X01( CLKB_ipd ) = '1' ) then
         prev_re := re;
         re := NOW;
         period := re - prev_re;
         if ( period > 0 ns ) then
            CLKB2X <= '1';
            CLKB2X <= transport '0' after ( period / 4.0 );
            CLKB2X <= transport '1' after ( period / 2.0 );
            CLKB2X <= transport '0' after ( period * 3.0 / 4.0 );
         end if;
       end if;
    end process double_CLKB;

    double_CLKC: process( CLKC_ipd )
       variable re      : Time := 0 ns;
       variable prev_re : Time := 0 ns;
       variable period  : Time := 0 ns;
    begin
       if ( TO_X01( CLKC_ipd ) = '1' ) then
         prev_re := re;
         re := NOW;
         period := re - prev_re;
         if ( period > 0 ns ) then
            CLKC2X <= '1';
            CLKC2X <= transport '0' after ( period / 4.0 );
            CLKC2X <= transport '1' after ( period / 2.0 );
            CLKC2X <= transport '0' after ( period * 3.0 / 4.0 );
         end if;
       end if;
    end process double_CLKC;

    --
    -- AOUT Output of Divider U
    --

    DividerU : process ( UIN, CLKA_ipd, OADIVRST_ipd, OADIVHALF_ipd, 
                         POWERDOWN_ipd )

      variable force_0         : Boolean  := True;
      variable num_edges       : Integer  := -1;
      variable res_post_reset1 : Integer  :=  0;
      variable fes_post_reset1 : Integer  :=  0;
      variable res_post_reset0 : Integer  :=  0;
      variable fes_post_reset0 : Integer  :=  0;

    begin

      if ( 1 = OAMUX_config ) then -- PLL core bypassed.  OADIVRST active.

        if ( CLKA_ipd'event ) then
          if ( TO_X01( CLKA_ipd ) = '1' and TO_X01( CLKA_ipd'last_value ) = '0' ) then
             if ( 4 > res_post_reset1 ) then
                res_post_reset1 := res_post_reset1 + 1;
             end if;
             if ( 4 > res_post_reset0 ) then
               res_post_reset0 := res_post_reset0 + 1;
             end if;
             if ( res_post_reset1 = 3 ) then
                force_0 := False;
                num_edges := -1;
             end if;
          elsif ( TO_X01( CLKA_ipd ) = '0' and TO_X01( CLKA_ipd'last_value ) = '1' ) then
             if ( 4 > fes_post_reset1 ) then
               fes_post_reset1 := fes_post_reset1 + 1;
             end if;
             if ( 4 > fes_post_reset0 ) then
               fes_post_reset0 := fes_post_reset0 + 1;
             end if;
             if ( fes_post_reset1 = 1 ) then
                force_0 := True;
             end if;
          end if;
        end if;

        if ( OADIVRST_ipd'event ) then
          if ( TO_X01( OADIVRST_ipd ) = '1' ) then
            if ( ( TO_X01( OADIVRST_ipd'last_value ) = '0' ) and
                 ( ( res_post_reset0 < 1 ) or ( fes_post_reset0 < 1 ) ) ) then
              assert false
              report "OADIVRST must be held low for at least one CLKA period for the reset operation to work correctly: reset operation may not be successful, edge alignment unpredictable"
              severity warning;
            end if;
            res_post_reset1 := 0;
            fes_post_reset1 := 0;
          elsif ( TO_X01( OADIVRST_ipd ) = '0' ) then
            if ( ( TO_X01( OADIVRST_ipd'last_value ) = '1' ) and
                 ( ( res_post_reset1 < 3 ) or ( fes_post_reset1 < 3 ) ) ) then
              assert false
              report "OADIVRST must be held high for at least three CLKA periods for the reset operation to work correctly: reset operation may not be succesful, edge alignment unpredictable"
              severity warning;
            end if;
            res_post_reset0 := 0;
            fes_post_reset0 := 0;
          else
            assert false
            report "OADIVRST is unknown. Edge alignment unpredictable."
            severity warning;
          end if;
        end if;

        if ( UIN'event ) then
          num_edges := num_edges + 1;
          if ( force_0 ) then
            AOUT <= '0';
          elsif ( TO_X01( UIN ) = 'X' ) then
            AOUT <= 'X';
          elsif ( ( num_edges mod DIVU ) = 0 ) then
            num_edges := 0;
            if ( TO_X01 ( AOUT ) = 'X' ) then
              AOUT <= UIN;
            else
              AOUT <= not AOUT;
            end if;
          end if;
        end if;

      else -- PLL not bypassed
        if ( TO_X01 ( POWERDOWN_ipd ) = '0' ) then
          AOUT <= '0';
        elsif ( TO_X01 ( POWERDOWN_ipd ) = '1' ) then
          AOUT <= UIN;
        else -- POWERDOWN unknown
          AOUT <= 'X';
        end if;
      end if;

    end process DividerU;


    --
    -- BOUT Output of Divider V
    --

    DividerV : process ( VIN, CLKB_ipd, OBDIVRST_ipd, OBDIVHALF_ipd,
                         POWERDOWN_ipd )

      variable force_0         : Boolean  := True;
      variable num_edges       : Integer  := -1;
      variable res_post_reset1 : Integer  :=  0;
      variable fes_post_reset1 : Integer  :=  0;
      variable res_post_reset0 : Integer  :=  0;
      variable fes_post_reset0 : Integer  :=  0;

    begin

      if ( 0 = OBMUX_config ) then
        BOUT <= 'X';
      elsif ( 1 = OBMUX_config ) then -- PLL core bypassed.  OBDIVRST active.

        if ( CLKB_ipd'event ) then
          if ( TO_X01( CLKB_ipd ) = '1' and TO_X01( CLKB_ipd'last_value ) = '0' ) then
             if ( 4 > res_post_reset1 ) then
               res_post_reset1 := res_post_reset1 + 1;
             end if;
             if ( 4 > res_post_reset0 ) then
               res_post_reset0 := res_post_reset0 + 1;
             end if;
             if ( res_post_reset1 = 3 ) then
                force_0 := False;
                num_edges := -1;
             end if;
          elsif ( TO_X01( CLKB_ipd ) = '0' and TO_X01( CLKB_ipd'last_value ) = '1' ) then
             if ( 4 > fes_post_reset1 ) then
               fes_post_reset1 := fes_post_reset1 + 1;
             end if;
             if ( 4 > fes_post_reset0 ) then
               fes_post_reset0 := fes_post_reset0 + 1;
             end if;
             if ( fes_post_reset1 = 1 ) then
                force_0 := True;
             end if;
          end if;
        end if;

        if ( OBDIVRST_ipd'event ) then
          if ( TO_X01( OBDIVRST_ipd ) = '1' ) then
            if ( ( TO_X01( OBDIVRST_ipd'last_value ) = '0' ) and
                 ( ( res_post_reset0 < 1 ) or ( fes_post_reset0 < 1 ) ) ) then
              assert false
              report "OBDIVRST must be held low for at least one CLKB period for the reset operation to work correctly: reset operation may not be successful, edge alignment unpredictable"
              severity warning;
            end if;
            res_post_reset1 := 0;
            fes_post_reset1 := 0;
          elsif ( TO_X01( OBDIVRST_ipd ) = '0' ) then
            if ( ( TO_X01( OBDIVRST_ipd'last_value ) = '1' ) and
                 ( ( res_post_reset1 < 3 ) or ( fes_post_reset1 < 3 ) ) ) then
              assert false
              report "OBDIVRST must be held high for at least three CLKB periods for the reset operation to work correctly: reset operation may not be succesful, edge alignment unpredictable"
              severity warning;
            end if;
            res_post_reset0 := 0;
            fes_post_reset0 := 0;
          else
            assert false
            report "OBDIVRST is unknown. Edge alignment unpredictable."
            severity warning;
          end if;
        end if;

        if ( VIN'event ) then
          num_edges := num_edges + 1;
          if ( force_0 ) then
            BOUT <= '0';
          elsif ( TO_X01( VIN ) = 'X' ) then
            BOUT <= 'X';
          elsif ( ( num_edges mod DIVV ) = 0 ) then
            num_edges := 0;
            if ( TO_X01 ( BOUT ) = 'X' ) then
              BOUT <= VIN;
            else
              BOUT <= not BOUT;
            end if;
          end if;
        end if;

      else -- PLL not bypassed
        if ( TO_X01 ( POWERDOWN_ipd ) = '0' ) then
          BOUT <= '0';
        elsif ( TO_X01 ( POWERDOWN_ipd ) = '1' ) then
          BOUT <= VIN;
        else -- POWERDOWN unknown
          BOUT <= 'X';
        end if;
      end if;

    end process DividerV;

    --
    -- COUT Output of Divider W
    --

    DividerW : process ( WIN, CLKC_ipd, OCDIVRST_ipd, OCDIVHALF_ipd,
                         POWERDOWN_ipd )

      variable force_0         : Boolean  := True;
      variable num_edges       : Integer  := -1;
      variable res_post_reset1 : Integer  :=  0;
      variable fes_post_reset1 : Integer  :=  0;
      variable res_post_reset0 : Integer  :=  0;
      variable fes_post_reset0 : Integer  :=  0;

    begin

      if ( 0 = OCMUX_config ) then
        COUT <= 'X';
      elsif ( 1 = OCMUX_config ) then -- PLL core bypassed.  OCDIVRST active.

        if ( CLKC_ipd'event ) then
          if ( TO_X01( CLKC_ipd ) = '1' and TO_X01( CLKC_ipd'last_value ) = '0' ) then
             if ( 4 > res_post_reset1 ) then
               res_post_reset1 := res_post_reset1 + 1;
             end if;
             if ( 4 > res_post_reset0 ) then
               res_post_reset0 := res_post_reset0 + 1;
             end if;
             if ( res_post_reset1 = 3 ) then
                force_0 := False;
                num_edges := -1;
             end if;
          elsif ( TO_X01( CLKC_ipd ) = '0' and TO_X01( CLKC_ipd'last_value ) = '1' ) then
             if ( 4 > fes_post_reset1 ) then
               fes_post_reset1 := fes_post_reset1 + 1;
             end if;
             if ( 4 > fes_post_reset0 ) then
               fes_post_reset0 := fes_post_reset0 + 1;
             end if;
             if ( fes_post_reset1 = 1 ) then
                force_0 := True;
             end if;
          end if;
        end if;

        if ( OCDIVRST_ipd'event ) then
          if ( TO_X01( OCDIVRST_ipd ) = '1' ) then
            if ( ( TO_X01( OCDIVRST_ipd'last_value ) = '0' ) and
                 ( ( res_post_reset0 < 1 ) or ( fes_post_reset0 < 1 ) ) ) then
              assert false
              report "OCDIVRST must be held low for at least one CLKC period for the reset operation to work correctly: reset operation may not be successful, edge alignment unpredictable"
              severity warning;
            end if;
            res_post_reset1 := 0;
            fes_post_reset1 := 0;
          elsif ( TO_X01( OCDIVRST_ipd ) = '0' ) then
            if ( ( TO_X01( OCDIVRST_ipd'last_value ) = '1' ) and
                 ( ( res_post_reset1 < 3 ) or ( fes_post_reset1 < 3 ) ) ) then
              assert false
              report "OCDIVRST must be held high for at least three CLKC periods for the reset operation to work correctly: reset operation may not be succesful, edge alignment unpredictable"
              severity warning;
            end if;
            res_post_reset0 := 0;
            fes_post_reset0 := 0;
          else
            assert false
            report "OCDIVRST is unknown. Edge alignment unpredictable."
            severity warning;
          end if;
        end if;

        if ( WIN'event ) then
          num_edges := num_edges + 1;
          if ( force_0 ) then
            COUT <= '0';
          elsif ( TO_X01( WIN ) = 'X' ) then
            COUT <= 'X';
          elsif ( ( num_edges mod DIVW ) = 0 ) then
            num_edges := 0;
            if ( TO_X01 ( COUT ) = 'X' ) then
              COUT <= WIN;
            else
              COUT <= not COUT;
            end if;
          end if;
        end if;

      else -- PLL not bypassed
        if ( TO_X01 ( POWERDOWN_ipd ) = '0' ) then
          COUT <= '0';
        elsif ( TO_X01 ( POWERDOWN_ipd ) = '1' ) then
          COUT <= WIN;
        else -- POWERDOWN unknown
          COUT <= 'X';
        end if;
      end if;

    end process DividerW;

    using_EXTFB <= TO_X01( FBSEL1_ipd and FBSEL0_ipd );

    external_dly_correct <= expected_EXTFB xnor EXTFB_ipd after 1 ps;

    get_EXTFB_period : process
      variable previous_re : time :=  0.000 ns; -- Previous EXTFB rising edge
    begin
      wait until rising_edge( EXTFB );
      EXTFB_period <= NOW - previous_re;
      previous_re := NOW;
    end process get_EXTFB_period;

    calculate_extfb_delay : process
      variable CLKA_edge : time := 0 ns;
    begin
       EXTFB_delay_dtrmd <= false;
       if ( ( '1' /= using_EXTFB ) or ( not CLKA_period_stable ) ) then
          wait until ( ( '1' = using_EXTFB ) and CLKA_period_stable );
       end if;
       wait for GLA_EXTFB_rise_dly;
       GLA_EXTFB_fall_dly <= 0 ps;
       GLA_EXTFB_rise_dly <= 0 ps;
       wait for ( CLKA_2_GLA_dly * 2);
       calibrate_EXTFB_delay <= '1';
       if ( '1' /= EXTFB_ipd ) then
          wait until ( EXTFB_ipd = '1' );
       end if;
       wait until falling_edge( CLKA_ipd );
       CLKA_edge := NOW;
       calibrate_EXTFB_delay <= '0';
       wait until falling_edge( EXTFB_ipd );
       GLA_EXTFB_fall_dly <= NOW - CLKA_edge - CLKA_2_GLA_dly;
       wait until rising_edge( CLKA_ipd );
       CLKA_edge := NOW;
       calibrate_EXTFB_delay <= '1';
       wait until rising_edge( EXTFB_ipd );
       GLA_EXTFB_rise_dly <= NOW - CLKA_edge - CLKA_2_GLA_dly;
       wait until falling_edge( CLKA_ipd );
       wait until ( CLKA_period_stable and rising_edge( fin ) );
       EXTFB_delay_dtrmd <= true;
       wait until falling_edge( expected_EXTFB );
       if ( '1' /= external_dly_correct ) then
         assert false
         report "ERROR: EXTFB must be a simple, time-delayed derivative of GLA. Simulation cannot continue until user-logic is corrected"
         severity failure;
         wait;
       end if;
       wait until ( '1' /= external_dly_correct );
    end process calculate_extfb_delay;

    external_feedback : process
       variable edges : integer := 1;
    begin
       wait on GLA_free_running, EXTFB_delay_dtrmd;
       if ( EXTFB_delay_dtrmd ) then
         if ( ( edges mod ( DIVM * 2 ) ) = 0 ) then
            GLA_free_running <= not GLA_free_running after ( GLA_pw - extfbin_fin_drift );
            edges := 0;
         else
            GLA_free_running <= not GLA_free_running after GLA_pw;
         end if;
         edges := edges + 1;
       else
         edges := 1;
         GLA_free_running <= '1' after GLA_pw;
       end if;
    end process external_feedback;

    gen_AOUT_using_EXTFB : process( AOUT, GLA_free_running, calibrate_EXTFB_delay, locked_vco0_edges, EXTFB_delay_dtrmd )
    begin
       if ( 0 <= locked_vco0_edges ) then
          AOUT_using_EXTFB <= AOUT;
       elsif ( EXTFB_delay_dtrmd ) then
          AOUT_using_EXTFB <= GLA_free_running;
       else
          AOUT_using_EXTFB <= calibrate_EXTFB_delay;
       end if;
    end process gen_AOUT_using_EXTFB;

    gen_expected_EXTFB: process( AOUT_using_EXTFB, EXTFB_delay_dtrmd )
    begin
       if ( not EXTFB_delay_dtrmd ) then
          expected_EXTFB <= 'X';
       elsif ( '1' = AOUT_using_EXTFB ) then
          expected_EXTFB <= transport AOUT_using_EXTFB after ( CLKA_2_GLA_dly + GLA_EXTFB_rise_dly );
       else
          expected_EXTFB <= transport AOUT_using_EXTFB after ( CLKA_2_GLA_dly + GLA_EXTFB_fall_dly );
       end if;
    end process gen_expected_EXTFB;

    Aoutputs: process( AOUT, CLKA_ipd, AOUT_using_EXTFB, OAMUX_config  )
    begin
        if ( 0 = OAMUX_config ) then
          GLA <= transport CLKA_ipd after CLKA_2_GLA_bypass0_dly;
        elsif ( ( 1 = OAMUX_config ) or ( 3 = OAMUX_config ) ) then
          GLA <= transport 'X' after CLKA_2_GLA_dly;
          assert ( not OAMUX_config'event )
            report "WARNING: Illegal OAMUX configuration."
            severity warning;
        elsif ( '1' = using_EXTFB ) then
          GLA <= transport AOUT_using_EXTFB after CLKA_2_GLA_dly;
        else
          GLA <= transport AOUT after CLKA_2_GLA_dly;
        end if;
    end process Aoutputs;
    
    Boutputs: process ( BOUT, CLKB_ipd, OBMUX_config )
    begin
        if ( 0 = OBMUX_config ) then
          GLB <= transport CLKB_ipd after CLKB_2_GLB_bypass0_dly;
          YB  <= 'X';
        elsif ( ( 1 = OBMUX_config ) or ( 3 = OBMUX_config ) ) then
          GLB <= transport 'X' after CLKA_2_GLB_dly;
          YB  <= transport 'X' after CLKA_2_YB_dly;
          assert ( not OBMUX_config'event )
            report "WARNING: Illegal OBMUX configuration."
            severity warning;
        else
          GLB <= transport BOUT after CLKA_2_GLB_dly;
          YB  <= transport BOUT after CLKA_2_YB_dly;
        end if;
    end process Boutputs;

    Coutputs: process ( COUT, CLKC_ipd, OCMUX_config )
    begin
        if ( 0 = OCMUX_config ) then
          GLC <= transport CLKC_ipd after CLKC_2_GLC_bypass0_dly;
          YC  <= 'X';
        elsif ( ( 1 = OCMUX_config ) or ( 3 = OCMUX_config ) ) then
          GLC <= transport 'X' after CLKA_2_GLC_dly;
          YC  <= transport 'X' after CLKA_2_YC_dly;
          assert ( not OCMUX_config'event )
            report "WARNING: Illegal OCMUX configuration."
            severity warning;
        else
          GLC <= transport COUT after CLKA_2_GLC_dly;
          YC  <= transport COUT after CLKA_2_YC_dly;
        end if;
    end process Coutputs;
    
  end VITAL_ACT;


library IEEE;
use IEEE.std_logic_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

-- entity declaration --
 entity PLL is
  generic(
    VCOFREQUENCY      :  Real    := 0.0;
    f_CLKA_LOCK       :  Integer := 3; -- Number of CLKA pulses after which LOCK is raised

    TimingChecksOn    :  Boolean          := True;
    InstancePath      :  String           := "*";
    Xon               :  Boolean          := False;
    MsgOn             :  Boolean          := True;
    
    tipd_CLKA         :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_EXTFB        :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_POWERDOWN    :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OADIV4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OAMUX0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OAMUX1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OAMUX2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA0      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA1      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA2      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA3      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLA4      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBDIV4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBMUX0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBMUX1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OBMUX2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYB4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB0      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB1      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB2      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB3      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLB4      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCDIV4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCMUX0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCMUX1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_OCMUX2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYYC4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC0      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC1      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC2      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC3      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_DLYGLC4      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV0      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV1      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV2      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV3      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV4      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV5      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FINDIV6      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV5       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDIV6       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY2       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY3       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBDLY4       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBSEL0       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_FBSEL1       :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_XDLYSEL      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_VCOSEL0      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_VCOSEL1      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );
    tipd_VCOSEL2      :  VitalDelayType01 := ( 0.000 ns, 0.000 ns );

    tpd_CLKA_GLA      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_GLA     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_GLA :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_GLB      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_GLB     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_GLB :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_GLC      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_GLC     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_GLC :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_YB       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_YB      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_YB  :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_YC       :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_EXTFB_YC      :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_POWERDOWN_YC  :  VitalDelayType01 := ( 0.100 ns, 0.100 ns );
    tpd_CLKA_LOCK     :  VitalDelayType01 := ( 0.100 ns, 0.100 ns )
   );

  port (
    CLKA         : in    std_ulogic;
    EXTFB        : in    std_ulogic;
    POWERDOWN    : in    std_ulogic;
    OADIV0       : in    std_ulogic;
    OADIV1       : in    std_ulogic;
    OADIV2       : in    std_ulogic;
    OADIV3       : in    std_ulogic;
    OADIV4       : in    std_ulogic;
    OAMUX0       : in    std_ulogic;
    OAMUX1       : in    std_ulogic;
    OAMUX2       : in    std_ulogic;
    DLYGLA0      : in    std_ulogic;
    DLYGLA1      : in    std_ulogic;
    DLYGLA2      : in    std_ulogic;
    DLYGLA3      : in    std_ulogic;
    DLYGLA4      : in    std_ulogic;
    OBDIV0       : in    std_ulogic;
    OBDIV1       : in    std_ulogic;
    OBDIV2       : in    std_ulogic;
    OBDIV3       : in    std_ulogic;
    OBDIV4       : in    std_ulogic;
    OBMUX0       : in    std_ulogic;
    OBMUX1       : in    std_ulogic;
    OBMUX2       : in    std_ulogic;
    DLYYB0       : in    std_ulogic;
    DLYYB1       : in    std_ulogic;
    DLYYB2       : in    std_ulogic;
    DLYYB3       : in    std_ulogic;
    DLYYB4       : in    std_ulogic;
    DLYGLB0      : in    std_ulogic;
    DLYGLB1      : in    std_ulogic;
    DLYGLB2      : in    std_ulogic;
    DLYGLB3      : in    std_ulogic;
    DLYGLB4      : in    std_ulogic;
    OCDIV0       : in    std_ulogic;
    OCDIV1       : in    std_ulogic;
    OCDIV2       : in    std_ulogic;
    OCDIV3       : in    std_ulogic;
    OCDIV4       : in    std_ulogic;
    OCMUX0       : in    std_ulogic;
    OCMUX1       : in    std_ulogic;
    OCMUX2       : in    std_ulogic;
    DLYYC0       : in    std_ulogic;
    DLYYC1       : in    std_ulogic;
    DLYYC2       : in    std_ulogic;
    DLYYC3       : in    std_ulogic;
    DLYYC4       : in    std_ulogic;
    DLYGLC0      : in    std_ulogic;
    DLYGLC1      : in    std_ulogic;
    DLYGLC2      : in    std_ulogic;
    DLYGLC3      : in    std_ulogic;
    DLYGLC4      : in    std_ulogic;
    FINDIV0      : in    std_ulogic;
    FINDIV1      : in    std_ulogic;
    FINDIV2      : in    std_ulogic;
    FINDIV3      : in    std_ulogic;
    FINDIV4      : in    std_ulogic;
    FINDIV5      : in    std_ulogic;
    FINDIV6      : in    std_ulogic;
    FBDIV0       : in    std_ulogic;
    FBDIV1       : in    std_ulogic;
    FBDIV2       : in    std_ulogic;
    FBDIV3       : in    std_ulogic;
    FBDIV4       : in    std_ulogic;
    FBDIV5       : in    std_ulogic;
    FBDIV6       : in    std_ulogic;
    FBDLY0       : in    std_ulogic;
    FBDlY1       : in    std_ulogic;
    FBDLY2       : in    std_ulogic;
    FBDLY3       : in    std_ulogic;
    FBDlY4       : in    std_ulogic;
    FBSEL0       : in    std_ulogic;
    FBSEL1       : in    std_ulogic;
    XDLYSEL      : in    std_ulogic;
    VCOSEL0      : in    std_ulogic;
    VCOSEL1      : in    std_ulogic;
    VCOSEL2      : in    std_ulogic;
    GLA          : out   std_ulogic;
    LOCK         : out   std_ulogic;
    GLB          : out   std_ulogic;
    YB           : out   std_ulogic;
    GLC          : out   std_ulogic;
    YC           : out   std_ulogic
   );

  attribute VITAL_LEVEL0 of PLL : entity is TRUE;
end PLL;

-- architecture body --
library IEEE;
use IEEE.VITAL_Primitives.all;
library proasic3;
use proasic3.components.all;

architecture VITAL_ACT of PLL is
attribute VITAL_LEVEL1 of VITAL_ACT : architecture is FALSE;

  signal CLKA_ipd               : std_ulogic;
  signal EXTFB_ipd              : std_ulogic;
  signal POWERDOWN_ipd          : std_ulogic;
  signal OADIV0_ipd             : std_ulogic;
  signal OADIV1_ipd             : std_ulogic;
  signal OADIV2_ipd             : std_ulogic;
  signal OADIV3_ipd             : std_ulogic;
  signal OADIV4_ipd             : std_ulogic;
  signal OAMUX0_ipd             : std_ulogic;
  signal OAMUX1_ipd             : std_ulogic;
  signal OAMUX2_ipd             : std_ulogic;
  signal DLYGLA0_ipd            : std_ulogic;
  signal DLYGLA1_ipd            : std_ulogic;
  signal DLYGLA2_ipd            : std_ulogic;
  signal DLYGLA3_ipd            : std_ulogic;
  signal DLYGLA4_ipd            : std_ulogic;
  signal OBDIV0_ipd             : std_ulogic;
  signal OBDIV1_ipd             : std_ulogic;
  signal OBDIV2_ipd             : std_ulogic;
  signal OBDIV3_ipd             : std_ulogic;
  signal OBDIV4_ipd             : std_ulogic;
  signal OBMUX0_ipd             : std_ulogic;
  signal OBMUX1_ipd             : std_ulogic;
  signal OBMUX2_ipd             : std_ulogic;
  signal DLYYB0_ipd             : std_ulogic;
  signal DLYYB1_ipd             : std_ulogic;
  signal DLYYB2_ipd             : std_ulogic;
  signal DLYYB3_ipd             : std_ulogic;
  signal DLYYB4_ipd             : std_ulogic;
  signal DLYGLB0_ipd            : std_ulogic;
  signal DLYGLB1_ipd            : std_ulogic;
  signal DLYGLB2_ipd            : std_ulogic;
  signal DLYGLB3_ipd            : std_ulogic;
  signal DLYGLB4_ipd            : std_ulogic;
  signal OCDIV0_ipd             : std_ulogic;
  signal OCDIV1_ipd             : std_ulogic;
  signal OCDIV2_ipd             : std_ulogic;
  signal OCDIV3_ipd             : std_ulogic;
  signal OCDIV4_ipd             : std_ulogic;
  signal OCMUX0_ipd             : std_ulogic;
  signal OCMUX1_ipd             : std_ulogic;
  signal OCMUX2_ipd             : std_ulogic;
  signal DLYYC0_ipd             : std_ulogic;
  signal DLYYC1_ipd             : std_ulogic;
  signal DLYYC2_ipd             : std_ulogic;
  signal DLYYC3_ipd             : std_ulogic;
  signal DLYYC4_ipd             : std_ulogic;
  signal DLYGLC0_ipd            : std_ulogic;
  signal DLYGLC1_ipd            : std_ulogic;
  signal DLYGLC2_ipd            : std_ulogic;
  signal DLYGLC3_ipd            : std_ulogic;
  signal DLYGLC4_ipd            : std_ulogic;
  signal FINDIV0_ipd            : std_ulogic;
  signal FINDIV1_ipd            : std_ulogic;
  signal FINDIV2_ipd            : std_ulogic;
  signal FINDIV3_ipd            : std_ulogic;
  signal FINDIV4_ipd            : std_ulogic;
  signal FINDIV5_ipd            : std_ulogic;
  signal FINDIV6_ipd            : std_ulogic;
  signal FBDIV0_ipd             : std_ulogic;
  signal FBDIV1_ipd             : std_ulogic;
  signal FBDIV2_ipd             : std_ulogic;
  signal FBDIV3_ipd             : std_ulogic;
  signal FBDIV4_ipd             : std_ulogic;
  signal FBDIV5_ipd             : std_ulogic;
  signal FBDIV6_ipd             : std_ulogic;
  signal FBDLY0_ipd             : std_ulogic;
  signal FBDlY1_ipd             : std_ulogic;
  signal FBDLY2_ipd             : std_ulogic;
  signal FBDLY3_ipd             : std_ulogic;
  signal FBDlY4_ipd             : std_ulogic;
  signal FBSEL0_ipd             : std_ulogic;
  signal FBSEL1_ipd             : std_ulogic;
  signal XDLYSEL_ipd            : std_ulogic;
  signal VCOSEL0_ipd            : std_ulogic;
  signal VCOSEL1_ipd            : std_ulogic;
  signal VCOSEL2_ipd            : std_ulogic;

  signal GND                    : std_logic := '0';
  signal UNUSED                 : std_logic := 'X';

  component PLLPRIM
    generic (
              VCOFREQUENCY :  Real;
              f_CLKA_LOCK  :  Integer
            );
    port (
           DYNSYNC      : in    std_ulogic;
           CLKA         : in    std_ulogic;
           EXTFB        : in    std_ulogic;
           POWERDOWN    : in    std_ulogic;
           CLKB         : in    std_ulogic;
           CLKC         : in    std_ulogic;
           OADIVRST     : in    std_ulogic;
           OADIVHALF    : in    std_ulogic;
           OADIV0       : in    std_ulogic;
           OADIV1       : in    std_ulogic;
           OADIV2       : in    std_ulogic;
           OADIV3       : in    std_ulogic;
           OADIV4       : in    std_ulogic;
           OAMUX0       : in    std_ulogic;
           OAMUX1       : in    std_ulogic;
           OAMUX2       : in    std_ulogic;
           DLYGLA0      : in    std_ulogic;
           DLYGLA1      : in    std_ulogic;
           DLYGLA2      : in    std_ulogic;
           DLYGLA3      : in    std_ulogic;
           DLYGLA4      : in    std_ulogic;
           OBDIVRST     : in    std_ulogic;
           OBDIVHALF    : in    std_ulogic;
           OBDIV0       : in    std_ulogic;
           OBDIV1       : in    std_ulogic;
           OBDIV2       : in    std_ulogic;
           OBDIV3       : in    std_ulogic;
           OBDIV4       : in    std_ulogic;
           OBMUX0       : in    std_ulogic;
           OBMUX1       : in    std_ulogic;
           OBMUX2       : in    std_ulogic;
           DLYYB0       : in    std_ulogic;
           DLYYB1       : in    std_ulogic;
           DLYYB2       : in    std_ulogic;
           DLYYB3       : in    std_ulogic;
           DLYYB4       : in    std_ulogic;
           DLYGLB0      : in    std_ulogic;
           DLYGLB1      : in    std_ulogic;
           DLYGLB2      : in    std_ulogic;
           DLYGLB3      : in    std_ulogic;
           DLYGLB4      : in    std_ulogic;
           OCDIVRST     : in    std_ulogic;
           OCDIVHALF    : in    std_ulogic;
           OCDIV0       : in    std_ulogic;
           OCDIV1       : in    std_ulogic;
           OCDIV2       : in    std_ulogic;
           OCDIV3       : in    std_ulogic;
           OCDIV4       : in    std_ulogic;
           OCMUX0       : in    std_ulogic;
           OCMUX1       : in    std_ulogic;
           OCMUX2       : in    std_ulogic;
           DLYYC0       : in    std_ulogic;
           DLYYC1       : in    std_ulogic;
           DLYYC2       : in    std_ulogic;
           DLYYC3       : in    std_ulogic;
           DLYYC4       : in    std_ulogic;
           DLYGLC0      : in    std_ulogic;
           DLYGLC1      : in    std_ulogic;
           DLYGLC2      : in    std_ulogic;
           DLYGLC3      : in    std_ulogic;
           DLYGLC4      : in    std_ulogic;
           FINDIV0      : in    std_ulogic;
           FINDIV1      : in    std_ulogic;
           FINDIV2      : in    std_ulogic;
           FINDIV3      : in    std_ulogic;
           FINDIV4      : in    std_ulogic;
           FINDIV5      : in    std_ulogic;
           FINDIV6      : in    std_ulogic;
           FBDIV0       : in    std_ulogic;
           FBDIV1       : in    std_ulogic;
           FBDIV2       : in    std_ulogic;
           FBDIV3       : in    std_ulogic;
           FBDIV4       : in    std_ulogic;
           FBDIV5       : in    std_ulogic;
           FBDIV6       : in    std_ulogic;
           FBDLY0       : in    std_ulogic;
           FBDlY1       : in    std_ulogic;
           FBDLY2       : in    std_ulogic;
           FBDLY3       : in    std_ulogic;
           FBDlY4       : in    std_ulogic;
           FBSEL0       : in    std_ulogic;
           FBSEL1       : in    std_ulogic;
           XDLYSEL      : in    std_ulogic;
           VCOSEL0      : in    std_ulogic;
           VCOSEL1      : in    std_ulogic;
           VCOSEL2      : in    std_ulogic;
           GLA          : out   std_ulogic;
           LOCK         : out   std_ulogic;
           GLB          : out   std_ulogic;
           YB           : out   std_ulogic;
           GLC          : out   std_ulogic;
           YC           : out   std_ulogic
         );
  end component;

  begin

    ---------------------
    --  INPUT PATH DELAYs
    ---------------------
    WireDelay : block

    begin

      VitalWireDelay ( CLKA_ipd,      CLKA,      tipd_CLKA );
      VitalWireDelay ( EXTFB_ipd,     EXTFB,     tipd_EXTFB );
      VitalWireDelay ( POWERDOWN_ipd, POWERDOWN, tipd_POWERDOWN );
      VitalWireDelay ( OADIV0_ipd,    OADIV0,    tipd_OADIV0 );
      VitalWireDelay ( OADIV1_ipd,    OADIV1,    tipd_OADIV1 );
      VitalWireDelay ( OADIV2_ipd,    OADIV2,    tipd_OADIV2 );
      VitalWireDelay ( OADIV3_ipd,    OADIV3,    tipd_OADIV3 );
      VitalWireDelay ( OADIV4_ipd,    OADIV4,    tipd_OADIV4 );
      VitalWireDelay ( OAMUX0_ipd,    OAMUX0,    tipd_OAMUX0 );
      VitalWireDelay ( OAMUX1_ipd,    OAMUX1,    tipd_OAMUX1 );
      VitalWireDelay ( OAMUX2_ipd,    OAMUX2,    tipd_OAMUX2 );
      VitalWireDelay ( DLYGLA0_ipd,   DLYGLA0,   tipd_DLYGLA0 );
      VitalWireDelay ( DLYGLA1_ipd,   DLYGLA1,   tipd_DLYGLA1 );
      VitalWireDelay ( DLYGLA2_ipd,   DLYGLA2,   tipd_DLYGLA2 );
      VitalWireDelay ( DLYGLA3_ipd,   DLYGLA3,   tipd_DLYGLA3 );
      VitalWireDelay ( DLYGLA4_ipd,   DLYGLA4,   tipd_DLYGLA4 );
      VitalWireDelay ( OBDIV0_ipd,    OBDIV0,    tipd_OBDIV0 );
      VitalWireDelay ( OBDIV1_ipd,    OBDIV1,    tipd_OBDIV1 );
      VitalWireDelay ( OBDIV2_ipd,    OBDIV2,    tipd_OBDIV2 );
      VitalWireDelay ( OBDIV3_ipd,    OBDIV3,    tipd_OBDIV3 );
      VitalWireDelay ( OBDIV4_ipd,    OBDIV4,    tipd_OBDIV4 );
      VitalWireDelay ( OBMUX0_ipd,    OBMUX0,    tipd_OBMUX0 );
      VitalWireDelay ( OBMUX1_ipd,    OBMUX1,    tipd_OBMUX1 );
      VitalWireDelay ( OBMUX2_ipd,    OBMUX2,    tipd_OBMUX2 );
      VitalWireDelay ( DLYYB0_ipd,    DLYYB0,    tipd_DLYYB0 );
      VitalWireDelay ( DLYYB1_ipd,    DLYYB1,    tipd_DLYYB1 );
      VitalWireDelay ( DLYYB2_ipd,    DLYYB2,    tipd_DLYYB2 );
      VitalWireDelay ( DLYYB3_ipd,    DLYYB3,    tipd_DLYYB3 );
      VitalWireDelay ( DLYYB4_ipd,    DLYYB4,    tipd_DLYYB4 );
      VitalWireDelay ( DLYGLB0_ipd,   DLYGLB0,   tipd_DLYGLB0 );
      VitalWireDelay ( DLYGLB1_ipd,   DLYGLB1,   tipd_DLYGLB1 );
      VitalWireDelay ( DLYGLB2_ipd,   DLYGLB2,   tipd_DLYGLB2 );
      VitalWireDelay ( DLYGLB3_ipd,   DLYGLB3,   tipd_DLYGLB3 );
      VitalWireDelay ( DLYGLB4_ipd,   DLYGLB4,   tipd_DLYGLB4 );
      VitalWireDelay ( OCDIV0_ipd,    OCDIV0,    tipd_OCDIV0 );
      VitalWireDelay ( OCDIV1_ipd,    OCDIV1,    tipd_OCDIV1 );
      VitalWireDelay ( OCDIV2_ipd,    OCDIV2,    tipd_OCDIV2 );
      VitalWireDelay ( OCDIV3_ipd,    OCDIV3,    tipd_OCDIV3 );
      VitalWireDelay ( OCDIV4_ipd,    OCDIV4,    tipd_OCDIV4 );
      VitalWireDelay ( OCMUX0_ipd,    OCMUX0,    tipd_OCMUX0 );
      VitalWireDelay ( OCMUX1_ipd,    OCMUX1,    tipd_OCMUX1 );
      VitalWireDelay ( OCMUX2_ipd,    OCMUX2,    tipd_OCMUX2 );
      VitalWireDelay ( DLYYC0_ipd,    DLYYC0,    tipd_DLYYC0 );
      VitalWireDelay ( DLYYC1_ipd,    DLYYC1,    tipd_DLYYC1 );
      VitalWireDelay ( DLYYC2_ipd,    DLYYC2,    tipd_DLYYC2 );
      VitalWireDelay ( DLYYC3_ipd,    DLYYC3,    tipd_DLYYC3 );
      VitalWireDelay ( DLYYC4_ipd,    DLYYC4,    tipd_DLYYC4 );
      VitalWireDelay ( DLYGLC0_ipd,   DLYGLC0,   tipd_DLYGLC0 );
      VitalWireDelay ( DLYGLC1_ipd,   DLYGLC1,   tipd_DLYGLC1 );
      VitalWireDelay ( DLYGLC2_ipd,   DLYGLC2,   tipd_DLYGLC2 );
      VitalWireDelay ( DLYGLC3_ipd,   DLYGLC3,   tipd_DLYGLC3 );
      VitalWireDelay ( DLYGLC4_ipd,   DLYGLC4,   tipd_DLYGLC4 );
      VitalWireDelay ( FINDIV0_ipd,   FINDIV0,   tipd_FINDIV0 );
      VitalWireDelay ( FINDIV1_ipd,   FINDIV1,   tipd_FINDIV1 );
      VitalWireDelay ( FINDIV2_ipd,   FINDIV2,   tipd_FINDIV2 );
      VitalWireDelay ( FINDIV3_ipd,   FINDIV3,   tipd_FINDIV3 );
      VitalWireDelay ( FINDIV4_ipd,   FINDIV4,   tipd_FINDIV4 );
      VitalWireDelay ( FINDIV5_ipd,   FINDIV5,   tipd_FINDIV5 );
      VitalWireDelay ( FINDIV6_ipd,   FINDIV6,   tipd_FINDIV6 );
      VitalWireDelay ( FBDIV0_ipd,    FBDIV0,    tipd_FBDIV0 );
      VitalWireDelay ( FBDIV1_ipd,    FBDIV1,    tipd_FBDIV1 );
      VitalWireDelay ( FBDIV2_ipd,    FBDIV2,    tipd_FBDIV2 );
      VitalWireDelay ( FBDIV3_ipd,    FBDIV3,    tipd_FBDIV3 );
      VitalWireDelay ( FBDIV4_ipd,    FBDIV4,    tipd_FBDIV4 );
      VitalWireDelay ( FBDIV5_ipd,    FBDIV5,    tipd_FBDIV5 );
      VitalWireDelay ( FBDIV6_ipd,    FBDIV6,    tipd_FBDIV6 );
      VitalWireDelay ( FBDLY0_ipd,    FBDLY0,    tipd_FBDLY0 );
      VitalWireDelay ( FBDLY1_ipd,    FBDLY1,    tipd_FBDLY1 );
      VitalWireDelay ( FBDLY2_ipd,    FBDLY2,    tipd_FBDLY2 );
      VitalWireDelay ( FBDLY3_ipd,    FBDLY3,    tipd_FBDLY3 );
      VitalWireDelay ( FBDLY4_ipd,    FBDLY4,    tipd_FBDLY4 );
      VitalWireDelay ( FBSEL0_ipd,    FBSEL0,    tipd_FBSEL0 );
      VitalWireDelay ( FBSEL1_ipd,    FBSEL1,    tipd_FBSEL1 );
      VitalWireDelay ( XDLYSEL_ipd,   XDLYSEL,   tipd_XDLYSEL );
      VitalWireDelay ( VCOSEL0_ipd,   VCOSEL0,   tipd_VCOSEL0 );
      VitalWireDelay ( VCOSEL1_ipd,   VCOSEL1,   tipd_VCOSEL1 );
      VitalWireDelay ( VCOSEL2_ipd,   VCOSEL2,   tipd_VCOSEL2 );
 
    end block WireDelay;
    
    P1: PLLPRIM
          generic map (
                        VCOFREQUENCY => VCOFREQUENCY,
                        f_CLKA_LOCK  => f_CLKA_LOCK
                      )
          port map    (
                        DYNSYNC      => GND,
                        CLKA         => CLKA_ipd,
                        EXTFB        => EXTFB_ipd,
                        POWERDOWN    => POWERDOWN_ipd,
                        CLKB         => UNUSED,
                        CLKC         => UNUSED,
                        OADIVRST     => GND,
                        OADIVHALF    => GND,
                        OADIV0       => OADIV0_ipd,
                        OADIV1       => OADIV1_ipd,
                        OADIV2       => OADIV2_ipd,
                        OADIV3       => OADIV3_ipd,
                        OADIV4       => OADIV4_ipd,
                        OAMUX0       => OAMUX0_ipd,
                        OAMUX1       => OAMUX1_ipd,
                        OAMUX2       => OAMUX2_ipd,
                        DLYGLA0      => DLYGLA0_ipd,
                        DLYGLA1      => DLYGLA1_ipd,
                        DLYGLA2      => DLYGLA2_ipd,
                        DLYGLA3      => DLYGLA3_ipd,
                        DLYGLA4      => DLYGLA4_ipd,
                        OBDIVRST     => GND,
                        OBDIVHALF    => GND,
                        OBDIV0       => OBDIV0_ipd,
                        OBDIV1       => OBDIV1_ipd,
                        OBDIV2       => OBDIV2_ipd,
                        OBDIV3       => OBDIV3_ipd,
                        OBDIV4       => OBDIV4_ipd,
                        OBMUX0       => OBMUX0_ipd,
                        OBMUX1       => OBMUX1_ipd,
                        OBMUX2       => OBMUX2_ipd,
                        DLYYB0       => DLYYB0_ipd,
                        DLYYB1       => DLYYB1_ipd,
                        DLYYB2       => DLYYB2_ipd,
                        DLYYB3       => DLYYB3_ipd,
                        DLYYB4       => DLYYB4_ipd,
                        DLYGLB0      => DLYGLB0_ipd,
                        DLYGLB1      => DLYGLB1_ipd,
                        DLYGLB2      => DLYGLB2_ipd,
                        DLYGLB3      => DLYGLB3_ipd,
                        DLYGLB4      => DLYGLB4_ipd,
                        OCDIVRST     => GND,
                        OCDIVHALF    => GND,
                        OCDIV0       => OCDIV0_ipd,
                        OCDIV1       => OCDIV1_ipd,
                        OCDIV2       => OCDIV2_ipd,
                        OCDIV3       => OCDIV3_ipd,
                        OCDIV4       => OCDIV4_ipd,
                        OCMUX0       => OCMUX0_ipd,
                        OCMUX1       => OCMUX1_ipd,
                        OCMUX2       => OCMUX2_ipd,
                        DLYYC0       => DLYYC0_ipd,
                        DLYYC1       => DLYYC1_ipd,
                        DLYYC2       => DLYYC2_ipd,
                        DLYYC3       => DLYYC3_ipd,
                        DLYYC4       => DLYYC4_ipd,
                        DLYGLC0      => DLYGLC0_ipd,
                        DLYGLC1      => DLYGLC1_ipd,
                        DLYGLC2      => DLYGLC2_ipd,
                        DLYGLC3      => DLYGLC3_ipd,
                        DLYGLC4      => DLYGLC4_ipd,
                        FINDIV0      => FINDIV0_ipd,
                        FINDIV1      => FINDIV1_ipd,
                        FINDIV2      => FINDIV2_ipd,
                        FINDIV3      => FINDIV3_ipd,
                        FINDIV4      => FINDIV4_ipd,
                        FINDIV5      => FINDIV5_ipd,
                        FINDIV6      => FINDIV6_ipd,
                        FBDIV0       => FBDIV0_ipd,
                        FBDIV1       => FBDIV1_ipd,
                        FBDIV2       => FBDIV2_ipd,
                        FBDIV3       => FBDIV3_ipd,
                        FBDIV4       => FBDIV4_ipd,
                        FBDIV5       => FBDIV5_ipd,
                        FBDIV6       => FBDIV6_ipd,
                        FBDLY0       => FBDLY0_ipd,
                        FBDlY1       => FBDlY1_ipd,
                        FBDLY2       => FBDLY2_ipd,
                        FBDLY3       => FBDLY3_ipd,
                        FBDlY4       => FBDlY4_ipd,
                        FBSEL0       => FBSEL0_ipd,
                        FBSEL1       => FBSEL1_ipd,
                        XDLYSEL      => XDLYSEL_ipd,
                        VCOSEL0      => VCOSEL0_ipd,
                        VCOSEL1      => VCOSEL1_ipd,
                        VCOSEL2      => VCOSEL2_ipd,
                        GLA          => GLA,
                        LOCK         => LOCK,
                        GLB          => GLB,
                        YB           => YB,
                        GLC          => GLC,
                        YC           => YC
                      );
  end VITAL_ACT;

 library IEEE;
 use IEEE.std_logic_1164.all;

 entity UJTAG is
   port(
      UTDO           :  in    STD_ULOGIC;
      TMS            :  in    STD_ULOGIC;
      TDI            :  in    STD_ULOGIC;
      TCK            :  in    STD_ULOGIC;
      TRSTB          :  in    STD_ULOGIC;
      UIREG0         :  out   STD_ULOGIC;
      UIREG1         :  out   STD_ULOGIC;
      UIREG2         :  out   STD_ULOGIC;
      UIREG3         :  out   STD_ULOGIC;
      UIREG4         :  out   STD_ULOGIC;
      UIREG5         :  out   STD_ULOGIC;
      UIREG6         :  out   STD_ULOGIC;
      UIREG7         :  out   STD_ULOGIC;
      UTDI           :  out   STD_ULOGIC;
      URSTB          :  out   STD_ULOGIC;
      UDRCK          :  out   STD_ULOGIC;
      UDRCAP         :  out   STD_ULOGIC;
      UDRSH          :  out   STD_ULOGIC;
      UDRUPD         :  out   STD_ULOGIC;
      TDO            :  out   STD_ULOGIC);
 end;

 library IEEE;
 use IEEE.std_logic_1164.all;

 architecture behav of UJTAG is
 begin
    UIREG0 <= '0';   
    UIREG1 <= '0';     
    UIREG2 <= '0';     
    UIREG3 <= '0';     
    UIREG4 <= '0';     
    UIREG5 <= '0';     
    UIREG6 <= '0';     
    UIREG7 <= '0';     
    UTDI   <= '0';     
    URSTB  <= '0';     
    UDRCK  <= '0';     
    UDRCAP <= '0';     
    UDRSH  <= '0';     
    UDRUPD <= '0';     
    TDO    <= '0';     
 end;

