--*************************************************************************
-- Project    : AES128                                                    *
--                                                                        *
-- Block Name : aes128_fast.vhd                                           *
--                                                                        *
-- Author     : Hemanth Satyanarayana                                     *
--                                                                        *
-- Email      : hemanth@opencores.org                                     *
--                                                                        *
-- Description: This is the top level module for the aes core.            *
--              It instantiates the key expander and uses the             *
--              aes package for other transformations.                    *
--              Implementation is ECB mode.                               *
--                                                                        *
-- Revision History                                                       *
-- |-----------|-------------|---------|---------------------------------|*
-- |   Name    |    Date     | Version |          Revision details       |*
-- |-----------|-------------|---------|---------------------------------|*
-- | Hemanth   | 15-Dec-2004 | 1.1.1.1 |            Uploaded             |*
-- |-----------|-------------|---------|---------------------------------|*
--                                                                        *
--  Refer FIPS-197 document for details                                   *
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
use ieee.std_logic_unsigned.all;
use work.aes_package.all;

entity aes128_fast is
port(
      clk       : in std_logic;
      reset     : in std_logic;
      start     : in std_logic; -- to initiate the encryption/decryption process after loading
      mode      : in std_logic; -- to select encryption or decryption
      load      : in std_logic; -- to load the input and keys.has to 
      key       : in std_logic_vector(63 downto 0);
      data_in   : in std_logic_vector(63 downto 0);
      data_out  : out std_logic_vector(127 downto 0);
      done      : out std_logic
     );
     
end aes128_fast;

architecture mapping of aes128_fast is


component key_expander 
port(
      clk      : in std_logic;
      reset    : in std_logic;
      key_in_c0: in state_array_type;
      key_in_c1: in state_array_type;
      key_in_c2: in state_array_type;
      key_in_c3: in state_array_type;
      count    : in integer;
      mode     : in std_logic;
      keyout_c0: out state_array_type;
      keyout_c1: out state_array_type;
      keyout_c2: out state_array_type;
      keyout_c3: out state_array_type
      );
end component;

signal data_in_reg0: state_array_type;
signal data_in_reg1: state_array_type;
signal data_in_reg2: state_array_type;
signal data_in_reg3: state_array_type;
signal key_reg0: state_array_type;
signal key_reg1: state_array_type;
signal key_reg2: state_array_type;
signal key_reg3: state_array_type;
signal s0      : state_array_type;
signal s1      : state_array_type;
signal s2      : state_array_type;
signal s3      : state_array_type;
signal s_00    : state_array_type;
signal s_01    : state_array_type;
signal s_02    : state_array_type;
signal s_03    : state_array_type;
signal r_00    : state_array_type;
signal r_01    : state_array_type;
signal r_02    : state_array_type;
signal r_03    : state_array_type;
signal load_d1 : std_logic;
signal start_d1: std_logic;
signal start_d2: std_logic;
signal round_cnt: integer range 0 to 15;
signal flag_cnt: std_logic;
signal done_d1 : std_logic;
signal done_d2 : std_logic;

signal mixcol_0: state_array_type;
signal mixcol_1: state_array_type;
signal mixcol_2: state_array_type;
signal mixcol_3: state_array_type;

signal new_key0: state_array_type;
signal new_key1: state_array_type;
signal new_key2: state_array_type;
signal new_key3: state_array_type;
signal new_key0_d1: state_array_type;
signal new_key1_d1: state_array_type;
signal new_key2_d1: state_array_type;
signal new_key3_d1: state_array_type;

signal s0_buf  : state_array_type;
signal s1_buf  : state_array_type;
signal s2_buf  : state_array_type;
signal s3_buf  : state_array_type;

signal next_round_data_0: state_array_type;
signal next_round_data_1: state_array_type;
signal next_round_data_2: state_array_type;
signal next_round_data_3: state_array_type;

signal pr_data_0: state_array_type;
signal pr_data_1: state_array_type;
signal pr_data_2: state_array_type;
signal pr_data_3: state_array_type;

signal mix_col_array   : std_logic_vector(0 to 127);
signal mixcol_key_array: std_logic_vector(0 to 127);
signal mixcol_key_0    : state_array_type;
signal mixcol_key_1    : state_array_type;
signal mixcol_key_2    : state_array_type;
signal mixcol_key_3    : state_array_type;
signal key_select_0    : state_array_type;
signal key_select_1    : state_array_type;
signal key_select_2    : state_array_type;
signal key_select_3    : state_array_type;
begin

-- Loading the data and keys
process(clk,reset)
begin
  if(reset = '1') then
    key_reg0 <= (others =>(others => '0'));
    key_reg1 <= (others =>(others => '0'));
    key_reg2 <= (others =>(others => '0'));
    key_reg3 <= (others =>(others => '0'));
    data_in_reg0 <= (others =>(others => '0'));
    data_in_reg1 <= (others =>(others => '0'));
    data_in_reg2 <= (others =>(others => '0'));
    data_in_reg3 <= (others =>(others => '0'));
  elsif rising_edge(clk) then
    if(load = '1' and load_d1 = '0') then
      key_reg0     <= (key(63 downto 56),key(55 downto 48),key(47 downto 40),key(39 downto 32));
      key_reg1     <= (key(31 downto 24),key(23 downto 16),key(15 downto 8),key(7 downto 0));
      data_in_reg0 <= (data_in(63 downto 56),data_in(55 downto 48),data_in(47 downto 40),data_in(39 downto 32));
      data_in_reg1 <= (data_in(31 downto 24),data_in(23 downto 16),data_in(15 downto 8),data_in(7 downto 0));
    elsif(load_d1 = '1' and load = '0') then  
      key_reg2     <= (key(63 downto 56),key(55 downto 48),key(47 downto 40),key(39 downto 32));
      key_reg3     <= (key(31 downto 24),key(23 downto 16),key(15 downto 8),key(7 downto 0));
      data_in_reg2 <= (data_in(63 downto 56),data_in(55 downto 48),data_in(47 downto 40),data_in(39 downto 32));
      data_in_reg3 <= (data_in(31 downto 24),data_in(23 downto 16),data_in(15 downto 8),data_in(7 downto 0));
    end if;
  end if;
end process;


----------STATE MATRIX ROW WORDS ------
-- Given input xored with given key for generating input to the first round
s0(0) <= data_in_reg0(0) xor key_reg0(0);
s0(1) <= data_in_reg0(1) xor key_reg0(1);
s0(2) <= data_in_reg0(2) xor key_reg0(2);
s0(3) <= data_in_reg0(3) xor key_reg0(3);
s1(0) <= data_in_reg1(0) xor key_reg1(0);
s1(1) <= data_in_reg1(1) xor key_reg1(1);
s1(2) <= data_in_reg1(2) xor key_reg1(2);
s1(3) <= data_in_reg1(3) xor key_reg1(3);
s2(0) <= data_in_reg2(0) xor key_reg2(0); 
s2(1) <= data_in_reg2(1) xor key_reg2(1);
s2(2) <= data_in_reg2(2) xor key_reg2(2);
s2(3) <= data_in_reg2(3) xor key_reg2(3);
s3(0) <= data_in_reg3(0) xor key_reg3(0);
s3(1) <= data_in_reg3(1) xor key_reg3(1);
s3(2) <= data_in_reg3(2) xor key_reg3(2);
s3(3) <= data_in_reg3(3) xor key_reg3(3);

-----------------SUB BYTES TRANSFORMATION--------------------------------------
process(s0_buf,s1_buf,s2_buf,s3_buf,mode)
begin
  if(mode = '1') then
    s_00(0) <= sbox_val(s0_buf(0));
    s_00(1) <= sbox_val(s0_buf(1));
    s_00(2) <= sbox_val(s0_buf(2));
    s_00(3) <= sbox_val(s0_buf(3));
    
    s_01(0) <= sbox_val(s1_buf(0));
    s_01(1) <= sbox_val(s1_buf(1));
    s_01(2) <= sbox_val(s1_buf(2));
    s_01(3) <= sbox_val(s1_buf(3));
    
    s_02(0) <= sbox_val(s2_buf(0));
    s_02(1) <= sbox_val(s2_buf(1));
    s_02(2) <= sbox_val(s2_buf(2));
    s_02(3) <= sbox_val(s2_buf(3));
    
    s_03(0) <= sbox_val(s3_buf(0));
    s_03(1) <= sbox_val(s3_buf(1));
    s_03(2) <= sbox_val(s3_buf(2));
    s_03(3) <= sbox_val(s3_buf(3));
  else
    s_00(0) <= inv_sbox_val(s0_buf(0));
    s_00(1) <= inv_sbox_val(s0_buf(1));
    s_00(2) <= inv_sbox_val(s0_buf(2));
    s_00(3) <= inv_sbox_val(s0_buf(3));
    
    s_01(0) <= inv_sbox_val(s1_buf(0));
    s_01(1) <= inv_sbox_val(s1_buf(1));
    s_01(2) <= inv_sbox_val(s1_buf(2));
    s_01(3) <= inv_sbox_val(s1_buf(3));
    
    s_02(0) <= inv_sbox_val(s2_buf(0));
    s_02(1) <= inv_sbox_val(s2_buf(1));
    s_02(2) <= inv_sbox_val(s2_buf(2));
    s_02(3) <= inv_sbox_val(s2_buf(3));
    
    s_03(0) <= inv_sbox_val(s3_buf(0));
    s_03(1) <= inv_sbox_val(s3_buf(1));
    s_03(2) <= inv_sbox_val(s3_buf(2));
    s_03(3) <= inv_sbox_val(s3_buf(3));
  end if;
end process;  

-----------SHIFT ROWS TRANSFORMATION--------------------------------------
process(s_00,s_01,s_02,s_03,mode)
begin
  if(mode = '1') then
    r_00 <= (s_00(0),s_01(1),s_02(2),s_03(3));
    r_01 <= (s_01(0),s_02(1),s_03(2),s_00(3));
    r_02 <= (s_02(0),s_03(1),s_00(2),s_01(3));
    r_03 <= (s_03(0),s_00(1),s_01(2),s_02(3));
  else
    r_00 <= (s_00(0),s_03(1),s_02(2),s_01(3)); 
    r_01 <= (s_01(0),s_00(1),s_03(2),s_02(3)); 
    r_02 <= (s_02(0),s_01(1),s_00(2),s_03(3)); 
    r_03 <= (s_03(0),s_02(1),s_01(2),s_00(3)); 
  end if;
end process;  
-----------MIX COLUMNS TRANSFORMATION--------------------------------------        

mix_col_array <= mix_cols_routine(r_00,r_01,r_02,r_03,mode);
mixcol_0 <= (mix_col_array(0 to 7),mix_col_array(8 to 15),mix_col_array(16 to 23),mix_col_array(24 to 31));
mixcol_1 <= (mix_col_array(32 to 39),mix_col_array(40 to 47),mix_col_array(48 to 55),mix_col_array(56 to 63));
mixcol_2 <= (mix_col_array(64 to 71),mix_col_array(72 to 79),mix_col_array(80 to 87),mix_col_array(88 to 95));
mixcol_3 <= (mix_col_array(96 to 103),mix_col_array(104 to 111),mix_col_array(112 to 119),mix_col_array(120 to 127));

mixcol_key_array <= mix_cols_routine(new_key0_d1,new_key1_d1,new_key2_d1,new_key3_d1,mode);
mixcol_key_0 <= (mixcol_key_array(0 to 7),mixcol_key_array(8 to 15),mixcol_key_array(16 to 23),mixcol_key_array(24 to 31));
mixcol_key_1 <= (mixcol_key_array(32 to 39),mixcol_key_array(40 to 47),mixcol_key_array(48 to 55),mixcol_key_array(56 to 63));
mixcol_key_2 <= (mixcol_key_array(64 to 71),mixcol_key_array(72 to 79),mixcol_key_array(80 to 87),mixcol_key_array(88 to 95));
mixcol_key_3 <= (mixcol_key_array(96 to 103),mixcol_key_array(104 to 111),mixcol_key_array(112 to 119),mixcol_key_array(120 to 127));

---------ADD ROUND KEY STEP-------------------------------------------------
expand_key:  key_expander 
             port map(
                          clk       => clk,
                          reset     => reset,
                          key_in_c0 => key_reg0,
                          key_in_c1 => key_reg1,
                          key_in_c2 => key_reg2,
                          key_in_c3 => key_reg3,
                          count     => round_cnt,
                          mode      => mode,
                          keyout_c0 => new_key0,
                          keyout_c1 => new_key1,
                          keyout_c2 => new_key2,
                          keyout_c3 => new_key3
                       );

process(clk,reset)  ---- registered to increase speed
begin
  if(reset = '1') then
    new_key0_d1 <= (others =>(others => '0'));
    new_key1_d1 <= (others =>(others => '0'));
    new_key2_d1 <= (others =>(others => '0'));
    new_key3_d1 <= (others =>(others => '0'));
  elsif rising_edge(clk) then  
    new_key0_d1 <= new_key0;
    new_key1_d1 <= new_key1;
    new_key2_d1 <= new_key2;
    new_key3_d1 <= new_key3;
  end if;
end process;

-- Previous round output as input to next round
next_round_data_0 <= (pr_data_0(0) xor key_select_0(0),pr_data_0(1) xor key_select_0(1),pr_data_0(2) xor key_select_0(2),pr_data_0(3) xor key_select_0(3)); 
next_round_data_1 <= (pr_data_1(0) xor key_select_1(0),pr_data_1(1) xor key_select_1(1),pr_data_1(2) xor key_select_1(2),pr_data_1(3) xor key_select_1(3));  
next_round_data_2 <= (pr_data_2(0) xor key_select_2(0),pr_data_2(1) xor key_select_2(1),pr_data_2(2) xor key_select_2(2),pr_data_2(3) xor key_select_2(3));  
next_round_data_3 <= (pr_data_3(0) xor key_select_3(0),pr_data_3(1) xor key_select_3(1),pr_data_3(2) xor key_select_3(2),pr_data_3(3) xor key_select_3(3));  

-- Muxing for choosing data for the last round
pr_data_0 <= r_00 when round_cnt=11 else
             mixcol_0;
pr_data_1 <= r_01 when round_cnt=11 else
             mixcol_1;
pr_data_2 <= r_02 when round_cnt=11 else
             mixcol_2;
pr_data_3 <= r_03 when round_cnt=11 else
             mixcol_3;
             
key_select_0 <= new_key0_d1 when (mode = '1') else
                mixcol_key_0 when(mode = '0' and round_cnt < 11) else
                new_key0_d1;
key_select_1 <= new_key1_d1 when (mode = '1') else
                mixcol_key_1 when(mode = '0' and round_cnt < 11) else
                new_key1_d1;
key_select_2 <= new_key2_d1 when (mode = '1') else
                mixcol_key_2 when(mode = '0' and round_cnt < 11) else
                new_key2_d1;
key_select_3 <= new_key3_d1 when (mode = '1') else
                mixcol_key_3 when(mode = '0' and round_cnt < 11) else
                new_key3_d1;
done <= done_d2;             

-- Registering start and load             
process(clk,reset)
begin
  if(reset = '1') then
    load_d1  <= '0';
    start_d1 <= '0';
    start_d2 <= '0';
  elsif rising_edge(clk) then
    load_d1  <= load;
    start_d1 <= start;
    start_d2 <= start_d1;
  end if;
end process;  

-- Register outputs at end of each round
process(clk,reset)
begin
  if(reset = '1') then
    s0_buf <= (others =>(others => '0'));
    s1_buf <= (others =>(others => '0'));
    s2_buf <= (others =>(others => '0'));
    s3_buf <= (others =>(others => '0'));
  elsif rising_edge(clk) then
    if(round_cnt = 0 or round_cnt = 1) then
      s0_buf <= s0;
      s1_buf <= s1;
      s2_buf <= s2;
      s3_buf <= s3;
    else
      s0_buf <= next_round_data_0;
      s1_buf <= next_round_data_1;
      s2_buf <= next_round_data_2;
      s3_buf <= next_round_data_3;
    end if;
  end if;  
end process;  

-- Initiator process
process(clk,reset)
begin
  if(reset = '1') then
    round_cnt <= 0;
    flag_cnt <= '0';
  elsif rising_edge(clk) then
    if((start_d2 = '1' and start_d1 = '0') or flag_cnt = '1') then
      if(round_cnt < 11) then
        round_cnt <= round_cnt + 1;
        flag_cnt <= '1';
      else  
        round_cnt <= 0;
        flag_cnt <= '0';
      end if;  
    end if;
  end if;  
end process;  

-- Completion signalling process
process(clk,reset)
begin
  if(reset = '1') then
    done_d1 <= '0';
    done_d2 <= '0';
  elsif rising_edge(clk) then
    if(start_d2 = '1' and start_d1 = '0') then
      done_d1 <= '0';
      done_d2 <= '0';
    elsif(round_cnt = 10) then
      done_d1 <= '1';
    end if;  
    done_d2 <= done_d1;
  end if;
end process;  

-- Output assignment process        
process(clk,reset)
begin
  if(reset= '1') then
    data_out <= (others => '0');
  elsif rising_edge(clk) then  
    if(done_d1 = '1' and done_d2 = '0') then
        data_out <= (next_round_data_0(0) & next_round_data_0(1) & next_round_data_0(2) & next_round_data_0(3) &
                     next_round_data_1(0) & next_round_data_1(1) & next_round_data_1(2) & next_round_data_1(3) &
                     next_round_data_2(0) & next_round_data_2(1) & next_round_data_2(2) & next_round_data_2(3) &
                     next_round_data_3(0) & next_round_data_3(1) & next_round_data_3(2) & next_round_data_3(3));
    end if;
  end if;
end process;

end mapping;

        
        
                