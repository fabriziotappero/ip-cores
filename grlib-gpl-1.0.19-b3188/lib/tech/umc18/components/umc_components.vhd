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
-- Package: 	umc_components
-- File:	umc_components.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	UMC 0.18 component declarations
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package umc_components is

  -- input pad

  component ICMT3V port( A : in std_logic; Z : out std_logic); end component;

  -- input pad with pull-up

  component ICMT3VPU port( A : in std_logic; Z : out std_logic); end component;

  -- input pad with pull-down

  component ICMT3VPD port( A : in std_logic; Z : out std_logic); end component;

  -- schmitt input pad

  component ISTRT3V port( A : in std_logic; Z : out std_logic); end component;

  -- output pads

  component OCM3V4 port( Z : out std_logic; A : in std_logic); end component;
  component OCM3V12 port( Z : out std_logic; A : in std_logic); end component;
  component OCM3V24 port( Z : out std_logic; A : in std_logic); end component;


  -- tri-state output pads

  component OCMTR4 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component OCMTR12 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component OCMTR24 port( EN : in std_logic; A : in std_logic; Z : out std_logic); end component;

  -- bidirectional pads

  component BICM3V4 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component BICM3V12 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;
  component BICM3V24 port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end component;

  component LVDS_Driver port ( A, Vref, HI : in std_logic; Z, ZN : out std_logic); end component;
  component LVDS_Receiver port ( A, AN : in std_logic; Z : out std_logic); end component;
  component LVDS_Biasmodule port ( RefR : in std_logic; Vref, HI : out std_logic); end component;

  -- single-port memory

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

end;

