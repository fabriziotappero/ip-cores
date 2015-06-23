--------------------------------------------------------------------------------
-- UART Receiver 19200/8N1                                                    --
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
use work.iuart.all;

entity uartr is
   port(
      si            : in  slave_in_t;
      so            : out slave_out_t;
   -- Non-Wishbone Signals
      RS232_DCE_RXD : in  std_logic
   );
end uartr;

architecture rtl of uartr is

   type state_t is (Idle, Start, Data, Stop, Ack, Ack2);

   type receiver_t is record
      s : state_t;                           -- Receiver state.
      n : natural range 0 to 15;             -- Tick counter.
      m : natural range 0 to 7;              -- Data bits counter.
      d : std_logic_vector(7 downto 0);      -- Data bits shift register.
   end record;

   type rx_t is record
      tick : std_logic;
      rst  : std_logic;
      ack  : std_logic;
   end record;

   signal rcv, rcvin : receiver_t;
   signal rx : rx_t;
begin

   -----------------------------------------------------------------------------
   -- Receiver Rate Generator                                                 --
   -----------------------------------------------------------------------------
   rx_rate : counter
      generic map(
         FREQ => 50,
         RATE => 19200
      )
      port map(
         clk  => si.clk,
         rst  => rx.rst,
         tick => rx.tick
      );

   -----------------------------------------------------------------------------
   -- Receiver Controller                                                     --
   -----------------------------------------------------------------------------
   receiver : process(RS232_DCE_RXD, rcv, rx.tick, si)
   begin

      rcvin  <= rcv;
      rx.rst <= '0';
      rx.ack <= '0';

      case rcv.s is

         -- Wait for receive signal to be set low - Start of new data package.
         when Idle =>
            rx.rst <= '1';
            if RS232_DCE_RXD = '0' then
               rcvin.n <= 0;
               rcvin.s <= Start;
            end if;

         when Start =>
            if rx.tick = '1' then
               if rcv.n = 7 then
                  rcvin.n <= 0;
                  rcvin.m <= 0;
                  rcvin.s <= Data;
               else
                  rcvin.n <= rcv.n + 1;
               end if;
            end if;
         
         -- Shift in all data bits. Least significant bit first.
         when Data =>
            if rx.tick = '1' then
               if rcv.n = 15 then
                  rcvin.n <= 0;
                  rcvin.d <= RS232_DCE_RXD & rcv.d(7 downto 1);
                  if rcv.m = 7 then
                     rcvin.s <= Stop;
                  else
                     rcvin.m <= rcv.m + 1;
                  end if;
               else
                  rcvin.n <= rcv.n + 1;
               end if;
            end if;

         when Stop =>
            if rx.tick = '1' then
               if rcv.n = 15 then
                  rcvin.s <= Ack;
               else
                  rcvin.n <= rcv.n + 1;
               end if;
            end if;

         when Ack =>
            if wb_read(si) then
               rx.ack <= '1';
               rcvin.s <= Ack2;
            end if;

         when Ack2 =>
            rx.ack <= '1';
            if si.stb = '0' then
               rcvin.s <= Idle;
            end if;
      end case;
   end process;

   so.dat <= x"0000" & rx.ack & "0000000" & rcv.d;
   so.ack <= rx.ack;

   -----------------------------------------------------------------------------
   -- Registers                                                               --
   -----------------------------------------------------------------------------
   reg : process(si.clk)
   begin
      if rising_edge(si.clk) then
         rcv <= rcvin;
         if si.rst = '1' then
            rcv.s <= Idle;
         end if;
      end if;
   end process;
end rtl;