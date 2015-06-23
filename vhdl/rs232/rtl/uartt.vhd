--------------------------------------------------------------------------------
-- UART Transmitter 19200/8N1                                                 --
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

entity uartt is
   port(
      si            : in  slave_in_t;
      so            : out slave_out_t;
   -- Non-Wishbone Signals
      RS232_DCE_TXD : out std_logic
   );
end uartt;

architecture rtl of uartt is

   type state_t is (Idle, Start, Data, Stop, Ack);

   type sender_t is record
      s : state_t;                           -- Sender state.
      n : natural range 0 to 15;             -- Tick counter.
      m : natural range 0 to 7;              -- Data bits counter.
      d : std_logic_vector(7 downto 0);      -- Data bits shift register.
   end record;

   type tx_t is record
      tick : std_logic;
      rst  : std_logic;
      ack  : std_logic;
   end record;

   signal snd, sndin : sender_t;
   signal tx : tx_t;
begin

   -----------------------------------------------------------------------------
   -- Transmitter Rate Generator                                              --
   -----------------------------------------------------------------------------
   tx_rate : counter
      generic map(
         FREQ => 50,
         RATE => 19200
      )
      port map(
         clk  => si.clk,
         rst  => tx.rst,
         tick => tx.tick
      );

   -----------------------------------------------------------------------------
   -- Transmitter Controller                                                  --
   -----------------------------------------------------------------------------
   receiver : process(snd, tx.tick, si)
   begin

      sndin         <= snd;
      tx.rst        <= '0';
      tx.ack        <= '0';
      RS232_DCE_TXD <= '1';                     -- Idle line is alwasys '1'.

      case snd.s is
         when Idle =>
            tx.rst <= '1';
            if wb_write(si) then
               sndin.n <= 0;
               sndin.d <= si.dat(7 downto 0);
               sndin.s <= Start;
            end if;

         when Start =>
            RS232_DCE_TXD <= '0';
            if tx.tick = '1' then
               if snd.n = 15 then
                  sndin.n <= 0;
                  sndin.m <= 0;
                  sndin.s <= Data;
               else
                  sndin.n <= snd.n + 1;
               end if;
            end if;

         when Data =>
            RS232_DCE_TXD <= snd.d(0);
            if tx.tick = '1' then
               if snd.n = 15 then
                  sndin.n <= 0;
                  sndin.d <= '0' & snd.d(7 downto 1);
                  if snd.m = 7 then
                     sndin.s <= Stop;
                  else
                     sndin.m <= snd.m + 1;
                  end if;
               else
                  sndin.n <= snd.n + 1;
               end if;
            end if;

         when Stop =>
            if tx.tick = '1' then
               if snd.n = 15 then
                  sndin.s <= Ack;
               else
                  sndin.n <= snd.n + 1;
               end if;
            end if;

         when Ack =>
            tx.ack <= '1';
            if si.stb = '0' then
               sndin.s <= Idle;
            end if;

      end case;
   end process;

   so.dat <= (others => '-');
   so.ack <= tx.ack;

   -----------------------------------------------------------------------------
   -- Registers                                                               --
   -----------------------------------------------------------------------------
   reg : process(si.clk)
   begin
      if rising_edge(si.clk) then
         snd <= sndin;
         if si.rst = '1' then
            snd.s <= Idle;
         end if;
      end if;
   end process;
end rtl;