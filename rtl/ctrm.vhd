-- Hi Emacs, this is -*- mode: vhdl; -*-
----------------------------------------------------------------------------------------------------
--
-- Up Syncronous counter of N bits with a/syncronous reset
--
-- Copyright (c) 2007 Javier Valcarce García, javier.valcarce@gmail.com
-- $Id: ctrm.vhd,v 1.1 2008-12-01 02:00:10 hharte Exp $
--
----------------------------------------------------------------------------------------------------
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ctrm is
  generic (
    M : integer := 08);
  port (
    reset : in  std_logic;              -- asyncronous reset
    clk   : in  std_logic;
    ce    : in  std_logic;              -- enable counting
    rs    : in  std_logic;              -- syncronous reset
    do    : out integer range (M-1) downto 0
    );
end ctrm;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture arch of ctrm is
  signal c : integer range (M-1) downto 0;
begin

  do <= c;

  process(reset, clk)
  begin
    if reset = '1' then
      c <= 0;
      
    elsif rising_edge(clk) then
      if ce = '1' then
        if rs = '1' then
          c <= 0;
        else
          c <= c + 1;
        end if;
      end if;
    end if;
  end process;

end arch;
