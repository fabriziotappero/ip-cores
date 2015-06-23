
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/15/2007
-- Last Update:   04/09/2008
-- Project Name:  camellia-vhdl
-- Description:   Key schedule for 128/192/256-bit keys
--
-- Copyright (C) 2007  Paolo Fulgoni
-- This file is part of camellia-vhdl.
-- camellia-vhdl is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
-- camellia-vhdl is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- The Camellia cipher algorithm is 128 bit cipher developed by NTT and
-- Mitsubishi Electric researchers.
-- http://info.isl.ntt.co.jp/crypt/eng/camellia/
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;


entity KEYSCHED256 is
    port(
            reset  : in STD_LOGIC;
            clk    : in STD_LOGIC;
            kl_in  : in STD_LOGIC_VECTOR (0 to 127);
            kr_in  : in STD_LOGIC_VECTOR (0 to 127);
            kl_out : out STD_LOGIC_VECTOR (0 to 127);
            kr_out : out STD_LOGIC_VECTOR (0 to 127);
            ka_out : out STD_LOGIC_VECTOR (0 to 127);
            kb_out : out STD_LOGIC_VECTOR (0 to 127)
            );
end KEYSCHED256;

architecture RTL of KEYSCHED256 is

    component F is
        port    (
                reset : in STD_LOGIC;
                clk   : in STD_LOGIC;
                x     : in STD_LOGIC_VECTOR (0 to 63);
                k     : in STD_LOGIC_VECTOR (0 to 63);
                z     : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;

    -- f inputs
    signal f1_in  : STD_LOGIC_VECTOR (0 to 63);
    signal f2_in  : STD_LOGIC_VECTOR (0 to 63);
    signal f3_in  : STD_LOGIC_VECTOR (0 to 63);
    signal f4_in  : STD_LOGIC_VECTOR (0 to 63);
    signal f5_in  : STD_LOGIC_VECTOR (0 to 63);
    signal f6_in  : STD_LOGIC_VECTOR (0 to 63);

    -- f outputs
    signal f1_out : STD_LOGIC_VECTOR (0 to 63);
    signal f2_out : STD_LOGIC_VECTOR (0 to 63);
    signal f3_out : STD_LOGIC_VECTOR (0 to 63);
    signal f4_out : STD_LOGIC_VECTOR (0 to 63);
    signal f5_out : STD_LOGIC_VECTOR (0 to 63);
    signal f6_out : STD_LOGIC_VECTOR (0 to 63);

    -- intermediate registers
    signal reg1_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg1_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg1_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg1_kr : STD_LOGIC_VECTOR (0 to 127);
    signal reg2_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg2_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg2_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg2_kr : STD_LOGIC_VECTOR (0 to 127);
    signal reg3_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg3_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg3_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg3_kr : STD_LOGIC_VECTOR (0 to 127);
    signal reg4_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg4_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg4_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg4_kr : STD_LOGIC_VECTOR (0 to 127);
    signal reg5_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg5_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg5_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg5_kr : STD_LOGIC_VECTOR (0 to 127);
    signal reg5_ka : STD_LOGIC_VECTOR (0 to 127);
    signal reg6_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg6_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg6_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg6_kr : STD_LOGIC_VECTOR (0 to 127);
    signal reg6_ka : STD_LOGIC_VECTOR (0 to 127);

    -- constant keys
    constant k1 : STD_LOGIC_VECTOR (0 to 63) := X"A09E667F3BCC908B";
    constant k2 : STD_LOGIC_VECTOR (0 to 63) := X"B67AE8584CAA73B2";
    constant k3 : STD_LOGIC_VECTOR (0 to 63) := X"C6EF372FE94F82BE";
    constant k4 : STD_LOGIC_VECTOR (0 to 63) := X"54FF53A5F1D36F1C";
    constant k5 : STD_LOGIC_VECTOR (0 to 63) := X"10E527FADE682D1D";
    constant k6 : STD_LOGIC_VECTOR (0 to 63) := X"B05688C2B3E6C1FD";

    -- intermediate signals
    signal inter1  : STD_LOGIC_VECTOR (0 to 127);
    signal inter2  : STD_LOGIC_VECTOR (0 to 127);
    signal ka_tmp  : STD_LOGIC_VECTOR (0 to 127);

begin

    F1 : F
        port map(reset, clk, f1_in, k1, f1_out);
    F2 : F
        port map(reset, clk, f2_in, k2, f2_out);
    F3 : F
        port map(reset, clk, f3_in, k3, f3_out);
    F4 : F
        port map(reset, clk, f4_in, k4, f4_out);
    F5 : F
        port map(reset, clk, f5_in, k5, f5_out);
    F6 : F
        port map(reset, clk, f6_in, k6, f6_out);

    REG : process(reset, clk)
    begin

        if (reset = '1') then
            reg1_l  <= (others=>'0');
            reg1_r  <= (others=>'0');
            reg1_kl <= (others=>'0');
            reg1_kr <= (others=>'0');
            reg2_l  <= (others=>'0');
            reg2_r  <= (others=>'0');
            reg2_kl <= (others=>'0');
            reg2_kr <= (others=>'0');
            reg3_l  <= (others=>'0');
            reg3_r  <= (others=>'0');
            reg3_kl <= (others=>'0');
            reg3_kr <= (others=>'0');
            reg4_l  <= (others=>'0');
            reg4_r  <= (others=>'0');
            reg4_kl <= (others=>'0');
            reg4_kr <= (others=>'0');
            reg5_l  <= (others=>'0');
            reg5_r  <= (others=>'0');
            reg5_kl <= (others=>'0');
            reg5_kr <= (others=>'0');
            reg5_ka <= (others=>'0');
            reg6_l  <= (others=>'0');
            reg6_r  <= (others=>'0');
            reg6_kl <= (others=>'0');
            reg6_kr <= (others=>'0');
            reg6_ka <= (others=>'0');
        else
            if (rising_edge(clk)) then -- rising clock edge
                reg1_l  <= f1_in;
                reg1_r  <= kl_in(64 to 127) xor kr_in(64 to 127);
                reg1_kl <= kl_in;
                reg1_kr <= kr_in;
                reg2_l  <= f2_in;
                reg2_r  <= reg1_l;
                reg2_kl <= reg1_kl;
                reg2_kr <= reg1_kr;
                reg3_l  <= f3_in;
                reg3_r  <= inter1(64 to 127);
                reg3_kl <= reg2_kl;
                reg3_kr <= reg2_kr;
                reg4_l  <= f4_in;
                reg4_r  <= reg3_l;
                reg4_kl <= reg3_kl;
                reg4_kr <= reg3_kr;
                reg5_l  <= f5_in;
                reg5_r  <= inter2(64 to 127);
                reg5_kl <= reg4_kl;
                reg5_kr <= reg4_kr;
                reg5_ka <= ka_tmp;
                reg6_l  <= f6_in;
                reg6_r  <= reg5_l;
                reg6_kl <= reg5_kl;
                reg6_kr <= reg5_kr;
                reg6_ka <= reg5_ka;
            end if;
        end if;
    end process;

    inter1  <= ((f2_out xor reg2_r) & reg2_l) xor reg2_kl;
    ka_tmp <= (f4_out xor reg4_r) & reg4_l;
    inter2  <= ka_tmp xor reg4_kr;

    -- f inputs
    f1_in <= kl_in(0 to 63) xor kr_in(0 to 63);
    f2_in <= f1_out xor reg1_r;
    f3_in <= inter1(0 to 63);
    f4_in <= f3_out xor reg3_r;
    f5_in <= inter2(0 to 63);
    f6_in <= f5_out xor reg5_r;

    -- output
    kl_out <= reg6_kl;
    kr_out <= reg6_kr;
    ka_out <= reg6_ka;
    kb_out <= (f6_out xor reg6_r) & reg6_l;

end RTL;
