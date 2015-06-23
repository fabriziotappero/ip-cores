----------------------------------------------------------------------------------------------
--
--      Input file         : config_Pkg.vhd
--      Design name        : config_Pkg
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Testbench which instantiates instruction memory, data memory,
--                           core, core address decoder and stdio
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity testbench is
end testbench;

architecture arch of testbench is

    component mblite_stdio is port
    (
        dmem_i : out dmem_in_type;
        dmem_o : in dmem_out_type;
        clk_i  : in std_logic
    );
    end component;

    signal dmem_o : dmem_out_type;
    signal dmem_i : dmem_in_type;
    signal imem_o : imem_out_type;
    signal imem_i : imem_in_type;
    signal s_dmem_o : dmem_out_array_type(CFG_NUM_SLAVES - 1 downto 0);
    signal s_dmem_i : dmem_in_array_type(CFG_NUM_SLAVES - 1 downto 0);

    signal sys_clk_i : std_logic := '0';
    signal sys_int_i : std_logic;
    signal sys_rst_i : std_logic;

    constant rom_size : integer := 16;
    constant ram_size : integer := 16;

    signal sel_o : std_logic_vector(3 downto 0);
    signal ena_o : std_logic;

BEGIN

    sys_clk_i <= not sys_clk_i after 10000 ps;
    sys_rst_i <= '1' after 0 ps, '0' after  150000 ps;
    sys_int_i <= '1' after 500000000 ps, '0' after 500040000 ps;

    -- Warning: an infinite loop like while(1) {} triggers this timeout too!
    -- disable this feature when a premature finish occur.
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

    stdio : mblite_stdio port map
    (
        dmem_i => s_dmem_i(1),
        dmem_o => s_dmem_o(1),
        clk_i  => sys_clk_i
    );

    s_dmem_i(0).ena_i <= '1';
    sel_o <= s_dmem_o(0).sel_o when s_dmem_o(0).we_o = '1' else (others => '0');
    ena_o <= not sys_rst_i and s_dmem_o(0).ena_o;

    dmem : sram_4en generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE => ram_size - 2
    )
    port map
    (
        dat_o => s_dmem_i(0).dat_i,
        dat_i => s_dmem_o(0).dat_o,
        adr_i => s_dmem_o(0).adr_o(ram_size - 1 downto 2),
        wre_i => sel_o,
        ena_i => ena_o,
        clk_i => sys_clk_i
    );

    decoder : core_address_decoder generic map
    (
        G_NUM_SLAVES => CFG_NUM_SLAVES
    )
    port map
    (
        m_dmem_i => dmem_i,
        s_dmem_o => s_dmem_o,
        m_dmem_o => dmem_o,
        s_dmem_i => s_dmem_i,
        clk_i    => sys_clk_i
    );

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
