----------------------------------------------------------------------------------------------
--
--      Input file         : decode.vhd
--      Design name        : decode
--      Author             : Tamar Kranenburg
--      Company            : Delft University of Technology
--                         : Faculty EEMCS, Department ME&CE
--                         : Systems and Circuits group
--
--      Description        : This combined register file and decoder uses three Dual Port
--                           read after write Random Access Memory components. Every clock
--                           cycle three data values can be read (ra, rb and rd) and one value
--                           can be stored.
--
----------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library mblite;
use mblite.config_Pkg.all;
use mblite.core_Pkg.all;
use mblite.std_Pkg.all;

entity decode is generic
(
    G_INTERRUPT  : boolean := CFG_INTERRUPT;
    G_USE_HW_MUL : boolean := CFG_USE_HW_MUL;
    G_USE_BARREL : boolean := CFG_USE_BARREL;
    G_DEBUG      : boolean := CFG_DEBUG
);
port
(
    decode_o : out decode_out_type;
    gprf_o   : out gprf_out_type;
    decode_i : in decode_in_type;
    ena_i    : in std_logic;
    rst_i    : in std_logic;
    clk_i    : in std_logic
);
end decode;

architecture arch of decode is

    type decode_reg_type is record
        instruction          : std_logic_vector(CFG_IMEM_WIDTH - 1 downto 0);
        program_counter      : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        immediate            : std_logic_vector(15 downto 0);
        is_immediate         : std_logic;
        msr_interrupt_enable : std_logic;
        interrupt            : std_logic;
        delay_interrupt      : std_logic;
    end record;

    signal r, rin     : decode_out_type;
    signal reg, regin : decode_reg_type;

    signal wb_dat_d : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);

begin

    decode_o.imm <= r.imm;

    decode_o.ctrl_ex <= r.ctrl_ex;
    decode_o.ctrl_mem <= r.ctrl_mem;
    decode_o.ctrl_wrb <= r.ctrl_wrb;

    decode_o.reg_a <= r.reg_a;
    decode_o.reg_b <= r.reg_b;
    decode_o.hazard <= r.hazard;
    decode_o.program_counter <= r.program_counter;

    decode_o.fwd_dec_result <= r.fwd_dec_result;
    decode_o.fwd_dec <= r.fwd_dec;

    decode_comb: process(decode_i,decode_i.ctrl_wrb,
                         decode_i.ctrl_mem_wrb,
                         decode_i.instruction,
                         decode_i.ctrl_mem_wrb.transfer_size,
                         r,r.ctrl_ex,r.ctrl_mem,
                         r.ctrl_mem.transfer_size,r.ctrl_wrb,
                         r.ctrl_wrb.reg_d,
                         r.fwd_dec,reg)

        variable v : decode_out_type;
        variable v_reg : decode_reg_type;
        variable opcode : std_logic_vector(5 downto 0);
        variable instruction : std_logic_vector(CFG_IMEM_WIDTH - 1 downto 0);
        variable program_counter : std_logic_vector(CFG_IMEM_SIZE - 1 downto 0);
        variable mem_result : std_logic_vector(CFG_DMEM_WIDTH - 1 downto 0);

    begin
        v := r;
        v_reg := reg;

        -- Default register values (NOP)
        v_reg.immediate := (others => '0');
        v_reg.is_immediate := '0';
        v_reg.program_counter := decode_i.program_counter;
        v_reg.instruction := decode_i.instruction;

        if decode_i.ctrl_mem_wrb.mem_read = '1' then
            mem_result := align_mem_load(decode_i.mem_result, decode_i.ctrl_mem_wrb.transfer_size, decode_i.alu_result(1 downto 0));
        else
            mem_result := decode_i.alu_result;
        end if;

        wb_dat_d <= mem_result;

        if G_INTERRUPT = true then
            v_reg.delay_interrupt := '0';
        end if;

        if CFG_REG_FWD_WRB = true then
            v.fwd_dec_result    := mem_result;
            v.fwd_dec           := decode_i.ctrl_wrb;
        else
            v.fwd_dec_result    := (others => '0');
            v.fwd_dec.reg_d     := (others => '0');
            v.fwd_dec.reg_write := '0';
        end if;

        if (not decode_i.flush_id and r.ctrl_mem.mem_read and (compare(decode_i.instruction(20 downto 16), r.ctrl_wrb.reg_d) or compare(decode_i.instruction(15 downto 11), r.ctrl_wrb.reg_d))) = '1' then
        -- A hazard occurred on register a or b

            -- set current instruction and program counter to 0
            instruction := (others => '0');
            program_counter := (others => '0');

            v.hazard := '1';

        elsif CFG_MEM_FWD_WRB = false and (not decode_i.flush_id and r.ctrl_mem.mem_read and compare(decode_i.instruction(25 downto 21), r.ctrl_wrb.reg_d)) = '1' then
        -- A hazard occurred on register d

            -- set current instruction and program counter to 0
            instruction := (others => '0');
            program_counter := (others => '0');

            v.hazard := '1';

        elsif r.hazard = '1' then
        -- Recover from hazard. Insert latched instruction

            instruction := reg.instruction;
            program_counter := reg.program_counter;
            v.hazard := '0';

        else

            instruction := decode_i.instruction;
            program_counter := decode_i.program_counter;
            v.hazard := '0';

        end if;

        v.program_counter := program_counter;
        opcode := instruction(31 downto 26);
        v.ctrl_wrb.reg_d := instruction(25 downto 21);
        v.reg_a := instruction(20 downto 16);
        v.reg_b := instruction(15 downto 11);

        -- SET IMM value
        if reg.is_immediate = '1' then
            v.imm := reg.immediate & instruction(15 downto 0);
        else
            v.imm := sign_extend(instruction(15 downto 0), instruction(15), 32);
        end if;

        -- Register if an interrupt occurs
        if G_INTERRUPT = true then
            if v_reg.msr_interrupt_enable = '1' and decode_i.interrupt = '1' then
                v_reg.interrupt := '1';
                v_reg.msr_interrupt_enable := '0';
            end if;
        end if;

        v.ctrl_ex.alu_op := ALU_ADD;
        v.ctrl_ex.alu_src_a := ALU_SRC_REGA;
        v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
        v.ctrl_ex.operation := '0';
        v.ctrl_ex.carry := CARRY_ZERO;
        v.ctrl_ex.carry_keep := CARRY_KEEP;
        v.ctrl_ex.delay := '0';
        v.ctrl_ex.branch_cond := NOP;
        v.ctrl_mem.mem_write := '0';
        v.ctrl_mem.transfer_size := WORD;
        v.ctrl_mem.mem_read := '0';
        v.ctrl_wrb.reg_write := '0';

        if G_INTERRUPT = true and (v_reg.interrupt = '1' and reg.delay_interrupt = '0' and decode_i.flush_id = '0' and v.hazard = '0' and r.ctrl_ex.delay = '0' and reg.is_immediate = '0') then
        -- IF an interrupt occured
        --    AND the current instruction is not a branch or return instruction,
        --    AND the current instruction is not in a delay slot,
        --    AND this is instruction is not preceded by an IMM instruction, than handle the interrupt.
            v_reg.msr_interrupt_enable := '0';
            v_reg.interrupt := '0';

            v.reg_a := (others => '0');
            v.reg_b := (others => '0');

            v.imm   := X"00000010";
            v.ctrl_wrb.reg_d := "01110";

            v.ctrl_ex.branch_cond := BNC;
            v.ctrl_ex.alu_src_a := ALU_SRC_ZERO;
            v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            v.ctrl_wrb.reg_write := '1';

        elsif (decode_i.flush_id or v.hazard) = '1' then
            -- clearing these registers is not necessary, but facilitates debugging.
            -- On the other hand performance improves when disabled.
            if G_DEBUG = true then
                v.program_counter := (others => '0');
                v.ctrl_wrb.reg_d  := (others => '0');
                v.reg_a           := (others => '0');
                v.reg_b           := (others => '0');
                v.imm             := (others => '0');
            end if;

        elsif is_zero(opcode(5 downto 4)) = '1' then
        -- ADD, SUBTRACT OR COMPARE

            -- Alu operation
            v.ctrl_ex.alu_op := ALU_ADD;

            -- Source operand A
            if opcode(0) = '1' then
                v.ctrl_ex.alu_src_a := ALU_SRC_NOT_REGA;
            else
                v.ctrl_ex.alu_src_a := ALU_SRC_REGA;
            end if;

            -- Source operand B
            if opcode(3) = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            else
                v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
            end if;

            if (compare(opcode, "000101") and instruction(1)) = '1' then
                v.ctrl_ex.operation := '1';
            end if;

            -- Carry
            case opcode(1 downto 0) is
                when "00" => v.ctrl_ex.carry := CARRY_ZERO;
                when "01" => v.ctrl_ex.carry := CARRY_ONE;
                when others => v.ctrl_ex.carry := CARRY_ALU;
            end case;

            -- Carry keep
            if opcode(2) = '1' then
                v.ctrl_ex.carry_keep := CARRY_KEEP;
            else
                v.ctrl_ex.carry_keep := CARRY_NOT_KEEP;
            end if;

            -- Flag writeback if reg_d != 0
            v.ctrl_wrb.reg_write := is_not_zero(v.ctrl_wrb.reg_d);

        elsif (compare(opcode(5 downto 2), "1000") or compare(opcode(5 downto 2), "1010")) = '1' then
        -- OR, AND, XOR, ANDN
        -- ORI, ANDI, XORI, ANDNI
            case opcode(1 downto 0) is
                when "00" => v.ctrl_ex.alu_op := ALU_OR;
                when "10" => v.ctrl_ex.alu_op := ALU_XOR;
                when others => v.ctrl_ex.alu_op := ALU_AND;
            end case;

            if opcode(3) = '1' and compare(opcode(1 downto 0), "11") = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_NOT_IMM;
            elsif opcode(3) = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            elsif opcode(3) = '0' and compare(opcode(1 downto 0), "11") = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_NOT_REGB;
            else
                v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
            end if;

            -- Flag writeback if reg_d != 0
            v.ctrl_wrb.reg_write := is_not_zero(v.ctrl_wrb.reg_d);

        elsif compare(opcode, "101100") = '1' then
        -- IMM instruction
            v_reg.immediate := instruction(15 downto 0);
            v_reg.is_immediate := '1';

        elsif compare(opcode, "100100") = '1' then
        -- SHIFT, SIGN EXTEND
            if compare(instruction(6 downto 5), "11") = '1' then
                if instruction(0) = '1' then
                    v.ctrl_ex.alu_op:= ALU_SEXT16;
                else
                    v.ctrl_ex.alu_op:= ALU_SEXT8;
                end if;
            else
                v.ctrl_ex.alu_op:= ALU_SHIFT;
                v.ctrl_ex.carry_keep := CARRY_NOT_KEEP;
                case instruction(6 downto 5) is
                    when "10"   => v.ctrl_ex.carry := CARRY_ZERO;
                    when "01"   => v.ctrl_ex.carry := CARRY_ALU;
                    when others => v.ctrl_ex.carry := CARRY_ARITH;
                end case;
            end if;

            -- Flag writeback if reg_d != 0
            v.ctrl_wrb.reg_write := is_not_zero(v.ctrl_wrb.reg_d);

        elsif (compare(opcode, "100110") or compare(opcode, "101110")) = '1' then
        -- BRANCH UNCONDITIONAL

            v.ctrl_ex.branch_cond := BNC;

            if opcode(3) = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            else
                v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
            end if;

            -- WRITE THE RESULT ALSO TO REGISTER D
            if v.reg_a(2) = '1' then
                -- Flag writeback if reg_d != 0
                v.ctrl_wrb.reg_write := is_not_zero(v.ctrl_wrb.reg_d);
            end if;

            if v.reg_a(3) = '1' then
                v.ctrl_ex.alu_src_a := ALU_SRC_ZERO;
            else
                v.ctrl_ex.alu_src_a := ALU_SRC_PC;
            end if;

            if G_INTERRUPT = true then
                v_reg.delay_interrupt := '1';
            end if;
            v.ctrl_ex.delay := v.reg_a(4);

        elsif (compare(opcode, "100111") or compare(opcode, "101111")) = '1' then
        -- BRANCH CONDITIONAL
            v.ctrl_ex.alu_op := ALU_ADD;
            v.ctrl_ex.alu_src_a := ALU_SRC_PC;

            if opcode(3) = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            else
                v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
            end if;

            case v.ctrl_wrb.reg_d(2 downto 0) is
                when "000"  => v.ctrl_ex.branch_cond := BEQ;
                when "001"  => v.ctrl_ex.branch_cond := BNE;
                when "010"  => v.ctrl_ex.branch_cond := BLT;
                when "011"  => v.ctrl_ex.branch_cond := BLE;
                when "100"  => v.ctrl_ex.branch_cond := BGT;
                when others => v.ctrl_ex.branch_cond := BGE;
            end case;

            if G_INTERRUPT = true then
                v_reg.delay_interrupt := '1';
            end if;
            v.ctrl_ex.delay := v.ctrl_wrb.reg_d(4);

        elsif compare(opcode, "101101") = '1' then
        -- RETURN

            v.ctrl_ex.branch_cond := BNC;
            v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            v.ctrl_ex.delay := '1';

            if G_INTERRUPT = true then
                if v.ctrl_wrb.reg_d(0) = '1' then
                    v_reg.msr_interrupt_enable := '1';
                end if;
                v_reg.delay_interrupt := '1';
            end if;

        elsif compare(opcode(5 downto 4), "11") = '1' then
            -- SW, LW
            v.ctrl_ex.alu_op := ALU_ADD;
            v.ctrl_ex.alu_src_a := ALU_SRC_REGA;

            if opcode(3) = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            else
                v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
            end if;

            v.ctrl_ex.carry := CARRY_ZERO;

            if opcode(2) = '1' then
                -- Store
                v.ctrl_mem.mem_write := '1';
                v.ctrl_mem.mem_read  := '0';
                v.ctrl_wrb.reg_write := '0';
            else
                -- Load
                v.ctrl_mem.mem_write := '0';
                v.ctrl_mem.mem_read  := '1';
                v.ctrl_wrb.reg_write := is_not_zero(v.ctrl_wrb.reg_d);
            end if;

            case opcode(1 downto 0) is
                when "00" => v.ctrl_mem.transfer_size := BYTE;
                when "01" => v.ctrl_mem.transfer_size := HALFWORD;
                when others => v.ctrl_mem.transfer_size := WORD;
            end case;

            v.ctrl_ex.delay := '0';

        elsif G_USE_HW_MUL = true and (compare(opcode, "010000") or compare(opcode, "011000")) = '1' then

            v.ctrl_ex.alu_op := ALU_MUL;

            if opcode(3) = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            else
                v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
            end if;

            v.ctrl_wrb.reg_write := is_not_zero(v.ctrl_wrb.reg_d);

        elsif G_USE_BARREL = true and (compare(opcode, "010001") or compare(opcode, "011001")) = '1' then

            v.ctrl_ex.alu_op := ALU_BS;

            if opcode(3) = '1' then
                v.ctrl_ex.alu_src_b := ALU_SRC_IMM;
            else
                v.ctrl_ex.alu_src_b := ALU_SRC_REGB;
            end if;

            v.ctrl_wrb.reg_write := is_not_zero(v.ctrl_wrb.reg_d);

        else
            -- UNKNOWN OPCODE
            null;
        end if;

        rin <= v;
        regin <= v_reg;

    end process;

    decode_seq: process(clk_i)
        procedure proc_reset_decode is
        begin
            r.reg_a                  <= (others => '0');
            r.reg_b                  <= (others => '0');
            r.imm                    <= (others => '0');
            r.program_counter        <= (others => '0');
            r.hazard                 <= '0';
            r.ctrl_ex.alu_op         <= ALU_ADD;
            r.ctrl_ex.alu_src_a      <= ALU_SRC_REGA;
            r.ctrl_ex.alu_src_b      <= ALU_SRC_REGB;
            r.ctrl_ex.operation      <= '0';
            r.ctrl_ex.carry          <= CARRY_ZERO;
            r.ctrl_ex.carry_keep     <= CARRY_NOT_KEEP;
            r.ctrl_ex.delay          <= '0';
            r.ctrl_ex.branch_cond    <= NOP;
            r.ctrl_mem.mem_write     <= '0';
            r.ctrl_mem.transfer_size <= WORD;
            r.ctrl_mem.mem_read      <= '0';
            r.ctrl_wrb.reg_d          <= (others => '0');
            r.ctrl_wrb.reg_write      <= '0';
            r.fwd_dec_result         <= (others => '0');
            r.fwd_dec.reg_d          <= (others => '0');
            r.fwd_dec.reg_write      <= '0';
            reg.instruction          <= (others => '0');
            reg.program_counter      <= (others => '0');
            reg.immediate            <= (others => '0');
            reg.is_immediate         <= '0';
            reg.msr_interrupt_enable <= '1';
            reg.interrupt            <= '0';
            reg.delay_interrupt      <= '0';
        end procedure proc_reset_decode;
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                proc_reset_decode;
            elsif ena_i = '1' then
                r <= rin;
                reg <= regin;
            end if;
        end if;
    end process;

    gprf0 : gprf port map
    (
        gprf_o         => gprf_o,
        gprf_i.adr_a_i => rin.reg_a,
        gprf_i.adr_b_i => rin.reg_b,
        gprf_i.adr_d_i => rin.ctrl_wrb.reg_d,
        gprf_i.dat_w_i => wb_dat_d,
        gprf_i.adr_w_i => decode_i.ctrl_wrb.reg_d,
        gprf_i.wre_i   => decode_i.ctrl_wrb.reg_write,
        ena_i          => ena_i,
        clk_i          => clk_i
    );
end arch;
