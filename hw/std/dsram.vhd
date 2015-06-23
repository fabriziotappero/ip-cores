----------------------------------------------------------------------------------------------
--
--      Input file         : dsram.vhd
--      Design name        : dsram
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Dual Port Synchronous 'read after write' Ram. 1 Read Port and 1
--                           Write Port.
--
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.std_Pkg.all;

entity dsram is generic
(
    WIDTH : positive := 32;
    SIZE  : positive := 8
);
port
(
    dat_o   : out std_logic_vector(WIDTH - 1 downto 0);
    adr_i   : in std_logic_vector(SIZE - 1 downto 0);
    ena_i   : in std_logic;
    dat_w_i : in std_logic_vector(WIDTH - 1 downto 0);
    adr_w_i : in std_logic_vector(SIZE - 1 downto 0);
    wre_i   : in std_logic;
    clk_i   : in std_logic
);
end dsram;

architecture arch of dsram is
    type ram_type is array(2 ** SIZE - 1 downto 0) of std_logic_vector(WIDTH - 1 downto 0);
    signal ram :  ram_type;
begin
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if ena_i = '1' then
                if wre_i = '1' then
                    ram(my_conv_integer(adr_w_i)) <= dat_w_i;
                end if;
                dat_o <= ram(my_conv_integer(adr_i));
            end if;
        end if;
    end process;
end arch;
