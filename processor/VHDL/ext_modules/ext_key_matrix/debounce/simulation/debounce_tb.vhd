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

entity debounce_tb is
end entity debounce_tb;

architecture sim of debounce_tb is
  component debounce_top is
    port
    (
      sys_clk : in std_logic;
      sys_res_n : in std_logic;
      btn_a : in std_logic;
      seg_a : out std_logic_vector(6 downto 0);
      seg_b : out std_logic_vector(6 downto 0)
    );
  end component debounce_top;
  
  signal sys_clk, sys_res_n : std_logic;
  signal btn_a : std_logic;
  signal seg_a, seg_b : std_logic_vector(6 downto 0);
  signal stop : boolean := false;
begin
  uut : debounce_top
    port map
    (
      sys_clk => sys_clk,
      sys_res_n => sys_res_n,
      btn_a => btn_a,
      seg_a => seg_a,
      seg_b => seg_b
    );
    
  process
  begin
    sys_clk <= '0';
    wait for 15 ns;
    sys_clk <= '1';
    if stop = true then
      wait;
    end if;
    wait for 15 ns;
  end process;
  
  process
  begin
    sys_res_n <= '0';
    btn_a <= '1';
    wait for 100 ns;
    sys_res_n <= '1';
    wait for 2 ms;
    btn_a <= '0';
    wait for 100 us;
    btn_a <= '1';
    wait for 50 us;
    btn_a <= '0';
    wait for 150 us;
    btn_a <= '1';
    wait for 25 us;
    btn_a <= '0';
    wait for 175 us;
    btn_a <= '1';
    wait for 1 us;
    btn_a <= '0';
    wait for 2 ms;
    btn_a <= '1';
    wait for 100 us;
    btn_a <= '0';
    wait for 50 us;
    btn_a <= '1';
    wait for 150 us;
    btn_a <= '0';
    wait for 25 us;
    btn_a <= '1';
    wait for 175 us;
    btn_a <= '0';
    wait for 1 us;
    btn_a <= '1';
    wait for 2 ms;
    btn_a <= '0';
    wait for 100 us;
    btn_a <= '1';
    wait for 50 us;
    btn_a <= '0';
    wait for 150 us;
    btn_a <= '1';
    wait for 25 us;
    btn_a <= '0';
    wait for 175 us;
    btn_a <= '1';
    wait for 1 us;
    btn_a <= '0';
    wait for 2 ms;
    stop <= true;
    wait;
  end process;
end architecture sim;
