----------------------------------------------------------------------------------------------
--
--      Input file         : config_Pkg.vhd
--      Design name        : config_Pkg
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Testbench instantiates core, data memory, instruction memory
--                           and a character device.
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

entity testbench is
end testbench;

architecture arch of testbench is

    signal imem_o : imem_out_type;
    signal imem_i : imem_in_type;

    signal wb_o : wb_mst_out_type;
    signal wb_i : wb_mst_in_type;

    signal sys_clk_i : std_logic := '0';
    signal sys_int_i : std_logic;
    signal sys_rst_i : std_logic;

    constant std_out_adr : std_logic_vector(CFG_DMEM_SIZE - 1 downto 0) := X"FFFFFFC0";
    signal std_out_ack : std_logic;

    signal stdo_ena : std_logic;

    signal dmem_ena : std_logic;
    signal dmem_dat : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
    signal dmem_sel : std_logic_vector(3 downto 0);

    constant rom_size : integer := 16;
    constant ram_size : integer := 16;

begin

    sys_clk_i <= not sys_clk_i after 10000 ps;
    sys_rst_i <= '1' after 0 ps, '0' after  150000 ps;
    sys_int_i <= '1' after 500000000 ps, '0' after 500040000 ps;

    timeout: process(sys_clk_i)
    begin
        if NOW = 10 ms then
            report "TIMEOUT" severity FAILURE;
        end if;

        -- BREAK ON EXIT (0xB8000000)
        if compare(imem_i.dat_i, "10111000000000000000000000000000") = '1' then
            -- Make sure the simulator finishes when an error is encountered.
            -- For modelsim: see menu Simulate -> Runtime options -> Assertions
            report "FINISHED" severity FAILURE;
        end if;
    end process;

    -- Character device
    wb_stdio_slave: process(sys_clk_i)
        variable s    : line;
        variable byte : std_logic_vector(7 downto 0);
        variable char : character;
    begin
        if rising_edge(sys_clk_i) then
            if (wb_o.stb_o and wb_o.cyc_o and compare(wb_o.adr_o, std_out_adr)) = '1' then
                if wb_o.we_o = '1' and std_out_ack = '0' then
                -- WRITE STDOUT
                    std_out_ack <= '1';
                    case wb_o.sel_o is
                        when "0001" => byte := wb_o.dat_o( 7 downto  0);
                        when "0010" => byte := wb_o.dat_o(15 downto  8);
                        when "0100" => byte := wb_o.dat_o(23 downto 16);
                        when "1000" => byte := wb_o.dat_o(31 downto 24);
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
                elsif std_out_ack = '0' then
                    std_out_ack <= '1';
                end if;
            else
                std_out_ack <= '0';
            end if;
        end if;

    end process;

    wb_i.clk_i <= sys_clk_i;
    wb_i.rst_i <= sys_rst_i;
    wb_i.int_i <= sys_int_i;

    dmem_ena <= wb_o.stb_o and wb_o.cyc_o and not compare(wb_o.adr_o, std_out_adr);

    process(wb_o.stb_o, wb_o.cyc_o, std_out_ack, wb_o.adr_o)
    begin
        if not compare(wb_o.adr_o, std_out_adr) = '1' then
            wb_i.ack_i <= wb_o.stb_o and wb_o.cyc_o after 2 ns;
        else
            wb_i.ack_i <= std_out_ack after 22 ns;
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

    dmem_sel <= wb_o.sel_o when wb_o.we_o = '1' else (others => '0');
    wb_i.dat_i <= X"61616161" when std_out_ack = '1' else dmem_dat;

    dmem : sram_4en generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE => ram_size - 2
    )
    port map
    (
        dat_o => dmem_dat,
        dat_i => wb_o.dat_o,
        adr_i => wb_o.adr_o(ram_size - 1 downto 2),
        wre_i => dmem_sel,
        ena_i => dmem_ena,
        clk_i => sys_clk_i
    );

    core_wb0 : core_wb port map
    (
        imem_o => imem_o,
        wb_o   => wb_o,
        imem_i => imem_i,
        wb_i   => wb_i
    );

end arch;
