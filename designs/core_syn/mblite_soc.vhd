----------------------------------------------------------------------------------------------
--
--      Input file         : config_Pkg.vhd
--      Design name        : config_Pkg
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Instantiates instruction- and datamemories and the core
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity mblite_soc is port
(
    sys_clk_i        : in std_logic;
    dbg_dmem_o_we_o  : out std_logic;
    dbg_dmem_o_ena_o : out std_logic;
    sys_rst_i        : in std_logic;
    sys_ena_i        : in std_logic;
    sys_int_i        : in std_logic;
    dbg_dmem_o_adr_o : out std_logic_vector (31 downto 0);
    dbg_dmem_o_dat_o : out std_logic_vector (31 downto 0);
    dbg_dmem_o_sel_o : out std_logic_vector ( 3 downto 0)
);
end mblite_soc;

architecture arch of mblite_soc is

    component sram_init is generic
    (
        WIDTH : integer;
        SIZE  : integer
    );
    port
    (
        dat_o : out std_logic_vector(WIDTH - 1 downto 0);
        dat_i : in std_logic_vector(WIDTH - 1 downto 0);
        adr_i : in std_logic_vector(SIZE - 1 downto 0);
        wre_i : in std_logic;
        ena_i : in std_logic;
        clk_i : in std_logic
    );
    end component;

    component sram_4en_init is generic
    (
        WIDTH : integer;
        SIZE  : integer
    );
    port
    (
        dat_o : out std_logic_vector(WIDTH - 1 downto 0);
        dat_i : in std_logic_vector(WIDTH - 1 downto 0);
        adr_i : in std_logic_vector(SIZE - 1 downto 0);
        wre_i : in std_logic_vector(3 downto 0);
        ena_i : in std_logic;
        clk_i : in std_logic
    );
    end component;

    signal dmem_o : dmem_out_type;
    signal imem_o : imem_out_type;
    signal dmem_i : dmem_in_type;
    signal imem_i : imem_in_type;

    signal mem_enable : std_logic;
    signal sel_o : std_logic_vector(3 downto 0);

    constant std_out_adr : std_logic_vector(CFG_DMEM_SIZE - 1 downto 0) := X"FFFFFFC0";
    constant rom_size : integer := 13;
    constant ram_size : integer := 13;

begin

    dbg_dmem_o_we_o  <= dmem_o.we_o;
    dbg_dmem_o_ena_o <= dmem_o.ena_o;
    dbg_dmem_o_adr_o <= dmem_o.adr_o;
    dbg_dmem_o_dat_o <= dmem_o.dat_o;
    dbg_dmem_o_sel_o <= dmem_o.sel_o;

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

    mem_enable <= not sys_rst_i and dmem_o.ena_o and not compare(dmem_o.adr_o, std_out_adr);
    sel_o <= dmem_o.sel_o when dmem_o.we_o = '1' else (others => '0');

    dmem : sram_4en generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE => ram_size - 2
    )
    port map
    (
        dat_o => dmem_i.dat_i,
        dat_i => dmem_o.dat_o,
        adr_i => dmem_o.adr_o(ram_size - 1 downto 2),
        wre_i => sel_o,
        ena_i => mem_enable,
        clk_i => sys_clk_i
    );

    dmem_i.ena_i <= sys_ena_i;

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