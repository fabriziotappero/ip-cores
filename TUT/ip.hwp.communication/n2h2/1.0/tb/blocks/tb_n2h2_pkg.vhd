-------------------------------------------------------------------------------
-- Title      : Package for block-level testing of Nios-to-HIBI
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_n2h2_pkg.vhd
-- Author     : Ari Kulmala
-- Company    : 
-- Created    : 2005-03-22
-- Last update: 2011-11-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2005-03-22  1.0      AK	Created
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This file is part of HIBI
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;

package tb_n2h2_pkg is
  
  type     addr_array is array (0 to 7) of integer;

  -- Noc addresses (HIBI addresses). These identify the active reception channel of the N2H DMA block
  constant addresses_c     : addr_array := (200, 250, 300, 444, 555, 666, 777, 888);

  -- Addresses on the avalon bus to the memory = memory addresses of reception buffer
  -- arrays 
  constant ava_addresses_c : addr_array := (1000, 3333, 5555, 7000000, 9000000, 11000000, 13000000, 15000000);



  --  constant addresses_c : addr_array := (16#1000000#, 16#3000000#, 16#5000000#, 16#7000000#, 16#9000000#, 16#b000000#, 16#d000000#, 16#f000000#);
  --  constant ava_addresses_c : addr_array := (1000000, 3000000, 5000000, 7000000, 9000000, 11000000, 13000000, 15000000);

  constant conf_bits_c    : integer := 4;  -- number of configuration bits in CPU

  
  procedure read_conf_file (
    mem_addr      : out integer;
    dst_addr      : out integer;
    irq_amount    : out integer;
    --    max_amount    : out integer;
    file file_txt :     text);

  
  function log2 (
    constant x         : integer)
    return integer;


  --  -- This has become obsolete (2011-11-11)
  --  procedure read_data_file (
  --    data          : out integer;
  --    file file_txt :     text);


end tb_n2h2_pkg;

package body tb_n2h2_pkg is


  -- Reads ASCII file that stores info how to confgiure N2H DMA
  procedure read_conf_file (
    mem_addr      : out integer;
    dst_addr      : out integer;
    irq_amount    : out integer;
    file file_txt :     text) is
    
    variable file_row        : line;
    --variable file_sample     : integer;
    -- variable file_sample_hex : std_logic_vector(31 downto 0);
    variable sample_ok            : boolean := FALSE;
  begin

    -- Loop until finding a line that is not a comment
    while sample_ok = false and not(endfile(file_txt)) loop
      readline(file_txt, file_row);      
      read (file_row, mem_addr, sample_ok);

      if sample_ok = FALSE then
        --Reading of the delay value failed
        --=> assume that this line is comment or empty, and skip other it
        -- assert false report "Skipped a line" severity note;
        next;                           -- start new loop interation
      end if;


      read(file_row, dst_addr); --file_sample);
      --dst_addr   := file_sample;
      read(file_row, irq_amount); -- file_sample);
      --irq_amount := file_sample;
    end loop;

    

    --    readline(file_txt, file_row);
    --    --    hread(file_row, file_sample_hex);
    --    --    mem_addr   := conv_integer(file_sample_hex);
    --    --    hread(file_row, file_sample_hex);
    --    --    dst_addr     := conv_integer(file_sample_hex);
    --    read(file_row, file_sample, sample_ok);
    --    if sample_ok = true then
    --    assert sample_ok report "ei oo hyvä" severity note;
    --    mem_addr   := file_sample;
    --    read(file_row, file_sample);
    --    dst_addr   := file_sample;
    --    read(file_row, file_sample);
    --    irq_amount := file_sample;
    --    end if;
  end read_conf_file;


  -- Logarithm with base=2
  function log2 (
    constant x : integer)
    return integer is

    variable tmp_v : integer := 1;
    --variable i_v   : integer := 0;
  begin  -- log2
    --report "log2(x):x is " &  integer'image(x);
    
    for i in 0 to 31 loop
      if tmp_v >= x then
        -- report "ceil(log2(x)) is " &  integer'image(i);
        return i;
      end if;
      tmp_v := tmp_v * 2;        
    end loop;  -- i

    -- We should not ever come here, let's return a definitely illegal value
    assert false report "Error in function log2(x)" severity warning;
    return -1;
    
  end log2;


    
--  procedure read_data_file (
--    data          : out integer;
--    file file_txt :     text) is
    
--    variable file_row    : line;
--    variable file_sample : integer;
--  begin  -- read_data_file
--    readline(file_txt, file_row);
--    read(file_row, file_sample);
--    data := file_sample;
--  end read_data_file;


  
end tb_n2h2_pkg;
