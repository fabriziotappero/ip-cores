-----------------------------------------------------------------------------
--	Copyright (C) 2009 Sam Green
--
-- This code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- Decodes manchester encoded data
-- 
-----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.globals.all;

entity decode is

  port (
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;
    nd_i      : in  std_logic;
    encoded_i : in  std_logic_vector(3 downto 0);
    decoded_o : out std_logic_vector(WORD_LENGTH-1 downto 0);
    nd_o      : out std_logic
  );

end;

architecture behavioral of decode is

  type state_type is (reset, pause, one_0, one_1, two_0, two_1);
  signal state, next_state : state_type;

  -- *2 comes from each bit in the word is manchester encoded.
  -- +2 comes from protocol transmitting -------_ to initiate
  -- a transmission; +1 from the ------- and +1 from the _
  constant STRING_LENGTH : integer := WORD_LENGTH*2+2;
  -- the range -1 comes from the state machine which will
  -- update index_n while the protocol finishes transmission
  signal index, index_n   : integer range -1 to STRING_LENGTH-1;
  signal str_buffer : std_logic_vector(STRING_LENGTH-3 downto 0);
  signal insert : std_logic_vector(1 downto 0);
  signal nd_o_buff : std_logic;
begin

  controller : process(nd_i, rst_i)
  begin
    if rst_i = '1' then

      index <= STRING_LENGTH-1;
      state <= reset;
      str_buffer <= (others => '0');
      nd_o_buff <= '0';

    elsif rising_edge(nd_i) then
      -- index is initalized at STRING_LENGTH-1
      -- the protocol initializes with two bits
      -- which are trashed, hence we wait until the first
      -- trashed bits have been passed
      -- 
      -- processing stops when the WORD_LENGTH bits have arrived (nd_o_buff = '1')
      if STRING_LENGTH - index >= 3 and nd_o_buff = '0' then
        -- Adding a single/double zero/one?
        if index - index_n = 2 then -- update 2
          str_buffer(index downto index-1) <= insert; -- insert double
        else -- update 1
          str_buffer(index) <= insert(1); -- insert single
        end if;
      end if;
       
      -- finished?
      if index = 0 then
        nd_o_buff <= '1';
        state <= reset;
      else
        index <= index_n;
        state <= next_state;
      end if;
    end if;
  end process;
  
  output_decode: process(state, index, nd_i)
  begin
    case state is  
    
      when one_1 =>
        insert <= "10";
        if (index > -1) then
          index_n <= index - 1;
        else
          index_n <= 0; -- error
        end if;

      when one_0 =>
        insert <= "00";
        if (index > -1) then
          index_n <= index - 1;
        else
          index_n <= 0; -- error
        end if;

      when two_1 =>
        insert <= "11";

        if (index > 0) then
          index_n <= index - 2;
        else
          index_n <= 0; -- error
        end if;        

      when two_0 =>
        insert <= "00";

        if (index > 0) then
          index_n <= index - 2; 
        else
          index_n <= 0; -- error
        end if;        

      when others =>
        insert <= "00";
        index_n <= index;
        
    end case;
  end process;

  -- For encoded_i:
  --
  -- 0000 = null
  -- 0001 = single one
  -- 0010 = double one
  -- 0100 = single zero
  -- 1000 = double zero  

  next_state_decode: process(state, encoded_i)
  begin
    next_state <= state;
    case(state) is
      when reset =>
      
        next_state <= pause;

      when pause =>

        next_state <= one_1; -- only if we came from reset. The long
        -- initialization string of ones --------- is considered a 
        -- single one.
        
      when one_0 =>

        case(encoded_i) is
          when "0100" => next_state <= one_0; -- remain here until change
          when "0001" => next_state <= one_1; -- because of the protocol, a 
          -- single 0 can only be followed by a single one.        
          when others => next_state <= reset; -- only on error
        end case;
      
      when one_1 =>

        case(encoded_i) is
          when "0001" => next_state <= one_1; -- remain here until change                                              
          when "0100" => next_state <= one_0;
          when "1000" => next_state <= two_0;
          when others => next_state <= reset; -- only on error
        end case;
      
      when two_0 =>

        case(encoded_i) is
          when "1000" => next_state <= two_0; -- remain here until change
          when "0001" => next_state <= one_1;
          when "0010" => next_state <= two_1;
          when others => next_state <= reset; -- only on error
        end case;
      
      when two_1 =>

        case(encoded_i) is
          when "0010" => next_state <= two_1; -- remain here until change
          when "0100" => next_state <= one_0;
          when "1000" => next_state <= two_0;
          when others => next_state <= reset; -- only on error
        end case;
               
      when others =>
        next_state <= reset;  -- only on error
      
    end case;
  end process;

  -- decoded!
  rearrange : process(clk_i, rst_i)
  begin
    if rst_i = '1' then
      decoded_o <= (others => '0');
      nd_o <= '0';
    elsif rising_edge(clk_i) then
      if nd_o_buff = '1' then
        for i in 0 to WORD_LENGTH-1 loop
          -- the bits are ror when transmitted, thus the left-most
          -- bit in decoded_buffer (excluding the xmitter protocol bits)
          -- describe the right-most bit in the original data word. 
          -- The following line of code turns 01 to 1 and 10 to 0 and it converts
          -- the big endian decoded_buffer to little endian decoded_o.        
          if str_buffer(str_buffer'left-2*i downto str_buffer'left-1-2*i) = "01" then
            decoded_o(i) <= '1';
          else
            decoded_o(i) <= '0';
          end if;
        end loop;

        nd_o <= '1';
      end if;
    end if;
  end process;

end;

