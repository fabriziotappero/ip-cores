
--------------------------------------------------------------------------------
-- Designer:      Paolo Fulgoni <pfulgoni@opencores.org>
--
-- Create Date:   01/22/2008
-- Last Update:   02/25/2008
-- Project Name:  camellia-vhdl
-- Description:   VHDL Test Bench for module F
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

entity f_tb is
end f_tb;

ARCHITECTURE behavior of f_tb is

    -- Component Declaration for the Unit Under Test (UUT)
    component F
        port    (
                x     : in STD_LOGIC_VECTOR (0 to 63);
                k     : in STD_LOGIC_VECTOR (0 to 63);
                z     : out STD_LOGIC_VECTOR (0 to 63)
                );
    end component;

    --Inputs
    signal x     : STD_LOGIC_VECTOR(0 to 63)    := (others=>'0');
    signal k     : STD_LOGIC_VECTOR(0 to 63)    := (others=>'0');

    --Outputs
    signal z     : STD_LOGIC_VECTOR(0 to 63);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: F port map(
        x     => x,
        k     => k,
        z     => z
    );

    tb    : process
    begin
        x <= X"0123456789abcdef";
        k <= X"a09e667f3bcc908b";
        wait for 10 ns;
        x <= X"0000000000000000";
        k <= X"0000000000000000";
        wait;
    end process;


end;
