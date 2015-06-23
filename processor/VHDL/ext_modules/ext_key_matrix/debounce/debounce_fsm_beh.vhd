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
use ieee.numeric_std.all;

architecture beh of debounce_fsm is
  constant CLK_PERIOD : time := 1E9 / CLK_FREQ * 1 ns;
  constant CNT_MAX : integer := TIMEOUT / CLK_PERIOD;
  type DEBOUNCE_FSM_STATE_TYPE is
    (REINIT0, REINIT1, IDLE0, TIMEOUT0, IDLE1, TIMEOUT1);
  signal debounce_fsm_state, debounce_fsm_state_next : DEBOUNCE_FSM_STATE_TYPE;
  signal cnt, cnt_next : integer range 0 to CNT_MAX;
begin
  next_state : process(debounce_fsm_state, i, reinit, reinit_value, cnt)
  begin
    debounce_fsm_state_next <= debounce_fsm_state;
    case debounce_fsm_state is
      when REINIT0 =>
        debounce_fsm_state_next <= TIMEOUT0;
      when REINIT1 =>
        debounce_fsm_state_next <= TIMEOUT1;
      when IDLE0 =>
        if reinit = '1' and reinit_value = '0' then
          debounce_fsm_state_next <= REINIT0;
        elsif reinit = '1' and reinit_value = '1' then
          debounce_fsm_state_next <= REINIT1;
        elsif i = '1' then
          debounce_fsm_state_next <= TIMEOUT0;
        end if;
      when TIMEOUT0 =>
        if reinit = '1' and reinit_value = '0' then
          debounce_fsm_state_next <= REINIT0;
        elsif reinit = '1' and reinit_value = '1' then
          debounce_fsm_state_next <= REINIT1;
        elsif i = '0' then
          debounce_fsm_state_next <= IDLE0;
        elsif cnt = CNT_MAX - 1 then
          debounce_fsm_state_next <= IDLE1;
        end if;
      when IDLE1 =>
        if reinit = '1' and reinit_value = '0' then
          debounce_fsm_state_next <= REINIT0;
        elsif reinit = '1' and reinit_value = '1' then
          debounce_fsm_state_next <= REINIT1;
        elsif i = '0' then
          debounce_fsm_state_next <= TIMEOUT1;
        end if;
      when TIMEOUT1 =>
        if reinit = '1' and reinit_value = '0' then
          debounce_fsm_state_next <= REINIT0;
        elsif reinit = '1' and reinit_value = '1' then
          debounce_fsm_state_next <= REINIT1;
        elsif i = '1' then
          debounce_fsm_state_next <= IDLE1;
        elsif cnt = CNT_MAX - 1 then
          debounce_fsm_state_next <= IDLE0;
        end if;
    end case;
  end process next_state;

  output : process(debounce_fsm_state, cnt)
  begin
    o <= RESET_VALUE;
    cnt_next <= 0;

    case debounce_fsm_state is
      when REINIT0 =>
        o <= '0';
      when REINIT1 =>
        o <= '1';
      when IDLE0 =>
        o <= '0';
      when TIMEOUT0 =>
        o <= '0';
        cnt_next <= cnt + 1;
      when IDLE1 =>
        o <= '1';
      when TIMEOUT1 =>
        o <= '1';
        cnt_next <= cnt + 1;
    end case;
  end process output;

  assert RESET_VALUE = '0' or RESET_VALUE = '1' report
    "RESET_VALUE may only be 0 or 1!" severity failure;

  sync : process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      if RESET_VALUE = '0' then
        debounce_fsm_state <= IDLE0;
      else
        debounce_fsm_state <= IDLE1;
      end if;
      cnt <= 0;
    elsif rising_edge(sys_clk) then
      debounce_fsm_state <= debounce_fsm_state_next;
      cnt <= cnt_next;
    end if;
  end process sync;
end architecture beh;
