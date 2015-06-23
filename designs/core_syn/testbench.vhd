----------------------------------------------------------------------------------------------
--
--      Input file         : config_Pkg.vhd
--      Design name        : config_Pkg
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Testbench instantiates mblite_soc and stdio
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity testbench is
end testbench;

architecture arch of testbench is

    component mblite_soc is port
    (
        sys_clk_i        : in std_logic := 'x'; 
        dbg_dmem_o_we_o  : out std_logic; 
        dbg_dmem_o_ena_o : out std_logic; 
        sys_rst_i        : in std_logic := 'x'; 
        sys_ena_i        : in std_logic := 'x'; 
        sys_int_i        : in std_logic := 'x'; 
        dbg_dmem_o_adr_o : out std_logic_vector(31 downto 0); 
        dbg_dmem_o_dat_o : out std_logic_vector(31 downto 0); 
        dbg_dmem_o_sel_o : out std_logic_vector( 3 downto 0) 
    );
    end component;

    signal sys_clk_i : std_logic := '0';
    signal sys_int_i : std_logic := '0';
    signal sys_rst_i : std_logic := '0';
    signal sys_ena_i : std_logic := '1';

    signal dmem_o : dmem_out_type;

    constant std_out_adr : std_logic_vector(CFG_DMEM_SIZE - 1 downto 0) := X"FFFFFFC0";
begin

    sys_clk_i <= not sys_clk_i after 10000 ps;
    sys_rst_i <= '1' after 0 ps, '0' after  150000 ps;
    sys_int_i <= '1' after 500000000 ps, '0' after 500040000 ps;

    soc : mblite_soc port map
    (
        sys_clk_i  => sys_clk_i,
        dbg_dmem_o_we_o => dmem_o.we_o,
        dbg_dmem_o_ena_o => dmem_o.ena_o,
        sys_rst_i => sys_rst_i,
        sys_ena_i => sys_ena_i,
        sys_int_i => sys_int_i,
        dbg_dmem_o_adr_o => dmem_o.adr_o,
        dbg_dmem_o_dat_o => dmem_o.dat_o,
        dbg_dmem_o_sel_o => dmem_o.sel_o
    );

    timeout: process(sys_clk_i)
    begin
        if NOW = 10 ms then
            report "TIMEOUT" severity FAILURE;
        end if;
    end process;

    -- Character device
    stdio: process(sys_clk_i)
        variable s    : line;
        variable byte : std_logic_vector(7 downto 0);
        variable char : character;
    begin

        if rising_edge(sys_clk_i) then
            if (not sys_rst_i and dmem_o.ena_o and compare(dmem_o.adr_o, std_out_adr)) = '1' then
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
                    if byte = X"0D" then
                        -- Ignore character 13
                    elsif byte = X"0A" then
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
