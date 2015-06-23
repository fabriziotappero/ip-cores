-----------------------------------------------------------------------------
--	Copyright (C) 2009 Sam Green
--
-- This code is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This code is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- Waits for data_i to high for INTERVAL_QUADRUPLE FPGA clocks then
-- sends ready_o high
--
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity waitForStart is
  port ( 
    data_i : in  std_logic;
    clk_i : in  std_logic;
    rst_i : in std_logic;           
    ready_o : out  std_logic
  );           
end;

architecture behavioral of waitForStart is
begin
  process (clk_i, rst_i)
    variable counter : integer;
    variable lock : std_logic;
  begin
    if (rst_i = '1') then
      ready_o <= '0';
      counter := 0;
      lock := '0';
    elsif rising_edge(clk_i) then    
      if data_i = '1' then
        counter := counter + 1;
      else
        counter := 0;
      end if;
      
      if counter > INTERVAL_QUADRUPLE or lock = '1' then
        ready_o <= '1';
        lock := '1';
      else
        ready_o <= '0';
      end if;    
    end if;        
  end process;
 
 end;

