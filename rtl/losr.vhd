-- Hi Emacs, this is -*- mode: vhdl -*-
----------------------------------------------------------------------------------------------------
--
-- Registro de desplazamiento a la izquierda, entrada paralelo, salida serie
--
-- Copyright (c) 2007 Javier Valcarce García, javier.valcarce@gmail.com
-- $Id: losr.vhd,v 1.1 2008-12-01 02:00:10 hharte Exp $
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity losr is
  generic (
    N : integer := 4);
  port (
    reset : in  std_logic;
    clk   : in  std_logic;
    load  : in  std_logic;
    ce    : in  std_logic;
    do    : out std_logic;
    di    : in  std_logic_vector(N-1 downto 0));
end losr;


architecture arch of losr is
begin

  process(reset, clk)
    variable data : std_logic_vector(N-1 downto 0);
  begin
    if reset = '1' then
      data := (others => '0');
    elsif rising_edge(clk) then
      if load = '1' then
        data := di;
      elsif ce = '1' then
        data := data(N-2 downto 0) & "0";
      end if;
    end if;

    do <= data(N-1);
  end process;

end arch;
