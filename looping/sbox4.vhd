
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   01/22/2008
-- Last Update:   02/19/2008
-- Project Name:  camellia-vhdl
-- Description:   Asynchronous SBOX4
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


entity SBOX4 is
    port    (
            data_in  : IN STD_LOGIC_VECTOR(0 to 7);
            data_out : OUT STD_LOGIC_VECTOR(0 to 7)
            );
end SBOX4;

architecture RTL of SBOX4 is

    component SBOX1 is
        port  (
               data_in  : IN STD_LOGIC_VECTOR(0 to 7);
               data_out : OUT STD_LOGIC_VECTOR(0 to 7)
                );
    end component;

    -- SBOX1 signals
    signal s1_data_in  : STD_LOGIC_VECTOR(0 to 7);
    signal s1_data_out : STD_LOGIC_VECTOR(0 to 7);

begin

    S1 : SBOX1
        port map(s1_data_in, s1_data_out);

    s1_data_in <= data_in(1 to 7) & data_in(0);
    data_out <= s1_data_out;

end RTL;
