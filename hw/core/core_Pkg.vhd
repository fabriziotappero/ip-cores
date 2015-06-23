----------------------------------------------------------------------------------------------
--
--      Input file         : core_Pkg.vhd
--      Design name        : core_Pkg
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : Package with components and type definitions for the interface
--                           of the components
--
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.std_Pkg.all;

package core_Pkg is

    constant C_8_ZEROS  : std_logic_vector ( 7 downto 0) := (others => '0');
    constant C_16_ZEROS : std_logic_vector (15 downto 0) := (others => '0');
    constant C_24_ZEROS : std_logic_vector (23 downto 0) := (others => '0');
    constant C_32_ZEROS : std_logic_vector (31 downto 0) := (others => '0');
----------------------------------------------------------------------------------------------
-- TYPES USED IN MB-LITE
----------------------------------------------------------------------------------------------

    type alu_operation    is (ALU_ADD, ALU_OR, ALU_AND, ALU_XOR, ALU_SHIFT, ALU_SEXT8, ALU_SEXT16, ALU_MUL, ALU_BS);
    type src_type_a       is (ALU_SRC_REGA, ALU_SRC_NOT_REGA, ALU_SRC_PC, ALU_SRC_ZERO);
    type src_type_b       is (ALU_SRC_REGB, ALU_SRC_NOT_REGB, ALU_SRC_IMM, ALU_SRC_NOT_IMM);
    type carry_type       is (CARRY_ZERO, CARRY_ONE, CARRY_ALU, CARRY_ARITH);
    type carry_keep_type  is (CARRY_NOT_KEEP, CARRY_KEEP);
    type branch_condition is (NOP, BNC, BEQ, BNE, BLT, BLE, BGT, BGE);
    type transfer_size    is (WORD, HALFWORD, BYTE);

    type ctrl_execution is record
        alu_op      : alu_operation;
        alu_src_a   : src_type_a;
        alu_src_b   : src_type_b;
        operation   : std_logic;
        carry       : carry_type;
        carry_keep  : carry_keep_type;
        branch_cond : branch_condition;
        delay       : std_logic;
    end record;

    type ctrl_memory is record
        mem_write     : std_logic;
        mem_read      : std_logic;
        transfer_size : transfer_size;
    end record;

    type ctrl_memory_writeback_type is record
        mem_read      : std_logic;
        transfer_size : transfer_size;
    end record;

    type forward_type is record
        reg_d     : std_logic_vector(CFG_GPRF_SIZE - 1 downto 0);
        reg_write : std_logic;
    end record;

    type imem_in_type is record
        dat_i : std_logic_vector(CFG_IMEM_WIDTH - 1 downto 0);
    end record;

    type imem_out_type is record
        adr_o : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        ena_o : std_logic;
    end record;

    type fetch_in_type is record
        hazard        : std_logic;
        branch        : std_logic;
        branch_target : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
    end record;

    type fetch_out_type is record
        program_counter : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
    end record;

    type gprf_out_type is record
        dat_a_o : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        dat_b_o : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        dat_d_o : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
    end record;

    type decode_in_type is record
        program_counter : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        instruction     : std_logic_vector(CFG_IMEM_WIDTH - 1 downto 0);
        ctrl_wrb        : forward_type;
        ctrl_mem_wrb    : ctrl_memory_writeback_type;
        mem_result      : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        alu_result      : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        interrupt       : std_logic;
        flush_id        : std_logic;
    end record;

    type decode_out_type is record
        reg_a           : std_logic_vector(CFG_GPRF_SIZE - 1 downto 0);
        reg_b           : std_logic_vector(CFG_GPRF_SIZE - 1 downto 0);
        imm             : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        program_counter : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        hazard          : std_logic;
        ctrl_ex         : ctrl_execution;
        ctrl_mem        : ctrl_memory;
        ctrl_wrb        : forward_type;
        fwd_dec_result  : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        fwd_dec         : forward_type;
    end record;

    type gprf_in_type is record
        adr_a_i : std_logic_vector(CFG_GPRF_SIZE - 1 downto 0);
        adr_b_i : std_logic_vector(CFG_GPRF_SIZE - 1 downto 0);
        adr_d_i : std_logic_vector(CFG_GPRF_SIZE - 1 downto 0);
        dat_w_i : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        adr_w_i : std_logic_vector(CFG_GPRF_SIZE - 1 downto 0);
        wre_i   : std_logic;
    end record;

    type execute_out_type is record
        alu_result      : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        dat_d           : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        branch          : std_logic;
        program_counter : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        flush_id        : std_logic;
        ctrl_mem        : ctrl_memory;
        ctrl_wrb        : forward_type;
    end record;

    type execute_in_type is record
        reg_a           : std_logic_vector(CFG_GPRF_SIZE  - 1 downto 0);
        dat_a           : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        reg_b           : std_logic_vector(CFG_GPRF_SIZE  - 1 downto 0);
        dat_b           : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        dat_d           : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        imm             : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        program_counter : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        fwd_dec         : forward_type;
        fwd_dec_result  : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        fwd_mem         : forward_type;
        ctrl_ex         : ctrl_execution;
        ctrl_mem        : ctrl_memory;
        ctrl_wrb        : forward_type;
        ctrl_mem_wrb    : ctrl_memory_writeback_type;
        mem_result      : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        alu_result      : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);

    end record;

    type mem_in_type is record
        dat_d           : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        alu_result      : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        mem_result      : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        program_counter : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        branch          : std_logic;
        ctrl_mem        : ctrl_memory;
        ctrl_wrb         : forward_type;
    end record;

    type mem_out_type is record
        alu_result  : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        ctrl_wrb     : forward_type;
        ctrl_mem_wrb : ctrl_memory_writeback_type;
    end record;

    type dmem_in_type is record
        dat_i : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        ena_i : std_logic;
    end record;

    type dmem_out_type is record
        dat_o : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
        adr_o : std_logic_vector(CFG_DMEM_SIZE - 1 downto 0);
        sel_o : std_logic_vector(3 downto 0);
        we_o  : std_logic;
        ena_o : std_logic;
    end record;

    type dmem_in_array_type is array(natural range <>) of dmem_in_type;
    type dmem_out_array_type is array(natural range <>) of dmem_out_type;

    -- WB-master inputs from the wb-slaves
    type wb_mst_in_type is record
        clk_i : std_logic;                                     -- master clock input
        rst_i : std_logic;                                     -- synchronous active high reset
        dat_i : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0); -- databus input
        ack_i : std_logic;                                     -- buscycle acknowledge input
        int_i : std_logic;                                     -- interrupt request input
    end record;

    -- WB-master outputs to the wb-slaves
    type wb_mst_out_type is record
        adr_o : std_logic_vector(CFG_DMEM_SIZE - 1 downto 0);  -- address bits
        dat_o : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0); -- databus output
        we_o  : std_logic;                                     -- write enable output
        stb_o : std_logic;                                     -- strobe signals
        sel_o : std_logic_vector(3 downto 0);                  -- select output array
        cyc_o : std_logic;                                     -- valid BUS cycle output
    end record;

    -- WB-slave inputs, from the WB-master
    type wb_slv_in_type is record
        clk_i : std_logic;                                     -- master clock input
        rst_i : std_logic;                                     -- synchronous active high reset
        adr_i : std_logic_vector(CFG_DMEM_SIZE - 1 downto 0);  -- address bits
        dat_i : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0); -- Databus input
        we_i  : std_logic;                                     -- Write enable input
        stb_i : std_logic;                                     -- strobe signals / core select signal
        sel_i : std_logic_vector(3 downto 0);                  -- select output array
        cyc_i : std_logic;                                     -- valid BUS cycle input
    end record;

    -- WB-slave outputs to the WB-master
    type wb_slv_out_type is record
        dat_o : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0); -- Databus output
        ack_o : std_logic;                                     -- Bus cycle acknowledge output
        int_o : std_logic;                                     -- interrupt request output
    end record;

----------------------------------------------------------------------------------------------
-- COMPONENTS USED IN MB-LITE
----------------------------------------------------------------------------------------------

    component core
        generic (
            G_INTERRUPT  : boolean := CFG_INTERRUPT;
            G_USE_HW_MUL : boolean := CFG_USE_HW_MUL;
            G_USE_BARREL : boolean := CFG_USE_BARREL;
            G_DEBUG      : boolean := CFG_DEBUG
        );
        port (
            imem_o : out imem_out_type;
            dmem_o : out dmem_out_type;
            imem_i : in imem_in_type;
            dmem_i : in dmem_in_type;
            int_i  : in std_logic;
            rst_i  : in std_logic;
            clk_i  : in std_logic
        );
    end component;

    component core_wb
        generic (
            G_INTERRUPT  : boolean := CFG_INTERRUPT;
            G_USE_HW_MUL : boolean := CFG_USE_HW_MUL;
            G_USE_BARREL : boolean := CFG_USE_BARREL;
            G_DEBUG      : boolean := CFG_DEBUG
        );
        port (
            imem_o : out imem_out_type;
            wb_o   : out wb_mst_out_type;
            imem_i : in imem_in_type;
            wb_i   : in wb_mst_in_type
        );
    end component;

    component core_wb_adapter
        port (
            dmem_i : out dmem_in_type;
            wb_o   : out wb_mst_out_type;
            dmem_o : in dmem_out_type;
            wb_i   : in wb_mst_in_type
        );
    end component;

    component core_wb_async_adapter
        port (
            dmem_i : out dmem_in_type;
            wb_o   : out wb_mst_out_type;
            dmem_o : in dmem_out_type;
            wb_i   : in wb_mst_in_type
        );
    end component;

    component fetch
        port (
            fetch_o : out fetch_out_type;
            imem_o  : out imem_out_type;
            fetch_i : in fetch_in_type;
            rst_i   : in std_logic;
            ena_i   : in std_logic;
            clk_i   : in std_logic
        );
    end component;

    component decode
        generic (
            G_INTERRUPT  : boolean := CFG_INTERRUPT;
            G_USE_HW_MUL : boolean := CFG_USE_HW_MUL;
            G_USE_BARREL : boolean := CFG_USE_BARREL;
            G_DEBUG      : boolean := CFG_DEBUG
        );
        port (
            decode_o : out decode_out_type;
            gprf_o   : out gprf_out_type;
            decode_i : in decode_in_type;
            ena_i    : in std_logic;
            rst_i    : in std_logic;
            clk_i    : in std_logic
        );
    end component;

    component gprf
        port (
            gprf_o : out gprf_out_type;
            gprf_i : in gprf_in_type;
            ena_i  : in std_logic;
            clk_i  : in std_logic
        );
    end component;

    component execute
        generic (
            G_USE_HW_MUL : boolean := CFG_USE_HW_MUL;
            G_USE_BARREL : boolean := CFG_USE_BARREL
        );
        port (
            exec_o : out execute_out_type;
            exec_i : in execute_in_type;
            ena_i  : in std_logic;
            rst_i  : in std_logic;
            clk_i  : in std_logic
        );
    end component;

    component mem
        port (
            mem_o  : out mem_out_type;
            dmem_o : out dmem_out_type;
            mem_i  : in mem_in_type;
            ena_i  : in std_logic;
            rst_i  : in std_logic;
            clk_i  : in std_logic
        );
    end component;

    component core_address_decoder
        generic (
            G_NUM_SLAVES : positive := CFG_NUM_SLAVES
        );
        port (
            m_dmem_i : out dmem_in_type;
            s_dmem_o : out dmem_out_array_type;
            m_dmem_o : in dmem_out_type;
            s_dmem_i : in dmem_in_array_type;
            clk_i    : in std_logic
        );
    end component;
----------------------------------------------------------------------------------------------
-- FUNCTIONS USED IN MB-LITE
----------------------------------------------------------------------------------------------

    function select_register_data (reg_dat, reg, wb_dat : std_logic_vector; write : std_logic) return std_logic_vector;
    function forward_condition (reg_write : std_logic; reg_a, reg_d : std_logic_vector) return std_logic;
    function align_mem_load (data : std_logic_vector; size : transfer_size; address : std_logic_vector) return std_logic_vector;
    function align_mem_store (data : std_logic_vector; size : transfer_size) return std_logic_vector;
    function decode_mem_store (address : std_logic_vector(1 downto 0); size : transfer_size) return std_logic_vector;

end core_Pkg;

package body core_Pkg is

    -- This function select the register value:
    --      A) zero
    --      B) bypass value read from register file
    --      C) value from register file
    function select_register_data (reg_dat, reg, wb_dat : std_logic_vector; write : std_logic) return std_logic_vector is
        variable tmp : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);
    begin
        if CFG_REG_FORCE_ZERO = true and is_zero(reg) = '1' then
            tmp := (others => '0');
        elsif CFG_REG_FWD_WRB = true and write = '1' then
            tmp := wb_dat;
        else
            tmp := reg_dat;
        end if;
        return tmp;
    end select_register_data;

    -- This function checks if a forwarding condition is met. The condition is met of register A and D match
    -- and the signal needs to be written back to the register file.
    function forward_condition (reg_write : std_logic; reg_a, reg_d : std_logic_vector ) return std_logic is
    begin
        return reg_write and compare(reg_a, reg_d);
    end forward_condition;

    -- This function aligns the memory load operation (Big endian decoding). 
    function align_mem_load (data : std_logic_vector; size : transfer_size; address : std_logic_vector ) return std_logic_vector is
    begin
        case size is
            when byte => 
                case address(1 downto 0) is
                    when "00"   => return C_24_ZEROS & data(31 downto 24);
                    when "01"   => return C_24_ZEROS & data(23 downto 16);
                    when "10"   => return C_24_ZEROS & data(15 downto  8);
                    when "11"   => return C_24_ZEROS & data( 7 downto  0);
                    when others => return C_32_ZEROS;
                end case;
            when halfword => 
                case address(1 downto 0) is
                    when "00"   => return C_16_ZEROS & data(31 downto 16);
                    when "10"   => return C_16_ZEROS & data(15 downto  0);
                    when others => return C_32_ZEROS;
                end case;
            when others =>
                return data;
        end case;
    end align_mem_load;

    -- This function repeats the operand to all positions in a memory store operation.
    function align_mem_store (data : std_logic_vector; size : transfer_size) return std_logic_vector is
    begin
        case size is
            when byte     => return data( 7 downto 0) & data( 7 downto 0) & data(7 downto 0) & data(7 downto 0);
            when halfword => return data(15 downto 0) & data(15 downto 0);
            when others   => return data;
        end case;
    end align_mem_store;

    -- This function selects the correct bytes for memory writes (Big endian encoding).
    function decode_mem_store (address : std_logic_vector(1 downto 0); size : transfer_size) return std_logic_vector is
    begin
        case size is
            when BYTE =>
                case address is
                    when "00"   => return "1000";
                    when "01"   => return "0100";
                    when "10"   => return "0010";
                    when "11"   => return "0001";
                    when others => return "0000";
                end case;
            when HALFWORD =>
                case address is
                    -- Big endian encoding
                    when "10"   => return "0011";
                    when "00"   => return "1100";
                    when others => return "0000";
                end case;
            when others =>
                return "1111";
        end case;
    end decode_mem_store;

end core_Pkg;