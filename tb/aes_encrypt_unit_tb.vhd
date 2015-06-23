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

entity aes_encrypt_unit_tb is
  
end aes_encrypt_unit_tb;

architecture tb of aes_encrypt_unit_tb is

  component aes_encrypt_unit
    port (
      key_in    : in  std_logic_vector(127 downto 0);
      key_wren  : in  std_logic;
      ready     : out std_logic;
      data_in   : in  std_logic_vector(127 downto 0);
      data_wren : in  std_logic;
      data_dv   : out std_logic;
      data_out  : out std_logic_vector(127 downto 0);
      clk       : in  std_logic;
      reset     : in  std_logic);
  end component;
  
  signal clk : std_logic;
  signal reset : std_logic;

  signal key_in : std_logic_vector(127 downto 0);
  signal key_wren : std_logic;
  signal ready : std_logic;
  signal data_in : std_logic_vector(127 downto 0);
  signal data_wren : std_logic;
  signal data_dv : std_logic;
  signal data_out : std_logic_vector(127 downto 0);
  

begin  

  CLKGEN: process
  begin 
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process CLKGEN;

  CRYPT0: aes_encrypt_unit
    port map (
        key_in    => key_in,
        key_wren  => key_wren,
        ready     => ready,
        data_in   => data_in,
        data_wren => data_wren,
        data_dv   => data_dv,
        data_out  => data_out,
        clk       => clk,
        reset     => reset);

  TESTBENCH: process
  begin 
    reset <= '1';
    data_in <= (others => '0');
    key_in <= (others => '0');
    data_wren <= '0';
    key_wren <= '0';
    wait for 50 ns;
    reset <= '0';
    wait for 20 ns;
    key_in <= X"2b7e151628aed2a6abf7158809cf4f3c";
    key_wren <= '1';
    wait for 10 ns;
    key_wren <= '0';

    wait until ready='1';
    wait for 40 ns;

    data_in <= X"3243f6a8885a308d313198a2e0370734";
    data_wren <= '1';
    wait for 10 ns;
    data_in <= X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    wait for 10 ns;
    data_in <= X"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
    wait for 10 ns;
    data_in <= X"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC";
    wait for 10 ns;
    data_in <= X"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD";
    wait for 10 ns;
    data_in <= X"3243f6a8885a308d313198a2e0370734";
    wait for 10 ns;
    data_in <= X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    wait for 10 ns;
    data_in <= X"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB";
    wait for 10 ns;
    data_in <= X"CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC";
    wait for 10 ns;
    data_in <= X"DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD";
    wait for 10 ns;
    data_in <= X"3243f6a8885a308d313198a2e0370734";
    wait for 10 ns;
    
    data_wren <= '0';
    data_in <= (others => '0');
    wait until data_dv='1';
    
    wait;
    
    
  end process TESTBENCH;

end tb;
