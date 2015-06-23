library ieee;
use ieee.std_logic_1164.all;
use work.whisk_constants.all;

entity instr_decode is
    port (
    clk : in std_logic;
    -- data lines
    reg1 : out std_logic_vector(WORD_BITS - 1 downto 0);
    reg2 : out std_logic_vector(WORD_BITS - 1 downto 0);
    immediate : out std_logic_vector(IMM_SIZE - 1 downto 0);
    regs_data_in : in std_logic_vector(WORD_BITS - 1 downto 0);
    --branch_target : out std_logic_vector(MC_ADDR_BITS - 1 downto 0);
    
    instr : in std_logic_vector(MC_INSTR_BITS - 1 downto 0);
  
    -- Let the control unit know if we're using indirect addressing
    indir_reg1_sel : out std_logic;
    indir_reg2_sel : out std_logic;
    alu_funct : out std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);
    reg_write : out std_logic; -- feed forward to next stage


    wb_reg_write : in std_logic; -- from write-back stage.
    ctrl_regs_we : in std_logic; -- from control unit
    ctrl_alu_funct : in std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);

    -- Select source of register address. Either direct or indirect register.
    regs_addr_src_1 : in std_logic;
    regs_addr_src_2 : in std_logic
    );  
end entity;


architecture mixed of instr_decode is
    signal regs_addr_1 : std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
    signal regs_addr_2 : std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
    signal regs_data_1 : std_logic_vector(WORD_BITS - 1 downto 0);
    signal regs_data_2 : std_logic_vector(WORD_BITS - 1 downto 0);
--    signal regs_data_in : std_logic_vector(WORD_BITS - 1 downto 0);

    --storage for the indirect registers
    signal indir_reg_1 : std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
    signal indir_reg_2 : std_logic_vector(REGS_ADDR_BITS - 1 downto 0);
begin
    regfile : entity dualport_mem 
    generic map (
        memsize => REGS_SIZE,
        addr_width => REGS_ADDR_BITS,
        data_width => WORD_BITS,
        initfile => SCRATCH_MEM_INIT)
    port map (
        clk => clk,
        a => regs_addr_1,
        b => regs_addr_2,
        doa => regs_data_1,
        dob => regs_data_2,
        dia => regs_data_in,
        we => wb_reg_write);

    -- Indirect register addressing
    regs_addr_1 <= indir_reg_1 when regs_addr_src_1 = '1' 
                               else instr(INSTR_REG1_START - 1 downto INSTR_REG1_END);
    regs_addr_2 <= indir_reg_2 when regs_addr_src_2 = '1' 
                               else instr(INSTR_REG2_START - 1 downto INSTR_REG2_END);

    -- Update pipeline registers.
    update_id_regs : process (clk)
    begin
        if rising_edge(clk) then
            immediate <= instr(INSTR_IMM_START downto 0);
            -- Control signals that are fed forward.
            reg_write <= ctrl_regs_we;
            -- Lets us know if the next cycle is an indirect addressing
            indir_reg1_sel <= instr(INSTR_REG1_INDIR);
            indir_reg2_sel <= instr(INSTR_REG2_INDIR);
            indir_reg_1 <= regs_data_1(REGS_ADDR_BITS - 1 downto 0);
            indir_reg_2 <= regs_data_2(REGS_ADDR_BITS - 1 downto 0);
            alu_funct <= ctrl_alu_funct;
       end if;
       -- output ports are registered, no need to be under flank.
       reg1 <= regs_data_1;
       reg2 <= regs_data_2;
 
    end process;
end architecture;
