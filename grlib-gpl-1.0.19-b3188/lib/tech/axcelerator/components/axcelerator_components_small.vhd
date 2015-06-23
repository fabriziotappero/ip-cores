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
-- Description:	Simple Actel RAM and pad component declarations
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package components is

-- Axcellerator rams

  component RAM64K36
    port(
    WRAD0, WRAD1, WRAD2, WRAD3, WRAD4, WRAD5, WRAD6, WRAD7, WRAD8, WRAD9, WRAD10,
    WRAD11, WRAD12, WRAD13, WRAD14, WRAD15, WD0, WD1, WD2, WD3, WD4, WD5, WD6,
    WD7, WD8, WD9, WD10, WD11, WD12, WD13, WD14, WD15, WD16, WD17, WD18, WD19,
    WD20, WD21, WD22, WD23, WD24, WD25, WD26, WD27, WD28, WD29, WD30, WD31, WD32,
    WD33, WD34, WD35, WEN, DEPTH0, DEPTH1, DEPTH2, DEPTH3, WW0, WW1, WW2, WCLK,
    RDAD0, RDAD1, RDAD2, RDAD3, RDAD4, RDAD5, RDAD6, RDAD7, RDAD8, RDAD9, RDAD10,
    RDAD11, RDAD12, RDAD13, RDAD14, RDAD15, REN, RW0, RW1, RW2, RCLK : in std_logic;
    RD0, RD1, RD2, RD3, RD4, RD5, RD6, RD7, RD8, RD9, RD10, RD11, RD12, RD13,
    RD14, RD15, RD16, RD17, RD18, RD19, RD20, RD21, RD22, RD23, RD24, RD25, RD26,
    RD27, RD28, RD29, RD30, RD31, RD32, RD33, RD34, RD35 : out std_logic);
  end component;

  attribute syn_black_box : boolean;
  attribute syn_black_box of RAM64K36 : component is true;
  attribute syn_tco1 : string;
  attribute syn_tco2 : string;
  attribute syn_tco1 of RAM64K36 : component is
  "RCLK->RD0,RD1,RD2,RD3,RD4,RD5,RD6,RD7,RD8,RD9,RD10,RD11,RD12,RD13,RD14,RD15,RD16,RD17,RD18,RD19,RD20,RD21,RD22,RD23,RD24,RD25,RD26,RD27,RD28,RD29,RD30,RD31,RD32,RD33,RD34,RD35 = 4.0";

-- Buffers

  component inbuf_lvds port(Y : out std_logic; PADP : in std_logic; PADN : in std_logic); end component;
  component outbuf_lvds port(D : in std_logic; PADP : out std_logic; PADN : out std_logic); end component;
  component hclkbuf
  port( pad : in  std_logic; y   : out std_logic); end component;
  component clkbuf port(pad : in std_logic; y : out std_logic); end component;
  component inbuf port(pad :in std_logic; y : out std_logic); end component;
  component bibuf port(
    d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
  end component;
  component outbuf port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_8 port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_12 port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_16 port(d : in std_logic; pad : out std_logic); end component;
  component outbuf_f_24 port(d : in std_logic; pad : out std_logic); end component;
  component tribuff port(d, e : in std_logic; pad : out std_logic); end component;

  component hclkint port(a : in std_ulogic; y : out std_ulogic); end component;
  component clkint port(a : in std_ulogic; y : out std_ulogic); end component;
  component hclkbuf_pci
  port( pad : in  std_logic; y   : out std_logic); end component;
  component clkbuf_pci port(pad : in std_logic; y : out std_logic); end component;
  component inbuf_pci port(pad :in std_logic; y : out std_logic); end component;
  attribute syn_tpd11 : string;
  attribute syn_tpd11 of inbuf_pci : component is "pad -> y = 2.0";
  component bibuf_pci port(
    d, e : in  std_logic; pad : inout std_logic; y : out std_logic);
  end component;
  attribute syn_tpd12 : string;
  attribute syn_tpd12 of bibuf_pci : component is "pad -> y = 2.0";
  component outbuf_pci port(d : in std_logic; pad : out std_logic); end component;
  attribute syn_tpd13 : string;
  attribute syn_tpd13 of outbuf_pci : component is "d -> pad = 2.0";
  component tribuff_pci port(d, e : in std_logic; pad : out std_logic); end component;
  attribute syn_tpd14 : string;
  attribute syn_tpd14 of tribuff_pci : component is "d,e -> pad = 2.0";


-- 1553 -------------------------------

   component add1 is
      port(
      a : in std_logic;
      b : in std_logic;
      fci : in std_logic;
      s : out std_logic;
      fco : out std_logic);
   end component add1;

   component and2 is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component and2;

   component and2a is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component and2a;

   component and2b is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component and2b;

   component and3 is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component and3;

   component and3a is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component and3a;

   component and3b is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component and3b;

   component and3c is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component and3c;

   component and4 is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component and4;

   component and4a is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component and4a;

   component and4b is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component and4b;

   component and4c is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component and4c;

   component buff is
      port(
      a : in std_logic;
      y : out std_logic);
   end component buff;

   component cm8 is
      port(
      d0 : in std_logic;
      d1 : in std_logic;
      d2 : in std_logic;
      d3 : in std_logic;
      s00 : in std_logic;
      s01 : in std_logic;
      s10 : in std_logic;
      s11 : in std_logic;
      y : out std_logic);
   end component cm8;

   component cm8inv is
      port(
      a : in std_logic;
      y : out std_logic);
   end component cm8inv;

   component df1 is
      port(
      d : in std_logic;
      clk : in std_logic;
      q : out std_logic);
   end component df1;

   component dfc1b is
      port(
      d : in std_logic;
      clk : in std_logic;
      clr : in std_logic;
      q : out std_logic);
   end component dfc1b;

   component dfc1c is
      port(
      d : in std_logic;
      clk : in std_logic;
      clr : in std_logic;
      q : out std_logic);
   end component dfc1c;

   component dfc1d is
      port(
      d : in std_logic;
      clk : in std_logic;
      clr : in std_logic;
      q : out std_logic);
   end component dfc1d;

   component dfe1b is
      port(
      d : in std_logic;
      e : in std_logic;
      clk : in std_logic;
      q : out std_logic);
   end component dfe1b;

   component dfe3c is
      port(
      d : in std_logic;
      e : in std_logic;
      clk : in std_logic;
      clr : in std_logic;
      q : out std_logic);
   end component dfe3c;

   component dfe4f is
      port(
      d : in std_logic;
      e : in std_logic;
      clk : in std_logic;
      pre : in std_logic;
      q : out std_logic);
   end component dfe4f;

   component dfp1 is
      port(
      d : in std_logic;
      clk : in std_logic;
      pre : in std_logic;
      q : out std_logic);
   end component dfp1;

   component dfp1b is
      port(
      d : in std_logic;
      clk : in std_logic;
      pre : in std_logic;
      q : out std_logic);
   end component dfp1b;

   component dfp1d is
      port(
      d : in std_logic;
      clk : in std_logic;
      pre : in std_logic;
      q : out std_logic);
   end component dfp1d;

   component dfm
      port(
      clk : in std_logic;
      s	: in std_logic;
      a	: in std_logic;
      b	: in std_logic;
      q	: out std_logic);

 end component;

   component gnd is
      port(
      y : out std_logic);
   end component gnd;

   component inv is
      port(
      a : in std_logic;
      y : out std_logic);
   end component inv;

   component nand4 is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component nand4;

   component or2 is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component or2;

   component or2a is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component or2a;

   component or2b is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component or2b;

   component or3 is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component or3;

   component or3a is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component or3a;

   component or3b is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component or3b;

   component or3c is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component or3c;

   component or4 is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component or4;

   component or4a is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component or4a;

   component or4b is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component or4b;

   component or4c is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component or4c;

   component or4d is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      d : in std_logic;
      y : out std_logic);
   end component or4d;

   component sub1 is
      port(
      a : in std_logic;
      b : in std_logic;
      fci : in std_logic;
      s : out std_logic;
      fco : out std_logic);
   end component sub1;

   component vcc is
      port(
      y : out std_logic);
   end component vcc;

   component xa1 is
      port(
      a : in std_logic;
      b : in std_logic;
      c : in std_logic;
      y : out std_logic);
   end component xa1;

   component xnor2 is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component xnor2;

   component xor2 is
      port(
      a : in std_logic;
      b : in std_logic;
      y : out std_logic);
   end component xor2;

   component xor4 is
      port(a,b,c,d : in std_logic;
        y : out std_logic);
   end component xor4;

component mx2 
   port(
   a : in std_logic;
   s : in std_logic;
   b : in std_logic;
   y : out std_logic);
end component;

 component ax1c
    port(
        a: in    std_logic;
	b: in    std_logic;
	c: in    std_logic;
	y: out   std_logic);
 end component;

component df1b
   port(
   d : in std_logic;
   clk : in std_logic;
   q : out std_logic);
end component;

component dfe1b
   port(
   d : in std_logic;
   e : in std_logic;
   clk : in std_logic;
   q : out std_logic);
end component;

component df1
   port(
   d : in std_logic;
   clk : in std_logic;
   q : out std_logic);
end component;

end;
