



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Entity: 	tech_atc18
-- File:	tech_atc18.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Contains Atmel ATC18 specific pads and ram generators
------------------------------------------------------------------------------




LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_atc18 is

-- sync ram generator

  component atc18_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector(abits -1 downto 0);
    clk      : in clk_type;
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_logic;
    write    : in std_logic);
  end component;

-- IU regfile generator

component atc18_regfile_iu
  generic (rftype : integer := 1; abits : integer := 8; dbits : integer := 32; words : integer := 136);
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
  end component;

component atc18_regfile_cp
  generic ( 
    abits : integer := 4;
    dbits : integer := 32;
    words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end component;

component atc18_dpram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address1 : in std_logic_vector((abits -1) downto 0);
    clk      : in clk_type;
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_logic;
    write1   : in std_logic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_logic;
    write2   : in std_logic
   ); 
end component;

-- input pads, all others pads are taken from the atc25 package

  component atc18_inpad 
    port (pad : in std_logic; q : out std_logic);
  end component; 
  component atc18_smpad
    port (pad : in std_logic; q : out std_logic);
  end component;

end;

------------------------------------------------------------------
-- behavioural pad models --------------------------------------------
------------------------------------------------------------------
-- Only needed for simulation, not synthesis.
-- pragma translate_off

-- input pad
library IEEE;
use IEEE.std_logic_1164.all;
entity pc33d00 is port (pad : in std_logic; cin : out std_logic); end; 
architecture rtl of pc33d00 is begin cin <= to_x01(pad) after 1 ns; end;

-- input schmitt pad
library IEEE;
use IEEE.std_logic_1164.all;
entity pc33d20 is port (pad : in std_logic; cin : out std_logic); end; 
architecture rtl of pc33d20 is begin cin <= to_x01(pad) after 1 ns; end;

------------------------------------------------------------------
-- behavioural ram models ----------------------------------------
------------------------------------------------------------------

-- synchronous 1-port ram

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atc18_syncram_sim is
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

architecture behavioral of atc18_syncram_sim is
  subtype word is std_logic_vector((dbits -1) downto 0);
  type mem is array(0 to (2**abits -1)) of word;
begin
  main : process(clk, oe, me)
  variable memarr : mem;
  variable doint  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clk) and (me = '1') and not is_x(addr) then
      if (we = '1') then memarr(conv_integer(unsigned(addr))) := di; end if;
      doint := memarr(conv_integer(unsigned(addr)));
    end if;
    if (me and oe) = '1' then do <= doint; 
    else do <= (others => 'Z'); end if;
  end process;
end behavioral;

--  synchronous 2-port ram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity atc18_2pram_sim is
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

architecture behavioral of atc18_2pram_sim is
  subtype word is std_logic_vector((dbits -1) downto 0);
  type mem is array(0 to (words-1)) of word;
begin
  main : process(clka, clkb, oeb, mea, meb, wea)
  variable memarr : mem;
  variable doint  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clka) and (mea = '1') and not is_x(addra) then
      if (wea = '1') then memarr(conv_integer(unsigned(addra)) mod words) := dia; end if;
    end if;
    if rising_edge(clkb) and (meb = '1') and not is_x(addrb) then
      doint := memarr(conv_integer(unsigned(addrb)) mod words);
    end if;
    if (meb and oeb) = '1' then dob <= doint; 
    else dob <= (others => 'Z'); end if;
  end process;
end behavioral;


--  synchronous dual-port ram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity atc18_dpram_sim is
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

architecture behavioral of atc18_dpram_sim is
  subtype word is std_logic_vector((dbits -1) downto 0);
  type mem is array(0 to (2**abits -1)) of word;
begin
  main : process(clka, oea, mea, clkb, oeb, meb)
  variable memarr : mem;
  variable dointa, dointb  : std_logic_vector((dbits -1) downto 0);
  begin
    if rising_edge(clka) and (mea = '1') and not is_x(addra) then
      if (wea = '1') then memarr(conv_integer(unsigned(addra))) := dia; end if;
      dointa := memarr(conv_integer(unsigned(addra)));
    end if;
    if (mea and oea) = '1' then doa <= dointa; 
    else doa <= (others => 'Z'); end if;
    if rising_edge(clkb) and (meb = '1') and not is_x(addrb) then
      if (web = '1') then memarr(conv_integer(unsigned(addrb))) := dib; end if;
      dointb := memarr(conv_integer(unsigned(addrb)));
    end if;
    if (meb and oeb) = '1' then dob <= dointb; 
    else dob <= (others => 'Z'); end if;
  end process;
end behavioral;

-- package with common ram simulation models
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_atc18_sim is
component atc18_syncram_sim
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
component atc18_2pram_sim
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

component atc18_dpram_sim
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
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss1_128x32cm4sw0 is
  port (
    addr, taddr : in std_logic_vector(6 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_128x32cm4sw0 is
begin
  syncram0 : atc18_syncram_sim
    generic map ( abits => 7, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss1_256x32cm4sw0 is
  port (
    addr, taddr : in std_logic_vector(7 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_256x32cm4sw0 is
begin
  syncram0 : atc18_syncram_sim
    generic map ( abits => 8, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss1_512x32cm4sw0 is
  port (
    addr, taddr : in std_logic_vector(8 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_512x32cm4sw0 is
begin
  syncram0 : atc18_syncram_sim
    generic map ( abits => 9, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss1_1024x32cm4sw0 is
  port (
    addr, taddr : in std_logic_vector(9 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_1024x32cm4sw0 is
begin
  syncram0 : atc18_syncram_sim
    generic map ( abits => 10, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss1_2048x32cm8sw0 is
  port (
    addr, taddr : in std_logic_vector(10 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
end;
architecture behavioral of hdss1_2048x32cm8sw0 is
begin
  syncram0 : atc18_syncram_sim
    generic map ( abits => 11, dbits => 32)
    port map ( addr, clk, di, do, me, oe, we);
end behavioral;

-- 2-port syncronous ram

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity rfss2_136x32cm2sw0 is
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
architecture behavioral of rfss2_136x32cm2sw0 is
begin
  syncram0 : atc18_2pram_sim
    generic map ( abits => 8, dbits => 32, words => 136)
    port map ( addra, addrb, clka, clkb, dia, dob, mea, wea, meb, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity rfss2_168x32cm2sw0 is
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
architecture behavioral of rfss2_168x32cm2sw0 is
begin
  syncram0 : atc18_2pram_sim
    generic map ( abits => 8, dbits => 32, words => 168)
    port map ( addra, addrb, clka, clkb, dia, dob, mea, wea, meb, oeb);
end behavioral;

-- dual-port syncronous ram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;

entity hdss2_64x32cm4sw0 is
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
architecture behavioral of hdss2_64x32cm4sw0 is
begin
  syncram0 : atc18_dpram_sim
    generic map ( abits => 6, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea, 
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss2_128x32cm4sw0 is
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
architecture behavioral of hdss2_128x32cm4sw0 is
begin
  syncram0 : atc18_dpram_sim
    generic map ( abits => 7, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea, 
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss2_256x32cm4sw0 is
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
architecture behavioral of hdss2_256x32cm4sw0 is
begin
  syncram0 : atc18_dpram_sim
    generic map ( abits => 8, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea, 
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc18_sim.all;
entity hdss2_512x32cm4sw0 is
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
architecture behavioral of hdss2_512x32cm4sw0 is
begin
  syncram0 : atc18_dpram_sim
    generic map ( abits => 9, dbits => 32)
    port map ( addra, clka, dia, doa, mea, oea, wea, 
	       addrb, clkb, dib, dob, meb, oeb, web);
end behavioral;

-- pragma translate_on
-- component declarations from true tech library

LIBRARY ieee;
use IEEE.std_logic_1164.all;
package tech_atc18_syn is

  component hdss1_128x32cm4sw0
  port (
    addr, taddr : in std_logic_vector(6 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_256x32cm4sw0
  port (
    addr, taddr : in std_logic_vector(7 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_512x32cm4sw0
  port (
    addr, taddr : in std_logic_vector(8 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_1024x32cm4sw0
  port (
    addr, taddr : in std_logic_vector(9 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component hdss1_2048x32cm8sw0
  port (
    addr, taddr : in std_logic_vector(10 downto 0);
    clk         : in std_logic;
    di, tdi     : in std_logic_vector(31 downto 0);
    do          : out std_logic_vector(31 downto 0);
    me, oe, we, tme, twe, awt, biste, toe : in std_logic
  );
  end component;

  component rfss2_136x32cm2sw0
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

  component rfss2_168x32cm2sw0
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

  component hdss2_64x32cm4sw0
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

  component hdss2_128x32cm4sw0
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

  component hdss2_256x32cm4sw0
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

  component hdss2_512x32cm4sw0
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

  -- input pad
  component pc33d00 port (pad : in std_logic; cin : out std_logic); end component; 
  -- schmitt input pad
  component pc33d20 port (pad : in std_logic; cin : out std_logic); end component; 
end;
------------------------------------------------------------------
-- sync ram generator --------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_atc18_syn.all;
use work.leon_iface.all;


entity atc18_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector(abits -1 downto 0);
    clk      : in clk_type;
    datain   : in std_logic_vector(dbits -1 downto 0);
    dataout  : out std_logic_vector(dbits -1 downto 0);
    enable   : in std_logic;
    write    : in std_logic
  );
end;

architecture rtl of atc18_syncram is
  signal d, q, gnd : std_logic_vector(35 downto 0);
  signal a : std_logic_vector(17 downto 0);
  signal vcc : std_logic;
  constant synopsys_bug : std_logic_vector(37 downto 0) := (others => '0');
begin

  gnd <= (others => '0'); vcc <= '1';
  a(abits -1 downto 0) <= address; 
  d(dbits -1 downto 0) <= datain(dbits -1 downto 0); 
  a(17 downto abits) <= synopsys_bug(17 downto abits);
  d(35 downto dbits) <= synopsys_bug(35 downto dbits);
  dataout <= q(dbits -1 downto 0);
  q(35 downto dbits) <= synopsys_bug(35 downto dbits);

  a7d32 : if (abits <= 7) and (dbits <= 32) generate
    id0 : hdss1_128x32cm4sw0 
      port map (a(6 downto 0), gnd(6 downto 0), clk  , 
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0), 
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a8d32 : if (abits = 8) and (dbits <= 32) generate
    id0 : hdss1_256x32cm4sw0 
      port map (a(7 downto 0), gnd(7 downto 0), clk  , 
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0), 
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a9d32 : if (abits = 9) and (dbits <= 32) generate
    id0 : hdss1_512x32cm4sw0 
      port map (address(8 downto 0), gnd(8 downto 0), clk , 
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0), 
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));

  end generate;
  a10d32 : if (abits = 10) and (dbits <= 32) generate
    id0 : hdss1_1024x32cm4sw0 
      port map (address(9 downto 0), gnd(9 downto 0), clk , 
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0), 
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a11d32 : if (abits = 11) and (dbits <= 32) generate
    id0 : hdss1_2048x32cm8sw0 
      port map (address(10 downto 0), gnd(10 downto 0), clk , 
	d(31 downto 0), gnd(31 downto 0), q(31 downto 0), 
	enable, vcc, write, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

end rtl;

------------------------------------------------------------------
-- sync dpram generator --------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_atc18_syn.all;
use work.leon_iface.all;


entity atc18_dpram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address1 : in std_logic_vector((abits -1) downto 0);
    clk      : in clk_type;
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_logic;
    write1   : in std_logic;
    address2 : in std_logic_vector((abits -1) downto 0);
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_logic;
    write2   : in std_logic
   ); 
end;
architecture rtl of atc18_dpram is
  signal vcc : std_logic;
  signal d1, d2, a1, a2, q1, q2, gnd : std_logic_vector(35 downto 0);
begin

  vcc <= '1'; gnd <=  (others => '0');
  d1(dbits-1 downto 0) <= datain1; d1(35 downto dbits) <= (others => '0');
  d2(dbits-1 downto 0) <= datain2; d2(35 downto dbits) <= (others => '0');
  a1(abits-1 downto 0) <= address1; a1(35 downto abits) <= (others => '0');
  a2(abits-1 downto 0) <= address2; a2(35 downto abits) <= (others => '0');
  dataout1 <= q1(dbits-1 downto 0); dataout2 <= q2(dbits-1 downto 0);

  a6d32 : if (abits <= 6) and (dbits <= 32) generate
    id0 : hdss2_64x32cm4sw0 
      port map (a1(5 downto 0), gnd(5 downto 0), a2(5 downto 0),
	gnd(5 downto 0), clk  , clk  , 
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0), 
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a7d32 : if (abits = 7) and (dbits <= 32) generate
    id0 : hdss2_128x32cm4sw0 
      port map (a1(6 downto 0), gnd(6 downto 0), a2(6 downto 0),
	gnd(6 downto 0), clk  , clk  , 
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0), 
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a8d32 : if (abits = 8) and (dbits <= 32) generate
    id0 : hdss2_256x32cm4sw0 
      port map (a1(7 downto 0), gnd(7 downto 0), a2(7 downto 0),
	gnd(7 downto 0), clk  , clk  , 
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0), 
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

  a9d32 : if (abits = 9) and (dbits <= 32) generate
    id0 : hdss2_512x32cm4sw0 
      port map (a1(8 downto 0), gnd(8 downto 0), a2(8 downto 0),
	gnd(8 downto 0), clk  , clk  , 
	d1(31 downto 0), gnd(31 downto 0), d2(31 downto 0), gnd(31 downto 0),
	q1(31 downto 0), q2(31 downto 0), 
	enable1, vcc, write1, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0),
	enable2, vcc, write2, gnd(0), gnd(0), gnd(0), gnd(0), gnd(0));
  end generate;

end;

------------------------------------------------------------------
-- regfile generator  --------------------------------------------
------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tech_generic.all;
use work.tech_atc18_syn.all;
use work.leon_iface.all;
use work.leon_config.all;

entity atc18_regfile_iu is
  generic ( 
    rftype : integer := 1;
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 136
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
end;

architecture rtl of atc18_regfile_iu is
signal din1, din2, qq1, qq2, gnd : std_logic_vector(39 downto 0);
signal vcc : std_logic;
signal ra1, ra2, wa : std_logic_vector(14 downto 0);
begin

  vcc <= '1'; gnd <= (others => '0');
  ra1(abits-1 downto 0) <= rfi.rd1addr;
  ra2(abits-1 downto 0) <= rfi.rd2addr;
  wa(abits-1 downto 0) <= rfi.wraddr;
  din1(dbits-1 downto 0) <= rfi.wrdata;
  din2(dbits-1 downto 0) <= rfi.wrdata;
  wa(14 downto abits)   <= gnd(14 downto abits);
  ra1(14 downto abits)  <= gnd(14 downto abits);
  ra2(14 downto abits)  <= gnd(14 downto abits);
  din1(39 downto dbits) <= (others => '0');
  din2(39 downto dbits) <= (others => '0');

  rf136x32 : if (words <= 136) and (dbits = 32) generate
    id0 : rfss2_136x32cm2sw0 port map (
      wa(7 downto 0), gnd(7 downto 0), ra1(7 downto 0), gnd(7 downto 0),
      clk , clkn , din1(31 downto 0), gnd(31 downto 0), qq1(31 downto 0), vcc, 
      rfi.wren, gnd(0), gnd(0), gnd(0), vcc, vcc, gnd(0), gnd(0),gnd(0), gnd(0));
    id1 : rfss2_136x32cm2sw0 port map (
      wa(7 downto 0), gnd(7 downto 0), ra2(7 downto 0), gnd(7 downto 0),
      clk , clkn , din2(31 downto 0), gnd(31 downto 0), qq2(31 downto 0), vcc, 
      rfi.wren, gnd(0), gnd(0), gnd(0), vcc, vcc, gnd(0), gnd(0),gnd(0), gnd(0));
  end generate;

  rf168x32 : if (words <= 168) and (words > 136) and (dbits = 32) generate
    id0 : rfss2_168x32cm2sw0 port map (
      wa(7 downto 0), gnd(7 downto 0), ra1(7 downto 0), gnd(7 downto 0),
      clk , clkn , din1(31 downto 0), gnd(31 downto 0), qq1(31 downto 0), vcc, 
      rfi.wren, gnd(0), gnd(0), gnd(0), vcc, vcc, gnd(0), gnd(0),gnd(0), gnd(0));
    id1 : rfss2_168x32cm2sw0 port map (
      wa(7 downto 0), gnd(7 downto 0), ra2(7 downto 0), gnd(7 downto 0),
      clk , clkn , din2(31 downto 0), gnd(31 downto 0), qq2(31 downto 0), vcc, 
      rfi.wren, gnd(0), gnd(0), gnd(0), vcc, vcc, gnd(0), gnd(0),gnd(0), gnd(0));
  end generate;


  rfo.data1(dbits-1 downto 0) <= qq1(dbits-1 downto 0);
  rfo.data2(dbits-1 downto 0) <= qq2(dbits-1 downto 0);

end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tech_generic.all;
use work.tech_atc18_syn.all;
use work.leon_iface.all;

entity atc18_regfile_cp is
  generic ( 
    abits : integer := 4;
    dbits : integer := 32;
    words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end;

architecture rtl of atc18_regfile_cp is
signal din1, qq1, qq2 : std_logic_vector(39 downto 0);
signal wa : std_logic_vector(abits-1 downto 0);
signal vcc, gnd, wen : std_logic;
begin
  vcc <= '1'; gnd <= '0';
  rfo.data1(dbits-1 downto 0) <= qq1(dbits-1 downto 0);
  rfo.data2(dbits-1 downto 0) <= qq2(dbits-1 downto 0);

end;

------------------------------------------------------------------
-- mapping generic pads on tech pads ---------------------------------
------------------------------------------------------------------

-- input pad
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc18_syn.all;
entity atc18_inpad is port (pad : in std_logic; q : out std_logic); end; 
architecture syn of atc18_inpad is begin 
  i0 : pc33d00 port map (pad => pad, cin => q); 
end;

-- input schmitt pad
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc18_syn.all;
entity atc18_smpad is port (pad : in std_logic; q : out std_logic); end; 
architecture syn of atc18_smpad is begin 
  i0 : pc33d20 port map (pad => pad, cin => q); 
end;
