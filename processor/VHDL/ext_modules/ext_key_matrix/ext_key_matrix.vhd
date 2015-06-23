-----------------------------------------------------------------------
-- This file is part of SCARTS.
-- 
-- SCARTS is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- SCARTS is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with SCARTS.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use work.scarts_pkg.all;
use work.ext_key_matrix_pkg.all;



entity ext_key_matrix is
  generic
  (
    CLK_FREQ  : integer range 1 to integer'high;
    COLUMN_COUNT       : integer range 1 to integer'high;
    ROW_COUNT          : integer range 1 to integer'high
  );  
  port
  (
    clk       : in std_logic;
    extsel    : in std_ulogic;
    exti      : in  module_in_type;
    exto      : out module_out_type;
    columns   : out std_logic_vector(COLUMN_COUNT - 1 downto 0);
    rows      : in  std_logic_vector(ROW_COUNT - 1 downto 0)
  );
end ext_key_matrix;




