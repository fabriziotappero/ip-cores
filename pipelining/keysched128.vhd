
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/09/2008
-- Project Name:  camellia-vhdl
-- Description:   Key schedule only for 128-bit keys
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


entity KEYSCHED128 is
    port    (
            reset  : in STD_LOGIC;
            clk    : in STD_LOGIC;
            kl_in  : in STD_LOGIC_VECTOR (0 to 127);
            kl_out : out STD_LOGIC_VECTOR (0 to 127);
            ka_out : out STD_LOGIC_VECTOR (0 to 127)
            );
end KEYSCHED128;

architecture RTL of KEYSCHED128 is

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

    -- f outputs
    signal f1_out : STD_LOGIC_VECTOR (0 to 63);
    signal f2_out : STD_LOGIC_VECTOR (0 to 63);
    signal f3_out : STD_LOGIC_VECTOR (0 to 63);
    signal f4_out : STD_LOGIC_VECTOR (0 to 63);

    -- intermediate registers
    signal reg1_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg1_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg1_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg2_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg2_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg2_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg3_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg3_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg3_kl : STD_LOGIC_VECTOR (0 to 127);
    signal reg4_l  : STD_LOGIC_VECTOR (0 to 63);
    signal reg4_r  : STD_LOGIC_VECTOR (0 to 63);
    signal reg4_kl : STD_LOGIC_VECTOR (0 to 127);

    -- constant keys
    constant k1 : STD_LOGIC_VECTOR (0 to 63) := X"A09E667F3BCC908B";
    constant k2 : STD_LOGIC_VECTOR (0 to 63) := X"B67AE8584CAA73B2";
    constant k3 : STD_LOGIC_VECTOR (0 to 63) := X"C6EF372FE94F82BE";
    constant k4 : STD_LOGIC_VECTOR (0 to 63) := X"54FF53A5F1D36F1C";

    -- intermediate signal
    signal inter   : STD_LOGIC_VECTOR (0 to 127);

begin

    F1 : F
        port map(reset, clk, f1_in, k1, f1_out);
    F2 : F
        port map(reset, clk, f2_in, k2, f2_out);
    F3 : F
        port map(reset, clk, f3_in, k3, f3_out);
    F4 : F
        port map(reset, clk, f4_in, k4, f4_out);

    REG : process(reset, clk)
    begin

        if (reset = '1') then
            reg1_l  <= (others=>'0');
            reg1_r  <= (others=>'0');
            reg1_kl <= (others=>'0');
            reg2_l  <= (others=>'0');
            reg2_r  <= (others=>'0');
            reg2_kl <= (others=>'0');
            reg3_l  <= (others=>'0');
            reg3_r  <= (others=>'0');
            reg3_kl <= (others=>'0');
            reg4_l  <= (others=>'0');
            reg4_r  <= (others=>'0');
            reg4_kl <= (others=>'0');
        else
            if (rising_edge(clk)) then -- rising clock edge
                reg1_l  <= f1_in;
                reg1_r  <= kl_in(64 to 127);
                reg1_kl <= kl_in;
                reg2_l  <= f2_in;
                reg2_r  <= reg1_l;
                reg2_kl <= reg1_kl;
                reg3_l  <= f3_in;
                reg3_r  <= inter(64 to 127);
                reg3_kl <= reg2_kl;
                reg4_l  <= f4_in;
                reg4_r  <= reg3_l;
                reg4_kl <= reg3_kl;
            end if;
        end if;
    end process;

    inter  <= ((f2_out xor reg2_r) & reg2_l) xor reg2_kl;

    -- f inputs
    f1_in <= kl_in(0 to 63);
    f2_in <= f1_out xor reg1_r;
    f3_in <= inter(0 to 63);
    f4_in <= f3_out xor reg3_r;

    -- output
    kl_out <= reg4_kl;
    ka_out <= (f4_out xor reg4_r) & reg4_l;

end RTL;
