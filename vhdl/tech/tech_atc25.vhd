



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
-- Entity: 	tech_atc25
-- File:	tech_atc25.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Contains Atmel ATC25 specific pads and ram generators
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_atc25 is

-- sync ram generator

  component atc25_syncram
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

component atc25_regfile_iu
  generic (rftype : integer := 1; abits : integer := 8; dbits : integer := 32; words : integer := 128);
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
  end component;

component atc25_regfile_cp
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

component atc25_dpram
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

-- standard pads

  component atc25_inpad 
    port (pad : in std_logic; q : out std_logic);
  end component; 
  component atc25_smpad
    port (pad : in std_logic; q : out std_logic);
  end component;
  component atc25_outpad
    generic (drive : integer := 1);
    port (d : in  std_logic; pad : out  std_logic);
  end component; 
  component atc25_toutpad
    generic (drive : integer := 1);
    port (d, en : in  std_logic; pad : out  std_logic);
  end component; 
  component atc25_toutpadu
    generic (drive : integer := 1);
    port (d, en : in  std_logic; pad : out  std_logic);
  end component; 
  component atc25_iopad 
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component atc25_iopadu 
    generic (drive : integer := 1);
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component atc25_iodpad 
    generic (drive : integer := 1);
    port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component atc25_odpad
    generic (drive : integer := 1);
    port ( d : in std_logic; pad : out std_logic);
  end component;

-- PCI pads
  component atc25_pcioutpad port (d : in  std_logic; pad : out  std_logic); end component; 
  component atc25_pcitoutpad port (d, en : in  std_logic; pad : out  std_logic); end component; 
  component atc25_pciiopad 
    port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
  end component;
  component atc25_pciiodpad 
    port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
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
entity pt33d00 is port (pad : in std_logic; cin : out std_logic); end; 
architecture rtl of pt33d00 is begin cin <= to_x01(pad) after 1 ns; end;

-- input pad with pull-up
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33d00u is port (pad : inout std_logic; cin : out std_logic); end; 
architecture rtl of pt33d00u is 
begin cin <= to_x01(pad) after 1 ns; pad <= 'H'; end;

-- input schmitt pad
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33d20 is port (pad : in std_logic; cin : out std_logic); end; 
architecture rtl of pt33d20 is begin cin <= to_x01(pad) after 1 ns; end;

-- input schmitt pad with pull-up
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33d20u is port (pad : inout std_logic; cin : out std_logic); end; 
architecture rtl of pt33d20u is 
begin cin <= to_x01(pad) after 1 ns; pad <= 'H'; end;

-- output pads
library IEEE; use IEEE.std_logic_1164.all;
entity pt33o01 is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o01 is begin pad <= to_x01(i) after 2 ns; end;
library IEEE; use IEEE.std_logic_1164.all;
entity pt33o02 is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o02 is begin pad <= to_x01(i) after 2 ns; end;
library IEEE; use IEEE.std_logic_1164.all;
entity pt33o03 is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o03 is begin pad <= to_x01(i) after 2 ns; end;
library IEEE; use IEEE.std_logic_1164.all;
entity pt33o04 is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33o04 is begin pad <= to_x01(i) after 2 ns; end;

-- output tri-state pads with pull-up
library IEEE; use IEEE.std_logic_1164.all;
entity pt33t01u is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t01u is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 
library IEEE; use IEEE.std_logic_1164.all;
entity pt33t02u is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t02u is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 
library IEEE; use IEEE.std_logic_1164.all;
entity pt33t03u is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pt33t03u is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns; end; 

-- bidirectional pad
library IEEE; use IEEE.std_logic_1164.all;
entity pt33b01 is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b01 is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33b02 is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b02 is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33b03 is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b03 is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33b04 is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b04 is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

-- bidirectional pads with pull-up
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33b01u is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b01u is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33b02u is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b02u is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33b03u is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b03u is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;
library IEEE;
use IEEE.std_logic_1164.all;
entity pt33b04u is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pt33b04u is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'H' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;

-- PCI output pad
library IEEE; use IEEE.std_logic_1164.all;
entity pp33o01 is port (i : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pp33o01 is begin pad <= to_x01(i) after 2 ns; end;
-- PCI bidirectional pad
library IEEE; use IEEE.std_logic_1164.all;
entity pp33b015vt is
  port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
end; 
architecture rtl of pp33b015vt is
begin 
  pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns;
  cin <= to_x01(pad) after 1 ns;
end;
-- PCI output tri-state pad
library IEEE; use IEEE.std_logic_1164.all;
entity pp33t015vt is port (i, oen : in  std_logic; pad : out  std_logic); end; 
architecture rtl of pp33t015vt is
begin pad <= to_x01(i) after 2 ns when oen = '0' else 'Z' after 2 ns; end; 
------------------------------------------------------------------
-- behavioural ram models ----------------------------------------
------------------------------------------------------------------

-- clocked address + control, unlatched data

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity atc25_syncram_sim is
  generic (
    abits : integer := 10;
    dbits : integer := 8
  );
  port (
    a     : in std_logic_vector((abits -1) downto 0);
    ce    : in std_logic;
    i     : in std_logic_vector((dbits -1) downto 0);
    o     : out std_logic_vector((dbits -1) downto 0);
    csb   : in std_logic;
    web   : in std_logic;
    oeb   : in std_logic
  ); 
end;

architecture behavioral of atc25_syncram_sim is
  subtype word is std_logic_vector((dbits -1) downto 0);
  type mem is array(0 to (2**abits -1)) of word;
begin
  main : process(ce)
  variable memarr : mem;
  begin
    if rising_edge(ce) and (csb = '0') and not is_x(a) then
      if oeb = '0' then o <= memarr(conv_integer(unsigned(a)));
      else o <= (others => 'Z'); end if;
      if (web = '0') then memarr(conv_integer(unsigned(a))) := i; end if;
    end if;
  end process;
end behavioral;

--  Asynchronous 2-port ram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity atc25_2pram is
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    ra  : in std_logic_vector (abits -1 downto 0);
    wa  : in std_logic_vector (abits -1 downto 0);
    di  : in std_logic_vector (dbits -1 downto 0);
    do  : out std_logic_vector (dbits -1 downto 0);
    re  : in std_logic;
    oe  : in std_logic;
    we  : in std_logic
  );
end;

architecture behav of atc25_2pram is
signal d1  : std_logic_vector (dbits -1 downto 0);
signal ra1, wa1  : std_logic_vector (abits -1 downto 0);
begin
  d1 <= di after 1 ns; ra1 <= ra after 1 ns; wa1 <= wa after 1 ns;
  rp : process(wa1, ra1, d1, re, oe, we)
  subtype dword is std_logic_vector(dbits -1 downto 0);
  type dregtype is array (0 to words - 1) of DWord;
  variable rfd : dregtype;
  begin
    if is_x(we) or ((we = '0') and is_x(wa1)) then
      for i in 0 to words -1 loop rfd(i) := (others => 'X'); end loop;
    elsif (we = '0') then
      rfd(conv_integer(unsigned(wa1)) mod words) := d1; 
    end if;
    if (oe or re) = '0' then
      if not is_x (ra1) then
        do <= rfd(conv_integer(unsigned(ra1)) mod words);
      else do <= (others => 'X'); end if;
    else do <= (others => 'Z'); end if;
  end process;
end;

--  Asynchronous dual-port ram

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity atc25_dpram_sim is
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    a1   : in std_logic_vector (abits -1 downto 0);
    a2   : in std_logic_vector (abits -1 downto 0);
    di1  : in std_logic_vector (dbits -1 downto 0);
    di2  : in std_logic_vector (dbits -1 downto 0);
    do1  : out std_logic_vector (dbits -1 downto 0);
    do2  : out std_logic_vector (dbits -1 downto 0);
    re1  : in std_logic;
    re2  : in std_logic;
    oe1  : in std_logic;
    oe2  : in std_logic;
    we1  : in std_logic;
    we2  : in std_logic
  );
end;

architecture behav of atc25_dpram_sim is
signal d1, d2  : std_logic_vector (dbits -1 downto 0);
signal aa1, aa2  : std_logic_vector (abits -1 downto 0);
signal w1, w2, o1, o2  : std_logic;
begin
  d1 <= di1 after 1 ns; d2 <= di2 after 1 ns;
  aa1 <= a1 after 1 ns; aa2 <= a2 after 1 ns;
  w1 <= re1 or we1; w2 <= re2 or we2;
  o1 <= oe1 and we1 and not re1; o2 <= oe2 and we2 and not re2;
  rp : process(w1, w2, aa1, aa2, d1, d2, o1, o2)
  subtype dword is std_logic_vector(dbits -1 downto 0);
  type dregtype is array (0 to words - 1) of DWord;
  variable rfd : dregtype;
  begin
    if w1 = '0' then
      rfd(conv_integer(unsigned(aa1)) mod words) := d1; 
    end if;
    if w2 = '0' then
      rfd(conv_integer(unsigned(aa2)) mod words) := d2; 
    end if;
    if o1 = '1' then
      if not (is_x (aa1) or ((aa1 = aa2) and (w1 = '0'))) then -- no write-through !
        do1 <= rfd(conv_integer(unsigned(aa1)) mod words);
      else do1 <= (others => 'X'); end if;
    else do1 <= (others => 'Z'); end if;
    if o2 = '1' then
      if not (is_x (aa2) or ((aa2 = aa1) and (w2 = '0'))) then -- no write-through !
        do2 <= rfd(conv_integer(unsigned(aa2)) mod words);
      else do2 <= (others => 'X'); end if;
    else do2 <= (others => 'Z'); end if;
  end process;
end;

-- package with common ram simulation models
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_atc25_sim is
-- clocked address + enable, unlatched data and write
component atc25_syncram_sim
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    a     : in std_logic_vector((abits -1) downto 0);
    ce    : in std_logic;
    i     : in std_logic_vector((dbits -1) downto 0);
    o     : out std_logic_vector((dbits -1) downto 0);
    csb   : in std_logic;
    web   : in std_logic;
    oeb   : in std_logic
   ); 
end component;

--  asynchronous 2-port ram
component atc25_2pram
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    ra  : in std_logic_vector (abits -1 downto 0);
    wa  : in std_logic_vector (abits -1 downto 0);
    di  : in std_logic_vector (dbits -1 downto 0);
    do  : out std_logic_vector (dbits -1 downto 0);
    re  : in std_logic;
    oe  : in std_logic;
    we  : in std_logic
  );
end component;

component atc25_dpram_sim
  generic (
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 256
  );
  port (
    a1   : in std_logic_vector (abits -1 downto 0);
    a2   : in std_logic_vector (abits -1 downto 0);
    di1  : in std_logic_vector (dbits -1 downto 0);
    di2  : in std_logic_vector (dbits -1 downto 0);
    do1  : out std_logic_vector (dbits -1 downto 0);
    do2  : out std_logic_vector (dbits -1 downto 0);
    re1  : in std_logic;
    re2  : in std_logic;
    oe1  : in std_logic;
    oe2  : in std_logic;
    we1  : in std_logic;
    we2  : in std_logic
  );
end component;

end;

-- Address, control and data signals latched on rising ME. 
-- Write enable (WEN) active low.

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_256x26 is
  port (
    a     : in std_logic_vector(7 downto 0);
    i     : in std_logic_vector(25 downto 0);
    o     : out std_logic_vector(25 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;
architecture behavioral of RAM_256x26 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 8, dbits => 26)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_256x28 is
  port (
    a     : in std_logic_vector(7 downto 0);
    i     : in std_logic_vector(27 downto 0);
    o     : out std_logic_vector(27 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;
architecture behavioral of RAM_256x28 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 8, dbits => 28)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_256x30 is
  port (
    a     : in std_logic_vector(7 downto 0);
    i     : in std_logic_vector(29 downto 0);
    o     : out std_logic_vector(29 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;
architecture behavioral of RAM_256x30 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 8, dbits => 30)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_512x28 is
  port (
    a     : in std_logic_vector(8 downto 0);
    i     : in std_logic_vector(27 downto 0);
    o     : out std_logic_vector(27 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;
architecture behavioral of RAM_512x28 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 9, dbits => 28)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_512x30 is
  port (
    a     : in std_logic_vector(8 downto 0);
    i     : in std_logic_vector(29 downto 0);
    o     : out std_logic_vector(29 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;
architecture behavioral of RAM_512x30 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 9, dbits => 30)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_512x32 is
  port (
    a     : in std_logic_vector(8 downto 0);
    i     : in std_logic_vector(31 downto 0);
    o     : out std_logic_vector(31 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;
architecture behavioral of RAM_512x32 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 9, dbits => 32)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_1024x32 is
  port (
    a     : in std_logic_vector(9 downto 0);
    i     : in std_logic_vector(31 downto 0);
    o     : out std_logic_vector(31 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;

architecture behavioral of RAM_1024x32 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 10, dbits => 32)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

library ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM_2048x32 is
  port (
    a     : in std_logic_vector(10 downto 0);
    i     : in std_logic_vector(31 downto 0);
    o     : out std_logic_vector(31 downto 0);
    ce, csb, oeb, web : in std_logic
  );
end;
architecture behavioral of RAM_2048x32 is
begin
  syncram0 : atc25_syncram_sim
    generic map ( abits => 11, dbits => 32)
    port map ( a, ce, i, o, csb, web, oeb);
end behavioral;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM2P_16X32 is
 port (
    RA, WA  : in  std_logic_vector(3 downto 0);
    DI      : in  std_logic_vector(31 downto 0);
    DO      : out std_logic_vector(31 downto 0);
    REB, OEB, WEB : in std_logic );
end;
architecture behav of RAM2P_16X32 is
begin
    dp0 : atc25_2pram 
	  generic map (abits => 4, dbits => 32, words => 16)
	  port map (ra, wa, di, do, reb, oeb, web);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM2P_136X32 is
 port (
    RA, WA  : in  std_logic_vector(7 downto 0);
    DI      : in  std_logic_vector(31 downto 0);
    DO      : out std_logic_vector(31 downto 0);
    REB, OEB, WEB : in std_logic );
end;
architecture behav of RAM2P_136X32 is
begin
    dp0 : atc25_2pram 
	  generic map (abits => 8, dbits => 32, words => 136)
	  port map (ra, wa, di, do, reb, oeb, web);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity RAM2P_168X32 is
 port (
    RA, WA  : in  std_logic_vector(7 downto 0);
    DI      : in  std_logic_vector(31 downto 0);
    DO      : out std_logic_vector(31 downto 0);
    REB, OEB, WEB : in std_logic );
end;
architecture behav of RAM2P_168X32 is
begin
    dp0 : atc25_2pram 
	  generic map (abits => 8, dbits => 32, words => 168)
	  port map (ra, wa, di, do, reb, oeb, web);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity DPRAM_256x26 is
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(25 downto 0);
	I2     : IN std_logic_vector(25 downto 0);
        O1     : OUT std_logic_vector(25 downto 0);
        O2     : OUT std_logic_vector(25 downto 0));
end;
architecture behav of DPRAM_256x26 is
begin
    dp0 : atc25_dpram_sim 
	  generic map (abits => 8, dbits => 26, words => 256)
	  port map (a1, a2, i1, i2, o1, o2, csb1, csb2, oe1, oe2, web1, web2);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity DPRAM_256x28 is
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(27 downto 0);
	I2     : IN std_logic_vector(27 downto 0);
        O1     : OUT std_logic_vector(27 downto 0);
        O2     : OUT std_logic_vector(27 downto 0));
end;
architecture behav of DPRAM_256x28 is
begin
    dp0 : atc25_dpram_sim 
	  generic map (abits => 8, dbits => 28, words => 256)
	  port map (a1, a2, i1, i2, o1, o2, csb1, csb2, oe1, oe2, web1, web2);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity DPRAM_256x30 is
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(29 downto 0);
	I2     : IN std_logic_vector(29 downto 0);
        O1     : OUT std_logic_vector(29 downto 0);
        O2     : OUT std_logic_vector(29 downto 0));
end;
architecture behav of DPRAM_256x30 is
begin
    dp0 : atc25_dpram_sim 
	  generic map (abits => 8, dbits => 30, words => 256)
	  port map (a1, a2, i1, i2, o1, o2, csb1, csb2, oe1, oe2, web1, web2);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity DPRAM_256x32 is
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(31 downto 0);
	I2     : IN std_logic_vector(31 downto 0);
        O1     : OUT std_logic_vector(31 downto 0);
        O2     : OUT std_logic_vector(31 downto 0));
end;
architecture behav of DPRAM_256x32 is
begin
    dp0 : atc25_dpram_sim 
	  generic map (abits => 8, dbits => 32, words => 256)
	  port map (a1, a2, i1, i2, o1, o2, csb1, csb2, oe1, oe2, web1, web2);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity DPRAM_512x28 is
  port (A1     : IN std_logic_vector(8 DOWNTO 0);
        A2     : IN std_logic_vector(8 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(27 downto 0);
	I2     : IN std_logic_vector(27 downto 0);
        O1     : OUT std_logic_vector(27 downto 0);
        O2     : OUT std_logic_vector(27 downto 0));
end;
architecture behav of DPRAM_512x28 is
begin
    dp0 : atc25_dpram_sim 
	  generic map (abits => 9, dbits => 28, words => 512)
	  port map (a1, a2, i1, i2, o1, o2, csb1, csb2, oe1, oe2, web1, web2);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity DPRAM_512x30 is
  port (A1     : IN std_logic_vector(8 DOWNTO 0);
        A2     : IN std_logic_vector(8 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(29 downto 0);
	I2     : IN std_logic_vector(29 downto 0);
        O1     : OUT std_logic_vector(29 downto 0);
        O2     : OUT std_logic_vector(29 downto 0));
end;
architecture behav of DPRAM_512x30 is
begin
    dp0 : atc25_dpram_sim 
	  generic map (abits => 9, dbits => 30, words => 512)
	  port map (a1, a2, i1, i2, o1, o2, csb1, csb2, oe1, oe2, web1, web2);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_atc25_sim.all;
entity DPRAM_512x32 is
  port (A1     : IN std_logic_vector(8 DOWNTO 0);
        A2     : IN std_logic_vector(8 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(31 downto 0);
	I2     : IN std_logic_vector(31 downto 0);
        O1     : OUT std_logic_vector(31 downto 0);
        O2     : OUT std_logic_vector(31 downto 0));
end;
architecture behav of DPRAM_512x32 is
begin
    dp0 : atc25_dpram_sim 
	  generic map (abits => 9, dbits => 32, words => 512)
	  port map (a1, a2, i1, i2, o1, o2, csb1, csb2, oe1, oe2, web1, web2);
end;


-- pragma translate_on
-- component declarations from true tech library

LIBRARY ieee;
use IEEE.std_logic_1164.all;
package tech_atc25_syn is

  -- various two-port rams (used for regfile)
  component RAM2P_16X32 port (
      RA, WA   : in  std_logic_vector(3 downto 0);
      DI   : in  std_logic_vector(31 downto 0);
      DO   : out std_logic_vector(31 downto 0);
      REB, OEB, WEB  : in  std_logic );
  end component;
  component RAM2P_136X32 port (
      RA, WA   : in  std_logic_vector(7 downto 0);
      DI   : in  std_logic_vector(31 downto 0);
      DO   : out std_logic_vector(31 downto 0);
      REB, OEB, WEB  : in  std_logic );
  end component;
  component RAM2P_168X32 port (
      RA, WA   : in  std_logic_vector(7 downto 0);
      DI   : in  std_logic_vector(31 downto 0);
      DO   : out std_logic_vector(31 downto 0);
      REB, OEB, WEB  : in  std_logic );
  end component;

  -- various single-port synchronous ram cells (used for caches)
  component RAM_256x26 port (
    a     : in std_logic_vector(7 downto 0);
    i     : in std_logic_vector(25 downto 0);
    o     : out std_logic_vector(25 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;
  component RAM_256x28 port (
    a     : in std_logic_vector(7 downto 0);
    i     : in std_logic_vector(27 downto 0);
    o     : out std_logic_vector(27 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;
  component RAM_256x30 port (
    a     : in std_logic_vector(7 downto 0);
    i     : in std_logic_vector(29 downto 0);
    o     : out std_logic_vector(29 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;
  component RAM_512x28 port (
    a     : in std_logic_vector(8 downto 0);
    i     : in std_logic_vector(27 downto 0);
    o     : out std_logic_vector(27 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;
  component RAM_512x30 port (
    a     : in std_logic_vector(8 downto 0);
    i     : in std_logic_vector(29 downto 0);
    o     : out std_logic_vector(29 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;
  component RAM_512x32 port (
    a     : in std_logic_vector(8 downto 0);
    i     : in std_logic_vector(31 downto 0);
    o     : out std_logic_vector(31 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;
  component RAM_1024x32 port (
    a     : in std_logic_vector(9 downto 0);
    i     : in std_logic_vector(31 downto 0);
    o     : out std_logic_vector(31 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;
  component RAM_2048x32 port (
    a     : in std_logic_vector(10 downto 0);
    i     : in std_logic_vector(31 downto 0);
    o     : out std_logic_vector(31 downto 0);
    ce, csb, oeb, web : in std_logic);
  end component;

-- dpram for tags when snooping is enabled or DSU trace buffer
  component DPRAM_256x26
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(25 downto 0);
	I2     : IN std_logic_vector(25 downto 0);
        O1     : OUT std_logic_vector(25 downto 0);
        O2     : OUT std_logic_vector(25 downto 0));
  end component;
  component DPRAM_256x28
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(27 downto 0);
	I2     : IN std_logic_vector(27 downto 0);
        O1     : OUT std_logic_vector(27 downto 0);
        O2     : OUT std_logic_vector(27 downto 0));
  end component;
  component DPRAM_256x30
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(29 downto 0);
	I2     : IN std_logic_vector(29 downto 0);
        O1     : OUT std_logic_vector(29 downto 0);
        O2     : OUT std_logic_vector(29 downto 0));
  end component;
  component DPRAM_256x32
  port (A1     : IN std_logic_vector(7 DOWNTO 0);
        A2     : IN std_logic_vector(7 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(31 downto 0);
	I2     : IN std_logic_vector(31 downto 0);
        O1     : OUT std_logic_vector(31 downto 0);
        O2     : OUT std_logic_vector(31 downto 0));
  end component;
  component DPRAM_512x28
  port (A1     : IN std_logic_vector(8 DOWNTO 0);
        A2     : IN std_logic_vector(8 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(27 downto 0);
	I2     : IN std_logic_vector(27 downto 0);
        O1     : OUT std_logic_vector(27 downto 0);
        O2     : OUT std_logic_vector(27 downto 0));
  end component;
  component DPRAM_512x30
  port (A1     : IN std_logic_vector(8 DOWNTO 0);
        A2     : IN std_logic_vector(8 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(29 downto 0);
	I2     : IN std_logic_vector(29 downto 0);
        O1     : OUT std_logic_vector(29 downto 0);
        O2     : OUT std_logic_vector(29 downto 0));
  end component;
  component DPRAM_512x32
  port (A1     : IN std_logic_vector(8 DOWNTO 0);
        A2     : IN std_logic_vector(8 DOWNTO 0);
        CSB1   : IN std_logic;
        CSB2   : IN std_logic;
        WEB1   : IN std_logic;
        WEB2   : IN std_logic;
        OE1    : IN std_logic;
        OE2    : IN std_logic;
  	I1     : IN std_logic_vector(31 downto 0);
	I2     : IN std_logic_vector(31 downto 0);
        O1     : OUT std_logic_vector(31 downto 0);
        O2     : OUT std_logic_vector(31 downto 0));
  end component;

  -- input pad
  component pt33d00 port (pad : in std_logic; cin : out std_logic); end component; 
  -- input pad with pull-up
  component pt33d00u port (pad : in std_logic; cin : out std_logic); end component; 
  -- schmitt input pad
  component pt33d20 port (pad : in std_logic; cin : out std_logic); end component; 
  -- schmitt input pad with pull-up
  component pt33d20u port (pad : inout std_logic; cin : out std_logic); end component; 
  -- output pads
  component pt33o01 port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o02 port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o03 port (i : in std_logic; pad : out std_logic); end component; 
  component pt33o04 port (i : in std_logic; pad : out std_logic); end component; 
  -- tri-state output pads with pull-up
  component pt33t01u port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t02u port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t03u port (i, oen : in std_logic; pad : out std_logic); end component; 
  component pt33t04u port (i, oen : in std_logic; pad : out std_logic); end component; 
  -- bidirectional pads
  component pt33b01
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b02
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b03
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b04
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  -- bidirectional pads with pull-up
  component pt33b01u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b02u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b03u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pt33b04u
    port (i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
--PCI pads
  component pp33o01 
    port (i : in  std_logic; pad : out  std_logic);
  end component; 
  component pp33b015vt 
    port ( i, oen : in std_logic; cin : out std_logic; pad : inout std_logic);
  end component; 
  component pp33t015vt 
    port (i, oen : in  std_logic; pad : out  std_logic);
  end component;
end;
------------------------------------------------------------------
-- sync ram generator --------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_atc25_syn.all;
use work.leon_iface.all;


entity atc25_syncram is
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

architecture rtl of atc25_syncram is
  signal wen, wel, gnd   : std_logic;
  signal d, q : std_logic_vector(35 downto 0);
  signal a : std_logic_vector(17 downto 0);
  constant synopsys_bug : std_logic_vector(37 downto 0) := (others => '0');
begin


  lat : process(clk, datain, write)
  begin 
    if clk = '0' then d(dbits -1 downto 0) <= datain; wel <= write; end if;
  end process;

  gnd <= '0';
  wen <= not wel;
  a(abits -1 downto 0) <= address; 
  a(abits+1 downto abits) <= synopsys_bug(abits+1 downto abits);
  d(dbits+1 downto dbits) <= synopsys_bug(dbits+1 downto dbits);
  dataout <= q(dbits -1 downto 0);

  a8d26 : if (abits <= 8) and (dbits <= 26) generate
    id0 : RAM_256x26 

	  port map (a(7 downto 0), d(25 downto 0), q(25 downto 0), clk, gnd, gnd, wen);

  end generate;
  a8d28 : if (abits <= 8) and (dbits > 26) and (dbits <= 28) generate
    id0 : RAM_256x28 

	  port map (a(7 downto 0), d(27 downto 0), q(27 downto 0), clk, gnd, gnd, wen);

  end generate;
  a8d30 : if (abits <= 8) and (dbits > 28) and (dbits <= 30) generate
    id0 : RAM_256x30 

	  port map (a(7 downto 0), d(29 downto 0), q(29 downto 0), clk, gnd, gnd, wen);

  end generate;
  a9d28 : if (abits = 9) and (dbits <= 28) generate
    id0 : RAM_512x28 

	  port map (a(8 downto 0), d(27 downto 0), q(27 downto 0), clk, gnd, gnd, wen);

  end generate;
  a9d30 : if (abits = 9) and (dbits > 28) and (dbits <= 30) generate
    id0 : RAM_512x30 

	  port map (a(8 downto 0), d(29 downto 0), q(29 downto 0), clk, gnd, gnd, wen);

  end generate;
  a9d32 : if ((abits = 9) and (dbits > 29) and (dbits <= 32)) or
               ((abits <= 9) and (dbits = 32)) generate
    id0 : RAM_512X32 

	  port map (a(8 downto 0), d(31 downto 0), q(31 downto 0), clk, gnd, gnd, wen);

  end generate;
  a10d32 : if ((abits = 10) and (dbits <= 32)) generate
    id0 : RAM_1024X32 

	  port map (a(9 downto 0), d(31 downto 0), q(31 downto 0), clk, gnd, gnd, wen);

  end generate;
  a11d32 : if (abits = 11) and (dbits <= 32) generate
    id0 : RAM_2048X32 

	  port map (a(10 downto 0), d(31 downto 0), q(31 downto 0), clk, gnd, gnd, wen);

  end generate;

end rtl;

------------------------------------------------------------------
-- sync dpram generator --------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_atc25_syn.all;
use work.leon_iface.all;


entity atc25_dpram is
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
architecture rtl of atc25_dpram is
  signal web1, web2, csb1, csb2, vcc : std_logic;
  signal web1n, web2n, csb1n, csb2n  : std_logic;
  signal web1nc, web2nc : std_logic;
  signal i1, i2, a1, a2, i11, i22, a11, a22, o1, o2 : std_logic_vector(35 downto 0);
begin

  vcc <= '1';
  i11(35 downto dbits) <= (others => '0');
  i22(35 downto dbits) <= (others => '0');
  a11(35 downto abits) <= (others => '0');
  a22(35 downto abits) <= (others => '0');
  -- add delay or address/data will not be valid during write
  a1 <= a11; a2 <= a22; i1 <= i11; i2 <= i22;
  csb1n <= not enable1; csb2n <= not enable2;
  web1n <= not write1;  web2n <= not write2;

  web1nc <= web1 or clk; web2nc <= web2 or clk;
  r : process (clk)
  begin
    if rising_edge(clk) then
      a11(abits-1 downto 0) <= address1; 
      a22(abits-1 downto 0) <= address2;
      i11(dbits-1 downto 0) <= datain1;
      i22(dbits-1 downto 0) <= datain2;
      csb1 <= csb1n; csb2 <= csb2n;
      web1 <= web1n; web2 <= web2n;
    end if;
  end process;

  dp256x26 : if (abits <= 8) and (dbits <= 26) generate
    dp0 : DPRAM_256x26 port map (
	a1(7 downto 0), a2(7 downto 0), 
	csb1, csb2, web1nc, web2nc, vcc, web2, 
	i1(25 downto 0), i2(25 downto 0), 
	o1(25 downto 0), o2(25 downto 0));
  end generate;

  dp256x28 : if (abits <= 8) and (dbits <= 28) and (dbits >= 27) generate
    dp0 : DPRAM_256x28 port map (
	a1(7 downto 0), a2(7 downto 0), 
	csb1, csb2, web1nc, web2nc, vcc, web2, 
	i1(27 downto 0), i2(27 downto 0), 
	o1(27 downto 0), o2(27 downto 0));
  end generate;

  dp256x30 : if (abits <= 8) and (dbits <= 30) and (dbits >= 29) generate
    dp0 : DPRAM_256x30 port map (
	a1(7 downto 0), a2(7 downto 0), 
	csb1, csb2, web1nc, web2nc, vcc, web2, 
	i1(29 downto 0), i2(29 downto 0), 
	o1(29 downto 0), o2(29 downto 0));
  end generate;

  dp256x32 : if (abits <= 8) and (dbits <= 32) and (dbits >= 31) generate
    dp0 : DPRAM_256x32 port map (
	a1(7 downto 0), a2(7 downto 0), 
	csb1, csb2, web1nc, web2nc, vcc, web2, 
	i1(31 downto 0), i2(31 downto 0), 
	o1(31 downto 0), o2(31 downto 0));
  end generate;

  dp512x28 : if (abits = 9) and (dbits <= 28) generate
    dp0 : DPRAM_512x28 port map (
	a1(8 downto 0), a2(8 downto 0), 
	csb1, csb2, web1nc, web2nc, vcc, web2, 
	i1(27 downto 0), i2(27 downto 0), 
	o1(27 downto 0), o2(27 downto 0));
  end generate;

  dp512x30 : if (abits = 9) and (dbits <= 30) and (dbits >= 29) generate
    dp0 : DPRAM_512x30 port map (
	a1(8 downto 0), a2(8 downto 0), 
	csb1, csb2, web1nc, web2nc, vcc, web2, 
	i1(29 downto 0), i2(29 downto 0), 
	o1(29 downto 0), o2(29 downto 0));
  end generate;

  dp512x32 : if (abits = 9) and (dbits <= 32) and (dbits >= 31) generate
    dp0 : DPRAM_512x32 port map (
	a1(8 downto 0), a2(8 downto 0), 
	csb1, csb2, web1nc, web2nc, vcc, web2, 
	i1(31 downto 0), i2(31 downto 0), 
	o1(31 downto 0), o2(31 downto 0));
  end generate;

  dataout1 <= o1(dbits-1 downto 0);
  dataout2 <= o2(dbits-1 downto 0);

end;

------------------------------------------------------------------
-- regfile generator  --------------------------------------------
------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tech_generic.all;
use work.tech_atc25_syn.all;
use work.leon_iface.all;
use work.leon_config.all;

entity atc25_regfile_iu is
  generic ( 
    rftype : integer := 1;
    abits : integer := 8;
    dbits : integer := 32;
    words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in clk_type;
    clkn     : in clk_type;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
end;

architecture rtl of atc25_regfile_iu is
signal din1, din2, qq1, qq2 : std_logic_vector(39 downto 0);
signal vcc, gnd, we, wen, ren1, ren2 : std_logic;
signal ra1, ra2, wa : std_logic_vector(12 downto 0);
begin

  rf2 : if rftype = 2 generate

      r : process (clkn, rfi) begin

        if clkn = '1' then
          din2(dbits-1 downto 0) <= rfi.wrdata;

          din1(dbits-1 downto 0) <= rfi.wrdata;
          wa(abits-1 downto 0)  <= rfi.wraddr(abits -1 downto 0);
	  we <= rfi.wren;
        end if;
      end process;

    wen <= not (clk and we);

  end generate;
  rf1 : if rftype = 1 generate
    wa(abits-1 downto 0)  <= rfi.wraddr(abits -1 downto 0);
    din1(dbits-1 downto 0) <= rfi.wrdata;
    din2(dbits-1 downto 0) <= rfi.wrdata;

    wen <= clk or not rfi.wren;

  end generate;

  vcc <= '1'; gnd <= '0'; ren1 <= not rfi.ren1; ren2 <= not rfi.ren2;
  ra1(12 downto abits)  <= (others => '0');
  ra2(12 downto abits)  <= (others => '0');
  ra1(abits-1 downto 0) <= rfi.rd1addr(abits -1 downto 0);
  ra2(abits-1 downto 0) <= rfi.rd2addr(abits -1 downto 0);

  wa(12 downto abits)   <= (others => '0');
  din1(39 downto dbits) <= (others => '0');
  din2(39 downto dbits) <= (others => '0');

  dp136x32 : if (words = 136) and (dbits = 32) generate
    u0: RAM2P_136X32
	port map (ra1(7 downto 0), wa(7 downto 0), din1(31 downto 0), 
		  qq1(31 downto 0), ren1, gnd, wen);
    u1: RAM2P_136X32
	port map (ra2(7 downto 0), wa(7 downto 0), din2(31 downto 0), 
		  qq2(31 downto 0), ren2, gnd, wen);
  end generate;

  dp168x32 : if (words = 168) and (dbits = 32) generate
    u0: RAM2P_168X32
	port map (ra1(7 downto 0), wa(7 downto 0), din1(31 downto 0), 
		  qq1(31 downto 0), ren1, gnd, wen);
    u1: RAM2P_168X32
	port map (ra2(7 downto 0), wa(7 downto 0), din2(31 downto 0), 
		  qq2(31 downto 0), ren2, gnd, wen);
  end generate;


  rfo.data1(dbits-1 downto 0) <= qq1(dbits-1 downto 0);
  rfo.data2(dbits-1 downto 0) <= qq2(dbits-1 downto 0);

end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tech_generic.all;
use work.tech_atc25_syn.all;
use work.leon_iface.all;

entity atc25_regfile_cp is
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

architecture rtl of atc25_regfile_cp is
type reg_type is record
  raddr1  : std_logic_vector(abits-1 downto 0);
  raddr2  : std_logic_vector(abits-1 downto 0);
  wraddr  : std_logic_vector(abits-1 downto 0);
  wrdata  : std_logic_vector(dbits-1 downto 0);
  wren    : std_logic;
end record;
signal r, rin : reg_type;

signal din1, qq1, qq2 : std_logic_vector(39 downto 0);
signal wa : std_logic_vector(abits-1 downto 0);
signal vcc, gnd, wen : std_logic;
begin
  vcc <= '1'; gnd <= '0';

  wen <= clk or not r.wren;

  din1(dbits-1 downto 0) <= r.wrdata;
  din1(39 downto dbits) <= (others => '0');
  wa <= r.wraddr;

  dp16x32 : if (words = 16) and (dbits = 32) generate
    u0: RAM2P_16X32
	port map (r.raddr1(3 downto 0), wa(3 downto 0), din1(dbits-1 downto 0), 
		  qq1(31 downto 0), gnd, gnd, wen);
    u1: RAM2P_16X32
	port map (r.raddr2(3 downto 0), wa(3 downto 0), din1(dbits-1 downto 0), 
		  qq2(31 downto 0), gnd, gnd, wen);
  end generate;

    adr_reg : process(clk)
    begin

      if rising_edge(clk) then 

	r.raddr1 <= rfi.rd1addr(abits -1 downto 0);
	r.raddr2 <= rfi.rd2addr(abits -1 downto 0);
	r.wraddr <= rfi.wraddr(abits -1 downto 0);
	r.wrdata <= rfi.wrdata;
	r.wren <= rfi.wren; 
      end if;
    end process;

  rfo.data1(dbits-1 downto 0) <= qq1(dbits-1 downto 0);
  rfo.data2(dbits-1 downto 0) <= qq2(dbits-1 downto 0);

end;

------------------------------------------------------------------
-- mapping generic pads on tech pads ---------------------------------
------------------------------------------------------------------

-- input pad
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_inpad is port (pad : in std_logic; q : out std_logic); end; 
architecture syn of atc25_inpad is begin 
  i0 : pt33d00 port map (pad => pad, cin => q); 
end;

-- input schmitt pad
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_smpad is port (pad : in std_logic; q : out std_logic); end; 
architecture syn of atc25_smpad is begin 
  i0 : pt33d20 port map (pad => pad, cin => q); 
end;

-- output pad
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_outpad is 
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
end; 
architecture syn of atc25_outpad is begin 
  d1 : if drive = 1 generate
    i0 : pt33o01 port map (pad => pad, i => d);
  end generate;
  d2 : if drive = 2 generate
    i0 : pt33o02 port map (pad => pad, i => d);
  end generate;
  d3 : if drive > 2 generate
    i0 : pt33o03 port map (pad => pad, i => d);
  end generate;
end; 

-- tri-state output pads with pull-up, oen active low
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_toutpadu is 
  generic (drive : integer := 1);
  port (d, en : in  std_logic; pad : out  std_logic);
end; 
architecture syn of atc25_toutpadu is 
begin 
  d1 : if drive = 1 generate
    i0 : pt33t01u port map (pad => pad, i => d, oen => en);
  end generate;
  d2 : if drive = 2 generate
    i0 : pt33t02u port map (pad => pad, i => d, oen => en);
  end generate;
  d3 : if drive > 3 generate
    i0 : pt33t03u port map (pad => pad, i => d, oen => en);
  end generate;
end;

-- bidirectional pad, oen active low
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_iopad is
  generic (drive : integer := 1);
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of atc25_iopad is 
begin 
  d1 : if drive = 1 generate
    i0 : pt33b01 port map (pad => pad, i => d, oen => en, cin => q);
  end generate;
  d2 : if drive = 2 generate
    i0 : pt33b02 port map (pad => pad, i => d, oen => en, cin => q);
  end generate;
  d3 : if drive > 2 generate
    i0 : pt33b03 port map (pad => pad, i => d, oen => en, cin => q);
  end generate;
end;

-- bidirectional pad with pull-up, oen active low
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_iopadu is
  generic (drive : integer := 1);
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of atc25_iopadu is 
begin 
  d1 : if drive = 1 generate
    i0 : pt33b01u port map (pad => pad, i => d, oen => en, cin => q);
  end generate;
  d2 : if drive = 2 generate
    i0 : pt33b02u port map (pad => pad, i => d, oen => en, cin => q);
  end generate;
  d3 : if drive > 2 generate
    i0 : pt33b03u port map (pad => pad, i => d, oen => en, cin => q);
  end generate;
end;

-- bidirectional pad with open-drain
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_iodpad is
  generic (drive : integer := 1);
  port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of atc25_iodpad is 
signal gnd : std_logic;
begin 
  gnd <= '0';
  d1 : if drive = 1 generate
    i0 : pt33b01u port map (pad => pad, i => gnd, oen => d, cin => q);
  end generate;
  d2 : if drive = 2 generate
    i0 : pt33b02u port map (pad => pad, i => gnd, oen => d, cin => q);
  end generate;
  d3 : if drive > 2 generate
    i0 : pt33b03u port map (pad => pad, i => gnd, oen => d, cin => q);
  end generate;
end;

-- output pad with open-drain
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_odpad is
  generic (drive : integer := 1);
  port (d : in std_logic; pad : out std_logic);
end;
architecture syn of atc25_odpad is 
signal gnd : std_logic;
begin 
  gnd <= '0';
  d1 : if drive = 1 generate
    i0 : pt33t01u port map (pad => pad, i => gnd, oen => d);
  end generate;
  d2 : if drive = 2 generate
    i0 : pt33t02u port map (pad => pad, i => gnd, oen => d);
  end generate;
  d3 : if drive > 2 generate
    i0 : pt33t03u port map (pad => pad, i => gnd, oen => d);
  end generate;
end;

-- PCI output pad
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_pcioutpad is port (d : in std_logic; pad : out std_logic); end; 
architecture syn of atc25_pcioutpad is begin 
  i0 : pp33o01 port map (pad => pad, i => d);
end;
-- PCI tristate output pad
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_pcitoutpad is 
port (d, en : in  std_logic; pad : out  std_logic); end; 
architecture syn of atc25_pcitoutpad is 
begin 
  i0 : pp33t015vt port map (pad => pad, i => d, oen => en);
end;
-- PCI bidirectional pad, oen active low
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_pciiopad is
  port ( d, en : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of atc25_pciiopad is 
begin 
  i0 : pp33b015vt port map (pad => pad, i => d, oen => en, cin => q);
end;
-- bidirectional pad with open-drain
library IEEE; use IEEE.std_logic_1164.all; use work.tech_atc25_syn.all;
entity atc25_pciiodpad is
  port ( d : in std_logic; q : out std_logic; pad : inout std_logic);
end;
architecture syn of atc25_pciiodpad is 
signal gnd : std_logic;
begin 
  gnd <= '0';
  i0 : pp33b015vt port map (pad => pad, i => gnd, oen => d, cin => q);
end;

