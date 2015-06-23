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


library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;

package key_matrix_pkg is
  component key_matrix is
    generic
    (
      CLK_FREQ           : integer range 1 to integer'high;
      SCAN_TIME_INTERVAL : time range 1 ms to 100 ms;
      DEBOUNCE_TIMEOUT   : time range 100 us to 1 ms;
      SYNC_STAGES        : integer range 2 to integer'high;
      COLUMN_COUNT       : integer range 1 to integer'high;
      ROW_COUNT          : integer range 1 to integer'high
    );
    port
    (
      sys_clk   : in  std_logic;
      sys_res_n : in  std_logic;
      columns   : out std_logic_vector(COLUMN_COUNT - 1 downto 0);
      rows      : in  std_logic_vector(ROW_COUNT - 1 downto 0);
      key       : out std_logic_vector(log2c(ROW_COUNT * COLUMN_COUNT) - 1 downto 0)
    );
  end component key_matrix;
end package key_matrix_pkg;
