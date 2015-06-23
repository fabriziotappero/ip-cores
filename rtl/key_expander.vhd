--*************************************************************************
-- Project    : AES128                                                    *
--                                                                        *
-- Block Name : key_expander.vhd                                          *
--                                                                        *
-- Author     : Hemanth Satyanarayana                                     *
--                                                                        *
-- Email      : hemanth@opencores.org                                     *
--                                                                        *
-- Description: This block implements the key expnasion algorithm         *
--              to generate different keys for each of 10 rounds.         *
--                         .                                              *
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


entity key_expander is
port(
      clk      : in std_logic;
      reset    : in std_logic;
      key_in_c0: in state_array_type; -- given input keys 
      key_in_c1: in state_array_type; -- given input keys 
      key_in_c2: in state_array_type; -- given input keys 
      key_in_c3: in state_array_type; -- given input keys 
      count    : in integer;          -- to synchronise with input transformation rounds
      mode     : in std_logic;        -- high=encrypt, low=decrypt
      keyout_c0: out state_array_type;-- output key value for each round
      keyout_c1: out state_array_type;-- output key value for each round
      keyout_c2: out state_array_type;-- output key value for each round
      keyout_c3: out state_array_type -- output key value for each round
      );
end key_expander;

architecture expansion of key_expander is
signal X0      : state_array_type;
signal X1      : state_array_type;
signal X2      : state_array_type;
signal X3      : state_array_type;
signal w_i_nk0 : state_array_type;
signal w_i_nk1 : state_array_type;
signal w_i_nk2 : state_array_type;
signal w_i_nk3 : state_array_type;
signal temp0   : state_array_type;
signal k_rot   : state_array_type;
signal key_sub : state_array_type;
signal key_xor_rcon: state_array_type;
signal rcon: std_logic_vector(7 downto 0);
begin

-- transformation of keys
process(mode,rcon,temp0,k_rot,key_sub,key_xor_rcon,X0,X1,X2,X3,w_i_nk0,w_i_nk1,w_i_nk2,w_i_nk3)
begin
  if(mode = '1') then -- if encrypt
    k_rot <= (temp0(1),temp0(2),temp0(3),temp0(0)); -- ROTATE word
    -- SUB word
    key_sub(0) <= sbox_val(k_rot(0));
    key_sub(1) <= sbox_val(k_rot(1));
    key_sub(2) <= sbox_val(k_rot(2));
    key_sub(3) <= sbox_val(k_rot(3));
    -- XOR with rcon
    key_xor_rcon <= ((key_sub(0) xor rcon),key_sub(1),key_sub(2),key_sub(3));
    
    -- XOR with Wi's
    X0 <= ( key_xor_rcon(0) xor w_i_nk0(0) ,key_xor_rcon(1) xor w_i_nk0(1),key_xor_rcon(2) xor w_i_nk0(2),key_xor_rcon(3) xor w_i_nk0(3));
    X1 <= ((X0(0) xor w_i_nk1(0)) , (X0(1) xor w_i_nk1(1)) , (X0(2) xor w_i_nk1(2)) , (X0(3) xor w_i_nk1(3)));
    X2 <= ((X1(0) xor w_i_nk2(0)) , (X1(1) xor w_i_nk2(1)) , (X1(2) xor w_i_nk2(2)) , (X1(3) xor w_i_nk2(3)));
    X3 <= ((X2(0) xor w_i_nk3(0)) , (X2(1) xor w_i_nk3(1)) , (X2(2) xor w_i_nk3(2)) , (X2(3) xor w_i_nk3(3)));
  else -- if decrypt
    X3 <= (w_i_nk3(0) xor w_i_nk2(0) , w_i_nk3(1) xor w_i_nk2(1) , w_i_nk3(2) xor w_i_nk2(2) , w_i_nk3(3) xor w_i_nk2(3));
    X2 <= (w_i_nk2(0) xor w_i_nk1(0) , w_i_nk2(1) xor w_i_nk1(1) , w_i_nk2(2) xor w_i_nk1(2) , w_i_nk2(3) xor w_i_nk1(3));
    X1 <= (w_i_nk1(0) xor w_i_nk0(0) , w_i_nk1(1) xor w_i_nk0(1) , w_i_nk1(2) xor w_i_nk0(2) , w_i_nk1(3) xor w_i_nk0(3));
    X0 <= ( key_xor_rcon(0) xor w_i_nk0(0) ,key_xor_rcon(1) xor w_i_nk0(1),key_xor_rcon(2) xor w_i_nk0(2),key_xor_rcon(3) xor w_i_nk0(3));

    k_rot <= (X3(1),X3(2),X3(3),X3(0));
    key_sub(0) <= sbox_val(k_rot(0));
    key_sub(1) <= sbox_val(k_rot(1));
    key_sub(2) <= sbox_val(k_rot(2));
    key_sub(3) <= sbox_val(k_rot(3));
    key_xor_rcon <= ((key_sub(0) xor rcon),key_sub(1),key_sub(2),key_sub(3));
  end if;
end process;  

-- registering key outputs for each round and generating rcon values for each round
process(clk,reset)
begin
  if(reset = '1') then
    temp0   <= (others =>(others => '0'));
    w_i_nk0 <= (others =>(others => '0'));
    w_i_nk1 <= (others =>(others => '0'));
    w_i_nk2 <= (others =>(others => '0'));
    w_i_nk3 <= (others =>(others => '0'));
    rcon    <= (others => '0');
  elsif clk'event and clk = '1' then
    if(count = 0) then
      temp0   <= key_in_c3;
      w_i_nk0 <= key_in_c0;
      w_i_nk1 <= key_in_c1;
      w_i_nk2 <= key_in_c2;
      w_i_nk3 <= key_in_c3;
    else
      temp0   <= X3;
      w_i_nk0 <= X0;
      w_i_nk1 <= X1;
      w_i_nk2 <= X2;
      w_i_nk3 <= X3;
    end if;
    if(mode = '1') then
      case count is
        when 0 => rcon <= "00000001";
        when 1 => rcon <= "00000010";
        when 2 => rcon <= "00000100";
        when 3 => rcon <= "00001000";
        when 4 => rcon <= "00010000";
        when 5 => rcon <= "00100000";
        when 6 => rcon <= "01000000";
        when 7 => rcon <= "10000000";
        when 8 => rcon <= "00011011";
        when 9 => rcon <= "00110110";
        when others => rcon <= "00000000";
      end case; 
    else------------------------->>>>>>>>>>>>>>
      case count is
        when 0 => rcon <= "00110110";
        when 1 => rcon <= "00011011";
        when 2 => rcon <= "10000000";
        when 3 => rcon <= "01000000";
        when 4 => rcon <= "00100000";
        when 5 => rcon <= "00010000";
        when 6 => rcon <= "00001000";
        when 7 => rcon <= "00000100";
        when 8 => rcon <= "00000010";
        when 9 => rcon <= "00000001";
        when others => rcon <= "00000000";
      end case; 
    end if;
  end if;
end process;  

keyout_c0 <= X0;
keyout_c1 <= X1;
keyout_c2 <= X2;
keyout_c3 <= X3;

end expansion;  
  
  
  
  
