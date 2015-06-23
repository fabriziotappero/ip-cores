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
use work.debounce_pkg.all;

architecture beh of key_matrix is
  constant CLK_PERIOD : time := 1E9 / CLK_FREQ * 1 ns;
  constant CNT_MAX : integer := SCAN_TIME_INTERVAL / CLK_PERIOD;

  signal rows_debounced : std_logic_vector(ROW_COUNT - 1 downto 0);
  type debounce_signal_array is array(0 to COLUMN_COUNT - 1, ROW_COUNT - 1 downto 0) of std_logic;
  signal rows_debounced_old, rows_debounced_old_next : debounce_signal_array;
  signal debouncer_reinit : std_logic;
  signal debouncer_reinit_value : std_logic_vector(ROW_COUNT - 1 downto 0);
  type KEY_MATRIX_STATE_TYPE is (STATE_FIRST_COLUMN, STATE_NEXT_COLUMN, STATE_REINIT_DEBOUNCER, STATE_EXECUTE);
  signal key_matrix_state, key_matrix_state_next : KEY_MATRIX_STATE_TYPE;
  signal interval, interval_next : integer range 0 to CNT_MAX;
  signal current_column, current_column_next : integer range 0 to COLUMN_COUNT - 1;
  signal key_next : std_logic_vector(log2c(ROW_COUNT * COLUMN_COUNT) - 1 downto 0);
  signal decode_data : std_logic;
begin
  process(current_column)
  begin
    columns <= (others => '0');
    columns(current_column) <= '1';
  end process;

  debouncer_gen : for i in 0 to ROW_COUNT - 1 generate
    debouncer_inst : debounce
      generic map
      (
        CLK_FREQ => CLK_FREQ,
        SYNC_STAGES => SYNC_STAGES,
        TIMEOUT => DEBOUNCE_TIMEOUT
      )
      port map
      (
        sys_clk => sys_clk,
        sys_res_n => sys_res_n,
        data_in => rows(i),
        data_out => rows_debounced(i),
        reinit => debouncer_reinit,
        reinit_value => debouncer_reinit_value(i)
      );
  end generate debouncer_gen;

  process(key_matrix_state, interval, current_column)
  begin
    key_matrix_state_next <= key_matrix_state;

    case key_matrix_state is
      when STATE_FIRST_COLUMN =>
        key_matrix_state_next <= STATE_REINIT_DEBOUNCER;
      when STATE_NEXT_COLUMN =>
        key_matrix_state_next <= STATE_REINIT_DEBOUNCER;
      when STATE_REINIT_DEBOUNCER =>
        key_matrix_state_next <= STATE_EXECUTE;
      when STATE_EXECUTE =>
        if interval = CNT_MAX - 1 then
          if current_column = COLUMN_COUNT - 1 then
            key_matrix_state_next <= STATE_FIRST_COLUMN;
          else
            key_matrix_state_next <= STATE_NEXT_COLUMN;
          end if;
        end if;
    end case;
  end process;
  
  process(key_matrix_state, interval, current_column, rows_debounced, rows_debounced_old)
  begin
    current_column_next <= current_column;
    debouncer_reinit <= '0';
    debouncer_reinit_value <= (others => '0');
    rows_debounced_old_next <= rows_debounced_old;
    interval_next <= 0;
    decode_data <= '0';

    case key_matrix_state is
      when STATE_FIRST_COLUMN =>
        current_column_next <= 0;
      when STATE_NEXT_COLUMN =>
        current_column_next <= current_column + 1;
      when STATE_REINIT_DEBOUNCER =>
        debouncer_reinit <= '1';
        for i in 0 to ROW_COUNT - 1 loop
          debouncer_reinit_value(i) <= rows_debounced_old(current_column, i);
        end loop;
      when STATE_EXECUTE =>
        interval_next <= interval + 1;
        for i in 0 to ROW_COUNT - 1 loop
          rows_debounced_old_next(current_column, i) <= rows_debounced(i);
        end loop;
        decode_data <= '1';
    end case;
  end process;

  process(sys_clk, sys_res_n)
  begin
    if sys_res_n = '0' then
      current_column <= 0;
      rows_debounced_old <= (others => (others => '0'));
      interval <= 0;
      key_matrix_state <= STATE_FIRST_COLUMN;
      key <= (others => '0');
    elsif rising_edge(sys_clk) then
      current_column <= current_column_next;
      interval <= interval_next;
      rows_debounced_old <= rows_debounced_old_next;
      key_matrix_state <= key_matrix_state_next;
      key <= key_next;
    end if;
  end process;
  
  process(decode_data, rows_debounced, rows_debounced_old, current_column)
    variable key_int : integer range 0 to ROW_COUNT * COLUMN_COUNT;
    variable found, valid : boolean;
  begin
    key_next <= (others => '0');

    if decode_data = '1' then
      key_int := 0;
      found := false;
      valid := true;
      for i in 0 to ROW_COUNT - 1 loop
        if rows_debounced(i) = '1' then
          if found = true then -- Only one key may be pressed at once
            valid := false;
          end if;
          if rows_debounced_old(current_column, i) = '1' then -- Only valid the first time the key is pressed
            valid := false;
          end if;
          found := true;
        end if;
        -- Calculate the key number (i * COLUMN_COUNT)
        -- = Addition of column count until the key is found
        if not found then
          key_int := key_int + COLUMN_COUNT;
        end if;
      end loop;
      if valid and found then
        -- If a valid key was found, correct the key number to the correct column
        key_int := key_int + current_column + 1;
      else
        key_int := 0;
      end if;
      key_next <= std_logic_vector(to_unsigned(key_int, log2c(ROW_COUNT * COLUMN_COUNT)));
    end if;
  end process;
end architecture beh;
