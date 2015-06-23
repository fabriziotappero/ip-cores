--
-- This file is part of the Crypto-PAn core (www.opencores.org).
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
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;


entity cryptopan_unit_tb is

end cryptopan_unit_tb;

architecture tb of cryptopan_unit_tb is

  component cryptopan_unit
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      ready    : out std_logic;
      key      : in  std_logic_vector(255 downto 0);
      key_wren : in  std_logic;
      ip_in    : in  std_logic_vector(31 downto 0);
      ip_wren  : in  std_logic;
      ip_out   : out std_logic_vector(31 downto 0);
      ip_dv    : out std_logic);
  end component;

  signal clk   : std_logic;
  signal reset : std_logic;

  signal key            : std_logic_vector(255 downto 0);
  signal key_wren       : std_logic;
  signal ready          : std_logic;
  signal ip_in, ip_out  : std_logic_vector(31 downto 0);
  signal ip_wren, ip_dv : std_logic;

  type char_file is file of character;
  file bin_file_raw  : char_file is in "sim/trace_bin_raw";
  file bin_file_anon : char_file is in "sim/trace_bin_anon";

  signal ip_in_int  : std_logic_vector(31 downto 0);
  signal ip_out_int : std_logic_vector(31 downto 0);

begin

  CLKGEN : process
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process CLKGEN;

  DUT : cryptopan_unit
    port map (
      clk      => clk,
      reset    => reset,
      ready    => ready,
      key      => key,
      key_wren => key_wren,
      ip_in    => ip_in,
      ip_wren  => ip_wren,
      ip_out   => ip_out,
      ip_dv    => ip_dv);

  GEN_IPS            : process
    variable my_char : character;
  begin  -- process GEN_IPS
    -- file_open(bin_file_raw, "sim/trace_bin_raw", read_mode);

    ip_in_int <= (others => '0');
    ip_wren   <= '0';
    wait until ready = '1';
    wait for 50 ns;

    while not endfile(bin_file_raw) loop


      read(bin_file_raw, my_char);
      ip_in_int(31 downto 24) <= conv_std_logic_vector(character'pos(my_char), 8);
      read(bin_file_raw, my_char);
      ip_in_int(23 downto 16) <= conv_std_logic_vector(character'pos(my_char), 8);
      read(bin_file_raw, my_char);
      ip_in_int(15 downto 8)  <= conv_std_logic_vector(character'pos(my_char), 8);
      read(bin_file_raw, my_char);
      ip_in_int(7 downto 0)   <= conv_std_logic_vector(character'pos(my_char), 8);
      wait for 10 ns;
      ip_wren                 <= '1';

      wait for 10 ns;

      ip_wren <= '0';

      wait until ready = '1';
    end loop;
    report "TEST COMPLETED" severity note;

  end process GEN_IPS;

  IP_OUT_INT_LOGIC : process
    variable my_char : character;
  begin  -- process IP_OUT_INT_LOGIC
    --ip_out_int <= (others => '0');
    wait until ip_dv = '1';
    read(bin_file_anon, my_char);
    ip_out_int(31 downto 24) <= conv_std_logic_vector(character'pos(my_char), 8);
    read(bin_file_anon, my_char);
    ip_out_int(23 downto 16) <= conv_std_logic_vector(character'pos(my_char), 8);
    read(bin_file_anon, my_char);
    ip_out_int(15 downto 8)  <= conv_std_logic_vector(character'pos(my_char), 8);
    read(bin_file_anon, my_char);
    ip_out_int(7 downto 0)   <= conv_std_logic_vector(character'pos(my_char), 8);

  end process IP_OUT_INT_LOGIC;

  DV_LOGIC           : process(clk)
    variable my_char : character;
  begin  -- process DV_LOGIC
    if clk'event and clk = '1' then
      if ip_dv = '1' then
        assert ip_out_int = ip_out report "TEST FAILED" severity error;
      end if;
    end if;
  end process DV_LOGIC;


  ip_in <= ip_in_int;

  TESTBENCH : process
  begin
    reset    <= '1';
-- ip_in <= (others => '0');
    key      <= (others => '0');
-- ip_wren <= '0';
    key_wren <= '0';
    wait for 50 ns;
    reset    <= '0';
    wait for 20 ns;
    key      <= X"d8988f837979652762574c2d2a8422021522178d33a4cf80130a5b1649907d10";
    key_wren <= '1';
    wait for 10 ns;
    key_wren <= '0';
-- wait until ready='1';
-- wait for 40 ns;
-- ip_in <= X"18050050";
-- ip_wren <= '1';
-- wait for 10 ns;
-- ip_wren <= '0';
-- wait until ready='1';
    wait;
  end process TESTBENCH;



end tb;
