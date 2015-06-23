--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// search_control.vhd                                           ////
--//                                                              ////
--// This file is part of the open_hitter opencores effort.       ////
--// <http://www.opencores.org/cores/open_hitter/>                ////
--//                                                              ////
--// Module Description:                                          ////
--// This is the multipelexed search's control item, used to set  ////
--// up, access and control the search.                           ////
--//    search_*_i - input to search_control                      ////
--//    order_*_o - output from search_control                    ////  
--// Buses perform the multiplex and are experienced by each item ////
--// as b1_* - set by search_control, input to search_item        ////
--//    b2_* - output from search_item, read by search_control    ////
--// The state machine in search_control coordinates the search,  ////
--// and the number of transitions is dependant on the incoming   ////
--// instruction (search_*_i).                                    ////
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

entity search_control is
   generic ( searchitems : integer );
   port (
        RX_CLK: in std_logic;
        -- control flag(s) on the incoming bus
           search_px_valid_i: in std_logic;
        -- pxdata: in price_packet
           search_px_type_i: in std_logic_vector(4 downto 0);
           search_buy_sell_i: in std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           search_px_i: in std_logic_vector(15 downto 0);     -- price
           search_qty_i: in std_logic_vector(15 downto 0);    -- quantity
           search_sec_i: in std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           search_id_i: in std_logic_vector(15 downto 0);    -- unique/identifier/counter
        -- pxdata: out price_packet
           order_px_type_o: out std_logic_vector(4 downto 0);
           order_buy_sell_o: out std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           order_px_o: out std_logic_vector(15 downto 0);     -- price
           order_qty_o: out std_logic_vector(15 downto 0);    -- quantity
           order_sec_o: out std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           order_id_o: out std_logic_vector(15 downto 0);     -- unique/identifier/counter
        -- control flag(s) on the outgoing bus
           order_px_valid_o: out std_logic
   );
end search_control;

architecture search_control_implementation of search_control is
      component search_item
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
      end component;
       -- for search_item_0: search_item use entity work.search_item;
      signal searchitems_count : integer := 0;
      --
      signal state : integer range 0 to 16 := 16;
   -- pxdata: store price_packet
      signal store_px_type: std_logic_vector(4 downto 0) := (others => '0');
      signal store_buy_sell: std_logic_vector(2 downto 0) := (others => '0');   -- 111 buy, 000 sell
      signal store_px: std_logic_vector(15 downto 0) := (others => '0');     -- price
      signal store_qty: std_logic_vector(15 downto 0) := (others => '0');    -- quantity
      signal store_sec: std_logic_vector(55 downto 0) := (others => '0');    -- 7x 8bits securities identifier
      signal store_id: std_logic_vector(15 downto 0) := (others => '0');     -- unique/identifier/counter
   -- control flag(s) on the incoming bus
      signal b1_px_valid: std_logic;
   -- pxdata: b1 price_packet
      signal b1_px_type: std_logic_vector(4 downto 0) := (others => '0');
      signal b1_buy_sell: std_logic_vector(2 downto 0) := (others => '0');   -- 111 buy, 000 sell
      signal b1_px: std_logic_vector(15 downto 0) := (others => '0');     -- price
      signal b1_qty: std_logic_vector(15 downto 0) := (others => '0');    -- quantity
      signal b1_sec: std_logic_vector(55 downto 0) := (others => '0');    -- 7x 8bits securities identifier
      signal b1_id: std_logic_vector(15 downto 0) := (others => '0');     -- unique/identifier/counter
   -- pxdata: b2 price_packet
      signal b2_px_type: std_logic_vector(4 downto 0) := (others => '0');
      signal b2_buy_sell: std_logic_vector(2 downto 0) := (others => '0');   -- 111 buy, 000 sell
      signal b2_px: std_logic_vector(15 downto 0) := (others => '0');     -- price
      signal b2_qty: std_logic_vector(15 downto 0) := (others => '0');    -- quantity
      signal b2_sec: std_logic_vector(55 downto 0) := (others => '0');    -- 7x 8bits securities identifier
      signal b2_id: std_logic_vector(15 downto 0) := (others => '0');     -- unique/identifier/counter
begin
      items_array : for iter_id in 0 to searchitems - 1 generate
      begin
         cell_item : entity work.search_item
            generic map ( item_id => std_logic_vector(to_unsigned(iter_id,16)) )
            port map (
                         RX_CLK => RX_CLK,
                         b1_px_valid => b1_px_valid,
                         b1_px_type => b1_px_type, b1_buy_sell => b1_buy_sell, b1_px => b1_px, b1_qty => b1_qty, b1_sec => b1_sec, b1_id => b2_id,
                         b2_px_type => b2_px_type, b2_buy_sell => b2_buy_sell, b2_px => b2_px, b2_qty => b2_qty, b2_sec => b2_sec, b2_id => b2_id 
                     );
      end generate items_array;
   
   match: process (RX_CLK) is
   begin
      if rising_edge(RX_CLK) then
         if search_px_valid_i = '1' then

            if search_px_type_i = std_logic_vector'("00000") then
                   -- do reset store and outputs
                   order_px_type_o  <= (others => 'Z');
                   order_buy_sell_o <= (others => 'Z');   -- 111 buy, 000 sell
                   order_px_o       <= (others => 'Z');   -- price
                   order_qty_o      <= (others => 'Z');   -- quantity
                   order_sec_o      <= (others => 'Z');   -- 7x 8bits securities identifier
                   order_px_valid_o <= '1';
                   --
                   b1_px_type  <= (others => '0');
                   b1_buy_sell <= (others => '0');   -- 111 buy, 000 sell
                   b1_px       <= (others => '0');   -- price
                   b1_qty      <= (others => '0');   -- quantity
                   b1_sec      <= (others => '0');   -- 7x 8bits securities identifier
                   -- b1_id      <= (others => '0');   -- unique/identifier/counter
                   b1_px_valid <= '1';
                   --
                   searchitems_count <= 0;  
                   state <= 8;

            elsif search_px_type_i = std_logic_vector'("00110") then
                   -- do set store from incoming price 
                   store_px_type  <= b1_px_type;
                   store_buy_sell <= b1_buy_sell;
                   store_px       <= b1_px;
                   store_qty      <= b1_qty;
                   store_sec      <= b1_sec;
                   store_id       <= b1_id;
                   --
                   b2_px_type <= std_logic_vector'(std_logic_vector'("00000"));
                   state <= 8;

            elsif search_px_type_i = std_logic_vector'("00101") then
                   -- incoming price, register it and start the state machine
                   if (store_sec /= b1_sec or store_buy_sell = b1_buy_sell or store_px_type /= std_logic_vector'(std_logic_vector'("0110")) ) then
                      -- not this store_item instance no action, also stop anything that might be going on
                      state <= 14;
                   elsif (to_integer(unsigned(store_qty)) = 0 or to_integer(unsigned(b1_qty)) = 0 or 
                             (store_buy_sell = std_logic_vector'("111") and store_px < b1_px) or
                             (store_buy_sell = std_logic_vector'("000") and store_px > b1_px) ) then
                      -- no deal: this is the correct store_item but there's no match
                      b2_px_type <= std_logic_vector'(std_logic_vector'("00000"));
                      state <= 8;
                   else
                      -- send a return order
                      b2_px_type <= std_logic_vector'("1010");
                      b2_buy_sell <= store_buy_sell;   -- 111 buy, 000 sell
                      b2_px <= b1_px;                   -- price
                      -- b2_qty <= 
                      if b1_qty < store_qty then 
                         b2_qty <= b1_qty;
                      else 
                         b2_qty <= store_qty; 
                      end if;    -- quantity
                      b2_sec <= store_sec;                                          -- 7x 8bits securities identifier
                      b2_id <= store_id;                                            -- unique/identifier/counter
                      -- update the store
                      -- store_qty
                      if (b1_qty < store_qty) then 
                         store_qty <= std_logic_vector(to_unsigned( to_integer(unsigned(store_qty)) - to_integer(unsigned(b1_qty)) ,16 ));
                      else  
                         store_qty <= (others => '0');
                         state <= 1;
                      end  if;
                   end if;

            else
               -- no action
               null;
            end if;   -- search_px_type

         else     -- search_px_valid_i
            -- no incoming search_px_i so check for state machine actions
            case state is
               when 1 => 
                   -- sent return order, so clean up
                   b2_px_type  <= (others => 'Z');
                   b2_buy_sell <= (others => 'Z');    -- 111 buy, 000 sell
                   b2_px       <= (others => 'Z');    -- price
                   b2_qty      <= (others => 'Z');    -- quantity
                   b2_sec      <= (others => 'Z');    -- 7x 8bits securities identifier
                   b2_id       <= (others => 'Z');    -- unique/identifier/counter
                   state <= 16;

               when 8 =>
                    -- correct store_item but there was no match
                    b2_px_type <= std_logic_vector'("ZZZZZ");
                   state <= 16;
                   order_px_valid_o <= '0';

               when others => null;
            end case;   -- state
            
            if (state < 16) then
               state <= state + 1;
            end if;

         end if;     -- search_px_valid_i
 
      end if;
   end process match;

end search_control_implementation;

