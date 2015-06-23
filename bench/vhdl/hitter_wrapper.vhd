--////////////////////////////////////////////////////////////////////
--//                                                              ////
--// hitter_wrapper.vhd                                           ////
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

     entity hitter_wrapper is
     end hitter_wrapper;
     
     architecture behaviour of hitter_wrapper is
        component hitter_sim
           port( RX_CLK: in std_logic;
                 PUSH_BUTTONS_5BITS_TRI_I: in std_logic_vector(4 downto 0);
                 LEDS_POSITIONS_TRI_O: out std_logic_vector(4 downto 0) 
           );
        end component;
        for hitter_sim_0: hitter_sim use entity work.hitter_sim;
        signal RX_CLK: std_logic;
        signal PUSH_BUTTONS_5BITS_TRI_I: std_logic_vector(4 downto 0);
        signal LEDS_POSITIONS_TRI_O: std_logic_vector(4 downto 0);
     begin
        hitter_sim_0: hitter_sim port map (
                         RX_CLK => RX_CLK,
                         PUSH_BUTTONS_5BITS_TRI_I => PUSH_BUTTONS_5BITS_TRI_I,
                         LEDS_POSITIONS_TRI_O => LEDS_POSITIONS_TRI_O );
        process
           variable l : line;
           variable counted : integer;
        begin
           write (l, String'("Exercising hitter_sim"));
           writeline (output, l);

           RX_CLK <= '0';
           wait for 1 ns;

           for counted in 0 to 30 loop
              -- Instruct:

              if (counted = 2) then
                 PUSH_BUTTONS_5BITS_TRI_I <= std_logic_vector'("11111");
              else
                 PUSH_BUTTONS_5BITS_TRI_I <= std_logic_vector'("00000");
              end if;

              RX_CLK <= '1';
              wait for 1 ns;

              -- Report:
              write (l, String'("Count:"));
              write(l, counted);
              write (l, String'(" LEDs: "));
              for i in LEDS_POSITIONS_TRI_O'range loop
                 case LEDS_POSITIONS_TRI_O(i) is
                    when '1' => write(l, character'('1'));
                    when others => write(l, character'('0'));
                 end case;
              end loop;
              writeline(output, l);

              -- Reset:
              RX_CLK <= '0';
              wait for 1 ns;
           end loop;

           write (l, String'("Done hitter_sim"));
           writeline (output, l);
           wait;
        end process;
     end behaviour;

