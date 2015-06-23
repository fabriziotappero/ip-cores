--------------------------------------------------------------------------------
-- PS2 Keyboard Controller - German Keyboard Layout                           --
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

entity ascii is
   port(
      clk   : in  std_logic;
      shft  : in  std_logic;
      altgr : in  std_logic;
      code  : in  std_logic_vector(7 downto 0);
      char  : out std_logic_vector(7 downto 0)
   );
end ascii;

architecture rtl of ascii is
begin
   conv : process(clk)
   begin
      if rising_edge(clk) then
         case code is
            --------------------------------------------------------------------
            -- Keys that are independend of the state of SHFT and ALTGR.      --
            --------------------------------------------------------------------
            when X"66" => char <= X"08"; -- BS  (BACKSPACE)
            when X"0d" => char <= X"09"; -- HT  (TAB)
            when X"5a" => char <= X"0d"; -- CR  (ENTER)
            when X"76" => char <= X"1b"; -- ESC (ESCAPE)
            when X"29" => char <= X"20"; -- SP  (SPACE)
            when X"71" => char <= X"7f"; -- DEL (DELETE)
            when X"7e" => char <= X"80"; -- SCROLL
            when X"75" => char <= X"f0"; -- UP ARROW
            when X"6b" => char <= X"f1"; -- LEFT ARROW
            when X"72" => char <= X"f2"; -- DOWN ARROW
            when X"74" => char <= X"f3"; -- RIGHT ARROW
            --when X"" => char <= X""

            when others =>
               case (altgr & shft & code) is
                  --------------------------------------------------------------
                  -- SHFT and ALTGR not pressed.                              --
                  --------------------------------------------------------------
                  when "00" & X"0e" => char <= X"5e"; -- ^
                  when "00" & X"15" => char <= X"71"; -- q
                  when "00" & X"16" => char <= X"31"; -- 1
                  when "00" & X"1a" => char <= X"79"; -- y
                  when "00" & X"1b" => char <= X"73"; -- s
                  when "00" & X"1c" => char <= X"61"; -- a
                  when "00" & X"1d" => char <= X"77"; -- w
                  when "00" & X"1e" => char <= X"32"; -- 2
                  when "00" & X"21" => char <= X"63"; -- c
                  when "00" & X"22" => char <= X"78"; -- x
                  when "00" & X"23" => char <= X"64"; -- d
                  when "00" & X"24" => char <= X"65"; -- e
                  when "00" & X"25" => char <= X"34"; -- 4
                  when "00" & X"26" => char <= X"33"; -- 3
                  when "00" & X"2a" => char <= X"76"; -- v
                  when "00" & X"2b" => char <= X"66"; -- f
                  when "00" & X"2c" => char <= X"74"; -- t
                  when "00" & X"2d" => char <= X"72"; -- r
                  when "00" & X"2e" => char <= X"35"; -- 5
                  when "00" & X"31" => char <= X"6e"; -- n
                  when "00" & X"32" => char <= X"62"; -- b
                  when "00" & X"33" => char <= X"68"; -- h
                  when "00" & X"34" => char <= X"67"; -- g
                  when "00" & X"35" => char <= X"7a"; -- z
                  when "00" & X"36" => char <= X"36"; -- 6
                  when "00" & X"3a" => char <= X"6d"; -- m
                  when "00" & X"3b" => char <= X"6a"; -- j
                  when "00" & X"3c" => char <= X"75"; -- u
                  when "00" & X"3d" => char <= X"37"; -- 7
                  when "00" & X"3e" => char <= X"38"; -- 8
                  when "00" & X"41" => char <= X"2c"; -- ,
                  when "00" & X"42" => char <= X"6b"; -- k
                  when "00" & X"43" => char <= X"69"; -- i
                  when "00" & X"44" => char <= X"6f"; -- o
                  when "00" & X"45" => char <= X"30"; -- 0
                  when "00" & X"46" => char <= X"39"; -- 9
                  when "00" & X"49" => char <= X"2e"; -- .
                  when "00" & X"4a" => char <= X"2d"; -- -
                  when "00" & X"4b" => char <= X"6c"; -- l
                  when "00" & X"4d" => char <= X"70"; -- p
                  when "00" & X"5b" => char <= X"2b"; -- +
                  when "00" & X"5d" => char <= X"23"; -- #
                  when "00" & X"61" => char <= X"3c"; -- <
                  --------------------------------------------------------------
                  -- SHFT pressed.                                            --
                  --------------------------------------------------------------
                  when "01" & X"15" => char <= X"51"; -- Q
                  when "01" & X"16" => char <= X"21"; -- !
                  when "01" & X"1a" => char <= X"59"; -- Y
                  when "01" & X"1b" => char <= X"53"; -- S
                  when "01" & X"1c" => char <= X"41"; -- A
                  when "01" & X"1d" => char <= X"57"; -- W
                  when "01" & X"1e" => char <= X"22"; -- "
                  when "01" & X"21" => char <= X"43"; -- C
                  when "01" & X"22" => char <= X"58"; -- X
                  when "01" & X"23" => char <= X"44"; -- D
                  when "01" & X"24" => char <= X"45"; -- E
                  when "01" & X"25" => char <= X"24"; -- $
                  when "01" & X"2a" => char <= X"56"; -- V
                  when "01" & X"2b" => char <= X"46"; -- F
                  when "01" & X"2c" => char <= X"54"; -- T
                  when "01" & X"2d" => char <= X"52"; -- R
                  when "01" & X"2e" => char <= X"25"; -- %
                  when "01" & X"31" => char <= X"4e"; -- N
                  when "01" & X"32" => char <= X"42"; -- B
                  when "01" & X"33" => char <= X"48"; -- H
                  when "01" & X"34" => char <= X"47"; -- G
                  when "01" & X"35" => char <= X"5a"; -- Z
                  when "01" & X"36" => char <= X"26"; -- &
                  when "01" & X"3a" => char <= X"4d"; -- M
                  when "01" & X"3b" => char <= X"4a"; -- J
                  when "01" & X"3c" => char <= X"55"; -- U
                  when "01" & X"3d" => char <= X"2f"; -- /
                  when "01" & X"3e" => char <= X"28"; -- (
                  when "01" & X"41" => char <= X"3b"; -- ;
                  when "01" & X"42" => char <= X"4b"; -- K
                  when "01" & X"43" => char <= X"49"; -- I
                  when "01" & X"44" => char <= X"4f"; -- O
                  when "01" & X"45" => char <= X"3d"; -- =
                  when "01" & X"46" => char <= X"29"; -- )
                  when "01" & X"49" => char <= X"3a"; -- :
                  when "01" & X"4a" => char <= X"5f"; -- _
                  when "01" & X"4b" => char <= X"4c"; -- L
                  when "01" & X"4d" => char <= X"50"; -- P
                  when "01" & X"4e" => char <= X"3f"; -- ?
                  when "01" & X"55" => char <= X"60"; -- `
                  when "01" & X"5b" => char <= X"2a"; -- *
                  when "01" & X"5d" => char <= X"27"; -- '
                  when "01" & X"61" => char <= X"3e"; -- >
                  --------------------------------------------------------------
                  -- ALTGR pressed.                                           --
                  --------------------------------------------------------------
                  when "10" & X"15" => char <= X"40"; -- @
                  when "10" & X"3d" => char <= X"7b"; -- {
                  when "10" & X"3e" => char <= X"5b"; -- [
                  when "10" & X"45" => char <= X"7d"; -- }
                  when "10" & X"46" => char <= X"5d"; -- ]
                  when "10" & X"4e" => char <= X"5c"; -- \
                  when "10" & X"5b" => char <= X"7e"; -- ~
                  when "10" & X"61" => char <= X"7c"; -- |
                  --------------------------------------------------------------
                  -- SHFT and ALTGR pressed.                                  --
                  --------------------------------------------------------------
                  --------------------------------------------------------------
                  -- Everything else returns the empty key X"00".             --
                  --------------------------------------------------------------
                  when others => char <= X"00";
               end case;
         end case;
      end if;
   end process;
end rtl;