-------------------------------------------------------------------------------
-- Title      : Port blinker
-- Project    : Funbase
-------------------------------------------------------------------------------
-- File       : port_blinker.vhd
-- Author     : Juha Arvio
-- Company    : TUT
-- Last update: 2011-12-05
-- Version    : 0.1
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Counts up and inverts output when reaching the limit value.
--              Then start over again.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 20.10.2011   0.1     arvio     Created
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
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

entity port_blinker is
  generic (
    SIGNAL_WIDTH : integer := 32
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    ena_in   : in  std_logic;
    val_in   : in  std_logic_vector(SIGNAL_WIDTH-1 downto 0);
    port_out : out std_logic
    );

end port_blinker;

architecture rtl of port_blinker is

  signal port_level_r : std_logic;
  signal val_cnt_r    : std_logic_vector(SIGNAL_WIDTH-1 downto 0);

begin
  
  port_out <= port_level_r;

  --
  -- Count upwards until reaching the value in the input
  -- 
  process (clk, rst_n)
  begin
    if (rst_n = '0') then
      port_level_r <= '0';
      val_cnt_r    <= (others => '0');
      
    elsif (clk'event and clk = '1') then
      
      if (ena_in = '0') then
        val_cnt_r <= (others => '0');
      else
        if (val_cnt_r = val_in) then
          port_level_r <= not(port_level_r);
          val_cnt_r    <= (others => '0');
        else
          val_cnt_r <= val_cnt_r + 1;
        end if;
      end if;
      
    end if;
  end process;
  
end rtl;
