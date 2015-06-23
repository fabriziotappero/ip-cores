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

entity fcomp_fmin_fmax is
    generic(
        USE_SUBNORMAL : boolean := false;
        LATENCY_1     : natural := 1;
        LATENCY_2     : natural := 1
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        cke   : in std_logic;
        
        x1 : in pfloat;
        x2 : in pfloat;
        
        sel : in std_logic;
        
        x1_l_x2   : out std_logic;
        x1_le_x2  : out std_logic;
        x1_e_x2   : out std_logic;
        x1_ge_x2  : out std_logic;
        x1_g_x2   : out std_logic;
        x1_ne_x2  : out std_logic;
        ordered   : out std_logic;
        unordered : out std_logic;
        
        y : out pfloat
    );
end entity;

architecture rtl of fcomp_fmin_fmax is
    type y_1_t is array(0 to LATENCY_2) of pfloat;
    
    signal x1_l_x2_1   : std_logic_vector(0 to LATENCY_1);
    signal x1_le_x2_1  : std_logic_vector(0 to LATENCY_1);
    signal x1_e_x2_1   : std_logic_vector(0 to LATENCY_1);
    signal x1_ge_x2_1  : std_logic_vector(0 to LATENCY_1);
    signal x1_g_x2_1   : std_logic_vector(0 to LATENCY_1);
    signal x1_ne_x2_1  : std_logic_vector(0 to LATENCY_1);
    signal ordered_1   : std_logic_vector(0 to LATENCY_1);
    signal unordered_1 : std_logic_vector(0 to LATENCY_1);
    
    signal y_1 : y_1_t;
begin
    process(clk, reset, cke,
            x1, x2, sel,
            x1_l_x2_1, x1_le_x2_1, x1_e_x2_1, x1_ge_x2_1, x1_g_x2_1, x1_ne_x2_1, ordered_1, unordered_1,
            y_1)
        type comp_t  is (less, equal, greater);
        type x1_x2_t is (is_x1, is_x2);
        
        variable x1_c  : pfloat_c;
        variable x2_c  : pfloat_c;
        variable comp  : comp_t;
        variable x1_x2 : x1_x2_t;
    begin
        x1_c := to_pfloat_c(x1, USE_SUBNORMAL);
        x2_c := to_pfloat_c(x2, USE_SUBNORMAL);
        
        if x1_c.nan or x2_c.nan then
            ordered_1(0) <= '0';
            unordered_1(0) <= '1';
        else
            ordered_1(0) <= '1';
            unordered_1(0) <= '0';
        end if;
        
        if x1_c.zero and x2_c.zero then
            comp := equal;
        elsif x1.sign /= x2.sign then
            case x1.sign is
            when '0'=>
                comp := greater;
            when '1'=>
                comp := less;
            when others=>
            end case;
        else
            if x1.exponent < x2.exponent then
                case x1.sign is
                when '0'=>
                    comp := less;
                when '1'=>
                    comp := greater;
                when others=>
                end case;
            elsif x1.exponent = x2.exponent then
                if x1.fraction < x2.fraction then
                    case x1.sign is
                    when '0'=>
                        comp := less;
                    when '1'=>
                        comp := greater;
                    when others=>
                    end case;
                elsif x1.fraction = x2.fraction then
                    comp := equal;
                else
                    case x1.sign is
                    when '0'=>
                        comp := greater;
                    when '1'=>
                        comp := less;
                    when others=>
                    end case;
                end if;
            else
                case x1.sign is
                when '0'=>
                    comp := greater;
                when '1'=>
                    comp := less;
                when others=>
                end case;
            end if;
        end if;
        
        case comp is
        when less=>
            x1_l_x2_1(0) <= ordered_1(0);
            x1_le_x2_1(0) <= ordered_1(0);
            x1_e_x2_1(0) <= '0';
            x1_ge_x2_1(0) <= '0';
            x1_g_x2_1(0) <= '0';
            x1_ne_x2_1(0) <= '1';
        when equal=>
            x1_l_x2_1(0) <= '0';
            x1_le_x2_1(0) <= ordered_1(0);
            x1_e_x2_1(0) <= ordered_1(0);
            x1_ge_x2_1(0) <= ordered_1(0);
            x1_g_x2_1(0) <= '0';
            x1_ne_x2_1(0) <= unordered_1(0);
        when greater=>
            x1_l_x2_1(0) <= '0';
            x1_le_x2_1(0) <= '0';
            x1_e_x2_1(0) <= '0';
            x1_ge_x2_1(0) <= ordered_1(0);
            x1_g_x2_1(0) <= ordered_1(0);
            x1_ne_x2_1(0) <= '1';
        end case;
        
        for i in 1 to LATENCY_1 loop
            if reset = '1' then
                x1_l_x2_1(i) <= '0';
                x1_le_x2_1(i) <= '0';
                x1_e_x2_1(i) <= '0';
                x1_ge_x2_1(i) <= '0';
                x1_g_x2_1(i) <= '0';
                x1_ne_x2_1(i) <= '0';
                ordered_1(i) <= '0';
                unordered_1(i) <= '0';
            elsif rising_edge(clk) and (cke = '1') then
                x1_l_x2_1(i) <= x1_l_x2_1(i-1);
                x1_le_x2_1(i) <= x1_le_x2_1(i-1);
                x1_e_x2_1(i) <= x1_e_x2_1(i-1);
                x1_ge_x2_1(i) <= x1_ge_x2_1(i-1);
                x1_g_x2_1(i) <= x1_g_x2_1(i-1);
                x1_ne_x2_1(i) <= x1_ne_x2_1(i-1);
                ordered_1(i) <= ordered_1(i-1);
                unordered_1(i) <= unordered_1(i-1);
            end if;
        end loop;
        
        x1_l_x2 <= x1_l_x2_1(LATENCY_1);
        x1_le_x2 <= x1_le_x2_1(LATENCY_1);
        x1_e_x2 <= x1_e_x2_1(LATENCY_1);
        x1_ge_x2 <= x1_ge_x2_1(LATENCY_1);
        x1_g_x2 <= x1_g_x2_1(LATENCY_1);
        x1_ne_x2 <= x1_ne_x2_1(LATENCY_1);
        ordered <= ordered_1(LATENCY_1);
        unordered <= unordered_1(LATENCY_1);
        
        if x1_c.nan then
            x1_x2 := is_x2;
        elsif x2_c.nan then
            x1_x2 := is_x1;
        else
            case sel is
            when '0'=>
                case comp is
                when less=>
                    x1_x2 := is_x1;
                when equal|greater=>
                    x1_x2 := is_x2;
                end case;
            when '1'=>
                case comp is
                when less=>
                    x1_x2 := is_x2;
                when equal|greater=>
                    x1_x2 := is_x1;
                end case;
            when others=>
            end case;
        end if;
        
        case x1_x2 is
        when is_x1=>
            y_1(0) <= x1;
        when is_x2=>
            y_1(0) <= x2;
        end case;
        
        for i in 1 to LATENCY_2 loop
            if reset = '1' then
                y_1(i) <= ('0', (others=> '0'), (others=> '0'));
            elsif rising_edge(clk) and (cke = '1') then
                y_1(i) <= y_1(i-1);
            end if;
        end loop;
        
        y <= y_1(LATENCY_2);
    end process;
end architecture;