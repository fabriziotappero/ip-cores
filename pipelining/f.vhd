
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   04/09/2008
-- Project Name:  camellia-vhdl
-- Description:   F function
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

entity F is
    port    (
            reset : in STD_LOGIC;
            clk   : in STD_LOGIC;
            x     : in STD_LOGIC_VECTOR (0 to 63);
            k     : in STD_LOGIC_VECTOR (0 to 63);
            z     : out STD_LOGIC_VECTOR (0 to 63)
            );
end F;

architecture RTL of F is

    -- S-BOX
    component SBOX1 is
        port  (
                clk   : IN  STD_LOGIC;
                addra : IN  STD_LOGIC_VECTOR(0 to 7);
                addrb : IN  STD_LOGIC_VECTOR(0 to 7);
                douta : OUT STD_LOGIC_VECTOR(0 to 7);
                doutb : OUT STD_LOGIC_VECTOR(0 to 7)
                );
    end component;
    component SBOX2 is
        port  (
                clk   : IN  STD_LOGIC;
                addra : IN  STD_LOGIC_VECTOR(0 to 7);
                addrb : IN  STD_LOGIC_VECTOR(0 to 7);
                douta : OUT STD_LOGIC_VECTOR(0 to 7);
                doutb : OUT STD_LOGIC_VECTOR(0 to 7)

                );
    end component;
    component SBOX3 is
        port  (
                clk   : IN  STD_LOGIC;
                addra : IN  STD_LOGIC_VECTOR(0 to 7);
                addrb : IN  STD_LOGIC_VECTOR(0 to 7);
                douta : OUT STD_LOGIC_VECTOR(0 to 7);
                doutb : OUT STD_LOGIC_VECTOR(0 to 7)

                );
    end component;
    component SBOX4 is
        port  (
                clk   : IN  STD_LOGIC;
                addra : IN  STD_LOGIC_VECTOR(0 to 7);
                addrb : IN  STD_LOGIC_VECTOR(0 to 7);
                douta : OUT STD_LOGIC_VECTOR(0 to 7);
                doutb : OUT STD_LOGIC_VECTOR(0 to 7)

                );
    end component;


    signal y : STD_LOGIC_VECTOR (0 to 63);
    signal y1, y2, y3, y4, y5, y6, y7, y8 : STD_LOGIC_VECTOR (0 to 7);

    signal so1, so2, so3, so4, so5, so6, so7, so8 : STD_LOGIC_VECTOR (0 to 7);

    signal pa1, pa2, pa3, pa4, pa5, pa6, pa7, pa8 : STD_LOGIC_VECTOR (0 to 7);

    signal pb1, pb2, pb3, pb4, pb5, pb6, pb7, pb8 : STD_LOGIC_VECTOR (0 to 7);


    begin

        y <= x xor k;

        y8 <= y(56 to 63);
        y7 <= y(48 to 55);
        y6 <= y(40 to 47);
        y5 <= y(32 to 39);
        y4 <= y(24 to 31);
        y3 <= y(16 to 23);
        y2 <= y(8 to 15);
        y1 <= y(0 to 7);


        -- S-FUNCTION

        S1 : SBOX1
            port map(clk, y8, y1, so8, so1);
        S2 : SBOX2
            port map(clk, y5, y2, so5, so2);
        S3 : SBOX3
            port map(clk, y6, y3, so6, so3);
        S4 : SBOX4
            port map(clk, y7, y4, so7, so4);

        -- P-FUNCTION
        pa8 <= so8 xor pa2;
        pa7 <= so7 xor pa1;
        pa6 <= so6 xor pa4;
        pa5 <= so5 xor pa3;
        pa4 <= so4 xor so5;
        pa3 <= so3 xor so8;
        pa2 <= so2 xor so7;
        pa1 <= so1 xor so6;

        pb8 <= pa8 xor pb3;
        pb7 <= pa7 xor pb2;
        pb6 <= pa6 xor pb1;
        pb5 <= pa5 xor pb4;
        pb4 <= pa4 xor pa7;
        pb3 <= pa3 xor pa6;
        pb2 <= pa2 xor pa5;
        pb1 <= pa1 xor pa8;


        z <= pb5 & pb6 & pb7 & pb8 & pb1 & pb2 & pb3 & pb4;


    end RTL;
