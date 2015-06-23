-- Copyright © 2009 Belousov Oleg <belousov.oleg@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rtea is
    generic (
        KEY_SIZE        : in integer := 128                     -- 128 or 256 only
    );
    port (
        clk             : in std_logic;
        start           : in std_logic;
        mode            : in std_logic;                         -- 0 = encode, 1 = decode
        din             : in std_logic_vector(63 downto 0);
        key             : in std_logic_vector(KEY_SIZE-1 downto 0);
        dout            : out std_logic_vector(63 downto 0);
        busy            : out std_logic);
end entity rtea;

architecture behave of rtea is
    signal max_round    : unsigned(5 downto 0);
    signal round        : unsigned(5 downto 0);

    signal l            : unsigned(31 downto 0);
    signal r            : unsigned(31 downto 0);

    signal key_slice    : unsigned(31 downto 0);
    signal f_r          : unsigned(31 downto 0);
    signal f_l          : unsigned(31 downto 0);
    signal run          : std_logic := '0';
    signal mode_reg     : std_logic;

begin
    key256: if KEY_SIZE = 256 generate
        max_round <= "111111";

        key_slice <=
            unsigned(key(31 downto 0)) when round(2 downto 0) = "000" else
            unsigned(key(63 downto 32)) when round(2 downto 0) = "001" else
            unsigned(key(95 downto 64)) when round(2 downto 0) = "010" else
            unsigned(key(127 downto 96)) when round(2 downto 0) = "011" else
            unsigned(key(159 downto 128)) when round(2 downto 0) = "100" else
            unsigned(key(191 downto 160)) when round(2 downto 0) = "101" else
            unsigned(key(223 downto 192)) when round(2 downto 0) = "110" else
            unsigned(key(255 downto 224));
    end generate;

    key128: if KEY_SIZE = 128 generate
        max_round <= "101111";

        key_slice <=
            unsigned(key(31 downto 0)) when round(1 downto 0) = "00" else
            unsigned(key(63 downto 32)) when round(1 downto 0) = "01" else
            unsigned(key(95 downto 64)) when round(1 downto 0) = "10" else
            unsigned(key(127 downto 96));
    end generate;

    busy <= run;

    f_r <= (r + round + key_slice) + ((r(25 downto 0) & "000000") xor ("00000000" & r(31 downto 8)));
    f_l <= (l + round + key_slice) + ((l(25 downto 0) & "000000") xor ("00000000" & l(31 downto 8)));

    process (clk) begin
        if rising_edge(clk) then
            if start = '0' then
                l <= unsigned(din(31 downto 0));
                r <= unsigned(din(63 downto 32));
                mode_reg <= mode;
                run <= '1';

                if mode = '0' then
                    round <= "000000";
                else
                    round <= max_round;
                end if;
            else
                if run = '1' then
                    if mode_reg = '0' then
                        r <= l + f_r;
                        l <= r;
                    else
                        l <= r - f_l;
                        r <= l;
                    end if;
                else
                    dout(31 downto 0) <= std_logic_vector(l);
                    dout(63 downto 32) <= std_logic_vector(r);
                end if;

                if mode_reg = '0' then
                    if round = max_round then
                        run <= '0';
                    else
                        round <= round + 1;
                    end if;
                else
                    if round = "000000" then
                        run <= '0';
                    else
                        round <= round - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

end behave;
