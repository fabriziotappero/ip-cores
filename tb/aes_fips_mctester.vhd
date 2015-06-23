--*************************************************************************
-- Project    : AES128                                                    *
--                                                                        *
-- Block Name : aes_fips_mctester.vhd                                     *
--                                                                        *
-- Author     : Hemanth Satyanarayana                                     *
--                                                                        *
-- Email      : hemanth@opencores.org                                     *
--                                                                        *
-- Description: Test bench module to test the aes implemntation           *
--              for Monte-Carlo based tests.                              *
--                         .                                              *
--                                                                        *
-- Revision History                                                       *
-- |-----------|-------------|---------|---------------------------------|*
-- |   Name    |    Date     | Version |          Revision details       |*
-- |-----------|-------------|---------|---------------------------------|*
-- | Hemanth   | 15-Dec-2004 | 1.1.1.1 |            Uploaded             |*
-- |-----------|-------------|---------|---------------------------------|*
--                                                                        *
--  Refer FIPS-KAT Document for details                                   *
--*************************************************************************
--                                                                        *
-- Copyright (C) 2004 Author                                              *
--                                                                        *
-- This source file may be used and distributed without                   *
-- restriction provided that this copyright statement is not              *
-- removed from the file and that any derivative work contains            *
-- the original copyright notice and the associated disclaimer.           *
--                                                                        *
-- This source file is free software; you can redistribute it             *
-- and/or modify it under the terms of the GNU Lesser General             *
-- Public License as published by the Free Software Foundation;           *
-- either version 2.1 of the License, or (at your option) any             *
-- later version.                                                         *
--                                                                        *
-- This source is distributed in the hope that it will be                 *
-- useful, but WITHOUT ANY WARRANTY; without even the implied             *
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR                *
-- PURPOSE.  See the GNU Lesser General Public License for more           *
-- details.                                                               *
--                                                                        *
-- You should have received a copy of the GNU Lesser General              *
-- Public License along with this source; if not, download it             *
-- from http://www.opencores.org/lgpl.shtml                               *
--                                                                        *
--*************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.math_real.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library std_developerskit;
use std_developerskit.std_iopak.all;

entity aes_fips_mctester is end aes_fips_mctester;

architecture behavioral of aes_fips_mctester is

component aes128_fast
port(
      clk       : in std_logic;
      reset     : in std_logic;
      start     : in std_logic;
      mode      : in std_logic;
      load      : in std_logic;
      key       : in std_logic_vector(63 downto 0);
      data_in   : in std_logic_vector(63 downto 0);
      data_out  : out std_logic_vector(127 downto 0);
      done      : out std_logic
     );
     
end component;

signal clock_tb: std_logic:='0';
signal reset_tb: std_logic:='0';
signal start_tb: std_logic:='0';
signal load_tb: std_logic:='0';
signal done_tb: std_logic;
--#############################
signal mode_tb: std_logic:='1'; -- 1-> encode; 0-> decode
--#############################
signal data_in_tb: std_logic_vector(63 downto 0):=X"0000000000000000";
signal data_out_tb: std_logic_vector(127 downto 0);
signal key_tb: std_logic_vector(63 downto 0):=X"0000000000000000";
signal chk: integer:=0;

begin

clock_tb <= not clock_tb after 50 ns;
reset_tb <= '1','0' after 150 ns;

aes_i: aes128_fast
       port map(
                  clk      => clock_tb,
                  reset    => reset_tb,
                  start    => start_tb,
                  mode     => mode_tb,
                  load     => load_tb,
                  key      => key_tb,
                  data_in  => data_in_tb,
                  data_out => data_out_tb,
                  done     => done_tb
                 );

process
file infile : text open read_mode is "ecb_e_m.txt";
file outfile: text open write_mode is "ecb_e_m_results.txt";
variable inline       : line;
variable outline      : line;
variable itr_numline  : string(1 to 2);
variable key_line     : string(1 to 4);
variable pt_line      : string(1 to 3);
variable ct_line      : string(1 to 3);
variable iteration_num: integer;
variable hex_key_str  : string(1 to 32);
variable pt_str       : string(1 to 32);
variable ct_str       : string(1 to 32);
variable exp_cipher   : std_logic_vector(127 downto 0);
variable next_round_data: std_logic_vector(127 downto 0):=X"00000000000000000000000000000000";
begin
  wait for 1 ns;
  wait until reset_tb = '0';
  write(outline,string'("Monte-Carlo Encryption Tests"));
  writeline(outfile,outline);
  write(outline,string'("----------------------------"));
  writeline(outfile,outline);
  while(not endfile(infile)) loop
    wait until rising_edge(clock_tb);
    wait until rising_edge(clock_tb);
    readline(infile,inline);
    read(inline,itr_numline);
    read(inline,iteration_num);
    readline(infile,inline);
    read(inline,key_line);
    read(inline,hex_key_str);
    readline(infile,inline);
    read(inline,pt_line);
    read(inline,pt_str);
    readline(infile,inline);
    read(inline,ct_line);
    read(inline,ct_str);
    exp_cipher := to_StdLogicVector(From_HexString(ct_str));
    for j in 0 to 9999 loop
      chk <= j;
      if(j = 0) then
        wait until rising_edge(clock_tb);
        load_tb <= '1';
        key_tb <= to_StdLogicVector(From_HexString(hex_key_str(1 to 16)));
        data_in_tb <= to_StdLogicVector(From_HexString(pt_str(1 to 16)));
        wait until rising_edge(clock_tb);
        load_tb <= '0';
        key_tb <= to_StdLogicVector(From_HexString(hex_key_str(17 to 32)));
        data_in_tb <= to_StdLogicVector(From_HexString(pt_str(17 to 32)));
      else
        wait until rising_edge(clock_tb);
        load_tb <= '1';
        key_tb <= to_StdLogicVector(From_HexString(hex_key_str(1 to 16)));
        data_in_tb <= next_round_data(127 downto 64);
        wait until rising_edge(clock_tb);
        load_tb <= '0';
        key_tb <= to_StdLogicVector(From_HexString(hex_key_str(17 to 32)));
        data_in_tb <= next_round_data(63 downto 0);
      end if;  
      wait until rising_edge(clock_tb);
      wait until rising_edge(clock_tb);
      start_tb <= '1';
      wait until rising_edge(clock_tb);
      start_tb <= '0';    
      wait until done_tb = '1';
      wait until rising_edge(clock_tb);
      next_round_data := data_out_tb;
      wait until rising_edge(clock_tb);
    end loop;
    write(outline,string'("Round Number - "));
    write(outline,iteration_num);
    writeline(outfile,outline);
    write(outline,string'("Result: "));
    if(data_out_tb = exp_cipher) then
      write(outline,string'("OK"));
    else
      write(outline,string'("Error"));
    end if;
    writeline(outfile,outline);
  end loop;
end process;

end behavioral;

    