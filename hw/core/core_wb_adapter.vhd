----------------------------------------------------------------------------------------------
--
--      Input file         : core_wb_adapter.vhd
--      Design name        : core_wb_adapter.vhd
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Wishbone adapter for the MB-Lite microprocessor. The data output
--                           is registered for multicycle transfers. This adapter implements
--                           the synchronous Wishbone Bus protocol, Rev3B.
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity core_wb_adapter is port
(
    dmem_i : out dmem_in_type;
    wb_o   : out wb_mst_out_type;
    dmem_o : in dmem_out_type;
    wb_i   : in wb_mst_in_type
);
end core_wb_adapter;

architecture arch of core_wb_adapter is

    signal r_cyc_o : std_logic;
    signal rin_cyc_o : std_logic;
    signal r_data, rin_data : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
    signal s_wait : std_logic;

begin

    -- Direct input-output connections
    wb_o.adr_o   <= dmem_o.adr_o;
    wb_o.sel_o   <= dmem_o.sel_o;
    wb_o.we_o    <= dmem_o.we_o;
    dmem_i.dat_i <= wb_i.dat_i;

    -- synchronous bus control connections
    wb_o.cyc_o <= r_cyc_o or wb_i.ack_i;
    wb_o.stb_o <= r_cyc_o;

    -- asynchronous core enable connection
    dmem_i.ena_i <= '0' when (dmem_o.ena_o = '1' and rin_cyc_o = '1') or s_wait = '1' else '1';
    wb_o.dat_o   <= rin_data;

    -- logic for wishbone master
    wb_adapter_comb: process(wb_i, dmem_o, r_cyc_o, r_data)
    begin

        if wb_i.rst_i = '1' then
            -- reset bus
            rin_data <= r_data;
            rin_cyc_o <= '0';
            s_wait <= '0';
        elsif r_cyc_o = '1' and wb_i.ack_i = '1' then
            -- terminate wishbone cycle
            rin_data <= r_data;
            rin_cyc_o <= '0';
            s_wait <= '0';
        elsif dmem_o.ena_o = '1' and wb_i.ack_i = '1' then
            -- wishbone bus is occuppied
            rin_data <= r_data;
            rin_cyc_o <= '1';
            s_wait <= '1';
        elsif r_cyc_o = '0' and dmem_o.ena_o = '1' and wb_i.ack_i = '0' then
            -- start wishbone cycle
            rin_data <= dmem_o.dat_o;
            rin_cyc_o <= '1';
            s_wait <= '0';
        else
            -- maintain wishbone cycle
            rin_data <= r_data;
            rin_cyc_o <= r_cyc_o;
            s_wait <= '0';
        end if;

    end process;

    wb_adapter_seq: process(wb_i.clk_i)
    begin
        if rising_edge(wb_i.clk_i) then
            r_cyc_o <= rin_cyc_o;
            r_data <= rin_data;
        end if;
    end process;

end arch;
