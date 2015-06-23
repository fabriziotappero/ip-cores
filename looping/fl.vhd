
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   01/22/2008
-- Last Update:   02/21/2008
-- Project Name:  camellia-vhdl
-- Description:   Asynchronous FL and FL^-1 functions
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


entity FL is
    port(
            fl_in   : in  STD_LOGIC_VECTOR (0 to 63);
            fli_in  : in  STD_LOGIC_VECTOR (0 to 63);
            fl_k    : in  STD_LOGIC_VECTOR (0 to 63);
            fli_k   : in  STD_LOGIC_VECTOR (0 to 63);
            fl_out  : out STD_LOGIC_VECTOR (0 to 63);
            fli_out : out STD_LOGIC_VECTOR (0 to 63)
            );
end FL;

architecture RTL of FL is

    signal fl_a1  : STD_LOGIC_VECTOR (0 to 31);
    signal fl_a2  : STD_LOGIC_VECTOR (0 to 31);
    signal fl_b1  : STD_LOGIC_VECTOR (0 to 31);
    signal fl_b2  : STD_LOGIC_VECTOR (0 to 31);
    signal fli_a1 : STD_LOGIC_VECTOR (0 to 31);
    signal fli_a2 : STD_LOGIC_VECTOR (0 to 31);
    signal fli_b1 : STD_LOGIC_VECTOR (0 to 31);
    signal fli_b2 : STD_LOGIC_VECTOR (0 to 31);

    begin

    --FL function
    fl_a1 <= fl_in(0 to 31) and fl_k(0 to 31);
    fl_a2 <= (fl_a1(1 to 31) & fl_a1(0)) xor fl_in(32 to 63);

    fl_b1 <= fl_a2 or fl_k(32 to 63);
    fl_b2 <= fl_in(0 to 31) xor fl_b1;

    fl_out <= fl_b2 & fl_a2;

    --FL^-1 function
    fli_a1 <= fli_in(32 to 63) or fli_k(32 to 63);
    fli_a2 <= fli_in(0 to 31) xor fli_a1;

    fli_b1 <= fli_a2 and fli_k(0 to 31);
    fli_b2 <= (fli_b1(1 to 31) & fli_b1(0)) xor fli_in(32 to 63);

    fli_out <= fli_a2 & fli_b2;

end RTL;
