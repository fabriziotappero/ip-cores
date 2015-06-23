-------------------------------------------------------------------------------
-- Title      : Reset generator for simulation
-- Project    : Nocbench & Funbase
-------------------------------------------------------------------------------
-- File       : rst_gen.vhd
-- Author     : ege
-- Created    : 2012-01-27
-- Last update: 2012-03-09
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

entity rst_gen is

  generic (
    active_period_ns_g : integer := 100  -- In nanoseconds
    );
  port (
    rst_n_out : out std_logic
    );

end rst_gen;


architecture behav of rst_gen is
  signal rst_tmp : std_logic := '0';    -- active low

begin  -- behav

  toggle: process (rst_tmp)
  begin  -- process toggle
    if rst_tmp = '0' then
      rst_tmp <= '1' after active_period_ns_g * 1 ns;
    end if;
  end process toggle;

  rst_n_out <= rst_tmp;
  
end behav;
