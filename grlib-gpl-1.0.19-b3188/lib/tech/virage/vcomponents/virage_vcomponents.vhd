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
-- Package: 	virage_vcomponents
-- File:	virage_vcomponents.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Simple simulation models for ACTEL RAM and pads
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package virage_vcomponents is

  component hdss1_128x32cm4sw0b
  port (
    addr, taddr : in std_logic_vector(6 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_256x32cm4sw0b
  port (
    addr, taddr : in std_logic_vector(7 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_512x32cm4sw0b
  port (
    addr, taddr : in std_logic_vector(8 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_1024x32cm4sw0b
  port (
    addr, taddr : in std_logic_vector(9 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_2048x32cm8sw0b
  port (
    addr, taddr : in std_logic_vector(10 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_4096x36cm8sw0b is
  port (
    addr, taddr : in std_logic_vector(11 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(35 downto 0);
    do          : out std_logic_vector(35 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_16384x8cm16sw0 is
  port (
    addr        : in std_logic_vector(13 downto 0);
    clk         : in std_logic;
    di          : in std_logic_vector(7 downto 0);
    do          : out std_logic_vector(7 downto 0);
    me, oe, we  : in std_logic
  );
  end component;

  component rfss2_136x32cm2sw0b
  port (
    addra, taddra : in std_logic_vector(7 downto 0);
    addrb, taddrb : in std_logic_vector(7 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dob      : out std_logic_vector(31 downto 0);
    mea, wea, tmea, twea, bistea : in std_logic;
    meb, oeb, tmeb,  awtb, bisteb, toeb : in std_logic
  );
  end component;

  component rfss2_168x32cm2sw0b
  port (
    addra, taddra : in std_logic_vector(7 downto 0);
    addrb, taddrb : in std_logic_vector(7 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dob      : out std_logic_vector(31 downto 0);
    mea, wea, tmea, twea, bistea : in std_logic;
    meb, oeb, tmeb,  awtb, bisteb, toeb : in std_logic
  );
  end component;

  component hdss2_64x32cm4sw0b
  port (
    addra, taddra : in std_logic_vector(5 downto 0);
    addrb, taddrb : in std_logic_vector(5 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dib, tdib     : in std_logic_vector(31 downto 0);
    doa, dob      : out std_logic_vector(31 downto 0);
    mea, oea, wea, tmea, twea, awta, bistea, toea : in std_logic;
    meb, oeb, web, tmeb, tweb, awtb, bisteb, toeb : in std_logic
  );
  end component;

  component hdss2_128x32cm4sw0b
  port (
    addra, taddra : in std_logic_vector(6 downto 0);
    addrb, taddrb : in std_logic_vector(6 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dib, tdib     : in std_logic_vector(31 downto 0);
    doa, dob      : out std_logic_vector(31 downto 0);
    mea, oea, wea, tmea, twea, awta, bistea, toea : in std_logic;
    meb, oeb, web, tmeb, tweb, awtb, bisteb, toeb : in std_logic
  );
  end component;

  component hdss2_256x32cm4sw0b
  port (
    addra, taddra : in std_logic_vector(7 downto 0);
    addrb, taddrb : in std_logic_vector(7 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dib, tdib     : in std_logic_vector(31 downto 0);
    doa, dob      : out std_logic_vector(31 downto 0);
    mea, oea, wea, tmea, twea, awta, bistea, toea : in std_logic;
    meb, oeb, web, tmeb, tweb, awtb, bisteb, toeb : in std_logic
  );
  end component;

  component hdss2_512x32cm4sw0b
  port (
    addra, taddra : in std_logic_vector(8 downto 0);
    addrb, taddrb : in std_logic_vector(8 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dib, tdib     : in std_logic_vector(31 downto 0);
    doa, dob      : out std_logic_vector(31 downto 0);
    mea, oea, wea, tmea, twea, awta, bistea, toea : in std_logic;
    meb, oeb, web, tmeb, tweb, awtb, bisteb, toeb : in std_logic
  );
  end component;

  component hdss2_512x38cm4sw0b
  port (
    addra, taddra : in std_logic_vector(8 downto 0);
    addrb, taddrb : in std_logic_vector(8 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(37 downto 0);
    dib, tdib     : in std_logic_vector(37 downto 0);
    doa, dob      : out std_logic_vector(37 downto 0);
    mea, oea, wea, tmea, twea, awta, bistea, toea : in std_logic;
    meb, oeb, web, tmeb, tweb, awtb, bisteb, toeb : in std_logic
  );
  end component;

end;
