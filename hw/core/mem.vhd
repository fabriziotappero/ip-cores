----------------------------------------------------------------------------------------------
--
--      Input file         : mem.vhd
--      Design name        : mem
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Memory retrieves data words from a data memory. Memory file
--                           access of byte, halfword and word sizes is supported. The sel_o
--                           signal indicates which bytes should be read or written. The
--                           responsibility for writing the right memory address is not within
--                           this integer unit but should be handled by the external memory
--                           device. This facilitates the addition of devices with different
--                           bus sizes.
--
--                           The dmem_i signals are directly connected to the decode and
--                           execute components.
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity mem is port
(
    mem_o  : out mem_out_type;
    dmem_o : out dmem_out_type;
    mem_i  : in mem_in_type;
    ena_i  : in std_logic;
    rst_i  : in std_logic;
    clk_i  : in std_logic
);
end mem;

architecture arch of mem is
    signal r, rin : mem_out_type;
    signal mem_result : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
begin
    -- connect pipline signals
    mem_o.ctrl_wrb     <= r.ctrl_wrb;
    mem_o.ctrl_mem_wrb <= r.ctrl_mem_wrb;
    mem_o.alu_result  <= r.alu_result;

    -- connect memory interface signals
    dmem_o.dat_o <= mem_result;
    dmem_o.sel_o <= decode_mem_store(mem_i.alu_result(1 downto 0), mem_i.ctrl_mem.transfer_size);
    dmem_o.we_o  <= mem_i.ctrl_mem.mem_write;
    dmem_o.adr_o <= mem_i.alu_result(CFG_DMEM_SIZE - 1 downto 0);
    dmem_o.ena_o <= mem_i.ctrl_mem.mem_read or mem_i.ctrl_mem.mem_write;

    mem_comb: process(mem_i, mem_i.ctrl_wrb, mem_i.ctrl_mem, r, r.ctrl_wrb, r.ctrl_mem_wrb)
        variable v : mem_out_type;
        variable intermediate : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
    begin

        v := r;
        v.ctrl_wrb := mem_i.ctrl_wrb;

        if mem_i.branch = '1' then
            -- set alu result for branch and load instructions
            v.alu_result := sign_extend(mem_i.program_counter, '0', 32);
        else
            v.alu_result := mem_i.alu_result;
        end if;

        -- Forward memory result
        if CFG_MEM_FWD_WRB = true and ( r.ctrl_mem_wrb.mem_read and compare(mem_i.ctrl_wrb.reg_d, r.ctrl_wrb.reg_d)) = '1' then
            intermediate := align_mem_load(mem_i.mem_result, r.ctrl_mem_wrb.transfer_size, r.alu_result(1 downto 0));
            mem_result <= align_mem_store(intermediate, mem_i.ctrl_mem.transfer_size);
        else
            mem_result <= mem_i.dat_d;
        end if;

        v.ctrl_mem_wrb.mem_read := mem_i.ctrl_mem.mem_read;
        v.ctrl_mem_wrb.transfer_size := mem_i.ctrl_mem.transfer_size;

        rin <= v;

    end process;

    mem_seq: process(clk_i)
        procedure proc_mem_reset is
        begin
            r.alu_result  <= (others => '0');
            r.ctrl_wrb.reg_d <= (others => '0');
            r.ctrl_wrb.reg_write <= '0';
            r.ctrl_mem_wrb.mem_read <= '0';
            r.ctrl_mem_wrb.transfer_size <= WORD;
        end procedure proc_mem_reset;
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                proc_mem_reset;
            elsif ena_i = '1' then
                r <= rin;
            end if;
        end if;
    end process;
end arch;
