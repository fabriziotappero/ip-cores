
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/15/2007
-- Last Update:   06/23/2008
-- Project Name:  camellia-vhdl
-- Description:   Camellia top level module, for 128/192/256-bit keys
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
use IEEE.std_logic_unsigned.all;


entity CAMELLIA256 is
    port(
            reset      : in STD_LOGIC;
            clk        : in STD_LOGIC;
            input      : in STD_LOGIC_VECTOR (0 to 127);  -- input data
            input_en   : in  STD_LOGIC;                   -- input enable
            key        : in STD_LOGIC_VECTOR (0 to 255);  -- key
            key_len    : in STD_LOGIC_VECTOR (0 to 1);    -- key lenght
            enc_dec    : in STD_LOGIC;                    -- dec=0 enc, dec=1 dec
            output     : out STD_LOGIC_VECTOR (0 to 127); -- en/decrypted data
            output_rdy : out STD_LOGIC                    -- output ready
            );
end CAMELLIA256;

architecture RTL of CAMELLIA256 is

    component KEYSCHED256 is
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
    end component;

    component SIXROUND256 is
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
    end component;

    component FL256 is
        generic    (
                    fl_ke128_offset  : INTEGER; -- 128bit encryption
                    fl_ke128_shift   : INTEGER;
                    fli_ke128_offset : INTEGER;
                    fli_ke128_shift  : INTEGER;
                    fl_kd128_offset  : INTEGER; -- 128bit decryption
                    fl_kd128_shift   : INTEGER;
                    fli_kd128_offset : INTEGER;
                    fli_kd128_shift  : INTEGER;
                    fl_ke256_offset  : INTEGER; -- 192/256bit encryption
                    fl_ke256_shift   : INTEGER;
                    fli_ke256_offset : INTEGER;
                    fli_ke256_shift  : INTEGER;
                    fl_kd256_offset  : INTEGER; -- 192/256bit decryption
                    fl_kd256_shift   : INTEGER;
                    fli_kd256_offset : INTEGER;
                    fli_kd256_shift  : INTEGER
                    );
        port(
                reset   : in  STD_LOGIC;
                clk     : in  STD_LOGIC;
                fl_in   : in  STD_LOGIC_VECTOR (0 to 63);
                fli_in  : in  STD_LOGIC_VECTOR (0 to 63);
                k       : in  STD_LOGIC_VECTOR (0 to 511);
                k_len   : in  STD_LOGIC_VECTOR (0 to 1);
                dec     : in  STD_LOGIC;
                fl_out  : out STD_LOGIC_VECTOR (0 to 63);
                fli_out : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;


    -- input registers
    signal reg_m      : STD_LOGIC_VECTOR (0 to 127);
    signal reg_kl     : STD_LOGIC_VECTOR (0 to 127);
    signal reg_kr_int : STD_LOGIC_VECTOR (0 to 127);
    signal reg_k_len  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_dec    : STD_LOGIC;
    signal reg_rdy : STD_LOGIC;

    -- used by pre-whitening
    signal kw1_enc        : STD_LOGIC_VECTOR (0 to 63);
    signal kw2_enc        : STD_LOGIC_VECTOR (0 to 63);
    signal ka_s111_dec128 : STD_LOGIC_VECTOR (0 to 127);
    signal kw1_dec128     : STD_LOGIC_VECTOR (0 to 63);
    signal kw2_dec128     : STD_LOGIC_VECTOR (0 to 63);
    signal ka_s111_dec256 : STD_LOGIC_VECTOR (0 to 127);
    signal kw1_dec256     : STD_LOGIC_VECTOR (0 to 63);
    signal kw2_dec256     : STD_LOGIC_VECTOR (0 to 63);
    signal kw1            : STD_LOGIC_VECTOR (0 to 63);
    signal kw2            : STD_LOGIC_VECTOR (0 to 63);
    signal w1             : STD_LOGIC_VECTOR (0 to 63);
    signal w2             : STD_LOGIC_VECTOR (0 to 63);

    -- used by post-whitening
    signal ka_s111_enc128 : STD_LOGIC_VECTOR (0 to 127);
    signal kw3_enc128     : STD_LOGIC_VECTOR (0 to 63);
    signal kw4_enc128     : STD_LOGIC_VECTOR (0 to 63);
    signal ka_s111_enc256 : STD_LOGIC_VECTOR (0 to 127);
    signal kw3_enc256     : STD_LOGIC_VECTOR (0 to 63);
    signal kw4_enc256     : STD_LOGIC_VECTOR (0 to 63);
    signal kw3_dec        : STD_LOGIC_VECTOR (0 to 63);
    signal kw4_dec        : STD_LOGIC_VECTOR (0 to 63);
    signal kw3            : STD_LOGIC_VECTOR (0 to 63);
    signal kw4            : STD_LOGIC_VECTOR (0 to 63);
    signal w3             : STD_LOGIC_VECTOR (0 to 63);
    signal w4             : STD_LOGIC_VECTOR (0 to 63);

    -- registers used during key schedule
    signal reg_a1_m    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a1_dec  : STD_LOGIC;
    signal reg_a1_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_a1_rdy  : STD_LOGIC;
    signal reg_a2_m    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a2_dec  : STD_LOGIC;
    signal reg_a2_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_a2_rdy  : STD_LOGIC;
    signal reg_a3_m    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a3_dec  : STD_LOGIC;
    signal reg_a3_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_a3_rdy  : STD_LOGIC;
    signal reg_a4_m    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a4_dec  : STD_LOGIC;
    signal reg_a4_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_a4_rdy  : STD_LOGIC;
    signal reg_a5_m    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a5_dec  : STD_LOGIC;
    signal reg_a5_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_a5_rdy  : STD_LOGIC;
    signal reg_a6_m    : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a6_dec  : STD_LOGIC;
    signal reg_a6_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_a6_rdy  : STD_LOGIC;

    -- registers used during 6-rounds and fls
    signal reg_b1_dec   : STD_LOGIC;
    signal reg_b1_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b1_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b1_rdy   : STD_LOGIC;
    signal reg_b2_dec   : STD_LOGIC;
    signal reg_b2_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b2_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b2_rdy   : STD_LOGIC;
    signal reg_b3_dec   : STD_LOGIC;
    signal reg_b3_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b3_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b3_rdy   : STD_LOGIC;
    signal reg_b4_dec   : STD_LOGIC;
    signal reg_b4_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b4_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b4_rdy   : STD_LOGIC;
    signal reg_b5_dec   : STD_LOGIC;
    signal reg_b5_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b5_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b5_rdy   : STD_LOGIC;
    signal reg_b6_dec   : STD_LOGIC;
    signal reg_b6_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b6_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b6_rdy   : STD_LOGIC;
    signal reg_b7_dec   : STD_LOGIC;
    signal reg_b7_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b7_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b7_rdy   : STD_LOGIC;
    signal reg_b8_dec   : STD_LOGIC;
    signal reg_b8_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b8_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b8_rdy   : STD_LOGIC;
    signal reg_b9_dec   : STD_LOGIC;
    signal reg_b9_k     : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b9_klen  : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b9_rdy   : STD_LOGIC;
    signal reg_b10_dec  : STD_LOGIC;
    signal reg_b10_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b10_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b10_rdy  : STD_LOGIC;
    signal reg_b11_dec  : STD_LOGIC;
    signal reg_b11_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b11_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b11_rdy  : STD_LOGIC;
    signal reg_b12_dec  : STD_LOGIC;
    signal reg_b12_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b12_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b12_rdy  : STD_LOGIC;
    signal reg_b13_dec  : STD_LOGIC;
    signal reg_b13_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b13_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b13_rdy  : STD_LOGIC;
    signal reg_b14_dec  : STD_LOGIC;
    signal reg_b14_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b14_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b14_rdy  : STD_LOGIC;
    signal reg_b15_dec  : STD_LOGIC;
    signal reg_b15_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b15_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b15_rdy  : STD_LOGIC;
    signal reg_b16_dec  : STD_LOGIC;
    signal reg_b16_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b16_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b16_rdy  : STD_LOGIC;
    signal reg_b17_dec  : STD_LOGIC;
    signal reg_b17_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b17_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b17_rdy  : STD_LOGIC;
    signal reg_b18_dec  : STD_LOGIC;
    signal reg_b18_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b18_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b18_rdy  : STD_LOGIC;
    signal reg_b19_dec  : STD_LOGIC;
    signal reg_b19_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b19_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b19_rdy  : STD_LOGIC;
    signal reg_b20_dec  : STD_LOGIC;
    signal reg_b20_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b20_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b20_rdy  : STD_LOGIC;
    signal reg_b21_dec  : STD_LOGIC;
    signal reg_b21_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b21_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b21_rdy  : STD_LOGIC;
    signal reg_b22_dec  : STD_LOGIC;
    signal reg_b22_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b22_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b22_rdy  : STD_LOGIC;
    signal reg_b23_dec  : STD_LOGIC;
    signal reg_b23_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b23_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b23_rdy  : STD_LOGIC;
    signal reg_b24_dec  : STD_LOGIC;
    signal reg_b24_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b24_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b24_rdy  : STD_LOGIC;
    signal reg_b25_dec  : STD_LOGIC;
    signal reg_b25_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b25_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b25_rdy  : STD_LOGIC;
    signal reg_b26_dec  : STD_LOGIC;
    signal reg_b26_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b26_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b26_rdy  : STD_LOGIC;
    signal reg_b27_dec  : STD_LOGIC;
    signal reg_b27_k    : STD_LOGIC_VECTOR (0 to 511);
    signal reg_b27_klen : STD_LOGIC_VECTOR (0 to 1);
    signal reg_b27_rdy  : STD_LOGIC;

    -- registers used for 128bit key encryptions
    signal reg_l128_1  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_r128_1  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_l128_2  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_r128_2  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_l128_3  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_r128_3  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_l128_4  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_r128_4  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_l128_5  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_r128_5  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_l128_6  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_r128_6  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_l128_7  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_r128_7  : STD_LOGIC_VECTOR (0 to 63);

    -- components outputs
    signal out_ksched : STD_LOGIC_VECTOR (0 to 511); -- key schedule
    signal out_r1l    : STD_LOGIC_VECTOR (0 to 63);  -- first six-round
    signal out_r1r    : STD_LOGIC_VECTOR (0 to 63);
    signal out_r2l    : STD_LOGIC_VECTOR (0 to 63);  -- second six-round
    signal out_r2r    : STD_LOGIC_VECTOR (0 to 63);
    signal out_r3l    : STD_LOGIC_VECTOR (0 to 63);  -- third six-round
    signal out_r3r    : STD_LOGIC_VECTOR (0 to 63);
    signal out_r4l    : STD_LOGIC_VECTOR (0 to 63);  -- fourth six-round
    signal out_r4r    : STD_LOGIC_VECTOR (0 to 63);
    signal out_fl1l   : STD_LOGIC_VECTOR (0 to 63);  -- first fl
    signal out_fl1r   : STD_LOGIC_VECTOR (0 to 63);
    signal out_fl2l   : STD_LOGIC_VECTOR (0 to 63);  -- second fl
    signal out_fl2r   : STD_LOGIC_VECTOR (0 to 63);
    signal out_fl3l   : STD_LOGIC_VECTOR (0 to 63);  -- third fl
    signal out_fl3r   : STD_LOGIC_VECTOR (0 to 63);

    -- misc signals
    signal kr_int   : STD_LOGIC_VECTOR (0 to 127);

    -- constants
    constant KL_OFFSET : INTEGER := 0;
    constant KR_OFFSET : INTEGER := 128;
    constant KA_OFFSET : INTEGER := 256;
    constant KB_OFFSET : INTEGER := 384;

begin

    KEY_SCHED: KEYSCHED256
    PORT MAP (
            reset  => reset,
            clk    => clk,
            kl_in  => reg_kl,
            kr_in  => reg_kr_int,
            kl_out => out_ksched(KL_OFFSET to KL_OFFSET+127),
            kr_out => out_ksched(KR_OFFSET to KR_OFFSET+127),
            ka_out => out_ksched(KA_OFFSET to KA_OFFSET+127),
            kb_out => out_ksched(KB_OFFSET to KB_OFFSET+127)
            );

    SIX1: SIXROUND256
    GENERIC MAP(
        k1e128_offset => KA_OFFSET,
        k1e128_shift  => 0,
        k2e128_offset => KA_OFFSET,
        k2e128_shift  => 0,
        k3e128_offset => KL_OFFSET,
        k3e128_shift  => 15,
        k4e128_offset => KL_OFFSET,
        k4e128_shift  => 15,
        k5e128_offset => KA_OFFSET,
        k5e128_shift  => 15,
        k6e128_offset => KA_OFFSET,
        k6e128_shift  => 15,
        k1d128_offset => KL_OFFSET,
        k1d128_shift  => 111,
        k2d128_offset => KL_OFFSET,
        k2d128_shift  => 111,
        k3d128_offset => KA_OFFSET,
        k3d128_shift  => 94,
        k4d128_offset => KA_OFFSET,
        k4d128_shift  => 94,
        k5d128_offset => KL_OFFSET,
        k5d128_shift  => 94,
        k6d128_offset => KL_OFFSET,
        k6d128_shift  => 94,
        k1e256_offset => KB_OFFSET,
        k1e256_shift  => 0,
        k2e256_offset => KB_OFFSET,
        k2e256_shift  => 0,
        k3e256_offset => KR_OFFSET,
        k3e256_shift  => 15,
        k4e256_offset => KR_OFFSET,
        k4e256_shift  => 15,
        k5e256_offset => KA_OFFSET,
        k5e256_shift  => 15,
        k6e256_offset => KA_OFFSET,
        k6e256_shift  => 15,
        k1d256_offset => KL_OFFSET,
        k1d256_shift  => 111,
        k2d256_offset => KL_OFFSET,
        k2d256_shift  => 111,
        k3d256_offset => KA_OFFSET,
        k3d256_shift  => 94,
        k4d256_offset => KA_OFFSET,
        k4d256_shift  => 94,
        k5d256_offset => KR_OFFSET,
        k5d256_shift  => 94,
        k6d256_offset => KR_OFFSET,
        k6d256_shift  => 94
    )
    PORT MAP(
        reset   => reset,
        clk     => clk,
        dec1    => reg_a6_dec,
        k_len1  => reg_a6_klen,
        k1      => out_ksched,
        dec2    => reg_b1_dec,
        k_len2  => reg_b1_klen,
        k2      => reg_b1_k,
        dec3    => reg_b2_dec,
        k_len3  => reg_b2_klen,
        k3      => reg_b2_k,
        dec4    => reg_b3_dec,
        k_len4  => reg_b3_klen,
        k4      => reg_b3_k,
        dec5    => reg_b4_dec,
        k_len5  => reg_b4_klen,
        k5      => reg_b4_k,
        dec6    => reg_b5_dec,
        k_len6  => reg_b5_klen,
        k6      => reg_b5_k,
        l_in    => w1,
        r_in    => w2,
        l_out   => out_r1l,
        r_out   => out_r1r
    );

    SIX2: SIXROUND256
    GENERIC MAP(
        k1e128_offset => KL_OFFSET,
        k1e128_shift  => 45,
        k2e128_offset => KL_OFFSET,
        k2e128_shift  => 45,
        k3e128_offset => KA_OFFSET,
        k3e128_shift  => 45,
        k4e128_offset => KL_OFFSET,
        k4e128_shift  => 60,
        k5e128_offset => KA_OFFSET,
        k5e128_shift  => 60,
        k6e128_offset => KA_OFFSET,
        k6e128_shift  => 60,
        k1d128_offset => KA_OFFSET,
        k1d128_shift  => 60,
        k2d128_offset => KA_OFFSET,
        k2d128_shift  => 60,
        k3d128_offset => KL_OFFSET,
        k3d128_shift  => 60,
        k4d128_offset => KA_OFFSET,
        k4d128_shift  => 45,
        k5d128_offset => KL_OFFSET,
        k5d128_shift  => 45,
        k6d128_offset => KL_OFFSET,
        k6d128_shift  => 45,
        k1e256_offset => KB_OFFSET,
        k1e256_shift  => 30,
        k2e256_offset => KB_OFFSET,
        k2e256_shift  => 30,
        k3e256_offset => KL_OFFSET,
        k3e256_shift  => 45,
        k4e256_offset => KL_OFFSET,
        k4e256_shift  => 45,
        k5e256_offset => KA_OFFSET,
        k5e256_shift  => 45,
        k6e256_offset => KA_OFFSET,
        k6e256_shift  => 45,
        k1d256_offset => KL_OFFSET,
        k1d256_shift  => 77,
        k2d256_offset => KL_OFFSET,
        k2d256_shift  => 77,
        k3d256_offset => KB_OFFSET,
        k3d256_shift  => 60,
        k4d256_offset => KB_OFFSET,
        k4d256_shift  => 60,
        k5d256_offset => KR_OFFSET,
        k5d256_shift  => 60,
        k6d256_offset => KR_OFFSET,
        k6d256_shift  => 60
    )
    PORT MAP(
        reset   => reset,
        clk     => clk,
        dec1    => reg_b7_dec,
        k_len1  => reg_b7_klen,
        k1      => reg_b7_k,
        dec2    => reg_b8_dec,
        k_len2  => reg_b8_klen,
        k2      => reg_b8_k,
        dec3    => reg_b9_dec,
        k_len3  => reg_b9_klen,
        k3      => reg_b9_k,
        dec4    => reg_b10_dec,
        k_len4  => reg_b10_klen,
        k4      => reg_b10_k,
        dec5    => reg_b11_dec,
        k_len5  => reg_b11_klen,
        k5      => reg_b11_k,
        dec6    => reg_b12_dec,
        k_len6  => reg_b12_klen,
        k6      => reg_b12_k,
        l_in    => out_fl1l,
        r_in    => out_fl1r,
        l_out   => out_r2l,
        r_out   => out_r2r
    );

    SIX3: SIXROUND256
    GENERIC MAP(
        k1e128_offset => KL_OFFSET,
        k1e128_shift  => 94,
        k2e128_offset => KL_OFFSET,
        k2e128_shift  => 94,
        k3e128_offset => KA_OFFSET,
        k3e128_shift  => 94,
        k4e128_offset => KA_OFFSET,
        k4e128_shift  => 94,
        k5e128_offset => KL_OFFSET,
        k5e128_shift  => 111,
        k6e128_offset => KL_OFFSET,
        k6e128_shift  => 111,
        k1d128_offset => KA_OFFSET,
        k1d128_shift  => 15,
        k2d128_offset => KA_OFFSET,
        k2d128_shift  => 15,
        k3d128_offset => KL_OFFSET,
        k3d128_shift  => 15,
        k4d128_offset => KL_OFFSET,
        k4d128_shift  => 15,
        k5d128_offset => KA_OFFSET,
        k5d128_shift  => 0,
        k6d128_offset => KA_OFFSET,
        k6d128_shift  => 0,
        k1e256_offset => KR_OFFSET,
        k1e256_shift  => 60,
        k2e256_offset => KR_OFFSET,
        k2e256_shift  => 60,
        k3e256_offset => KB_OFFSET,
        k3e256_shift  => 60,
        k4e256_offset => KB_OFFSET,
        k4e256_shift  => 60,
        k5e256_offset => KL_OFFSET,
        k5e256_shift  => 77,
        k6e256_offset => KL_OFFSET,
        k6e256_shift  => 77,
        k1d256_offset => KA_OFFSET,
        k1d256_shift  => 45,
        k2d256_offset => KA_OFFSET,
        k2d256_shift  => 45,
        k3d256_offset => KL_OFFSET,
        k3d256_shift  => 45,
        k4d256_offset => KL_OFFSET,
        k4d256_shift  => 45,
        k5d256_offset => KB_OFFSET,
        k5d256_shift  => 30,
        k6d256_offset => KB_OFFSET,
        k6d256_shift  => 30
    )
    PORT MAP(
        reset   => reset,
        clk     => clk,
        dec1    => reg_b14_dec,
        k_len1  => reg_b14_klen,
        k1      => reg_b14_k,
        dec2    => reg_b15_dec,
        k_len2  => reg_b15_klen,
        k2      => reg_b15_k,
        dec3    => reg_b16_dec,
        k_len3  => reg_b16_klen,
        k3      => reg_b16_k,
        dec4    => reg_b17_dec,
        k_len4  => reg_b17_klen,
        k4      => reg_b17_k,
        dec5    => reg_b18_dec,
        k_len5  => reg_b18_klen,
        k5      => reg_b18_k,
        dec6    => reg_b19_dec,
        k_len6  => reg_b19_klen,
        k6      => reg_b19_k,
        l_in    => out_fl2l,
        r_in    => out_fl2r,
        l_out   => out_r3l,
        r_out   => out_r3r
    );

    SIX4: SIXROUND256
    GENERIC MAP(
        k1e128_offset => 0,
        k1e128_shift  => 0,
        k2e128_offset => 0,
        k2e128_shift  => 0,
        k3e128_offset => 0,
        k3e128_shift  => 0,
        k4e128_offset => 0,
        k4e128_shift  => 0,
        k5e128_offset => 0,
        k5e128_shift  => 0,
        k6e128_offset => 0,
        k6e128_shift  => 0,
        k1d128_offset => 0,
        k1d128_shift  => 0,
        k2d128_offset => 0,
        k2d128_shift  => 0,
        k3d128_offset => 0,
        k3d128_shift  => 0,
        k4d128_offset => 0,
        k4d128_shift  => 0,
        k5d128_offset => 0,
        k5d128_shift  => 0,
        k6d128_offset => 0,
        k6d128_shift  => 0,
        k1e256_offset => KR_OFFSET,
        k1e256_shift  => 94,
        k2e256_offset => KR_OFFSET,
        k2e256_shift  => 94,
        k3e256_offset => KA_OFFSET,
        k3e256_shift  => 94,
        k4e256_offset => KA_OFFSET,
        k4e256_shift  => 94,
        k5e256_offset => KL_OFFSET,
        k5e256_shift  => 111,
        k6e256_offset => KL_OFFSET,
        k6e256_shift  => 111,
        k1d256_offset => KA_OFFSET,
        k1d256_shift  => 15,
        k2d256_offset => KA_OFFSET,
        k2d256_shift  => 15,
        k3d256_offset => KR_OFFSET,
        k3d256_shift  => 15,
        k4d256_offset => KR_OFFSET,
        k4d256_shift  => 15,
        k5d256_offset => KB_OFFSET,
        k5d256_shift  => 0,
        k6d256_offset => KB_OFFSET,
        k6d256_shift  => 0
    )
    PORT MAP(
        reset   => reset,
        clk     => clk,
        dec1    => reg_b21_dec,
        k_len1  => reg_b21_klen,
        k1      => reg_b21_k,
        dec2    => reg_b22_dec,
        k_len2  => reg_b22_klen,
        k2      => reg_b22_k,
        dec3    => reg_b23_dec,
        k_len3  => reg_b23_klen,
        k3      => reg_b23_k,
        dec4    => reg_b24_dec,
        k_len4  => reg_b24_klen,
        k4      => reg_b24_k,
        dec5    => reg_b25_dec,
        k_len5  => reg_b25_klen,
        k5      => reg_b25_k,
        dec6    => reg_b26_dec,
        k_len6  => reg_b26_klen,
        k6      => reg_b26_k,
        l_in    => out_fl3l,
        r_in    => out_fl3r,
        l_out   => out_r4l,
        r_out   => out_r4r
    );

    FL1: FL256
    GENERIC MAP (
            fl_ke128_offset  => KA_OFFSET,
            fl_ke128_shift   => 30,
            fli_ke128_offset => KA_OFFSET,
            fli_ke128_shift  => 30,
            fl_kd128_offset  => KL_OFFSET,
            fl_kd128_shift   => 77,
            fli_kd128_offset => KL_OFFSET,
            fli_kd128_shift  => 77,
            fl_ke256_offset  => KR_OFFSET,
            fl_ke256_shift   => 30,
            fli_ke256_offset => KR_OFFSET,
            fli_ke256_shift  => 30,
            fl_kd256_offset  => KA_OFFSET,
            fl_kd256_shift   => 77,
            fli_kd256_offset => KA_OFFSET,
            fli_kd256_shift  => 77
            )
    PORT MAP (
            reset   => reset,
            clk     => clk,
            fl_in   => out_r1l,
            fli_in  => out_r1r,
            k       => reg_b7_k,
            k_len   => reg_b7_klen,
            dec     => reg_b7_dec,
            fl_out  => out_fl1l,
            fli_out => out_fl1r
            );

    FL2: FL256
    GENERIC MAP (
            fl_ke128_offset  => KL_OFFSET,
            fl_ke128_shift   => 77,
            fli_ke128_offset => KL_OFFSET,
            fli_ke128_shift  => 77,
            fl_kd128_offset  => KA_OFFSET,
            fl_kd128_shift   => 30,
            fli_kd128_offset => KA_OFFSET,
            fli_kd128_shift  => 30,
            fl_ke256_offset  => KL_OFFSET,
            fl_ke256_shift   => 60,
            fli_ke256_offset => KL_OFFSET,
            fli_ke256_shift  => 60,
            fl_kd256_offset  => KL_OFFSET,
            fl_kd256_shift   => 60,
            fli_kd256_offset => KL_OFFSET,
            fli_kd256_shift  => 60
            )
    PORT MAP (
            reset   => reset,
            clk     => clk,
            fl_in   => out_r2l,
            fli_in  => out_r2r,
            k       => reg_b14_k,
            k_len   => reg_b14_klen,
            dec     => reg_b14_dec,
            fl_out  => out_fl2l,
            fli_out => out_fl2r
            );

    FL3: FL256
    GENERIC MAP (
            fl_ke128_offset  => 0,
            fl_ke128_shift   => 0,
            fli_ke128_offset => 0,
            fli_ke128_shift  => 0,
            fl_kd128_offset  => 0,
            fl_kd128_shift   => 0,
            fli_kd128_offset => 0,
            fli_kd128_shift  => 0,
            fl_ke256_offset  => KA_OFFSET,
            fl_ke256_shift   => 77,
            fli_ke256_offset => KA_OFFSET,
            fli_ke256_shift  => 77,
            fl_kd256_offset  => KR_OFFSET,
            fl_kd256_shift   => 30,
            fli_kd256_offset => KR_OFFSET,
            fli_kd256_shift  => 30
            )
    PORT MAP (
            reset   => reset,
            clk     => clk,
            fl_in   => out_r3l,
            fli_in  => out_r3r,
            k       => reg_b21_k,
            k_len   => reg_b21_klen,
            dec     => reg_b21_dec,
            fl_out  => out_fl3l,
            fli_out => out_fl3r
            );


    process(reset, clk)
    begin
        if(reset = '1') then
            reg_m       <= (others=>'0');
            reg_kl      <= (others=>'0');
            reg_kr_int  <= (others=>'0');
            reg_k_len   <= (others=>'0');

            reg_dec     <= '0';
            reg_rdy     <= '0';
            reg_a1_rdy  <= '0';
            reg_a2_rdy  <= '0';
            reg_a3_rdy  <= '0';
            reg_a4_rdy  <= '0';
            reg_a5_rdy  <= '0';
            reg_a6_rdy  <= '0';
            reg_b1_rdy  <= '0';
            reg_b2_rdy  <= '0';
            reg_b3_rdy  <= '0';
            reg_b4_rdy  <= '0';
            reg_b5_rdy  <= '0';
            reg_b6_rdy  <= '0';
            reg_b7_rdy  <= '0';
            reg_b8_rdy  <= '0';
            reg_b9_rdy  <= '0';
            reg_b10_rdy <= '0';
            reg_b11_rdy <= '0';
            reg_b12_rdy <= '0';
            reg_b13_rdy <= '0';
            reg_b14_rdy <= '0';
            reg_b15_rdy <= '0';
            reg_b16_rdy <= '0';
            reg_b17_rdy <= '0';
            reg_b18_rdy <= '0';
            reg_b19_rdy <= '0';
            reg_b20_rdy <= '0';
            reg_b21_rdy <= '0';
            reg_b22_rdy <= '0';
            reg_b23_rdy <= '0';
            reg_b24_rdy <= '0';
            reg_b25_rdy <= '0';
            reg_b26_rdy <= '0';
            reg_b27_rdy <= '0';
            output_rdy  <= '0';
        elsif(rising_edge(clk)) then
            reg_m       <= input;
            reg_kl      <= key(0 to 127);
            reg_kr_int  <= kr_int;
            reg_dec     <= enc_dec;
            reg_k_len   <= key_len;
            reg_rdy     <= input_en;

            reg_a1_m    <= reg_m;
            reg_a1_dec  <= reg_dec;
            reg_a1_klen <= reg_k_len;
            reg_a1_rdy  <= reg_rdy;
            reg_a2_m    <= reg_a1_m;
            reg_a2_dec  <= reg_a1_dec;
            reg_a2_klen <= reg_a1_klen;
            reg_a2_rdy  <= reg_a1_rdy;
            reg_a3_m    <= reg_a2_m;
            reg_a3_dec  <= reg_a2_dec;
            reg_a3_klen <= reg_a2_klen;
            reg_a3_rdy  <= reg_a2_rdy;
            reg_a4_m    <= reg_a3_m;
            reg_a4_dec  <= reg_a3_dec;
            reg_a4_klen <= reg_a3_klen;
            reg_a4_rdy  <= reg_a3_rdy;
            reg_a5_m    <= reg_a4_m;
            reg_a5_dec  <= reg_a4_dec;
            reg_a5_klen <= reg_a4_klen;
            reg_a5_rdy  <= reg_a4_rdy;
            reg_a6_m    <= reg_a5_m;
            reg_a6_dec  <= reg_a5_dec;
            reg_a6_klen <= reg_a5_klen;
            reg_a6_rdy  <= reg_a5_rdy;

            reg_b1_dec  <= reg_a6_dec;
            reg_b1_k    <= out_ksched;
            reg_b1_klen <= reg_a6_klen;
            reg_b1_rdy  <= reg_a6_rdy;
            reg_b2_dec  <= reg_b1_dec;
            reg_b2_k    <= reg_b1_k;
            reg_b2_klen <= reg_b1_klen;
            reg_b2_rdy  <= reg_b1_rdy;
            reg_b3_dec  <= reg_b2_dec;
            reg_b3_k    <= reg_b2_k;
            reg_b3_klen <= reg_b2_klen;
            reg_b3_rdy  <= reg_b2_rdy;
            reg_b4_dec  <= reg_b3_dec;
            reg_b4_k    <= reg_b3_k;
            reg_b4_klen <= reg_b3_klen;
            reg_b4_rdy  <= reg_b3_rdy;
            reg_b5_dec  <= reg_b4_dec;
            reg_b5_k    <= reg_b4_k;
            reg_b5_klen <= reg_b4_klen;
            reg_b5_rdy  <= reg_b4_rdy;
            reg_b6_dec  <= reg_b5_dec;
            reg_b6_k    <= reg_b5_k;
            reg_b6_klen <= reg_b5_klen;
            reg_b6_rdy  <= reg_b5_rdy;
            reg_b7_dec  <= reg_b6_dec;
            reg_b7_k    <= reg_b6_k;
            reg_b7_klen <= reg_b6_klen;
            reg_b7_rdy  <= reg_b6_rdy;
            reg_b8_dec  <= reg_b7_dec;
            reg_b8_k    <= reg_b7_k;
            reg_b8_klen <= reg_b7_klen;
            reg_b8_rdy  <= reg_b7_rdy;
            reg_b9_dec  <= reg_b8_dec;
            reg_b9_k    <= reg_b8_k;
            reg_b9_klen <= reg_b8_klen;
            reg_b9_rdy  <= reg_b8_rdy;
            reg_b10_dec  <= reg_b9_dec;
            reg_b10_k    <= reg_b9_k;
            reg_b10_klen <= reg_b9_klen;
            reg_b10_rdy  <= reg_b9_rdy;
            reg_b11_dec  <= reg_b10_dec;
            reg_b11_k    <= reg_b10_k;
            reg_b11_klen <= reg_b10_klen;
            reg_b11_rdy  <= reg_b10_rdy;
            reg_b12_dec  <= reg_b11_dec;
            reg_b12_k    <= reg_b11_k;
            reg_b12_klen <= reg_b11_klen;
            reg_b12_rdy  <= reg_b11_rdy;
            reg_b13_dec  <= reg_b12_dec;
            reg_b13_k    <= reg_b12_k;
            reg_b13_klen <= reg_b12_klen;
            reg_b13_rdy  <= reg_b12_rdy;
            reg_b14_dec  <= reg_b13_dec;
            reg_b14_k    <= reg_b13_k;
            reg_b14_klen <= reg_b13_klen;
            reg_b14_rdy  <= reg_b13_rdy;
            reg_b15_dec  <= reg_b14_dec;
            reg_b15_k    <= reg_b14_k;
            reg_b15_klen <= reg_b14_klen;
            reg_b15_rdy  <= reg_b14_rdy;
            reg_b16_dec  <= reg_b15_dec;
            reg_b16_k    <= reg_b15_k;
            reg_b16_klen <= reg_b15_klen;
            reg_b16_rdy  <= reg_b15_rdy;
            reg_b17_dec  <= reg_b16_dec;
            reg_b17_k    <= reg_b16_k;
            reg_b17_klen <= reg_b16_klen;
            reg_b17_rdy  <= reg_b16_rdy;
            reg_b18_dec  <= reg_b17_dec;
            reg_b18_k    <= reg_b17_k;
            reg_b18_klen <= reg_b17_klen;
            reg_b18_rdy  <= reg_b17_rdy;
            reg_b19_dec  <= reg_b18_dec;
            reg_b19_k    <= reg_b18_k;
            reg_b19_klen <= reg_b18_klen;
            reg_b19_rdy  <= reg_b18_rdy;
            reg_b20_dec  <= reg_b19_dec;
            reg_b20_k    <= reg_b19_k;
            reg_b20_klen <= reg_b19_klen;
            reg_b20_rdy  <= reg_b19_rdy;
            reg_b21_dec  <= reg_b20_dec;
            reg_b21_k    <= reg_b20_k;
            reg_b21_klen <= reg_b20_klen;
            reg_b21_rdy  <= reg_b20_rdy;
            reg_b22_dec  <= reg_b21_dec;
            reg_b22_k    <= reg_b21_k;
            reg_b22_klen <= reg_b21_klen;
            reg_b22_rdy  <= reg_b21_rdy;
            reg_b23_dec  <= reg_b22_dec;
            reg_b23_k    <= reg_b22_k;
            reg_b23_klen <= reg_b22_klen;
            reg_b23_rdy  <= reg_b22_rdy;
            reg_b24_dec  <= reg_b23_dec;
            reg_b24_k    <= reg_b23_k;
            reg_b24_klen <= reg_b23_klen;
            reg_b24_rdy  <= reg_b23_rdy;
            reg_b25_dec  <= reg_b24_dec;
            reg_b25_k    <= reg_b24_k;
            reg_b25_klen <= reg_b24_klen;
            reg_b25_rdy  <= reg_b24_rdy;
            reg_b26_dec  <= reg_b25_dec;
            reg_b26_k    <= reg_b25_k;
            reg_b26_klen <= reg_b25_klen;
            reg_b26_rdy  <= reg_b25_rdy;
            reg_b27_dec  <= reg_b26_dec;
            reg_b27_k    <= reg_b26_k;
            reg_b27_klen <= reg_b26_klen;
            reg_b27_rdy  <= reg_b26_rdy;

            reg_l128_1  <= out_r3l;
            reg_r128_1  <= out_r3r;
            reg_l128_2  <= reg_l128_1;
            reg_r128_2  <= reg_r128_1;
            reg_l128_3  <= reg_l128_2;
            reg_r128_3  <= reg_r128_2;
            reg_l128_4  <= reg_l128_3;
            reg_r128_4  <= reg_r128_3;
            reg_l128_5  <= reg_l128_4;
            reg_r128_5  <= reg_r128_4;
            reg_l128_6  <= reg_l128_5;
            reg_r128_6  <= reg_r128_5;
            reg_l128_7  <= reg_l128_6;
            reg_r128_7  <= reg_r128_6;

            -- output
            output <= w3 & w4;
			output_rdy <= reg_b27_rdy;

        end if;
    end process;

    --kr depends on key lenght
    kr_int <= (others=>'0') when key_len(0)='0' else
              key(128 to 191) & not key(128 to 191) when key_len="10" else
              key(128 to 255);

    -- pre-whitening
    kw1_enc <= out_ksched(KL_OFFSET to KL_OFFSET+63);
    kw2_enc <= out_ksched(KL_OFFSET+64 to KL_OFFSET+127);

    ka_s111_dec128 <= out_ksched(KA_OFFSET+111 to KA_OFFSET+127) &
                      out_ksched(KA_OFFSET to KA_OFFSET+110);
    kw1_dec128 <= ka_s111_dec128(0 to 63);
    kw2_dec128 <= ka_s111_dec128(64 to 127);

    ka_s111_dec256 <= out_ksched(KB_OFFSET+111 to KB_OFFSET+127) &
                      out_ksched(KB_OFFSET to KB_OFFSET+110);
    kw1_dec256 <= ka_s111_dec256(0 to 63);
    kw2_dec256 <= ka_s111_dec256(64 to 127);

    kw1 <= kw1_dec128 when reg_a6_dec='1' and reg_a6_klen(0)='0' else
           kw1_dec256 when reg_a6_dec='1' and reg_a6_klen(0)='1' else
           kw1_enc;
    kw2 <= kw2_dec128 when reg_a6_dec='1' and reg_a6_klen(0)='0' else
           kw2_dec256 when reg_a6_dec='1' and reg_a6_klen(0)='1' else
           kw2_enc;

    w1 <= reg_a6_m(0 to 63) xor kw1;
    w2 <= reg_a6_m(64 to 127) xor kw2;

    -- post-whitening
    ka_s111_enc128 <= reg_b27_k(KA_OFFSET+111 to KA_OFFSET+127) &
                      reg_b27_k(KA_OFFSET to KA_OFFSET+110);
    kw3_enc128 <= ka_s111_enc128(0 to 63);
    kw4_enc128 <= ka_s111_enc128(64 to 127);

    ka_s111_enc256 <= reg_b27_k(KB_OFFSET+111 to KB_OFFSET+127) &
                      reg_b27_k(KB_OFFSET to KB_OFFSET+110);
    kw3_enc256 <= ka_s111_enc256(0 to 63);
    kw4_enc256 <= ka_s111_enc256(64 to 127);

    kw3_dec <= reg_b27_k(KL_OFFSET to KL_OFFSET+63);
    kw4_dec <= reg_b27_k(KL_OFFSET+64 to KL_OFFSET+127);

    kw3 <= kw3_enc128 when reg_b27_dec='0' and reg_b27_klen(0)='0' else
           kw3_enc256 when reg_b27_dec='0' and reg_b27_klen(0)='1' else
           kw3_dec;
    kw4 <= kw4_enc128 when reg_b27_dec='0' and reg_b27_klen(0)='0' else
           kw4_enc256 when reg_b27_dec='0' and reg_b27_klen(0)='1' else
           kw4_dec;


    w3 <= reg_r128_7 xor kw3 when reg_b27_klen(0)='0' else
          out_r4r xor kw3;
    w4 <= reg_l128_7 xor kw4 when reg_b27_klen(0)='0' else
          out_r4l xor kw4;

end RTL;
