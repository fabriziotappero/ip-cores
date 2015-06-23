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
use work.core_pkg.all;

entity core is
    generic(
        USE_SUBNORMAL       : boolean           := false;
        ROUND_STYLE         : float_round_style := round_to_nearest;
        DEDICATED_REGISTERS : boolean           := false;
        LATENCY_1           : boolean           := false;
        FADD_LATENCY        : natural           := 2;
        EMBEDDED_MULTIPLIER : boolean           := true;
        FMUL_LATENCY        : natural           := 2;
        FDIV_LATENCY        : natural           := 14;
        FCOMP_LATENCY       : natural           := 0
    );
    port(
        clk   : in std_logic;
        reset : in std_logic;
        cke   : in std_logic;
        
        pc          : buffer unsigned(31 downto 0);
        instruction : in     std_logic_vector(31 downto 0);
        
        address   : out    unsigned(31 downto 0);
        read      : buffer std_logic;
        readdata  : in     std_logic_vector(31 downto 0);
        write     : buffer std_logic;
        writedata : out    std_logic_vector(31 downto 0);
        
        stop_core : out std_logic;
        irq       : out std_logic
    );
end entity;

architecture rtl of core is
    function to_integer(x : boolean) return integer is
    begin
        if x then
            return 1;
        else
            return 0;
        end if;
    end function;
    
    constant INSTRUCTION_1_LATENCY : natural := maximum(maximum(to_integer(LATENCY_1), FADD_LATENCY),
                                                        maximum(maximum(FMUL_LATENCY, FDIV_LATENCY), FCOMP_LATENCY));
    
    type instruction_1_t is array(0 to INSTRUCTION_1_LATENCY) of std_logic_vector(31 downto 0);
    type condition_t     is array(0 to INSTRUCTION_1_LATENCY) of std_logic;
    type k_t             is array(0 to 7)                     of std_logic_vector(31 downto 0);
    type ie_t            is array(0 to INSTRUCTION_1_LATENCY) of std_logic_vector(31 downto 0);
    
    signal instruction_1 : instruction_1_t;
    signal cr            : std_logic_vector(7 downto 0);
    signal ie            : ie_t;
    
    signal k : k_t := (to_stdlogicvector(-INFINITY),             -- -inf
                       '1'&"01111111"&"00000000000000000000000", -- -1
                       to_stdlogicvector(ZERO),                  -- 0
                       '0'&"01111111"&"00000000000000000000000", -- 1
                       '0'&"10000000"&"01011011111100001010100", -- e
                       '0'&"10000000"&"10010010000111111011011", -- pi
                       to_stdlogicvector(INFINITY),              -- inf
                       to_stdlogicvector(NAN));                  -- nan
    
    signal dataa_1 : std_logic_vector(31 downto 0);
    signal dataa   : std_logic_vector(31 downto 0);
    signal datab   : std_logic_vector(31 downto 0);
    signal addrc_1 : unsigned(4 downto 0);
    signal wec_1   : std_logic;
    signal datac_1 : std_logic_vector(31 downto 0);
    
    signal ploadfu_l                    : std_logic_vector(15 downto 0);
    signal fmulp2_datac                 : pfloat;
    signal fadd_fsub_datac              : pfloat;
    signal fmul_datac                   : pfloat;
    signal fdiv_datac                   : pfloat;
    signal a_l_b                        : std_logic;
    signal a_le_b                       : std_logic;
    signal a_e_b                        : std_logic;
    signal a_ge_b                       : std_logic;
    signal a_g_b                        : std_logic;
    signal a_ne_b                       : std_logic;
    signal ordered                      : std_logic;
    signal unordered                    : std_logic;
    signal fmin_fmax_datac              : pfloat;
    signal trunc_round_ceil_floor_datac : pfloat;
    signal address_1                    : unsigned(31 downto 0);
    
    signal addrc : addrc_t(0 to 16);
    signal wec   : std_logic_vector(0 to 16);
    signal datac : datac_t(0 to 16);
    
    signal pc_1 : unsigned(31 downto 0);
begin
    -- instruction enable matrix
    process(clk, cke, reset,
            instruction,
            instruction_1, cr, ie)
        variable decoder : std_logic_vector(31 downto 0);
        variable ie_1    : std_logic_vector(31 downto 0);
    begin
        decoder := (others=> '0');
        decoder(to_integer(unsigned(instruction(31 downto 27)))) := '1';
        ie_1 := (others=> (not(instruction(26)) or (instruction(25) xor cr(to_integer(unsigned(instruction(24 downto 22)))))));
        ie(0) <= decoder and ie_1;
        instruction_1(0) <= instruction;
        
        for i in 1 to INSTRUCTION_1_LATENCY loop
            if reset = '1' then
                ie(i) <= (others=> '0');
                instruction_1(i) <= (others=> '0');
            elsif rising_edge(clk) and (cke = '1') then
                ie(i) <= ie(i-1);
                instruction_1(i) <= instruction_1(i-1);
            end if;
        end loop;
    end process;
    
    -- registers
    u0 : registers
    generic map(
        ADDR_WIDTH=> 5,
        DATA_WIDTH=> 32,
        USE_RESET=>  DEDICATED_REGISTERS
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        addra=> unsigned(instruction_1(0)(20 downto 16)),
        dataa=> dataa_1,
        
        addrb=> unsigned(instruction_1(0)(9 downto 5)),
        datab=> datab,
        
        addrc=> addrc_1,
        wec=>   wec_1,
        datac=> datac_1
    );
    
    -- dataa may be a register or a constant
    process(instruction_1,
            k,
            dataa_1)
    begin
        case instruction_1(0)(21) is
        when '0'=>
            dataa <= k(to_integer(unsigned(instruction_1(0)(18 downto 16))));
        when '1'=>
            dataa <= dataa_1;
        when others=>
        end case;
    end process;
    
    -- ploadf_l, loadf_h, ploadu_l, loadu_h, ploadaddr_l, loadaddr_h
    addrc(0) <= unsigned(instruction_1(0)(4 downto 0));
    wec(0) <= ie(0)(2#00001#) and instruction_1(0)(5);
    datac(0) <= instruction_1(0)(21 downto 6)&ploadfu_l;
    process(clk, reset, cke,
            instruction_1, ie,
            datab)
    begin
        if reset = '1' then
            ploadfu_l <= (others=> '0');
        elsif rising_edge(clk) and (cke = '1') and (ie(0)(2#00001#) = '1') and (instruction_1(0)(5) = '0') then
            ploadfu_l <= instruction_1(0)(21 downto 6);
        end if;
    end process;
    
    -- copy, fabs, fneg, fnabs
    addrc(1) <= unsigned(instruction_1(0)(4 downto 0));
    wec(1) <= ie(0)(2#00010#);
    process(instruction_1,
            dataa)
    begin
        case instruction_1(0)(11 downto 10) is
        when "00"=>
            datac(1) <= dataa;
        when "01"=>
            datac(1) <= to_stdlogicvector(abs(to_pfloat(dataa)));
        when "10"=>
            datac(1) <= to_stdlogicvector(-to_pfloat(dataa));
        when "11"=>
            datac(1) <= to_stdlogicvector(-abs(to_pfloat(dataa)));
        when others=>
        end case;
    end process;
    
    -- fmulp2
    addrc(2) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(2) <= ie(to_integer(LATENCY_1))(2#00011#);
    datac(2) <= to_stdlogicvector(fmulp2_datac);
    u2 : fmulp2
    generic map(
        USE_SUBNORMAL=> USE_SUBNORMAL,
        LATENCY=>       to_integer(LATENCY_1)
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        x1=>        to_pfloat(dataa),
        exponent2=> signed(instruction_1(0)(13 downto 5)),
        
        y=> fmulp2_datac
    );
    
    -- fadd, fsub
    addrc(3) <= unsigned(instruction_1(FADD_LATENCY)(4 downto 0));
    wec(3) <= ie(FADD_LATENCY)(2#00100#);
    datac(3) <= to_stdlogicvector(fadd_fsub_datac);
    u3 : fadd_fsub
    generic map(
        USE_SUBNORMAL=> USE_SUBNORMAL,
        ROUND_STYLE=>   ROUND_STYLE,
        LATENCY=>       FADD_LATENCY
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        sel=> instruction_1(0)(10),
        x1=>  to_pfloat(dataa),
        x2=>  to_pfloat(datab),
        
        y=> fadd_fsub_datac
    );
    
    -- fmul
    addrc(4) <= unsigned(instruction_1(FMUL_LATENCY)(4 downto 0));
    wec(4) <= ie(FMUL_LATENCY)(2#00101#);
    datac(4) <= to_stdlogicvector(fmul_datac);
    u4 : fmul
    generic map(
        USE_SUBNORMAL=>       USE_SUBNORMAL,
        ROUND_STYLE=>         ROUND_STYLE,
        LATENCY=>             FMUL_LATENCY,
        EMBEDDED_MULTIPLIER=> EMBEDDED_MULTIPLIER
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        x1=> to_pfloat(dataa),
        x2=> to_pfloat(datab),
        
        y=> fmul_datac
    );
    
    -- fdiv
    addrc(5) <= unsigned(instruction_1(FDIV_LATENCY)(4 downto 0));
    wec(5) <= ie(FDIV_LATENCY)(2#00110#);
    datac(5) <= to_stdlogicvector(fdiv_datac);
    u5 : fdiv
    generic map(
        USE_SUBNORMAL=> USE_SUBNORMAL,
        ROUND_STYLE=>   ROUND_STYLE,
        LATENCY=>       FDIV_LATENCY
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        x1=> to_pfloat(dataa),
        x2=> to_pfloat(datab),
        
        y=> fdiv_datac
    );
    
    -- fcomp_l, fcomp_le, fcomp_e, fcomp_ge, fcomp_g, fcomp_ne, fcomp_o, fcomp_u, fmin, fmax
    addrc(6) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(6) <= ie(to_integer(LATENCY_1))(2#00111#);
    datac(6) <= to_stdlogicvector(fmin_fmax_datac);
    u6 : fcomp_fmin_fmax
    generic map(
        USE_SUBNORMAL=> USE_SUBNORMAL,
        LATENCY_1=>     FCOMP_LATENCY,
        LATENCY_2=>     to_integer(LATENCY_1)
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        x1=> to_pfloat(dataa),
        x2=> to_pfloat(datab),
        
        sel=> instruction_1(0)(10),
        
        x1_l_x2=>   a_l_b,
        x1_le_x2=>  a_le_b,
        x1_e_x2=>   a_e_b,
        x1_ge_x2=>  a_ge_b,
        x1_g_x2=>   a_g_b,
        x1_ne_x2=>  a_ne_b,
        ordered=>   ordered,
        unordered=> unordered,
        
        y=> fmin_fmax_datac
    );
    
    -- trunc, round, ceil, floor
    addrc(7) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(7) <= ie(to_integer(LATENCY_1))(2#01000#);
    datac(7) <= to_stdlogicvector(trunc_round_ceil_floor_datac);
    u7 : trunc_round_ceil_floor
    generic map(
        USE_SUBNORMAL=> USE_SUBNORMAL,
        LATENCY=>       to_integer(LATENCY_1)
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        sel=> instruction_1(0)(11 downto 10),
        x=>   to_pfloat(dataa),
        
        y=> trunc_round_ceil_floor_datac
    );
    
    -- ftou8_ll, ftou8_lh, ftou8_hl, ftou8_hh
    addrc(8) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(8) <= ie(to_integer(LATENCY_1))(2#01001#);
    u8 : ftou8
    generic map(
        DATAC_REG=> LATENCY_1
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        dataa=>       dataa,
        ll_lh_hl_hh=> instruction_1(0)(11 downto 10),
        datab=>       datab,
        
        datac=> datac(8)
    );
    
    -- u16tof_l, u16tof_h
    addrc(9) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(9) <= ie(to_integer(LATENCY_1))(2#01010#);
    u9 : ftou16
    generic map(
        DATAC_REG=> LATENCY_1
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        dataa=> dataa,
        l_h=>   instruction_1(0)(10),
        datab=> datab,
        
        datac=> datac(9)
    );
    
    -- ftou32
    addrc(10) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(10) <= ie(to_integer(LATENCY_1))(2#01011#);
    u10 : ftou32
    generic map(
        DATAC_REG=> LATENCY_1
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        dataa=> dataa,
        datac=> datac(10)
    );
    
    -- u8tof_ll, u8tof_lh, u8tof_hl, u8tof_hh
    addrc(11) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(11) <= ie(to_integer(LATENCY_1))(2#01100#);
    u11 : u8tof
    generic map(
        DATAC_REG=> LATENCY_1
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        ll_lh_hl_hh=> instruction_1(0)(11 downto 10),
        datab=>       datab,
        
        datac=> datac(11)
    );
    
    -- u16tof_l, u16tof_h
    addrc(12) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(12) <= ie(to_integer(LATENCY_1))(2#01101#);
    u12 : u16tof
    generic map(
        DATAC_REG=> LATENCY_1
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        l_h=>   instruction_1(0)(10),
        datab=> datab,
        
        datac=> datac(12)
    );
    
    -- u32tof
    addrc(13) <= unsigned(instruction_1(to_integer(LATENCY_1))(4 downto 0));
    wec(13) <= ie(to_integer(LATENCY_1))(2#01110#);
    u13 : u32tof
    generic map(
        DATAC_REG=> LATENCY_1
    )
    port map(
        clk=>   clk,
        reset=> reset,
        cke=>   cke,
        
        datab=> datab,
        datac=> datac(13)
    );
    
    -- fcomp_l, fcomp_le, fcomp_e, fcomp_ge, fcomp_g, fcomp_ne, fcomp_o, fcomp_u
    process(clk, reset, cke,
            instruction_1, ie,
            a_l_b, a_le_b, a_e_b, a_ge_b, a_g_b, a_ne_b, ordered, unordered)
        variable comp : std_logic;
    begin
        case instruction_1(FCOMP_LATENCY)(12 downto 10) is
        when "000"=>
            comp := a_l_b;
        when "001"=>
            comp := a_le_b;
        when "010"=>
            comp := a_e_b;
        when "011"=>
            comp := a_ge_b;
        when "100"=>
            comp := a_g_b;
        when "101"=>
            comp := a_ne_b;
        when "110"=>
            comp := ordered;
        when "111"=>
            comp := unordered;
        when others=>
        end case;
        
        if reset = '1' then
            cr <= (others=> '0');
        elsif rising_edge(clk) and (cke = '1') and (ie(FCOMP_LATENCY)(2#01111#) = '1') then
            cr(to_integer(unsigned(instruction_1(FCOMP_LATENCY)(2 downto 0)))) <= comp;
        end if;
    end process;
    
    -- add
    addrc(14) <= unsigned(instruction_1(0)(4 downto 0));
    wec(14) <= ie(0)(2#10000#);
    datac(14) <= std_logic_vector(unsigned(dataa)+unsigned(datab));
    
    -- load_addr
    addrc(15) <= unsigned(instruction_1(0)(4 downto 0));
    wec(15) <= ie(0)(2#10001#);
    datac(15) <= std_logic_vector(address_1);
    
    -- store_addr, d_load, i_load, pop, load, load_d, load_i, d_store, i_store, store, store_d, push, store_i, rcall, call, ret
    addrc(16) <= unsigned(instruction_1(0)(4 downto 0));
    wec(16) <= ie(0)(2#10011#);
    datac(16) <= readdata;
    process(clk, reset, cke,
            pc,
            read, write,
            instruction_1, ie,
            dataa, datab,
            address_1)
        variable address_2 : unsigned(31 downto 0);
    begin
        case instruction_1(0)(11) is
        when '0'=>
            address_2 := unsigned(datab);
        when '1'=>
            address_2 := add_sub_f(address_1, to_unsigned(4, 32), instruction_1(0)(10))(31 downto 0);
        when others=>
        end case;
        
        if reset = '1' then
            address_1 <= (others=> '0');
        elsif rising_edge(clk) and (cke = '1') and ((ie(0)(2#10010#) = '1') or (read = '1') or (write = '1')) then
            address_1 <= address_2;
        end if;
        
        case instruction_1(0)(12) is
        when '0'=>
            address <= address_2;
        when '1'=>
            address <= address_1;
        when others=>
        end case;
        
        read <= ie(0)(2#10011#) or ie(0)(2#10111#);
        write <= ie(0)(2#10100#) or ((ie(0)(2#10101#) or ie(0)(2#10110#)) and instruction_1(0)(13));
        
        if ie(0)(2#10100#) = '1' then
            writedata <= dataa;
        else
            writedata <= std_logic_vector(pc);
        end if;
    end process;
    
    -- jump, rcall, goto, call, ret
    process(clk, cke, reset,
            pc,
            instruction_1,
            ie,
            pc_1)
        variable k   : std_logic_vector(17 downto 0);
        variable pck : signed(32 downto 0);
    begin
        k := instruction_1(0)(21 downto 14)&instruction_1(0)(9 downto 0);
        pck := signed('0'&pc_1)+signed(k);
        
        if reset = '1' then
            pc <= (others=> '0');
        elsif rising_edge(clk) and (cke = '1') then
            if ie(0)(2#10101#) = '1' then    -- jump, rcall
                pc <= unsigned(pck(31 downto 0));
            elsif ie(0)(2#10110#) = '1' then -- goto, call
                pc <= unsigned(datab);
            elsif ie(0)(2#10111#) = '1' then -- ret
                pc <= unsigned(readdata);
            else
                pc <= pc+1;
            end if;
        end if;
        
        if reset = '1' then
            pc_1 <= (others=> '0');
        elsif rising_edge(clk) and (cke = '1') then
            pc_1 <= pc;
        end if;
    end process;
    
    -- stop_core, irq
    stop_core <= ie(0)(2#11000#);
    irq <= ie(0)(2#11001#);
    
    -- tristate bridge
    u14 : portc_tristate_bridge
    generic map(
        PORTS=> 17
    )
    port map(
        iaddrc=> addrc,
        iwec=>   wec,
        idatac=> datac,
        
        oaddrc=> addrc_1,
        owec=>   wec_1,
        odatac=> datac_1
    );
end architecture;