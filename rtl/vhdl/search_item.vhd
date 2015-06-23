--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// search_item.vhd                                              ////
--//                                                              ////
--// This file is part of the open_hitter opencores effort.       ////
--// <http://www.opencores.org/cores/open_hitter/>                ////
--//                                                              ////
--// Module Description:                                          ////
--// This is the multipelexed search's repeated item. The project ////
--// buses perform the multiplex and are experienced by each item ////
--// as b1_* - input to search_item                               ////
--//    b2_* - output from search_item                            ////
--// there is also a small state-machine in each search_item.     ////
--// For now, the count of number of states is fixed, per px_type ////
--//                                                              ////
--// To Do:                                                       ////
--//                                                              ////
--// Author(s):                                                   ////
--// - Stephen Hawes                                              ////
--//                                                              ////
--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// Copyright (C) 2015 Stephen Hawes and OPENCORES.ORG           ////
--//                                                              ////
--// This source file may be used and distributed without         ////
--// restriction provided that this copyright statement is not    ////
--// removed from the file and that any derivative work contains  ////
--// the original copyright notice and the associated disclaimer. ////
--//                                                              ////
--// This source file is free software; you can redistribute it   ////
--// and/or modify it under the terms of the GNU Lesser General   ////
--// Public License as published by the Free Software Foundation; ////
--// either version 2.1 of the License, or (at your option) any   ////
--// later version.                                               ////
--//                                                              ////
--// This source is distributed in the hope that it will be       ////
--// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
--// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
--// PURPOSE. See the GNU Lesser General Public License for more  ////
--// details.                                                     ////
--//                                                              ////
--// You should have received a copy of the GNU Lesser General    ////
--// Public License along with this source; if not, download it   ////
--// from <http://www.opencores.org/lgpl.shtml>                   ////
--//                                                              ////
--////////////////////////////////////////////////////////////////////
--//
--// \$Id\$  TAKE OUT THE \'s and this comment in order to get this to work
--//
--// CVS Revision History
--//
--// \$Log\$  TAKE OUT THE \'s and this comment in order to get this to work
--//
library ieee;
use ieee.std_logic_1164.all;     
use ieee.numeric_std.ALL;

entity search_item is
   generic ( item_id: std_logic_vector(15 downto 0) );
   port (
        RX_CLK: in std_logic;
        -- control flag(s) on the incoming bus
           b1_px_valid: in std_logic;
        -- pxdata: in price_packet
           b1_px_type: in std_logic_vector(4 downto 0);
           b1_buy_sell: in std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           b1_px: in std_logic_vector(15 downto 0);     -- price
           b1_qty: in std_logic_vector(15 downto 0);    -- quantity
           b1_sec: in std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           b1_id: in std_logic_vector(15 downto 0);    -- unique/identifier/counter
        -- pxdata: out price_packet
           b2_px_type: out std_logic_vector(4 downto 0);
           b2_buy_sell: out std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           b2_px: out std_logic_vector(15 downto 0);     -- price
           b2_qty: out std_logic_vector(15 downto 0);    -- quantity
           b2_sec: out std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           b2_id: out std_logic_vector(15 downto 0)      -- unique/identifier/counter
   );
end search_item;

architecture search_item_implementation of search_item is
      signal state : integer range 0 to 16 := 16;
   -- pxdata: out price_packet
      signal store_px_type: std_logic_vector(4 downto 0) := (others => '0');
      signal store_buy_sell: std_logic_vector(2 downto 0) := (others => '0');   -- 111 buy, 000 sell
      signal store_px: std_logic_vector(15 downto 0) := (others => '0');     -- price
      signal store_qty: std_logic_vector(15 downto 0) := (others => '0');    -- quantity
      signal store_sec: std_logic_vector(55 downto 0) := (others => '0');    -- 7x 8bits securities identifier
      signal store_id: std_logic_vector(15 downto 0) := (others => '0');     -- unique/identifier/counter
begin
   match: process (RX_CLK) is
   begin
      if rising_edge(RX_CLK) then
         if b1_px_valid = '1' then

            if b1_px_type = std_logic_vector'("00000") then
                   -- do reset store and outputs
                   store_px_type  <= (others => '0');
                   store_buy_sell <= (others => '0');   -- 111 buy, 000 sell
                   store_px       <= (others => '0');   -- price
                   store_qty      <= (others => '0');   -- quantity
                   store_sec      <= (others => '0');   -- 7x 8bits securities identifier
              -- not reset / generic     store_id       <= (others => '0');   -- unique/identifier/counter
                   --
                   b2_px_type  <= (others => 'Z');
                   b2_buy_sell <= (others => 'Z');   -- 111 buy, 000 sell
                   b2_px       <= (others => 'Z');   -- price
                   b2_qty      <= (others => 'Z');   -- quantity
                   b2_sec      <= (others => 'Z');   -- 7x 8bits securities identifier
                   b2_id       <= (others => 'Z');   -- unique/identifier/counter
                   --
                   b2_px_type <= std_logic_vector'("ZZZZZ");
                   state <= 16;

            elsif b1_px_type = std_logic_vector'("00110") then
                  if store_buy_sell = b1_buy_sell and
                     store_sec      = b1_sec  then
                       -- do set store from incoming price 
                       store_px_type  <= b1_px_type;
                       -- store_buy_sell <= b1_buy_sell;
                       store_px       <= b1_px;
                       store_qty      <= b1_qty;
                       -- store_sec      <= b1_sec;
                       store_id       <= b1_id;
                       --
                       b2_px_type <= std_logic_vector'(std_logic_vector'("00110"));
                       state <= 8;
                   end if;

            elsif b1_px_type = std_logic_vector'("01010") then 
                   if item_id = b1_id then
                       -- do set store and security from incoming price 
                       store_px_type  <= b1_px_type;
                       store_buy_sell <= b1_buy_sell;
                       store_px       <= b1_px;
                       store_qty      <= b1_qty;
                       store_sec      <= b1_sec;
                       store_id       <= b1_id;
                       --
                       b2_px_type <= b1_px_type;
                       b2_id      <= item_id;
                       state <= 8;
                   end if;

            elsif b1_px_type = std_logic_vector'("11100") then
                   -- incoming price, register it and start the state machine
                   if (store_sec /= b1_sec or store_buy_sell = b1_buy_sell ) then
                      -- not this store_item instance no action
                      null;
                   elsif (to_integer(unsigned(store_qty)) = 0 or to_integer(unsigned(b1_qty)) = 0 or 
                             (store_buy_sell = std_logic_vector'("111") and store_px < b1_px) or
                             (store_buy_sell = std_logic_vector'("000") and store_px > b1_px) ) then
                      -- no deal: this is the correct store_item but there's no match
                      b2_px_type <= std_logic_vector'(std_logic_vector'("11101"));
                   else
                      -- send a return order
                      b2_buy_sell <= store_buy_sell;   -- 111 buy, 000 sell
                      b2_sec <= store_sec;                                          -- 7x 8bits securities identifier
                      b2_id <= store_id;                                            -- unique/identifier/counter
                      b2_px <= b1_px;                   -- price
                      -- b2_qty <= 
                      if b1_qty < store_qty then 
                         b2_qty <= b1_qty;
                      else 
                         b2_qty <= store_qty; 
                      end if;    -- quantity
                      -- update the store
                      -- store_qty
                      if (b1_qty < store_qty) then 
                         store_qty <= std_logic_vector(to_unsigned( to_integer(unsigned(store_qty)) - to_integer(unsigned(b1_qty)) ,16 ));
                      else  
                         store_qty <= (others => '0');
                      end  if;
                      b2_px_type <= std_logic_vector'(std_logic_vector'("11100"));
                   end if;
                   state <= 8;

            else
               -- no action
               null;
            end if;   -- b1_px_type

         else     -- b1_px_valid
            -- no incoming b1_px so check for state machine actions
            case state is
               when 8 => 
                   -- sent return order, so clean up
                   b2_px_type  <= (others => 'Z');
                   b2_buy_sell <= (others => 'Z');    -- 111 buy, 000 sell
                   b2_px       <= (others => 'Z');    -- price
                   b2_qty      <= (others => 'Z');    -- quantity
                   b2_sec      <= (others => 'Z');    -- 7x 8bits securities identifier
                   b2_id       <= (others => 'Z');    -- unique/identifier/counter
                   --
                   b2_px_type <= std_logic_vector'("ZZZZZ");
                   state <= 16;

               when others => null;
            end case;   -- state
            
            if (state < 16) then
               state <= state + 1;
            end if;

         end if;     -- b1_px_valid
 
      end if;
   end process match;

end search_item_implementation;

