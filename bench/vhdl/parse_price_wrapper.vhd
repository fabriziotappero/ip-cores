--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// parse_price_wrapper.vhd                                      ////
--//                                                              ////
--// This file is part of the open_hitter opencores effort.       ////
--// <http://www.opencores.org/cores/open_hitter/>                ////
--//                                                              ////
--// Module Description:                                          ////
--// Simulation program (non-synthesizable)                       ////
--// Single module development: parse_price.vhd                   ////
--// target env: ghdl <attrib required>                           ////        
--//                                                              ////
--// To Do:                                                       ////
--//    #LOTS                                                     ////
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
use std.textio.all; --  Imports the standard textio package.
-- use ieee.std_logic_textio.all;

     entity parse_price_wrapper is
     end parse_price_wrapper;
     
     architecture behaviour of parse_price_wrapper is
        component parse_price
           port (
               RX_CLK: in std_logic;
               in_byte: in std_logic_vector(7 downto 0);
               byte_reset: in std_logic;
               byte_ready: in std_logic;
               price_ready: out std_logic;
               -- pxdata: out price_packet
                  px_type: out std_logic_vector(4 downto 0);
                  buy_sell: out std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
                  px: out std_logic_vector(15 downto 0);     -- price
                  qty: out std_logic_vector(15 downto 0);    -- quantity
                  sec: out std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
                  id: out std_logic_vector(15 downto 0)     -- unique/identifier/counter
           );
        end component;
        for parse_price_0: parse_price use entity work.parse_price;
               signal RX_CLK: std_logic;
               signal in_byte: std_logic_vector(7 downto 0);
               signal byte_reset: std_logic;
               signal byte_ready: std_logic;
               signal price_ready: std_logic;
               -- pxdata: price_packet
                  signal px_type: std_logic_vector(4 downto 0);
                  signal buy_sell: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
                  signal px: std_logic_vector(15 downto 0);     -- price
                  signal qty: std_logic_vector(15 downto 0);    -- quantity
                  signal sec: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
                  signal id: std_logic_vector(15 downto 0);     -- unique/identifier/counter
     begin
        parse_price_0: parse_price port map (
               RX_CLK => RX_CLK,
               in_byte => in_byte,
               byte_reset => byte_reset,
               byte_ready => byte_ready,
               price_ready => price_ready,
               -- price_packet
                  px_type => px_type,
                  buy_sell => buy_sell,
                  px => px,
                  qty => qty,
                  sec => sec,
                  id => id
               );
        process
           variable l : line;
           --                                                          WWHHAATTSSEECC
           constant pkt : std_logic_vector(111 downto 0) := X"081234567857484154534543C078";
           variable pos : integer;
           variable offset : integer;
           variable eoffset : integer;
        begin
           write (l, String'("Exercising parse_price"));
           writeline (output, l);

              byte_reset <= '1';
              byte_ready <= '0';
              RX_CLK <= '0';
              wait for 1 ns;
              RX_CLK <= '1';
              wait for 1 ns;
              RX_CLK <= '0';
              wait for 1 ns;

              for pos in 13 downto 0 loop
                 in_byte <= pkt(8*pos+7 downto 8*pos);
                 byte_ready <= '1';
                 byte_reset <= '0';
                 RX_CLK <= '1';
                 wait for 1 ns;

                 for i in in_byte'range loop
                    write(l, std_logic'image(in_byte(i)) );
                 end loop;

                 write(l, String'(" px_type:"));
                 for i in px_type'range loop
                    write(l, std_logic'image(px_type(i)) );
                 end loop;

                 write(l, String'(" buy_sell:"));
                 for i in buy_sell'range loop
                    write(l, std_logic'image(buy_sell(i)) );
                 end loop;

                 write(l, String'(" px:"));
                 for i in px'range loop
                    write(l, std_logic'image(px(i)) );
                 end loop;

                 write(l, String'(" qty:"));
                 for i in qty'range loop
                    write(l, std_logic'image(qty(i)) );
                 end loop;

                 write(l, String'(" sec:"));
                 for i in sec'range loop
                    write(l, std_logic'image(sec(i)) );
                 end loop;

                 write(l, String'(" id:"));
                 for i in id'range loop
                    write(l, std_logic'image(id(i)) );
                 end loop;

                 writeline(output, l);

                 RX_CLK <= '0';
                 wait for 1 ns;
              end loop;

           write (l, String'("Done parse_price"));
           writeline (output, l);
                                                                                   --  081234 5678 574841545345 43C0
           if (px_type = B"00001") and (buy_sell = B"000") and (px = B"00010010_00110100")  -- 081234
              and (qty = B"01010110_01111000")                                              -- 5678  
              and (sec = B"01010111_01001000_01000001_01010100_01010011_01000101_01000011") -- 57484154534543
              and (id  = B"11000000_01111000")                                              -- C078
           then
               write (l, String'("... and Price is OK."));
               writeline (output, l);
           else
               write (l, String'("... and price check failed."));
               writeline (output, l);
           end if;

           wait;
        end process;
     end behaviour;
