--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// hitter_sim.vhd                                               ////
--//                                                              ////
--// This file is part of the open_hitter opencores effort.       ////
--// <http://www.opencores.org/cores/open_hitter/>                ////
--//                                                              ////
--// Module Description:                                          ////
--//    Synthesizable simulation class for the class 'hitter'     ////
--//    * translates button actions/results onto NSEW buttons     ////
--//      and NSEW LEDs                                           ////
--//    * target env: Xilinx Virtex 6 / ML605                     ////
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

entity hitter_sim is
port (
        RX_CLK: in std_logic;
        PUSH_BUTTONS_5BITS_TRI_I: in std_logic_vector(4 downto 0);
        LEDS_POSITIONS_TRI_O: out std_logic_vector(4 downto 0)
);
end hitter_sim;

architecture implementation of hitter_sim is
   component parse_price_sim
      port (
         RX_CLK: in std_logic;
         restart: in std_logic;
         processing: out std_logic;
         result_is_ok: out std_logic
      );
   end component;
   for parse_price_sim_0: parse_price_sim use entity work.parse_price_sim;
       --signal RX_CLK: std_logic;
       signal restart: std_logic;
       signal processing: std_logic;
       signal result_is_ok: std_logic;
   --
   signal alight: std_logic := '0';
   signal pos: integer := 0;
begin
   parse_price_sim_0: parse_price_sim port map (
       RX_CLK => RX_CLK,
       restart => restart,
       processing => processing,
       result_is_ok => result_is_ok
   );
   --
   flasher: process (RX_CLK) is
   begin
      if rising_edge(RX_CLK) then
         if (pos < 4) then         -- ghdl flash
    --  if (pos < 62500000) then   -- 125Mhz timing / 0.5s
            pos <= pos + 1;
         else
            alight <= not alight;
            pos <= 0;
         end if;
      end if;
   end process flasher;

   LEDS_POSITIONS_TRI_O(0) <= alight;
   LEDS_POSITIONS_TRI_O(1) <= result_is_ok;
   LEDS_POSITIONS_TRI_O(2) <= result_is_ok;
   LEDS_POSITIONS_TRI_O(3) <= processing;
   LEDS_POSITIONS_TRI_O(4) <= alight;
   restart <= PUSH_BUTTONS_5BITS_TRI_I(0);
end implementation;

