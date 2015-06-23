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
-- File:	memory_eclipse.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Memory generators for Quicklogic Eclipse rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- translate_off
library eclipsee;
use eclipsee.all;
-- translate_on

entity eclipse_syncram_2p is
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

architecture rtl of eclipse_syncram_2p is
  component RAM128X18_25um is
   port (WA, RA : in std_logic_vector (6 downto 0);
         WD : in std_logic_vector (17 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (17 downto 0) );
  end component;

  component RAM256X9_25um is
   port (WA, RA : in std_logic_vector (7 downto 0);
         WD : in std_logic_vector (8 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (8 downto 0) );
  end component;

  component RAM512X4_25um
   port (WA, RA : in std_logic_vector (8 downto 0);
         WD : in std_logic_vector (3 downto 0);
         WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
         RD : out std_logic_vector (3 downto 0));
  end component;

  component RAM1024X2_25um is
  port (WA, RA : in std_logic_vector (9 downto 0);
        WD : in std_logic_vector (1 downto 0);
        WE, RE, WCLK, RCLK, ASYNCRD : in std_logic;
        RD : out std_logic_vector (1 downto 0) );
  end component;

  constant dlen : integer := dbits + 18;
  signal di1, q2, gnd : std_logic_vector(dlen downto 0);
  signal a1, a2 : std_logic_vector(12 downto 0);
begin

  gnd <= (others => '0');
  di1(dbits-1 downto 0) <= din; di1(dlen downto dbits) <= (others => '0');
  a1(abits-1 downto 0) <= waddr; a1(12 downto abits) <= (others => '0');
  a2(abits-1 downto 0) <= raddr; a2(12 downto abits) <= (others => '0');
  dout <= q2(dbits-1 downto 0); q2(dlen downto dbits) <= (others => '0');
  a7 : if (abits <= 7) generate
    x : for i in 0 to (dbits-1)/18 generate
      u0 : RAM128X18_25um port map (
        a1(6 downto 0), a2(6 downto 0), di1(i*18+17 downto i*18),
	write, rena, wclk, rclk, gnd(0), q2(i*18+17 downto i*18));
    end generate;
  end generate;
  a8 : if (abits = 8) generate
    x : for i in 0 to (dbits-1)/9 generate
      u0 : RAM256X9_25um port map (
        a1(7 downto 0), a2(7 downto 0), di1(i*9+8 downto i*9),
	write, rena, wclk, rclk, gnd(0), q2(i*9+8 downto i*9));
    end generate;
  end generate;
  a9 : if (abits = 9) generate
    x : for i in 0 to (dbits-1)/4 generate
      u0 : RAM512X4_25um port map (
        a1(8 downto 0), a2(8 downto 0), di1(i*4+3 downto i*4),
	write, rena, wclk, rclk, gnd(0), q2(i*4+3 downto i*4));
    end generate;
  end generate;
  a10 : if (abits = 10) generate
    x : for i in 0 to (dbits-1)/2 generate
      u0 : RAM1024X2_25um port map (
        a1(9 downto 0), a2(9 downto 0), di1(i*2+1 downto i*2),
	write, rena, wclk, rclk, gnd(0), q2(i*2+1 downto i*2));
    end generate;
  end generate;
-- pragma translate_off  
  unsup : if abits > 10 generate
    x : process
    begin
      assert false
      report  "Address depth larger than 10 is not supported for Eclipse rams"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on
end;
