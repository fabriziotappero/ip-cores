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
use work.sync_pkg.all;
use work.debounce_pkg.all;
use work.math_pkg.all;

architecture struct of debounce is
  signal data_sync : std_logic;
begin
  sync_inst : sync
    generic map
    (
      SYNC_STAGES => SYNC_STAGES,
      RESET_VALUE => RESET_VALUE
    )
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      data_in => data_in,
      data_out => data_sync
    );

  fsm_inst : debounce_fsm
    generic map
    (
      CLK_FREQ => CLK_FREQ,
      TIMEOUT => TIMEOUT,
      RESET_VALUE => RESET_VALUE
    )
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      i => data_sync,
      o => data_out,
      reinit => reinit,
      reinit_value => reinit_value
    );
end architecture struct;
