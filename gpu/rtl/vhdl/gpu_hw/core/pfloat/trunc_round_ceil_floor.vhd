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

entity trunc_round_ceil_floor is
    generic(
        USE_SUBNORMAL : boolean := false;
        LATENCY       : natural := 1
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        cke   : in std_logic;
        
        sel : in std_logic_vector(1 downto 0);
        x   : in pfloat;
        
        y : out pfloat
    );
end entity;

architecture rtl of trunc_round_ceil_floor is
    type y_1_t is array(0 to LATENCY) of pfloat;
    
    signal y_1 : y_1_t;
begin
    process(clk, reset, cke,
            sel, x,
            y_1)
        variable x_c      : pfloat_c;
        variable add      : std_logic;
        variable a        : unsigned(24 downto 0);
        variable a_shift  : signed(8 downto 0);
        variable b        : unsigned(23 downto 0);
        variable b_shift  : signed(8 downto 0);
        variable fraction : unsigned(24 downto 0);
        variable exponent : unsigned(7 downto 0);
    begin
        x_c := to_pfloat_c(x, USE_SUBNORMAL);
        
        if x_c.nan or x_c.zero or x_c.infinity then -- si x es NaN, 0 o infinito no se hace nada
            y_1(0) <= x;
        else
            case sel is
            when "00"=> -- trunc not adds
                add := '0';
            when "01"=> -- round adds .5 to fraction
                add := '1';
            when "10"=> -- ceil adds .999... to fraction if positive
                add := not(x.sign);
            when "11"=> -- floor adds .999... to fraction if negative
                add := x.sign;
            when others=>
            end case;
            
            a := (24=> add, others=> add and sel(1)); -- a is .5 with trunc and round, or .999... with ceil and floor
            a_shift := signed('0'&x.exponent)-125;
            
            if a_shift(8) = '0' then
                a := shift_right(a, to_integer(unsigned(a_shift(7 downto 0))));
            end if;
            
            b := "111111111111111111111111";
            b_shift := (126+24)-signed('0'&x.exponent);
            
            if b_shift(8) = '0' then
                b := shift_left(b, to_integer(unsigned(b_shift(7 downto 0))));
            end if;
            
            fraction := (("01"&x.fraction)+('0'&a(23 downto 0))) and ('1'&b);
            
            if x.exponent < 127 then -- if (x <= .5) x can only be 0. or 1. else carry fraction(24)
                case sel is
                when "00"=>
                    exponent := to_unsigned(0, 8);
                when "01"=>
                    if x.exponent = 126 then
                        exponent := to_unsigned(127, 8);
                    else
                        exponent := to_unsigned(0, 8);
                    end if;
                when "10"=>
                    if x.sign = '0' then
                        exponent := to_unsigned(127, 8);
                    else
                        exponent := to_unsigned(0, 8);
                    end if;
                when "11"=>
                    if x.sign = '1' then
                        exponent := to_unsigned(127, 8);
                    else
                        exponent := to_unsigned(0, 8);
                    end if;
                when others=>
                end case;
            else
                exponent := x.exponent+fraction(24 downto 24);
            end if;
            
            y_1(0) <= (x.sign, exponent, fraction(22 downto 0));
        end if;
        
        for i in 1 to LATENCY loop
            if reset = '1' then
                y_1(i) <= ('0', (others=> '0'), (others=> '0'));
            elsif rising_edge(clk) and (cke = '1') then
                y_1(i) <= y_1(i-1);
            end if;
        end loop;
        
        y <= y_1(LATENCY);
    end process;
end architecture;