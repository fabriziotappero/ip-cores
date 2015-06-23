--------------------------------------------------------------------------------
-- UART Transceiver 19200/8N1                                                 --
--------------------------------------------------------------------------------
-- This minimal implementation of an Universal Asynchronous Receiver and      --
-- Transmitter (UART) suits a baud rate of 19200 baud/sec as well as 8 bits   --
-- of data, no parity bit and one stop bit configuration only. It comprises   --
-- two seperate baud generators to receive and transmit simultanously.        --
--                                                                            --
-- REFERENCES                                                                 --
--                                                                            --
--  [1] Chu Pong P., FPGA Prototyping By VHDL Examples,                       --
--      John Wiley & Sons Inc., Hoboken, New Jersy, 2008,                     --
--      ISBN: 978-0470185315                                                  --
--                                                                            --
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

package iuart is

   component uartr is
      port(
         si            : in  slave_in_t;
         so            : out slave_out_t;
      -- Non-Wishbone Signals
         RS232_DCE_RXD : in  std_logic
      );
   end component;

   component uartt is
      port(
         si            : in  slave_in_t;
         so            : out slave_out_t;
      -- Non-Wishbone Signals
         RS232_DCE_TXD : out std_logic
      );
   end component;

   component counter is
      generic(
         FREQ : positive := 50;           -- Clock frequency in MHz.
         RATE : positive := 19200         -- Baud rate.
      );
      port(
         clk    : in  std_logic;
         rst    : in  std_logic;
         tick   : out std_logic
      );
   end component;
end iuart;