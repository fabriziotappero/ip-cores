----------------------------------------------------------------------
----                                                              ----
---- WISHBONE SPDIF IP Core                                       ----
----                                                              ----
---- This file is part of the SPDIF project                       ----
---- http://www.opencores.org/cores/spdif_interface/              ----
----                                                              ----
---- Description                                                  ----
---- Dual port ram. This version is specific for Altera FPGA's,   ----
---- and uses Altera library to instantiate block ram.            ----
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
-- Revision 1.3  2004/06/26 14:14:46  gedra
-- Converted to numeric_std and fixed a few bugs.
--
-- Revision 1.2  2004/06/19 09:55:19  gedra
-- Delint'ed and changed name of architecture.
--
-- Revision 1.1  2004/06/18 18:40:04  gedra
-- Alternate dual port memory implementation for Altera FPGA's.
-- 
--

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

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

architecture altera of dpram is
   
   component lpm_ram_dp
      generic (LPM_WIDTH              : positive;
                LPM_WIDTHAD           : positive;
                LPM_NUMWORDS          : natural := 0;
                LPM_INDATA            : string  := "REGISTERED";
                LPM_OUTDATA           : string  := "REGISTERED";
                LPM_RDADDRESS_CONTROL : string  := "REGISTERED";
                LPM_WRADDRESS_CONTROL : string  := "REGISTERED";
                LPM_FILE              : string  := "UNUSED";
                LPM_TYPE              : string  := "LPM_RAM_DP";
                LPM_HINT              : string  := "UNUSED");
      port (data                    : in  std_logic_vector(LPM_WIDTH-1 downto 0);
             rdaddress, wraddress   : in  std_logic_vector(LPM_WIDTHAD-1 downto 0);
             rdclock, wrclock       : in  std_logic := '0';
             rden, rdclken, wrclken : in  std_logic := '1';
             wren                   : in  std_logic;
             q                      : out std_logic_vector(LPM_WIDTH-1 downto 0));
   end component;

   signal one : std_logic;

begin

   one <= '1';

   ram : lpm_ram_dp
      generic map(LPM_WIDTH    => DATA_WIDTH,
                  LPM_WIDTHAD  => RAM_WIDTH,
                  LPM_NUMWORDS => 2**RAM_WIDTH)
      port map (data      => din,
                rdaddress => rd_addr,
                wraddress => wr_addr,
                rdclock   => clk,
                wrclock   => clk,
                rden      => rd_en,
                rdclken   => one,
                wrclken   => one,
                wren      => wr_en,
                q         => dout);    

end altera;
