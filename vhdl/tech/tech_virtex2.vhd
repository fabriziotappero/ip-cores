



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 2003 Gaisler Research
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.


-----------------------------------------------------------------------------
-- Package: 	tech_virtex2
-- File:	tech_virtex2.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Author:	Richard Pender - Pender Electronic Design
-- Description:	Xilinx Virtex2 specific regfile and cache ram generators
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;

package tech_virtex2 is

component virtex2_syncram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector((abits -1) downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_logic;
    write    : in std_logic
   ); 
end component;

-- three-port regfile with sync read, sync write
  component virtex2_regfile
  generic ( 
    rftype : integer := 1;
    abits : integer := 8; dbits : integer := 32; words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    clkn     : in std_logic;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
  end component;

  component virtex2_regfile_cp
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
  end component;

component virtex2_dpram
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address1 : in std_logic_vector((abits -1) downto 0);
    clk1     : in std_logic;
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_logic;
    write1   : in std_logic;
    address2 : in std_logic_vector((abits -1) downto 0);
    clk2     : in std_logic;
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_logic;
    write2   : in std_logic
   ); 
end component;

component virtex2_clkgen
  generic ( clk_mul : integer := 1 ; clk_div : integer := 1);
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type
  );
end component; 

end;

-- package with virtex select-ram component declarations
library IEEE;
use IEEE.std_logic_1164.all;

package virtex2_complib is
  component RAMB16_S1
  port (
    DO : out std_logic_vector (0 downto 0);
    ADDR : in std_logic_vector (13 downto 0);
    DI : in std_logic_vector (0 downto 0);
    EN : in std_logic;
    CLK : in std_logic;
    WE : in std_logic;
    SSR : in std_logic
  );
end component;

component RAMB16_S2
 port (
   DO : out std_logic_vector (1 downto 0);
   ADDR : in std_logic_vector (12 downto 0);
   DI : in std_logic_vector (1 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end component;

component RAMB16_S4
 port (
   DO : out std_logic_vector (3 downto 0);
   ADDR : in std_logic_vector (11 downto 0);
   DI : in std_logic_vector (3 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end component;

component RAMB16_S9
 port (
   DO : out std_logic_vector (7 downto 0);
   DOP : out std_logic_vector (0 downto 0);
   ADDR : in std_logic_vector (10 downto 0);
   DI : in std_logic_vector (7 downto 0);
   DIP : in std_logic_vector (0 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end component;

  component RAMB16_S18
  port (
    DO : out std_logic_vector (15 downto 0);
    DOP : out std_logic_vector (1 downto 0);
    ADDR : in std_logic_vector (9 downto 0);
    DI : in std_logic_vector (15 downto 0);
    DIP : in std_logic_vector (1 downto 0);
    EN : in std_logic;
    CLK : in std_logic;
    WE : in std_logic;
    SSR : in std_logic
  );
end component;

component RAMB16_S36
 port (
   DO : out std_logic_vector (31 downto 0);
   DOP : out std_logic_vector (3 downto 0);
   ADDR : in std_logic_vector (8 downto 0);
   DI : in std_logic_vector (31 downto 0);
   DIP : in std_logic_vector (3 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end component;

component RAMB16_S4_S4
 port (
   DOA : out std_logic_vector (3 downto 0);
   DOB : out std_logic_vector (3 downto 0);
   ADDRA : in std_logic_vector (11 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (3 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (11 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (3 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
 );
end component;

component RAMB16_S9_S9
 port (
   DOA : out std_logic_vector (7 downto 0);
   DOPA : out std_logic_vector (0 downto 0);
   DOB : out std_logic_vector (7 downto 0);
   DOPB : out std_logic_vector (0 downto 0);
   ADDRA : in std_logic_vector (10 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (7 downto 0);
   DIPA : in std_logic_vector (0 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (10 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (7 downto 0);
   DIPB : in std_logic_vector (0 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
 );
end component;

component RAMB16_S18_S18
 port (
   DOA : out std_logic_vector (15 downto 0);
   DOPA : out std_logic_vector (1 downto 0);
   DOB : out std_logic_vector (15 downto 0);
   DOPB : out std_logic_vector (1 downto 0);
   ADDRA : in std_logic_vector (9 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (15 downto 0);
   DIPA : in std_logic_vector (1 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (9 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (15 downto 0);
   DIPB : in std_logic_vector (1 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
 );
end component;

component RAMB16_S36_S36
 port (
   DOA : out std_logic_vector (31 downto 0);
   DOPA : out std_logic_vector (3 downto 0);
   DOB : out std_logic_vector (31 downto 0);
   DOPB : out std_logic_vector (3 downto 0);
   ADDRA : in std_logic_vector (8 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (31 downto 0);
   DIPA : in std_logic_vector (3 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (8 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (31 downto 0);
   DIPB : in std_logic_vector (3 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
 );
end component;

-- pragma translate_off
component ram16_sx_sx 
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
   DOA : out std_logic_vector (dbits-1 downto 0);
   DOB : out std_logic_vector (dbits-1 downto 0);
   ADDRA : in std_logic_vector (abits-1 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (dbits-1 downto 0);
   ENA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (abits-1 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (dbits-1 downto 0);
   ENB : in std_logic;
   WEB : in std_logic
  );
end component;
-- pragma translate_on
end;
-- pragma translate_off

-- simulation models for select-rams

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_generic.all;

entity RAMB16_S1 is
 port (
   DO : out std_logic_vector (0 downto 0);
   ADDR : in std_logic_vector (13 downto 0);
   DI : in std_logic_vector (0 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end;
architecture behav of RAMB16_S1 is
begin x : generic_syncram generic map (14,1)
          port map (addr, clk, di, do, en, we); 
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_generic.all;

entity RAMB16_S2 is
 port (
   DO : out std_logic_vector (1 downto 0);
   ADDR : in std_logic_vector (12 downto 0);
   DI : in std_logic_vector (1 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end;
architecture behav of RAMB16_S2 is
begin x : generic_syncram generic map (13,2)
          port map (addr, clk, di, do, en, we); 
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_generic.all;

entity RAMB16_S4 is
 port (
   DO : out std_logic_vector (3 downto 0);
   ADDR : in std_logic_vector (11 downto 0);
   DI : in std_logic_vector (3 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end;
architecture behav of RAMB16_S4 is
begin x : generic_syncram generic map (12,4)
          port map (addr, clk, di, do, en, we); 
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_generic.all;

entity RAMB16_S9 is
 port (
   DO : out std_logic_vector (7 downto 0);
   DOP : out std_logic_vector (0 downto 0);
   ADDR : in std_logic_vector (10 downto 0);
   DI : in std_logic_vector (7 downto 0);
   DIP : in std_logic_vector (0 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end;
architecture behav of RAMB16_S9 is
signal dix, dox : std_logic_vector (8 downto 0);
begin x : generic_syncram generic map (11,9)
          port map (addr, clk, dix, dox, en, we); 
  dix <= dip & di; dop <= dox(8 downto 8); do <= dox(7 downto 0);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_generic.all;

entity RAMB16_S18 is
 port (
   DO : out std_logic_vector (15 downto 0);
   DOP : out std_logic_vector (1 downto 0);
   ADDR : in std_logic_vector (9 downto 0);
   DI : in std_logic_vector (15 downto 0);
   DIP : in std_logic_vector (1 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end;
architecture behav of RAMB16_S18 is
signal dix, dox : std_logic_vector (17 downto 0);
begin x : generic_syncram generic map (10,18)
          port map (addr, clk, dix, dox, en, we); 
  dix <= dip & di; dop <= dox(17 downto 16); do <= dox(15 downto 0);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.tech_generic.all;

entity RAMB16_S36 is
 port (
   DO : out std_logic_vector (31 downto 0);
   DOP : out std_logic_vector (3 downto 0);
   ADDR : in std_logic_vector (8 downto 0);
   DI : in std_logic_vector (31 downto 0);
   DIP : in std_logic_vector (3 downto 0);
   EN : in std_logic;
   CLK : in std_logic;
   WE : in std_logic;
   SSR : in std_logic
 );
end;
architecture behav of RAMB16_S36 is
signal dix, dox : std_logic_vector (35 downto 0);
begin x : generic_syncram generic map (9, 36)
          port map (addr, clk, dix, dox, en, we); 
  dix <= dip & di; dop <= dox(35 downto 32); do <= dox(31 downto 0);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity ram16_sx_sx is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
   DOA : out std_logic_vector (dbits-1 downto 0);
   DOB : out std_logic_vector (dbits-1 downto 0);
   ADDRA : in std_logic_vector (abits-1 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (dbits-1 downto 0);
   ENA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (abits-1 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (dbits-1 downto 0);
   ENB : in std_logic;
   WEB : in std_logic
  );
end;
architecture behav of ram16_sx_sx is
begin
  rp : process(clka, clkb)
  subtype dword is std_logic_vector(dbits-1 downto 0);
  type dregtype is array (0 to 2**abits -1) of DWord;
  variable rfd : dregtype;
  begin
    if rising_edge(clka) and not is_x (addra) then 
      if ena = '1' then
        doa <= rfd(conv_integer(unsigned(addra)));
        if wea = '1' then rfd(conv_integer(unsigned(addra))) := dia; end if;
      end if;
    end if;
    if rising_edge(clkb) and not is_x (addrb) then 
      if enb = '1' then
        dob <= rfd(conv_integer(unsigned(addrb)));
        if web = '1' then rfd(conv_integer(unsigned(addrb))) := dib; end if;
      end if;
    end if;
  end process;
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.virtex2_complib.all;

entity RAMB16_S4_S4 is
  port (
   DOA : out std_logic_vector (3 downto 0);
   DOB : out std_logic_vector (3 downto 0);
   ADDRA : in std_logic_vector (11 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (3 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (11 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (3 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
  );
end;
architecture behav of RAMB16_S4_S4 is
begin 
  x : ram16_sx_sx generic map (12, 4)
  port map (doa, dob, addra, clka, dia, ena, wea, addrb, clkb, dib, enb, web); 
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.virtex2_complib.all;

entity RAMB16_S9_S9 is
  port (
   DOA : out std_logic_vector (7 downto 0);
   DOPA : out std_logic_vector (0 downto 0);
   DOB : out std_logic_vector (7 downto 0);
   DOPB : out std_logic_vector (0 downto 0);
   ADDRA : in std_logic_vector (10 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (7 downto 0);
   DIPA : in std_logic_vector (0 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (10 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (7 downto 0);
   DIPB : in std_logic_vector (0 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
  );
end;
architecture behav of RAMB16_S9_S9 is
signal diax, doax, dibx, dobx : std_logic_vector (8 downto 0);
begin 
  x : ram16_sx_sx generic map (11, 9)
  port map (doax, dobx, addra, clka, diax, ena, wea, addrb, clkb, dibx, enb, web); 
  diax <= dipa & dia; dopa <= doax(8 downto 8); doa <= doax(7 downto 0);
  dibx <= dipb & dib; dopb <= dobx(8 downto 8); dob <= dobx(7 downto 0);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.virtex2_complib.all;

entity RAMB16_S18_S18 is
  port (
   DOA : out std_logic_vector (15 downto 0);
   DOPA : out std_logic_vector (1 downto 0);
   DOB : out std_logic_vector (15 downto 0);
   DOPB : out std_logic_vector (1 downto 0);
   ADDRA : in std_logic_vector (9 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (15 downto 0);
   DIPA : in std_logic_vector (1 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (9 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (15 downto 0);
   DIPB : in std_logic_vector (1 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
  );
end;
architecture behav of RAMB16_S18_S18 is
signal diax, doax, dibx, dobx : std_logic_vector (17 downto 0);
begin 
  x : ram16_sx_sx generic map (10, 18)
  port map (doax, dobx, addra, clka, diax, ena, wea, addrb, clkb, dibx, enb, web); 
  diax <= dipa & dia; dopa <= doax(17 downto 16); doa <= doax(15 downto 0);
  dibx <= dipb & dib; dopb <= dobx(17 downto 16); dob <= dobx(15 downto 0);
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.virtex2_complib.all;

entity RAMB16_S36_S36 is
  port (
   DOA : out std_logic_vector (31 downto 0);
   DOPA : out std_logic_vector (3 downto 0);
   DOB : out std_logic_vector (31 downto 0);
   DOPB : out std_logic_vector (3 downto 0);
   ADDRA : in std_logic_vector (8 downto 0);
   CLKA : in std_logic;
   DIA : in std_logic_vector (31 downto 0);
   DIPA : in std_logic_vector (3 downto 0);
   ENA : in std_logic;
   SSRA : in std_logic;
   WEA : in std_logic;
   ADDRB : in std_logic_vector (8 downto 0);
   CLKB : in std_logic;
   DIB : in std_logic_vector (31 downto 0);
   DIPB : in std_logic_vector (3 downto 0);
   ENB : in std_logic;
   SSRB : in std_logic;
   WEB : in std_logic
  );
end;
architecture behav of RAMB16_S36_S36 is
signal diax, doax, dibx, dobx : std_logic_vector (35 downto 0);
begin 
  x : ram16_sx_sx generic map (9, 36)
  port map (doax, dobx, addra, clka, diax, ena, wea, addrb, clkb, dibx, enb, web); 
  diax <= dipa & dia; dopa <= doax(35 downto 32); doa <= doax(31 downto 0);
  dibx <= dipb & dib; dopb <= dobx(35 downto 32); dob <= dobx(31 downto 0);
end;

-- pragma translate_on
-- parametrisable sync ram generator using virtex2 select rams

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.virtex2_complib.all;

entity virtex2_syncram is
  generic ( abits : integer := 9; dbits : integer := 32);
  port (
    address : in std_logic_vector (abits -1 downto 0);
    clk     : in std_logic;
    datain  : in std_logic_vector (dbits -1 downto 0);
    dataout : out std_logic_vector (dbits -1 downto 0);
    enable  : in std_logic;
    write   : in std_logic
  );
end;

architecture behav of virtex2_syncram is
signal gnd : std_logic;
signal do, di : std_logic_vector(129 downto 0);
signal xa, ya : std_logic_vector(19 downto 0);
begin
  gnd <= '0';
  dataout <= do(dbits-1 downto 0);
  di(dbits-1 downto 0) <= datain; di(129 downto dbits) <= (others => '0');
  xa(abits-1 downto 0) <= address; xa(19 downto abits) <= (others => '0');
  ya(abits-1 downto 0) <= address; ya(19 downto abits) <= (others => '1');

  a9 : if (abits <= 9) generate
    x : for i in 0 to ((dbits-1)/36) generate
      r : RAMB16_S36 port map ( do(((i+1)*36)-5 downto i*36),
	do(((i+1)*36)-1 downto i*36+32), xa(8 downto 0),
	di(((i+1)*36)-5 downto i*36), di(((i+1)*36)-1 downto i*36+32),
	enable, clk, write, gnd);
    end generate;
  end generate;
  a10 : if abits = 10 generate
    x : for i in 0 to ((dbits-1)/18) generate
      r : RAMB16_S18 port map ( do(((i+1)*18)-3 downto i*18),
	do(((i+1)*18)-1 downto i*18+16), xa(9 downto 0),
	di(((i+1)*18)-3 downto i*18), di(((i+1)*18)-1 downto i*18+16),
	enable, clk, write, gnd);
    end generate;
  end generate;
  a11 : if abits = 11 generate
    x : for i in 0 to ((dbits-1)/9) generate
      r : RAMB16_S9 port map ( do(((i+1)*9)-2 downto i*9),
	do(((i+1)*9)-1 downto i*9+8), xa(10 downto 0),
	di(((i+1)*9)-2 downto i*9), di(((i+1)*9)-1 downto i*9+8),
	enable, clk, write, gnd);
    end generate;
  end generate;
  a12 : if abits = 12 generate
    x : for i in 0 to ((dbits-1)/4) generate
      r : RAMB16_S4 port map ( do(((i+1)*4)-1 downto i*4), xa(11 downto 0),
	di(((i+1)*4)-1 downto i*4), enable, clk, write, gnd);
    end generate;
  end generate;
  a13 : if abits = 13 generate
    x : for i in 0 to ((dbits-1)/2) generate
      r : RAMB16_S2 port map ( do(((i+1)*2)-1 downto i*2), xa(12 downto 0),
	di(((i+1)*2)-1 downto i*2), enable, clk, write, gnd);
    end generate;
  end generate;
  a14 : if abits = 14 generate
    x : for i in 0 to (dbits-1) generate
      r : RAMB16_S1 port map ( do((i+1)-1 downto i), xa(13 downto 0),
	di((i+1)-1 downto i), enable, clk, write, gnd);
    end generate;
  end generate;
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
use work.virtex2_complib.all;

entity virtex2_dpram is
  generic ( 
    abits : integer := 4; dbits : integer := 32
  );
  port (
    address1 : in std_logic_vector((abits -1) downto 0);
    clk1     : in std_logic;
    datain1  : in std_logic_vector((dbits -1) downto 0);
    dataout1 : out std_logic_vector((dbits -1) downto 0);
    enable1  : in std_logic;
    write1   : in std_logic;
    address2 : in std_logic_vector((abits -1) downto 0);
    clk2     : in std_logic;
    datain2  : in std_logic_vector((dbits -1) downto 0);
    dataout2 : out std_logic_vector((dbits -1) downto 0);
    enable2  : in std_logic;
    write2   : in std_logic);
end;

architecture behav of virtex2_dpram is

signal gnd, vcc : std_logic;
signal do1, do2, di1, di2 : std_logic_vector(129 downto 0);
signal addr1, addr2 : std_logic_vector(19 downto 0);
begin
  gnd <= '0'; vcc <= '1';
  dataout1 <= do1(dbits-1 downto 0); dataout2 <= do2(dbits-1 downto 0);
  di1(dbits-1 downto 0) <= datain1; di1(129 downto dbits) <= (others => '0');
  di2(dbits-1 downto 0) <= datain2; di2(129 downto dbits) <= (others => '0');
  addr1(abits-1 downto 0) <= address1; addr1(19 downto abits) <= (others => '0');
  addr2(abits-1 downto 0) <= address2; addr2(19 downto abits) <= (others => '0');

  a9 : if abits <= 9 generate
    x : for i in 0 to ((dbits-1)/36) generate
      r0 : RAMB16_S36_S36 port map (
	  do1(((i+1)*36)-5 downto i*36), do1(((i+1)*36)-1 downto i*36+32),
	  do2(((i+1)*36)-5 downto i*36), do2(((i+1)*36)-1 downto i*36+32),
	  addr1(8 downto 0), clk1,
	  di1(((i+1)*36)-5 downto i*36), di1(((i+1)*36)-1 downto i*36+32),
	  enable1, gnd, write1, addr2(8 downto 0), clk2,
	  di2(((i+1)*36)-5 downto i*36), di2(((i+1)*36)-1 downto i*36+32),
	  enable2, gnd, write2);
    end generate;
  end generate;

  a10 : if abits = 10 generate
    x : for i in 0 to ((dbits-1)/18) generate
      r0 : RAMB16_S18_S18 port map (
	  do1(((i+1)*18)-3 downto i*18), do1(((i+1)*18)-1 downto i*18+16),
	  do2(((i+1)*18)-3 downto i*18), do2(((i+1)*18)-1 downto i*18+16),
	  addr1(9 downto 0), clk1,
	  di1(((i+1)*18)-3 downto i*18), di1(((i+1)*18)-1 downto i*18+16),
	  enable1, gnd, write1, addr2(9 downto 0), clk2,
	  di2(((i+1)*18)-3 downto i*18), di2(((i+1)*18)-1 downto i*18+16),
	  enable2, gnd, write2);
    end generate;
  end generate;

end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
use work.tech_virtex2.all;

entity virtex2_regfile is
  generic ( 
    rftype : integer := 1;
    abits : integer := 8; dbits : integer := 32; words : integer := 128
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    clkn     : in std_logic;
    rfi      : in rf_in_type;
    rfo      : out rf_out_type);
end;

architecture behav of virtex2_regfile is

signal vcc : std_logic;
signal gnd : std_logic_vector(127 downto 0);
begin
  vcc <= '1'; gnd <= (others => '0');

  rf0 : if rftype = 1 generate
    r0 : virtex2_dpram generic map (abits, dbits)
      port map (
        rfi.rd1addr((abits -1) downto 0), clkn, gnd((dbits -1) downto 0),
        rfo.data1((dbits -1) downto 0), vcc, gnd(0),
        rfi.wraddr((abits -1) downto 0), clkn, rfi.wrdata((dbits -1) downto 0),
        open, rfi.wren, rfi.wren);
    r1 : virtex2_dpram generic map (abits, dbits)
      port map (
        rfi.rd2addr((abits -1) downto 0), clkn, gnd((dbits -1) downto 0),
        rfo.data2((dbits -1) downto 0), vcc, gnd(0),
        rfi.wraddr((abits -1) downto 0), clkn, rfi.wrdata((dbits -1) downto 0),
        open, rfi.wren, rfi.wren);
  end generate;

  rf1 : if rftype = 2 generate
    r0 : virtex2_dpram generic map (abits, dbits)
      port map (
        rfi.rd1addr((abits -1) downto 0), clkn, gnd((dbits -1) downto 0),
        rfo.data1((dbits -1) downto 0), vcc, gnd(0),
        rfi.wraddr((abits -1) downto 0), clk, rfi.wrdata((dbits -1) downto 0),
        open, rfi.wren, rfi.wren);
    r1 : virtex2_dpram generic map (abits, dbits)
      port map (
        rfi.rd2addr((abits -1) downto 0), clkn, gnd((dbits -1) downto 0),
        rfo.data2((dbits -1) downto 0), vcc, gnd(0),
        rfi.wraddr((abits -1) downto 0), clk, rfi.wrdata((dbits -1) downto 0),
        open, rfi.wren, rfi.wren);
  end generate;
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
use work.virtex2_complib.all;

entity virtex2_regfile_cp is
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end;

architecture behav of virtex2_regfile_cp is

signal vcc : std_logic;
signal do1, do2, di1, di2 : std_logic_vector(129 downto 0);
signal ra1, ra2, wa : std_logic_vector(19 downto 0);
signal gnd : std_logic_vector(31 downto 0);
begin
  vcc <= '1'; gnd <= (others => '0');
  rfo.data1 <= do1(dbits-1 downto 0); rfo.data2 <= do2(dbits-1 downto 0);
  di1(dbits-1 downto 0) <= rfi.wrdata; di1(129 downto dbits) <= (others => '0');
  di2(129 downto 0) <= (others => '0');
  ra1(abits-1 downto 0) <= rfi.rd1addr; ra1(19 downto abits) <= (others => '0');
  ra2(abits-1 downto 0) <= rfi.rd2addr; ra2(19 downto abits) <= (others => '0');
  wa(abits-1 downto 0) <= rfi.wraddr; wa(19 downto abits) <= (others => '0');

  a9 : if abits <= 9 generate
      x : for i in 0 to ((dbits-1)/36) generate
        r0 : RAMB16_S36_S36 port map ( do1(((i+1)*36)-5 downto i*36),
	  do1(((i+1)*36)-1 downto i*36+32), open, open, ra1(8 downto 0), clk,
	  gnd(31 downto 0), gnd(3 downto 0), vcc, gnd(0), gnd(0),
	  wa(8 downto 0), clk, di1(((i+1)*36)-5 downto i*36),
	  di1(((i+1)*36)-1 downto i*36+32), vcc, gnd(0), rfi.wren);
        r1 : RAMB16_S36_S36 port map ( do2(((i+1)*36)-5 downto i*36),
	  do2(((i+1)*36)-1 downto i*36+32), open, open, ra2(8 downto 0), clk,
	  gnd(31 downto 0), gnd(3 downto 0), vcc, gnd(0), gnd(0),
	  wa(8 downto 0), clk, di1(((i+1)*36)-5 downto i*36),
	  di1(((i+1)*36)-1 downto i*36+32), vcc, gnd(0), rfi.wren);
      end generate;
  end generate;
end;

------------------------------------------------------------------
-- Virtex2 clock generator ---------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.leon_target.all;
use work.leon_iface.all;
use work.leon_config.all;
--library unisim;
--use unisim.vcomponents.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity virtex2_clkgen is
  generic ( clk_mul : integer := 1 ; clk_div : integer := 1);
  port (
    clkin   : in  std_logic;
    pciclkin: in  std_logic;
    clk     : out std_logic;			-- main clock
    clkn    : out std_logic;			-- inverted main clock
    sdclk   : out std_logic;			-- SDRAM clock
    pciclk  : out std_logic;			-- PCI clock
    cgi     : in clkgen_in_type;
    cgo     : out clkgen_out_type
  );
end; 

architecture struct of virtex2_clkgen is 

--  attribute CLKFX_MULTIPLY : string;  
--  attribute CLKFX_DIVIDE : string;  
  attribute CLKIN_PERIOD : string;
--  
--  attribute CLKFX_MULTIPLY of dll0: label is "5";
--  attribute CLKFX_DIVIDE of dll0: label is "4";
  attribute CLKIN_PERIOD of dll0: label is "25";
--
--  attribute CLKFX_MULTIPLY of dll1: label is "4";
--  attribute CLKFX_DIVIDE of dll1: label is "4";
--  attribute CLKIN_PERIOD of dll1: label is "25";
--

component DCM
  generic (
    CLKFX_MULTIPLY : integer := 1 ;
    CLKFX_DIVIDE : integer := 1
  );
  port (
    CLKFB    : in  std_logic;
    CLKIN    : in  std_logic;
    DSSEN    : in  std_logic;
    PSCLK    : in  std_logic;
    PSEN     : in  std_logic;
    PSINCDEC : in  std_logic;
    RST      : in  std_logic;
    CLK0     : out std_logic;
    CLK90    : out std_logic;
    CLK180   : out std_logic;
    CLK270   : out std_logic;
    CLK2X    : out std_logic;
    CLK2X180 : out std_logic;
    CLKDV    : out std_logic;
    CLKFX    : out std_logic;
    CLKFX180 : out std_logic;
    LOCKED   : out std_logic;
    PSDONE   : out std_logic;
    STATUS   : out std_logic_vector (7 downto 0));
end component;

component IBUFG port ( O : out std_logic; I : in std_logic); end component;
component BUFG port ( O : out std_logic; I : in std_logic); end component;
component IBUFG_PCI33_3 port ( O : out std_logic; I : in std_logic); end component;
component BUFGDLL port ( O : out std_logic; I : in std_logic); end component;
component OBUF_F_12 port( O : out std_ulogic; I : in  std_ulogic ); end component;

signal gnd, Clk_i, Clk_j, Clk_k, Clk_l, Clk_m, dll0rst, dll0lock, dll1lock, dll1rst : std_logic;
signal Clk0B, Clk_FB, Clkint, pciclkint, sdclki : std_logic;

begin

  gnd <= '0'; clk <= clk_i; clkn <= clk_m;

  c0 : if not PCI_SYSCLK generate
    ibufg0 : IBUFG port map (I => Clkin, O => Clkint);
  end generate;
  c1 : if PCI_SYSCLK generate 
    ibufg0 : IBUFG port map (I => pciclkin, O => Clkint);
  end generate;

  c2 : if PCIEN generate
    p0 : if PCI_CLKDLL generate
      u0 : IBUFG port map (I => pciclkin, O => pciclkint);
      u1 : BUFGDLL port map (O => pciclk, I => pciclkint);
    end generate;
    p1 : if not PCI_CLKDLL generate 
      u0 : if not PCI_SYSCLK generate
	u1 : BUFG port map (I => pciclkin, O => pciclkint);
      end generate;
      pciclk <= clk_i when PCI_SYSCLK else pciclkint; 
    end generate;
  end generate;
  c3 : if not PCIEN generate
    pciclk <= Clkint;
  end generate;

  bufg0 : BUFG port map (I => Clk0B, O => Clk_i);
  bufg1 : BUFG port map (I => Clk_j, O => Clk_k);
  bufg2 : BUFG port map (I => Clk_l, O => Clk_m);
  ibufg1 : IBUFG port map (I => cgi.pllref, O => Clk_FB);
  dll0rst <= not cgi.pllrst;
  dll0 : DCM 
    generic map (CLKFX_MULTIPLY => clk_mul, CLKFX_DIVIDE => clk_div)
    port map ( CLKIN => Clkint, CLKFB => Clk_k, DSSEN => gnd, PSCLK => gnd,
    PSEN => gnd, PSINCDEC => gnd, RST => dll0rst, CLK0 => Clk_j,
    CLKFX => Clk0B, CLKFX180 => Clk_l, LOCKED => dll0lock);
   
  sd0 : if SDRAMEN and not SDINVCLK generate
    dll1rst <= not dll0lock; cgo.clklock <= dll1lock;
    dll1 : DCM generic map (CLKFX_MULTIPLY => 2, CLKFX_DIVIDE => 2)
      port map ( CLKIN => Clk_i, CLKFB => Clk_FB, DSSEN => gnd, PSCLK => gnd,
      PSEN => gnd, PSINCDEC => gnd, RST => dll1rst, CLK0 => sdclki, 
      LOCKED => dll1lock);
  end generate;

  sd1 : if not (SDRAMEN and not SDINVCLK) generate
    sdclki <= not clk_i; cgo.clklock <= dll0lock;
  end generate;

  sd2 : if SDRAMEN generate
    sdbuf : OBUF_F_12 port map (I => sdclki, O => sdclk);
  end generate;
  sd3 : if not SDRAMEN generate sdclk <= sdclki; end generate;

  cgo.pcilock <= '1';

end;






