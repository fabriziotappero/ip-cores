----------------------------------------------------------------------
----                                                              ----
----  PLB2WB-Bridge                                               ----
----                                                              ----
----  This file is part of the PLB-to-WB-Bridge project           ----
----  http://opencores.org/project,plb2wbbridge                   ----
----                                                              ----
----  Description                                                 ----
----  Implementation of a PLB-to-WB-Bridge according to           ----
----  PLB-to-WB Bridge specification document.                    ----
----                                                              ----
----  To Do:                                                      ----
----   Nothing                                                    ----
----                                                              ----
----  Author(s):                                                  ----
----      - Christian Haettich                                    ----
----        feddischson@opencores.org                             ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2010 Authors                                   ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity plb2wb_short_impulse is
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           IMPULSE : in  STD_LOGIC;
           SHORT_IMPULSE : out  STD_LOGIC);
end plb2wb_short_impulse;

architecture IMP of plb2wb_short_impulse is


type state is record
   was_down       : std_logic;
   start_of_high  : std_logic;
end record;

signal current_state, next_state : state;

begin

states_state : process( CLK, RESET )

   begin
        if CLK'event and CLK='1' then

           if RESET = '1' then

              current_state <= (   was_down       => '0',
                                   start_of_high  => '0' );

           else
               current_state <= next_state;
           end if;

        end if;
   end process;



detection : process( current_state, IMPULSE )
   begin

      next_state                 <= current_state;
      next_state.start_of_high   <= '0';
      SHORT_IMPULSE              <= '0';

      if current_state.was_down = '1' and IMPULSE = '1' then
         next_state.was_down        <= '0';
         next_State.start_of_high   <= '1';
         SHORT_IMPULSE              <= '1';
      end if;

      if current_state.was_down = '0' and IMPULSE = '0' then
         next_state.was_down        <= '1';
      end if;

   end process;



end IMP;

