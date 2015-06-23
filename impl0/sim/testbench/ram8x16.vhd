--------------------------------------------------------------
-- ram8x16.vhd
--------------------------------------------------------------
-- project: HPC-16 Microprocessor
--
-- usage: RAM with async read and sync write operation (not synthsizable, without timing params)
--
-- dependency: none 
--
-- Author: M. Umair Siddiqui (umairsiddiqui@opencores.org)
---------------------------------------------------------------
------------------------------------------------------------------------------------
--                                                                                --
--    Copyright (c) 2005, M. Umair Siddiqui all rights reserved                   --
--                                                                                --
--    This file is part of HPC-16.                                                --
--                                                                                --
--    HPC-16 is free software; you can redistribute it and/or modify              --
--    it under the terms of the GNU Lesser General Public License as published by --
--    the Free Software Foundation; either version 2.1 of the License, or         --
--    (at your option) any later version.                                         --
--                                                                                --
--    HPC-16 is distributed in the hope that it will be useful,                   --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of              --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               --
--    GNU Lesser General Public License for more details.                         --
--                                                                                --
--    You should have received a copy of the GNU Lesser General Public License    --
--    along with HPC-16; if not, write to the Free Software                       --
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   --
--                                                                                --
------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
---------------------------------------------
entity ram8x16 is
  generic
  (
    init_0 : std_logic_vector(15 downto 0) := (others => '0');
    init_1 : std_logic_vector(15 downto 0) := (others => '0');
    init_2 : std_logic_vector(15 downto 0) := (others => '0');
    init_3 : std_logic_vector(15 downto 0) := (others => '0');
    init_4 : std_logic_vector(15 downto 0) := (others => '0');
    init_5 : std_logic_vector(15 downto 0) := (others => '0');
    init_6 : std_logic_vector(15 downto 0) := (others => '0');
    init_7 : std_logic_vector(15 downto 0) := (others => '0')    
  );
  port
  (
    clk : in std_logic;
    adr : in std_logic_vector(2 downto 0);
    dat_i : in std_logic_vector(15 downto 0);
    --
    cs : in std_logic;
    we : in std_logic;
    ub : in std_logic;
    lb : in std_logic;
    oe : in std_logic;
    --
    dat_o : out std_logic_vector(15 downto 0)
  );
end ram8x16;
-------------------------------------------
architecture sim of ram8x16 is
  type rtype is array(0 to 7) of std_logic_vector(7 downto 0);
  shared variable ram_data_lower : rtype := ( init_0(7 downto 0),
                                     init_1(7 downto 0),
                                     init_2(7 downto 0),
                                     init_3(7 downto 0),
                                     init_4(7 downto 0),
                                     init_5(7 downto 0),
                                     init_6(7 downto 0),
                                     init_7(7 downto 0));
  shared variable ram_data_upper : rtype := ( init_0(15 downto 8),
                                     init_1(15 downto 8),
                                     init_2(15 downto 8),
                                     init_3(15 downto 8),
                                     init_4(15 downto 8),
                                     init_5(15 downto 8),
                                     init_6(15 downto 8),
                                     init_7(15 downto 8));
  
  signal write_lower : std_logic;
  signal write_upper : std_logic;
  signal out_lower : std_logic;
  signal out_upper : std_logic;  
begin
  ----------------------------------------------------------------------------
  -- main
  ----------------------------------------------------------------------------
  write_low: write_lower <= cs and we and lb;
  write_up : write_upper <= cs and we and ub;
  ----------------------------------------------------------------------------
  upper: process(clk)
  begin
    if rising_edge(clk) then
      if write_upper = '1' then
        ram_data_upper(conv_integer(adr)) := dat_i(15 downto 8);          
      end if;  
    end if;
  end process upper;
  ----------------------------------------------------------------------------
  lower: process(clk)
  begin
    if rising_edge(clk) then
      if write_lower = '1' then
        ram_data_lower(conv_integer(adr)) := dat_i(7 downto 0);
      end if;
    end if;
  end process lower;
  -----------------------------------------------------------------------
  out_low : out_lower <= cs and (not we) and lb and oe;
  out_up  : out_upper <= cs and (not we) and ub and oe;
  ----------------------------------------------------------------------
  dat_up   : dat_o(15 downto 8) <= ram_data_upper(conv_integer(adr)) when out_upper = '1' else
                                  (others => 'Z');
  dat_low  : dat_o(7 downto 0)  <= ram_data_lower(conv_integer(adr)) when out_lower = '1' else
                                  (others => 'Z');
  ----------------------------------------------------------------------  
end sim;
