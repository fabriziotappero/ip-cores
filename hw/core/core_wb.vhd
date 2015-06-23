----------------------------------------------------------------------------------------------
--
--      Input file         : core_wb.vhd
--      Design name        : core_wb
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Top level module of the MB-Lite microprocessor with connected
--                           wishbone data bus
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity core_wb is generic
(
    G_INTERRUPT  : boolean := CFG_INTERRUPT;
    G_USE_HW_MUL : boolean := CFG_USE_HW_MUL;
    G_USE_BARREL : boolean := CFG_USE_BARREL;
    G_DEBUG      : boolean := CFG_DEBUG
);
port
(
    imem_o : out imem_out_type;
    wb_o   : out wb_mst_out_type;
    imem_i : in imem_in_type;
    wb_i   : in wb_mst_in_type
);
end core_wb;

architecture arch of core_wb is
    signal dmem_i : dmem_in_type;
    signal dmem_o : dmem_out_type;
begin

    wb_adapter0 : core_wb_adapter port map
    (
        dmem_i => dmem_i,
        wb_o   => wb_o,
        dmem_o => dmem_o,
        wb_i   => wb_i
    );

    core0 : core generic map
    (
        G_INTERRUPT  => G_INTERRUPT,
        G_USE_HW_MUL => G_USE_HW_MUL,
        G_USE_BARREL => G_USE_BARREL,
        G_DEBUG      => G_DEBUG
    )
    port map
    (
        imem_o => imem_o,
        dmem_o => dmem_o,
        imem_i => imem_i,
        dmem_i => dmem_i,
        int_i  => wb_i.int_i,
        rst_i  => wb_i.rst_i,
        clk_i  => wb_i.clk_i
    );

end arch;
