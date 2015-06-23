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

use work.cryptopan.all;

entity aes_encrypt_unit is
  port (
    key_in   : in  std_logic_vector(127 downto 0);
    key_wren : in  std_logic;
    ready    : out std_logic;

    data_in   : in  std_logic_vector(127 downto 0);
    data_wren : in  std_logic;
    data_dv   : out std_logic;
    data_out  : out std_logic_vector(127 downto 0);

    clk   : in std_logic;
    reset : in std_logic
    );

end aes_encrypt_unit;

architecture rtl of aes_encrypt_unit is

  component round_unit
    generic (
      do_mixcolumns : boolean);
    port (
      bytes_in  : in  s_vector;
      bytes_out : out s_vector;
      in_en     : in  std_logic;
      out_en    : out std_logic;
      load_en   : in  std_logic;
      load_data : in  std_logic_vector(31 downto 0);
      load_clk  : in  std_logic;
      clk       : in  std_logic;
      reset     : in  std_logic);
  end component;

  component dual_bram_256x8
    port (
      addra : IN  std_logic_VECTOR(7 downto 0);
      addrb : IN  std_logic_VECTOR(7 downto 0);
      clka  : IN  std_logic;
      clkb  : IN  std_logic;
      douta : OUT std_logic_VECTOR(7 downto 0);
      doutb : OUT std_logic_VECTOR(7 downto 0));
  end component;
  component sbox
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      addra : in  std_logic_vector(7 downto 0);
      douta : out std_logic_vector(7 downto 0));
  end component;
  
  signal cipher_key : s_vector;
  signal input      : s_vector;

  type states is (INIT, KEY_EXP_INIT, KEY_EXP, LOADED);
  signal state : states;

  signal key_exp_counter      : std_logic_vector(1 downto 0);
  --signal round_onehot_counter : std_logic_vector(9 downto 0);
  signal round_shift_counter : std_logic_vector(9 downto 0);
  
  
  signal rcon             : std_logic_vector(7 downto 0);
  signal subword          : std_logic_vector(31 downto 0);
  signal subword_xor_rcon : std_logic_vector(31 downto 0);

  signal cur_w     : std_logic_vector(31 downto 0);
  signal cur_w_rot : std_logic_vector(31 downto 0);
  signal w0        : std_logic_vector(31 downto 0);
  signal w1        : std_logic_vector(31 downto 0);
  signal w2        : std_logic_vector(31 downto 0);

  signal load_bit : std_logic;

  type s_vector_array is array (0 to 10) of s_vector;
  signal round_bytes   : s_vector_array;
  signal round_en      : std_logic_vector(0 to 10);
  signal round_load_en : std_logic_vector(0 to 9);

  signal sbox_clk : std_logic;

  signal slow_clk : std_logic;
  signal clk_counter : std_logic_vector(1 downto 0);

  signal key_wren_int : std_logic;
  signal key_wren_counter : std_logic_vector(2 downto 0);
begin  -- rtl

  SLOWCLK_LOGIC: process (clk, reset)
  begin  
    if reset = '1' then                
      clk_counter <= (others => '0');
    elsif clk'event and clk = '1' then 
      clk_counter <= clk_counter + 1;
    end if;
  end process SLOWCLK_LOGIC;

  slow_clk <= clk_counter(1);
  sbox_clk <= not slow_clk;

  cur_w_rot        <= cur_w(23 downto 0) & cur_w(31 downto 24);
  subword_xor_rcon <= (rcon xor subword(31 downto 24)) & subword(23 downto 0);

  GEN_BRAM: if use_bram=true generate
    GEN_SBOX_BRAM: for i in 0 to 1 generate
      SBOX_i: dual_bram_256x8
        port map (
            addra => cur_w_rot((8*i)+7 downto (8*i)),
            addrb => cur_w_rot((8*i)+23 downto (8*i)+16),
            clka  => sbox_clk,
            clkb  => sbox_clk,
            douta => subword((8*i)+7 downto (8*i)),
            doutb => subword((8*i)+23 downto (8*i)+16)
            );
      
    end generate GEN_SBOX_BRAM;
  end generate GEN_BRAM;

  GEN_NO_BRAM: if use_bram=false generate
    GEN_SBOX_NO_BRAM: for i in 0 to 3 generate
      SBOX_i: sbox
        port map (
            clk   => sbox_clk,
            reset => reset,
            addra => cur_w_rot((8*i)+7 downto (8*i)),
            douta => subword((8*i)+7 downto (8*i)) );
    end generate GEN_SBOX_NO_BRAM;
  end generate GEN_NO_BRAM;


  round_en(0) <= data_wren;
  data_dv     <= round_en(10);

  data_out(127 downto 120) <= round_bytes(10)(0);
  data_out(119 downto 112) <= round_bytes(10)(4);
  data_out(111 downto 104) <= round_bytes(10)(8);
  data_out(103 downto 96) <= round_bytes(10)(12);
  data_out(95 downto 88) <= round_bytes(10)(1);
  data_out(87 downto 80) <= round_bytes(10)(5);
  data_out(79 downto 72) <= round_bytes(10)(9);
  data_out(71 downto 64) <= round_bytes(10)(13);
  data_out(63 downto 56) <= round_bytes(10)(2);
  data_out(55 downto 48) <= round_bytes(10)(6);
  data_out(47 downto 40) <= round_bytes(10)(10);
  data_out(39 downto 32) <= round_bytes(10)(14);
  data_out(31 downto 24) <= round_bytes(10)(3);
  data_out(23 downto 16) <= round_bytes(10)(7);
  data_out(15 downto 8) <= round_bytes(10)(11);
  data_out(7 downto 0) <= round_bytes(10)(15);
  
  input(0)  <= data_in(127 downto 120);
  input(4)  <= data_in(119 downto 112);
  input(8)  <= data_in(111 downto 104);
  input(12) <= data_in(103 downto 96);
  input(1)  <= data_in(95 downto 88);
  input(5)  <= data_in(87 downto 80);
  input(9)  <= data_in(79 downto 72);
  input(13) <= data_in(71 downto 64);
  input(2)  <= data_in(63 downto 56);
  input(6)  <= data_in(55 downto 48);
  input(10) <= data_in(47 downto 40);
  input(14) <= data_in(39 downto 32);
  input(3)  <= data_in(31 downto 24);
  input(7)  <= data_in(23 downto 16);
  input(11) <= data_in(15 downto 8);
  input(15) <= data_in(7 downto 0);

  FIRST_ROUND_INPUT : for i in 0 to 15 generate
    round_bytes(0)(i)              <= cipher_key(i) xor input(i);
  end generate FIRST_ROUND_INPUT;

  KEYWREN_LOGIC: process (clk, reset)
  begin  
    if reset = '1' then
      key_wren_counter <= (others => '0');  
    elsif clk'event and clk = '1' then  
      if key_wren='1' then
        key_wren_counter <= "100";
      elsif key_wren_counter(2)='1' then
        key_wren_counter <= key_wren_counter + 1;
      end if;
    end if;
  end process KEYWREN_LOGIC;
  key_wren_int <= key_wren_counter(2);
  
  CLKLOGIC : process (slow_clk, reset)
  begin  
    if reset = '1' then                
      for i in 0 to 15 loop
        cipher_key(i) <= (others => '0');
      end loop;  
      state           <= INIT;
      ready           <= '0';
    elsif slow_clk'event and slow_clk = '1' then  

      if key_wren_int = '1' then
        cipher_key(0)  <= key_in(127 downto 120);
        cipher_key(4)  <= key_in(119 downto 112);
        cipher_key(8)  <= key_in(111 downto 104);
        cipher_key(12) <= key_in(103 downto 96);
        cipher_key(1)  <= key_in(95 downto 88);
        cipher_key(5)  <= key_in(87 downto 80);
        cipher_key(9)  <= key_in(79 downto 72);
        cipher_key(13) <= key_in(71 downto 64);
        cipher_key(2)  <= key_in(63 downto 56);
        cipher_key(6)  <= key_in(55 downto 48);
        cipher_key(10) <= key_in(47 downto 40);
        cipher_key(14) <= key_in(39 downto 32);
        cipher_key(3)  <= key_in(31 downto 24);
        cipher_key(7)  <= key_in(23 downto 16);
        cipher_key(11) <= key_in(15 downto 8);
        cipher_key(15) <= key_in(7 downto 0);

        state <= KEY_EXP_INIT;
      end if;

      if state = KEY_EXP_INIT then
        state <= KEY_EXP;
      end if;

      if state = KEY_EXP then
        if round_shift_counter(9) = '1' and key_exp_counter = "11" then
          state <= LOADED;
        end if;
      end if;

      if state = LOADED then
        ready <= '1';
      else
        ready <= '0';
      end if;
    end if;
  end process CLKLOGIC;

  with round_shift_counter select
    rcon <=
    X"02" when "0000000010",
    X"04" when "0000000100",
    X"08" when "0000001000",
    X"10" when "0000010000",
    X"20" when "0000100000",
    X"40" when "0001000000",
    X"80" when "0010000000",
    X"1b" when "0100000000",
    X"36" when "1000000000",
    X"01" when others;

  with state select
    load_bit <=
    '1' when KEY_EXP,
    '0' when others;


  ROUNTER_CNT_LOGIC : process (slow_clk, reset)
  begin
    if reset = '1' then
      key_exp_counter      <= (others => '0');
      --round_onehot_counter <= "0000000001";
      round_shift_counter <= "0000000001";
      
      w0    <= (others => '0');
      w1    <= (others => '0');
      w2    <= (others => '0');
      cur_w <= (others => '0');


    elsif slow_clk'event and slow_clk = '1' then
      if key_wren_int = '1' then
        w0    <= key_in(127 downto 96);
        w1    <= key_in(95 downto 64);
        w2    <= key_in(63 downto 32);
        cur_w <= key_in(31 downto 0);

      elsif state = KEY_EXP then

        w0 <= w1;
        w1 <= w2;
        w2 <= cur_w;

        if key_exp_counter = "00" then
          cur_w <= subword_xor_rcon xor w0;
        else
          cur_w <= cur_w xor w0;
        end if;

        key_exp_counter             <= key_exp_counter + 1;

        if key_exp_counter = "11" then
          round_shift_counter <= round_shift_counter(8 downto 0) & round_shift_counter(9);
        end if;

      end if;
    end if;
  end process ROUNTER_CNT_LOGIC;


  ROUND_GEN : for i in 0 to 8 generate
    ROUND_I : round_unit  
	generic map (
	  do_mixcolumns => true )
      port map (
        bytes_in  => round_bytes(i),
        bytes_out => round_bytes(i+1),
        in_en     => round_en(i),
        out_en    => round_en(i+1),
        load_en   => round_load_en(i),
        load_data => cur_w,
        load_clk  => slow_clk,
        clk       => clk,
        reset     => reset);
  end generate ROUND_GEN;

  ROUND9 : round_unit
    generic map (
      do_mixcolumns => false)
    port map (
      bytes_in      => round_bytes(9),
      bytes_out     => round_bytes(10),
      in_en         => round_en(9),
      out_en        => round_en(10),
      load_en       => round_load_en(9),
      load_data     => cur_w,
      load_clk      => slow_clk,
      clk           => clk,
      reset         => reset);

  LOAD_EN_DELAY : process (slow_clk, reset)
  begin 
    if reset = '1' then
      round_load_en      <= (others => '0');
    elsif slow_clk'event and slow_clk = '1' then
      for i in 0 to 9 loop
        round_load_en(i) <= round_shift_counter(i) and load_bit;
      end loop;
    end if;
  end process LOAD_EN_DELAY;

end rtl;
