----------------------------------------------------------------------
----                                                              ----
---- WISHBONE GPU IP Core                                         ----
----                                                              ----
---- This file is part of the GPU project                         ----
---- http://www.opencores.org/project,gpu                         ----
----                                                              ----
---- Description                                                  ----
---- Implementation of GPU IP core according to                   ----
---- GPU IP core specification document.                          ----
----                                                              ----
---- Author:                                                      ----
----     - Diego A. González Idárraga, diegoandres91b@hotmail.com ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                 ----
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

use work.core_pkg.all;

entity portc_tristate_bridge is
    generic(
        PORTS : natural := 2
    );
    port(
        iaddrc : in addrc_t(0 to PORTS-1);
        iwec   : in std_logic_vector(0 to PORTS-1);
        idatac : in datac_t(0 to PORTS-1);
        
        oaddrc : out unsigned(4 downto 0);
        owec   : out std_logic;
        odatac : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of portc_tristate_bridge is
begin
    u0 : for i in 0 to PORTS-1 generate
        oaddrc <= iaddrc(i) when iwec(i) = '1' else (others=> 'Z');
        odatac <= idatac(i) when iwec(i) = '1' else (others=> 'Z');
    end generate;
    
    process(iwec)
        variable owec_1 : std_logic;
    begin
        owec_1 := '0';
        for i in 0 to PORTS-1 loop
            owec_1 := owec_1 or iwec(i);
        end loop;
        owec <= owec_1;
    end process;
end architecture;