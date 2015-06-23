----------------------------------------------------------------------------------------------
--
--      Input file         : wb_stdio.vhd
--      Design name        : wb_stdio
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

entity wb_stdio is port
(
    wb_o : out wb_slv_out_type;
    wb_i : in wb_slv_in_type
);
end wb_stdio;

architecture arch of wb_stdio is
    constant ack_assert_delay : TIME := 2 ns;
    constant ack_deassert_delay : TIME := 2 ns;
    signal ack : std_logic;
    signal chr_dat : std_logic_vector(31 downto 0);
    signal chr_cnt : natural := 0;
begin
    wb_o.int_o <= '0';
    wb_o.dat_o <= chr_dat;
    -- Character device
    stdio: process(wb_i.clk_i)
        variable s    : line;
        variable byte : std_logic_vector(7 downto 0);
        variable char : character;
    begin
        if rising_edge(wb_i.clk_i) then
            if (wb_i.stb_i and wb_i.cyc_i) = '1' then
                if wb_i.we_i = '1' and ack = '0' then
                -- WRITE STDOUT
                    wb_o.ack_o <= '1' after ack_assert_delay;
                    ack <= '1';
                    case wb_i.sel_i is
                        when "0001" => byte := wb_i.dat_i( 7 downto 0);
                        when "0010" => byte := wb_i.dat_i(15 downto 8);
                        when "0100" => byte := wb_i.dat_i(23 downto 16);
                        when "1000" => byte := wb_i.dat_i(31 downto 24);
                        when others => null;
                    end case;
                    char := character'val(my_conv_integer(byte));
                    if byte = X"0D" then
                        -- Ignore character 13
                    elsif byte = X"0A" then
                        -- Writeline on character 10 (newline)
                        writeline(output, s);
                    else
                        -- Write to buffer
                        write(s, char);
                    end if;
                elsif ack = '0' then
                -- READ stdout
                    ack <= '1';
                    wb_o.ack_o <= '1' after ack_assert_delay;
                    if chr_cnt = 0 then
                        chr_cnt <= 1;
                        chr_dat <= X"4C4C4C4C";
                    elsif chr_cnt = 1 then
                        chr_cnt <= 2;
                        chr_dat <= X"4D4D4D4D";
                    elsif chr_cnt = 2 then
                        chr_cnt <= 3;
                        chr_dat <= X"4E4E4E4E";
                    elsif chr_cnt = 3 then
                        chr_cnt <= 0;
                        chr_dat <= X"0A0A0A0A";
                    end if;
                end if;
            else
                ack <= '0';
                wb_o.ack_o <= '0' after ack_deassert_delay;
            end if;
        end if;
    end process;
end arch;