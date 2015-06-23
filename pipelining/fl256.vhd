
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/09/2008
-- Project Name:  camellia-vhdl
-- Description:   FL and FL^-1 functions, for 128/192/256-bit key en/decryption
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


entity FL256 is
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
end FL256;

architecture RTL of FL256 is

    signal fl_in_l  : STD_LOGIC_VECTOR (0 to 31);
    signal fl_in_r  : STD_LOGIC_VECTOR (0 to 31);
    signal fli_in_l : STD_LOGIC_VECTOR (0 to 31);
    signal fli_in_r : STD_LOGIC_VECTOR (0 to 31);

    signal fl_ke128  : STD_LOGIC_VECTOR (0 to 127); -- 128bit encryption
    signal fli_ke128 : STD_LOGIC_VECTOR (0 to 127);
    signal fl_kd128  : STD_LOGIC_VECTOR (0 to 127); -- 128bit decryption
    signal fli_kd128 : STD_LOGIC_VECTOR (0 to 127);
    signal fl_ke256  : STD_LOGIC_VECTOR (0 to 127); -- 192/256bit encryption
    signal fli_ke256 : STD_LOGIC_VECTOR (0 to 127);
    signal fl_kd256  : STD_LOGIC_VECTOR (0 to 127); -- 192/256bit decryption
    signal fli_kd256 : STD_LOGIC_VECTOR (0 to 127);
    signal fl_k_l    : STD_LOGIC_VECTOR (0 to 31);
    signal fl_k_r    : STD_LOGIC_VECTOR (0 to 31);
    signal fli_k_l   : STD_LOGIC_VECTOR (0 to 31);
    signal fli_k_r   : STD_LOGIC_VECTOR (0 to 31);

    signal fl_a1  : STD_LOGIC_VECTOR (0 to 31);
    signal fl_a2  : STD_LOGIC_VECTOR (0 to 31);
    signal fl_b1  : STD_LOGIC_VECTOR (0 to 31);
    signal fl_b2  : STD_LOGIC_VECTOR (0 to 31);
    signal fli_a1 : STD_LOGIC_VECTOR (0 to 31);
    signal fli_a2 : STD_LOGIC_VECTOR (0 to 31);
    signal fli_b1 : STD_LOGIC_VECTOR (0 to 31);
    signal fli_b2 : STD_LOGIC_VECTOR (0 to 31);

    -- registers
    signal reg_fl_in  : STD_LOGIC_VECTOR (0 to 63);
    signal reg_fli_in : STD_LOGIC_VECTOR (0 to 63);

    begin

    REG : process(reset, clk)
    begin

        if (reset = '1') then
            reg_fl_in  <= (others=>'0');
            reg_fli_in <= (others=>'0');
        else
            if (rising_edge(clk)) then -- rising clock edge
                reg_fl_in  <= fl_in;
                reg_fli_in <= fli_in;
            end if;
        end if;
    end process;

    --FL function
    fl_in_l <= reg_fl_in(0 to 31);
    fl_in_r <= reg_fl_in(32 to 63);

    fl_ke128 <= k(fl_ke128_offset+fl_ke128_shift to fl_ke128_offset+127) &
                    k(fl_ke128_offset to fl_ke128_offset+fl_ke128_shift-1);
    fl_kd128 <= k(fl_kd128_offset+fl_kd128_shift to fl_kd128_offset+127) &
                    k(fl_kd128_offset to fl_kd128_offset+fl_kd128_shift-1);
    fl_ke256 <= k(fl_ke256_offset+fl_ke256_shift to fl_ke256_offset+127) &
                    k(fl_ke256_offset to fl_ke256_offset+fl_ke256_shift-1);
    fl_kd256 <= k(fl_kd256_offset+fl_kd256_shift to fl_kd256_offset+127) &
                    k(fl_kd256_offset to fl_kd256_offset+fl_kd256_shift-1);
    fl_k_l <= fl_ke128(0 to 31)  when dec='0' and k_len(0)='0' else
              fl_kd128(64 to 95) when dec='1' and k_len(0)='0' else
              fl_ke256(0 to 31)  when dec='0' and k_len(0)='1' else
              fl_kd256(64 to 95);
    fl_k_r <= fl_ke128(32 to 63)  when dec='0' and k_len(0)='0' else
              fl_kd128(96 to 127) when dec='1' and k_len(0)='0' else
              fl_ke256(32 to 63)  when dec='0' and k_len(0)='1' else
              fl_kd256(96 to 127);

    fl_a1 <= fl_in_l and fl_k_l;
    fl_a2 <= (fl_a1(1 to 31) & fl_a1(0)) xor fl_in_r;

    fl_b1 <= fl_a2 or fl_k_r;
    fl_b2 <= fl_in_l xor fl_b1;

    fl_out <= fl_b2 & fl_a2;

    --FL^-1 function
    fli_in_l <= reg_fli_in(0 to 31);
    fli_in_r <= reg_fli_in(32 to 63);

    fli_ke128 <= k(fli_ke128_offset+fli_ke128_shift to fli_ke128_offset+127) &
                    k(fli_ke128_offset to fli_ke128_offset+fli_ke128_shift-1);
    fli_kd128 <= k(fli_kd128_offset+fli_kd128_shift to fli_kd128_offset+127) &
                    k(fli_kd128_offset to fli_kd128_offset+fli_kd128_shift-1);
    fli_ke256 <= k(fli_ke256_offset+fli_ke256_shift to fli_ke256_offset+127) &
                    k(fli_ke256_offset to fli_ke256_offset+fli_ke256_shift-1);
    fli_kd256 <= k(fli_kd256_offset+fli_kd256_shift to fli_kd256_offset+127) &
                    k(fli_kd256_offset to fli_kd256_offset+fli_kd256_shift-1);
    fli_k_l <= fli_ke128(64 to 95) when dec='0' and k_len(0)='0' else
               fli_kd128(0 to 31)  when dec='1' and k_len(0)='0' else
               fli_ke256(64 to 95) when dec='0' and k_len(0)='1' else
               fli_kd256(0 to 31);
    fli_k_r <= fli_ke128(96 to 127) when dec='0' and k_len(0)='0' else
               fli_kd128(32 to 63)  when dec='1' and k_len(0)='0' else
               fli_ke256(96 to 127) when dec='0' and k_len(0)='1' else
               fli_kd256(32 to 63);

    fli_a1 <= fli_in_r or fli_k_r;
    fli_a2 <= fli_in_l xor fli_a1;

    fli_b1 <= fli_a2 and fli_k_l;
    fli_b2 <= (fli_b1(1 to 31) & fli_b1(0)) xor fli_in_r;

    fli_out <= fli_a2 & fli_b2;

end RTL;
