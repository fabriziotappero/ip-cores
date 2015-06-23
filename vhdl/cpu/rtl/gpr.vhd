--------------------------------------------------------------------------------
-- MIPS™ I CPU - General Purpose Register                                     --
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

entity gpr is
   port(
      clk_i : in  std_logic;
      hld_i : in  std_logic;
      rs_a  : in  std_logic_vector(4 downto 0);
      rt_a  : in  std_logic_vector(4 downto 0);
      rd_a  : in  std_logic_vector(4 downto 0);
      rd_we : in  std_logic;
      rd_i  : in  std_logic_vector(31 downto 0);
      rs_o  : out std_logic_vector(31 downto 0);
      rt_o  : out std_logic_vector(31 downto 0)
   );
end gpr;

architecture rtl of gpr is

   type gpr_t is array (0 to 31) of std_logic_vector(31 downto 0);
   signal gpr : gpr_t := (others => (others => '0'));

   attribute RAM_STYLE : string;
   attribute RAM_STYLE of gpr: signal is "BLOCK";
begin

   reg : process(clk_i)
   begin
      if rising_edge(clk_i) then
         if (hld_i = '0') then

            -- Save data only if it's register address is not zero.
            -- Keeps register $0 zero.
            if (rd_we = '1') and (rd_a /= "00000") then
               gpr( to_integer(unsigned(rd_a)) ) <= rd_i;
            end if;
            rs_o <= gpr( to_integer(unsigned(rs_a)) );
            rt_o <= gpr( to_integer(unsigned(rt_a)) );
         end if;
      end if;
   end process;
end rtl;