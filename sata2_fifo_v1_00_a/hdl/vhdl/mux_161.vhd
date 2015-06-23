-- Copyright (C) 2012
-- Ashwin A. Mendon
--
-- This file is part of SATA2 core.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.  


--------------------------------------------------------------------------------
-- Entity   mux_161 
-- Version: 1.0
-- Author:  Ashwin Mendon 
-- Description: 32 bit 16:1 Multiplexer
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity mux_161 is
  generic(
           DATA_WIDTH: natural := 32 
         );

  port(
    a      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    b      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    c      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    d      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    e      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    f      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    g	   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    h      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    i      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    j      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    k      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    l      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    m      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    n      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    o      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    p      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    sel    : in  std_logic_vector(3 downto 0);
    output : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end mux_161;       

architecture mux_behav of mux_161 is
begin
  process(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,sel)
  begin
    case (sel) is
     when "0000" => 
       	output <= a;
     when "0001" => 
       	output <= b;
     when "0010" => 
       	output <= c;
     when "0011" => 
       	output <= d;
     when "0100" => 
       	output <= e;
     when "0101" => 
       	output <= f;
     when "0110" => 
       	output <= g;
     when "0111" => 
       	output <= h;
     when "1000" => 
       	output <= i;
     when "1001" => 
       	output <= j;
     when "1010" => 
       	output <= k;
     when "1011" => 
       	output <= l;
     when "1100" => 
       	output <= m;
     when "1101" => 
       	output <= n;
     when "1110" => 
       	output <= o;
     when others => 
       	output <= p;
    end case;
  end process;
end mux_behav;

