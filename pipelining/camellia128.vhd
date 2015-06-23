
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/14/2008
-- Project Name:  camellia-vhdl
-- Description:   Camellia top level module, only for 128-bit key en/decryption
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


entity CAMELLIA128 is
    port(
            reset      : in  STD_LOGIC;
            clk        : in  STD_LOGIC;
            input      : in  STD_LOGIC_VECTOR (0 to 127);  -- input data
            input_en   : in  STD_LOGIC;                    -- input enable
            key        : in  STD_LOGIC_VECTOR (0 to 127);  -- key
            enc_dec    : in  STD_LOGIC;                    -- dec=0 enc, dec=1 dec
            output     : out STD_LOGIC_VECTOR (0 to 127);  -- en/decrypted data
            output_rdy : out STD_LOGIC                     -- output ready
            );
end CAMELLIA128;

architecture RTL of CAMELLIA128 is

    component KEYSCHED128 is
        port    (
                reset  : in STD_LOGIC;
                clk    : in STD_LOGIC;
                kl_in  : in STD_LOGIC_VECTOR (0 to 127);
                kl_out : out STD_LOGIC_VECTOR (0 to 127);
                ka_out : out STD_LOGIC_VECTOR (0 to 127)
                );
    end component;

    component SIXROUND128 is
        generic (
                k1e_offset  : INTEGER;
                k1e_shift   : INTEGER;
                k2e_offset  : INTEGER;
                k2e_shift   : INTEGER;
                k3e_offset  : INTEGER;
                k3e_shift   : INTEGER;
                k4e_offset  : INTEGER;
                k4e_shift   : INTEGER;
                k5e_offset  : INTEGER;
                k5e_shift   : INTEGER;
                k6e_offset  : INTEGER;
                k6e_shift   : INTEGER;
                k1d_offset  : INTEGER;
                k1d_shift   : INTEGER;
                k2d_offset  : INTEGER;
                k2d_shift   : INTEGER;
                k3d_offset  : INTEGER;
                k3d_shift   : INTEGER;
                k4d_offset  : INTEGER;
                k4d_shift   : INTEGER;
                k5d_offset  : INTEGER;
                k5d_shift   : INTEGER;
                k6d_offset  : INTEGER;
                k6d_shift   : INTEGER
                );
        port(
                reset   : in  STD_LOGIC;
                clk     : in  STD_LOGIC;
                dec1    : in  STD_LOGIC;
                k1      : in  STD_LOGIC_VECTOR (0 to 255);
                dec2    : in  STD_LOGIC;
                k2      : in  STD_LOGIC_VECTOR (0 to 255);
                dec3    : in  STD_LOGIC;
                k3      : in  STD_LOGIC_VECTOR (0 to 255);
                dec4    : in  STD_LOGIC;
                k4      : in  STD_LOGIC_VECTOR (0 to 255);
                dec5    : in  STD_LOGIC;
                k5      : in  STD_LOGIC_VECTOR (0 to 255);
                dec6    : in  STD_LOGIC;
                k6      : in  STD_LOGIC_VECTOR (0 to 255);
                l_in    : in  STD_LOGIC_VECTOR (0 to 63);
                r_in    : in  STD_LOGIC_VECTOR (0 to 63);
                l_out   : out STD_LOGIC_VECTOR (0 to 63);
                r_out   : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;

    component FL128 is
        generic    (
                    fl_ke_offset  : INTEGER;
                    fl_ke_shift   : INTEGER;
                    fli_ke_offset : INTEGER;
                    fli_ke_shift  : INTEGER;
                    fl_kd_offset  : INTEGER;
                    fl_kd_shift   : INTEGER;
                    fli_kd_offset : INTEGER;
                    fli_kd_shift  : INTEGER
                    );
        port(
                    reset   : in  STD_LOGIC;
                    clk     : in  STD_LOGIC;
                    fl_in   : in  STD_LOGIC_VECTOR (0 to 63);
                    fli_in  : in  STD_LOGIC_VECTOR (0 to 63);
                    k       : in  STD_LOGIC_VECTOR (0 to 255);
                    dec     : in  STD_LOGIC;
                    fl_out  : out STD_LOGIC_VECTOR (0 to 63);
                    fli_out : out STD_LOGIC_VECTOR (0 to 63)
                    );
    end component;


    -- input registers
    signal reg_m   : STD_LOGIC_VECTOR (0 to 127);
    signal reg_k   : STD_LOGIC_VECTOR (0 to 127);
    signal reg_dec : STD_LOGIC;
    signal reg_rdy : STD_LOGIC;

    -- used by pre-whitening
    signal kw1_enc     : STD_LOGIC_VECTOR (0 to 63);
    signal kw2_enc     : STD_LOGIC_VECTOR (0 to 63);
    signal ka_s111_dec : STD_LOGIC_VECTOR (0 to 127);
    signal kw1_dec     : STD_LOGIC_VECTOR (0 to 63);
    signal kw2_dec     : STD_LOGIC_VECTOR (0 to 63);
    signal kw1         : STD_LOGIC_VECTOR (0 to 63);
    signal kw2         : STD_LOGIC_VECTOR (0 to 63);
    signal w1          : STD_LOGIC_VECTOR (0 to 63);
    signal w2          : STD_LOGIC_VECTOR (0 to 63);

    -- used by post-whitening
    signal ka_s111_enc : STD_LOGIC_VECTOR (0 to 127);
    signal kw3_enc     : STD_LOGIC_VECTOR (0 to 63);
    signal kw4_enc     : STD_LOGIC_VECTOR (0 to 63);
    signal kw3_dec     : STD_LOGIC_VECTOR (0 to 63);
    signal kw4_dec     : STD_LOGIC_VECTOR (0 to 63);
    signal kw3         : STD_LOGIC_VECTOR (0 to 63);
    signal kw4         : STD_LOGIC_VECTOR (0 to 63);
    signal w3          : STD_LOGIC_VECTOR (0 to 63);
    signal w4          : STD_LOGIC_VECTOR (0 to 63);

    -- registers used during key schedule
    signal reg_a1_m   : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a1_dec : STD_LOGIC;
    signal reg_a1_rdy : STD_LOGIC;
    signal reg_a2_m   : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a2_dec : STD_LOGIC;
    signal reg_a2_rdy : STD_LOGIC;
    signal reg_a3_m   : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a3_dec : STD_LOGIC;
    signal reg_a3_rdy : STD_LOGIC;
    signal reg_a4_m   : STD_LOGIC_VECTOR (0 to 127);
    signal reg_a4_dec : STD_LOGIC;
    signal reg_a4_rdy : STD_LOGIC;

    -- registers used during 6-rounds and fls
    signal reg_b1_dec  : STD_LOGIC;
    signal reg_b1_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b1_rdy  : STD_LOGIC;
    signal reg_b2_dec  : STD_LOGIC;
    signal reg_b2_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b2_rdy  : STD_LOGIC;
    signal reg_b3_dec  : STD_LOGIC;
    signal reg_b3_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b3_rdy  : STD_LOGIC;
    signal reg_b4_dec  : STD_LOGIC;
    signal reg_b4_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b4_rdy  : STD_LOGIC;
    signal reg_b5_dec  : STD_LOGIC;
    signal reg_b5_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b5_rdy  : STD_LOGIC;
    signal reg_b6_dec  : STD_LOGIC;
    signal reg_b6_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b6_rdy  : STD_LOGIC;
    signal reg_b7_dec  : STD_LOGIC;
    signal reg_b7_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b7_rdy  : STD_LOGIC;
    signal reg_b8_dec  : STD_LOGIC;
    signal reg_b8_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b8_rdy  : STD_LOGIC;
    signal reg_b9_dec  : STD_LOGIC;
    signal reg_b9_k    : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b9_rdy  : STD_LOGIC;
    signal reg_b10_dec : STD_LOGIC;
    signal reg_b10_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b10_rdy : STD_LOGIC;
    signal reg_b11_dec : STD_LOGIC;
    signal reg_b11_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b11_rdy : STD_LOGIC;
    signal reg_b12_dec : STD_LOGIC;
    signal reg_b12_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b12_rdy : STD_LOGIC;
    signal reg_b13_dec : STD_LOGIC;
    signal reg_b13_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b13_rdy : STD_LOGIC;
    signal reg_b14_dec : STD_LOGIC;
    signal reg_b14_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b14_rdy : STD_LOGIC;
    signal reg_b15_dec : STD_LOGIC;
    signal reg_b15_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b15_rdy : STD_LOGIC;
    signal reg_b16_dec : STD_LOGIC;
    signal reg_b16_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b16_rdy : STD_LOGIC;
    signal reg_b17_dec : STD_LOGIC;
    signal reg_b17_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b17_rdy : STD_LOGIC;
    signal reg_b18_dec : STD_LOGIC;
    signal reg_b18_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b18_rdy : STD_LOGIC;
    signal reg_b19_dec : STD_LOGIC;
    signal reg_b19_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b19_rdy : STD_LOGIC;
    signal reg_b20_dec : STD_LOGIC;
    signal reg_b20_k   : STD_LOGIC_VECTOR (0 to 255);
    signal reg_b20_rdy : STD_LOGIC;

    -- components outputs
    signal out_ksched  : STD_LOGIC_VECTOR (0 to 255); -- key schedule
    signal out_r1l     : STD_LOGIC_VECTOR (0 to 63);  -- first six-round
    signal out_r1r     : STD_LOGIC_VECTOR (0 to 63);
    signal out_r2l     : STD_LOGIC_VECTOR (0 to 63);  -- second six-round
    signal out_r2r     : STD_LOGIC_VECTOR (0 to 63);
    signal out_r3l     : STD_LOGIC_VECTOR (0 to 63);  -- third six-round
    signal out_r3r     : STD_LOGIC_VECTOR (0 to 63);
    signal out_fl1l    : STD_LOGIC_VECTOR (0 to 63);  -- first fl
    signal out_fl1r    : STD_LOGIC_VECTOR (0 to 63);
    signal out_fl2l    : STD_LOGIC_VECTOR (0 to 63);  -- second fl
    signal out_fl2r    : STD_LOGIC_VECTOR (0 to 63);

    -- constants
    constant KL_OFFSET : integer := 0;
    constant KA_OFFSET : integer := 128;

begin

    KEY_SCHED: KEYSCHED128
    PORT MAP (
            reset  => reset,
            clk    => clk,
            kl_in  => reg_k,
            kl_out => out_ksched(KL_OFFSET to KL_OFFSET+127),
            ka_out => out_ksched(KA_OFFSET to KA_OFFSET+127)
            );

    SIX1: SIXROUND128
    GENERIC MAP(
        k1e_offset => KA_OFFSET,
        k1e_shift  => 0,
        k2e_offset => KA_OFFSET,
        k2e_shift  => 0,
        k3e_offset => KL_OFFSET,
        k3e_shift  => 15,
        k4e_offset => KL_OFFSET,
        k4e_shift  => 15,
        k5e_offset => KA_OFFSET,
        k5e_shift  => 15,
        k6e_offset => KA_OFFSET,
        k6e_shift  => 15,
        k1d_offset => KL_OFFSET,
        k1d_shift  => 111,
        k2d_offset => KL_OFFSET,
        k2d_shift  => 111,
        k3d_offset => KA_OFFSET,
        k3d_shift  => 94,
        k4d_offset => KA_OFFSET,
        k4d_shift  => 94,
        k5d_offset => KL_OFFSET,
        k5d_shift  => 94,
        k6d_offset => KL_OFFSET,
        k6d_shift  => 94
    )
    PORT MAP(
        reset   => reset,
        clk     => clk,
        dec1    => reg_a4_dec,
        k1      => out_ksched,
        dec2    => reg_b1_dec,
        k2      => reg_b1_k,
        dec3    => reg_b2_dec,
        k3      => reg_b2_k,
        dec4    => reg_b3_dec,
        k4      => reg_b3_k,
        dec5    => reg_b4_dec,
        k5      => reg_b4_k,
        dec6    => reg_b5_dec,
        k6      => reg_b5_k,
        l_in    => w1,
        r_in    => w2,
        l_out   => out_r1l,
        r_out   => out_r1r
    );

    SIX2: SIXROUND128
    GENERIC MAP(
        k1e_offset => KL_OFFSET,
        k1e_shift  => 45,
        k2e_offset => KL_OFFSET,
        k2e_shift  => 45,
        k3e_offset => KA_OFFSET,
        k3e_shift  => 45,
        k4e_offset => KL_OFFSET,
        k4e_shift  => 60,
        k5e_offset => KA_OFFSET,
        k5e_shift  => 60,
        k6e_offset => KA_OFFSET,
        k6e_shift  => 60,
        k1d_offset => KA_OFFSET,
        k1d_shift  => 60,
        k2d_offset => KA_OFFSET,
        k2d_shift  => 60,
        k3d_offset => KL_OFFSET,
        k3d_shift  => 60,
        k4d_offset => KA_OFFSET,
        k4d_shift  => 45,
        k5d_offset => KL_OFFSET,
        k5d_shift  => 45,
        k6d_offset => KL_OFFSET,
        k6d_shift  => 45
    )
    PORT MAP(
        reset   => reset,
        clk     => clk,
        dec1    => reg_b7_dec,
        k1      => reg_b7_k,
        dec2    => reg_b8_dec,
        k2      => reg_b8_k,
        dec3    => reg_b9_dec,
        k3      => reg_b9_k,
        dec4    => reg_b10_dec,
        k4      => reg_b10_k,
        dec5    => reg_b11_dec,
        k5      => reg_b11_k,
        dec6    => reg_b12_dec,
        k6      => reg_b12_k,
        l_in    => out_fl1l,
        r_in    => out_fl1r,
        l_out   => out_r2l,
        r_out   => out_r2r
    );

    SIX3: SIXROUND128
    GENERIC MAP(
        k1e_offset => KL_OFFSET,
        k1e_shift  => 94,
        k2e_offset => KL_OFFSET,
        k2e_shift  => 94,
        k3e_offset => KA_OFFSET,
        k3e_shift  => 94,
        k4e_offset => KA_OFFSET,
        k4e_shift  => 94,
        k5e_offset => KL_OFFSET,
        k5e_shift  => 111,
        k6e_offset => KL_OFFSET,
        k6e_shift  => 111,
        k1d_offset => KA_OFFSET,
        k1d_shift  => 15,
        k2d_offset => KA_OFFSET,
        k2d_shift  => 15,
        k3d_offset => KL_OFFSET,
        k3d_shift  => 15,
        k4d_offset => KL_OFFSET,
        k4d_shift  => 15,
        k5d_offset => KA_OFFSET,
        k5d_shift  => 0,
        k6d_offset => KA_OFFSET,
        k6d_shift  => 0
    )
    PORT MAP(
        reset   => reset,
        clk     => clk,
        dec1    => reg_b14_dec,
        k1      => reg_b14_k,
        dec2    => reg_b15_dec,
        k2      => reg_b15_k,
        dec3    => reg_b16_dec,
        k3      => reg_b16_k,
        dec4    => reg_b17_dec,
        k4      => reg_b17_k,
        dec5    => reg_b18_dec,
        k5      => reg_b18_k,
        dec6    => reg_b19_dec,
        k6      => reg_b19_k,
        l_in    => out_fl2l,
        r_in    => out_fl2r,
        l_out   => out_r3l,
        r_out   => out_r3r
    );

    FL1: FL128
    GENERIC MAP (
            fl_ke_offset  => KA_OFFSET,
            fl_ke_shift   => 30,
            fli_ke_offset => KA_OFFSET,
            fli_ke_shift  => 30,
            fl_kd_offset  => KL_OFFSET,
            fl_kd_shift   => 77,
            fli_kd_offset => KL_OFFSET,
            fli_kd_shift  => 77
            )
    PORT MAP (
            reset   => reset,
            clk     => clk,
            fl_in   => out_r1l,
            fli_in  => out_r1r,
            k       => reg_b7_k,
            dec     => reg_b7_dec,
            fl_out  => out_fl1l,
            fli_out => out_fl1r
            );

    FL2: FL128
    GENERIC MAP (
            fl_ke_offset  => KL_OFFSET,
            fl_ke_shift   => 77,
            fli_ke_offset => KL_OFFSET,
            fli_ke_shift  => 77,
            fl_kd_offset  => KA_OFFSET,
            fl_kd_shift   => 30,
            fli_kd_offset => KA_OFFSET,
            fli_kd_shift  => 30
            )
    PORT MAP (
            reset   => reset,
            clk     => clk,
            fl_in   => out_r2l,
            fli_in  => out_r2r,
            k       => reg_b14_k,
            dec     => reg_b14_dec,
            fl_out  => out_fl2l,
            fli_out => out_fl2r
            );

    process(reset, clk)
    begin
        if(reset = '1') then
            reg_m       <= (others=>'0');
            reg_k       <= (others=>'0');
            reg_dec     <= '0';
            reg_rdy     <= '0';
            reg_a1_rdy  <= '0';
            reg_a2_rdy  <= '0';
            reg_a3_rdy  <= '0';
            reg_a4_rdy  <= '0';
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
            output_rdy  <= '0';
        elsif(rising_edge(clk)) then
            reg_m       <= input;
            reg_k       <= key;
            reg_dec     <= enc_dec;
            reg_rdy     <= input_en;

            reg_a1_m    <= reg_m;
            reg_a1_dec  <= reg_dec;
            reg_a1_rdy  <= reg_rdy;
            reg_a2_m    <= reg_a1_m;
            reg_a2_dec  <= reg_a1_dec;
            reg_a2_rdy  <= reg_a1_rdy;
            reg_a3_m    <= reg_a2_m;
            reg_a3_dec  <= reg_a2_dec;
            reg_a3_rdy  <= reg_a2_rdy;
            reg_a4_m    <= reg_a3_m;
            reg_a4_dec  <= reg_a3_dec;
            reg_a4_rdy  <= reg_a3_rdy;

            reg_b1_dec  <= reg_a4_dec;
            reg_b1_k    <= out_ksched;
            reg_b1_rdy  <= reg_a4_rdy;
            reg_b2_dec  <= reg_b1_dec;
            reg_b2_k    <= reg_b1_k;
            reg_b2_rdy  <= reg_b1_rdy;
            reg_b3_dec  <= reg_b2_dec;
            reg_b3_k    <= reg_b2_k;
            reg_b3_rdy  <= reg_b2_rdy;
            reg_b4_dec  <= reg_b3_dec;
            reg_b4_k    <= reg_b3_k;
            reg_b4_rdy  <= reg_b3_rdy;
            reg_b5_dec  <= reg_b4_dec;
            reg_b5_k    <= reg_b4_k;
            reg_b5_rdy  <= reg_b4_rdy;
            reg_b6_dec  <= reg_b5_dec;
            reg_b6_k    <= reg_b5_k;
            reg_b6_rdy  <= reg_b5_rdy;
            reg_b7_dec  <= reg_b6_dec;
            reg_b7_k    <= reg_b6_k;
            reg_b7_rdy  <= reg_b6_rdy;
            reg_b8_dec  <= reg_b7_dec;
            reg_b8_k    <= reg_b7_k;
            reg_b8_rdy  <= reg_b7_rdy;
            reg_b9_dec  <= reg_b8_dec;
            reg_b9_k    <= reg_b8_k;
            reg_b9_rdy  <= reg_b8_rdy;
            reg_b10_dec <= reg_b9_dec;
            reg_b10_k   <= reg_b9_k;
            reg_b10_rdy <= reg_b9_rdy;
            reg_b11_dec <= reg_b10_dec;
            reg_b11_k   <= reg_b10_k;
            reg_b11_rdy <= reg_b10_rdy;
            reg_b12_dec <= reg_b11_dec;
            reg_b12_k   <= reg_b11_k;
            reg_b12_rdy <= reg_b11_rdy;
            reg_b13_dec <= reg_b12_dec;
            reg_b13_k   <= reg_b12_k;
            reg_b13_rdy <= reg_b12_rdy;
            reg_b14_dec <= reg_b13_dec;
            reg_b14_k   <= reg_b13_k;
            reg_b14_rdy <= reg_b13_rdy;
            reg_b15_dec <= reg_b14_dec;
            reg_b15_k   <= reg_b14_k;
            reg_b15_rdy <= reg_b14_rdy;
            reg_b16_dec <= reg_b15_dec;
            reg_b16_k   <= reg_b15_k;
            reg_b16_rdy <= reg_b15_rdy;
            reg_b17_dec <= reg_b16_dec;
            reg_b17_k   <= reg_b16_k;
            reg_b17_rdy <= reg_b16_rdy;
            reg_b18_dec <= reg_b17_dec;
            reg_b18_k   <= reg_b17_k;
            reg_b18_rdy <= reg_b17_rdy;
            reg_b19_dec <= reg_b18_dec;
            reg_b19_k   <= reg_b18_k;
            reg_b19_rdy <= reg_b18_rdy;
            reg_b20_dec <= reg_b19_dec;
            reg_b20_k   <= reg_b19_k;
            reg_b20_rdy <= reg_b19_rdy;

            -- outputs
            output     <= w3 & w4;
            output_rdy <= reg_b20_rdy;


        end if;
    end process;

    -- pre-whitening
    kw1_enc <= out_ksched(KL_OFFSET to KL_OFFSET+63);
    kw2_enc <= out_ksched(KL_OFFSET+64 to KL_OFFSET+127);

    ka_s111_dec <= out_ksched(KA_OFFSET+111 to KA_OFFSET+127) &
                   out_ksched(KA_OFFSET to KA_OFFSET+110);
    kw1_dec <= ka_s111_dec(0 to 63);
    kw2_dec <= ka_s111_dec(64 to 127);

    kw1 <= kw1_dec when reg_a4_dec='1' else kw1_enc;
    kw2 <= kw2_dec when reg_a4_dec='1' else kw2_enc;

    w1 <= reg_a4_m(0 to 63) xor kw1;
    w2 <= reg_a4_m(64 to 127) xor kw2;

    -- post-whitening
    ka_s111_enc <= reg_b20_k(KA_OFFSET+111 to KA_OFFSET+127) &
                   reg_b20_k(KA_OFFSET to KA_OFFSET+110);
    kw3_enc <= ka_s111_enc(0 to 63);
    kw4_enc <= ka_s111_enc(64 to 127);

    kw3_dec <= reg_b20_k(KL_OFFSET to KL_OFFSET+63);
    kw4_dec <= reg_b20_k(KL_OFFSET+64 to KL_OFFSET+127);

    kw3 <= kw3_dec when reg_b20_dec='1' else kw3_enc;
    kw4 <= kw4_dec when reg_b20_dec='1' else kw4_enc;

    w3 <= out_r3r xor kw3;
    w4 <= out_r3l xor kw4;

end RTL;
