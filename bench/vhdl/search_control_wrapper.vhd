--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// search_control_wrapper.vhd                                   ////
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

entity search_control_wrapper is
end search_control_wrapper;

architecture behaviour of search_control_wrapper is
   component search_control is
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
   end component;
   for search_control_0: search_control use entity work.search_control;
        signal RX_CLK: std_logic;
        -- control flag(s) on the incoming bus
           signal search_px_valid_i: std_logic;
        -- pxdata: in price_packet
           signal search_px_type_i: std_logic_vector(4 downto 0);
           signal search_buy_sell_i: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           signal search_px_i: std_logic_vector(15 downto 0);     -- price
           signal search_qty_i: std_logic_vector(15 downto 0);    -- quantity
           signal search_sec_i: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           signal search_id_i: std_logic_vector(15 downto 0);    -- unique/identifier/counter
        -- pxdata: out price_packet
           signal order_px_type_o: std_logic_vector(4 downto 0);
           signal order_buy_sell_o: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
           signal order_px_o: std_logic_vector(15 downto 0);     -- price
           signal order_qty_o: std_logic_vector(15 downto 0);    -- quantity
           signal order_sec_o: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
           signal order_id_o: std_logic_vector(15 downto 0);     -- unique/identifier/counter
        -- control
           signal order_px_valid_o: std_logic;
   begin
        search_control_0: search_control 
           generic map ( searchitems => 3 )
           port map (
              RX_CLK => RX_CLK,
           -- control flag(s) on the incoming bus
              search_px_valid_i => search_px_valid_i,
           -- pxdata: in price_packet
              search_px_type_i => search_px_type_i,
              search_buy_sell_i => search_buy_sell_i,
              search_px_i => search_px_i,
              search_qty_i => search_qty_i,
              search_sec_i => search_sec_i,
              search_id_i => search_id_i,
           -- pxdata: out price_packet
              order_px_type_o => order_px_type_o,
              order_buy_sell_o => order_buy_sell_o,
              order_px_o => order_px_o,
              order_qty_o => order_qty_o,
              order_sec_o => order_sec_o,
              order_id_o => order_id_o,
           -- control
              order_px_valid_o => order_px_valid_o
           );
   process
        variable l : line;
        variable res : integer;

        type input_pattern_type is record
           -- control flag(s) on the incoming bus
              search_px_valid_i: std_logic;
           -- pxdata: in price_packet
              search_px_type_i: std_logic_vector(4 downto 0);
              search_buy_sell_i: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
              search_px_i: std_logic_vector(15 downto 0);     -- price
              search_qty_i: std_logic_vector(15 downto 0);    -- quantity
              search_sec_i: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
              -- search_id_i: std_logic_vector(15 downto 0);    -- unique/identifier/counter
         end record;
         type output_pattern_type is record
            -- pxdata: out price_packet
              order_px_type_o: std_logic_vector(4 downto 0);
              order_buy_sell_o: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
              order_px_o: std_logic_vector(15 downto 0);     -- price
              order_qty_o: std_logic_vector(15 downto 0);    -- quantity
              order_sec_o: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
              order_id_o: std_logic_vector(15 downto 0);      -- unique/identifier/counter
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
         constant test_sec0: std_logic_vector(55 downto 0) := std_logic_vector'(X"ABA544223478DC"); 
         constant test_sec1: std_logic_vector(55 downto 0) := std_logic_vector'(X"ABA543332178DC"); 
         constant test_sec2: std_logic_vector(55 downto 0) := std_logic_vector'(X"ABA234234378DC"); 
         constant test_sec3: std_logic_vector(55 downto 0) := std_logic_vector'(X"ABA534534578DC"); 
         constant test_id: std_logic_vector(15 downto 0) := std_logic_vector'("0110011001100110");
         constant other_id: std_logic_vector(15 downto 0) := std_logic_vector'("0000010001100010");
         constant other_px: std_logic_vector(15 downto 0) := std_logic_vector'("0000000000001110");
         constant other_sec: std_logic_vector(55 downto 0) := std_logic_vector'(X"CDC423354634AA"); 
         type input_pattern_array is array (natural range <>) of input_pattern_type;
           constant input_patterns : input_pattern_array :=
             ( ('1', std_logic_vector'("00000"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec), -- 0 reset
               ('0', std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec), -- 1 nothing
               ('1', std_logic_vector'("01010"), std_logic_vector'("000"), test_px, set_qty, test_sec0),  -- 2 sec/set
               ('1', std_logic_vector'("01010"), std_logic_vector'("000"), test_px, set_qty, test_sec1),  -- 3 sec/set
               ('1', std_logic_vector'("01010"), std_logic_vector'("111"), test_px, set_qty, test_sec2),  -- 4 sec/set
               ('1', std_logic_vector'("01010"), std_logic_vector'("000"), test_px, set_qty, test_sec3),  -- 5 too many sec/set 
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), test_px, test_qty, test_sec1),   -- 6 incoming px 
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), test_px, zz_qty, other_sec),   -- 7 incoming px (wrong security)
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), other_px, test_qty, test_sec1),   -- 8 incoming px (too low sale price)
               ('1', std_logic_vector'("11100"), std_logic_vector'("111"), test_px, test_qty, test_sec1) ); -- 9 incoming px (part qty)
         type output_pattern_array is array (natural range <>) of output_pattern_type;
           constant output_patterns : output_pattern_array :=
             ( (std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 0 reset
               (std_logic_vector'("ZZZZZ"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 1 nothing
               (std_logic_vector'("01010"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, std_logic_vector'(X"0001")),  -- 2 sec/set
               (std_logic_vector'("01010"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, std_logic_vector'(X"0002")),  -- 3 sec/set
               (std_logic_vector'("01010"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, std_logic_vector'(X"0003")),  -- 4 sec/set
               (std_logic_vector'("11111"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 5 bad sec/set (too many)
               (std_logic_vector'("11100"), std_logic_vector'("000"), test_px, test_qty, test_sec1, test_id),  -- 6 incoming px
               (std_logic_vector'("11110"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 7 incoming px (wrong security)
               (std_logic_vector'("11101"), std_logic_vector'("ZZZ"), zz_px, zz_qty, zz_sec, zz_id),  -- 8 incoming px (too low sale price)
               (std_logic_vector'("11100"), std_logic_vector'("000"), test_px, remain_qty, test_sec1, test_id) );  -- 9 incoming px (part qty)
   begin
        write (l, String'("Exercising search_control"));
        writeline (output, l);
        RX_CLK <= '0';
        wait for 1 ns;

           --  Check each pattern.
           for i in input_patterns'range loop
              --  Set the inputs.
              search_px_valid_i <= input_patterns(i).search_px_valid_i;
              search_px_type_i <= input_patterns(i).search_px_type_i;
              search_buy_sell_i <= input_patterns(i).search_buy_sell_i;
              search_px_i <= input_patterns(i).search_px_i;
              search_qty_i <= input_patterns(i).search_qty_i;
              search_sec_i <= input_patterns(i).search_sec_i;
              --search_id_i <= input_patterns(i).search_id_i;
              --  Clock once for the results.
              RX_CLK <= '1';
              wait for 1 ns;
              --  Check the outputs.
              res := 0;
              for r in 0 to 4 loop
                 if order_px_valid_o = '1' then
                    write(l, i);
                    writeline (output, l);
                    assert order_px_type_o = output_patterns(i).order_px_type_o report "search_control_wrapper: bad px type" severity error;
                    assert order_buy_sell_o = output_patterns(i).order_buy_sell_o report "search_control_wrapper: bad buy_sell" severity error;
                    assert order_px_o = output_patterns(i).order_px_o report "search_control_wrapper: bad px" severity error;
                    assert order_qty_o = output_patterns(i).order_qty_o report "search_control_wrapper: bad qty" severity error;
                    assert order_sec_o = output_patterns(i).order_sec_o report "search_control_wrapper: bad sec" severity error;
                    assert order_id_o = output_patterns(i).order_id_o report "search_control_wrapper: bad id" severity error;
                    res := res + 1;
                 end if;
                 --  Clock down.
                 RX_CLK <= '0';
                 wait for 1 ns;
                 search_px_valid_i <= '0';
                 RX_CLK <= '1';
                 wait for 1 ns;
              end loop;
              assert res = 1 report "search_control_wrapper: wrong number of results from input pattern message" severity error; 

              RX_CLK <= '0';
              wait for 1 ns;
           end loop;
      --     assert false report "end of test" severity note;
 
        write (l, String'("Done search_control"));
        writeline (output, l);

        wait;
        end process;
     end behaviour;

