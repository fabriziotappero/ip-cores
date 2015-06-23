--*************************************************************************
-- Project    : AES128                                                    *
--                                                                        *
-- Block Name : aes_fips_mctester.vhd                                     *
--                                                                        *
-- Author     : Hemanth Satyanarayana                                     *
--                                                                        *
-- Email      : hemanth@opencores.org                                     *
--                                                                        *
-- Description: Test bench module to test the aes implementation          *
--              for general text based informal tests.                    *
--                         .                                              *
--                                                                        *
-- Revision History                                                       *
-- |-----------|-------------|---------|---------------------------------|*
-- |   Name    |    Date     | Version |          Revision details       |*
-- |-----------|-------------|---------|---------------------------------|*
-- | Hemanth   | 15-Dec-2004 | 1.1.1.1 |            Uploaded             |*
-- |-----------|-------------|---------|---------------------------------|*
--                                                                        *
--                                                                        *
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
use work.aes_tb_package.all;

entity aes_tester is end aes_tester;

architecture behavioral of aes_tester is

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
constant total_num_char: integer:= 160;-- 
type array1 is array (1 to 300) of std_logic_vector(7 downto 0);
-- array to hold binary representation of text input
type array2 is array (1 to (total_num_char/16 + 1)) of std_logic_vector(127 downto 0);
-- array to hold decrypted binary values
type array3 is array (1 to 9) of std_logic_vector(127 downto 0);
--@@@@@@@@@@@@@@@@@@@@@@@@@@@
signal indicator: integer:=2; -- 1-> text_2_bits; 0-> bits_2_text; 2-> bits_2_bits
--@@@@@@@@@@@@@@@@@@@@@@@@@@@
signal clock_tb: std_logic:='0';
signal reset_tb: std_logic:='0';
signal load_tb : std_logic:='0';
signal start_tb: std_logic:='0';
signal done_tb : std_logic;
--#############################
signal mode_tb: std_logic:='0'; -- 1-> encode; 0-> decode
--#############################
signal data_in_tb: std_logic_vector(63 downto 0);
signal data_out_tb: std_logic_vector(127 downto 0);
signal key_tb: std_logic_vector(63 downto 0);
constant key_val: std_logic_vector(127 downto 0):=X"000102030405060708090A0B0C0D0E0F";
signal char_vector: array1:=(others =>(others => '0'));
signal code_out: array2;

signal decode_vector: array3;
signal num_vecs: integer:=0;
constant key_val_decode:std_logic_vector(127 downto 0):=X"13111D7FE3944A17F307A78B4D2B30C5";
signal decode_out: array3;
signal one_block_in: std_logic_vector(127 downto 0);
signal one_block_out: std_logic_vector(127 downto 0);

signal chk: character;
signal chk3: character;
signal chk1: std_logic:='0';
signal length_inline: integer:=0;
signal itr_cnt: integer:=0;
signal chk2: integer:=0;
begin

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
file infile1: text open read_mode is "text_in.txt";
file infile2: text open read_mode is "encoded_text.txt";
file infile3: text open read_mode is "aes_data_in.txt";
type char_array is array (1 to 6,1 to 40) of character; -- upto 6 lines of 40 characters each for
variable inline: line;                                  -- text_2_bit conversion mode
variable one_char: character;
variable linestr: char_array;
variable outline: line;
variable j: integer:=0;
variable bits_128: std_logic_vector(127 downto 0);
begin
  wait for 1 ns;
  if(indicator = 1) then
    while(not endfile(infile1)) loop
      readline(infile1,inline);
      length_inline <= inline'length + length_inline;
      wait for 1 ns;
      for i in 1 to inline'length loop
        read(inline,one_char);
        char_vector(i+j) <= ascii_2_std_logic_vector(one_char);
        chk <= one_char;
      end loop; 
      j := length_inline;
    end loop;
    chk1 <= '1';
  elsif(indicator = 0) then
    while(not endfile(infile2)) loop
      j:= j+1;
      num_vecs <= j;
      readline(infile2,inline);
      read(inline,bits_128);
      decode_vector(j) <= bits_128;
    end loop;
  elsif(indicator = 2) then  
    while(not endfile(infile3)) loop
      readline(infile3,inline);
      read(inline,bits_128);
      one_block_in <= bits_128;
    end loop;  
  end if;
end process;

clock_tb <= not clock_tb after 50 ns;
reset_tb <= '1','0' after 150 ns;

itr_cnt <= length_inline/16 when ((length_inline rem 16) = 0) else (length_inline/16 +1);
process
file outfile1: text open write_mode is "coded_text.txt";
file outfile2: text open write_mode is "decoded_text.txt";
file outfile3: text open write_mode is "aes_data_out.txt";
variable outline: line;
variable x: integer:=0;
variable getchar: character;
begin
 key_tb <= (others => '0');
 data_in_tb <= (others => '0');
 code_out <=(others =>(others => '0'));
 wait for 10 ns;
 wait until (reset_tb = '0');
if(indicator = 1) then
 wait until(clock_tb'event and clock_tb = '1');
 for i in 1 to itr_cnt loop
   load_tb <= '1';
   key_tb <= key_val(127 downto 64);
   data_in_tb <= (char_vector(1+x) & char_vector(2+x) & char_vector(3+x) & char_vector(4+x) & 
                  char_vector(5+x) & char_vector(6+x) & char_vector(7+x) & char_vector(8+x));
                  
   wait until(clock_tb'event and clock_tb = '1');
   load_tb <= '0';
   key_tb <= key_val(63 downto 0);
   data_in_tb <= (char_vector(9+x) & char_vector(10+x) & char_vector(11+x) & char_vector(12+x) &
                  char_vector(13+x) & char_vector(14+x) & char_vector(15+x) & char_vector(16+x));
   wait until(clock_tb'event and clock_tb = '1');
   wait until(clock_tb'event and clock_tb = '1');
   start_tb <= '1';
   wait until(clock_tb'event and clock_tb = '1');
   start_tb <= '0';
   wait until(clock_tb'event and clock_tb = '1');
   wait until done_tb = '1';
   code_out(i) <= data_out_tb;
   wait for 1 ns;
   write(outline,code_out(i));
   writeline(outfile1,outline);
   wait until(clock_tb'event and clock_tb = '1');
   chk2 <=i;
   x:= x+16;
   wait until(clock_tb'event and clock_tb = '1');
 end loop;  
 wait until(clock_tb'event and clock_tb = '1');
elsif(indicator = 0) then
 for i in 1 to num_vecs loop 
   load_tb <= '1';
   key_tb <= key_val_decode(127 downto 64);
   data_in_tb <= decode_vector(i)(127 downto 64);
   wait until(clock_tb'event and clock_tb = '1');
   load_tb <= '0';
   key_tb <= key_val_decode(63 downto 0);
   data_in_tb <= decode_vector(i)(63 downto 0);
   wait until(clock_tb'event and clock_tb = '1');
   wait until(clock_tb'event and clock_tb = '1');
   start_tb <= '1';
   wait until(clock_tb'event and clock_tb = '1');
   start_tb <= '0';
   wait until(clock_tb'event and clock_tb = '1');
   wait until done_tb = '1';
   decode_out(i) <= data_out_tb;
   wait for 1 ns;
   for k in 0 to 15 loop
     getchar := std_logic_vector_2_ascii(decode_out(i)((127-(8*k)) downto (120-(8*k))));
     chk3 <= getchar;
     chk2 <= k;
     wait for 1 ns;
     if(getchar = '~') then
       writeline(outfile2,outline);
     else
       write(outline,getchar);
     end if; 
   end loop; 
   wait until(clock_tb'event and clock_tb = '1');
 end loop;  
elsif(indicator = 2)  then
   load_tb <= '1';
   if(mode_tb = '1') then
     key_tb <= key_val(127 downto 64);
   else
     key_tb <= key_val_decode(127 downto 64);
   end if;    
   data_in_tb <= one_block_in(127 downto 64);
   wait until(clock_tb'event and clock_tb = '1');
   wait until(clock_tb'event and clock_tb = '1');
   wait until(clock_tb'event and clock_tb = '1');
   load_tb <= '0';
   if(mode_tb = '1') then
     key_tb <= key_val(63 downto 0);
   else
     key_tb <= key_val_decode(63 downto 0);
   end if;    
   data_in_tb <= one_block_in(63 downto 0);
   wait until(clock_tb'event and clock_tb = '1');
   wait until(clock_tb'event and clock_tb = '1');
   start_tb <= '1';
   wait until(clock_tb'event and clock_tb = '1');
   start_tb <= '0';
   wait until(clock_tb'event and clock_tb = '1');
   wait until done_tb = '1';
   one_block_out <= data_out_tb;
   wait for 1 ns;
   write(outline,one_block_out);
   writeline(outfile3,outline);
   hwrite(outline,one_block_out);
   writeline(outfile3,outline);
   wait until(clock_tb'event and clock_tb = '1');
 end if;
 
 wait;
end process;

      
      
end behavioral;      
      
      
      
      
      
      
      