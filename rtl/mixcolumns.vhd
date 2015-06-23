--
-- This file is part of the Crypto-PAn core.
--
-- Copyright (c) 2007 The University of Waikato, Hamilton, New Zealand.
-- Authors: Anthony Blake (tonyb33@opencores.org)
--          
-- All rights reserved.
--
-- This code has been developed by the University of Waikato WAND 
-- research group. For further information please see http://www.wand.net.nz/
--
-- This source file is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This source is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with libtrace; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--

library ieee;
use ieee.std_logic_1164.all;

use work.cryptopan.all;

entity mixcolumns is

  port (
    bytes_in  : in  s_vector;
    bytes_out : out s_vector;

    in_en : in std_logic;
    out_en : out std_logic;

    clk   : in std_logic;
    reset : in std_logic
    );

end mixcolumns;

architecture rtl of mixcolumns is
  signal reg : s_vector;
  signal en_reg : std_logic;

  function transform(p : std_logic_vector(31 downto 0) ) return std_logic_vector is
    variable result     : std_logic_vector(7 downto 0);
    variable m, n       : std_logic_vector(7 downto 0);
  begin
    if(p(7) = '1') then
      m    := (p(30 downto 24) & '0') xor "00011011";
    else
      m    := (p(30 downto 24) & '0');
    end if;
    if(p(7) = '1') then
      n    := (p(22 downto 16) & '0') xor "00011011" xor p(23 downto 16);
    else
      n    := (p(22 downto 16) & '0') xor p(23 downto 16);
    end if;
    result := m xor n xor p(15 downto 8) xor p(7 downto 0);
    return result;
  end function transform;

begin 

  REGGEN: process (clk, reset)
  begin 
    if reset = '1' then                
      reg <= (others => (others => '0'));
      en_reg <= '0';
    elsif clk'event and clk = '1' then 
      reg <= bytes_in;
      en_reg <= in_en;
    end if;
  end process REGGEN;

  out_en <= en_reg;
  
  bytes_out(0) <= transform(reg(0) & reg(4) & reg(8) & reg(12));
  bytes_out(1) <= transform(reg(1) & reg(5) & reg(9) & reg(13));
  bytes_out(2) <= transform(reg(2) & reg(6) & reg(10) & reg(14));
  bytes_out(3) <= transform(reg(3) & reg(7) & reg(11) & reg(15));

  bytes_out(4) <= transform(reg(4) & reg(8) & reg(12) & reg(0));
  bytes_out(5) <= transform(reg(5) & reg(9) & reg(13) & reg(1));
  bytes_out(6) <= transform(reg(6) & reg(10) & reg(14) & reg(2));
  bytes_out(7) <= transform(reg(7) & reg(11) & reg(15) & reg(3));

  bytes_out(8) <= transform(reg(8) & reg(12) & reg(0) & reg(4));
  bytes_out(9) <= transform(reg(9) & reg(13) & reg(1) & reg(5));
  bytes_out(10) <= transform(reg(10) & reg(14) & reg(2) & reg(6));
  bytes_out(11) <= transform(reg(11) & reg(15) & reg(3) & reg(7));

  bytes_out(12) <= transform(reg(12) & reg(0) & reg(4) & reg(8));
  bytes_out(13) <= transform(reg(13) & reg(1) & reg(5) & reg(9));
  bytes_out(14) <= transform(reg(14) & reg(2) & reg(6) & reg(10));
  bytes_out(15) <= transform(reg(15) & reg(3) & reg(7) & reg(11));

  
end rtl;
