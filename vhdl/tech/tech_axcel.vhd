



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
-- Entity: 	tech_axcel
-- File:	tech_axcel.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Ram generators for Actel Axcelerator FPGAs
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_axcel is

-- generic sync ram

component axcel_syncram
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

-- regfile generator

component axcel_regfile_iu
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

component axcel_regfile_cp
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end component;

end;

------------------------------------------------------------------
-- behavioural ram models --------------------------------------------
------------------------------------------------------------------

-- pragma translate_off

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tech_generic.all;

entity RAM64K36 is generic (abits : integer := 16); port(
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
end;

architecture rtl of RAM64K36 is
  signal re : std_logic;
begin

  rp : process(RCLK, WCLK)
  constant words : integer := 2**abits;
  subtype word is std_logic_vector(35 downto 0);
  type dregtype is array (0 to words - 1) of word;
  variable rfd : dregtype;
  variable wa, ra : std_logic_vector(15 downto 0);
  variable q : std_logic_vector(35 downto 0);
  begin
    if rising_edge(WCLK) and (wen = '0') then
      wa := WRAD15 & WRAD14 & WRAD13 & WRAD12 & WRAD11 & WRAD10 & WRAD9 &
            WRAD8 & WRAD7 & WRAD6 & WRAD5 & WRAD4 & WRAD3 & WRAD2 & WRAD1 & WRAD0;
      if not is_x (wa) then 
   	rfd(conv_integer(unsigned(wa)) mod words) :=
          WD35 & WD34 & WD33 & WD32 & WD31 & WD30 & WD29 & WD28 & WD27 &
	  WD26 & WD25 & WD24 & WD23 & WD22 & WD21 & WD20 & WD19 & WD18 &
	  WD17 & WD16 & WD15 & WD14 & WD13 & WD12 & WD11 & WD10 & WD9 &
	  WD8 & WD7 & WD6 & WD5 & WD4 & WD3 & WD2 & WD1 & WD0;
      end if;
    end if;
    if rising_edge(RCLK) then
      ra := RDAD15 & RDAD14 & RDAD13 & RDAD12 & RDAD11 & RDAD10 & RDAD9 &
            RDAD8 & RDAD7 & RDAD6 & RDAD5 & RDAD4 & RDAD3 & RDAD2 & RDAD1 & RDAD0;
      if not (is_x (ra)) and REN = '0' then 
        q := rfd(conv_integer(unsigned(ra)) mod words);
      else q := (others => 'X'); end if;
    end if;
    RD35 <= q(35); RD34 <= q(34); RD33 <= q(33); RD32 <= q(32); RD31 <= q(31);
    RD30 <= q(30); RD29 <= q(29); RD28 <= q(28); RD27 <= q(27); RD26 <= q(26);
    RD25 <= q(25); RD24 <= q(24); RD23 <= q(23); RD22 <= q(22); RD21 <= q(21);
    RD20 <= q(20); RD19 <= q(19); RD18 <= q(18); RD17 <= q(17); RD16 <= q(16);
    RD15 <= q(15); RD14 <= q(14); RD13 <= q(13); RD12 <= q(12); RD11 <= q(11);
    RD10 <= q(10); RD9 <= q(9); RD8 <= q(8); RD7 <= q(7); RD6 <= q(6);
    RD5 <= q(5); RD4 <= q(4); RD3 <= q(3); RD2 <= q(2); RD1 <= q(1);
    RD0 <= q(0);
  end process;
end;

-- pragma translate_on

--------------------------------------------------------------------
-- A simpler interface to the syncram
--------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_config.all;
use work.leon_iface.all;
entity axcel_ssram is
  generic (abits : integer := 16; dbits : integer := 36);
  port (
    wa, ra       : in  std_logic_vector(15 downto 0);
    wclk, rclk   : in  std_logic;
    di           : in  std_logic_vector(dbits -1 downto 0);
    do           : out std_logic_vector(dbits -1 downto 0);
    width        : in  std_logic_vector(2 downto 0);
    ren, wen     : in  std_logic
   ); 
end;

architecture rtl of axcel_ssram is
signal gnd : std_logic;
component RAM64K36 
-- pragma translate_off
  generic (abits : integer := 16);
-- pragma translate_on
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
attribute syn_tco1 of RAM64K36 : component is
"RCLK->RD0, RD1, RD2, RD3, RD4, RD5, RD6, RD7, RD8, RD9, RD10, RD11, RD12, RD13, RD14, RD15, RD16, RD17, RD18, RD19, RD20, RD21, RD22, RD23, RD24, RD25, RD26, RD27, RD28, RD29, RD30, RD31, RD32, RD33, RD34, RD35 = 4.0";
signal depth : std_logic_vector(4 downto 0);
signal d, q : std_logic_vector(36 downto 0);
begin
  depth <= "00000";
  do <= q(dbits-1 downto 0);
  d(dbits-1 downto 0) <= di;
  d(36 downto dbits) <= (others => '0');
    u0 : RAM64K36
-- pragma translate_off
    generic map (abits => abits) 
-- pragma translate_on
    port map (
      WRAD0 => wa(0), WRAD1 => wa(1), WRAD2 => wa(2), WRAD3 => wa(3),
      WRAD4 => wa(4), WRAD5 => wa(5), WRAD6 => wa(6), WRAD7 => wa(7),
      WRAD8 => wa(8), WRAD9 => wa(9), WRAD10 => wa(10), WRAD11 => wa(11),
      WRAD12 => wa(12), WRAD13 => wa(13), WRAD14 => wa(14), WRAD15 => wa(15),
      WD0 => d(0), WD1 => d(1), WD2 => d(2), WD3 => d(3), WD4 => d(4),
      WD5 => d(5), WD6 => d(6), WD7 => d(7), WD8 => d(8), WD9 => d(9),
      WD10 => d(10), WD11 => d(11), WD12 => d(12), WD13 => d(13), WD14 => d(14),
      WD15 => d(15), WD16 => d(16), WD17 => d(17), WD18 => d(18), WD19 => d(19),
      WD20 => d(20), WD21 => d(21), WD22 => d(22), WD23 => d(23), WD24 => d(24),
      WD25 => d(25), WD26 => d(26), WD27 => d(27), WD28 => d(28), WD29 => d(29),
      WD30 => d(30), WD31 => d(31), WD32 => d(32), WD33 => d(33), WD34 => d(34),
      WD35 => d(35), WEN => wen, DEPTH0 => depth(0),
      DEPTH1 => depth(1), DEPTH2 => depth(2), DEPTH3 => depth(3),
      WW0 => width(0), WW1 => width(1), WW2 => width(2), WCLK => wclk,
      RDAD0 => ra(0), RDAD1 => ra(1), RDAD2 => ra(2), RDAD3 => ra(3),
      RDAD4 => ra(4), RDAD5 => ra(5), RDAD6 => ra(6), RDAD7 => ra(7),
      RDAD8 => ra(8), RDAD9 => ra(9), RDAD10 => ra(10), RDAD11 => ra(11),
      RDAD12 => ra(12), RDAD13 => ra(13), RDAD14 => ra(14), RDAD15 => ra(15),
      REN => ren, RW0 => width(0), RW1 => width(1), RW2 => width(2),
      RCLK => rclk,
      RD0 => q(0), RD1 => q(1), RD2 => q(2), RD3 => q(3), RD4 => q(4),
      RD5 => q(5), RD6 => q(6), RD7 => q(7), RD8 => q(8), RD9 => q(9),
      RD10 => q(10), RD11 => q(11), RD12 => q(12), RD13 => q(13), RD14 => q(14),
      RD15 => q(15), RD16 => q(16), RD17 => q(17), RD18 => q(18), RD19 => q(19),
      RD20 => q(20), RD21 => q(21), RD22 => q(22), RD23 => q(23), RD24 => q(24),
      RD25 => q(25), RD26 => q(26), RD27 => q(27), RD28 => q(28), RD29 => q(29),
      RD30 => q(30), RD31 => q(31), RD32 => q(32), RD33 => q(33), RD34 => q(34),
      RD35 => q(35));

  d(dbits -1 downto 0) <= di;
  do <= q(dbits -1 downto 0);
end;

--------------------------------------------------------------------
-- regfile generators
--------------------------------------------------------------------

-- integer unit regfile
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
use work.tech_generic.all;
entity axcel_regfile_iu is
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

architecture rtl of axcel_regfile_iu is
component axcel_ssram 
  generic (abits : integer := 16; dbits : integer := 36);
  port (
    wa, ra       : in  std_logic_vector(15 downto 0);
    wclk, rclk   : in  std_logic;
    di           : in  std_logic_vector(dbits -1 downto 0);
    do           : out std_logic_vector(dbits -1 downto 0);
    width        : in  std_logic_vector(2 downto 0);
    ren, wen     : in  std_logic
   ); 
end component;
signal wen, gnd : std_logic;
signal width : std_logic_vector(2 downto 0);
signal depth : std_logic_vector(4 downto 0);
signal wa, ra1, ra2 : std_logic_vector(15 downto 0);
signal di, q1, qq1, q2, qq2 : std_logic_vector(35 downto 0);
signal ren1, ren2 : std_logic;
constant xbits : integer := 32/(2**(abits-7)); 
begin
  width <= "101" when abits <= 7 else
           "100" when abits = 8 else
           "011" when abits = 9 else
           "010" when abits = 10 else
           "001" when abits = 11 else
           "000";

  wen <= not rfi.wren; gnd <= '0';
  wa(15 downto abits) <= (others =>'0');
  wa(abits-1 downto 0) <= rfi.wraddr(abits-1 downto 0);
  ra1(15 downto abits) <= (others =>'0');
  ra1(abits-1 downto 0) <= rfi.rd1addr(abits-1 downto 0);
  ra2(15 downto abits) <= (others =>'0');
  ra2(abits-1 downto 0) <= rfi.rd2addr(abits-1 downto 0);
  di(35 downto dbits) <= (others =>'0');
  di(dbits-1 downto 0) <= rfi.wrdata(dbits-1 downto 0);
  rfo.data1 <= q1(dbits-1 downto 0);
  rfo.data2 <= q2(dbits-1 downto 0);
  ren1 <= not rfi.ren1;
  ren2 <= not rfi.ren2;

  rt1 : if RFIMPTYPE = 1 generate
    a7 : if abits <= 7 generate
      u0 : axcel_ssram
      generic map (abits => abits, dbits => 32) 
      port map ( ra => ra1, wa => wa, di => di(31 downto 0), wen => wen,
      width => width, wclk => clkn, ren => ren1, rclk => clkn, do => q1(31 downto 0));
      u1 : axcel_ssram
      generic map (abits => abits, dbits => 32) 
      port map ( ra => ra2, wa => wa, di => di(31 downto 0), wen => wen,
      width => width, wclk => clkn, ren => ren2, rclk => clkn, do => q2(31 downto 0));
    end generate;
    a8to12 : if abits > 7 generate
      agen : for i in 0 to (dbits+xbits-1)/xbits-1 generate
        u0 : axcel_ssram
        generic map (abits => abits, dbits => xbits) 
        port map ( ra => ra1, wa => wa, di => di(xbits*(i+1)-1 downto xbits*i),
           wen => wen, width => width, wclk => clkn, ren => ren1, rclk => clkn,
           do => q1(xbits*(i+1)-1 downto xbits*i));
        u1 : axcel_ssram
        generic map (abits => abits, dbits => xbits) 
        port map ( ra => ra2, wa => wa, di => di(xbits*(i+1)-1 downto xbits*i),
           wen => wen, width => width, wclk => clkn, ren => ren2, rclk => clkn,
           do => q2(xbits*(i+1)-1 downto xbits*i));
      end generate;
    end generate;
  end generate;

  rt2 : if RFIMPTYPE = 2 generate
    a7 : if abits <= 7 generate
      u0 : axcel_ssram
      generic map (abits => abits, dbits => 32) 
      port map ( ra => ra1, wa => wa, di => di(31 downto 0), wen => wen,
      width => width, wclk => clk, ren => ren1, rclk => clkn, do => q1(31 downto 0));
      u1 : axcel_ssram
      generic map (abits => abits, dbits => 32) 
      port map ( ra => ra2, wa => wa, di => di(31 downto 0), wen => wen,
      width => width, wclk => clk, ren => ren2, rclk => clkn, do => q2(31 downto 0));
    end generate;
    a8to12 : if abits > 7 generate
      agen : for i in 0 to (dbits+xbits-1)/xbits-1 generate
        u0 : axcel_ssram
        generic map (abits => abits, dbits => xbits) 
        port map ( ra => ra1, wa => wa, di => di(xbits*(i+1)-1 downto xbits*i),
           wen => wen, width => width, wclk => clk, ren => ren1, rclk => clkn,
           do => q1(xbits*(i+1)-1 downto xbits*i));
        u1 : axcel_ssram
        generic map (abits => abits, dbits => xbits) 
        port map ( ra => ra2, wa => wa, di => di(xbits*(i+1)-1 downto xbits*i),
           wen => wen, width => width, wclk => clk, ren => ren2, rclk => clkn,
           do => q2(xbits*(i+1)-1 downto xbits*i));
      end generate;
    end generate;
  end generate;
end;

-- co-processor regfile
-- synchronous operation without write-through support
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
entity axcel_regfile_cp is
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end;

architecture rtl of axcel_regfile_cp is
component axcel_ssram 
  generic (abits : integer := 16; dbits : integer := 36);
  port (
    wa, ra       : in  std_logic_vector(15 downto 0);
    wclk, rclk   : in  std_logic;
    di           : in  std_logic_vector(dbits -1 downto 0);
    do           : out std_logic_vector(dbits -1 downto 0);
    width        : in  std_logic_vector(2 downto 0);
    ren, wen     : in  std_logic
   ); 
end component;
signal wen, gnd : std_logic;
signal width : std_logic_vector(2 downto 0);
signal wa, ra1, ra2 : std_logic_vector(15 downto 0);
signal di, q1, q2 : std_logic_vector(35 downto 0);
signal ren1, ren2 : std_logic;
begin

  width <= "101";
  wen <= not rfi.wren; gnd <= '0';
  wa(15 downto abits) <= (others =>'0');
  wa(abits-1 downto 0) <= rfi.wraddr(abits-1 downto 0);
  ra1(15 downto abits) <= (others =>'0');
  ra1(abits-1 downto 0) <= rfi.rd1addr(abits-1 downto 0);
  ra2(15 downto abits) <= (others =>'0');
  ra2(abits-1 downto 0) <= rfi.rd2addr(abits-1 downto 0);
  di(35 downto dbits) <= (others =>'0');
  di(dbits-1 downto 0) <= rfi.wrdata(dbits-1 downto 0);
  rfo.data1 <= q1(dbits-1 downto 0);
  rfo.data2 <= q2(dbits-1 downto 0);
  ren1 <= not rfi.ren1;
  ren2 <= not rfi.ren2;

  u0 : axcel_ssram
  generic map (abits => abits, dbits => 32) 
  port map ( ra => ra1, wa => wa, di => di(31 downto 0), wen => wen,
  width => width, wclk => clk, ren => ren1, rclk => clk, do => q1(31 downto 0));

  u1 : axcel_ssram
  generic map (abits => abits, dbits => 32) 
  port map ( ra => ra2, wa => wa, di => di(31 downto 0), wen => wen,
  width => width, wclk => clk, ren => ren2, rclk => clk, do => q2(31 downto 0));

end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_config.all;
use work.leon_iface.all;
entity axcel_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    address  : in std_logic_vector((abits -1) downto 0);
    clk      : in std_logic;
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_logic;
    write    : in std_logic
   ); 
end;

architecture rtl of axcel_syncram is
component axcel_ssram 
  generic (abits : integer := 16; dbits : integer := 36);
  port (
    wa, ra       : in  std_logic_vector(15 downto 0);
    wclk, rclk   : in  std_logic;
    di           : in  std_logic_vector(dbits -1 downto 0);
    do           : out std_logic_vector(dbits -1 downto 0);
    width        : in  std_logic_vector(2 downto 0);
    ren, wen     : in  std_logic
   ); 
end component;

signal wen, gnd : std_logic;
signal a : std_logic_vector(15 downto 0);
signal d, q : std_logic_vector(35 downto 0);
signal ren  : std_logic;
constant xbits : integer := 32/(2**(abits-7)); 
signal width : std_logic_vector(2 downto 0);
begin
  width <= "101" when abits <= 7 else
           "100" when abits = 8 else
           "011" when abits = 9 else
           "010" when abits = 10 else
           "001" when abits = 11 else
           "000";
  wen <= not write; gnd <= '0';
  a(15 downto abits) <= (others =>'0');
  a(abits-1 downto 0) <= address(abits-1 downto 0);
  d(35 downto dbits) <= (others =>'0');
  d(dbits-1 downto 0) <= datain(dbits-1 downto 0);
  dataout <= q(dbits-1 downto 0);
  ren <= '0';

  a7 : if abits <= 7 generate
    u0 : axcel_ssram
    generic map (abits => abits) 
    port map ( ra => a, wa => a, di => d, wen => wen, width => width,
	 wclk => clk, ren => ren, rclk => clk, do => q);
  end generate;
  a8to12 : if abits > 7 generate
    agen : for i in 0 to (dbits+xbits-1)/xbits-1 generate
      u0 : axcel_ssram
      generic map (abits => abits, dbits => xbits) 
      port map ( ra => a, wa => a, di => d(xbits*(i+1)-1 downto xbits*i),
         wen => wen, width => width, wclk => clk, ren => ren, rclk => clk,
         do => q(xbits*(i+1)-1 downto xbits*i));
    end generate;
  end generate;
end;
