--------------------------------------------------------------------------------
-- Programmable Interval Timer                                                --
--------------------------------------------------------------------------------
-- Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.comt>         --
--                                                                            --
-- This program is free software: you can redistribute it and/or modify       --
-- it under the terms of the GNU General Public License as published by       --
-- the Free Software Foundation, either version 3 of the License, or          --
-- (at your option) any later version.                                        --
--                                                                            --
-- This program is distributed in the hope that it will be useful,            --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of             --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              --
-- GNU General Public License for more details.                               --
--                                                                            --
-- You should have received a copy of the GNU General Public License          --
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.      --
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.iwb.all;

entity pit is
   port(
      si   : in  slave_in_t;
      so   : out slave_out_t;
   -- Non-Wishbone Signals
      intr : out std_logic
   );
end pit;

architecture rtl of pit is

   type state_t is (Idle, Count, Ack, Ack2);
   signal s, sin : state_t;

   signal n, nin : unsigned(31 downto 0);    -- Counter.
   signal l, lin : unsigned(31 downto 0);    -- Count limit set by the user.
begin

   -----------------------------------------------------------------------------
   -- PIT Control                                                             --
   -----------------------------------------------------------------------------
   nsl : process(s, l, n, si.stb, si.we, si.dat, si)
   begin

      sin  <= s;
      lin  <= l;
      nin  <= n;

      intr <= '0';

      case s is

         -- Wait for a WB write operation to trigger a new timer loop. The
         -- timer starts at 1 to count in the Idle state cycle.
         when Idle =>
            if wb_write(si) then
               nin <= x"00000000";
               lin <= unsigned(si.dat);
               sin <= Count;
            end if;

         when Count =>
            if n = l then
               sin <= Ack;
            else
               nin <= n + 1;
            end if;

         -- Set interrupt signal and wait for a WB write operation to reset.
         when Ack =>
            intr <= '1';
            if wb_read(si) then
               sin <= Ack2;
            end if;

         when Ack2 =>
            intr <= '1';
            if si.stb = '0' then
               sin <= Idle;
            end if;

      end case;
   end process;

   -- Reading while still counting returns the progress.
   so.dat <= std_logic_vector(n);
   so.ack <= si.stb;

   -----------------------------------------------------------------------------
   -- Registers                                                               --
   -----------------------------------------------------------------------------
   reg : process(si.clk)
   begin
      if rising_edge(si.clk) then
         s <= sin;
         n <= nin;
         l <= lin;

         if si.rst = '1' then
            s <= Idle;
         end if;
      end if;
   end process;
end rtl;