package ao68000_tool;
class Parser {
	boolean newline;
	Parser() { this(true); }
	Parser(boolean newline) { this.newline = newline; }
	Parser EA_REG_IR_2_0() throws Exception {
		GenerateMicrocode.entry(newline, "EA_REG_IR_2_0");
		return new Parser(false);
	}
	Parser EA_REG_IR_11_9() throws Exception {
		GenerateMicrocode.entry(newline, "EA_REG_IR_11_9");
		return new Parser(false);
	}
	Parser EA_REG_MOVEM_REG_2_0() throws Exception {
		GenerateMicrocode.entry(newline, "EA_REG_MOVEM_REG_2_0");
		return new Parser(false);
	}
	Parser EA_REG_3b111() throws Exception {
		GenerateMicrocode.entry(newline, "EA_REG_3b111");
		return new Parser(false);
	}
	Parser EA_REG_3b100() throws Exception {
		GenerateMicrocode.entry(newline, "EA_REG_3b100");
		return new Parser(false);
	}
	Parser EA_MOD_IR_5_3() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_IR_5_3");
		return new Parser(false);
	}
	Parser EA_MOD_MOVEM_MOD_5_3() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_MOVEM_MOD_5_3");
		return new Parser(false);
	}
	Parser EA_MOD_IR_8_6() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_IR_8_6");
		return new Parser(false);
	}
	Parser EA_MOD_PREDEC() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_PREDEC");
		return new Parser(false);
	}
	Parser EA_MOD_3b111() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_3b111");
		return new Parser(false);
	}
	Parser EA_MOD_DN_PREDEC() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_DN_PREDEC");
		return new Parser(false);
	}
	Parser EA_MOD_DN_AN_EXG() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_DN_AN_EXG");
		return new Parser(false);
	}
	Parser EA_MOD_POSTINC() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_POSTINC");
		return new Parser(false);
	}
	Parser EA_MOD_AN() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_AN");
		return new Parser(false);
	}
	Parser EA_MOD_DN() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_DN");
		return new Parser(false);
	}
	Parser EA_MOD_INDIRECTOFFSET() throws Exception {
		GenerateMicrocode.entry(newline, "EA_MOD_INDIRECTOFFSET");
		return new Parser(false);
	}
	Parser EA_TYPE_ALL() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_ALL");
		return new Parser(false);
	}
	Parser EA_TYPE_CONTROL_POSTINC() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_CONTROL_POSTINC");
		return new Parser(false);
	}
	Parser EA_TYPE_CONTROLALTER_PREDEC() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_CONTROLALTER_PREDEC");
		return new Parser(false);
	}
	Parser EA_TYPE_CONTROL() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_CONTROL");
		return new Parser(false);
	}
	Parser EA_TYPE_DATAALTER() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_DATAALTER");
		return new Parser(false);
	}
	Parser EA_TYPE_DN_AN() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_DN_AN");
		return new Parser(false);
	}
	Parser EA_TYPE_MEMORYALTER() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_MEMORYALTER");
		return new Parser(false);
	}
	Parser EA_TYPE_DATA() throws Exception {
		GenerateMicrocode.entry(newline, "EA_TYPE_DATA");
		return new Parser(false);
	}
	Parser OP1_FROM_OP2() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_OP2");
		return new Parser(false);
	}
	Parser OP1_FROM_ADDRESS() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_ADDRESS");
		return new Parser(false);
	}
	Parser OP1_FROM_DATA() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_DATA");
		return new Parser(false);
	}
	Parser OP1_FROM_IMMEDIATE() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_IMMEDIATE");
		return new Parser(false);
	}
	Parser OP1_FROM_RESULT() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_RESULT");
		return new Parser(false);
	}
	Parser OP1_MOVEQ() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_MOVEQ");
		return new Parser(false);
	}
	Parser OP1_FROM_PC() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_PC");
		return new Parser(false);
	}
	Parser OP1_LOAD_ZEROS() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_LOAD_ZEROS");
		return new Parser(false);
	}
	Parser OP1_LOAD_ONES() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_LOAD_ONES");
		return new Parser(false);
	}
	Parser OP1_FROM_SR() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_SR");
		return new Parser(false);
	}
	Parser OP1_FROM_USP() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_USP");
		return new Parser(false);
	}
	Parser OP1_FROM_AN() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_AN");
		return new Parser(false);
	}
	Parser OP1_FROM_DN() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_DN");
		return new Parser(false);
	}
	Parser OP1_FROM_IR() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_IR");
		return new Parser(false);
	}
	Parser OP1_FROM_FAULT_ADDRESS() throws Exception {
		GenerateMicrocode.entry(newline, "OP1_FROM_FAULT_ADDRESS");
		return new Parser(false);
	}
	Parser OP2_FROM_OP1() throws Exception {
		GenerateMicrocode.entry(newline, "OP2_FROM_OP1");
		return new Parser(false);
	}
	Parser OP2_LOAD_1() throws Exception {
		GenerateMicrocode.entry(newline, "OP2_LOAD_1");
		return new Parser(false);
	}
	Parser OP2_LOAD_COUNT() throws Exception {
		GenerateMicrocode.entry(newline, "OP2_LOAD_COUNT");
		return new Parser(false);
	}
	Parser OP2_ADDQ_SUBQ() throws Exception {
		GenerateMicrocode.entry(newline, "OP2_ADDQ_SUBQ");
		return new Parser(false);
	}
	Parser OP2_MOVE_OFFSET() throws Exception {
		GenerateMicrocode.entry(newline, "OP2_MOVE_OFFSET");
		return new Parser(false);
	}
	Parser OP2_MOVE_ADDRESS_BUS_INFO() throws Exception {
		GenerateMicrocode.entry(newline, "OP2_MOVE_ADDRESS_BUS_INFO");
		return new Parser(false);
	}
	Parser OP2_DECR_BY_1() throws Exception {
		GenerateMicrocode.entry(newline, "OP2_DECR_BY_1");
		return new Parser(false);
	}
	Parser ADDRESS_INCR_BY_SIZE() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_INCR_BY_SIZE");
		return new Parser(false);
	}
	Parser ADDRESS_DECR_BY_SIZE() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_DECR_BY_SIZE");
		return new Parser(false);
	}
	Parser ADDRESS_INCR_BY_2() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_INCR_BY_2");
		return new Parser(false);
	}
	Parser ADDRESS_FROM_AN_OUTPUT() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_FROM_AN_OUTPUT");
		return new Parser(false);
	}
	Parser ADDRESS_FROM_BASE_INDEX_OFFSET() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_FROM_BASE_INDEX_OFFSET");
		return new Parser(false);
	}
	Parser ADDRESS_FROM_IMM_16() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_FROM_IMM_16");
		return new Parser(false);
	}
	Parser ADDRESS_FROM_IMM_32() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_FROM_IMM_32");
		return new Parser(false);
	}
	Parser ADDRESS_FROM_PC_INDEX_OFFSET() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_FROM_PC_INDEX_OFFSET");
		return new Parser(false);
	}
	Parser ADDRESS_FROM_TRAP() throws Exception {
		GenerateMicrocode.entry(newline, "ADDRESS_FROM_TRAP");
		return new Parser(false);
	}
	Parser SIZE_BYTE() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_BYTE");
		return new Parser(false);
	}
	Parser SIZE_WORD() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_WORD");
		return new Parser(false);
	}
	Parser SIZE_LONG() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_LONG");
		return new Parser(false);
	}
	Parser SIZE_1() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_1");
		return new Parser(false);
	}
	Parser SIZE_1_PLUS() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_1_PLUS");
		return new Parser(false);
	}
	Parser SIZE_2() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_2");
		return new Parser(false);
	}
	Parser SIZE_3() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_3");
		return new Parser(false);
	}
	Parser SIZE_4() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_4");
		return new Parser(false);
	}
	Parser SIZE_5() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_5");
		return new Parser(false);
	}
	Parser SIZE_6() throws Exception {
		GenerateMicrocode.entry(newline, "SIZE_6");
		return new Parser(false);
	}
	Parser MOVEM_MODREG_LOAD_0() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_MODREG_LOAD_0");
		return new Parser(false);
	}
	Parser MOVEM_MODREG_LOAD_6b001111() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_MODREG_LOAD_6b001111");
		return new Parser(false);
	}
	Parser MOVEM_MODREG_INCR_BY_1() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_MODREG_INCR_BY_1");
		return new Parser(false);
	}
	Parser MOVEM_MODREG_DECR_BY_1() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_MODREG_DECR_BY_1");
		return new Parser(false);
	}
	Parser MOVEM_LOOP_LOAD_0() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_LOOP_LOAD_0");
		return new Parser(false);
	}
	Parser MOVEM_LOOP_INCR_BY_1() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_LOOP_INCR_BY_1");
		return new Parser(false);
	}
	Parser MOVEM_REG_FROM_OP1() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_REG_FROM_OP1");
		return new Parser(false);
	}
	Parser MOVEM_REG_SHIFT_RIGHT() throws Exception {
		GenerateMicrocode.entry(newline, "MOVEM_REG_SHIFT_RIGHT");
		return new Parser(false);
	}
	Parser IR_LOAD_WHEN_PREFETCH_VALID() throws Exception {
		GenerateMicrocode.entry(newline, "IR_LOAD_WHEN_PREFETCH_VALID");
		return new Parser(false);
	}
	Parser PC_FROM_RESULT() throws Exception {
		GenerateMicrocode.entry(newline, "PC_FROM_RESULT");
		return new Parser(false);
	}
	Parser PC_INCR_BY_2() throws Exception {
		GenerateMicrocode.entry(newline, "PC_INCR_BY_2");
		return new Parser(false);
	}
	Parser PC_INCR_BY_4() throws Exception {
		GenerateMicrocode.entry(newline, "PC_INCR_BY_4");
		return new Parser(false);
	}
	Parser PC_INCR_BY_SIZE() throws Exception {
		GenerateMicrocode.entry(newline, "PC_INCR_BY_SIZE");
		return new Parser(false);
	}
	Parser PC_FROM_PREFETCH_IR() throws Exception {
		GenerateMicrocode.entry(newline, "PC_FROM_PREFETCH_IR");
		return new Parser(false);
	}
	Parser PC_INCR_BY_2_IN_MAIN_LOOP() throws Exception {
		GenerateMicrocode.entry(newline, "PC_INCR_BY_2_IN_MAIN_LOOP");
		return new Parser(false);
	}
	Parser TRAP_ILLEGAL_INSTR() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_ILLEGAL_INSTR");
		return new Parser(false);
	}
	Parser TRAP_DIV_BY_ZERO() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_DIV_BY_ZERO");
		return new Parser(false);
	}
	Parser TRAP_CHK() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_CHK");
		return new Parser(false);
	}
	Parser TRAP_TRAPV() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_TRAPV");
		return new Parser(false);
	}
	Parser TRAP_PRIVIL_VIOLAT() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_PRIVIL_VIOLAT");
		return new Parser(false);
	}
	Parser TRAP_TRACE() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_TRACE");
		return new Parser(false);
	}
	Parser TRAP_TRAP() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_TRAP");
		return new Parser(false);
	}
	Parser TRAP_FROM_DECODER() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_FROM_DECODER");
		return new Parser(false);
	}
	Parser TRAP_FROM_INTERRUPT() throws Exception {
		GenerateMicrocode.entry(newline, "TRAP_FROM_INTERRUPT");
		return new Parser(false);
	}
	Parser OFFSET_IMM_8() throws Exception {
		GenerateMicrocode.entry(newline, "OFFSET_IMM_8");
		return new Parser(false);
	}
	Parser OFFSET_IMM_16() throws Exception {
		GenerateMicrocode.entry(newline, "OFFSET_IMM_16");
		return new Parser(false);
	}
	Parser INDEX_0() throws Exception {
		GenerateMicrocode.entry(newline, "INDEX_0");
		return new Parser(false);
	}
	Parser INDEX_LOAD_EXTENDED() throws Exception {
		GenerateMicrocode.entry(newline, "INDEX_LOAD_EXTENDED");
		return new Parser(false);
	}
	Parser STOP_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "STOP_FLAG_SET");
		return new Parser(false);
	}
	Parser STOP_FLAG_CLEAR() throws Exception {
		GenerateMicrocode.entry(newline, "STOP_FLAG_CLEAR");
		return new Parser(false);
	}
	Parser TRACE_FLAG_COPY_WHEN_NO_STOP() throws Exception {
		GenerateMicrocode.entry(newline, "TRACE_FLAG_COPY_WHEN_NO_STOP");
		return new Parser(false);
	}
	Parser GROUP_0_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "GROUP_0_FLAG_SET");
		return new Parser(false);
	}
	Parser GROUP_0_FLAG_CLEAR_WHEN_VALID_PREFETCH() throws Exception {
		GenerateMicrocode.entry(newline, "GROUP_0_FLAG_CLEAR_WHEN_VALID_PREFETCH");
		return new Parser(false);
	}
	Parser INSTRUCTION_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "INSTRUCTION_FLAG_SET");
		return new Parser(false);
	}
	Parser INSTRUCTION_FLAG_CLEAR_IN_MAIN_LOOP() throws Exception {
		GenerateMicrocode.entry(newline, "INSTRUCTION_FLAG_CLEAR_IN_MAIN_LOOP");
		return new Parser(false);
	}
	Parser READ_MODIFY_WRITE_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "READ_MODIFY_WRITE_FLAG_SET");
		return new Parser(false);
	}
	Parser READ_MODIFY_WRITE_FLAG_CLEAR() throws Exception {
		GenerateMicrocode.entry(newline, "READ_MODIFY_WRITE_FLAG_CLEAR");
		return new Parser(false);
	}
	Parser DO_RESET_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "DO_RESET_FLAG_SET");
		return new Parser(false);
	}
	Parser DO_RESET_FLAG_CLEAR() throws Exception {
		GenerateMicrocode.entry(newline, "DO_RESET_FLAG_CLEAR");
		return new Parser(false);
	}
	Parser DO_INTERRUPT_FLAG_SET_IF_ACTIVE() throws Exception {
		GenerateMicrocode.entry(newline, "DO_INTERRUPT_FLAG_SET_IF_ACTIVE");
		return new Parser(false);
	}
	Parser DO_INTERRUPT_FLAG_CLEAR() throws Exception {
		GenerateMicrocode.entry(newline, "DO_INTERRUPT_FLAG_CLEAR");
		return new Parser(false);
	}
	Parser DO_READ_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "DO_READ_FLAG_SET");
		return new Parser(false);
	}
	Parser DO_READ_FLAG_CLEAR() throws Exception {
		GenerateMicrocode.entry(newline, "DO_READ_FLAG_CLEAR");
		return new Parser(false);
	}
	Parser DO_WRITE_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "DO_WRITE_FLAG_SET");
		return new Parser(false);
	}
	Parser DO_WRITE_FLAG_CLEAR() throws Exception {
		GenerateMicrocode.entry(newline, "DO_WRITE_FLAG_CLEAR");
		return new Parser(false);
	}
	Parser DO_BLOCKED_FLAG_SET() throws Exception {
		GenerateMicrocode.entry(newline, "DO_BLOCKED_FLAG_SET");
		return new Parser(false);
	}
	Parser DATA_WRITE_FROM_RESULT() throws Exception {
		GenerateMicrocode.entry(newline, "DATA_WRITE_FROM_RESULT");
		return new Parser(false);
	}
	Parser AN_ADDRESS_FROM_EXTENDED() throws Exception {
		GenerateMicrocode.entry(newline, "AN_ADDRESS_FROM_EXTENDED");
		return new Parser(false);
	}
	Parser AN_ADDRESS_USP() throws Exception {
		GenerateMicrocode.entry(newline, "AN_ADDRESS_USP");
		return new Parser(false);
	}
	Parser AN_ADDRESS_SSP() throws Exception {
		GenerateMicrocode.entry(newline, "AN_ADDRESS_SSP");
		return new Parser(false);
	}
	Parser AN_WRITE_ENABLE_SET() throws Exception {
		GenerateMicrocode.entry(newline, "AN_WRITE_ENABLE_SET");
		return new Parser(false);
	}
	Parser AN_INPUT_FROM_ADDRESS() throws Exception {
		GenerateMicrocode.entry(newline, "AN_INPUT_FROM_ADDRESS");
		return new Parser(false);
	}
	Parser AN_INPUT_FROM_PREFETCH_IR() throws Exception {
		GenerateMicrocode.entry(newline, "AN_INPUT_FROM_PREFETCH_IR");
		return new Parser(false);
	}
	Parser DN_ADDRESS_FROM_EXTENDED() throws Exception {
		GenerateMicrocode.entry(newline, "DN_ADDRESS_FROM_EXTENDED");
		return new Parser(false);
	}
	Parser DN_WRITE_ENABLE_SET() throws Exception {
		GenerateMicrocode.entry(newline, "DN_WRITE_ENABLE_SET");
		return new Parser(false);
	}
	Parser ALU_SR_SET_INTERRUPT() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_SR_SET_INTERRUPT");
		return new Parser(false);
	}
	Parser ALU_SR_SET_TRAP() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_SR_SET_TRAP");
		return new Parser(false);
	}
	Parser ALU_MOVEP_M2R_1() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_M2R_1");
		return new Parser(false);
	}
	Parser ALU_MOVEP_M2R_2() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_M2R_2");
		return new Parser(false);
	}
	Parser ALU_MOVEP_M2R_3() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_M2R_3");
		return new Parser(false);
	}
	Parser ALU_MOVEP_M2R_4() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_M2R_4");
		return new Parser(false);
	}
	Parser ALU_MOVEP_R2M_1() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_R2M_1");
		return new Parser(false);
	}
	Parser ALU_MOVEP_R2M_2() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_R2M_2");
		return new Parser(false);
	}
	Parser ALU_MOVEP_R2M_3() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_R2M_3");
		return new Parser(false);
	}
	Parser ALU_MOVEP_R2M_4() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVEP_R2M_4");
		return new Parser(false);
	}
	Parser ALU_SIGN_EXTEND() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_SIGN_EXTEND");
		return new Parser(false);
	}
	Parser ALU_ARITHMETIC_LOGIC() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_ARITHMETIC_LOGIC");
		return new Parser(false);
	}
	Parser ALU_ABCD_SBCD_ADDX_SUBX_prepare() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_ABCD_SBCD_ADDX_SUBX_prepare");
		return new Parser(false);
	}
	Parser ALU_ABCD_SBCD_ADDX_SUBX() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_ABCD_SBCD_ADDX_SUBX");
		return new Parser(false);
	}
	Parser ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_prepare() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_prepare");
		return new Parser(false);
	}
	Parser ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR");
		return new Parser(false);
	}
	Parser ALU_MOVE() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVE");
		return new Parser(false);
	}
	Parser ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ");
		return new Parser(false);
	}
	Parser ALU_CHK() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_CHK");
		return new Parser(false);
	}
	Parser ALU_MULS_MULU_DIVS_DIVU() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MULS_MULU_DIVS_DIVU");
		return new Parser(false);
	}
	Parser ALU_BCHG_BCLR_BSET_BTST() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_BCHG_BCLR_BSET_BTST");
		return new Parser(false);
	}
	Parser ALU_TAS() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_TAS");
		return new Parser(false);
	}
	Parser ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT");
		return new Parser(false);
	}
	Parser ALU_SIMPLE_LONG_ADD() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_SIMPLE_LONG_ADD");
		return new Parser(false);
	}
	Parser ALU_SIMPLE_LONG_SUB() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_SIMPLE_LONG_SUB");
		return new Parser(false);
	}
	Parser ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR");
		return new Parser(false);
	}
	Parser ALU_SIMPLE_MOVE() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_SIMPLE_MOVE");
		return new Parser(false);
	}
	Parser ALU_LINK_MOVE() throws Exception {
		GenerateMicrocode.entry(newline, "ALU_LINK_MOVE");
		return new Parser(false);
	}
	Parser BRANCH_movem_loop() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_movem_loop");
		return new Parser(false);
	}
	Parser BRANCH_movem_reg() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_movem_reg");
		return new Parser(false);
	}
	Parser BRANCH_operand2() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_operand2");
		return new Parser(false);
	}
	Parser BRANCH_alu_signal() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_alu_signal");
		return new Parser(false);
	}
	Parser BRANCH_alu_mult_div_ready() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_alu_mult_div_ready");
		return new Parser(false);
	}
	Parser BRANCH_condition_0() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_condition_0");
		return new Parser(false);
	}
	Parser BRANCH_condition_1() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_condition_1");
		return new Parser(false);
	}
	Parser BRANCH_result() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_result");
		return new Parser(false);
	}
	Parser BRANCH_V() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_V");
		return new Parser(false);
	}
	Parser BRANCH_movep_16() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_movep_16");
		return new Parser(false);
	}
	Parser BRANCH_stop_flag_wait_ir_decode() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_stop_flag_wait_ir_decode");
		return new Parser(false);
	}
	Parser BRANCH_ir() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_ir");
		return new Parser(false);
	}
	Parser BRANCH_trace_flag_and_interrupt() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_trace_flag_and_interrupt");
		return new Parser(false);
	}
	Parser BRANCH_group_0_flag() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_group_0_flag");
		return new Parser(false);
	}
	Parser BRANCH_procedure() throws Exception {
		GenerateMicrocode.entry(newline, "BRANCH_procedure");
		return new Parser(false);
	}
	Parser PROCEDURE_call_load_ea() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_call_load_ea");
		return new Parser(false);
	}
	Parser PROCEDURE_call_perform_ea_read() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_call_perform_ea_read");
		return new Parser(false);
	}
	Parser PROCEDURE_call_perform_ea_write() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_call_perform_ea_write");
		return new Parser(false);
	}
	Parser PROCEDURE_call_save_ea() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_call_save_ea");
		return new Parser(false);
	}
	Parser PROCEDURE_return() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_return");
		return new Parser(false);
	}
	Parser PROCEDURE_wait_finished() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_wait_finished");
		return new Parser(false);
	}
	Parser PROCEDURE_wait_prefetch_valid() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_wait_prefetch_valid");
		return new Parser(false);
	}
	Parser PROCEDURE_wait_prefetch_valid_32() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_wait_prefetch_valid_32");
		return new Parser(false);
	}
	Parser PROCEDURE_jump_to_main_loop() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_jump_to_main_loop");
		return new Parser(false);
	}
	Parser PROCEDURE_push_micropc() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_push_micropc");
		return new Parser(false);
	}
	Parser PROCEDURE_call_trap() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_call_trap");
		return new Parser(false);
	}
	Parser PROCEDURE_pop_micropc() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_pop_micropc");
		return new Parser(false);
	}
	Parser PROCEDURE_interrupt_mask() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_interrupt_mask");
		return new Parser(false);
	}
	Parser PROCEDURE_call_read() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_call_read");
		return new Parser(false);
	}
	Parser PROCEDURE_call_write() throws Exception {
		GenerateMicrocode.entry(newline, "PROCEDURE_call_write");
		return new Parser(false);
	}
	void label(String label) throws Exception { GenerateMicrocode.entry(newline, "label_" + label); }
	Parser offset(String label) throws Exception {
		GenerateMicrocode.entry(newline, "offset_" + label);
		return new Parser(false);
	}
}
