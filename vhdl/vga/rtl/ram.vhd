--------------------------------------------------------------------------------
-- 8-Color 100x37 Textmode Video Controller                                   --
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

entity ram is
   port(
      clk  : in  std_logic;
      adrs : in  std_logic_vector(11 downto 0);
      adru : in  std_logic_vector(11 downto 0);
      we   : in  std_logic;
      stb  : in  std_logic;
      din  : in  std_logic_vector(15 downto 0);
      chr  : out std_logic_vector(7 downto 0);
      fgc  : out std_logic_vector(2 downto 0);
      bgc  : out std_logic_vector(2 downto 0);
      datu : out std_logic_vector(15 downto 0);
      ack  : out std_logic
   );
end ram;

architecture rtl of ram is

   -- Two bits are obsolete, since character color is 6 bit information only.
   -- However, this will not reduce the number of block rams, so we stick to
   -- 8 bit color. The remaining 396 halfwords, can be used for something else.
   type mem_t is array (0 to 4095) of std_logic_vector(15 downto 0);

   signal mem : mem_t := ( others => (others => '0') );

   attribute RAM_STYLE : string;
   attribute RAM_STYLE of mem: signal is "BLOCK";

   signal dat  : std_logic_vector(15 downto 0);
   signal acki : std_logic;
begin

   reg : process(clk)
   begin
      if rising_edge(clk) then
         acki <= '0';
         if (stb = '1') and (we = '1') then
            mem( to_integer(unsigned(adru)) ) <= din;
            acki <= '1';
         elsif (stb = '1') and (we = '0') then
            acki <= '1';
         end if;
         dat  <= mem( to_integer(unsigned(adrs)) );
         datu <= mem( to_integer(unsigned(adru)) );
      end if;
   end process;

   fgc <= dat(14 downto 12);
   bgc <= dat(10 downto 8);
   chr <= dat(7 downto 0);
   ack <= acki;
end rtl;