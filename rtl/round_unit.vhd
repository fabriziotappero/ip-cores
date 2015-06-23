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
use ieee.std_logic_unsigned.all;

use work.cryptopan.all;

entity round_unit is
  generic (
    do_mixcolumns :     boolean := true);
  port (
    bytes_in      : in  s_vector;
    bytes_out     : out s_vector;

    in_en  : in  std_logic;
    out_en : out std_logic;

    load_en   : in std_logic;
    load_data : in std_logic_vector(31 downto 0);

    load_clk : in std_logic;
    clk   : in std_logic;
    reset : in std_logic
    );

end round_unit;

architecture rtl of round_unit is

  component mixcolumns
    port (
      bytes_in  : in  s_vector;
      bytes_out : out s_vector;
      in_en     : in  std_logic;
      out_en    : out std_logic;
      clk       : in  std_logic;
      reset     : in  std_logic);
  end component;

  component subbytesshiftrows
    port (
      bytes_in    : in  s_vector;
      bytes_out   : out s_vector;
      in_en       : in  std_logic;
      out_en      : out std_logic;
      clk         : in  std_logic;
      reset       : in  std_logic);
  end component;
  signal sbsr_out :     s_vector;
  signal mix_out  :     s_vector;

  signal round_key : s_vector;
  signal round_out : s_vector;

  signal load_counter : std_logic_vector(1 downto 0);
  signal sbsr_out_en  : std_logic;
  signal mix_out_en : std_logic;
begin 

  bytes_out <= round_out;

  LOAD_LOGIC : process (load_clk, reset)
  begin
    if reset = '1' then
      for i in 0 to 15 loop
        round_key(i) <= (others => '0');
      end loop;
      load_counter   <= "00";

    elsif load_clk'event and load_clk = '1' then

      if load_en = '1' then
        if load_counter = "00" then
          round_key(12) <= load_data(7 downto 0);
          round_key(8)  <= load_data(15 downto 8);
          round_key(4)  <= load_data(23 downto 16);
          round_key(0)  <= load_data(31 downto 24);
        elsif load_counter = "01" then
          round_key(13) <= load_data(7 downto 0);
          round_key(9)  <= load_data(15 downto 8);
          round_key(5)  <= load_data(23 downto 16);
          round_key(1)  <= load_data(31 downto 24);
        elsif load_counter = "10" then
          round_key(14) <= load_data(7 downto 0);
          round_key(10) <= load_data(15 downto 8);
          round_key(6)  <= load_data(23 downto 16);
          round_key(2)  <= load_data(31 downto 24);
        elsif load_counter = "11" then
          round_key(15) <= load_data(7 downto 0);
          round_key(11) <= load_data(15 downto 8);
          round_key(7)  <= load_data(23 downto 16);
          round_key(3)  <= load_data(31 downto 24);
        end if;
        load_counter    <= load_counter + 1;
      else
        load_counter    <= "00";
      end if;
    end if;
  end process LOAD_LOGIC;

  SBSR0 : subbytesshiftrows
    port map (
      bytes_in  => bytes_in,
      bytes_out => sbsr_out,
      in_en     => in_en,
      out_en    => sbsr_out_en,
      clk       => clk,
      reset     => reset);

  out_en    <= mix_out_en;

  
  GENMIXCOLUMNS : if do_mixcolumns = true generate
    MIX0        : mixcolumns
      port map (
        bytes_in  => sbsr_out,
        bytes_out => mix_out,
        in_en => sbsr_out_en,
        out_en => mix_out_en,
        clk       => clk,
        reset     => reset);

  end generate GENMIXCOLUMNS;

  NO_GENMIXCOLUMNS : if do_mixcolumns = false generate
    mix_out <= sbsr_out;
    mix_out_en <= sbsr_out_en;
  end generate NO_GENMIXCOLUMNS;


  ROUND_XOR : for i in 0 to 15 generate
    round_out(i) <= round_key(i) xor mix_out(i);
  end generate ROUND_XOR;


end rtl;
