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

package pfloat_pkg is
    type pfloat is record
        sign     : std_logic;
        exponent : unsigned(7 downto 0);
        fraction : unsigned(22 downto 0);
    end record;
    
    type shift_t is record
        i     : natural;
        valid : boolean;
    end record;
    
    type shift_array_t is array(natural range <>) of shift_t;
    
    constant ZERO     : pfloat := ('0', "00000000", "00000000000000000000000");
    constant INFINITY : pfloat := ('0', "11111111", "00000000000000000000000");
    constant NAN      : pfloat := ('0', "11111111", "10000000000000000000000");
    
    type pfloat_c is record
        exponent_or_reduce  : std_logic;
        exponent_and_reduce : std_logic;
        fraction_or_reduce  : std_logic;
        zero                : boolean;
        subnormal           : boolean;
        normal              : boolean;
        infinity            : boolean;
        nan                 : boolean;
    end record;
    
    type float_round_style is (
        round_toward_zero,
        round_to_nearest,
        round_toward_infinity,
        round_toward_neg_infinity
    );
    
    function to_pfloat(x : std_logic_vector(31 downto 0)) return pfloat;
    
    function to_pfloat(
        x         : unsigned;
        SUBDIVIDE : positive := 1
    ) return pfloat;
    
    function "-"(x : pfloat) return pfloat;
    function "abs"(x : pfloat) return pfloat;
    
    function copysign(
        x    : pfloat;
        sign : std_logic
    ) return pfloat;
    
    function or_reduce(x : std_logic_vector) return std_logic;
    function or_reduce(x : signed) return std_logic;
    function or_reduce(x : unsigned) return std_logic;
    
    function and_reduce(x : std_logic_vector) return std_logic;
    function and_reduce(x : signed) return std_logic;
    function and_reduce(x : unsigned) return std_logic;
    
    function to_pfloat_c(
        x : pfloat;
        USE_SUBNORMAL : boolean
    ) return pfloat_c;
    
    function minimum(x1, x2 : integer) return integer;
    function maximum(x1, x2 : integer) return integer;
    
    function add_sub_f(
        x1  : unsigned;
        x2  : unsigned;
        sel : std_logic;
        mul : std_logic := '1'
    ) return unsigned;
    
    function shift_calc(
        x         : unsigned;
        SUBDIVIDE : positive := 1
    ) return shift_t;
    
    component add_sub is
        generic(
            DATA_WIDTH : positive;
            SHIFT_MAX  : natural;
            LATENCY    : natural
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            sel   : in std_logic;
            x1    : in unsigned(DATA_WIDTH-1 downto 0);
            x2    : in unsigned(DATA_WIDTH-1 downto 0);
            shift : in natural range 0 to SHIFT_MAX;
            
            y      : out unsigned(DATA_WIDTH+1 downto 0);
            round  : out std_logic;
            sticky : out std_logic
        );
    end component;
    
    component mul is
        generic(
            DATA_WIDTH          : positive;
            LATENCY             : natural;
            EMBEDDED_MULTIPLIER : boolean
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            x1 : in unsigned(DATA_WIDTH-1 downto 0);
            x2 : in unsigned(DATA_WIDTH-1 downto 0);
            
            y      : out unsigned(DATA_WIDTH downto 0);
            round  : out std_logic;
            sticky : out std_logic
        );
    end component;
    
    component div is
        generic(
            DATA_WIDTH : positive;
            LATENCY    : natural
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            x1 : in unsigned(DATA_WIDTH-1 downto 0);
            x2 : in unsigned(DATA_WIDTH-1 downto 0);
            
            y      : out unsigned(DATA_WIDTH downto 0);
            round  : out std_logic;
            sticky : out std_logic
        );
    end component;
    
    function to_pfloat(
        sign     : std_logic;
        exponent : signed(9 downto 0);
        fraction : unsigned;
        shift    : natural;
        
        round_style : float_round_style;
        round       : std_logic;
        sticky      : std_logic;
        
        iszero : boolean;
        isinf  : boolean;
        
        USE_SUBNORMAL : boolean
    ) return pfloat;
    
    component fmulp2 is
        generic(
            USE_SUBNORMAL : boolean;
            LATENCY       : natural
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            x1        : in pfloat;
            exponent2 : in signed(8 downto 0);
            
            y : out pfloat
        );
    end component;
    
    component fadd_fsub is
        generic(
            USE_SUBNORMAL : boolean;
            ROUND_STYLE   : float_round_style;
            LATENCY       : natural
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            sel : in std_logic;
            x1  : in pfloat;
            x2  : in pfloat;
            
            y : out pfloat
        );
    end component;
    
    component fmul is
        generic(
            USE_SUBNORMAL       : boolean;
            ROUND_STYLE         : float_round_style;
            LATENCY             : natural;
            EMBEDDED_MULTIPLIER : boolean
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            x1 : in pfloat;
            x2 : in pfloat;
            
            y : out pfloat
        );
    end component;
    
    component fdiv is
        generic(
            USE_SUBNORMAL : boolean;
            ROUND_STYLE   : float_round_style;
            LATENCY       : natural
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            x1 : in pfloat;
            x2 : in pfloat;
            
            y : out pfloat
        );
    end component;
    
    component trunc_round_ceil_floor is
        generic(
            USE_SUBNORMAL : boolean;
            LATENCY       : natural
        );
        port(
            clk   : in std_logic;
            reset : in std_logic;
            cke   : in std_logic;
            
            sel : in std_logic_vector(1 downto 0);
            x   : in pfloat;
            
            y : out pfloat
        );
    end component;
    
    component fcomp_fmin_fmax is
        generic(
            USE_SUBNORMAL : boolean;
            LATENCY_1      : natural;
            LATENCY_2      : natural
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
    end component;
    
    function to_stdlogicvector(x : pfloat) return std_logic_vector;
    
    function to_unsigned(
        x    : pfloat;
        size : natural
    ) return unsigned;
end package;

package body pfloat_pkg is
    function to_pfloat(x : std_logic_vector(31 downto 0)) return pfloat is
    begin
        return (x(31), unsigned(x(30 downto 23)), unsigned(x(22 downto 0)));
    end function;
    
    function to_pfloat(
        x         : unsigned;
        SUBDIVIDE : positive := 1
    ) return pfloat is
        variable shift    : shift_t;
        variable exponent : natural;
        variable x_1      : unsigned(x'length-1 downto 0);
        variable fraction : unsigned(23 downto 0);
        variable y        : pfloat;
    begin
        shift := shift_calc(x, SUBDIVIDE);
        exponent := x'length+126-shift.i;
        
        if not(shift.valid) then
            y := ZERO;
        elsif (x'length+126 > 254) and (exponent > 254) then
            y := INFINITY;
        else
            x_1 := shift_left(x, shift.i);
            fraction := (others=> '0');
            fraction(23 downto maximum(24-x'length, 0)) := x_1(x'length-1 downto maximum(x'length-24, 0));
            y := ('0', to_unsigned(exponent, 8), fraction(22 downto 0));
        end if;
        
        return y;
    end function;
    
    function "-"(x : pfloat) return pfloat is
    begin
        return (not(x.sign), x.exponent, x.fraction);
    end function;
    
    function "abs"(x : pfloat) return pfloat is
    begin
        return ('0', x.exponent, x.fraction);
    end function;
    
    function copysign(
        x    : pfloat;
        sign : std_logic
    ) return pfloat is
    begin
        return (sign, x.exponent, x.fraction);
    end function;
    
    function or_reduce(x : std_logic_vector) return std_logic is
        variable i0 : boolean := true;
        variable y : std_logic := '0';
    begin
        for i in x'range loop
            if i0 = true then
                y := x(i);
                i0 := false;
            else
                y := y or x(i);
            end if;
        end loop;
        
        return y;
    end function;
    
    function or_reduce(x : signed) return std_logic is
    begin
        return or_reduce(std_logic_vector(x));
    end function;
    
    function or_reduce(x : unsigned) return std_logic is
    begin
        return or_reduce(std_logic_vector(x));
    end function;
    
    function and_reduce(x : std_logic_vector) return std_logic is
        variable i0 : boolean := true;
        variable y : std_logic := '1';
    begin
        for i in x'range loop
            if i0 = true then
                y := x(i);
                i0 := false;
            else
                y := y and x(i);
            end if;
        end loop;
        
        return y;
    end function;
    
    function and_reduce(x : signed) return std_logic is
    begin
        return and_reduce(std_logic_vector(x));
    end function;
    
    function and_reduce(x : unsigned) return std_logic is
    begin
        return and_reduce(std_logic_vector(x));
    end function;
    
    function to_pfloat_c(
        x : pfloat;
        USE_SUBNORMAL : boolean
    ) return pfloat_c is
        variable x_c : pfloat_c;
    begin
        x_c.exponent_or_reduce  := or_reduce(x.exponent);
        x_c.exponent_and_reduce := and_reduce(x.exponent);
        x_c.fraction_or_reduce  := or_reduce(x.fraction);
        
        if USE_SUBNORMAL then
            x_c.zero      := (x_c.exponent_or_reduce = '0') and (x_c.fraction_or_reduce = '0');
            x_c.subnormal := (x_c.exponent_or_reduce = '0') and (x_c.fraction_or_reduce = '1');
        else
            x_c.zero      := x_c.exponent_or_reduce = '0';
            x_c.subnormal := false;
        end if;
        x_c.normal        := (x_c.exponent_or_reduce = '1') and (x_c.exponent_and_reduce = '0');
        x_c.infinity      := (x_c.exponent_and_reduce = '1') and (x_c.fraction_or_reduce = '0');
        x_c.nan           := (x_c.exponent_and_reduce = '1') and (x_c.fraction_or_reduce = '1');
        
        return x_c;
    end function;
    
    function minimum(x1, x2 : integer) return integer is
    begin
        if x1 < x2 then
            return x1;
        else
            return x2;
        end if;
    end function;
    
    function maximum(x1, x2 : integer) return integer is
    begin
        if x1 < x2 then
            return x2;
        else
            return x1;
        end if;
    end function;
    
    function add_sub_f(
        x1  : unsigned;
        x2  : unsigned;
        sel : std_logic;
        mul : std_logic := '1'
    ) return unsigned is
        constant x_length : natural := maximum(x1'length, x2'length);
        
        variable aux1 : unsigned(x_length-1 downto 0);
        variable aux2 : unsigned(x_length-1 downto 0);
        variable y_1  : unsigned(x_length+1 downto 0);
        variable y    : unsigned(x_length downto 0);
    begin
        aux1 := (others=> mul);
        aux2 := (others=> sel);
        y_1 := ('0'&resize(x1, x_length)&sel)+('0'&((resize(x2, x_length) and aux1) xor aux2)&sel);
        y := y_1(x_length+1 downto 1);
        return y;
    end function;
    
    function shift_calc_aux3(
        x : unsigned;
        i : natural
    ) return natural is
        alias x_1 : unsigned(x'length-1 downto 0) is x;
    begin
        if (x'length = 1) or (x_1(x'length-1) = '1') then
            return i;
        else
            return shift_calc_aux3(x_1(x'length-2 downto 0), i+1);
        end if;
    end function;
    
    function shift_calc_aux2(
        x : unsigned;
        i : natural
    ) return shift_t is
        variable valid : boolean;
    begin
        valid := (or_reduce(x) = '1');
        
        if x'length = 0 then
            return (i, valid);
        else
            return (shift_calc_aux3(x, i), valid);
        end if;
    end function;
    
    function shift_calc_aux1(x : shift_array_t) return shift_t is
        alias x_1 : shift_array_t(x'length-1 downto 0) is x;
    begin
        if (x'length = 1) or x_1(x'length-1).valid then
            return x_1(x'length-1);
        else
            return shift_calc_aux1(x_1(x'length-2 downto 0));
        end if;
    end function;
    
    function shift_calc(
        x         : unsigned;
        SUBDIVIDE : positive := 1
    ) return shift_t is
        alias    x_1 : unsigned(x'length-1 downto 0) is x;
        variable sa  : shift_array_t(SUBDIVIDE-1 downto 0);
    begin
        for i in 0 to SUBDIVIDE-1 loop
            sa(SUBDIVIDE-1-i) := shift_calc_aux2(x_1(x'length-1-integer(round(real(x'length)/real(SUBDIVIDE)*real(i))) downto
                                                     x'length-integer(round(real(x'length)/real(SUBDIVIDE)*real(i+1)))),
                                                 integer(round(real(x'length)/real(SUBDIVIDE)*real(i))));
        end loop;
        
        return shift_calc_aux1(sa);
    end function;
    
    function check_round(
        ROUND_STYLE : float_round_style;
        sign        : std_logic;
        x           : unsigned
    ) return std_logic is
        alias x_1 : unsigned(x'length-1 downto 0) is x;
    begin
        case ROUND_STYLE is
        when round_toward_zero=>
            return '0';
        when round_to_nearest=>
            return (x_1(x'length-2) and or_reduce(x_1(x'length-3 downto 0))) or (x_1(x'length-1) and x_1(x'length-2));
        when round_toward_infinity=>
            return not(sign) and or_reduce(x_1(x'length-2 downto 0));
        when round_toward_neg_infinity=>
            return sign and or_reduce(x_1(x'length-2 downto 0));
        end case;
    end function;
    
    function to_pfloat(
        sign     : std_logic;
        exponent : signed(9 downto 0);
        fraction : unsigned;
        shift    : natural;
        
        ROUND_STYLE : float_round_style;
        round       : std_logic;
        sticky      : std_logic;
        
        iszero : boolean;
        isinf  : boolean;
        
        USE_SUBNORMAL : boolean
    ) return pfloat is
        variable exponent_1 : signed(9 downto 0);
        variable fraction_1 : unsigned(fraction'length downto 0);
        variable cr         : unsigned(0 downto 0);
    begin
        exponent_1 := exponent-shift;
        
        if USE_SUBNORMAL then
            fraction_1 := '0'&(fraction sll shift+minimum(to_integer(exponent_1), 0));
        else
            fraction_1 := '0'&shift_left(fraction, shift);
        end if;
        
        cr(0) := check_round(ROUND_STYLE, sign, fraction_1(fraction'length-24 downto 0)&round&sticky);
        fraction_1(fraction'length downto fraction'length-24) := fraction_1(fraction'length downto fraction'length-24)+cr;
        exponent_1 := exponent_1+signed('0'&fraction_1(fraction'length downto fraction'length));
        
        if iszero or (exponent_1(9) = '1') or (or_reduce(exponent_1(8 downto 0)) = '0') then
            if USE_SUBNORMAL then -- FP_ZERO or FP_SUBNORMAL
                return (sign, (others=> '0'), fraction_1(fraction'length-1 downto fraction'length-23));
            else -- FP_ZERO
                return copysign(ZERO, sign);
            end if;
        elsif isinf or (exponent_1(8) = '1') or (and_reduce(exponent_1(7 downto 0)) = '1') then -- FP_INFINITY
            return copysign(INFINITY, sign);
        else -- FP_NORMAL
            return (sign, unsigned(exponent_1(7 downto 0)), fraction_1(fraction'length-2 downto fraction'length-24));
        end if;
    end function;
    
    function to_stdlogicvector(x : pfloat) return std_logic_vector is
    begin
        return x.sign&std_logic_vector(x.exponent&x.fraction);
    end function;
    
    function to_unsigned(
        x    : pfloat;
        size : natural
    ) return unsigned is
        variable x_c      : pfloat_c;
        variable bias     : natural;
        variable y        : unsigned(size-1 downto 0);
        variable fraction : unsigned(23 downto 0);
    begin
        x_c := to_pfloat_c(x, false);
        bias := size+126;
        
        if x_c.nan or (x.sign = '1') then
            y := (others=> '0');
        elsif x_c.infinity or ((bias < 254) and (bias < x.exponent)) then
            y := (others=> '1');
        else
            fraction := '1'&x.fraction;
            y := (others=> '0');
            y(size-1 downto maximum(size-24, 0)) := fraction(23 downto maximum(24-size, 0));
            y := shift_right(y, to_integer(bias-x.exponent));
        end if;
        
        return y;
    end function;
end package body;