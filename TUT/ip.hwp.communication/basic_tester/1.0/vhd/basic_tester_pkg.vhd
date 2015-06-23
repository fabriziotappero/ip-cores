-------------------------------------------------------------------------------
-- Title      : Package includes a file reading function
-- Project    : 
-------------------------------------------------------------------------------
-- File       : basic_tester_pkg.vhd
-- Author     : ege
-- Created    : 2010-03-24
-- Last update: 2012-02-06
--
--
-------------------------------------------------------------------------------
-- Copyright (c) 2010
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
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
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;          -- 2010-10-06 for hread

package basic_tester_pkg is

  procedure read_conf_file (
    variable delay        : out integer;
    variable dest_agent_n : out integer;
    variable value        : out integer;
    variable cmd          : out integer;
    file conf_dat         :     text);

end package basic_tester_pkg;



package body basic_tester_pkg is

  -- Reads the (opened) file that is given as paremter.
  -- The file line structure is as follows:
  --  1st hex value: delay cycles before sending
  --  2nd hex value: destination addr
  --  3rd hew value: data value to be sent.
  --  4th hex value: HIBI command (optional)
  procedure read_conf_file (
    delay         : out integer;
    dest_agent_n  : out integer;
    value         : out integer;
    cmd           : out integer;
    file conf_dat :     text) is

    variable filerow_v : line;
    
    variable delay_v        : integer;
    variable delay2_v       : std_logic_vector (16-1 downto 0);
    variable dest_agent_n_v : std_logic_vector (32-1 downto 0);
    variable data_val_v     : std_logic_vector (32-1 downto 0);
    variable cmd_v          : std_logic_vector (8-1 downto 0);

    variable delay_ok_v : boolean := false;
    variable cmd_ok_v   : boolean := false;
    
  begin  -- read_conf_file

    -- Loop until finding a line that is not a comment
    while delay_ok_v = false and not(endfile(conf_dat)) loop
      readline(conf_dat, filerow_v);

      hread (filerow_v, delay2_v, delay_ok_v);

      if delay_ok_v = false then
        --Reading of the delay value failed
        --=> assume that this line is comment or empty, and skip other it
        -- assert false report "Skipped a line" severity note;
        next;                           -- start new loop interation
      end if;

      delay_v := to_integer(signed(delay2_v));
      --assert false report "tx delay cycles: " & integer'image (delay_v)
      -- severity note;      

      hread (filerow_v, dest_agent_n_v);
      hread (filerow_v, data_val_v);
      hread (filerow_v, cmd_v, cmd_ok_v);
      if cmd_ok_v = false then
        cmd_v := x"FF";
      end if;

      -- Return the values
      delay        := delay_v;
      dest_agent_n := to_integer(signed (dest_agent_n_v));
      value        := to_integer(signed (data_val_v));
      cmd          := to_integer(signed (cmd_v));
    end loop;

  end read_conf_file;
  
end package body basic_tester_pkg;
