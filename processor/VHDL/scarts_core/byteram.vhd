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


entity scarts_byteram is
  generic (
    CONF : scarts_conf_type);
  port (
    wclk        : in  std_ulogic;
    rclk        : in  std_ulogic;
    enable      : in  std_ulogic;

    wdata       : in  std_logic_vector(7 downto 0);
    waddr       : in  std_logic_vector((CONF.data_ram_size-3) downto 0);
    wen         : in  std_ulogic;
    raddr       : in  std_logic_vector((CONF.data_ram_size-3) downto 0);
    rdata       : out std_logic_vector(7 downto 0)
    );
end scarts_byteram;

architecture behaviour of scarts_byteram is

-- FIXME (jl): is this correct?
constant WORD_CNT : natural := 2**(CONF.data_ram_size - CONF.word_size/16);

subtype WORD is std_logic_vector(7 downto 0);
type ram_array is array (0 to WORD_CNT-1) of WORD;

signal ram : ram_array := (others => (others => '0'));

begin

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
        rdata <= (others => '0');
        rdata <= ram(to_integer(unsigned(raddr)));
      end if;
    end if;
  end process;

end behaviour;
