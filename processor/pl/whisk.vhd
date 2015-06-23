library ieee;
use ieee.std_logic_1164.all;

library work;
use work.leval2_constants.all;
use work.all;

entity whisk is
    port (
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic_vector (BUS_BITS - 1 downto 0);
    data_out : in std_logic_vector (BUS_BITS - 1 downto 0);
    addr_bus : in std_logic_vector (ADDR_BITS - 1 downto 0);
    iowait : in std_logic;
    sync : in std_logic;
    read : out std_logic;
    write : out std_logic;
    led : out std_logic);
end entity;

architecture rtl of whisk is
    -- signals from control
    signal ctrl_indir_reg1 : std_logic;
    signal ctrl_indir_reg2 : std_logic;
    signal ctrl_indir_idex_reg1 : std_logic;
    signal ctrl_indir_idex_reg2 : std_logic;
    signal ctrl_alu_funct : std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);
    signal ctrl_reg_write : std_logic;

    -- signals from stage 1 (fetch)
    signal ctrl_pc_mux : std_logic_vector(1 downto 0);
    signal fetched_instruction : std_logic_vector(MC_INSTR_BITS - 1 downto 0);
    signal branch_target : std_logic_vector(MC_ADDR_BITS - 1 downto 0);

    -- signals from stage 2 (decode)
    signal reg1_out : std_logic_vector(WORD_BITS - 1 downto 0);
    signal reg2_out : std_logic_vector(WORD_BITS - 1 downto 0);

    -- signal ctrl_regs_we : std_logic;
    signal ctrl_regs_addr_src_1 : std_logic;
    signal ctrl_regs_addr_src_2 : std_logic;
    signal immediate : std_logic_vector(IMM_SIZE - 1 downto 0);
    signal decode_reg_write : std_logic;
    signal alu_funct : std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);
    
    -- signals from stage 3 (exec)
    signal alu_result : std_logic_vector(WORD_BITS - 1 downto 0);
    signal alu_flags : std_logic_vector(STATUS_REG_BITS - 1 downto 0);
    signal exec_write_mem : std_logic;
    signal exec_read_mem : std_logic;
    signal exec_mem_ce : std_logic_vector(1 downto 0);
    signal exec_branch_taken : std_logic;
    signal exec_reg_write : std_logic; -- fwd to memory stage
    signal exec_reg2_out : std_logic_vector(WORD_BITS - 1 downto 0);

    -- signals from memory stage
    signal mem_mem_to_reg : std_logic;

    signal mem_reg_write : std_logic; -- register write control signal fed forward
    signal mem_reg_data : std_logic_vector(WORD_BITS - 1 downto 0); -- data from register to store

    signal mem_loaded_data : std_logic_vector(WORD_BITS - 1 downto 0); 
    signal mem_alu_result : std_logic_vector(WORD_BITS - 1 downto 0); 

    signal mem_write_mem : std_logic; -- signal out of memory stage to external mem
    signal mem_read_mem : std_logic; -- signal out of memory to external mem
    
    -- signals from write back 
    signal wb_reg_write : std_logic; -- register write control signal piped forward
    signal wb_reg_data : std_logic_vector(WORD_BITS - 1 downto 0); -- data to write to register

    -- signals used from and to the data bus and to off-chip
    signal bus_read_data : std_logic_vector(WORD_BITS - 1 downto 0);
    signal mem_write_enable : std_logic;  -- to external memory
    signal mem_write_data : std_logic_vector(WORD_BITS - 1 downto 0);
    signal databus : std_logic_vector(WORD_BITS - 1 downto 0); --to outside. 
    signal mem_address : std_logic_vector(ADDR_BITS - 1 downto 0);

    signal memory_wait : std_logic;
    signal memory_ce : std_logic_vector(1 downto 0);
    signal avr_irq : std_logic;
begin

    fetch_stage : entity instr_fetch
    port map (
        core_clk => clk,
        core_rst => rst,
        pc_mux => ctrl_pc_mux,
        instruction => fetched_instruction,
        branch_target => branch_target );

    decode_stage : entity instr_decode
    port map (
        instr => fetched_instruction,
        clk => clk,
        reg1 => reg1_out,
        reg2 => reg2_out,
        regs_addr_src_1 => ctrl_regs_addr_src_1,
        regs_addr_src_2 => ctrl_regs_addr_src_2,
        indir_reg1_sel => ctrl_indir_reg1,
        indir_reg2_sel => ctrl_indir_reg2,
        regs_data_in => wb_reg_data,
        ctrl_regs_we => ctrl_reg_write,
        wb_reg_write => mem_reg_write,
        ctrl_alu_funct => ctrl_alu_funct,
        reg_write => decode_reg_write,
        alu_funct => alu_funct);

    exec_stage : entity exec 
    port map (
        clk => clk,
        operand1 => reg1_out,
        operand2 => reg2_out,
        imm => immediate,
        alu_res => alu_result,
        alu_flags => alu_flags,
        alu_funct => alu_funct,
        reg_write => decode_reg_write,
        branch_taken => exec_branch_taken,
        branch_target => branch_target,
        exec_reg_write => exec_reg_write,
        exec_reg2_out => exec_reg2_out);

    mem_stage : entity mem
    port map (
        -- Pipeline control signals
        clk => clk,
        
        exec_reg_write => exec_reg_write, -- Register write control  (in)
        mem_reg_write => mem_reg_write, -- Register write control (out)

        mem_mem_to_reg => mem_mem_to_reg, -- Write to register when read

        address => alu_result(WORD_BITS - 1 downto 0), -- address to read/write
        data => exec_reg2_out, -- Data to write 

        mem_loaded_data => mem_loaded_data,
        mem_alu_result => mem_alu_result,

        -- Bus IO
        mem_read_data => bus_read_data,
        mem_write_data => mem_write_data,
        mem_address => mem_address,
        
        write_mem => mem_write_mem,
        read_mem => mem_read_mem,
        memory_wait => memory_wait -- Stall signal from external memory
    );

    bus_interface : entity bidirbus 
    port map (
        clk => clk,
        bidir => databus,
        oe => mem_write_enable,
        inp => mem_write_data,
        outp => bus_read_data);
    -- write back stage
    wb_reg_data <= mem_loaded_data when mem_mem_to_reg = '1' else mem_alu_result;
    wb_reg_write <= mem_reg_write;

    -- ctrl section
    control : entity control
    port map (
        indir_reg1 =>  ctrl_indir_reg1,
        indir_reg2 => ctrl_indir_reg2,
        indir_idex_reg1 => ctrl_indir_idex_reg1,
        indir_idex_reg2 => ctrl_indir_idex_reg2,
        pc_mux => ctrl_pc_mux,
        opcode => fetched_instruction(INSTR_OPCODE_START downto INSTR_OPCODE_END),
        idex_alu_funct => ctrl_alu_funct,
        reg_write => ctrl_reg_write,
        memory_wait => memory_wait,
        branch => exec_branch_taken);

end architecture;
