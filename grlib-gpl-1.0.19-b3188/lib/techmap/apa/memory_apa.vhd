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
-- File:	mem_apa_gen.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Memory generators for Actel Proasic rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;
-- pragma translate_off
library apa;
use apa.RAM256x9SST;
-- pragma translate_on

entity proasic_syncram_2p is
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
end;

architecture rtl of proasic_syncram_2p is
  component RAM256x9SST port(
    DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0 : out std_logic;
    WPE, RPE, DOS : out std_logic;
    WADDR7, WADDR6, WADDR5, WADDR4, WADDR3, WADDR2, WADDR1, WADDR0 : in std_logic;
    RADDR7, RADDR6, RADDR5, RADDR4, RADDR3, RADDR2, RADDR1, RADDR0 : in std_logic;
    WCLKS, RCLKS : in std_logic;
    DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0 : in std_logic;
    WRB, RDB, WBLKB, RBLKB, PARODD, DIS : in std_logic);
  end component;

  type powarr is array (1 to 19) of integer;
  constant ntbl : powarr := (1, 1, 1, 1, 1, 1, 1, 1, 2, 4, 8, 16, 32, others => 64);
  constant dw : integer := dbits + 8;
  subtype dword is std_logic_vector(dw downto 0);
  type qarr is array (0 to 63) of dword;
  signal gnd, wen, ren : std_ulogic;
  signal q : qarr;
  signal d : dword;
  signal rra : std_logic_vector (20 downto 0);
  signal ra, wa : std_logic_vector (63 downto 0);
  signal wenv : std_logic_vector (63 downto 0);
  signal renv : std_logic_vector (63 downto 0);
begin
  gnd <= '0';
  wa(63 downto abits) <= (others => '0'); wa(abits-1 downto 0) <= waddr;
  ra(63 downto abits) <= (others => '0'); ra(abits-1 downto 0) <= raddr;
  d(dw downto dbits)  <= (others => '0'); d(dbits-1 downto 0)  <= din;
  wen <= not write; ren <= not rena;

  x0 : if abits < 15 generate
    b0 : for j in 0 to ntbl(abits)-1 generate
      g0 : for i in 0 to (dbits-1)/9 generate
        u0 : RAM256x9SST port map (
          DO0 => q(j)(i*9+0), DO1 => q(j)(i*9+1), DO2 => q(j)(i*9+2),
          DO3 => q(j)(i*9+3), DO4 => q(j)(i*9+4), DO5 => q(j)(i*9+5), 
          DO6 => q(j)(i*9+6), DO7 => q(j)(i*9+7), DO8 => q(j)(i*9+8),
          DOS => open, RPE => open, WPE => open,
          WADDR0 => wa(0), WADDR1 => wa(1), WADDR2 => wa(2),
          WADDR3 => wa(3), WADDR4 => wa(4), WADDR5 => wa(5),
          WADDR6 => wa(6), WADDR7 => wa(7),
          RADDR0 => ra(0), RADDR1 => ra(1), RADDR2 => ra(2),
          RADDR3 => ra(3), RADDR4 => ra(4), RADDR5 => ra(5),
          RADDR6 => ra(6), RADDR7 => ra(7),
          WCLKS => wclk, RCLKS => rclk,
          DI0 => d(i*9+0), DI1 => d(i*9+1), DI2 => d(i*9+2),
          DI3 => d(i*9+3), DI4 => d(i*9+4), DI5 => d(i*9+5), 
          DI6 => d(i*9+6), DI7 => d(i*9+7), DI8 => d(i*9+8),
          RDB => ren, WRB => wen, RBLKB => renv(j), WBLKB => wenv(j),
	  PARODD => gnd, DIS => gnd
	);
      end generate;
    end generate;

    rra(20 downto abits) <= (others => '0');
    reg : process(rclk)
    begin
      if rising_edge(rclk) then
        rra(abits-1 downto 0) <= raddr(abits-1 downto 0);
        rra(7 downto 0) <= (others => '0');
      end if;
    end process;

    ctrl : process(write, waddr, q, rra, rena, raddr)
    variable we,z,re : std_logic_vector(63 downto 0);
    variable wea,rea : std_logic_vector(63 downto 0);
    begin
      we := (others => '0'); z := (others => '0'); re := (others => '0');
      wea := (others => '0'); rea := (others => '0');
      wea(abits-1 downto 0) := waddr(abits-1 downto 0); wea(7 downto 0) := (others => '0');
      rea(abits-1 downto 0) := raddr(abits-1 downto 0); wea(7 downto 0) := (others => '0');
      z(dbits-1 downto 0) := 
		q(conv_integer(rra(19 downto 8)))(dbits-1 downto 0);
      we (conv_integer(wea(19 downto 8))) := write;
      re (conv_integer(rea(19 downto 8))) := rena;
      wenv <= not we; renv <= not re; dout <= z(dbits-1 downto 0);
    end process;

  end generate;

-- pragma translate_off  
  unsup : if abits > 14 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 14 not supported for ProAsic rams"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on
  
end;

library ieee;
use ieee.std_logic_1164.all;

entity proasic_syncram is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    clk      : in std_ulogic;
    address  : in std_logic_vector((abits -1) downto 0);
    datain   : in std_logic_vector((dbits -1) downto 0);
    dataout  : out std_logic_vector((dbits -1) downto 0);
    enable   : in std_ulogic;
    write    : in std_ulogic
   ); 
end;

architecture rtl of proasic_syncram is
component proasic_syncram_2p
  generic ( abits : integer := 8; dbits : integer := 32);
  port (
    rclk  : in std_ulogic;
    rena  : in std_ulogic;
    raddr : in std_logic_vector (abits -1 downto 0);
    dout  : out std_logic_vector (dbits -1 downto 0);
    wclk  : in std_ulogic;
    waddr : in std_logic_vector (abits -1 downto 0);
    din   : in std_logic_vector (dbits -1 downto 0);
    write : in std_ulogic);
end component;


begin
  u0 : proasic_syncram_2p generic map (abits, dbits)
       port map (clk, enable, address, dataout, clk, address, datain, write);
end;
