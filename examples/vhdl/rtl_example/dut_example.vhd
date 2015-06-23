----------------------------------------------------------------------
----                                                              ----
---- PlTbUtils Example DUT                                        ----
----                                                              ----
---- This file is part of the PlTbUtils project                   ----
---- http://opencores.org/project,pltbutils                       ----
----                                                              ----
---- Description:                                                 ----
---- PlTbUtils is a collection of functions, procedures and       ----
---- components for easily creating stimuli and checking response ----
---- in automatic self-checking testbenches.                      ----
----                                                              ----
---- This file is an example component for use as DUT             ----
---- (Device Under Test) in tb_example.vhd, which demonstrates    ----
---- how PlTbUtils can be used.                                   ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Per Larsson, pela.opencores@gmail.com                      ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2013 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more  ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dut_example is
  generic (
    G_WIDTH         : integer := 8;
    G_DISABLE_BUGS  : integer range 0 to 1 := 1
  );
  port (
    clk_i           : in  std_logic;
    rst_i           : in  std_logic;
    carry_i         : in  std_logic;
    x_i             : in  std_logic_vector(G_WIDTH-1 downto 0);
    y_i             : in  std_logic_vector(G_WIDTH-1 downto 0);
    sum_o           : out std_logic_vector(G_WIDTH-1 downto 0);
    carry_o         : out std_logic
  );    
end entity dut_example;

architecture rtl of dut_example is
  signal x          : unsigned(G_WIDTH downto 0);
  signal y          : unsigned(G_WIDTH downto 0);
  signal c          : unsigned(G_WIDTH downto 0);
  signal sum        : unsigned(G_WIDTH downto 0);
begin

  x <= resize(unsigned(x_i), G_WIDTH+1);
  y <= resize(unsigned(y_i), G_WIDTH+1);
  c <= resize(unsigned(std_logic_vector'('0' & carry_i)), G_WIDTH+1);
  
  p_sum : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        sum <= (others => '0');
      else
        if G_DISABLE_BUGS = 1 then
          sum <= x + y + c;
        else
          sum <= x + y;
        end if;
      end if;
    end if;
  end process;
  
  sum_o <= std_logic_vector(sum(sum'high-1 downto 0));
  carry_o <= sum(sum'high);
  
end architecture rtl;

