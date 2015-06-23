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

entity rtea_tb is
end rtea_tb;

architecture behav of rtea_tb is
    component rtea is
        generic(
            KEY_SIZE        : in integer := 256
        );
        port (
            clk             : in std_logic;
            start           : in std_logic;
            mode            : in std_logic;
            din             : in std_logic_vector(63 downto 0);
            key             : in std_logic_vector(KEY_SIZE-1 downto 0);
            dout            : out std_logic_vector(63 downto 0);
            busy            : out std_logic);
    end component;

    constant key_size   : integer := 256;

    signal clk          : std_logic := '0';
    signal start        : std_logic;
    signal busy         : std_logic;
    signal din          : std_logic_vector(63 downto 0);
    signal key          : std_logic_vector(key_size-1 downto 0);
    signal dout         : std_logic_vector(63 downto 0);
begin

    rtea_i : rtea
        generic map(
            key_size    => key_size
        )
        port map(
            clk         => clk,
            start       => start,
            mode        => '0',
            din         => din,
            key         => key,
            dout        => dout
        );

    process begin
        clk <= '0';
        wait for 10.0 ns;
        clk <= '1';
        wait for 10.0 ns;
    end process;

    process is begin
        start <= '0';
        wait until rising_edge(clk);
        start <= '1';
        wait;
    end process;

    din <= x"11112222_12345678";
    key <=  (others => '0');

    process begin
        wait for 100 ns;
        assert false report "end of test" severity note;
        wait;
    end process;

end behav;
