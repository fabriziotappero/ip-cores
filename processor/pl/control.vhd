library ieee;
use ieee.std_logic_1164.all;
use work.leval2_package.all;

entity control is
    port (
    -- from decode
    -- Controls the indirect register fetch stage.
    IndirReg1 : in std_logic;
    IndirReg2 : in std_logic;

     -- controls 
    PCmux : out std_logic_vector(1 downto 0);
    AluOp : out std_logic_vector(ALU_FUNCT_SIZE - 1 downto 0);
    WriteReg : out std_logic;
    Flush : out std_logic;
    MemToReg : out std_logic;

    IndirMux1 : out std_logic;
    IndirMux2 : out std_logic;

	Branch : out std_logic;
	StoreInst : out std_logic;
    Stall : out std_logic;

    Opcode : in std_logic_vector(INSTR_OPCODE_BITS - 1 downto 0);
    MemWait : in std_logic;
	Sync : in std_logic;
    BranchTaken : in std_logic;

	Hazard : in std_logic
);
end entity;


architecture behav of control is
begin
    control_set : process (IndirReg1,IndirReg2,Opcode,MemWait,BranchTaken)
    begin
        -- default values for the output. 
        PCmux <= PCMUX_NOBRANCH;
        AluOp <= ALU_PASS;
        WriteReg <= '0';
        MemToReg <= '0';
		StoreInst <= '0';

		-- Stall control

        -- Indirection control
        if IndirReg1 = '1' or Sync = '1' then
            --We have an indirect register addressing mode. Stall pipeline.
            PCmux <= PCMUX_STALL;
            
        elsif MemWait = '1' or Sync = '1' then 
            -- Memory wait control. Freeze pipeline while waiting 
            -- for memory transaction to complete.
            PCmux <= PCMUX_STALL;
        end if;

        -- Opcode control
        case opcode is
                    -- Arithmetical / Logic functions
            when ADD =>
                AluOp<= ALU_ADD;
                WriteReg <= '1';

            when SUBB =>
                AluOp<= ALU_SUB;
                WriteReg <= '1';

            when MUL =>
                AluOp<= ALU_MUL;
                WriteReg <= '1';

                    --					-- NOT IMPLEMENTED
                    --					when DIV =>
                    --						AluOp<= ALU_DIV;
                    --						--WriteReg <= '1';
                    --					when MODULO =>
                    --						AluOp<= ALU_MOD;
                    --						--WriteReg <= '1';

            when LAND =>
                AluOp<= ALU_AND;
                WriteReg <= '1';

            when LOR =>
                AluOp<= ALU_OR;
                WriteReg <= '1';

            when LXOR =>
                AluOp<= ALU_XOR;
                WriteReg <= '1';

            when LOAD =>
                MemToReg <= '1'; -- use data bus
                AluOp<= ALU_ADD;
--                alu_op2_sel <= '1';
 --               --alu_op1_sel <= '1';
                --stored <= false;
                --stall <= '1';
                -- Also, stall pipeline!

            when STORE =>
                AluOp<= ALU_ADD;
				StoreInst <= '1';
                --alu_op2_sel <= '1';
                ----alu_op1_sel <= '1';

            when BIDX =>
                if BranchTaken = '1' then
                    AluOp<= ALU_ADD;
                    --branch_taken <= '1';
                    --alu_op2_sel <= '1';
                end if;

            when GET_TYPE =>
                AluOp<= ALU_GET_TYPE;
                WriteReg <= '1';

            when SET_TYPE =>
                AluOp<= ALU_SET_TYPE;
                WriteReg <= '1';

            when SET_TYPE_IMM	=>
                AluOp<= ALU_SET_TYPE;
                WriteReg <= '1';
                --alu_op2_sel <= '1';

            when SET_DATUM =>
                AluOp<= ALU_SET_DATUM;
                WriteReg <= '1';

            when SET_DATUM_IMM =>
                AluOp<= ALU_SET_DATUM;
                WriteReg <= '1';
                --alu_op2_sel <= '1';

            when SET_GC =>
                AluOp<= ALU_SET_GC;
                WriteReg <= '1';

            when SET_GC_IMM =>
                AluOp<= ALU_SET_GC;
                WriteReg <= '1';
                --alu_op2_sel <= '1';

            when CPY =>
                AluOp<= ALU_CPY;
                WriteReg <= '1';

            when CMP_TYPE =>
                AluOp<= ALU_CMP_TYPE;

            when CMP_TYPE_IMM =>
                AluOp<= ALU_CMP_TYPE_IMM;
                --alu_op2_sel <= '1';

            when CMP_DATUM =>
                AluOp<= ALU_CMP_DATUM;

            when CMP_DATUM_IMM =>
                AluOp<= ALU_CMP_DATUM;
                --alu_op2_sel <= '1';

            when CMP_GC =>
                AluOp<= ALU_CMP_GC;

            when CMP_GC_IMM =>
                AluOp<= ALU_CMP_GC_IMM;
                --alu_op2_sel <= '1';

            when CMP =>
                AluOp<= ALU_CMP;

            when SHIFT_L =>
                AluOp<= ALU_SL;
                WriteReg <= '1';

            when SHIFT_R =>
                AluOp<= ALU_SR;
                WriteReg <= '1';

            when SETLED =>
                AluOp<= ALU_SETLED;

            when others =>
                -- unknown opcode, do nothing
                AluOp<= ALU_PASS;
        end case;
    end process;
end architecture;





