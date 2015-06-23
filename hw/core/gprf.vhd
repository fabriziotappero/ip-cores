----------------------------------------------------------------------------------------------
--
--      Input file         : gprf.vhd
--      Design name        : gprf
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : The general purpose register infers memory blocks to implement
--                           the register file. All outputs are registered, possibly by using
--                           registered memory elements.
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity gprf is port
(
    gprf_o : out gprf_out_type;
    gprf_i : in gprf_in_type;
    ena_i  : in std_logic;
    clk_i  : in std_logic
);
end gprf;

-- This architecture is the default implementation. It
-- consists of three dual port memories. Other
-- architectures can be added while configurations can
-- control the implemented architecture.
architecture arch of gprf is
begin
    a : dsram generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE  => CFG_GPRF_SIZE
    )
    port map
    (
        dat_o   => gprf_o.dat_a_o,
        adr_i   => gprf_i.adr_a_i,
        ena_i   => ena_i,
        dat_w_i => gprf_i.dat_w_i,
        adr_w_i => gprf_i.adr_w_i,
        wre_i   => gprf_i.wre_i,
        clk_i   => clk_i
    );

    b : dsram generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE  => CFG_GPRF_SIZE
    )
    port map
    (
        dat_o   => gprf_o.dat_b_o,
        adr_i   => gprf_i.adr_b_i,
        ena_i   => ena_i,
        dat_w_i => gprf_i.dat_w_i,
        adr_w_i => gprf_i.adr_w_i,
        wre_i   => gprf_i.wre_i,
        clk_i   => clk_i
    );

    d : dsram generic map
    (
        WIDTH => CFG_DMEM_WIDTH,
        SIZE  => CFG_GPRF_SIZE
    )
    port map
    (
        dat_o   => gprf_o.dat_d_o,
        adr_i   => gprf_i.adr_d_i,
        ena_i   => ena_i,
        dat_w_i => gprf_i.dat_w_i,
        adr_w_i => gprf_i.adr_w_i,
        wre_i   => gprf_i.wre_i,
        clk_i   => clk_i
    );
end arch;
