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
-- Package: 	umc_simprims
-- File:	umc_simprims.vhd
-- Author:	Jiri Gaisler - Gaisler Research
-- Description:	Simple UMC 0.18 simulation models
------------------------------------------------------------------------------

-- pragma translate_off
  
-- input pad

library ieee;
use ieee.std_logic_1164.all;

entity ICMT3V is port( A : in std_logic; Z : out std_logic); end ;
architecture behav of ICMT3V is begin Z <= to_X01(A) after 1 ns; end;

-- input pad with pull-up

library ieee;
use ieee.std_logic_1164.all;

entity ICMT3VPU is port( A : in std_logic; Z : out std_logic); end ;
architecture behav of ICMT3VPU is begin 
  Z <= to_X01(A) after 1 ns; --A <= 'H';
end;

-- input pad with pull-down

library ieee;
use ieee.std_logic_1164.all;

entity ICMT3VPD is port( A : in std_logic; Z : out std_logic); end ;
architecture behav of ICMT3VPD is begin 
  Z <= to_X01(A) after 1 ns; --A <= 'L';
end;

-- schmitt input pad

library ieee;
use ieee.std_logic_1164.all;

entity ISTRT3V is port( A : in std_logic; Z : out std_logic); end ;
architecture behav of ISTRT3V is begin Z <= to_X01(A) after 1 ns; end;

-- output pads

library ieee;
use ieee.std_logic_1164.all;

entity OCM3V4 is port( Z : out std_logic; A : in std_logic); end;
architecture behav of OCM3V4 is begin Z <= to_X01(A) after 3 ns; end;

library ieee;
use ieee.std_logic_1164.all;

entity OCM3V12 is port( Z : out std_logic; A : in std_logic); end;
architecture behav of OCM3V12 is begin Z <= to_X01(A) after 2 ns; end;

library ieee;
use ieee.std_logic_1164.all;

entity OCM3V24 is port( Z : out std_logic; A : in std_logic); end;
architecture behav of OCM3V24 is begin Z <= to_X01(A) after 1 ns; end;


-- tri-state output pads

library ieee;
use ieee.std_logic_1164.all;

entity OCMTR4 is port( EN : in std_logic; A : in std_logic; Z : out std_logic); end;
architecture behav of OCMTR4 is begin 
  Z <= to_X01(A) after 3 ns when to_X01(en) = '1' else
             'Z' after 3 ns when to_X01(en) = '0' else 'X' after 3 ns; 
end;

library ieee;
use ieee.std_logic_1164.all;

entity OCMTR12 is port( EN : in std_logic; A : in std_logic; Z : out std_logic); end;
architecture behav of OCMTR12 is begin 
  Z <= to_X01(A) after 2 ns when to_X01(en) = '1' else
             'Z' after 2 ns when to_X01(en) = '0' else 'X' after 2 ns; 
end;

library ieee;
use ieee.std_logic_1164.all;

entity OCMTR24 is port( EN : in std_logic; A : in std_logic; Z : out std_logic); end;
architecture behav of OCMTR24 is begin 
  Z <= to_X01(A) after 1 ns when to_X01(en) = '1' else
             'Z' after 1 ns when to_X01(en) = '0' else 'X' after 1 ns; 
end;

-- bidirectional pads

library ieee;
use ieee.std_logic_1164.all;

entity BICM3V4 is port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end;
architecture behav of BICM3V4 is begin 
  IO <= to_X01(A) after 3 ns when to_X01(en) = '1' else
             'Z' after 3 ns when to_X01(en) = '0' else 'X' after 3 ns; 
  Z <= to_X01(IO) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;

entity BICM3V12 is port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end;
architecture behav of BICM3V12 is begin 
  IO <= to_X01(A) after 2 ns when to_X01(en) = '1' else
             'Z' after 2 ns when to_X01(en) = '0' else 'X' after 2 ns; 
  Z <= to_X01(IO) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;

entity BICM3V24 is port( IO : inout std_logic; EN : in std_logic; A : in std_logic; Z : out std_logic); end;
architecture behav of BICM3V24 is begin 
  IO <= to_X01(A) after 1 ns when to_X01(en) = '1' else
             'Z' after 1 ns when to_X01(en) = '0' else 'X' after 1 ns; 
  Z <= to_X01(IO) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;
entity LVDS_Receiver is port(  A, AN : in std_logic; Z : out std_logic); end; 
architecture struct of LVDS_Receiver is 
signal yn : std_ulogic := '0';
begin 
  yn <= to_X01(A) after 1 ns when to_x01(A xor AN) = '1' else yn after 1 ns;
  Z <= yn;
end;

library ieee;
use ieee.std_logic_1164.all;
entity LVDS_Driver is port (A, Vref, HI : in std_logic; Z, ZN : out std_logic ); end; 
architecture struct of LVDS_Driver is begin 
  Z <= A after 1 ns; 
  ZN <= not A after 1 ns; 
end;

library ieee;
use ieee.std_logic_1164.all;
entity LVDS_Biasmodule is port ( RefR : in std_logic; Vref, HI : out std_logic); end;
architecture struct of LVDS_Biasmodule is begin end;

-- single-port memory

library ieee;
use ieee.std_logic_1164.all;
library grlib;
use grlib.stdlib.all;

entity UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of UMC_SIM_SRAM is
subtype memword is std_logic_vector(dbits-1 downto 0);
type mem_type is array (0 to 2**abits-1) of memword;
signal qint : memword;
begin
  m : process(clk)
  variable mem : mem_type;
  begin
    if rising_edge(clk) then
      qint <= (others => 'X');
      if to_X01(wen) = '0' then mem(conv_integer(a)) := data;
      elsif to_X01(wen) = '1' then qint <= mem(conv_integer(a)); end if;
    end if;
  end process;

  q <= qint when to_X01(oen) = '0' else
        (others => 'Z') when to_X01(oen) = '1' else (others => 'X');
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_2048wx32b is
  port (
	a    : in  std_logic_vector(10 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_2048wx32b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (11, 32) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_1024wx32b is
  port (
	a    : in  std_logic_vector(9 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_1024wx32b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (10, 32) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_512wx32b is
  port (
	a    : in  std_logic_vector(8 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_512wx32b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (9, 32) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_256wx32b is
  port (
	a    : in  std_logic_vector(7 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_256wx32b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (8, 32) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_128wx32b is
  port (
	a    : in  std_logic_vector(6 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_128wx32b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (7, 32) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_64wx32b is
  port (
	a    : in  std_logic_vector(5 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_64wx32b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (6, 32) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_32wx32b is
  port (
	a    : in  std_logic_vector(4 downto 0);
	data : in  std_logic_vector(31 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(31 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_32wx32b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (5, 32) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_2048wx40b is
  port (
	a    : in  std_logic_vector(10 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_2048wx40b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (11, 40) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_1024wx40b is
  port (
	a    : in  std_logic_vector(9 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_1024wx40b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (10, 40) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_512wx40b is
  port (
	a    : in  std_logic_vector(8 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_512wx40b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (9, 40) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_256wx40b is
  port (
	a    : in  std_logic_vector(7 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_256wx40b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (8, 40) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_128wx40b is
  port (
	a    : in  std_logic_vector(6 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_128wx40b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (7, 40) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_64wx40b is
  port (
	a    : in  std_logic_vector(5 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_64wx40b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (6, 40) port map (a, data, csn, wen, oen, q, clk);
end;

library ieee;
use ieee.std_logic_1164.all;

entity SRAM_32wx40b is
  port (
	a    : in  std_logic_vector(4 downto 0);
	data : in  std_logic_vector(39 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(39 downto 0);
	clk  : in  std_logic
       );
end;
architecture behav of SRAM_32wx40b is
  component UMC_SIM_SRAM is
  generic (abits, dbits : integer := 8);
  port (
	a    : in  std_logic_vector(abits-1 downto 0);
	data : in  std_logic_vector(dbits-1 downto 0);
	csn  : in  std_logic;
	wen  : in  std_logic;
	oen  : in  std_logic;
	q    : out std_logic_vector(dbits-1 downto 0);
	clk  : in  std_logic
       );
  end component;
begin
 m : UMC_SIM_SRAM generic map (5, 40) port map (a, data, csn, wen, oen, q, clk);
end;

-- pragma translate_on
