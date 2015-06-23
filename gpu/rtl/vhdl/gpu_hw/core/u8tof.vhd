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

use work.pfloat_pkg.all;

entity u8tof is
    generic(
        DATAC_REG : boolean := true
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        cke   : in std_logic;
        
        ll_lh_hl_hh : in std_logic_vector(1 downto 0);  -- alignment
        datab       : in std_logic_vector(31 downto 0);
        
        datac : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of u8tof is
begin
    process(clk, reset, cke,
            ll_lh_hl_hh, datab)
        variable u8 : unsigned(7 downto 0);
    begin
        case ll_lh_hl_hh is
        when "00"=>
            u8 := unsigned(datab(7 downto 0));
        when "01"=>
            u8 := unsigned(datab(15 downto 8));
        when "10"=>
            u8 := unsigned(datab(23 downto 16));
        when "11"=>
            u8 := unsigned(datab(31 downto 24));
        when others=>
            null;
        end case;
        
        if DATAC_REG and (reset = '1') then
            datac <= (others=> '0');
        elsif not(DATAC_REG) or (rising_edge(clk) and (cke = '1')) then
            datac <= to_stdlogicvector(to_pfloat(u8));
        end if;
    end process;
end architecture;