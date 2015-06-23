
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/14/2008
-- Project Name:  camellia-vhdl
-- Description:   Dual-port SBOX4
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


entity SBOX4 is
    port  (
    		clk   : IN  STD_LOGIC;
            addra : IN  STD_LOGIC_VECTOR(0 to 7);
            addrb : IN  STD_LOGIC_VECTOR(0 to 7);
            douta : OUT STD_LOGIC_VECTOR(0 to 7);
            doutb : OUT STD_LOGIC_VECTOR(0 to 7)
            );
end SBOX4;

architecture RTL of SBOX4 is

    component SBOX1 is
        port  (
                clk   : IN  STD_LOGIC;
                addra : IN  STD_LOGIC_VECTOR(0 to 7);
                addrb : IN  STD_LOGIC_VECTOR(0 to 7);
                douta : OUT STD_LOGIC_VECTOR(0 to 7);
                doutb : OUT STD_LOGIC_VECTOR(0 to 7)
                );
    end component;

    -- SBOX1 signals
    signal s1_addra : STD_LOGIC_VECTOR(0 to 7);
    signal s1_addrb : STD_LOGIC_VECTOR(0 to 7);
    signal s1_clk  : STD_LOGIC;
    signal s1_douta : STD_LOGIC_VECTOR(0 to 7);
    signal s1_doutb : STD_LOGIC_VECTOR(0 to 7);

begin

    S1 : SBOX1
        port map(s1_clk, s1_addra, s1_addrb, s1_douta, s1_doutb);

    s1_clk   <= clk;
    s1_addra <= addra(1 to 7) & addra(0);
    s1_addrb <= addrb(1 to 7) & addrb(0);

    douta <= s1_douta;
    doutb <= s1_doutb;

end RTL;
