
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   09/14/2007
-- Last Update:   09/25/2007
-- Project Name:  camellia-vhdl
-- Description:   VHDL Test Bench for module F
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

entity f_tb is
end f_tb;

ARCHITECTURE behavior of f_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component F
        port    (
                reset : in STD_LOGIC;
                clk   : in STD_LOGIC;
                x     : in STD_LOGIC_VECTOR (0 to 63);
                k     : in STD_LOGIC_VECTOR (0 to 63);
                z     : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;

    --Inputs
    signal reset : STD_LOGIC;
    signal clk   : STD_LOGIC;
    signal x     : STD_LOGIC_VECTOR(0 to 63)    := (others=>'0');
    signal k     : STD_LOGIC_VECTOR(0 to 63)    := (others=>'0');

    --Outputs
    signal z     : STD_LOGIC_VECTOR(0 to 63);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: F port map(
        reset => reset,
        clk   => clk,
        x     => x,
        k     => k,
        z     => z
    );

    tb    : process
    begin
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
        x <= X"abcdef1234567890";
        k <= X"0987654321abcdef";
        wait for 30 ns;
        x <= X"0000000000000000";
        k <= X"0000000000000000";
        wait;
    end process;

    ck : process
    begin
        clk <= '0';
        wait for 15 ns;
        clk <= '1';
        wait for 15 ns;
    end process;

end;
