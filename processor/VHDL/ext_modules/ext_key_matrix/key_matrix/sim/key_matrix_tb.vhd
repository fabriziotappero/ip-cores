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
use work.key_matrix_pkg.all;
use work.testbench_util_pkg.all;

entity key_matrix_tb is
end entity key_matrix_tb;

architecture sim of key_matrix_tb is
  constant CLK_FREQ : integer := 25000000;
  signal sys_clk, sys_res_n : std_logic;
  signal columns : std_logic_vector(2 downto 0);
  signal rows : std_logic_vector(3 downto 0);
  signal key : std_logic_vector(3 downto 0);
  signal stop : boolean := false;
begin
  uut : key_matrix
    generic map
    (
      CLK_FREQ => CLK_FREQ / 1000,
      SCAN_TIME_INTERVAL => 100 ms,
      DEBOUNCE_TIMEOUT => 1 ms,
      SYNC_STAGES => 2,
      COLUMN_COUNT => 3,
      ROW_COUNT => 4
    )
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      columns => columns,
      rows => rows,
      key => key
    );

  process
  begin
    sys_clk <= '0';
    wait for 1 sec/CLK_FREQ;
    sys_clk <= '1';
    if stop = true then
      wait;
    end if;
    wait for 1 sec/CLK_FREQ;
  end process;

  process
  begin
    sys_res_n <= '0';
    rows <= (others => '0');
    wait_cycle(sys_clk, 100);
    sys_res_n <= '1';
    wait_cycle(sys_clk, 10010);
    rows(0) <= '1';
    wait_cycle(sys_clk, 5);
    rows(0) <= '0';
    wait_cycle(sys_clk, 5);
    rows(0) <= '1';
    wait_cycle(sys_clk, 5);
    rows(0) <= '0';
    wait_cycle(sys_clk, 5);
    rows(0) <= '1';
    wait_cycle(sys_clk, 100);
    rows(0) <= '0';
    wait_cycle(sys_clk, 5);
    rows(0) <= '1';
    wait_cycle(sys_clk, 5);
    rows(0) <= '0';
    wait_cycle(sys_clk, 5);
    rows(0) <= '1';
    wait_cycle(sys_clk, 5);
    rows(0) <= '0';
  
    wait_cycle(sys_clk, 100);
    rows(1) <= '1';
    wait_cycle(sys_clk, 5);
    rows(1) <= '0';
    wait_cycle(sys_clk, 5);
    rows(1) <= '1';
    wait_cycle(sys_clk, 5);
    rows(1) <= '0';
    wait_cycle(sys_clk, 5);
    rows(1) <= '1';
    wait_cycle(sys_clk, 100);
    rows(1) <= '0';
    wait_cycle(sys_clk, 5);
    rows(1) <= '1';
    wait_cycle(sys_clk, 5);
    rows(1) <= '0';
    wait_cycle(sys_clk, 5);
    rows(1) <= '1';
    wait_cycle(sys_clk, 5);
    rows(1) <= '0';

    wait_cycle(sys_clk, 100);
    rows(2) <= '1';
    wait_cycle(sys_clk, 5);
    rows(2) <= '0';
    wait_cycle(sys_clk, 5);
    rows(2) <= '1';
    wait_cycle(sys_clk, 5);
    rows(2) <= '0';
    wait_cycle(sys_clk, 5);
    rows(2) <= '1';
    wait_cycle(sys_clk, 100);
    rows(2) <= '0';
    wait_cycle(sys_clk, 5);
    rows(2) <= '1';
    wait_cycle(sys_clk, 5);
    rows(2) <= '0';
    wait_cycle(sys_clk, 5);
    rows(2) <= '1';
    wait_cycle(sys_clk, 5);
    rows(2) <= '0';
    
    wait_cycle(sys_clk, 100);
    rows(3) <= '1';
    wait_cycle(sys_clk, 5);
    rows(3) <= '0';
    wait_cycle(sys_clk, 5);
    rows(3) <= '1';
    wait_cycle(sys_clk, 5);
    rows(3) <= '0';
    wait_cycle(sys_clk, 5);
    rows(3) <= '1';
    wait_cycle(sys_clk, 100);
    rows(3) <= '0';
    wait_cycle(sys_clk, 5);
    rows(3) <= '1';
    wait_cycle(sys_clk, 5);
    rows(3) <= '0';
    wait_cycle(sys_clk, 5);
    rows(3) <= '1';
    wait_cycle(sys_clk, 5);
    rows(3) <= '0';
    
    wait_cycle(sys_clk, 1550);
    
    rows(0) <= '1';
    wait_cycle(sys_clk, 5);
    rows(0) <= '0';
    wait_cycle(sys_clk, 5);
    rows(0) <= '1';
    wait_cycle(sys_clk, 5);
    rows(0) <= '0';
    wait_cycle(sys_clk, 5);
    rows(0) <= '1';
    wait_cycle(sys_clk, 75);
    rows(0) <= '0';
   
    wait_cycle(sys_clk, 10000);
        
    stop <= true;
    wait;
  end process;
end architecture sim;
