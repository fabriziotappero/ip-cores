----------------------------------------------------------------------------------------------
--
--      Input file         : config_Pkg.vhd
--      Design name        : config_Pkg
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Testbench instantiates core, data memory and instruction memory,
--                           together with a character device.
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

    signal dmem_o : dmem_out_type;
    signal imem_o : imem_out_type;
    signal dmem_i : dmem_in_type;
    signal imem_i : imem_in_type;

    signal sys_clk_i : std_logic := '0';
    signal sys_int_i : std_logic := '0';
    signal sys_rst_i : std_logic := '0';
    signal sys_ena_i : std_logic := '1';

    constant std_out_adr : std_logic_vector(CFG_DMEM_SIZE - 1 downto 0) := X"FFFFFFC0";
    constant rom_size    : integer := 16;
    constant ram_size    : integer := 16;

    signal mem_enable : std_logic;
    signal chr_enable : std_logic;
    signal chr_read   : std_logic;
    signal sel_o      : std_logic_vector(3 downto 0);
    signal mem_dat    : std_logic_vector(31 downto 0);
    signal chr_dat    : std_logic_vector(31 downto 0);
    signal chr_cnt    : integer := 0;

BEGIN

    sys_clk_i <= not sys_clk_i after 10000 ps;
    sys_rst_i <= '1' after 0 ps, '0' after  150000 ps;
    sys_int_i <= '1' after 500000000 ps, '0' after 500040000 ps;


    dmem_i.ena_i <= sys_ena_i;
    sel_o <= dmem_o.sel_o when dmem_o.we_o = '1' else (others => '0');

    mem_enable <= not sys_rst_i and dmem_o.ena_o and not compare(dmem_o.adr_o, std_out_adr);
    chr_enable <= not sys_rst_i and dmem_o.ena_o and compare(dmem_o.adr_o, std_out_adr);

    dmem_i.dat_i <= chr_dat when chr_read = '1' else mem_dat;

    -- Character device
    stdio: process(sys_clk_i)
        variable s    : line;
        variable byte : std_logic_vector(7 downto 0);
        variable char : character;
    begin
        if rising_edge(sys_clk_i) then
            if chr_enable = '1' then
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
                    chr_read <= '0';
                else
                    chr_read <= '1';
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
                chr_read <= '0';
            end if;
        end if;

    end process;

    -- Warning: an infinite loop like while(1) {} triggers this timeout too!
    -- disable this feature when a premature finish occur.
    timeout: process(sys_clk_i)
    begin
        if now = 10 ms then
            report "TIMEOUT" severity FAILURE;
        end if;
        -- BREAK ON EXIT (0xB8000000)
        if compare(imem_i.dat_i, "10111000000000000000000000000000") = '1' then
            -- Make sure the simulator finishes when an error is encountered.
            -- For modelsim: see menu Simulate -> Runtime options -> Assertions
            report "FINISHED" severity FAILURE;
        end if;
    end process;

    imem : sram generic map
    (
        WIDTH => CFG_IMEM_WIDTH,
        SIZE => rom_size - 2
    )
    port map
    (
        dat_o => imem_i.dat_i,
        dat_i => "00000000000000000000000000000000",
        adr_i => imem_o.adr_o(rom_size - 1 downto 2),
        wre_i => '0',
        ena_i => imem_o.ena_o,
        clk_i => sys_clk_i
    );

    dmem : sram_4en generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE => ram_size - 2
    )
    port map
    (
        dat_o => mem_dat,
        dat_i => dmem_o.dat_o,
        adr_i => dmem_o.adr_o(ram_size - 1 downto 2),
        wre_i => sel_o,
        ena_i => mem_enable,
        clk_i => sys_clk_i
    );

    core0 : core port map
    (
        imem_o => imem_o,
        dmem_o => dmem_o,
        imem_i => imem_i,
        dmem_i => dmem_i,
        int_i  => sys_int_i,
        rst_i  => sys_rst_i,
        clk_i  => sys_clk_i
    );

end arch;

----------------------------------------------------------------------------------------------
-- USE CONFIGURATIONS INSTEAD OF GENERICS TO IMPLEMENT - FOR EXAMPLE - DIFFERENT MEMORIES.
-- CONFIGURATIONS CAN HIERARCHICALLY INVOKE OTHER CONFIGURATIONS TO REDUCE THE SIZE OF THE
-- CONFIGURATION DECLARATION
----------------------------------------------------------------------------------------------
configuration tb_conf_example of testbench is
    for arch
        for all: sram_4en
            use entity mblite.sram_4en(arch);
        end for;
    end for;
end tb_conf_example;
