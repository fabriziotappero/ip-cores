library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.whisk_constants.all;

entity exec is
    port (
    -- data lines
    alu_res : out std_logic_vector(WORD_BITS - 1 downto 0);
    reg2 : out std_logic_vector(WORD_BITS - 1 downto 0); -- data to be written to main memory

    operand1 : in std_logic_vector(WORD_BITS - 1 downto 0);
    operand2 : in std_logic_vector(WORD_BITS - 1 downto 0);
    imm : in std_logic_vector(IMM_SIZE - 1 downto 0);
 
    -- control lines
    clk : in std_logic;
    alu_funct : in std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);
    reg_write : in std_logic;
    branch_taken : out std_logic;
    branch_target : out std_logic_vector(MC_ADDR_BITS - 1 downto 0);
    alu_flags : out std_logic_vector(STATUS_REG_BITS - 1 downto 0);
    exec_reg_write : out std_logic; --forward control signals
    exec_reg2_out : out std_logic_vector(WORD_BITS - 1 downto 0)

    );
end entity;

architecture mixed of exec is
--    signal EXMEM : EXMEM_t;
    signal alu_out : std_logic_vector(WORD_BITS - 1 downto 0);
begin
    branch_target <=  std_logic_vector(unsigned(operand1) + unsigned(operand2)); 

    alu : entity alu 
    port map (
        in_a => operand1,
        in_b => operand2,
        funct => alu_funct,
        status => alu_flags,
        output => alu_out
    );

    exec_stage : process (clk)
    begin
        if rising_edge(clk) then
            reg2 <= operand2;
            alu_res <= alu_out;
            exec_reg_write <= reg_write; -- forward control signal
            exec_reg2_out <= operand2;
        end if;
    end process;
end architecture;
