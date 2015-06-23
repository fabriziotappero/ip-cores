-------------------------------------------------------------------------------
----                                                                       ----
---- WISHBONE Wishbone_BFM IP Core                                         ----
----                                                                       ----
---- This file is part of the Wishbone_BFM project                         ----
---- http://www.opencores.org/cores/Wishbone_BFM/                          ----
----                                                                       ----
---- Description                                                           ----
---- Implementation of Wishbone_BFM IP core according to                   ----
---- Wishbone_BFM IP core specification document.                          ----
----                                                                       ----
---- To Do:                                                                ----
----	NA                                                                 ----
----                                                                       ----
---- Author(s):                                                            ----
----   Andrew Mulcock, amulcock@opencores.org                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
---- Copyright (C) 2008 Authors and OPENCORES.ORG                          ----
----                                                                       ----
---- This source file may be used and distributed without                  ----
---- restriction provided that this copyright statement is not             ----
---- removed from the file and that any derivative work contains           ----
---- the original copyright notice and the associated disclaimer.          ----
----                                                                       ----
---- This source file is free software; you can redistribute it            ----
---- and/or modify it under the terms of the GNU Lesser General            ----
---- Public License as published by the Free Software Foundation           ----
---- either version 2.1 of the License, or (at your option) any            ----
---- later version.                                                        ----
----                                                                       ----
---- This source is distributed in the hope that it will be                ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied            ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR               ----
---- PURPOSE. See the GNU Lesser General Public License for more           ----
---- details.                                                              ----
----                                                                       ----
---- You should have received a copy of the GNU Lesser General             ----
---- Public License along with this source; if not, download it            ----
---- from http://www.opencores.org/lgpl.shtml                              ----
----                                                                       ----
-------------------------------------------------------------------------------
----                                                                       ----
-- CVS Revision History                                                    ----
----                                                                       ----
-- $Log: not supported by cvs2svn $                                                                   ----
----                                                                       ----


use work.io_pack.all;   -- contains the clock frequency integer


library ieee;
use ieee.std_logic_1164.all;
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

entity syscon is
    port(
    -- sys_con ports
    RST_sys    : in  std_logic;
    CLK_stop   : in  std_logic;
    RST_O      : out std_logic;
    CLK_O      : out std_logic
        );

end syscon;

architecture Behavioral of syscon is

signal  clk_internal    : std_logic;
signal  rst_internal    : std_logic := '0'; -- not reset

begin


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
 -- sys con siumulator
clock_loop : process
begin
    clk_internal <= '0';
        if CLK_stop = '1' then
            wait;
        end if;
    wait for clk_period/2;
        clk_internal <= '1';
    wait for clk_period/2;
end process clock_loop;


CLK_O <= clk_internal;

rst_loop : process ( RST_sys, clk_internal )
begin
    if ( RST_sys = '1' ) then
        rst_internal <= '1';
    elsif rising_edge( clk_internal ) then
        if RST_sys = '0' then
            rst_internal <= '0';
        end if;
    end if;
end process rst_loop;

RST_O <= rst_internal;

end Behavioral;
