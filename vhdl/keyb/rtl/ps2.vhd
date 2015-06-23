--------------------------------------------------------------------------------
-- PS2 Controller                                                             --
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

entity ps2 is
   port(
      clk      : in  std_logic;
      rst      : in  std_logic;
      PS2_CLK  : in  std_logic;
      PS2_DATA : in  std_logic;
      char     : out std_logic_vector(7 downto 0);
      rx_done  : out std_logic
   );
end ps2;

architecture rtl of ps2 is

   type ps2_state_t is (Start, Data, Parity, Stop, Ack);

   signal p, pin    : ps2_state_t := Start;
   signal s, sin    : std_logic_vector(7 downto 0);
   signal n, nin    : natural range 0 to 7;
   signal f, fin    : std_logic_vector(7 downto 0);
   signal t, tin    : std_logic;
   signal fall_edge : std_logic;
begin

   -----------------------------------------------------------------------------
   -- Input Signal Debounce                                                   --
   -----------------------------------------------------------------------------
   -- the frequency of the PS2 clock signal is about 20 to 30 KHz. To avoid   --
   -- undesired glitches, wait 8 cycles for a stable signal.                  --
   -----------------------------------------------------------------------------
   fin <= PS2_CLK & f(7 downto 1);

   tin <= '1' when f = x"FF" else
          '0' when f = x"00" else
          t;

     filter : process(clk)
   begin
      if rising_edge(clk) then
         f <= fin;
         t <= tin;
      end if;
   end process;

   fall_edge <= t and (not tin);

   -----------------------------------------------------------------------------
   -- PS2 Read                                                               --
   -----------------------------------------------------------------------------
   fsm : process(p, s, n, fall_edge, PS2_DATA)
   begin

      rx_done <= '0';

      pin <= p;
      sin <= s;
      nin <= n;

      case p is

         -- Wait for first falling edge. The first bit is a start bit with
         -- value '0'. We do not check that.
         when Start =>
            if fall_edge = '1' then
               nin <= 0;
               pin <= Data;
            end if;

         -- On the next 8 falling edges we shuffle data into the shift register.
         -- The keyboard sends the LSB first.
         when Data =>
            if fall_edge = '1' then
               sin <= PS2_DATA & s(7 downto 1);
               if n = 7 then
                  pin <= Parity;
               else
                  nin <= n + 1;
               end if;
            end if;

         -- Fetch odd parity bit. No parity check here.
         when Parity =>
            if fall_edge = '1' then
               sin <= PS2_DATA & s(7 downto 1);    -- A mystery.
               pin <= Stop;
            end if;

         -- Fetch stop bit. Always '1'.
         when Stop =>
            if fall_edge = '1' then
               pin <= Ack;
            end if;

         -- One cycle tick to indicate a complete reception.
         when Ack =>
            rx_done <= '1';
            pin     <= Start;

      end case;
   end process;

     reg : process(clk)
   begin
      if rising_edge(clk) then
         p <= pin;
         s <= sin;
         n <= nin;
         f <= fin;

         if rst = '1' then p <= Start; end if;
      end if;
   end process;

   char <= s;
end rtl;
