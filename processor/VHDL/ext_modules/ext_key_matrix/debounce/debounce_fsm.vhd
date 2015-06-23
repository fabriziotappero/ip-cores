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

entity debounce_fsm is
  generic
  (
    CLK_FREQ    : integer;
    TIMEOUT     : time range 100 us to 100 ms := 1 ms;
    RESET_VALUE : std_logic
  );
  port
  (
    sys_clk : in std_logic;
    sys_res_n : in std_logic;
    i : in std_logic;
    o : out std_logic;
    reinit  : in std_logic;
    reinit_value  : in std_logic
  );
end entity debounce_fsm;
