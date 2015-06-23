----------------------------------------------------------------------------------------------
--
--      Input file         : mblite_stdio.vhd
--      Design name        : mblite_stdio
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Simulates standard output using stdio package
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

use std.textio.all;

entity mblite_stdio is port
(
    dmem_i : out dmem_in_type;
    dmem_o : in dmem_out_type;
    clk_i  : in std_logic
);
end mblite_stdio;

architecture arch of mblite_stdio is
begin
    -- Character device
    stdio: process(clk_i)
            variable s    : line;
            variable byte : std_logic_vector(7 downto 0);
            variable char : character;
        begin
            dmem_i.dat_i <= (others => '0');
            dmem_i.ena_i <= '1';
            if rising_edge(clk_i) then
                if dmem_o.ena_o = '1' then
                    if dmem_o.we_o = '1' then
                    -- WRITE STDOUT
                        case dmem_o.sel_o is
                            when "0001" => byte := dmem_o.dat_o( 7 downto  0);
                            when "0010" => byte := dmem_o.dat_o(15 downto  8);
                            when "0100" => byte := dmem_o.dat_o(23 downto 16);
                            when "1000" => byte := dmem_o.dat_o(31 downto 24);
                            when others => null;
                        end case;
                        char := character'val(my_conv_integer(byte));
                        if byte = x"0d" then
                            -- Ignore character 13
                        elsif byte = x"0a" then
                            -- Writeline on character 10 (newline)
                            writeline(output, s);
                        else
                            -- Write to buffer
                            write(s, char);
                        end if;
                    end if;
                end if;
            end if;
    end process;
end arch;