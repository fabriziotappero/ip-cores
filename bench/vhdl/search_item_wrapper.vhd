--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// search_item.vhd                                              ////
--//                                                              ////
--// This file is part of the open_hitter opencores effort.       ////
--// <http://www.opencores.org/cores/open_hitter/>                ////
--//                                                              ////
--// Module Description:                                          ////
--// Simulation program (non-synthesizable)                       ////
--// Drives auto regression tests via NSEW button actions and     ////
--// NSEW LED reporting                                           ////
--// target env: ghdl <attrib required>                           ////
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
use std.textio.all; --  Imports the standard textio package.

entity search_item_wrapper is
end search_item_wrapper;

architecture behaviour of search_item_wrapper is
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
   for search_item_0: search_item use entity work.search_item;
        signal RX_CLK: std_logic;
        -- control flag(s) on the incoming bus
           signal b1_px_valid: std_logic;
        -- pxdata: in price_packet
           signal b1_px_type: std_logic_vector(4 downto 0);
           signal b1_buy_sell: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           signal b1_px: std_logic_vector(15 downto 0);     -- price
           signal b1_qty: std_logic_vector(15 downto 0);    -- quantity
           signal b1_sec: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           signal b1_id: std_logic_vector(15 downto 0);    -- unique/identifier/counter
        -- pxdata: out price_packet
           signal b2_px_type: std_logic_vector(4 downto 0);
           signal b2_buy_sell: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           signal b2_px: std_logic_vector(15 downto 0);     -- price
           signal b2_qty: std_logic_vector(15 downto 0);    -- quantity
           signal b2_sec: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           signal b2_id: std_logic_vector(15 downto 0);     -- unique/identifier/counter
   begin
        search_item_0: search_item 
           generic map ( item_id => std_logic_vector'("0110011001100110") )
           port map (
              RX_CLK => RX_CLK,
           -- control flag(s) on the incoming bus
              b1_px_valid => b1_px_valid,
           -- pxdata: in price_packet
              b1_px_type => b1_px_type,
              b1_buy_sell => b1_buy_sell,
              b1_px => b1_px,
              b1_qty => b1_qty,
              b1_sec => b1_sec,
              b1_id => b1_id,
           -- pxdata: out price_packet
              b2_px_type => b2_px_type,
              b2_buy_sell => b2_buy_sell,
              b2_px => b2_px,
              b2_qty => b2_qty,
              b2_sec => b2_sec,
              b2_id => b2_id
           );
   process
        variable l : line;

        type input_pattern_type is record
           -- control flag(s) on the incoming bus
              b1_px_valid: std_logic;
           -- pxdata: in price_packet
              b1_px_type: std_logic_vector(4 downto 0);
              b1_buy_sell: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
              b1_px: std_logic_vector(15 downto 0);     -- price
              b1_qty: std_logic_vector(15 downto 0);    -- quantity
              b1_sec: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
              b1_id: std_logic_vector(15 downto 0);    -- unique/identifier/counter
         end record;
         type output_pattern_type is record
            -- pxdata: out price_packet
              b2_px_type: std_logic_vector(4 downto 0);
              b2_buy_sell: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
              b2_px: std_logic_vector(15 downto 0);     -- price
              b2_qty: std_logic_vector(15 downto 0);    -- quantity
              b2_sec: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
              b2_id: std_logic_vector(15 downto 0);      -- unique/identifier/counter
         end record;

         --  The patterns to apply.
         constant zz_px: std_logic_vector(15 downto 0) := (others => 'Z'); 
         constant zz_qty: std_logic_vector(15 downto 0) := (others => 'Z'); 
         constant zz_sec: std_logic_vector(55 downto 0) := (others => 'Z'); 
         constant zz_id: std_logic_vector(15 downto 0) := (others => 'Z'); 
         constant set_qty: std_logic_vector(15 downto 0) := std_logic_vector'("0000000000010000"); 
         constant test_px: std_logic_vector(15 downto 0) := std_logic_vector'("0000000011100000"); 
         constant test_qty: std_logic_vector(15 downto 0) := std_logic_vector'("0000000000001100"); 
         constant remain_qty: std_logic_vector(15 downto 0) := std_logic_vector'("0000000000000100"); 
         constant test_sec: std_logic_vector(55 downto 0) := std_logic_vector'(X"ABA543332178DC"); 
         constant test_id: std_logic_vector(15 downto 0) := std_logic_vector'("0110011001100110");
         constant other_id: std_logic_vector(15 downto 0) := std_logic_vector'("0000010001100010");
         constant other_px: std_logic_vector(15 downto 0) := std_logic_vector'("0000000000001110");
         constant other_sec: std_logic_vector(55 downto 0) := std_logic_vector'(X"CDC423354634AA"); 
         type input_pattern_array is array (natural range <>) of input_pattern_type;
           constant input_patterns : input_pattern_array :=
             ( ('1', std_logic_vector'("00000"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id), -- 0 reset
               ('0', std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id), -- 1 nothing
               ('1', std_logic_vector'("01010"), std_logic_vector'("000"), test_px, set_qty, test_sec, other_id),  -- 2 bad sec/set
               ('1', std_logic_vector'("01010"), std_logic_vector'("000"), test_px, set_qty, test_sec, test_id),  -- 3 sec/set
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), test_px, test_qty, test_sec, zz_id),   -- 4 incoming px 
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), test_px, zz_qty, other_sec, zz_id),   -- 5 incoming px (wrong security)
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), other_px, test_qty, test_sec, zz_id),   -- 6 incoming px (too low sale price)
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), test_px, test_qty, test_sec, zz_id) ); -- 7 incoming px (part qty)
         type output_pattern_array is array (natural range <>) of output_pattern_type;
           constant output_patterns : output_pattern_array :=
             ( (std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 0 reset
               (std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 1 nothing
               (std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 2 nothing (bad sec/set)
               (std_logic_vector'("01010"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, test_id),  -- 3 sec/set
               (std_logic_vector'("11100"), std_logic_vector'("000"), test_px, test_qty, test_sec, test_id),  -- 4 incoming px
               (std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 5 incoming px (wrong security)
               (std_logic_vector'("11101"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 6 incoming px (too low sale price)
               (std_logic_vector'("11100"), std_logic_vector'("000"), test_px, remain_qty, test_sec, test_id) );  -- 7 incoming px (part qty)

   begin
        write (l, String'("Exercising search_item"));
        writeline (output, l);
        RX_CLK <= '0';
        wait for 1 ns;

           --  Check each pattern.
           for i in input_patterns'range loop
              --  Set the inputs.
              b1_px_valid <= input_patterns(i).b1_px_valid;
              b1_px_type <= input_patterns(i).b1_px_type;
              b1_buy_sell<= input_patterns(i).b1_buy_sell;
              b1_px <= input_patterns(i).b1_px;
              b1_qty <= input_patterns(i).b1_qty;
              b1_sec <= input_patterns(i).b1_sec;
              b1_id <= input_patterns(i).b1_id;
              --  Clock once for the results.
              RX_CLK <= '1';
              wait for 1 ns;
              --  Check the outputs.
              write(l, i);
              writeline (output, l);
              assert b2_px_type = output_patterns(i).b2_px_type report "search_item_wrapper: bad px type" severity error;
              assert b2_buy_sell = output_patterns(i).b2_buy_sell report "search_item_wrapper: bad buy_sell" severity error;
              assert b2_px = output_patterns(i).b2_px report "search_item_wrapper: bad px" severity error;
              assert b2_qty = output_patterns(i).b2_qty report "search_item_wrapper: bad qty" severity error;
              assert b2_sec = output_patterns(i).b2_sec report "search_item_wrapper: bad sec" severity error;
              assert b2_id = output_patterns(i).b2_id report "search_item_wrapper: bad id" severity error;
              --  Clock down.
              RX_CLK <= '0';
              wait for 1 ns;
              b1_px_valid <= '0';
              RX_CLK <= '1';
              wait for 1 ns;
              RX_CLK <= '0';
              wait for 1 ns;
           end loop;
      --     assert false report "end of test" severity note;
 
        write (l, String'("Done search_item"));
        writeline (output, l);

        wait;
        end process;
     end behaviour;

