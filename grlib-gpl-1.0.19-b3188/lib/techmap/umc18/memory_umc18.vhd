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
-- File:	mem_umc_gen.vhd
-- Author:	Jiri Gaisler Gaisler Research
-- Description:	Memory generators for UMC rams
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
-- pragma translate_off
library umc18;
use umc18.SRAM_2048wx32b;
use umc18.SRAM_1024wx32b;
use umc18.SRAM_512wx32b;
use umc18.SRAM_256wx32b;
use umc18.SRAM_128wx32b;
use umc18.SRAM_64wx32b;
use umc18.SRAM_32wx32b;
use umc18.SRAM_2048wx40b;
use umc18.SRAM_1024wx40b;
use umc18.SRAM_512wx40b;
use umc18.SRAM_256wx40b;
use umc18.SRAM_128wx40b;
use umc18.SRAM_64wx40b;
use umc18.SRAM_32wx40b;
-- pragma translate_on

entity umc_syncram is
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

architecture rtl of umc_syncram is
  component SRAM_2048wx32b is
  port (
	a    : in  std_logic_vector(10 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_1024wx32b is
  port (
	a    : in  std_logic_vector(9 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_512wx32b is
  port (
	a    : in  std_logic_vector(8 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_256wx32b is
  port (
	a    : in  std_logic_vector(7 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_128wx32b is
  port (
	a    : in  std_logic_vector(6 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_64wx32b is
  port (
	a    : in  std_logic_vector(5 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_32wx32b is
  port (
	a    : in  std_logic_vector(4 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_2048wx40b is
  port (
	a    : in  std_logic_vector(10 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_1024wx40b is
  port (
	a    : in  std_logic_vector(9 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_512wx40b is
  port (
	a    : in  std_logic_vector(8 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_256wx40b is
  port (
	a    : in  std_logic_vector(7 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_128wx40b is
  port (
	a    : in  std_logic_vector(6 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_64wx40b is
  port (
	a    : in  std_logic_vector(5 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
  end component;

  component SRAM_32wx40b is
  port (
	a    : in  std_logic_vector(4 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
  end component;

  signal d, q, gnd : std_logic_vector(41 downto 0);
  signal a : std_logic_vector(17 downto 0);
  signal vcc, csn, wen : std_ulogic;
  constant synopsys_bug : std_logic_vector(41 downto 0) := (others => '0');
begin

  csn <= not enable; wen <= not write;
  gnd <= (others => '0'); vcc <= '1';
  a(abits -1 downto 0) <= address;
  d(dbits -1 downto 0) <= datain(dbits -1 downto 0);
  a(17 downto abits) <= synopsys_bug(17 downto abits);
  d(41 downto dbits) <= synopsys_bug(41 downto dbits);
  dataout <= q(dbits -1 downto 0);
--  q(41 downto dbits) <= synopsys_bug(41 downto dbits);

  d32 : if (dbits <= 32) generate
    a5d32 : if (abits <= 5) generate
      id0 : SRAM_32wx32b port map (a(4 downto 0), d(31 downto 0), csn,
				   wen, gnd(0), q(31 downto 0), clk);
    end generate;
    a6d32 : if (abits = 6) generate
      id0 : SRAM_64wx32b port map (a(5 downto 0), d(31 downto 0), csn,
				   wen, gnd(0), q(31 downto 0), clk);
    end generate;
    a7d32 : if (abits = 7) generate
      id0 : SRAM_128wx32b port map (a(6 downto 0), d(31 downto 0), csn,
				   wen, gnd(0), q(31 downto 0), clk);
    end generate;
    a8d32 : if (abits = 8) generate
      id0 : SRAM_256wx32b port map (a(7 downto 0), d(31 downto 0), csn,
				   wen, gnd(0), q(31 downto 0), clk);
    end generate;
    a9d32 : if (abits = 9) generate
      id0 : SRAM_512wx32b port map (a(8 downto 0), d(31 downto 0), csn,
				   wen, gnd(0), q(31 downto 0), clk);
    end generate;
    a10d32 : if (abits = 10) generate
      id0 : SRAM_1024wx32b port map (a(9 downto 0), d(31 downto 0), csn,
				   wen, gnd(0), q(31 downto 0), clk);
    end generate;
    a11d32 : if (abits = 11) generate
      id0 : SRAM_2048wx32b port map (a(10 downto 0), d(31 downto 0), csn,
				   wen, gnd(0), q(31 downto 0), clk);
    end generate;
  end generate;

  d40 : if (dbits > 32) and  (dbits <= 40) generate
    a5d40 : if (abits <= 5) generate
      id0 : SRAM_32wx40b port map (a(4 downto 0), d(39 downto 0), csn,
				   wen, gnd(0), q(39 downto 0), clk);
    end generate;
    a6d40 : if (abits = 6) generate
      id0 : SRAM_64wx40b port map (a(5 downto 0), d(39 downto 0), csn,
				   wen, gnd(0), q(39 downto 0), clk);
    end generate;
    a7d40 : if (abits = 7) generate
      id0 : SRAM_128wx40b port map (a(6 downto 0), d(39 downto 0), csn,
				   wen, gnd(0), q(39 downto 0), clk);
    end generate;
    a8d40 : if (abits = 8) generate
      id0 : SRAM_256wx40b port map (a(7 downto 0), d(39 downto 0), csn,
				   wen, gnd(0), q(39 downto 0), clk);
    end generate;
    a9d40 : if (abits = 9) generate
      id0 : SRAM_512wx40b port map (a(8 downto 0), d(39 downto 0), csn,
				   wen, gnd(0), q(39 downto 0), clk);
    end generate;
    a10d40 : if (abits = 10) generate
      id0 : SRAM_1024wx40b port map (a(9 downto 0), d(39 downto 0), csn,
				   wen, gnd(0), q(39 downto 0), clk);
    end generate;
    a11d40 : if (abits = 11) generate
      id0 : SRAM_2048wx40b port map (a(10 downto 0), d(39 downto 0), csn,
				   wen, gnd(0), q(39 downto 0), clk);
    end generate;
  end generate;

-- pragma translate_off
  a_to_high : if (abits > 12) or (dbits > 40) generate
    x : process
    begin
      assert false
      report  "Unsupported memory size (umc18)"
      severity failure;
      wait;
    end process;
  end generate;
-- pragma translate_on

end;
