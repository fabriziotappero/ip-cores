-------------------------------------------------------------------------------
-- Title      : Signal generator
-- Project    : Funbase
-------------------------------------------------------------------------------
-- File       : sig_gen.vhd
-- Author     : Juha Arvio
-- Company    : TUT
-- Last update: 2011-12-05
-- Version    : 0.1
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Generates a constant value to the output bus and an enable
--              signal that can be toggled.
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

entity sig_gen is
  generic (
    SIGNAL_VAL   : integer := 5000000;  -- Constant value driven to the output
    SIGNAL_WIDTH : integer := 32        -- In bits
    );
  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    toggle_in : in  std_logic;
    sig_out   : out std_logic_vector(SIGNAL_WIDTH-1 downto 0);
    ena_out   : out std_logic
    );

end sig_gen;

architecture rtl of sig_gen is
  
  function i2s(value : integer; width : integer) return std_logic_vector is
  begin
    return conv_std_logic_vector(value, width);
  end;

  function s2i(value : std_logic_vector) return integer is
  begin
    return conv_integer(value);
  end;

  signal toggle_d1_r : std_logic;
  signal ena_r       : std_logic;
begin
  
  sig_out <= i2s(SIGNAL_VAL, SIGNAL_WIDTH);
  ena_out <= ena_r;

  --
  -- Detects a rising edge in toggle-input 
  --
  process (clk, rst_n)
  begin
    if (rst_n = '0') then
      toggle_d1_r <= '0';
      ena_r       <= '0';
      
    elsif (clk'event and clk = '1') then
      toggle_d1_r <= toggle_in;

      if ((toggle_in = '1') and (toggle_d1_r = '0')) then
        ena_r <= not(ena_r);
      end if;
    end if;
  end process;
  
end rtl;
