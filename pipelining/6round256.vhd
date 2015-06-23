
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/09/2008
-- Project Name:  camellia-vhdl
-- Description:   Six rounds of F, for 128/192/256-bit key en/decryption
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


entity SIXROUND256 is
    generic (
            k1e128_offset  : INTEGER; -- encryption 128bit
            k1e128_shift   : INTEGER;
            k2e128_offset  : INTEGER;
            k2e128_shift   : INTEGER;
            k3e128_offset  : INTEGER;
            k3e128_shift   : INTEGER;
            k4e128_offset  : INTEGER;
            k4e128_shift   : INTEGER;
            k5e128_offset  : INTEGER;
            k5e128_shift   : INTEGER;
            k6e128_offset  : INTEGER;
            k6e128_shift   : INTEGER;
            k1d128_offset  : INTEGER; -- decryption 128bit
            k1d128_shift   : INTEGER;
            k2d128_offset  : INTEGER;
            k2d128_shift   : INTEGER;
            k3d128_offset  : INTEGER;
            k3d128_shift   : INTEGER;
            k4d128_offset  : INTEGER;
            k4d128_shift   : INTEGER;
            k5d128_offset  : INTEGER;
            k5d128_shift   : INTEGER;
            k6d128_offset  : INTEGER;
            k6d128_shift   : INTEGER;
            k1e256_offset  : INTEGER; -- encryption 192/256bit
            k1e256_shift   : INTEGER;
            k2e256_offset  : INTEGER;
            k2e256_shift   : INTEGER;
            k3e256_offset  : INTEGER;
            k3e256_shift   : INTEGER;
            k4e256_offset  : INTEGER;
            k4e256_shift   : INTEGER;
            k5e256_offset  : INTEGER;
            k5e256_shift   : INTEGER;
            k6e256_offset  : INTEGER;
            k6e256_shift   : INTEGER;
            k1d256_offset  : INTEGER; -- decryption 192/256bit
            k1d256_shift   : INTEGER;
            k2d256_offset  : INTEGER;
            k2d256_shift   : INTEGER;
            k3d256_offset  : INTEGER;
            k3d256_shift   : INTEGER;
            k4d256_offset  : INTEGER;
            k4d256_shift   : INTEGER;
            k5d256_offset  : INTEGER;
            k5d256_shift   : INTEGER;
            k6d256_offset  : INTEGER;
            k6d256_shift   : INTEGER
            );
    port(
            reset   : in  STD_LOGIC;
            clk     : in  STD_LOGIC;
            dec1    : in  STD_LOGIC;
            k_len1  : in  STD_LOGIC_VECTOR (0 to 1);
            k1      : in  STD_LOGIC_VECTOR (0 to 511);
            dec2    : in  STD_LOGIC;
            k_len2  : in  STD_LOGIC_VECTOR (0 to 1);
            k2      : in  STD_LOGIC_VECTOR (0 to 511);
            dec3    : in  STD_LOGIC;
            k_len3  : in  STD_LOGIC_VECTOR (0 to 1);
            k3      : in  STD_LOGIC_VECTOR (0 to 511);
            dec4    : in  STD_LOGIC;
            k_len4  : in  STD_LOGIC_VECTOR (0 to 1);
            k4      : in  STD_LOGIC_VECTOR (0 to 511);
            dec5    : in  STD_LOGIC;
            k_len5  : in  STD_LOGIC_VECTOR (0 to 1);
            k5      : in  STD_LOGIC_VECTOR (0 to 511);
            dec6    : in  STD_LOGIC;
            k_len6  : in  STD_LOGIC_VECTOR (0 to 1);
            k6      : in  STD_LOGIC_VECTOR (0 to 511);
            l_in    : in  STD_LOGIC_VECTOR (0 to 63);
            r_in    : in  STD_LOGIC_VECTOR (0 to 63);
            l_out   : out STD_LOGIC_VECTOR (0 to 63);
            r_out   : out STD_LOGIC_VECTOR (0 to 63)
            );
end SIXROUND256;

architecture RTL of SIXROUND256 is

    component F is
        port    (
                reset : in STD_LOGIC;
                clk   : in STD_LOGIC;
                x     : in STD_LOGIC_VECTOR (0 to 63);
                k     : in STD_LOGIC_VECTOR (0 to 63);
                z     : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;

    -- subkeys
    signal t1_enc128 : STD_LOGIC_VECTOR (0 to 127);
    signal t2_enc128 : STD_LOGIC_VECTOR (0 to 127);
    signal t3_enc128 : STD_LOGIC_VECTOR (0 to 127);
    signal t4_enc128 : STD_LOGIC_VECTOR (0 to 127);
    signal t5_enc128 : STD_LOGIC_VECTOR (0 to 127);
    signal t6_enc128 : STD_LOGIC_VECTOR (0 to 127);
    signal t1_dec128 : STD_LOGIC_VECTOR (0 to 127);
    signal t2_dec128 : STD_LOGIC_VECTOR (0 to 127);
    signal t3_dec128 : STD_LOGIC_VECTOR (0 to 127);
    signal t4_dec128 : STD_LOGIC_VECTOR (0 to 127);
    signal t5_dec128 : STD_LOGIC_VECTOR (0 to 127);
    signal t6_dec128 : STD_LOGIC_VECTOR (0 to 127);
    signal t1_enc256 : STD_LOGIC_VECTOR (0 to 127);
    signal t2_enc256 : STD_LOGIC_VECTOR (0 to 127);
    signal t3_enc256 : STD_LOGIC_VECTOR (0 to 127);
    signal t4_enc256 : STD_LOGIC_VECTOR (0 to 127);
    signal t5_enc256 : STD_LOGIC_VECTOR (0 to 127);
    signal t6_enc256 : STD_LOGIC_VECTOR (0 to 127);
    signal t1_dec256 : STD_LOGIC_VECTOR (0 to 127);
    signal t2_dec256 : STD_LOGIC_VECTOR (0 to 127);
    signal t3_dec256 : STD_LOGIC_VECTOR (0 to 127);
    signal t4_dec256 : STD_LOGIC_VECTOR (0 to 127);
    signal t5_dec256 : STD_LOGIC_VECTOR (0 to 127);
    signal t6_dec256 : STD_LOGIC_VECTOR (0 to 127);
    signal int_k1     : STD_LOGIC_VECTOR (0 to 63);
    signal int_k2     : STD_LOGIC_VECTOR (0 to 63);
    signal int_k3     : STD_LOGIC_VECTOR (0 to 63);
    signal int_k4     : STD_LOGIC_VECTOR (0 to 63);
    signal int_k5     : STD_LOGIC_VECTOR (0 to 63);
    signal int_k6     : STD_LOGIC_VECTOR (0 to 63);

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
    signal reg1_l : STD_LOGIC_VECTOR (0 to 63);
    signal reg1_r : STD_LOGIC_VECTOR (0 to 63);
    signal reg2_l : STD_LOGIC_VECTOR (0 to 63);
    signal reg2_r : STD_LOGIC_VECTOR (0 to 63);
    signal reg3_l : STD_LOGIC_VECTOR (0 to 63);
    signal reg3_r : STD_LOGIC_VECTOR (0 to 63);
    signal reg4_l : STD_LOGIC_VECTOR (0 to 63);
    signal reg4_r : STD_LOGIC_VECTOR (0 to 63);
    signal reg5_l : STD_LOGIC_VECTOR (0 to 63);
    signal reg5_r : STD_LOGIC_VECTOR (0 to 63);
    signal reg6_l : STD_LOGIC_VECTOR (0 to 63);
    signal reg6_r : STD_LOGIC_VECTOR (0 to 63);

begin

    -- shift of kl, kr, ka, kb
    t1_enc128 <= k1(k1e128_offset+k1e128_shift to k1e128_offset+127) &
                k1(k1e128_offset to k1e128_offset+k1e128_shift-1);
    t2_enc128 <= k2(k2e128_offset+k2e128_shift to k2e128_offset+127) &
                k2(k2e128_offset to k2e128_offset+k2e128_shift-1);
    t3_enc128 <= k3(k3e128_offset+k3e128_shift to k3e128_offset+127) &
                k3(k3e128_offset to k3e128_offset+k3e128_shift-1);
    t4_enc128 <= k4(k4e128_offset+k4e128_shift to k4e128_offset+127) &
                k4(k4e128_offset to k4e128_offset+k4e128_shift-1);
    t5_enc128 <= k5(k5e128_offset+k5e128_shift to k5e128_offset+127) &
                k5(k5e128_offset to k5e128_offset+k5e128_shift-1);
    t6_enc128 <= k6(k6e128_offset+k6e128_shift to k6e128_offset+127) &
                k6(k6e128_offset to k6e128_offset+k6e128_shift-1);

    t1_dec128 <= k1(k1d128_offset+k1d128_shift to k1d128_offset+127) &
                k1(k1d128_offset to k1d128_offset+k1d128_shift-1);
    t2_dec128 <= k2(k2d128_offset+k2d128_shift to k2d128_offset+127) &
                k2(k2d128_offset to k2d128_offset+k2d128_shift-1);
    t3_dec128 <= k3(k3d128_offset+k3d128_shift to k3d128_offset+127) &
                k3(k3d128_offset to k3d128_offset+k3d128_shift-1);
    t4_dec128 <= k4(k4d128_offset+k4d128_shift to k4d128_offset+127) &
                k4(k4d128_offset to k4d128_offset+k4d128_shift-1);
    t5_dec128 <= k5(k5d128_offset+k5d128_shift to k5d128_offset+127) &
                k5(k5d128_offset to k5d128_offset+k5d128_shift-1);
    t6_dec128 <= k6(k6d128_offset+k6d128_shift to k6d128_offset+127) &
                k6(k6d128_offset to k6d128_offset+k6d128_shift-1);

    t1_enc256 <= k1(k1e256_offset+k1e256_shift to k1e256_offset+127) &
                k1(k1e256_offset to k1e256_offset+k1e256_shift-1);
    t2_enc256 <= k2(k2e256_offset+k2e256_shift to k2e256_offset+127) &
                k2(k2e256_offset to k2e256_offset+k2e256_shift-1);
    t3_enc256 <= k3(k3e256_offset+k3e256_shift to k3e256_offset+127) &
                k3(k3e256_offset to k3e256_offset+k3e256_shift-1);
    t4_enc256 <= k4(k4e256_offset+k4e256_shift to k4e256_offset+127) &
                k4(k4e256_offset to k4e256_offset+k4e256_shift-1);
    t5_enc256 <= k5(k5e256_offset+k5e256_shift to k5e256_offset+127) &
                k5(k5e256_offset to k5e256_offset+k5e256_shift-1);
    t6_enc256 <= k6(k6e256_offset+k6e256_shift to k6e256_offset+127) &
                k6(k6e256_offset to k6e256_offset+k6e256_shift-1);

    t1_dec256 <= k1(k1d256_offset+k1d256_shift to k1d256_offset+127) &
                k1(k1d256_offset to k1d256_offset+k1d256_shift-1);
    t2_dec256 <= k2(k2d256_offset+k2d256_shift to k2d256_offset+127) &
                k2(k2d256_offset to k2d256_offset+k2d256_shift-1);
    t3_dec256 <= k3(k3d256_offset+k3d256_shift to k3d256_offset+127) &
                k3(k3d256_offset to k3d256_offset+k3d256_shift-1);
    t4_dec256 <= k4(k4d256_offset+k4d256_shift to k4d256_offset+127) &
                k4(k4d256_offset to k4d256_offset+k4d256_shift-1);
    t5_dec256 <= k5(k5d256_offset+k5d256_shift to k5d256_offset+127) &
                k5(k5d256_offset to k5d256_offset+k5d256_shift-1);
    t6_dec256 <= k6(k6d256_offset+k6d256_shift to k6d256_offset+127) &
                k6(k6d256_offset to k6d256_offset+k6d256_shift-1);

    -- subkeys generation
    -- int_k1, int_k3, int_k5 get always the left/right slice when en/decrypting
    -- int_k2, int_k4, int_k6 get always the right/left slice when en/decrypting
    int_k1 <= t1_enc128(0 to 63)   when dec1='0' and k_len1(0)='0' else
              t1_dec128(64 to 127) when dec1='1' and k_len1(0)='0' else
              t1_enc256(0 to 63)   when dec1='0' and k_len1(0)='1' else
              t1_dec256(64 to 127);
    int_k2 <= t2_enc128(64 to 127) when dec2='0' and k_len2(0)='0' else
              t2_dec128(0 to 63)   when dec2='1' and k_len2(0)='0' else
              t2_enc256(64 to 127) when dec2='0' and k_len2(0)='1' else
              t2_dec256(0 to 63);
    int_k3 <= t3_enc128(0 to 63)   when dec3='0' and k_len3(0)='0' else
              t3_dec128(64 to 127) when dec3='1' and k_len3(0)='0' else
              t3_enc256(0 to 63)   when dec3='0' and k_len3(0)='1' else
              t3_dec256(64 to 127);
    int_k4 <= t4_enc128(64 to 127) when dec4='0' and k_len4(0)='0' else
              t4_dec128(0 to 63)   when dec4='1' and k_len4(0)='0' else
              t4_enc256(64 to 127) when dec4='0' and k_len4(0)='1' else
              t4_dec256(0 to 63);
    int_k5 <= t5_enc128(0 to 63)   when dec5='0' and k_len5(0)='0' else
              t5_dec128(64 to 127) when dec5='1' and k_len5(0)='0' else
              t5_enc256(0 to 63)   when dec5='0' and k_len5(0)='1' else
              t5_dec256(64 to 127);
    int_k6 <= t6_enc128(64 to 127) when dec6='0' and k_len6(0)='0' else
              t6_dec128(0 to 63)   when dec6='1' and k_len6(0)='0' else
              t6_enc256(64 to 127) when dec6='0' and k_len6(0)='1' else
              t6_dec256(0 to 63);

    -- f inputs
    f1_in <= l_in;
    f2_in <= f1_out xor reg1_r;
    f3_in <= f2_out xor reg2_r;
    f4_in <= f3_out xor reg3_r;
    f5_in <= f4_out xor reg4_r;
    f6_in <= f5_out xor reg5_r;

    F1  : F
        port map(reset, clk, f1_in, int_k1, f1_out);
    F2  : F
        port map(reset, clk, f2_in, int_k2, f2_out);
    F3  : F
        port map(reset, clk, f3_in, int_k3, f3_out);
    F4  : F
        port map(reset, clk, f4_in, int_k4, f4_out);
    F5  : F
        port map(reset, clk, f5_in, int_k5, f5_out);
    F6  : F
        port map(reset, clk, f6_in, int_k6, f6_out);


    REG : process(reset, clk)
    begin

        if (reset = '1') then
            reg1_l <= (others=>'0');
            reg1_r <= (others=>'0');
            reg2_l <= (others=>'0');
            reg2_r <= (others=>'0');
            reg3_l <= (others=>'0');
            reg3_r <= (others=>'0');
            reg4_l <= (others=>'0');
            reg4_r <= (others=>'0');
            reg5_l <= (others=>'0');
            reg5_r <= (others=>'0');
            reg6_l <= (others=>'0');
            reg6_r <= (others=>'0');
        else
            if (rising_edge(clk)) then -- rising clock edge
                reg1_l <= f1_in;
                reg1_r <= r_in;
                reg2_l <= f2_in;
                reg2_r <= reg1_l;
                reg3_l <= f3_in;
                reg3_r <= reg2_l;
                reg4_l <= f4_in;
                reg4_r <= reg3_l;
                reg5_l <= f5_in;
                reg5_r <= reg4_l;
                reg6_l <= f6_in;
                reg6_r <= reg5_l;
            end if;
        end if;
    end process;

    -- there isn't an output register
    l_out   <= f6_out xor reg6_r;
    r_out   <= reg6_l;

end RTL;
