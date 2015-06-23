

-- Copyright (c) 2013 Antonio de la Piedra
 
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity dual_mem is
  generic (ADDR_LENGTH : integer := 6;
           DATA_LENGTH : integer := 32;
           N_ADDR      : integer := 64);
  port (clk  : in std_logic;  
        we   : in std_logic;  
        a    : in std_logic_vector(ADDR_LENGTH - 1 downto 0);
        dpra : in std_logic_vector(ADDR_LENGTH - 1 downto 0);
        di   : in std_logic_vector(DATA_LENGTH - 1 downto 0);
        spo  : out std_logic_vector(DATA_LENGTH - 1 downto 0);
        dpo  : out std_logic_vector(DATA_LENGTH - 1 downto 0));
end dual_mem;  

architecture rtl of dual_mem is
  type ram_type is array (N_ADDR - 1  downto 0)
        of std_logic_vector (DATA_LENGTH - 1 downto 0);
  signal RAM : ram_type;  
  signal read_a : std_logic_vector(ADDR_LENGTH - 1 downto 0);
  signal read_dpra : std_logic_vector(ADDR_LENGTH - 1 downto 0);

  attribute ram_style: string;
  attribute ram_style of RAM: signal is "block";

begin
  process (clk)
  begin  
    if rising_edge(clk) then
      if (we = '1') then    
        RAM(conv_integer(a)) <= di;
      end if;  
      read_a <= a;
      read_dpra <= dpra;
    end if;  
  end process;
  
  spo <= RAM(conv_integer(read_a));
  dpo <= RAM(conv_integer(read_dpra));
end rtl;
