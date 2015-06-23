



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
-- Entity: 	tech_proasic
-- File:	tech_proasic.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Ram generators for Actel ProAsic/ProAsicPlus
------------------------------------------------------------------------------

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_iface.all;
package tech_proasic is

-- generic sync ram

component proasic_syncram
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

component proasic_regfile_iu
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

component proasic_regfile_cp
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
use work.tech_generic.all;

entity RAM256x9SST is
    port(
  DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0 : out std_logic;
  WPE, RPE, DOS : out std_logic;
  WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
  RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
  WCLKS, RCLKS : in std_logic;
  DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0 : in std_logic;
  WRB, RDB, WBLKB, RBLKB, PARODD, DIS : in std_logic);
end;

architecture rtl of RAM256x9SST is
  signal d, q : std_logic_vector(8 downto 0);
  signal wa, ra : std_logic_vector(7 downto 0);
  signal wen : std_logic;
begin
  wen <= not (WBLKB or WRB);
  wa  <= WADDR7 & WADDR6 & WADDR5 & WADDR4 & WADDR3 & WADDR2 & WADDR1 & WADDR0;
  ra  <= RADDR7 & RADDR6 & RADDR5 & RADDR4 & RADDR3 & RADDR2 & RADDR1 & RADDR0;
  d   <= DI8 & DI7 & DI6 & DI5 & DI4 & DI3 & DI2 & DI1 & DI0;
  u0 : generic_dpram_ss generic map (abits => 8, dbits => 9, words => 256)
       port map (clk => WCLKS, rdaddress => ra, wraddress => wa, 
	         data => d, wren => wen, q => q);
  DO8 <= q(8); DO7 <= q(7); DO6 <= q(6); DO5 <= q(5); DO4 <= q(4);
  DO3 <= q(3); DO2 <= q(2); DO1 <= q(1); DO0 <= q(0);
  
end;

library IEEE;
use IEEE.std_logic_1164.all;
use work.tech_generic.all;

entity RAM256x9SA is
    port(
  DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8 : out std_logic;
  DOS, RPE, WPE : out std_logic;
  WADDR0, WADDR1, WADDR2, WADDR3, WADDR4, WADDR5, WADDR6, WADDR7 : in std_logic;
  RADDR0, RADDR1, RADDR2, RADDR3, RADDR4, RADDR5, RADDR6, RADDR7 : in std_logic;
  WCLKS : in std_logic;
  DI0, DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8 : in std_logic;
  RDB, WRB, RBLKB, WBLKB, PARODD, DIS : in std_logic);
end;

architecture rtl of RAM256x9SA is
  signal d, q : std_logic_vector(8 downto 0);
  signal wa, ra : std_logic_vector(7 downto 0);
  signal wen : std_logic;
begin
  wen <= not (WBLKB or WRB);
  wa  <= WADDR7 & WADDR6 & WADDR5 & WADDR4 & WADDR3 & WADDR2 & WADDR1 & WADDR0;
  ra  <= RADDR7 & RADDR6 & RADDR5 & RADDR4 & RADDR3 & RADDR2 & RADDR1 & RADDR0;
  d   <= DI8 & DI7 & DI6 & DI5 & DI4 & DI3 & DI2 & DI1 & DI0;
  u0 : generic_dpram_as generic map (abits => 8, dbits => 9, words => 256)
       port map (clk => WCLKS, rdaddress => ra, wraddress => wa, 
	         data => d, wren => wen, q => q);
  DO8 <= q(8); DO7 <= q(7); DO6 <= q(6); DO5 <= q(5); DO4 <= q(4);
  DO3 <= q(3); DO2 <= q(2); DO1 <= q(1); DO0 <= q(0);
  
end;

-- pragma translate_on

--------------------------------------------------------------------
-- regfile generators
--------------------------------------------------------------------

-- integer unit regfile
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
entity proasic_regfile_iu is
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

architecture rtl of proasic_regfile_iu is
  component RAM256x9SA port(
    DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8 : out std_logic;
    DOS, RPE, WPE : out std_logic;
    WADDR0, WADDR1, WADDR2, WADDR3, WADDR4, WADDR5, WADDR6, WADDR7 : in std_logic;
    RADDR0, RADDR1, RADDR2, RADDR3, RADDR4, RADDR5, RADDR6, RADDR7 : in std_logic;
    WCLKS : in std_logic;
    DI0, DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8 : in std_logic;
    RDB, WRB, RBLKB, WBLKB, PARODD, DIS : in std_logic);
  end component;
signal wen, gnd : std_logic;
signal wa, ra1, ra2 : std_logic_vector(15 downto 0);
begin

  wen <= not rfi.wren; gnd <= '0';
  wa(15 downto abits) <= (others => '0');
  wa(abits-1 downto 0) <=  rfi.wraddr(abits-1 downto 0);
  ra1(15 downto abits) <= (others => '0');
  ra1(abits-1 downto 0) <=  rfi.rd1addr(abits-1 downto 0);
  ra2(15 downto abits) <= (others => '0');
  ra2(abits-1 downto 0) <=  rfi.rd2addr(abits-1 downto 0);

  g0 : for i in 0 to 3 generate
    u0 : RAM256x9SA port map (
      DO0 => rfo.data1(i*8 + 0), DO1 => rfo.data1(i*8 + 1), 
      DO2 => rfo.data1(i*8 + 2), DO3 => rfo.data1(i*8 + 3), 
      DO4 => rfo.data1(i*8 + 4), DO5 => rfo.data1(i*8 + 5), 
      DO6 => rfo.data1(i*8 + 6), DO7 => rfo.data1(i*8 + 7), DO8 => open,
      DOS => open, RPE => open, WPE => open,
      WADDR0 => wa(0), WADDR1 => wa(1), WADDR2 => wa(2), WADDR3 => wa(3),
      WADDR4 => wa(4), WADDR5 => wa(5), WADDR6 => wa(6), WADDR7 => wa(7),
      RADDR0 => ra1(0), RADDR1 => ra1(1), RADDR2 => ra1(2), RADDR3 => ra1(3),
      RADDR4 => ra1(4), RADDR5 => ra1(5), RADDR6 => ra1(6), RADDR7 => ra1(7),
      WCLKS => clk,
      DI0 => rfi.wrdata(i*8 + 0), DI1 => rfi.wrdata(i*8 + 1), 
      DI2 => rfi.wrdata(i*8 + 2), DI3 => rfi.wrdata(i*8 + 3), 
      DI4 => rfi.wrdata(i*8 + 4), DI5 => rfi.wrdata(i*8 + 5), 
      DI6 => rfi.wrdata(i*8 + 6), DI7 => rfi.wrdata(i*8 + 7), DI8 => gnd,
      RDB => gnd, WRB => wen, RBLKB => gnd, WBLKB => wen, PARODD => gnd, 
      DIS => gnd);
    u1 : RAM256x9SA port map (
      DO0 => rfo.data2(i*8 + 0), DO1 => rfo.data2(i*8 + 1), 
      DO2 => rfo.data2(i*8 + 2), DO3 => rfo.data2(i*8 + 3), 
      DO4 => rfo.data2(i*8 + 4), DO5 => rfo.data2(i*8 + 5), 
      DO6 => rfo.data2(i*8 + 6), DO7 => rfo.data2(i*8 + 7), DO8 => open,
      DOS => open, RPE => open, WPE => open,
      WADDR0 => wa(0), WADDR1 => wa(1), WADDR2 => wa(2), WADDR3 => wa(3),
      WADDR4 => wa(4), WADDR5 => wa(5), WADDR6 => wa(6), WADDR7 => wa(7),
      RADDR0 => ra2(0), RADDR1 => ra2(1), RADDR2 => ra2(2), RADDR3 => ra2(3),
      RADDR4 => ra2(4), RADDR5 => ra2(5), RADDR6 => ra2(6), RADDR7 => ra2(7),
      WCLKS => clk,
      DI0 => rfi.wrdata(i*8 + 0), DI1 => rfi.wrdata(i*8 + 1), 
      DI2 => rfi.wrdata(i*8 + 2), DI3 => rfi.wrdata(i*8 + 3), 
      DI4 => rfi.wrdata(i*8 + 4), DI5 => rfi.wrdata(i*8 + 5), 
      DI6 => rfi.wrdata(i*8 + 6), DI7 => rfi.wrdata(i*8 + 7), DI8 => gnd,
      RDB => gnd, WRB => wen, RBLKB => gnd, WBLKB => wen, PARODD => gnd, 
      DIS => gnd);
    end generate;
end;

-- co-processor regfile
-- synchronous operation without write-through support
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use work.leon_config.all;
use work.leon_iface.all;
entity proasic_regfile_cp is
  generic ( 
    abits : integer := 4; dbits : integer := 32; words : integer := 16
  );
  port (
    rst      : in std_logic;
    clk      : in std_logic;
    rfi      : in rf_cp_in_type;
    rfo      : out rf_cp_out_type);
end;

architecture rtl of proasic_regfile_cp is
  component RAM256x9SST port(
    DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0 : out std_logic;
    WPE, RPE, DOS : out std_logic;
    WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
    RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
    WCLKS, RCLKS : in std_logic;
    DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0 : in std_logic;
    WRB, RDB, WBLKB, RBLKB, PARODD, DIS : in std_logic);
  end component;
  signal wen, gnd : std_logic;
begin
  wen <= not rfi.wren; gnd <= '0';
  g0 : for i in 0 to 3 generate
    u0 : RAM256x9SST port map (
      DO0 => rfo.data1(i*8 + 0), DO1 => rfo.data1(i*8 + 1), 
      DO2 => rfo.data1(i*8 + 2), DO3 => rfo.data1(i*8 + 3), 
      DO4 => rfo.data1(i*8 + 4), DO5 => rfo.data1(i*8 + 5), 
      DO6 => rfo.data1(i*8 + 6), DO7 => rfo.data1(i*8 + 7), DO8 => open,
      DOS => open, RPE => open, WPE => open,
      WADDR0 => rfi.wraddr(0), WADDR1 => rfi.wraddr(1), WADDR2 => rfi.wraddr(2),
      WADDR3 => rfi.wraddr(3), WADDR4 => gnd, WADDR5 => gnd,
      WADDR6 => gnd, WADDR7 => gnd,
      RADDR0 => rfi.rd1addr(0), RADDR1 => rfi.rd1addr(1), RADDR2 => rfi.rd1addr(2),
      RADDR3 => rfi.rd1addr(3), RADDR4 => gnd, RADDR5 => gnd,
      RADDR6 => gnd, RADDR7 => gnd,
      WCLKS => clk, RCLKS => clk,
      DI0 => rfi.wrdata(i*8 + 0), DI1 => rfi.wrdata(i*8 + 1), 
      DI2 => rfi.wrdata(i*8 + 2), DI3 => rfi.wrdata(i*8 + 3), 
      DI4 => rfi.wrdata(i*8 + 4), DI5 => rfi.wrdata(i*8 + 5), 
      DI6 => rfi.wrdata(i*8 + 6), DI7 => rfi.wrdata(i*8 + 7), DI8 => gnd,
      RDB => gnd, WRB => wen, RBLKB => gnd, WBLKB => wen, PARODD => gnd, 
      DIS => gnd);
    u1 : RAM256x9SST port map (
      DO0 => rfo.data2(i*8 + 0), DO1 => rfo.data2(i*8 + 1), 
      DO2 => rfo.data2(i*8 + 2), DO3 => rfo.data2(i*8 + 3), 
      DO4 => rfo.data2(i*8 + 4), DO5 => rfo.data2(i*8 + 5), 
      DO6 => rfo.data2(i*8 + 6), DO7 => rfo.data2(i*8 + 7), DO8 => open,
      DOS => open, RPE => open, WPE => open,
      WADDR0 => rfi.wraddr(0), WADDR1 => rfi.wraddr(1), WADDR2 => rfi.wraddr(2),
      WADDR3 => gnd, WADDR4 => gnd, WADDR5 => gnd,
      WADDR6 => gnd, WADDR7 => gnd,
      RADDR0 => rfi.rd2addr(0), RADDR1 => rfi.rd2addr(1), RADDR2 => rfi.rd2addr(2),
      RADDR3 => rfi.rd2addr(3), RADDR4 => gnd, RADDR5 => gnd,
      RADDR6 => gnd, RADDR7 => gnd, WCLKS => clk, RCLKS => clk,
      DI0 => rfi.wrdata(i*8 + 0), DI1 => rfi.wrdata(i*8 + 1), 
      DI2 => rfi.wrdata(i*8 + 2), DI3 => rfi.wrdata(i*8 + 3), 
      DI4 => rfi.wrdata(i*8 + 4), DI5 => rfi.wrdata(i*8 + 5), 
      DI6 => rfi.wrdata(i*8 + 6), DI7 => rfi.wrdata(i*8 + 7), DI8 => gnd,
      RDB => gnd, WRB => wen, RBLKB => gnd, WBLKB => wen, PARODD => gnd, 
      DIS => gnd);
    end generate;
end;

LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.leon_config.all;
use work.leon_iface.all;
entity proasic_syncram is
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

architecture rtl of proasic_syncram is
  component RAM256x9SST port(
    DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0 : out std_logic;
    WPE, RPE, DOS : out std_logic;
    WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
    RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
    WCLKS, RCLKS : in std_logic;
    DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0 : in std_logic;
    WRB, RDB, WBLKB, RBLKB, PARODD, DIS : in std_logic);
  end component;
  type powarr is array (0 to 6) of integer;
  constant powtbl : powarr := (0, 1, 3, 7, 15, 31, 63);
  subtype word is std_logic_vector(63 downto 0);
  type qarr is array (0 to 63) of word;
  signal gnd : std_logic;
  signal q : qarr;
  signal d : word;
  signal a, rra : word;
  signal wen : std_logic_vector (63 downto 0);
begin
  gnd <= '0';
  a(63 downto abits) <= (others => '0');
  a(abits-1 downto 0) <= address;
  d(63 downto dbits) <= (others => '0');
  d(dbits-1 downto 0) <= datain;
  x0 : if abits > 8 generate
    b0 : for j in 0 to powtbl(abits-8) generate
     g0 : for i in 0 to (dbits-1)/9 generate
      u0 : RAM256x9SST port map (
      DO0 => q(j)(i*9+0), DO1 => q(j)(i*9+1), DO2 => q(j)(i*9+2),
      DO3 => q(j)(i*9+3), DO4 => q(j)(i*9+4), DO5 => q(j)(i*9+5), 
      DO6 => q(j)(i*9+6), DO7 => q(j)(i*9+7), DO8 => q(j)(i*9+8),
      DOS => open, RPE => open, WPE => open,
      WADDR0 => a(0), WADDR1 => a(1), WADDR2 => a(2),
      WADDR3 => a(3), WADDR4 => a(4), WADDR5 => a(5),
      WADDR6 => a(6), WADDR7 => a(7),
      RADDR0 => a(0), RADDR1 => a(1), RADDR2 => a(2),
      RADDR3 => a(3), RADDR4 => a(4), RADDR5 => a(5),
      RADDR6 => a(6), RADDR7 => a(7),
      WCLKS => clk, RCLKS => clk,
      DI0 => d(i*9+0), DI1 => d(i*9+1), DI2 => d(i*9+2),
      DI3 => d(i*9+3), DI4 => d(i*9+4), DI5 => d(i*9+5), 
      DI6 => d(i*9+6), DI7 => d(i*9+7), DI8 => d(i*9+8),
      RDB => gnd, WRB => wen(j), RBLKB => gnd, WBLKB => wen(j), PARODD => gnd, 
      DIS => gnd);
     end generate;
   end generate;

    reg : process(clk)
    begin
      if rising_edge(clk) then
        rra(abits-9 downto 0) <= address(abits-1 downto 8);
      end if;
    end process;

    ctrl : process(write, address, q, rra)
    variable we,z : std_logic_vector(63 downto 0);
    begin
      we := (others => '0');
      z := (others => '0');
-- pragma translate_off
      if not is_x(rra(abits-9 downto 0)) then
-- pragma translate_on
        z(dbits-1 downto 0) := q(conv_integer(unsigned(rra(abits-9 downto 0))))(dbits-1 downto 0);
-- pragma translate_off
      end if;
      if not is_x(address(abits-1 downto 8)) then
-- pragma translate_on
        we (conv_integer(unsigned(address(abits-1 downto 8)))) := write;
-- pragma translate_off
      end if;
-- pragma translate_on
      wen <= not we;
      dataout <= z(dbits-1 downto 0);
    end process;

  end generate;

  asz8 : if abits <= 8 generate
    g0 : for i in 0 to (dbits-1)/9 generate
      u0 : RAM256x9SST port map (
      DO0 => q(0)(i*9+0), DO1 => q(0)(i*9+1), DO2 => q(0)(i*9+2),
      DO3 => q(0)(i*9+3), DO4 => q(0)(i*9+4), DO5 => q(0)(i*9+5), 
      DO6 => q(0)(i*9+6), DO7 => q(0)(i*9+7), DO8 => q(0)(i*9+8),
      DOS => open, RPE => open, WPE => open,
      WADDR0 => a(0), WADDR1 => a(1), WADDR2 => a(2),
      WADDR3 => a(3), WADDR4 => a(4), WADDR5 => a(5),
      WADDR6 => a(6), WADDR7 => a(7),
      RADDR0 => a(0), RADDR1 => a(1), RADDR2 => a(2),
      RADDR3 => a(3), RADDR4 => a(4), RADDR5 => a(5),
      RADDR6 => a(6), RADDR7 => a(7),
      WCLKS => clk, RCLKS => clk,
      DI0 => d(i*9+0), DI1 => d(i*9+1), DI2 => d(i*9+2),
      DI3 => d(i*9+3), DI4 => d(i*9+4), DI5 => d(i*9+5), 
      DI6 => d(i*9+6), DI7 => d(i*9+7), DI8 => d(i*9+8),
      RDB => gnd, WRB => wen(0), RBLKB => gnd, WBLKB => wen(0), PARODD => gnd, 
      DIS => gnd);
    end generate;
    wen(0) <= not write;
    dataout <= q(0)(dbits-1 downto 0);
  end generate;

end;
