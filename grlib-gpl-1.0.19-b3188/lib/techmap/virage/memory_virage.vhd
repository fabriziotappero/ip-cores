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
-- File:	mem_virage_gen.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Memory generators for Virage rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library virage;
use virage.hdss1_128x32cm4sw0ab;
use virage.hdss1_256x32cm4sw0ab;
use virage.hdss1_512x32cm4sw0ab;
use virage.hdss1_512x38cm4sw0ab;
use virage.hdss1_1024x32cm4sw0ab;
use virage.hdss1_2048x32cm8sw0ab;
use virage.hdss1_4096x36cm8sw0ab;
use virage.hdss1_16384x8cm16sw0;
-- pragma translate_on

entity virage_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector(abits -1 downto 0);
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
  );
end;

architecture rtl of virage_syncram is

  component hdss1_128x32cm4sw0ab
  port (
    addr, taddr : in std_logic_vector(6 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_256x32cm4sw0ab
  port (
    addr, taddr : in std_logic_vector(7 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_512x32cm4sw0ab
  port (
    addr, taddr : in std_logic_vector(8 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_512x38cm4sw0ab
  port (
    addr, taddr : in std_logic_vector(8 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(37 downto 0);
    do          : out std_logic_vector(37 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_1024x32cm4sw0ab
  port (
    addr, taddr : in std_logic_vector(9 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_2048x32cm8sw0ab
  port (
    addr, taddr : in std_logic_vector(10 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_4096x36cm8sw0ab is
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

  signal d, q, gnd : std_logic_vector(40 downto 0);
  signal a : std_logic_vector(17 downto 0);
  signal vcc : std_ulogic;
  constant synopsys_bug : std_logic_vector(40 downto 0) := (others => '0');
begin

  gnd <= (others => '0'); vcc <= '1';
  a(abits -1 downto 0) <= address;
  d(dbits -1 downto 0) <= datain(dbits -1 downto 0);
  a(17 downto abits) <= synopsys_bug(17 downto abits);
  d(40 downto dbits) <= synopsys_bug(40 downto dbits);
  dataout <= q(dbits -1 downto 0);

  a7d32 : if (abits <= 7) and (dbits <= 32) generate
    id0 : hdss1_128x32cm4sw0ab
      port map (a(6 downto 0), gnd(6 downto 0),clk,
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0),
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a8d32 : if (abits = 8) and (dbits <= 32) generate
    id0 : hdss1_256x32cm4sw0ab
      port map (a(7 downto 0), gnd(7 downto 0),clk,
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0),
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a9d32 : if (abits = 9) and (dbits <= 32) generate
    id0 : hdss1_512x32cm4sw0ab
      port map (address(8 downto 0), gnd(8 downto 0),clk,
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0),
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a9d38 : if (abits = 9) and (dbits > 32) and (dbits <= 38) generate
    id0 : hdss1_512x38cm4sw0ab
      port map (address(8 downto 0), gnd(8 downto 0),clk,
	d(37 downto 0), gnd(37 downto 0), q(37 downto 0),
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a10d32 : if (abits = 10) and (dbits <= 32) generate
    id0 : hdss1_1024x32cm4sw0ab
      port map (address(9 downto 0), gnd(9 downto 0), clk,
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0),
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a11d32 : if (abits = 11) and (dbits <= 32) generate
    id0 : hdss1_2048x32cm8sw0ab
      port map (address(10 downto 0), gnd(10 downto 0), clk,
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0),
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a12d36 : if (abits = 12) and (dbits <= 36) generate
    id0 : hdss1_4096x36cm8sw0ab
      port map (address(11 downto 0), gnd(11 downto 0), clk,
	d(35 downto 0), gnd(35 downto 0), q(35 downto 0),
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a14d8 : if (abits = 14) and (dbits <= 8) generate
    id0 : hdss1_16384x8cm16sw0
      port map (address(13 downto 0), clk,
	d(7 downto 0), q(7 downto 0),
	enable, vcc, Write);
  end generate;

end rtl;

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library virage;
use virage.hdss2_64x32cm4sw0ab;
use virage.hdss2_128x32cm4sw0ab;
use virage.hdss2_256x32cm4sw0ab;
use virage.hdss2_512x32cm4sw0ab;
use virage.hdss2_512x38cm4sw0ab;
use virage.hdss2_8192x8cm16sw0ab;
-- pragma translate_on

entity virage_syncram_dp is
  generic ( abits : integer := 10; dbits : integer := 8);
  port (
    clk1     : in std_ulogic;
    address1 : in std_logic_vector((abits -1) downto 0);
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_ulogic;
    write1   : in std_ulogic;
    clk2     : in std_ulogic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_ulogic;
    write2   : in std_ulogic
   );
end;
architecture rtl of virage_syncram_dp is

  component hdss2_64x32cm4sw0ab
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

  component hdss2_128x32cm4sw0ab
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

  component hdss2_256x32cm4sw0ab
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

  component hdss2_512x32cm4sw0ab
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

  component hdss2_512x38cm4sw0ab
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

  component hdss2_8192x8cm16sw0ab
  port (
    addra, taddra : in std_logic_vector(12 downto 0);
    addrb, taddrb : in std_logic_vector(12 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(7 downto 0);
    dib, tdib     : in std_logic_vector(7 downto 0);
    doa, dob      : out std_logic_vector(7 downto 0);
    mea, oea, wea, tmea, twea, awta, bistea, toea : in std_logic;
    meb, oeb, web, tmeb, tweb, awtb, bisteb, toeb : in std_logic
  );
  end component;

  signal vcc : std_ulogic;
  signal d1, d2, a1, a2, q1, q2, gnd : std_logic_vector(40 downto 0);
begin

  vcc <= '1'; gnd <=  (others => '0');
  d1(dbits-1 downto 0) <= datain1; d1(40 downto dbits) <= (others => '0');
  d2(dbits-1 downto 0) <= datain2; d2(40 downto dbits) <= (others => '0');
  a1(abits-1 downto 0) <= address1; a1(40 downto abits) <= (others => '0');
  a2(abits-1 downto 0) <= address2; a2(40 downto abits) <= (others => '0');
  dataout1 <= q1(dbits-1 downto 0); dataout2 <= q2(dbits-1 downto 0);

  a6d32 : if (abits <= 6) and (dbits <= 32) generate
    id0 : hdss2_64x32cm4sw0ab
      port map (a1(5 downto 0), gnd(5 downto 0), a2(5 downto 0),
	gnd(5 downto 0), clk1, clk2,
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0),
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a7d32 : if (abits = 7) and (dbits <= 32) generate
    id0 : hdss2_128x32cm4sw0ab
      port map (a1(6 downto 0), gnd(6 downto 0), a2(6 downto 0),
	gnd(6 downto 0), clk1, clk2,
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0),
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a8d32 : if (abits = 8) and (dbits <= 32) generate
    id0 : hdss2_256x32cm4sw0ab
      port map (a1(7 downto 0), gnd(7 downto 0), a2(7 downto 0),
	gnd(7 downto 0), clk1, clk2,
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0),
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a9d32 : if (abits = 9) and (dbits <= 32) generate
    id0 : hdss2_512x32cm4sw0ab
      port map (a1(8 downto 0), gnd(8 downto 0), a2(8 downto 0),
	gnd(8 downto 0), clk1, clk2,
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0),
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a9d38 : if (abits = 9) and (dbits > 32) and (dbits <= 38) generate
    id0 : hdss2_512x38cm4sw0ab
      port map (a1(8 downto 0), gnd(8 downto 0), a2(8 downto 0),
	gnd(8 downto 0), clk1, clk2,
	d1(37 downto 0), gnd(37 downto 0), d2(37 downto 0), gnd(37 downto 0),
	q1(37 downto 0), q2(37 downto 0),
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

end;



library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library virage;
use virage.rfss2_136x32cm2sw0ab;
use virage.rfss2_136x40cm2sw0ab;
use virage.rfss2_168x32cm2sw0ab;
use virage.hdss2_64x32cm4sw0ab;
use virage.hdss2_128x32cm4sw0ab;
use virage.hdss2_256x32cm4sw0ab;
use virage.hdss2_512x32cm4sw0ab;
use virage.hdss2_8192x8cm16sw0ab;
-- pragma translate_on

entity virage_syncram_2p is
  generic ( abits : integer := 6; dbits : integer := 8;
	sepclk : integer := 0; wrfst : integer := 0);
  port (
    rclk     : in std_ulogic;
    renable  : in std_ulogic;
    raddress : in std_logic_vector((abits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    wclk     : in std_ulogic;
    write    : in std_ulogic;
    waddress : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0));
end;

architecture rtl of virage_syncram_2p is

  component rfss2_136x32cm2sw0ab
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

  component rfss2_136x40cm2sw0ab
  port (
    addra, taddra : in std_logic_vector(7 downto 0);
    addrb, taddrb : in std_logic_vector(7 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(39 downto 0);
    dob      : out std_logic_vector(39 downto 0);
    mea, wea, tmea, twea, bistea : in std_logic;
    meb, oeb, tmeb,  awtb, bisteb, toeb : in std_logic
  );
  end component;

  signal vcc : std_ulogic;
  signal d1, a1, a2, q1, gnd : std_logic_vector(40 downto 0);
begin

  vcc <= '1'; gnd <=  (others => '0');
  d1(dbits-1 downto 0) <= datain; d1(40 downto dbits) <= (others => '0');
  a1(abits-1 downto 0) <= waddress; a1(40 downto abits) <= (others => '0');
  a2(abits-1 downto 0) <= raddress; a2(40 downto abits) <= (others => '0');
  dataout <= q1(dbits-1 downto 0);

    id0 : rfss2_136x40cm2sw0ab
      port map (
	a1(7 downto 0), gnd(7 downto 0), a2(7 downto 0), gnd(7 downto 0), 
	wclk, rclk, d1(39 downto 0), gnd(39 downto 0), 
	q1(39 downto 0), 
	vcc, write, gnd(0), gnd(0), gnd(0),
	renable, vcc, gnd(0), gnd(0), gnd(0), gnd(0));

end;

