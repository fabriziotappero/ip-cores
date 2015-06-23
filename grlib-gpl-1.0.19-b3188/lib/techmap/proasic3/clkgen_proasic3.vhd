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
-- Entity: 	various
-- File:	clkgen_proasic3.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Clock generators for Proasic3
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
-- pragma translate_off
library proasic3;
use proasic3.PLL;
use proasic3.PLLINT;
-- pragma translate_on
library techmap;
use techmap.gencomp.all;

------------------------------------------------------------------
-- Proasic3 clock generator --------------------------------------
------------------------------------------------------------------

entity clkgen_proasic3 is
  generic (
    clk_mul  : integer := 1; 
    clk_div  : integer := 1;
    clk_odiv : integer := 1;
    pcien    : integer := 0;
    pcisysclk: integer := 0;
    freq     : integer := 25000);	-- clock frequency in KHz
  port (
    clkin   : in  std_ulogic;
    pciclkin: in  std_ulogic;
    clk     : out std_ulogic;			-- main clock
    sdclk   : out std_ulogic;			-- SDRAM clock
    pciclk  : out std_ulogic;
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type
  );
end; 

architecture struct of clkgen_proasic3 is 

constant VERSION : integer := 0;

    component PLL
    generic (VCOFREQUENCY:real := 0.0);

        port(CLKA, EXTFB, POWERDOWN : in std_logic := 'U'; GLA, 
        LOCK, GLB, YB, GLC, YC : out std_logic;  OADIV0, OADIV1, 
        OADIV2, OADIV3, OADIV4, OAMUX0, OAMUX1, OAMUX2, DLYGLA0, 
        DLYGLA1, DLYGLA2, DLYGLA3, DLYGLA4, OBDIV0, OBDIV1, 
        OBDIV2, OBDIV3, OBDIV4, OBMUX0, OBMUX1, OBMUX2, DLYYB0, 
        DLYYB1, DLYYB2, DLYYB3, DLYYB4, DLYGLB0, DLYGLB1, DLYGLB2, 
        DLYGLB3, DLYGLB4, OCDIV0, OCDIV1, OCDIV2, OCDIV3, OCDIV4, 
        OCMUX0, OCMUX1, OCMUX2, DLYYC0, DLYYC1, DLYYC2, DLYYC3, 
        DLYYC4, DLYGLC0, DLYGLC1, DLYGLC2, DLYGLC3, DLYGLC4, 
        FINDIV0, FINDIV1, FINDIV2, FINDIV3, FINDIV4, FINDIV5, 
        FINDIV6, FBDIV0, FBDIV1, FBDIV2, FBDIV3, FBDIV4, FBDIV5, 
        FBDIV6, FBDLY0, FBDLY1, FBDLY2, FBDLY3, FBDLY4, FBSEL0, 
        FBSEL1, XDLYSEL, VCOSEL0, VCOSEL1, VCOSEL2 : in std_logic := 
        'U') ;
    end component;

    component PLLINT port( A : in std_logic; Y :out std_logic); end component;

    signal VCC_1_net, GND_1_net, clkint : std_logic ;
    signal M, N : std_logic_vector(6 downto 0) ;
    signal O : std_logic_vector(4 downto 0) ;
    signal vcosel : std_logic_vector(2 downto 0) ;

    constant vcomhz : integer := (((freq * clk_mul)/clk_div)/1000);
    constant glamhz : integer := vcomhz / clk_odiv;
    constant vcofreq : real := real(vcomhz);

    begin   

    VCC_1_net <= '1'; GND_1_net <= '0';

--  GLA = M / (N * U)

    M <= conv_std_logic_vector((clk_mul)-1, 7);
    N <= conv_std_logic_vector(clk_div-1, 7);
    O <= conv_std_logic_vector(clk_odiv-1, 5);
    vcosel <= "000" when vcomhz < 44 else
              "010" when vcomhz < 88 else
              "100" when vcomhz < 175 else "110";

    c0: if (pcisysclk = 0) or (pcien = 0) generate
      pllint0 : pllint port map (a => clkin, y => clkint);
    end generate;

    c1: if (pcien /= 0) generate
      d0: if pcisysclk = 1 generate
        pllint0 : pllint port map (a => pciclkin, y => clkint);
      end generate d0;
      pciclk <= pciclkin;
    end generate;

    c3 : if pcien = 0 generate 
      pciclk <= '0';
    end generate;

    cgo.pcilock <= '1';

    Core : PLL
      generic map(VCOFREQUENCY => vcofreq)

      port map(CLKA => clkint, EXTFB => GND_1_net, POWERDOWN => 
        VCC_1_net, GLA => clk, LOCK => cgo.clklock, GLB => OPEN , YB => 
        OPEN , GLC => OPEN , YC => OPEN , 
	OADIV0 => O(0), 
        OADIV1 => O(1), 
	OADIV2 => O(2), 
	OADIV3 => O(3), 
	OADIV4 => O(4), 
	OAMUX0 => GND_1_net, 
        OAMUX1 => GND_1_net, 
	OAMUX2 => VCC_1_net, 
	DLYGLA0 => GND_1_net, 
	DLYGLA1 => GND_1_net, 
	DLYGLA2 => GND_1_net, 
        DLYGLA3 => GND_1_net, 
	DLYGLA4 => GND_1_net, 
	OBDIV0 => GND_1_net, 
	OBDIV1 => GND_1_net, 
	OBDIV2 => GND_1_net, 
        OBDIV3 => GND_1_net, 
	OBDIV4 => GND_1_net, 
	OBMUX0 => GND_1_net, 
	OBMUX1 => GND_1_net, 
	OBMUX2 => GND_1_net, 
        DLYYB0 => GND_1_net, 
	DLYYB1 => GND_1_net, 
	DLYYB2 => GND_1_net, 
	DLYYB3 => GND_1_net, 
	DLYYB4 => GND_1_net, 
        DLYGLB0 => GND_1_net, 
	DLYGLB1 => GND_1_net, 
	DLYGLB2 => GND_1_net, 
	DLYGLB3 => GND_1_net, 
	DLYGLB4 => GND_1_net, 
        OCDIV0 => GND_1_net, 
	OCDIV1 => GND_1_net, 
	OCDIV2 => GND_1_net, 
	OCDIV3 => GND_1_net, 
	OCDIV4 => GND_1_net, 
        OCMUX0 => GND_1_net, 
	OCMUX1 => GND_1_net, 
	OCMUX2 => GND_1_net, 
	DLYYC0 => GND_1_net, 
	DLYYC1 => GND_1_net, 
        DLYYC2 => GND_1_net, 
	DLYYC3 => GND_1_net, 
	DLYYC4 => GND_1_net, 
	DLYGLC0 => GND_1_net, 
	DLYGLC1 => GND_1_net, 
	DLYGLC2 => GND_1_net, 
	DLYGLC3 => GND_1_net, 
	DLYGLC4 => GND_1_net, 
	FINDIV0 => N(0), 
	FINDIV1 => N(1), 
        FINDIV2 => N(2), 
	FINDIV3 => N(3), 
	FINDIV4 => N(4), 
	FINDIV5 => N(5), 
	FINDIV6 => N(6), 
        FBDIV0 => M(0), 
	FBDIV1 => M(1), 
	FBDIV2 => M(2), 
	FBDIV3 => M(3), 
	FBDIV4 => M(4), 
        FBDIV5 => M(5), 
	FBDIV6 => M(6), 
	FBDLY0 => GND_1_net, 
	FBDLY1 => GND_1_net, 
	FBDLY2 => GND_1_net, 
        FBDLY3 => GND_1_net, 
	FBDLY4 => GND_1_net, 
	FBSEL0 => VCC_1_net, 
	FBSEL1 => GND_1_net, 
	XDLYSEL => GND_1_net, 
        VCOSEL0 => vcosel(0), 
	VCOSEL1 => vcosel(1), 
	VCOSEL2 => vcosel(2));

-- pragma translate_off
  bootmsg : report_version 
  generic map (
    "clkgen_proasic3" & ": proasic3 clock generator, input clock " &  tost(freq/1000) & " MHz",
    "clkgen_proasic3" & ": output clock " & tost(glamhz) & " MHz, mul/div/odiv " & tost(clk_mul) 
	& "/" & tost(clk_div) & "/" & tost(clk_odiv)
	& ", VCO " & tost(vcomhz) & " MHz");
-- pragma translate_on

end ;

