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

entity fmul is
    generic(
        USE_SUBNORMAL       : boolean           := false;
        ROUND_STYLE         : float_round_style := round_to_nearest;
        LATENCY             : natural           := 2;
        EMBEDDED_MULTIPLIER : boolean           := true
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        cke   : in std_logic;
        
        x1 : in pfloat;
        x2 : in pfloat;
        
        y : out pfloat
    );
end entity;

architecture rtl of fmul is
    constant latency_1 : natural := maximum(0, LATENCY-1);
    
    type x_c_t      is array(0 to latency_1) of pfloat_c;
    type exponent_t is array(0 to latency_1) of signed(9 downto 0);
    type sign_t     is array(0 to latency_1) of std_logic;
    
    signal x1_c : x_c_t;
    signal x2_c : x_c_t;
    signal fraction1_1 : unsigned(23 downto 0);
    signal fraction2_1 : unsigned(23 downto 0);
    signal exponent : exponent_t;
    signal sign : sign_t;
    signal fraction : unsigned(24 downto 0);
    signal round : std_logic;
    signal sticky : std_logic;
begin
    process(clk, reset, cke,
            x1, x2,
            x1_c, x2_c, fraction, exponent, sign, round, sticky)
        variable fraction1 : unsigned(23 downto 0);
        variable fraction2 : unsigned(23 downto 0);
        variable shift1 : natural;
        variable shift2 : natural;
        variable bias : natural;
        variable reg : boolean;
    begin
        x1_c(0) <= to_pfloat_c(x1, USE_SUBNORMAL);
        x2_c(0) <= to_pfloat_c(x2, USE_SUBNORMAL);
        
        if USE_SUBNORMAL then
            fraction1 := x1_c(0).exponent_or_reduce&x1.fraction;
            fraction2 := x2_c(0).exponent_or_reduce&x2.fraction;
            shift1 := shift_calc(fraction1, 3).i;
            shift2 := shift_calc(fraction2, 3).i;
        else
            fraction1 := '1'&x1.fraction;
            fraction2 := '1'&x2.fraction;
            shift1 := 0;
            shift2 := 0;
        end if;
        
        fraction1_1 <= shift_left(fraction1, shift1);
        fraction2_1 <= shift_left(fraction2, shift2);
        
        if x1_c(0).subnormal and x2_c(0).subnormal then
            bias := 125-1;
        elsif x1_c(0).subnormal xor x2_c(0).subnormal then
            bias := 126-1;
        else
            bias := 127-1;
        end if;
        
        exponent(0) <= signed("00"&x1.exponent)+signed("00"&x2.exponent)-bias-(shift1+shift2);
        sign(0) <= x1.sign xor x2.sign;
        
        for i in 1 to latency_1 loop
            if reset = '1' then
                x1_c(i) <= ('0', '0', '0', false, false, false, false, false);
                x2_c(i) <= ('0', '0', '0', false, false, false, false, false);
                exponent(i) <= (others=> '0');
                sign(i) <= '0';
            elsif rising_edge(clk) and (cke = '1') then
                x1_c(i) <= x1_c(i-1);
                x2_c(i) <= x2_c(i-1);
                exponent(i) <= exponent(i-1);
                sign(i) <= sign(i-1);
            end if;
        end loop;
        
        reg := (LATENCY /= 0);
        
        if reg and (reset = '1') then
            y <= ('0', (others=> '0'), (others=> '0'));
        elsif not(reg) or (rising_edge(clk) and (cke = '1')) then
            if x1_c(latency_1).nan or x2_c(latency_1).nan or -- nan*x, x*nan, nan*nan : nan
               (x1_c(latency_1).infinity and x2_c(latency_1).zero) or -- inf*0 : nan
               (x1_c(latency_1).zero and x2_c(latency_1).infinity) then -- 0*inf : nan
                y <= NAN;
            else
                y <= to_pfloat(sign(latency_1), exponent(latency_1), fraction, shift_calc(fraction(24 downto 23)).i,
                               ROUND_STYLE, round, sticky,
                               x1_c(latency_1).zero or x2_c(latency_1).zero, -- 0*x = x*0 = 0
                               x1_c(latency_1).infinity or x2_c(latency_1).infinity, -- inf*x = x*inf = inf
                               USE_SUBNORMAL);
            end if;
        end if;
    end process;
    
    u0 : mul
    generic map(
        DATA_WIDTH=>          24,
        LATENCY=>             latency_1,
        EMBEDDED_MULTIPLIER=> EMBEDDED_MULTIPLIER
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        x1=> fraction1_1,
        x2=> fraction2_1,
        
        y=>      fraction,
        round=>  round,
        sticky=> sticky
    );
end architecture;