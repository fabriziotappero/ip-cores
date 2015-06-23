--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// parse_price.vhd                                              ////
--//                                                              ////
--// This file is part of the open_hitter opencores effort.       ////
--// <http://www.opencores.org/cores/open_hitter/>                ////
--//                                                              ////
--// Module Description:                                          ////
--// Byte stream input, open hitter price output                  ////
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

entity parse_price is
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
end parse_price;

architecture parse_price_implementation of parse_price is
   signal infield: std_logic_vector(55 downto 0);
   signal pos: integer range 0 to 14 := 14;
begin
   parse: process (RX_CLK) is
   begin
      if rising_edge(RX_CLK) then
         case pos is
            when 0 => 
                px_type <= in_byte(7 downto 3);
                buy_sell <= in_byte(2 downto 0);
            when 2 =>
                px(15 downto 8) <= infield(7 downto 0);
                px(7 downto 0) <= in_byte;
            when 4 =>
                qty(15 downto 8) <= infield(7 downto 0);
                qty(7 downto 0) <= in_byte;
            when 11 =>
                sec(55 downto 8) <= infield(47 downto 0);
                sec(7 downto 0) <= in_byte;
            when 13 =>
                id(15 downto 8) <= infield(7 downto 0);
                id(7 downto 0) <= in_byte;
                price_ready <= std_logic'('1');
            when others => null;
         end case;
 
         if (byte_reset = '1') then
            pos <= 0;
         elsif (pos = 14) then
            pos <= 14;
         elsif (byte_ready = '1') then
            pos <= pos+1;
         else
            pos <= pos;
         end if;

         infield(55 downto 8) <= infield(47 downto 0);
         infield(7 downto 0) <= in_byte;

      end if;
   end process parse;

end parse_price_implementation;

-- 2008: can make price packet generic, eg;
--    generic ( type price_packet );
-- type price_packet is record
--    px_type: std_logic_vector(4 downto 0);
--    buy_sell: std_logic_vector(2 downto 0);   -- 111 buy, 000 sell
--    px: std_logic_vector(15 downto 0);     -- price   
--    qty: std_logic_vector(15 downto 0);    -- quantity
--    sec: std_logic_vector(55 downto 0);    -- 7x 8bits securities identifier
--    id: std_logic_vector(15 downto 0);     -- unique/identifier/counter
-- end record price_packet;

