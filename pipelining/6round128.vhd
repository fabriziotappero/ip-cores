
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/09/2008
-- Project Name:  camellia-vhdl
-- Description:   Six rounds of F, only for 128-bit key en/decryption
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


entity SIXROUND128 is
    generic (
            k1e_offset  : INTEGER; -- encryption
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
            k1d_offset  : INTEGER; -- decryption
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
end SIXROUND128;

architecture RTL of SIXROUND128 is

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
    signal t_enc1 : STD_LOGIC_VECTOR (0 to 127);
    signal t_enc2 : STD_LOGIC_VECTOR (0 to 127);
    signal t_enc3 : STD_LOGIC_VECTOR (0 to 127);
    signal t_enc4 : STD_LOGIC_VECTOR (0 to 127);
    signal t_enc5 : STD_LOGIC_VECTOR (0 to 127);
    signal t_enc6 : STD_LOGIC_VECTOR (0 to 127);
    signal t_dec1 : STD_LOGIC_VECTOR (0 to 127);
    signal t_dec2 : STD_LOGIC_VECTOR (0 to 127);
    signal t_dec3 : STD_LOGIC_VECTOR (0 to 127);
    signal t_dec4 : STD_LOGIC_VECTOR (0 to 127);
    signal t_dec5 : STD_LOGIC_VECTOR (0 to 127);
    signal t_dec6 : STD_LOGIC_VECTOR (0 to 127);
    signal int_k1 : STD_LOGIC_VECTOR (0 to 63);
    signal int_k2 : STD_LOGIC_VECTOR (0 to 63);
    signal int_k3 : STD_LOGIC_VECTOR (0 to 63);
    signal int_k4 : STD_LOGIC_VECTOR (0 to 63);
    signal int_k5 : STD_LOGIC_VECTOR (0 to 63);
    signal int_k6 : STD_LOGIC_VECTOR (0 to 63);

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

    -- shift of kl, ka
    t_enc1 <= k1(k1e_offset+k1e_shift to k1e_offset+127) &
                k1(k1e_offset to k1e_offset+k1e_shift-1);
    t_enc2 <= k2(k2e_offset+k2e_shift to k2e_offset+127) &
                k2(k2e_offset to k2e_offset+k2e_shift-1);
    t_enc3 <= k3(k3e_offset+k3e_shift to k3e_offset+127) &
                k3(k3e_offset to k3e_offset+k3e_shift-1);
    t_enc4 <= k4(k4e_offset+k4e_shift to k4e_offset+127) &
                k4(k4e_offset to k4e_offset+k4e_shift-1);
    t_enc5 <= k5(k5e_offset+k5e_shift to k5e_offset+127) &
                k5(k5e_offset to k5e_offset+k5e_shift-1);
    t_enc6 <= k6(k6e_offset+k6e_shift to k6e_offset+127) &
                k6(k6e_offset to k6e_offset+k6e_shift-1);

    t_dec1 <= k1(k1d_offset+k1d_shift to k1d_offset+127) &
                k1(k1d_offset to k1d_offset+k1d_shift-1);
    t_dec2 <= k2(k2d_offset+k2d_shift to k2d_offset+127) &
                k2(k2d_offset to k2d_offset+k2d_shift-1);
    t_dec3 <= k3(k3d_offset+k3d_shift to k3d_offset+127) &
                k3(k3d_offset to k3d_offset+k3d_shift-1);
    t_dec4 <= k4(k4d_offset+k4d_shift to k4d_offset+127) &
                k4(k4d_offset to k4d_offset+k4d_shift-1);
    t_dec5 <= k5(k5d_offset+k5d_shift to k5d_offset+127) &
                k5(k5d_offset to k5d_offset+k5d_shift-1);
    t_dec6 <= k6(k6d_offset+k6d_shift to k6d_offset+127) &
                k6(k6d_offset to k6d_offset+k6d_shift-1);

    -- subkeys generation
    -- int_k1, int_k3, int_k5 get always the left/right slice when en/decrypting
    -- int_k2, int_k4, int_k6 get always the right/left slice when en/decrypting
    int_k1 <= t_enc1(0 to 63)   when dec1='0' else t_dec1(64 to 127);
    int_k2 <= t_enc2(64 to 127) when dec2='0' else t_dec2(0 to 63);
    int_k3 <= t_enc3(0 to 63)   when dec3='0' else t_dec3(64 to 127);
    int_k4 <= t_enc4(64 to 127) when dec4='0' else t_dec4(0 to 63);
    int_k5 <= t_enc5(0 to 63)   when dec5='0' else t_dec5(64 to 127);
    int_k6 <= t_enc6(64 to 127) when dec6='0' else t_dec6(0 to 63);

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
