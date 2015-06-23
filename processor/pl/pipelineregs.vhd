library ieee;
use ieee.std_logic_1164.all;

library work;
use work.leval2_package.all;


package leval2_pipelineregs is
    type IFID_t is
        record 
			PC : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
        end record;

    type IDEX_t is
        record
            -- Control signals
            WriteReg : std_logic;
            MemToReg : std_logic; -- Indicates load.
            Store : std_logic;
            AluIn2Src : std_logic;
            AluOp : std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);
            IndirReg1bit : std_logic;
            IndirReg2bit : std_logic;
			Branch : std_logic;

            -- Data paths
            IR : std_logic_vector(MC_INSTR_BITS - 1 downto 0);
			PC : std_logic_vector(MC_ADDR_BITS - 1 downto 0);
            Immediate : std_logic_vector(WORD_BITS - 1 downto 0);
            IndirReg1 : std_logic_vector(WORD_BITS - 1 downto 0);
            IndirReg2 : std_logic_vector(WORD_BITS - 1 downto 0);
        end record;

    type EXMEM_t is
        record 
            --Control signals
            WriteReg : std_logic;
            MemToReg : std_logic;
            Store : std_logic;
            
            -- Data paths
            IR : std_logic_vector(MC_INSTR_BITS - 1 downto 0);
            AluRes : std_logic_vector(WORD_BITS - 1 downto 0);
            MemWriteData : std_logic_vector(WORD_BITS - 1 downto 0);

        end record;

    type M1M2_t is
        record
            -- Control signals
            WriteReg : std_logic;
            MemToReg : std_logic;
            Store : std_logic;

            -- Data paths
            IR : std_logic_vector(MC_INSTR_BITS - 1 downto 0);
            Tag : std_logic_vector(CACHE_TAG_BITS - 1 downto 0);
            Address : std_logic_vector(WORD_BITS - 1 downto 0);
            Data : std_logic_vector(CACHE_DATA_BITS - 1 downto 0);
            MemWriteData : std_logic_vector(WORD_BITS - 1 downto 0);
        end record;

    type M2WB_t is
        record 
            -- Control
            WriteReg : std_logic;
            MemToReg : std_logic;

            -- Data paths
            IR : std_logic_vector(MC_INSTR_BITS - 1 downto 0);
            AluRes : std_logic_vector(WORD_BITS - 1 downto 0);
            MemWriteData : std_logic_vector(WORD_BITS - 1 downto 0);
            --WriteRegAddr : std_logic_vector(REGS_ADDR_BITS - 1 downto 0);

        end record; 
end package;
