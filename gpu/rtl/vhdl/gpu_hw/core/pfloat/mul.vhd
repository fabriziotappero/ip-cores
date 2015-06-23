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
use ieee.math_real.all;
use work.pfloat_pkg.all;

entity mul is
    generic(
        DATA_WIDTH          : positive := 24;
        LATENCY             : natural  := 1;
        EMBEDDED_MULTIPLIER : boolean  := true
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        cke   : in std_logic;
        
        x1 : in unsigned(DATA_WIDTH-1 downto 0); -- x1: x.xxx...
        x2 : in unsigned(DATA_WIDTH-1 downto 0); -- x2: x.xxx...
        
        y      : out unsigned(DATA_WIDTH downto 0); -- y: xx.xxx...
        round  : out std_logic;
        sticky : out std_logic
    );
end entity;

architecture rtl of mul is
    type mul_reg_t is array(DATA_WIDTH-1 downto 0) of unsigned(DATA_WIDTH+2 downto 0);
    type x_t       is array(DATA_WIDTH-1 downto 0) of unsigned(DATA_WIDTH-1 downto 0);
    
    signal mul_reg : mul_reg_t;
    signal x1_reg  : x_t;
    signal x2_reg  : x_t;
    
    function latency_1_init return natural is
    begin
        if EMBEDDED_MULTIPLIER then
            return LATENCY;
        else
            return maximum(0, LATENCY-(DATA_WIDTH-1));
        end if;
    end function;
    
    constant latency_1 : natural := latency_1_init;
    
    type y_1_t          is array(latency_1 downto 0) of unsigned(DATA_WIDTH downto 0);
    type round_sticky_t is array(latency_1 downto 0) of std_logic;
    
    signal y_1      : y_1_t;
    signal round_1  : round_sticky_t;
    signal sticky_1 : round_sticky_t;
begin
    process(clk, cke, reset,
            x1, x2,
            mul_reg, x1_reg, x2_reg,
            y_1, round_1, sticky_1)
        variable mul_var : unsigned(2*DATA_WIDTH-1 downto 0);
        variable reg     : boolean;
        variable add_var : unsigned(DATA_WIDTH downto 0);
    begin
        if EMBEDDED_MULTIPLIER then
            mul_var := x1*x2;
            y_1(0) <= mul_var(2*DATA_WIDTH-1 downto DATA_WIDTH-1);
            
            if DATA_WIDTH > 1 then
                round_1(0) <= mul_var(DATA_WIDTH-2);
            else
                round_1(0) <= '0';
            end if;
            
            sticky_1(0) <= or_reduce(mul_var(DATA_WIDTH-3 downto 0));
        else
            for i in 0 to DATA_WIDTH-1 loop
                if i = 0 then
                    mul_reg(i) <= add_sub_f(to_unsigned(0, DATA_WIDTH), x1, '0', x2(i))&"00";
                    x1_reg(i) <= x1;
                    x2_reg(i) <= x2;
                else
                    reg := (LATENCY /= 0) and ((real(i) mod (real(DATA_WIDTH-1)/real(LATENCY))) < 1.0); -- segmentation
                    
                    if reg and (reset = '1') then
                        mul_reg(i) <= (others=> '0');
                        x1_reg(i) <= (others=> '0');
                        x2_reg(i) <= (others=> '0');
                    elsif not(reg) or (rising_edge(clk) and (cke = '1')) then
                        add_var := add_sub_f(mul_reg(i-1)(DATA_WIDTH+2 downto 3), x1_reg(i-1), '0', x2_reg(i-1)(i));
                        mul_reg(i)(DATA_WIDTH+2 downto 3) <= add_var(DATA_WIDTH downto 1);
                        
                        if i < DATA_WIDTH-2 then
                            mul_reg(i)(2) <= mul_reg(i-1)(2) or add_var(0);
                        else
                            mul_reg(i)(2) <= add_var(0);
                        end if;
                        
                        mul_reg(i)(1 downto 0) <= mul_reg(i-1)(2 downto 1);
                        x1_reg(i) <= x1_reg(i-1);
                        x2_reg(i) <= x2_reg(i-1);
                    end if;
                end if;
            end loop;
            
            y_1(0) <= mul_reg(DATA_WIDTH-1)(DATA_WIDTH+2 downto 2);
            round_1(0) <= mul_reg(DATA_WIDTH-1)(1);
            sticky_1(0) <= mul_reg(DATA_WIDTH-1)(0);
        end if;
        
        for i in 1 to latency_1 loop
            if reset = '1' then
                y_1(i) <= (others=> '0');
                round_1(i) <= '0';
                sticky_1(i) <= '0';
            elsif rising_edge(clk) and (cke = '1') then
                y_1(i) <= y_1(i-1);
                round_1(i) <= round_1(i-1);
                sticky_1(i) <= sticky_1(i-1);
            end if;
        end loop;
        
        y <= y_1(latency_1);
        round <= round_1(latency_1);
        sticky <= sticky_1(latency_1);
    end process;
end architecture;