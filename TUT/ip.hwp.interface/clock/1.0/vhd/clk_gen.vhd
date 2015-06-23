-------------------------------------------------------------------------------
-- Title      : Clock generator for simulation
-- Project    : Nocbench & Funbase
-------------------------------------------------------------------------------
-- File       : clk_gen.vhd
-- Author     : ege
-- Created    : 2012-01-27
-- Last update: 2012-01-31
-- Description: Just toggles the 1-bit clock output forever.
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2010
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- April 2010   1.0     ege     First version
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

entity clk_gen is

  generic (
    hi_period_ns_g : integer := 1;      -- In nanoseconds
    lo_period_ns_g : integer := 1       -- In nanoseconds
    );
  port (
    clk_out : out std_logic
    );

end clk_gen;

architecture behav of clk_gen is

  signal clk_tmp : std_logic := '0';
  
begin  -- behav
  
  clk_out <= clk_tmp;

  toggle : process (clk_tmp)
  begin  -- process toggle
    if clk_tmp = '0' then
      clk_tmp <= '1' after lo_period_ns_g * 1 ns;
    else
      clk_tmp <= '0' after hi_period_ns_g * 1 ns;      
    end if;
  end process toggle;


  
end behav;
