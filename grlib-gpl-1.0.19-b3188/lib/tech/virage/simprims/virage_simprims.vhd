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
-- Package: 	virage_simprims
-- File:	virage_simprims.vhd
-- Author:	Jiri Gaisler, Gaisler Research
-- Description:	Simple simulation models for VIRAGE RAMs
-----------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;

package virage_simprims is

component virage_syncram_sim
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    addr  : in std_logic_vector((abits -1) downto 0);
    clk   : in std_logic;
    di    : in std_logic_vector((dbits -1) downto 0);
    do    : out std_logic_vector((dbits -1) downto 0);
    me    : in std_logic;
    oe    : in std_logic;
    we    : in std_logic
   );
end component;

--  synchronous 2-port ram
component virage_2pram_sim
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    addra, addrb  : in std_logic_vector((abits -1) downto 0);
    clka, clkb   : in std_logic;
    dia    : in std_logic_vector((dbits -1) downto 0);
    dob    : out std_logic_vector((dbits -1) downto 0);
    mea, wea, meb, oeb    : in std_logic
  );
end component;

component virage_dpram_sim
  generic (
    abits : integer := 8;
    dbits : integer := 32
  );
  port (
    addra  : in std_logic_vector((abits -1) downto 0);
    clka   : in std_logic;
    dia    : in std_logic_vector((dbits -1) downto 0);
    doa    : out std_logic_vector((dbits -1) downto 0);
    mea, oea, wea : in std_logic;
    addrb  : in std_logic_vector((abits -1) downto 0);
    clkb   : in std_logic;
    dib    : in std_logic_vector((dbits -1) downto 0);
    dob    : out std_logic_vector((dbits -1) downto 0);
    meb, oeb, web : in std_logic
  );
end component;

end;

-- 1-port syncronous ram

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity virage_syncram_sim is
  generic (
    abits : integer := 10;
    dbits : integer := 8
  );
  port (
    addr  : in std_logic_vector((abits -1) downto 0);
    clk   : in std_logic;
    di    : in std_logic_vector((dbits -1) downto 0);
    do    : out std_logic_vector((dbits -1) downto 0);
    me    : in std_logic;
    oe    : in std_logic;
    we    : in std_logic
  );
end;

architecture behavioral of virage_syncram_sim is
  subtype word is std_logic_vector((dbits -1) downto 0);
  type mem is array(0 to (2**abits -1)) of word;
begin
  main : process(clk, oe, me)
  variable memarr : mem;-- := (others => (others => '0'));
  variable doint  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clk) and (me = '1') and not is_x(addr) then
      if (we = '1') then memarr(to_integer(unsigned(addr))) := di; end if;
      doint := memarr(to_integer(unsigned(addr)));
    end if;
--    if (me and oe) = '1' then do <= doint;
    if oe = '1' then do <= doint;
    else do <= (others => 'Z'); end if;
  end process;
end behavioral;

--  synchronous 2-port ram

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity virage_2pram_sim is
  generic (
    abits : integer := 10;
    dbits : integer := 8;
    words : integer := 1024
  );
  port (
    addra, addrb  : in std_logic_vector((abits -1) downto 0);
    clka, clkb   : in std_logic;
    dia    : in std_logic_vector((dbits -1) downto 0);
    dob    : out std_logic_vector((dbits -1) downto 0);
    mea, wea, meb, oeb    : in std_logic
  );
end;

architecture behavioral of virage_2pram_sim is
  subtype word is std_logic_vector((dbits -1) downto 0);
  type mem is array(0 to (words-1)) of word;
begin
  main : process(clka, clkb, oeb, mea, meb, wea)
  variable memarr : mem;
  variable doint  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clka) and (mea = '1') and not is_x(addra) then
      if (wea = '1') then memarr(to_integer(unsigned(addra)) mod words) := dia; end if;
    end if;
    if rising_edge(clkb) and (meb = '1') and not is_x(addrb) then
      doint := memarr(to_integer(unsigned(addrb)) mod words);
    end if;
    if oeb = '1' then dob <= doint;
    else dob <= (others => 'Z'); end if;
  end process;
end behavioral;


--  synchronous dual-port ram

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity virage_dpram_sim is
  generic (
    abits : integer := 10;
    dbits : integer := 8
  );
  port (
    addra  : in std_logic_vector((abits -1) downto 0);
    clka   : in std_logic;
    dia    : in std_logic_vector((dbits -1) downto 0);
    doa    : out std_logic_vector((dbits -1) downto 0);
    mea, oea, wea : in std_logic;
    addrb  : in std_logic_vector((abits -1) downto 0);
    clkb   : in std_logic;
    dib    : in std_logic_vector((dbits -1) downto 0);
    dob    : out std_logic_vector((dbits -1) downto 0);
    meb, oeb, web : in std_logic
  );
end;

architecture behavioral of virage_dpram_sim is
  subtype word is std_logic_vector((dbits -1) downto 0);
  type mem is array(0 to (2**abits -1)) of word;
begin
  main : process(clka, oea, mea, clkb, oeb, meb)
  variable memarr : mem;
  variable dointa, dointb  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clka) and (mea = '1') and not is_x(addra) then
      if (wea = '1') then memarr(to_integer(unsigned(addra))) := dia; end if;
      dointa := memarr(to_integer(unsigned(addra)));
    end if;
    if oea = '1' then doa <= dointa;
    else doa <= (others => 'Z'); end if;
    if rising_edge(clkb) and (meb = '1') and not is_x(addrb) then
      if (web = '1') then memarr(to_integer(unsigned(addrb))) := dib; end if;
      dointb := memarr(to_integer(unsigned(addrb)));
    end if;
    if oeb = '1' then dob <= dointb;
    else dob <= (others => 'Z'); end if;
  end process;
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_128x32cm4sw0ab is
  port (
    addr, taddr : in std_logic_vector(6 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_128x32cm4sw0ab is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 7, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_256x32cm4sw0ab is
  port (
    addr, taddr : in std_logic_vector(7 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_256x32cm4sw0ab is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 8, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_512x32cm4sw0ab is
  port (
    addr, taddr : in std_logic_vector(8 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_512x32cm4sw0ab is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 9, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_512x38cm4sw0ab is
  port (
    addr, taddr : in std_logic_vector(8 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(37 downto 0);
    do          : out std_logic_vector(37 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_512x38cm4sw0ab is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 9, dbits => 38)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_1024x32cm4sw0ab is
  port (
    addr, taddr : in std_logic_vector(9 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_1024x32cm4sw0ab is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 10, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_2048x32cm8sw0ab is
  port (
    addr, taddr : in std_logic_vector(10 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_2048x32cm8sw0ab is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 11, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_4096x36cm8sw0ab is
  port (
    addr, taddr : in std_logic_vector(11 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(35 downto 0);
    do          : out std_logic_vector(35 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_4096x36cm8sw0ab is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 12, dbits => 36)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss1_16384x8cm16sw0 is
  port (
    addr        : in std_logic_vector(13 downto 0);
    clk         : in std_logic;
    di          : in std_logic_vector(7 downto 0);
    do          : out std_logic_vector(7 downto 0);
    me, oe, we  : in std_logic
  );
end;
architecture behavioral of hdss1_16384x8cm16sw0 is
begin
  syncram0 : virage_syncram_sim
    generic map ( abits => 14, dbits => 8)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

-- 2-port syncronous ram

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity rfss2_136x32cm2sw0ab is
  port (
    addra, taddra : in std_logic_vector(7 downto 0);
    addrb, taddrb : in std_logic_vector(7 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dob           : out std_logic_vector(31 downto 0);
    mea, wea, tmea, twea, bistea : in std_logic;
    meb, oeb, tmeb,  awtb, bisteb, toeb : in std_logic
  );
end;
architecture behavioral of rfss2_136x32cm2sw0ab is
begin
  syncram0 : virage_2pram_sim
    generic map ( abits => 8, dbits => 32, words => 136)
    port map ( addra, addrb, clka, clkb, dia, dob, mea, wea, meb, oeb);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity rfss2_136x40cm2sw0ab is
  port (
    addra, taddra : in std_logic_vector(7 downto 0);
    addrb, taddrb : in std_logic_vector(7 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(39 downto 0);
    dob           : out std_logic_vector(39 downto 0);
    mea, wea, tmea, twea, bistea : in std_logic;
    meb, oeb, tmeb,  awtb, bisteb, toeb : in std_logic
  );
end;
architecture behavioral of rfss2_136x40cm2sw0ab is
begin
  syncram0 : virage_2pram_sim
    generic map ( abits => 8, dbits => 40, words => 136)
    port map ( addra, addrb, clka, clkb, dia, dob, mea, wea, meb, oeb);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity rfss2_168x32cm2sw0ab is
  port (
    addra, taddra : in std_logic_vector(7 downto 0);
    addrb, taddrb : in std_logic_vector(7 downto 0);
    clka, clkb    : in std_logic;
    dia, tdia     : in std_logic_vector(31 downto 0);
    dob           : out std_logic_vector(31 downto 0);
    mea, wea, tmea, twea, bistea : in std_logic;
    meb, oeb, tmeb,  awtb, bisteb, toeb : in std_logic
  );
end;
architecture behavioral of rfss2_168x32cm2sw0ab is
begin
  syncram0 : virage_2pram_sim
    generic map ( abits => 8, dbits => 32, words => 168)
    port map ( addra, addrb, clka, clkb, dia, dob, mea, wea, meb, oeb);
end behavioral;

-- dual-port syncronous ram

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;

entity hdss2_64x32cm4sw0ab is
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
end;
architecture behavioral of hdss2_64x32cm4sw0ab is
begin
  syncram0 : virage_dpram_sim
    generic map ( abits => 6, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea,
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss2_128x32cm4sw0ab is
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
end;
architecture behavioral of hdss2_128x32cm4sw0ab is
begin
  syncram0 : virage_dpram_sim
    generic map ( abits => 7, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea,
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss2_256x32cm4sw0ab is
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
end;
architecture behavioral of hdss2_256x32cm4sw0ab is
begin
  syncram0 : virage_dpram_sim
    generic map ( abits => 8, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea,
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss2_512x32cm4sw0ab is
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
end;
architecture behavioral of hdss2_512x32cm4sw0ab is
begin
  syncram0 : virage_dpram_sim
    generic map ( abits => 9, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea,
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss2_512x38cm4sw0ab is
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
end;
architecture behavioral of hdss2_512x38cm4sw0ab is
begin
  syncram0 : virage_dpram_sim
    generic map ( abits => 9, dbits => 38)
    port map ( addra, clka, dia, doa, mea, oea, wea,
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use ieee.std_logic_1164.all;
library virage;
use virage.virage_simprims.all;
entity hdss2_8192x8cm16sw0ab is
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
end;
architecture behavioral of hdss2_8192x8cm16sw0ab is
begin
  syncram0 : virage_dpram_sim
    generic map ( abits => 13, dbits => 8)
    port map ( addra, clka, dia, doa, mea, oea, wea,
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

-- pragma translate_on
