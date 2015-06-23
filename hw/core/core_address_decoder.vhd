----------------------------------------------------------------------------------------------
--
--      Input file         : core_address_decoder.vhd
--      Design name        : core_address_decoder
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Wishbone adapter for the MB-Lite microprocessor
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity core_address_decoder is generic
(
    G_NUM_SLAVES : positive := CFG_NUM_SLAVES;
    G_MEMORY_MAP : memory_map_type := CFG_MEMORY_MAP
);
port
(
    m_dmem_i : out dmem_in_type;
    s_dmem_o : out dmem_out_array_type(G_NUM_SLAVES - 1 downto 0);
    m_dmem_o : in dmem_out_type;
    s_dmem_i : in dmem_in_array_type(G_NUM_SLAVES - 1 downto 0);
    clk_i : std_logic
);
end core_address_decoder;

architecture arch of core_address_decoder is

    -- Decodes the address based on the memory map. Returns "1" if 0 or 1 slave is attached.
    function decode(adr : std_logic_vector) return std_logic_vector is
        variable result : std_logic_vector(G_NUM_SLAVES - 1 downto 0);
    begin
        if G_NUM_SLAVES > 1 and notx(adr) then
            for i in G_NUM_SLAVES - 1 downto 0 loop
                if (adr >= G_MEMORY_MAP(i) and adr < G_MEMORY_MAP(i+1)) then
                    result(i) := '1';
                else
                    result(i) := '0';
                end if;
            end loop;
        else
            result := (others => '1');
        end if;
        return result;
    end function;

    function demux(dmem_i : dmem_in_array_type; ce, r_ce : std_logic_vector) return dmem_in_type is
        variable dmem : dmem_in_type;
    begin
        dmem := dmem_i(0);
        if notx(ce) then
            for i in G_NUM_SLAVES - 1 downto 0 loop
                if ce(i) = '1' then
                    dmem.ena_i := dmem_i(i).ena_i;
                end if;
                if r_ce(i) = '1' then
                    dmem.dat_i := dmem_i(i).dat_i;
                end if;
            end loop;
        end if;
        return dmem;
    end function;

    signal r_ce, ce : std_logic_vector(G_NUM_SLAVES - 1 downto 0) := (others => '1');

begin

    ce <= decode(m_dmem_o.adr_o);
    m_dmem_i <= demux(s_dmem_i, ce, r_ce);

    CON: for i in G_NUM_SLAVES-1 downto 0 generate
    begin
        s_dmem_o(i).dat_o <= m_dmem_o.dat_o;
        s_dmem_o(i).adr_o <= m_dmem_o.adr_o;
        s_dmem_o(i).sel_o <= m_dmem_o.sel_o;
        s_dmem_o(i).we_o  <= m_dmem_o.we_o and ce(i);
        s_dmem_o(i).ena_o <= m_dmem_o.ena_o and ce(i);
    end generate;

    process(clk_i)
    begin
        if rising_edge(clk_i) then
            r_ce <= ce;
        end if;
    end process;
end arch;
