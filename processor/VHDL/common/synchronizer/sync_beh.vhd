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

architecture beh of sync is
  signal sync : std_logic_vector(1 to SYNC_STAGES);
begin
  process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      sync <= (others => RESET_VALUE);
    elsif rising_edge(sys_clk) then
      sync(1) <= data_in;
      for i in 2 to SYNC_STAGES loop
        sync(i) <= sync(i - 1);
      end loop;
    end if;
  end process;
  data_out <= sync(SYNC_STAGES);
end architecture beh;
