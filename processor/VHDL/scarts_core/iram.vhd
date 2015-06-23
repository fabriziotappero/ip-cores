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

use work.scarts_core_pkg.all;
use work.scarts_pkg.all;

entity scarts_iram is
  generic (
    CONF : scarts_conf_type);    
  port (
    wclk        : in  std_ulogic;
    rclk        : in  std_ulogic;
    hold        : in  std_ulogic;

    wdata       : in  INSTR;
    waddr       : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
    wen         : in  std_ulogic;
    raddr       : in  std_logic_vector(CONF.instr_ram_size-1 downto 0);
    rdata       : out INSTR);
end scarts_iram;

architecture behaviour of scarts_iram is

  constant NWORDS : integer  := 2**CONF.instr_ram_size;
  type ram_array is array (0 to NWORDS-1) of INSTR;

  signal ram : ram_array := (others => NOP);
  signal enable    : std_ulogic;
  signal data_int       : INSTR;

begin

  enable <= not hold;

  process(wclk)
  begin
    if rising_edge(wclk) then 
      if (enable = '1') then
        if wen = '1' then
          ram(to_integer(unsigned(waddr))) <= wdata;
        end if;
      end if;
    end if;
  end process;

  process(rclk)
  begin
    if rising_edge(rclk) then 
      if (enable = '1') then
        data_int <= (others => '0');
        data_int <= ram(to_integer(unsigned(raddr)));
      end if;
    end if;
  end process;

  -- little-endianness used for storing instructions in memory
  -- => swap bytes
  rdata(15 downto 8) <= data_int(7 downto 0);
  rdata(7 downto 0) <= data_int(15 downto 8);
  
end behaviour;
