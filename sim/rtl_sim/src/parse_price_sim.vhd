--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// parse_price_sim.vhd                                          ////
--//                                                              ////
--// This file is part of the open_hitter opencores effort.       ////
--// <http://www.opencores.org/cores/open_hitter/>                ////
--//                                                              ////
--// Module Description:                                          ////
--// Simulation program (synthesizable)                           ////
--// Unit test for parse_price.vhd                                ////
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

     entity parse_price_sim is
     port (
            RX_CLK: in std_logic;
            restart: in std_logic;        
            processing: out std_logic;  
            result_is_ok: out std_logic
     );
     end parse_price_sim;
     
     architecture behav of parse_price_sim is
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
        --  Specifies which entity is bound with the component.
        for parse_price_0: parse_price use entity work.parse_price;
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
         signal pos: integer;
     begin
        --  Component instantiation.
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
        process (RX_CLK) is
           constant pkt : std_logic_vector(111 downto 0) := X"081234567857484154534543C078";
        begin
           if rising_edge(RX_CLK) then
              if (px_type = B"00001") and (buy_sell = B"000") and (px = B"00010010_00110100")  -- 081234
                 and (qty = B"01010110_01111000")                                              -- 5678
                 and (sec = B"01010111_01001000_01000001_01010100_01010011_01000101_01000011") -- 57484154534543
                 and (id  = B"11000000_01111000")                                              -- C078
              then
                 result_is_ok <= '1';
                 processing <= '0';
              else
                 result_is_ok <= '0';
              end if;

              if ((pos > -1) and (pos < 14)) then
                 in_byte <= pkt(8*pos+7 downto 8*pos);
                 byte_reset <= '0';
                 byte_ready <= '1';
              else
                 byte_ready <= '0';
              end if;

              if (pos > -1) then
                 pos <= pos -1;
              end if;
 
              if (restart = '1') then
                 byte_reset <= '1';
                 processing <= '1';
                 pos <= 15;
              end if;

            end if;
        end process;


     end behav;
