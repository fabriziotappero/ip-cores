
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   01/22/2008
-- Last Update:   03/04/2008
-- Project Name:  camellia-vhdl
-- Description:   Datapath
--
-- Copyright (C) 2008  Paolo Fulgoni
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

entity datapath is
    port    (
            clk      : in STD_LOGIC;
            reset    : in STD_LOGIC;
            data_in  : in STD_LOGIC_VECTOR (0 to 127);
            k1       : in STD_LOGIC_VECTOR (0 to 63);
            k2       : in STD_LOGIC_VECTOR (0 to 63);
            newdata  : in STD_LOGIC;
            sel      : in STD_LOGIC;    -- 0 if F,  1 if FL
            pre_xor  : in STD_LOGIC_VECTOR (0 to 127);
            post_xor : in STD_LOGIC_VECTOR (0 to 127);
            data_out : out STD_LOGIC_VECTOR (0 to 127)
            );
end datapath;

architecture RTL of datapath is

    component F is
        port    (
                x     : in  STD_LOGIC_VECTOR (0 to 63);
                k     : in  STD_LOGIC_VECTOR (0 to 63);
                z     : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;

    component FL is
        port(
                fl_in   : in  STD_LOGIC_VECTOR (0 to 63);
                fli_in  : in  STD_LOGIC_VECTOR (0 to 63);
                fl_k    : in  STD_LOGIC_VECTOR (0 to 63);
                fli_k   : in  STD_LOGIC_VECTOR (0 to 63);
                fl_out  : out STD_LOGIC_VECTOR (0 to 63);
                fli_out : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;

    signal f_in    : STD_LOGIC_VECTOR (0 to 63);
    signal f_k     : STD_LOGIC_VECTOR (0 to 63);
    signal f_out   : STD_LOGIC_VECTOR (0 to 63);
    signal fl_in   : STD_LOGIC_VECTOR (0 to 63);
    signal fl_k    : STD_LOGIC_VECTOR (0 to 63);
    signal fl_out  : STD_LOGIC_VECTOR (0 to 63);
    signal fli_in  : STD_LOGIC_VECTOR (0 to 63);
    signal fli_k   : STD_LOGIC_VECTOR (0 to 63);
    signal fli_out : STD_LOGIC_VECTOR (0 to 63);

    signal data_in_sx : STD_LOGIC_VECTOR (0 to 63);
    signal data_in_dx : STD_LOGIC_VECTOR (0 to 63);
    signal pre_xor_sx : STD_LOGIC_VECTOR (0 to 63);
    signal pre_xor_dx : STD_LOGIC_VECTOR (0 to 63);

    signal mux1       : STD_LOGIC_VECTOR (0 to 63);
    signal mux1_pxor  : STD_LOGIC_VECTOR (0 to 63);
    signal mux2       : STD_LOGIC_VECTOR (0 to 63);
    signal mux2_pxor  : STD_LOGIC_VECTOR (0 to 63);
    signal f_out_xor  : STD_LOGIC_VECTOR (0 to 63);

    signal reg_fl_out    : STD_LOGIC_VECTOR (0 to 63);
    signal reg_fli_out   : STD_LOGIC_VECTOR (0 to 63);
    signal reg_f_out_xor : STD_LOGIC_VECTOR (0 to 63);
    signal reg_mux2_pxor : STD_LOGIC_VECTOR (0 to 63);
    signal reg_sel       : STD_LOGIC;

    constant SEL_F    : STD_LOGIC := '0';
    constant SEL_FL   : STD_LOGIC := '1';

begin

    F1  : F
        port map(f_in, f_k, f_out);

    FL1  : FL
        port map(fl_in, fli_in, fl_k, fli_k, fl_out, fli_out);


    data_in_sx <= data_in(0 to 63);
    data_in_dx <= data_in(64 to 127);
    pre_xor_sx <= pre_xor(0 to 63);
    pre_xor_dx <= pre_xor(64 to 127);
    f_in       <= mux2_pxor;
    f_k        <= k1;
    fl_in      <= reg_f_out_xor;
    fl_k       <= k1;
    fli_in     <= reg_mux2_pxor;
    fli_k      <= k2;
    f_out_xor  <= f_out xor mux1_pxor;

    mux1 <= reg_fli_out     when newdata='0' and reg_sel=SEL_FL else
            reg_mux2_pxor   when newdata='0' and reg_sel=SEL_F  else
            data_in_dx;
    mux2 <= reg_fl_out      when newdata='0' and reg_sel=SEL_FL else
            reg_f_out_xor   when newdata='0' and reg_sel=SEL_F  else
            data_in_sx;

    mux1_pxor  <= mux1 xor pre_xor_dx;
    mux2_pxor  <= mux2 xor pre_xor_sx;

    data_out   <= (f_out_xor & mux2_pxor) xor post_xor;

    REGISTERS: process(clk, reset)
    begin

        if (reset = '1') then
            reg_fl_out    <= (others=>'0');
            reg_fli_out   <= (others=>'0');
            reg_f_out_xor <= (others=>'0');
            reg_mux2_pxor <= (others=>'0');
            reg_sel       <= SEL_F;
        elsif (clk'event and clk='1') then
            reg_fl_out    <= fl_out;
            reg_fli_out   <= fli_out;
            reg_f_out_xor <= f_out_xor;
            reg_mux2_pxor <= mux2_pxor;
            reg_sel       <= sel;
        end if;

    end process;

end RTL;
