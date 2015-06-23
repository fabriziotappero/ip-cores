--------------------------------------------------------------
-- ramNx16.vhd
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
-- synopsis synthesis_off
use std.textio.all;
use ieee.std_logic_textio.all;
-- synopsis synthesis_on
-------------------------------------
entity ramNx16 is 
  generic
  (
    -- synopsis synthesis_off
    init_file_name : string := "init_ramNx16.txt";
    -- synopsis synthesis_on
    adr_width : integer := 4;
    dat_width : integer := 16    
  );
  port
  (
    clk : in std_logic;
    adr : in std_logic_vector(adr_width - 1 downto 0);
    dat_i : in std_logic_vector(dat_width - 1 downto 0);
    --
    cs : in std_logic;
    we : in std_logic;
    ub : in std_logic;
    lb : in std_logic;
    oe : in std_logic;
    --
    dat_o : out std_logic_vector(dat_width - 1 downto 0)
  );
end ramNx16;
-----------------------------------------------------------------------
-----------------------------------------------------------------------
architecture async of ramNx16 is
  constant locs : integer := 2 ** adr_width;
  type rtype is array(0 to locs - 1) of std_logic_vector((dat_width/2) - 1 downto 0);
  shared variable ram_data_lower : rtype;
  shared variable ram_data_upper : rtype;
  --
  signal s_init : boolean := false;
  --
  signal write_lower : std_logic;
  signal write_upper : std_logic;
  signal out_lower : std_logic;
  signal out_upper : std_logic;  
begin
  ----------------------------------------------------------------------------
  -- assertion  
  ----------------------------------------------------------------------------
  assert dat_width = 16
    report "module is designed for 16-bit data"
    severity error;  
  ----------------------------------------------------------------------------
  -- init
  ----------------------------------------------------------------------------
  -- synopsis sythesis_off
  init: process
    file init_file : text;
    variable buf : line;
    variable address: integer;
    variable sep : character;
    variable data : std_logic_vector(dat_width - 1 downto 0);    
  begin
    if ((not s_init) and (init_file_name /= "none")) then
      file_open(init_file, init_file_name, read_mode);
      while (not endfile(init_file)) loop
        readline(init_file, buf);
        read(buf, address);
        read(buf, sep);
        read(buf, data);
        ram_data_lower(address) := data(7 downto 0);
        ram_data_upper(address) := data(15 downto 8);
      end loop;
      file_close(init_file);
      s_init <= true;
    end if; 
    wait; 
  end process init;
  -- synopsis synthesis_on
  ----------------------------------------------------------------------------
  -- main
  ----------------------------------------------------------------------------
  write_low: write_lower <= cs and lb and we;
  write_up : write_upper <= cs and ub and we;
  ----------------------------------------------------------------------------
  upper: process(clk)
  begin
    -- synopsis synthesis_off
    if (s_init) then
    -- synopsis synthesis_on
      if rising_edge(clk) then
        if write_upper = '1' then
          ram_data_upper(conv_integer(adr)) := dat_i(15 downto 8);              
        end if;
      end if;
    -- synopsis synthesis_off
    end if;
    -- synopsis synthesis_on
  end process upper;
  ----------------------------------------------------------------------------
  lower: process(clk)
  begin
    -- synopsis synthesis_off
    if (s_init) then
    -- synopsis synthesis_on
      if rising_edge(clk) then
          if write_lower = '1' then
            ram_data_lower(conv_integer(adr)) := dat_i(7 downto 0);              
          end if;
      end if;
    -- synopsis synthesis_off
    end if;
    -- synopsis synthesis_on
  end process lower;
  -----------------------------------------------------------------------
  out_low : out_lower <= cs and lb and (not we) and oe;
  out_up  : out_upper <= cs and ub and (not we) and oe;
  ----------------------------------------------------------------------
  dat_low : dat_o(15 downto 8) <= ram_data_upper(conv_integer(adr)) when out_upper = '1' else
                                  (others => 'Z');
  dat_up  : dat_o(7 downto 0)  <= ram_data_lower(conv_integer(adr)) when out_lower = '1' else
                                  (others => 'Z');
  ----------------------------------------------------------------------                      
end async;
