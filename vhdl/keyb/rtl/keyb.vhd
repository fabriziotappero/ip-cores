--------------------------------------------------------------------------------
-- PS2 Keyboard Controller                                                    --
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
-- http://www.computer-engineering.org/ps2keyboard/
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.iwb.all;

entity keyb is
   port(
      si        : in  slave_in_t;
      so        : out slave_out_t;
   -- Non-Wishbone Signals
      PS2_CLK   : in  std_logic;
      PS2_DATA  : in  std_logic;
      intr      : out std_logic
   );
end keyb;

architecture rtl of keyb is

   constant EXTENDED_CODE : std_logic_vector(7 downto 0) := x"E0";
   constant BREAK_CODE    : std_logic_vector(7 downto 0) := x"F0";
   constant CAPS          : std_logic_vector(7 downto 0) := x"58";
   constant LEFT_SHIFT    : std_logic_vector(7 downto 0) := x"12";
   constant RIGHT_SHIFT   : std_logic_vector(7 downto 0) := x"59";
   constant LEFT_CTRL     : std_logic_vector(7 downto 0) := x"14";
   constant LEFT_ALT      : std_logic_vector(7 downto 0) := x"11";
   constant RIGHT_CTRL    : std_logic_vector(7 downto 0) := x"14";
   constant RIGHT_ALT     : std_logic_vector(7 downto 0) := x"11";

   component ps2 is
      port(
         clk      : in  std_logic;
         rst      : in  std_logic;
         PS2_CLK  : in  std_logic;
         PS2_DATA : in  std_logic;
         char     : out std_logic_vector(7 downto 0);
         rx_done  : out std_logic
      );
   end component;

   component ascii is
      port(
         clk   : in  std_logic;
         shft  : in  std_logic;
         altgr : in std_logic;
         code  : in  std_logic_vector(7 downto 0);
         char  : out std_logic_vector(7 downto 0)
      );
   end component;

   attribute RAM_STYLE : string;
   attribute RAM_STYLE of ascii : component is "BLOCK";

   type state_t is (Idle, ExtCode, BrkCode, ExtRelease, Translate, Check,
                    Ack, Ack2);

   type char_t is record
      shft  : std_logic;                           -- Shift key.
      cps   : std_logic;                           -- Caps key.
      ctrl  : std_logic;                           -- Control key.
      alt   : std_logic;                           -- Alt key.
      altgr : std_logic;                           -- Alt Gr key.
      m     : std_logic_vector(7 downto 0);        -- Scan code.
   end record;

   signal k, kin   : state_t := Idle;              -- Keyboard controller state.
   signal c, cin   : char_t;                       -- Character structure.
   signal code     : std_logic_vector(7 downto 0); -- PS2 scan code.
   signal char     : std_logic_vector(7 downto 0); -- ASCII character.
   signal shftcps  : std_logic;                    -- SHIFT xor CAPS.
   signal rx_done  : std_logic;                    -- PS2 receive done tick.
   signal key_done : std_logic;                    -- Keyboard ctrl done tick.
begin

   -----------------------------------------------------------------------------
   -- PS2 Controller                                                          --
   -----------------------------------------------------------------------------
   ps2_ctrl : ps2 port map(
      clk      => si.clk,
      rst      => si.rst,
      PS2_CLK  => PS2_CLK,
      PS2_DATA => PS2_DATA,
      char     => code,
      rx_done  => rx_done
   );

   -----------------------------------------------------------------------------
   -- ScanCode To ASCII ROM                                                   --
   -----------------------------------------------------------------------------
   shftcps <= c.shft xor c.cps;     -- If both are set, turn to lower case.

   ascii_rom : ascii port map(
      clk   => si.clk,
      shft  => shftcps,
      altgr => c.altgr,
      code  => c.m,
      char  => char
   );

   -----------------------------------------------------------------------------
   -- Keyboard Control                                                        --
   -----------------------------------------------------------------------------
   key : process(k, c, rx_done, code, si.stb, si.we, si, char)
   begin

      kin <= k;
      cin <= c;

      intr   <= '0';
      so.ack <= '0';
      --key_done <= '0';  
      
      case k is

         -- Wait for some key input.
         when Idle =>
            if rx_done = '1' then
               case code is

                  when EXTENDED_CODE =>
                     kin   <= ExtCode;

                  when BREAK_CODE =>
                     kin   <= BrkCode;

                  -- User pressed a functional key. Just latch and then return
                  -- to Idle state. The CPU does not need to be bothered.
                  when LEFT_SHIFT | RIGHT_SHIFT =>
                     cin.shft <= '1';
                     kin      <= Idle;
                  when CAPS =>
                     cin.cps  <= not c.cps;
                     kin      <= Idle;
                  when LEFT_CTRL =>
                     cin.ctrl <= '1';
                     kin      <= Idle;
                  when LEFT_ALT =>
                     cin.alt  <= '1';
                     kin      <= Idle;

                  -- The actual key code.
                  when others =>
                     cin.m <= code;
                     kin   <= Translate;
               end case;
            end if;

         -- PREVIOUS STATE: Idle.
         when ExtCode =>
            if rx_done = '1' then
               case code is

                  -- If we receive a BREAK CODE we know that the following
                  -- pressed key (represented by the next byte) has been
                  -- released.
                  when BREAK_CODE =>
                     kin   <= ExtRelease;

                  -- The RIGHT CTRL and RIGHT ALT (ALT GR) are the same key
                  -- codes as LEFT CTRL and LEFT ALT plus an preceeding EXTENDED
                  -- CODE. RIGHT ALT (ALT GR) has a different functional
                  -- meaning.
                  when RIGHT_CTRL =>
                     cin.ctrl  <= '1';
                     kin       <= Idle;
                  when RIGHT_ALT =>
                     cin.altgr <= '1';
                     kin       <= Idle;

                  -- Once more the actual key code.
                  when others =>
                     cin.m <= code;
                     kin   <= Translate;
               end case;
            end if;

         -- PREVIOUS STATE: Idle.
         when BrkCode =>
            if rx_done = '1' then
               case code is

                  -- A functional key has been released.
                  when LEFT_SHIFT | RIGHT_SHIFT =>
                     cin.shft <= '0';
                     kin      <= Idle;
                  when LEFT_CTRL =>
                     cin.ctrl <= '0';
                     kin      <= Idle;
                  when LEFT_ALT =>
                     cin.alt  <= '0';
                     kin      <= Idle;

                  -- Do nothing when CAPS is released.
                  when CAPS =>
                     kin <= Idle;

                  -- Do nothing on key release.
                  when others =>
                     kin <= Idle;
               end case;
            end if;

         -- PREVIOUS STATE: ExtCode.
         -- Either turn off the RIGHT CTRL or RIGHT ALT flags, or receive a non
         -- functional key code release.
         when ExtRelease =>
            if rx_done = '1' then
               case code is

                  -- The RIGHT CTRL and RIGHT ALT (ALT GR) are the same key
                  -- codes as LEFT CTRL and LEFT ALT plus an preceeding EXTENDED
                  -- CODE. RIGHT ALT (ALT GR) has a different functional
                  -- meaning.
                  when RIGHT_CTRL =>
                     cin.ctrl <= '0';
                     kin      <= Idle;
                  when RIGHT_ALT =>
                     cin.altgr <= '0';
                     kin       <= Idle;

                  -- Do nothing on key release.
                  when others =>
                     kin   <= Idle;
               end case;
            end if;

         -- PREVIOUS STATES: Idle, ExtCode.
         -- One cycle delay for the ASCII-ROM to translate the keyboard code.
         when Translate =>
            kin <= Check;

         -- Ignore all undefined keys.
         when Check =>
            if char = x"00" then
               kin <= Idle;
            else
               kin <= Ack;
            end if;

         -- Wait for a Wishbone read, set interrrupt meanwhile.
         when Ack =>
            intr <= '1';
            if wb_read(si) then
               so.ack <= '1';
               --key_done <= '1';
               kin      <= Ack2;
            end if;

         -- Wait and hold done signal until master notices ack signal and pulls
         -- stb down.
         when Ack2 =>
            intr   <= '1';
            so.ack <= '1';
            --key_done <= '1';
            if si.stb = '0' then
               kin <= Idle;
            end if;

      end case;
   end process;

   so.dat <= x"0000" & c.shft & c.ctrl & c.alt & c.altgr & x"0" & char;
   --so.ack <= key_done;

   -----------------------------------------------------------------------------
   -- Registers                                                               --
   -----------------------------------------------------------------------------
     reg : process(si.clk)
   begin
      if rising_edge(si.clk) then
         k <= kin;
         c <= cin;
         if si.rst = '1' then
            k <= Idle;
            c <= ('0','0','0','0','0',(others => '-'));
         end if;
      end if;
   end process;
end rtl;
