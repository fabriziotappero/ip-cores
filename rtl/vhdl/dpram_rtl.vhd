----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Dual port ram. This is a RTL implementation. Some synthesis  ----
---- tools like Synplify will automatically instantiate FPGA      ----
---- block ram. Substitute with dpram_altera or dpram_xilinx for  ----
---- Altera or Xilinx implementations using their free SW.        ----
----                                                              ----
----                                                              ----
---- To Do:                                                       ----
---- -                                                            ----
----                                                              ----
---- Author(s):                                                   ----
---- - Geir Drange, gedra@opencores.org                           ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2004 Authors and OPENCORES.ORG                 ----
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
--
-- CVS Revision History
--
-- $Log: not supported by cvs2svn $
-- Revision 1.3  2004/06/26 14:14:47  gedra
-- Converted to numeric_std and fixed a few bugs.
--
-- Revision 1.2  2004/06/10 18:57:36  gedra
-- Cleaned up lint warnings.
--
-- Revision 1.1  2004/06/09 19:24:31  gedra
-- Generic dual port ram model.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is
   generic (DATA_WIDTH : positive;
            RAM_WIDTH  : positive);
   port (
      clk     : in  std_logic;
      rst     : in  std_logic;          -- reset is optional, not used here
      din     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      wr_en   : in  std_logic;
      rd_en   : in  std_logic;
      wr_addr : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
      rd_addr : in  std_logic_vector(RAM_WIDTH - 1 downto 0);
      dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end dpram;

--library synplify; -- uncomment this line when using Synplify       
architecture rtl of dpram is

   type memory_type is array (2**RAM_WIDTH - 1 downto 0) of
      std_logic_vector(DATA_WIDTH - 1 downto 0);
   signal memory   : memory_type;
   signal lrd_addr : std_logic_vector(RAM_WIDTH - 1 downto 0);
-- Enable syn_ramstyle attribute when using Xilinx to enable block ram
-- otherwise you get embedded CLB ram.
-- attribute syn_ramstyle : string;
-- attribute syn_ramstyle of memory : signal is "block_ram";

begin
   -- Generic ram, good synthesis programs will make block ram out of it...
   process(clk)
   begin
      if rising_edge(clk) then
         if wr_en = '1' then
            memory(to_integer(unsigned(wr_addr))) <= din;
         end if;
      end if;
   end process;

   process(clk)
   begin
      if rising_edge(clk) then
         if rd_en = '1' then
            dout <= memory(to_integer(unsigned(rd_addr)));
         end if;
      end if;
   end process;
   
end rtl;

