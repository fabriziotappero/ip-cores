wire [4:0] rd_call_gate_param;
assign rd_call_gate_param = glob_param_3[24:20] - 5'd1;

wire rd_io_allow_1_fault;
wire rd_io_allow_2_fault;
assign rd_io_allow_1_fault = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_1 && (   ~(tr_cache_valid) || (tr_cache[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_386 && tr_cache[`DESC_BITS_TYPE] != `DESC_TSS_BUSY_386) || tr_limit < 32'd103 );
assign rd_io_allow_2_fault = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_2 && ({ 16'd0, rd_memory_last[15:0] } + { 16'd0, 3'd0, glob_param_1[15:3] }) >= tr_limit;
assign rd_io_allow_fault = rd_io_allow_1_fault || rd_io_allow_2_fault;

wire rd_imul_modregrm_mutex_busy;
assign rd_imul_modregrm_mutex_busy = (  rd_decoder[3]  && rd_mutex_busy_modregrm_reg) || (~(rd_decoder[3]) && rd_mutex_busy_eax);

wire rd_arith_modregrm_to_rm;
wire rd_arith_modregrm_to_reg;
assign rd_arith_modregrm_to_rm = ~(rd_decoder[1]);
assign rd_arith_modregrm_to_reg= rd_decoder[1];

wire rd_in_condition;
assign rd_in_condition = (rd_mutex_busy_active && (rd_cmdex == `CMDEX_IN_imm || rd_cmdex == `CMDEX_IN_dx) && ~(io_allow_check_needed)) || (rd_cmdex == `CMDEX_IN_dx && rd_mutex_busy_edx);

wire [31:0] rd_offset_for_esp_from_tss;
wire [31:0] rd_offset_for_ss_from_tss;
wire [31:0] r_limit_for_ss_esp_from_tss;
wire        rd_ss_esp_from_tss_386;
assign rd_ss_esp_from_tss_386 = tr_cache[`DESC_BITS_TYPE] == `DESC_TSS_AVAIL_386 || tr_cache[`DESC_BITS_TYPE] == `DESC_TSS_BUSY_386;
assign r_limit_for_ss_esp_from_tss = (rd_ss_esp_from_tss_386)?   { 27'd0, glob_descriptor[`DESC_BITS_DPL], 3'd0 } + 32'd11 : { 28'd0, glob_descriptor[`DESC_BITS_DPL], 2'd0 } + 32'd5;
assign rd_offset_for_ss_from_tss = (rd_ss_esp_from_tss_386)?   { 27'd0, glob_descriptor[`DESC_BITS_DPL], 3'd0 } + 32'd8 : { 28'd0, glob_descriptor[`DESC_BITS_DPL], 2'd0 } + 32'd4;
assign rd_offset_for_esp_from_tss = (rd_ss_esp_from_tss_386)?   { 27'd0, glob_descriptor[`DESC_BITS_DPL], 3'd0 } + 32'd4 : { 28'd0, glob_descriptor[`DESC_BITS_DPL], 2'd0 } + 32'd2;
assign rd_ss_esp_from_tss_fault = (   (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_0) || (rd_cmd == `CMD_int_2  && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_0) ) && r_limit_for_ss_esp_from_tss > tr_limit;

wire [31:0] rd_task_switch_linear_next;
reg [31:0] rd_task_switch_linear_reg;
assign rd_task_switch_linear_next = (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? rd_task_switch_linear_reg + 32'd2 : rd_task_switch_linear_reg + 32'd4;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)                                                               rd_task_switch_linear_reg <= 32'd0; else if(rd_cmd == `CMD_task_switch && rd_cmdex == `CMDEX_task_switch_STEP_12)   rd_task_switch_linear_reg <= rd_system_linear; else if(rd_ready)                                                               rd_task_switch_linear_reg <= rd_task_switch_linear_next;
end

//======================================================== conditions
wire cond_0 = rd_cmd == `CMD_XADD && rd_cmdex == `CMDEX_XADD_FIRST;
wire cond_1 = rd_modregrm_mod == 2'b11;
wire cond_2 = rd_mutex_busy_modregrm_reg || rd_mutex_busy_modregrm_rm;
wire cond_3 = rd_modregrm_mod != 2'b11;
wire cond_4 = rd_mutex_busy_modregrm_reg || rd_mutex_busy_memory;
wire cond_5 = ~(read_for_rd_ready);
wire cond_6 = rd_cmd == `CMD_XADD && rd_cmdex == `CMDEX_XADD_LAST;
wire cond_7 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Ev_STEP_0;
wire cond_8 = rd_mutex_busy_modregrm_rm;
wire cond_9 = rd_mutex_busy_memory;
wire cond_10 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Jv_STEP_0;
wire cond_11 = rd_cmd == `CMD_CALL && (rd_cmdex == `CMDEX_CALL_Ep_STEP_0 || rd_cmdex == `CMDEX_CALL_Ep_STEP_1);
wire cond_12 = rd_cmdex == `CMDEX_CALL_Ep_STEP_1;
wire cond_13 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Ap_STEP_0;
wire cond_14 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Ap_STEP_1;
wire cond_15 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_protected_STEP_0;
wire cond_16 = rd_mutex_busy_active;
wire cond_17 = glob_param_1[15:2] != 14'd0;
wire cond_18 = rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_task_gate_STEP_0;
wire cond_19 = rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_task_gate_STEP_1;
wire cond_20 = glob_param_1[`SELECTOR_BIT_TI] == 1'b0;
wire cond_21 = rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_STEP_1;
wire cond_22 = rd_cmd == `CMD_CALL_3 && (rd_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_4 || rd_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_5);
wire cond_23 = ~(glob_param_3[19]);
wire cond_24 = glob_param_3[19];
wire cond_25 = rd_ready;
wire cond_26 = rd_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_4;
wire cond_27 = rd_cmd == `CMD_PUSH_MOV_SEG && { rd_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_implicit;
wire cond_28 = rd_cmd == `CMD_PUSH_MOV_SEG && { rd_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_modregrm;
wire cond_29 = ~(write_virtual_check_ready);
wire cond_30 = rd_cmd == `CMD_NEG;
wire cond_31 = rd_cmd == `CMD_INVLPG && rd_cmdex == `CMDEX_INVLPG_STEP_1;
wire cond_32 = ~(rd_address_effective_ready);
wire cond_33 = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_1;
wire cond_34 = rd_io_allow_1_fault || rd_mutex_busy_active;
wire cond_35 = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_2;
wire cond_36 = rd_io_allow_2_fault;
wire cond_37 = rd_cmd == `CMD_SCAS;
wire cond_38 = rd_mutex_busy_memory || (rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0);
wire cond_39 = ~(rd_string_ignore);
wire cond_40 = rd_cmd == `CMD_INC_DEC && { rd_cmdex[3:1], 1'b0 } == `CMDEX_INC_DEC_modregrm;
wire cond_41 = rd_cmd == `CMD_INC_DEC && { rd_cmdex[3:1], 1'b0 } == `CMDEX_INC_DEC_implicit;
wire cond_42 = rd_mutex_busy_implicit_reg;
wire cond_43 = rd_cmd == `CMD_RET_near && rd_cmdex != `CMDEX_RET_near_LAST;
wire cond_44 = rd_cmd == `CMD_ARPL;
wire cond_45 = rd_mutex_busy_modregrm_rm || rd_mutex_busy_modregrm_reg;
wire cond_46 = rd_mutex_busy_memory || rd_mutex_busy_modregrm_reg;
wire cond_47 = rd_cmd == `CMD_BSWAP;
wire cond_48 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_1;
wire cond_49 = ~(rd_address_effective_ready) || rd_mutex_busy_memory;
wire cond_50 = rd_operand_16bit;
wire cond_51 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_2;
wire cond_52 = rd_operand_32bit;
wire cond_53 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_3;
wire cond_54 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_LAST;
wire cond_55 = (rd_cmd == `CMD_MOV_to_seg || rd_cmd == `CMD_LLDT || rd_cmd == `CMD_LTR) && rd_cmdex == `CMDEX_MOV_to_seg_LLDT_LTR_STEP_1;
wire cond_56 = rd_cmd == `CMD_MOV_to_seg || cpl == 2'd0;
wire cond_57 = rd_cmd == `CMD_MOV_to_seg;
wire cond_58 = rd_cmd == `CMD_LLDT;
wire cond_59 = rd_cmd == `CMD_LTR;
wire cond_60 = rd_cmd == `CMD_CLC || rd_cmd == `CMD_CMC || rd_cmd == `CMD_CLD || rd_cmd == `CMD_STC || rd_cmd == `CMD_STD || rd_cmd == `CMD_SAHF;
wire cond_61 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_task_gate_STEP_0;
wire cond_62 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_task_gate_STEP_1;
wire cond_63 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_int_trap_gate_STEP_1;
wire cond_64 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_real_STEP_3;
wire cond_65 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_real_STEP_4;
wire cond_66 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_protected_STEP_1;
wire cond_67 = rd_cmd == `CMD_AAM || rd_cmd == `CMD_AAD;
wire cond_68 = rd_mutex_busy_eax;
wire cond_69 = rd_cmd == `CMD_load_seg && rd_cmdex == `CMDEX_load_seg_STEP_1;
wire cond_70 = v8086_mode;
wire cond_71 = real_mode;
wire cond_72 = protected_mode;
wire cond_73 = rd_cmd == `CMD_load_seg && rd_cmdex == `CMDEX_load_seg_STEP_2;
wire cond_74 = ~(protected_mode && glob_param_1[15:2] == 14'd0);
wire cond_75 = rd_cmd == `CMD_POP_seg && rd_cmdex == `CMDEX_POP_seg_STEP_1;
wire cond_76 = { rd_cmd[6:2], 2'd0 } == `CMD_BTx;
wire cond_77 = rd_mutex_busy_modregrm_rm || (rd_cmdex == `CMDEX_BTx_modregrm && rd_mutex_busy_modregrm_reg);
wire cond_78 = rd_mutex_busy_memory || (rd_cmdex == `CMDEX_BTx_modregrm && rd_mutex_busy_modregrm_reg);
wire cond_79 = rd_cmd == `CMD_IRET && rd_cmdex <= `CMDEX_IRET_real_v86_STEP_2;
wire cond_80 = rd_cmdex >`CMDEX_IRET_real_v86_STEP_0;
wire cond_81 = rd_cmdex == `CMDEX_IRET_real_v86_STEP_0;
wire cond_82 = rd_cmdex == `CMDEX_IRET_real_v86_STEP_1;
wire cond_83 = rd_cmdex == `CMDEX_IRET_real_v86_STEP_2;
wire cond_84 = rd_mutex_busy_memory || (rd_mutex_busy_eflags && v8086_mode);
wire cond_85 = ~(v8086_mode) || iopl == 2'd3;
wire cond_86 = rd_cmd == `CMD_IRET && rd_cmdex == `CMDEX_IRET_protected_STEP_0;
wire cond_87 = rd_mutex_busy_memory || rd_mutex_busy_eflags;
wire cond_88 = rd_cmd == `CMD_IRET && rd_cmdex == `CMDEX_IRET_task_switch_STEP_0;
wire cond_89 = rd_cmd == `CMD_IRET && rd_cmdex == `CMDEX_IRET_task_switch_STEP_1;
wire cond_90 = ~(rd_descriptor_not_in_limits);
wire cond_91 = rd_cmd == `CMD_IRET && rd_cmdex >= `CMDEX_IRET_protected_STEP_1 && rd_cmdex <= `CMDEX_IRET_protected_STEP_3;
wire cond_92 = rd_cmdex == `CMDEX_IRET_protected_STEP_1;
wire cond_93 = rd_cmdex == `CMDEX_IRET_protected_STEP_2;
wire cond_94 = rd_cmdex == `CMDEX_IRET_protected_STEP_3;
wire cond_95 = rd_cmd == `CMD_IRET && rd_cmdex >= `CMDEX_IRET_protected_to_v86_STEP_0;
wire cond_96 = rd_cmdex == `CMDEX_IRET_protected_to_v86_STEP_0;
wire cond_97 = rd_cmd == `CMD_IRET_2 && rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_0;
wire cond_98 = rd_cmd == `CMD_IRET_2 && rd_cmdex >= `CMDEX_IRET_2_protected_outer_STEP_1 && rd_cmdex <= `CMDEX_IRET_2_protected_outer_STEP_3;
wire cond_99 = rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_1;
wire cond_100 = rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_2;
wire cond_101 = rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_3;
wire cond_102 = rd_cmd == `CMD_IRET_2 && rd_cmdex >= `CMDEX_IRET_2_protected_outer_STEP_6;
wire cond_103 = rd_cmd == `CMD_POP && rd_cmdex == `CMDEX_POP_implicit;
wire cond_104 = rd_mutex_busy_memory || rd_mutex_busy_esp;
wire cond_105 = rd_cmd == `CMD_POP && rd_cmdex == `CMDEX_POP_modregrm_STEP_0;
wire cond_106 = rd_cmd == `CMD_POP && rd_cmdex == `CMDEX_POP_modregrm_STEP_1;
wire cond_107 = rd_cmd == `CMD_IDIV || rd_cmd == `CMD_DIV;
wire cond_108 = rd_mutex_busy_eax || (rd_decoder[0] && rd_mutex_busy_edx) || rd_mutex_busy_modregrm_rm;
wire cond_109 = rd_mutex_busy_eax || (rd_decoder[0] && rd_mutex_busy_edx) || rd_mutex_busy_memory;
wire cond_110 = rd_cmd == `CMD_Shift && rd_cmdex != `CMDEX_Shift_implicit;
wire cond_111 = rd_cmd == `CMD_Shift && rd_cmdex == `CMDEX_Shift_implicit;
wire cond_112 = rd_mutex_busy_modregrm_rm || rd_mutex_busy_ecx;
wire cond_113 = rd_mutex_busy_memory || rd_mutex_busy_ecx;
wire cond_114 = rd_cmd == `CMD_CMPS && rd_cmdex == `CMDEX_CMPS_FIRST;
wire cond_115 = rd_cmd == `CMD_CMPS && rd_cmdex == `CMDEX_CMPS_LAST;
wire cond_116 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_SMSW_STEP_0;
wire cond_117 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_LMSW_STEP_0;
wire cond_118 = cpl == 2'd0;
wire cond_119 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_MOV_load_STEP_0;
wire cond_120 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_MOV_store_STEP_0;
wire cond_121 = (rd_cmd == `CMD_LGDT || rd_cmd == `CMD_LIDT) && (rd_cmdex == `CMDEX_LGDT_LIDT_STEP_1 || rd_cmdex == `CMDEX_LGDT_LIDT_STEP_2);
wire cond_122 = rd_cmdex == `CMDEX_LGDT_LIDT_STEP_1;
wire cond_123 = rd_cmdex == `CMDEX_LGDT_LIDT_STEP_2;
wire cond_124 = rd_cmd == `CMD_PUSHA;
wire cond_125 = (rd_cmdex == `CMDEX_PUSHA_STEP_0 && rd_mutex_busy_eax) || (rd_cmdex == `CMDEX_PUSHA_STEP_1 && rd_mutex_busy_ecx) || (rd_cmdex == `CMDEX_PUSHA_STEP_2 && rd_mutex_busy_edx);
wire cond_126 = rd_cmd == `CMD_SETcc;
wire cond_127 = rd_cmd == `CMD_CMPXCHG;
wire cond_128 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_FIRST;
wire cond_129 = rd_mutex_busy_ebp;
wire cond_130 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_LAST;
wire cond_131 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_PUSH;
wire cond_132 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_LOOP;
wire cond_133 = rd_cmd == `CMD_IMUL && rd_cmdex == `CMDEX_IMUL_modregrm_imm;
wire cond_134 = rd_decoder[1:0] == 2'b11;
wire cond_135 = rd_cmd == `CMD_IMUL && rd_cmdex == `CMDEX_IMUL_modregrm;
wire cond_136 = rd_imul_modregrm_mutex_busy || rd_mutex_busy_modregrm_rm;
wire cond_137 = rd_imul_modregrm_mutex_busy || rd_mutex_busy_memory;
wire cond_138 = rd_cmd == `CMD_LEAVE;
wire cond_139 = { rd_cmd[6:1], 1'd0 } == `CMD_SHxD && rd_cmdex != `CMDEX_SHxD_implicit;
wire cond_140 = { rd_cmd[6:1], 1'd0 } == `CMD_SHxD && rd_cmdex == `CMDEX_SHxD_implicit;
wire cond_141 = rd_mutex_busy_modregrm_rm || rd_mutex_busy_ecx || rd_mutex_busy_modregrm_reg;
wire cond_142 = rd_mutex_busy_memory || rd_mutex_busy_ecx || rd_mutex_busy_modregrm_reg;
wire cond_143 = { rd_cmd[6:3], 3'd0 } == `CMD_Arith && rd_cmdex == `CMDEX_Arith_modregrm;
wire cond_144 = rd_decoder[5:3] != 3'b111;
wire cond_145 = rd_decoder[5:3] != 3'b111 && rd_arith_modregrm_to_rm;
wire cond_146 = rd_decoder[5:3] != 3'b111 && rd_arith_modregrm_to_reg;
wire cond_147 = { rd_cmd[6:3], 3'd0 } == `CMD_Arith && rd_cmdex == `CMDEX_Arith_modregrm_imm;
wire cond_148 = rd_decoder[13:11] != 3'b111;
wire cond_149 = { rd_cmd[6:3], 3'd0 } == `CMD_Arith && rd_cmdex == `CMDEX_Arith_immediate;
wire cond_150 = rd_cmd == `CMD_MUL;
wire cond_151 = rd_mutex_busy_eax || rd_mutex_busy_modregrm_rm;
wire cond_152 = rd_mutex_busy_eax || rd_mutex_busy_memory;
wire cond_153 = rd_cmd == `CMD_LOOP;
wire cond_154 = rd_cmd == `CMD_TEST && rd_cmdex == `CMDEX_TEST_modregrm;
wire cond_155 = rd_cmd == `CMD_TEST && rd_cmdex == `CMDEX_TEST_modregrm_imm;
wire cond_156 = rd_cmd == `CMD_TEST && rd_cmdex == `CMDEX_TEST_immediate;
wire cond_157 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_outer_STEP_3;
wire cond_158 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_STEP_1;
wire cond_159 = real_mode || v8086_mode;
wire cond_160 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_STEP_2;
wire cond_161 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_outer_STEP_4;
wire cond_162 = rd_cmd == `CMD_LODS;
wire cond_163 = rd_cmd == `CMD_XCHG && rd_cmdex == `CMDEX_XCHG_implicit;
wire cond_164 = rd_mutex_busy_implicit_reg || rd_mutex_busy_eax;
wire cond_165 = rd_cmd == `CMD_XCHG && rd_cmdex == `CMDEX_XCHG_modregrm;
wire cond_166 = rd_cmd == `CMD_XCHG && rd_cmdex == `CMDEX_XCHG_modregrm_LAST;
wire cond_167 = rd_cmd == `CMD_PUSH && (rd_cmdex == `CMDEX_PUSH_immediate || rd_cmdex == `CMDEX_PUSH_immediate_se);
wire cond_168 = rd_cmd == `CMD_PUSH && rd_cmdex == `CMDEX_PUSH_implicit;
wire cond_169 = rd_cmd == `CMD_PUSH && rd_cmdex == `CMDEX_PUSH_modregrm;
wire cond_170 = rd_cmd == `CMD_INT_INTO && rd_cmdex == `CMDEX_INT_INTO_INTO_STEP_0;
wire cond_171 = rd_mutex_busy_eflags;
wire cond_172 = rd_cmd == `CMD_CPUID;
wire cond_173 = rd_cmd == `CMD_IN && rd_cmdex != `CMDEX_IN_idle;
wire cond_174 = rd_in_condition;
wire cond_175 = ~(io_allow_check_needed) || rd_cmdex == `CMDEX_IN_protected;
wire cond_176 = ~(rd_io_ready);
wire cond_177 = rd_cmd == `CMD_NOT;
wire cond_178 = (rd_cmd == `CMD_LAR || rd_cmd == `CMD_LSL || rd_cmd == `CMD_VERR || rd_cmd == `CMD_VERW) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_1;
wire cond_179 = (rd_cmd == `CMD_LAR || rd_cmd == `CMD_LSL || rd_cmd == `CMD_VERR || rd_cmd == `CMD_VERW) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_2;
wire cond_180 = ~(glob_param_1[15:2] == 14'd0) && ~(rd_descriptor_not_in_limits);
wire cond_181 = (rd_cmd == `CMD_LAR || rd_cmd == `CMD_LSL) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST;
wire cond_182 = rd_cmd == `CMD_LAR;
wire cond_183 = exe_mutex[`MUTEX_ACTIVE_BIT];
wire cond_184 = glob_param_2[1:0] == 2'd0 && ((glob_param_2[2] == 1'd0 && rd_cmd == `CMD_LAR) || (glob_param_2[3] == 1'd0 && rd_cmd == `CMD_LSL));
wire cond_185 = (rd_cmd == `CMD_VERR || rd_cmd == `CMD_VERW) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST;
wire cond_186 = glob_param_2[1:0] == 2'd0 && ((glob_param_2[4] == 1'd0 && rd_cmd == `CMD_VERR) || (glob_param_2[5] == 1'd0 && rd_cmd == `CMD_VERW));
wire cond_187 =  (rd_cmd == `CMD_int_2  && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_0) || (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_0) ;
wire cond_188 = rd_ss_esp_from_tss_fault;
wire cond_189 =  (rd_cmd == `CMD_int_2 && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_1) || (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_1) ;
wire cond_190 =  (rd_cmd == `CMD_int_2 && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_2) || (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_2) ;
wire cond_191 = rd_cmd == `CMD_STOS;
wire cond_192 = rd_mutex_busy_eax || (rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0);
wire cond_193 = rd_cmd == `CMD_INS && (rd_cmdex == `CMDEX_INS_real_1 || rd_cmdex == `CMDEX_INS_protected_1);
wire cond_194 = rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0;
wire cond_195 = ~(rd_string_ignore) && ~(io_allow_check_needed && rd_cmdex == `CMDEX_INS_real_1);
wire cond_196 = rd_cmd == `CMD_INS && (rd_cmdex == `CMDEX_INS_real_2 || rd_cmdex == `CMDEX_INS_protected_2);
wire cond_197 = rd_mutex_busy_edx || (rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0);
wire cond_198 = rd_cmd == `CMD_OUTS;
wire cond_199 = ~(rd_string_ignore) && ~(io_allow_check_needed && rd_cmdex == `CMDEX_OUTS_first);
wire cond_200 = rd_cmd == `CMD_PUSHF;
wire cond_201 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_Jv_STEP_0;
wire cond_202 = rd_cmd == `CMD_JMP  && rd_cmdex == `CMDEX_JMP_Ap_STEP_1;
wire cond_203 = rd_cmd == `CMD_JMP_2 && rd_cmdex == `CMDEX_JMP_2_call_gate_STEP_0;
wire cond_204 = rd_cmd == `CMD_JMP_2 && rd_cmdex == `CMDEX_JMP_2_call_gate_STEP_1;
wire cond_205 = rd_cmd == `CMD_JMP  && rd_cmdex == `CMDEX_JMP_Ev_STEP_0;
wire cond_206 = rd_cmd == `CMD_JMP  && (rd_cmdex == `CMDEX_JMP_Ep_STEP_0  || rd_cmdex == `CMDEX_JMP_Ep_STEP_1);
wire cond_207 = rd_cmdex == `CMDEX_JMP_Ep_STEP_1;
wire cond_208 = rd_cmd == `CMD_JMP  && rd_cmdex == `CMDEX_JMP_Ap_STEP_0;
wire cond_209 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_protected_STEP_0;
wire cond_210 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_task_gate_STEP_0;
wire cond_211 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_task_gate_STEP_1;
wire cond_212 = rd_cmd == `CMD_OUT;
wire cond_213 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_memoffset;
wire cond_214 = ~(rd_decoder[1]);
wire cond_215 = rd_mutex_busy_eax || ~(write_virtual_check_ready);
wire cond_216 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_modregrm && rd_decoder[1];
wire cond_217 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_modregrm && ~(rd_decoder[1]);
wire cond_218 = rd_mutex_busy_modregrm_reg;
wire cond_219 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_modregrm_imm;
wire cond_220 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_immediate;
wire cond_221 = rd_cmd == `CMD_LAHF || rd_cmd == `CMD_CBW || rd_cmd == `CMD_CWD;
wire cond_222 = rd_cmd == `CMD_POPF && rd_cmdex == `CMDEX_POPF_STEP_0;
wire cond_223 = rd_cmd == `CMD_CLI || rd_cmd == `CMD_STI;
wire cond_224 = rd_cmd == `CMD_BOUND && rd_cmdex == `CMDEX_BOUND_STEP_FIRST;
wire cond_225 = rd_cmd == `CMD_BOUND && rd_cmdex == `CMDEX_BOUND_STEP_LAST;
wire cond_226 = rd_cmd == `CMD_SALC && rd_cmdex == `CMDEX_SALC_STEP_0;
wire cond_227 = rd_cmd == `CMD_task_switch && rd_cmdex == `CMDEX_task_switch_STEP_6;
wire cond_228 = glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_JUMP || glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_IRET;
wire cond_229 = rd_cmd == `CMD_task_switch && rd_cmdex == `CMDEX_task_switch_STEP_9;
wire cond_230 = rd_cmd == `CMD_task_switch_2 && rd_cmdex <= `CMDEX_task_switch_2_STEP_7;
wire cond_231 = rd_cmd == `CMD_task_switch_2 && rd_cmdex == `CMDEX_task_switch_2_STEP_13;
wire cond_232 = rd_cmd == `CMD_task_switch && rd_cmdex >= `CMDEX_task_switch_STEP_12 && rd_cmdex <= `CMDEX_task_switch_STEP_14;
wire cond_233 = rd_cmdex == `CMDEX_task_switch_STEP_12 && glob_descriptor[`DESC_BITS_TYPE] <= 4'd3;
wire cond_234 = rd_cmdex == `CMDEX_task_switch_STEP_12 && glob_descriptor[`DESC_BITS_TYPE] >  4'd3;
wire cond_235 = rd_cmdex == `CMDEX_task_switch_STEP_13 || rd_cmdex == `CMDEX_task_switch_STEP_14;
wire cond_236 = rd_cmdex != `CMDEX_task_switch_STEP_12 || (glob_descriptor[`DESC_BITS_TYPE] > 4'd3 && cr0_pg);
wire cond_237 = rd_cmd == `CMD_task_switch_3;
wire cond_238 = rd_cmdex <= `CMDEX_task_switch_3_STEP_12 || glob_descriptor[`DESC_BITS_TYPE] > 4'd3;
wire cond_239 = rd_cmd == `CMD_task_switch_4 && rd_cmdex == `CMDEX_task_switch_4_STEP_0;
wire cond_240 = glob_param_1[`TASK_SWITCH_SOURCE_BITS] != `TASK_SWITCH_FROM_IRET;
wire cond_241 = rd_cmd == `CMD_task_switch_4 && rd_cmdex == `CMDEX_task_switch_4_STEP_2;
wire cond_242 = glob_param_1[`SELECTOR_BIT_TI] == 1'b0 && glob_param_1[15:2] != 14'd0 && ~(rd_descriptor_not_in_limits);
wire cond_243 = rd_cmd == `CMD_task_switch_4 && rd_cmdex >= `CMDEX_task_switch_4_STEP_3 && rd_cmdex <= `CMDEX_task_switch_4_STEP_8;
wire cond_244 = glob_param_1[15:2] != 14'd0 && ~(rd_descriptor_not_in_limits);
wire cond_245 = rd_cmd == `CMD_LEA;
wire cond_246 = (rd_cmd == `CMD_SGDT || rd_cmd == `CMD_SIDT);
wire cond_247 = rd_cmdex == `CMDEX_SGDT_SIDT_STEP_1;
wire cond_248 = rd_cmdex == `CMDEX_SGDT_SIDT_STEP_2;
wire cond_249 = rd_cmd == `CMD_MOVS;
wire cond_250 = rd_cmd == `CMD_MOVSX || rd_cmd == `CMD_MOVZX;
wire cond_251 = rd_cmd == `CMD_POPA;
wire cond_252 = rd_cmdex[2:0] > 3'd0;
wire cond_253 = rd_cmdex[2:0] == 3'd7;
wire cond_254 = rd_cmd == `CMD_debug_reg && rd_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0;
wire cond_255 = rd_cmd == `CMD_debug_reg && rd_cmdex == `CMDEX_debug_reg_MOV_load_STEP_0;
wire cond_256 = rd_cmd == `CMD_XLAT;
wire cond_257 = rd_cmd == `CMD_AAA || rd_cmd == `CMD_AAS || rd_cmd == `CMD_DAA || rd_cmd == `CMD_DAS;
wire cond_258 = { rd_cmd[6:1], 1'd0 } == `CMD_BSx;
//======================================================== saves
//======================================================== always
//======================================================== sets
assign rd_glob_param_5_set =
    (cond_22 && ~cond_16)? (`TRUE) :
    (cond_98 && cond_100)? (`TRUE) :
    (cond_190 && ~cond_16 && cond_90)? (`TRUE) :
    (cond_190 && ~cond_16 && ~cond_90)? (`TRUE) :
    1'd0;
assign rd_glob_param_2_set =
    (cond_43)? (`TRUE) :
    (cond_48 && ~cond_49 && cond_50)? (`TRUE) :
    (cond_53 && ~cond_50)? (`TRUE) :
    (cond_64)? (`TRUE) :
    (cond_79 && cond_81)? (`TRUE) :
    (cond_89 && ~cond_16 && cond_90)? (`TRUE) :
    (cond_89 && ~cond_16 && ~cond_90)? (`TRUE) :
    (cond_91 && cond_94)? (`TRUE) :
    (cond_98 && cond_101)? (`TRUE) :
    (cond_158 && ~cond_9 && cond_159)? (`TRUE) :
    (cond_160 && ~cond_9 && cond_72)? (`TRUE) :
    (cond_179 && cond_180 && ~cond_9)? (`TRUE) :
    (cond_179 && ~cond_180)? (`TRUE) :
    (cond_203 && ~cond_16)? (`TRUE) :
    (cond_227 && ~cond_16 && cond_228)? (`TRUE) :
    (cond_241 && ~cond_16 && cond_242)? (`TRUE) :
    (cond_241 && ~cond_16 && ~cond_242)? (`TRUE) :
    (cond_243 && ~cond_16 && cond_70)? (`TRUE) :
    (cond_243 && ~cond_16 && ~cond_70 && cond_244)? (`TRUE) :
    (cond_243 && ~cond_16 && ~cond_70 && ~cond_244)? (`TRUE) :
    1'd0;
assign rd_req_all =
    (cond_251 && cond_253)? (`TRUE) :
    1'd0;
assign rd_req_esp =
    (cond_27)? (`TRUE) :
    (cond_43)? (`TRUE) :
    (cond_75)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_105)? (`TRUE) :
    (cond_124)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_130)? (`TRUE) :
    (cond_131)? (`TRUE) :
    (cond_132)? (`TRUE) :
    (cond_138 && ~cond_9)? (`TRUE) :
    (cond_167)? (`TRUE) :
    (cond_168)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_200)? (`TRUE) :
    (cond_222)? (`TRUE) :
    1'd0;
assign rd_src_is_cmdex =
    (cond_124)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_230)? (`TRUE) :
    1'd0;
assign rd_req_implicit_reg =
    (cond_41)? (`TRUE) :
    (cond_47)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_220)? (`TRUE) :
    1'd0;
assign rd_req_reg =
    (cond_6)? (`TRUE) :
    (cond_54)? (`TRUE) :
    (cond_133)? (`TRUE) :
    (cond_135)? (          rd_decoder[3]) :
    (cond_143 && cond_1 && cond_144)? ( rd_arith_modregrm_to_reg) :
    (cond_143 && cond_3 && cond_146)? (`TRUE) :
    (cond_166)? (`TRUE) :
    (cond_181 && ~cond_183 && cond_184)? (`TRUE) :
    (cond_216)? (`TRUE) :
    (cond_245)? (`TRUE) :
    (cond_258)? (`TRUE) :
    1'd0;
assign rd_dst_is_0 =
    (cond_30)? (`TRUE) :
    1'd0;
assign address_esi =
    (cond_114)? (`TRUE) :
    (cond_162)? (`TRUE) :
    (cond_198)? (`TRUE) :
    (cond_249)? (`TRUE) :
    1'd0;
assign address_stack_save =
    (cond_22 && cond_26)? (`TRUE) :
    (cond_91 && cond_92)? (`TRUE) :
    (cond_95 && cond_96)? (`TRUE) :
    (cond_98 && cond_99)? (`TRUE) :
    (cond_158)? (`TRUE) :
    (cond_157)? (`TRUE) :
    1'd0;
assign read_rmw_virtual =
    (cond_0 && cond_3 && ~cond_4)? (`TRUE) :
    (cond_30 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_40 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_44 && cond_3 && ~cond_46)? (`TRUE) :
    (cond_76 && cond_3 && ~cond_78)? (    rd_cmd[1:0] != 2'd0) :
    (cond_110 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_111 && cond_3 && ~cond_113)? (`TRUE) :
    (cond_127 && cond_3 && ~cond_4)? (`TRUE) :
    (cond_130)? (`TRUE) :
    (cond_139 && cond_3 && ~cond_46)? (`TRUE) :
    (cond_140 && cond_3 && ~cond_142)? (`TRUE) :
    (cond_143 && cond_3 && ~cond_46 && cond_145)? (`TRUE) :
    (cond_147 && cond_3 && ~cond_9 && cond_148)? (`TRUE) :
    (cond_165 && cond_3 && ~cond_4)? (`TRUE) :
    (cond_177 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_193 && ~cond_194 && cond_195)? (`TRUE) :
    1'd0;
assign address_stack_pop_speedup =
    (cond_79 && cond_80)? (`TRUE) :
    (cond_160)? (  real_mode || v8086_mode) :
    (cond_251 && cond_252)? (`TRUE) :
    1'd0;
assign io_read =
    (cond_173 && ~cond_174 && cond_175)? (`TRUE) :
    (cond_196 && ~cond_197 && cond_195)? (`TRUE) :
    1'd0;
assign address_leave =
    (cond_138)? (`TRUE) :
    1'd0;
assign rd_dst_is_eax =
    (cond_37 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_67)? (`TRUE) :
    (cond_149)? (`TRUE) :
    (cond_156)? (`TRUE) :
    (cond_213 && cond_214)? (`TRUE) :
    (cond_256)? (`TRUE) :
    (cond_257)? (`TRUE) :
    1'd0;
assign rd_src_is_imm =
    (cond_10)? (`TRUE) :
    (cond_13)? (`TRUE) :
    (cond_67)? (`TRUE) :
    (cond_149)? (`TRUE) :
    (cond_156)? (`TRUE) :
    (cond_167)? (`TRUE) :
    (cond_208)? (`TRUE) :
    (cond_220)? (`TRUE) :
    1'd0;
assign address_bits_transform =
    (cond_76)? ( rd_cmdex == `CMDEX_BTx_modregrm) :
    1'd0;
assign rd_src_is_1 =
    (cond_40)? (`TRUE) :
    (cond_41)? (`TRUE) :
    (cond_110)? (            rd_cmdex == `CMDEX_Shift_modregrm) :
    1'd0;
assign read_system_dword =
    (cond_189)? ( rd_ss_esp_from_tss_386) :
    (cond_232 && cond_236 && ~cond_9)? ( glob_descriptor[`DESC_BITS_TYPE] >  4'd3) :
    (cond_237 && cond_238)? ( glob_descriptor[`DESC_BITS_TYPE] >  4'd3 && rd_cmdex <= `CMDEX_task_switch_3_STEP_7) :
    1'd0;
assign address_stack_for_ret_first =
    (cond_158)? (`TRUE) :
    1'd0;
assign rd_req_eax =
    (cond_67)? (`TRUE) :
    (cond_107)? (`TRUE) :
    (cond_127)? (`TRUE) :
    (cond_135)? (          ~(rd_decoder[3])) :
    (cond_149 && cond_144)? (`TRUE) :
    (cond_150)? (`TRUE) :
    (cond_162 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_172)? (`TRUE) :
    (cond_213 && cond_214)? (`TRUE) :
    (cond_221)? ( rd_cmd != `CMD_CWD) :
    (cond_226)? (`TRUE) :
    (cond_256)? (`TRUE) :
    (cond_257)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_last =
    (cond_98 && cond_101)? (`TRUE) :
    1'd0;
assign rd_glob_param_3_value =
    (cond_15 && ~cond_16 && cond_17)? ( 32'd0) :
    (cond_22 && cond_25)? ( { 7'd0, rd_call_gate_param, glob_param_3[19:0] }) :
    (cond_79 && cond_83)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_89)? ( { 10'd0, rd_consumed, 18'd0 }) :
    (cond_91 && cond_92)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_97)? ( glob_param_1) :
    (cond_157)? ( glob_param_1) :
    (cond_187 && ~cond_188)? ( { 16'd0, read_4[15:0] }) :
    (cond_209 && ~cond_16 && cond_17)? ( 32'd0) :
    32'd0;
assign read_virtual =
    (cond_7 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_11 && ~cond_9)? (`TRUE) :
    (cond_22 && ~cond_16)? (`TRUE) :
    (cond_37 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_43 && ~cond_9)? (`TRUE) :
    (cond_48 && ~cond_49 && cond_50)? (`TRUE) :
    (cond_51 && cond_52)? (`TRUE) :
    (cond_53)? (`TRUE) :
    (cond_55 && cond_56 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_75 && ~cond_9)? (`TRUE) :
    (cond_76 && cond_3 && ~cond_78)? (        rd_cmd[1:0] == 2'd0) :
    (cond_79 && ~cond_84 && cond_85)? (`TRUE) :
    (cond_91)? (`TRUE) :
    (cond_95)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_98)? (`TRUE) :
    (cond_103 && ~cond_104)? (`TRUE) :
    (cond_105 && ~cond_104)? (`TRUE) :
    (cond_107 && cond_3 && ~cond_109)? (`TRUE) :
    (cond_114 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_115 && cond_39)? (`TRUE) :
    (cond_117 && cond_118 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_121 && cond_118 && ~cond_9)? (`TRUE) :
    (cond_132)? (`TRUE) :
    (cond_133 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_135 && cond_3 && ~cond_137)? (`TRUE) :
    (cond_138 && ~cond_9)? (`TRUE) :
    (cond_143 && cond_3 && ~cond_46 && ~cond_145)? (`TRUE) :
    (cond_147 && cond_3 && ~cond_9 && ~cond_148)? (`TRUE) :
    (cond_150 && cond_3 && ~cond_152)? (`TRUE) :
    (cond_154 && cond_3 && ~cond_46)? (`TRUE) :
    (cond_155 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_157)? (`TRUE) :
    (cond_158 && ~cond_9)? (`TRUE) :
    (cond_160 && ~cond_9)? (`TRUE) :
    (cond_161)? (`TRUE) :
    (cond_162 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_169 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_178 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_198 && ~cond_38 && cond_199)? (`TRUE) :
    (cond_205 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_206 && ~cond_9)? (`TRUE) :
    (cond_213 && cond_214 && ~cond_9)? (`TRUE) :
    (cond_216 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_222 && ~cond_9)? (`TRUE) :
    (cond_224 && ~cond_9)? (`TRUE) :
    (cond_225 && ~cond_9)? (`TRUE) :
    (cond_249 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_250 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_251 && ~cond_104)? (`TRUE) :
    (cond_256 && ~cond_9)? (`TRUE) :
    (cond_258 && cond_3 && ~cond_9)? (`TRUE) :
    1'd0;
assign rd_glob_param_4_value =
    (cond_98 && cond_99)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_161)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_189)? ( (rd_ss_esp_from_tss_386)? read_4 : { 16'd0, read_4[15:0] }) :
    32'd0;
assign address_stack_pop_for_call =
    (cond_22)? (`TRUE) :
    1'd0;
assign rd_glob_param_5_value =
    (cond_22 && ~cond_16)? ( read_4) :
    (cond_98 && cond_100)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_190 && ~cond_16 && cond_90)? ( 32'd0) :
    (cond_190 && ~cond_16 && ~cond_90)? ( { 31'd0, rd_descriptor_not_in_limits }) :
    32'd0;
assign write_virtual_check =
    (cond_28 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_106 && cond_3)? (`TRUE) :
    (cond_116 && cond_3)? (`TRUE) :
    (cond_126 && cond_3)? (`TRUE) :
    (cond_213 && ~cond_214)? (`TRUE) :
    (cond_217 && cond_3 && ~cond_218)? (`TRUE) :
    (cond_219 && cond_3 && ~cond_218)? (`TRUE) :
    (cond_246)? (`TRUE) :
    1'd0;
assign rd_req_esi =
    (cond_114 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_115 && cond_39)? (`TRUE) :
    (cond_162 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_198 && ~cond_38 && cond_199 && ~cond_5)? (`TRUE) :
    (cond_249 && ~cond_38 && cond_39)? (`TRUE) :
    1'd0;
assign rd_dst_is_implicit_reg =
    (cond_41)? (`TRUE) :
    (cond_47)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_220)? (`TRUE) :
    1'd0;
assign rd_req_eflags =
    (cond_6)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_37 && ~cond_38 && cond_39 && ~cond_5)? (`TRUE) :
    (cond_40)? (`TRUE) :
    (cond_41)? (`TRUE) :
    (cond_44 && cond_1)? (`TRUE) :
    (cond_60)? (`TRUE) :
    (cond_67)? (`TRUE) :
    (cond_76)? (`TRUE) :
    (cond_110)? (`TRUE) :
    (cond_111)? (`TRUE) :
    (cond_114 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_115 && cond_39)? (`TRUE) :
    (cond_127)? (`TRUE) :
    (cond_133)? (`TRUE) :
    (cond_135)? (`TRUE) :
    (cond_139)? (`TRUE) :
    (cond_140)? (`TRUE) :
    (cond_143)? (`TRUE) :
    (cond_147)? (`TRUE) :
    (cond_149)? (`TRUE) :
    (cond_150)? (`TRUE) :
    (cond_154)? (`TRUE) :
    (cond_155)? (`TRUE) :
    (cond_156)? (`TRUE) :
    (cond_181)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_222)? (`TRUE) :
    (cond_223)? (`TRUE) :
    (cond_257)? (`TRUE) :
    (cond_258)? (`TRUE) :
    1'd0;
assign rd_extra_wire =
    (cond_14)? ( rd_decoder[55:24]) :
    (cond_181 && cond_182)? ( { 8'd0, glob_descriptor[55:40], 8'd0 }) :
    (cond_181 && ~cond_182)? ( glob_desc_limit) :
    (cond_202)? ( rd_decoder[55:24]) :
    32'd0;
assign address_memoffset =
    (cond_213)? (`TRUE) :
    1'd0;
assign rd_src_is_reg =
    (cond_0)? (`TRUE) :
    (cond_44 && cond_1)? (`TRUE) :
    (cond_76)? (           rd_cmdex == `CMDEX_BTx_modregrm) :
    (cond_127)? (`TRUE) :
    (cond_139)? (`TRUE) :
    (cond_140)? (`TRUE) :
    (cond_143)? (  rd_arith_modregrm_to_rm) :
    (cond_154)? (`TRUE) :
    (cond_165)? (`TRUE) :
    (cond_217)? (`TRUE) :
    1'd0;
assign io_read_address =
    (cond_173)? ( (rd_cmdex == `CMDEX_IN_imm)? { 8'd0, rd_decoder[15:8] } : (rd_cmdex == `CMDEX_IN_protected)? glob_param_1[15:0] : edx[15:0]) :
    (cond_196)? ( edx[15:0]) :
    16'd0;
assign rd_req_memory =
    (cond_6)? (  rd_modregrm_mod != 2'b11) :
    (cond_27)? (`TRUE) :
    (cond_28 && cond_3)? (`TRUE) :
    (cond_30 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_40 && cond_3)? (`TRUE) :
    (cond_44 && cond_3)? (`TRUE) :
    (cond_76 && cond_3)? ( rd_cmd[1:0] != 2'd0) :
    (cond_106 && cond_3)? (`TRUE) :
    (cond_110 && cond_3)? (`TRUE) :
    (cond_111 && cond_3)? (`TRUE) :
    (cond_116 && cond_3)? (`TRUE) :
    (cond_124)? (`TRUE) :
    (cond_126 && cond_3)? (`TRUE) :
    (cond_127 && cond_3 && ~cond_4)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_131)? (`TRUE) :
    (cond_132)? (`TRUE) :
    (cond_139 && cond_3)? (`TRUE) :
    (cond_140 && cond_3)? (`TRUE) :
    (cond_143 && cond_3 && cond_145)? (`TRUE) :
    (cond_147 && cond_3 && cond_148)? (`TRUE) :
    (cond_166 && cond_3)? (`TRUE) :
    (cond_167)? (`TRUE) :
    (cond_168)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_177 && cond_3)? (`TRUE) :
    (cond_191 && ~cond_192 && cond_39)? (`TRUE) :
    (cond_196 && ~cond_197 && cond_195)? (`TRUE) :
    (cond_200)? (`TRUE) :
    (cond_213 && ~cond_214)? (`TRUE) :
    (cond_217 && cond_3)? (`TRUE) :
    (cond_219 && cond_3)? (`TRUE) :
    (cond_227 && ~cond_16 && cond_228)? (`TRUE) :
    (cond_231)? (`TRUE) :
    (cond_246)? (`TRUE) :
    (cond_249 && ~cond_38 && cond_39)? (`TRUE) :
    1'd0;
assign rd_glob_param_3_set =
    (cond_15 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_22 && cond_25)? (`TRUE) :
    (cond_79 && cond_83)? (`TRUE) :
    (cond_89)? (`TRUE) :
    (cond_91 && cond_92)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_157)? (`TRUE) :
    (cond_187 && ~cond_188)? (`TRUE) :
    (cond_209 && ~cond_16 && cond_17)? (`TRUE) :
    1'd0;
assign rd_glob_descriptor_value =
    (cond_15 && ~cond_16 && cond_17)? ( read_8) :
    (cond_19 && cond_20)? ( read_8) :
    (cond_21 && ~cond_16 && cond_17)? ( read_8) :
    (cond_62 && cond_20)? ( read_8) :
    (cond_63 && ~cond_16 && cond_17)? ( read_8) :
    (cond_66)? ( read_8) :
    (cond_69 && cond_70)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0, glob_param_1[15:12], glob_param_1[11:0], 4'd0, 16'hFFFF }) :
    (cond_69 && cond_71)? ( `DESC_MASK_P | `DESC_MASK_SEG | { 24'd0, 4'd0, glob_param_1[15:12], glob_param_1[11:0], 4'd0, 16'd0 }) :
    (cond_69 && cond_72)? ( `DESC_MASK_SEG | { 24'd0, 24'd0, 16'd0 }) :
    (cond_73 && cond_74)? ( read_8) :
    (cond_89 && ~cond_16 && cond_90)? ( read_8) :
    (cond_179 && cond_180 && ~cond_9)? ( read_8) :
    (cond_190 && ~cond_16 && cond_90)? ( read_8) :
    (cond_204 && cond_17)? ( read_8) :
    (cond_209 && ~cond_16 && cond_17)? ( read_8) :
    (cond_211 && cond_20)? ( read_8) :
    (cond_241 && ~cond_16 && cond_242)? ( read_8) :
    (cond_243 && ~cond_16 && cond_70)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,glob_param_1[15:12], glob_param_1[11:0],4'd0, 16'hFFFF }) :
    (cond_243 && ~cond_16 && ~cond_70 && cond_244)? ( read_8) :
    64'd0;
assign address_stack_add_4_to_saved =
    (cond_95)? (`TRUE) :
    1'd0;
assign rd_dst_is_eip =
    (cond_10)? (`TRUE) :
    (cond_201)? (`TRUE) :
    1'd0;
assign rd_src_is_memory =
    (cond_7 && cond_3)? (`TRUE) :
    (cond_11)? (`TRUE) :
    (cond_30 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_35 && ~cond_36)? (`TRUE) :
    (cond_37 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_95)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_105)? (`TRUE) :
    (cond_107 && cond_3 && ~cond_109)? (`TRUE) :
    (cond_114 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_115 && cond_39)? (`TRUE) :
    (cond_117 && cond_118 && cond_3)? (`TRUE) :
    (cond_121 && cond_118)? (`TRUE) :
    (cond_132)? (`TRUE) :
    (cond_133 && cond_3)? (`TRUE) :
    (cond_135 && cond_3 && ~cond_137)? (`TRUE) :
    (cond_138 && ~cond_9)? (`TRUE) :
    (cond_143 && cond_3)? (   rd_arith_modregrm_to_reg) :
    (cond_150 && cond_3)? (`TRUE) :
    (cond_162 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_169 && cond_3)? (`TRUE) :
    (cond_198 && ~cond_38 && cond_199)? (`TRUE) :
    (cond_205 && cond_3)? (`TRUE) :
    (cond_206)? (`TRUE) :
    (cond_213 && cond_214)? (`TRUE) :
    (cond_216 && cond_3)? (`TRUE) :
    (cond_222)? (`TRUE) :
    (cond_224)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_232 && cond_236 && ~cond_9)? (`TRUE) :
    (cond_237 && cond_238)? (`TRUE) :
    (cond_239 && ~cond_16 && cond_240)? (`TRUE) :
    (cond_249 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_250 && cond_3)? (`TRUE) :
    (cond_251 && ~cond_104)? (`TRUE) :
    (cond_256)? (`TRUE) :
    (cond_258 && cond_3)? (`TRUE) :
    1'd0;
assign read_system_qword =
    (cond_66 && ~cond_16)? (`TRUE) :
    1'd0;
assign rd_dst_is_modregrm_imm =
    (cond_133 && ~cond_134)? (`TRUE) :
    1'd0;
assign address_stack_pop =
    (cond_43)? (`TRUE) :
    (cond_75)? (`TRUE) :
    (cond_79)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_105)? (`TRUE) :
    (cond_158)? (       real_mode || v8086_mode) :
    (cond_160)? (          real_mode || v8086_mode) :
    (cond_222)? (`TRUE) :
    (cond_251)? (`TRUE) :
    1'd0;
assign rd_req_reg_not_8bit =
    (cond_250)? (`TRUE) :
    1'd0;
assign rd_dst_is_rm =
    (cond_0 && cond_1)? (`TRUE) :
    (cond_28 && cond_1)? (`TRUE) :
    (cond_30 && cond_1)? (`TRUE) :
    (cond_40 && cond_1 && ~cond_8)? (`TRUE) :
    (cond_44 && cond_1)? (`TRUE) :
    (cond_55 && cond_56 && cond_1)? (`TRUE) :
    (cond_76 && cond_1)? (`TRUE) :
    (cond_106 && cond_1)? (`TRUE) :
    (cond_110 && cond_1)? (`TRUE) :
    (cond_111 && cond_1)? (`TRUE) :
    (cond_116 && cond_1)? (`TRUE) :
    (cond_120)? (`TRUE) :
    (cond_126 && cond_1)? (`TRUE) :
    (cond_127 && cond_1 && ~cond_2)? (`TRUE) :
    (cond_139 && cond_1)? (`TRUE) :
    (cond_140 && cond_1)? (`TRUE) :
    (cond_143 && cond_1)? (   rd_arith_modregrm_to_rm) :
    (cond_147 && cond_1)? (`TRUE) :
    (cond_154 && cond_1)? (`TRUE) :
    (cond_155 && cond_1)? (`TRUE) :
    (cond_165 && cond_1)? (`TRUE) :
    (cond_177 && cond_1)? (`TRUE) :
    (cond_178 && cond_1 && ~cond_8)? (`TRUE) :
    (cond_217 && cond_1)? (`TRUE) :
    (cond_219 && cond_1)? (`TRUE) :
    (cond_254)? (`TRUE) :
    1'd0;
assign rd_req_edx =
    (cond_172)? (`TRUE) :
    (cond_221)? ( rd_cmd == `CMD_CWD) :
    1'd0;
assign rd_src_is_io =
    (cond_173 && ~cond_174 && cond_175)? (`TRUE) :
    (cond_196 && ~cond_197 && cond_195)? (`TRUE) :
    1'd0;
assign rd_src_is_eax =
    (cond_163)? (`TRUE) :
    (cond_191 && ~cond_192 && cond_39)? (`TRUE) :
    (cond_212)? (`TRUE) :
    (cond_213 && ~cond_214)? (`TRUE) :
    1'd0;
assign address_stack_for_ret_second =
    (cond_157)? (`TRUE) :
    1'd0;
assign rd_glob_param_1_set =
    (cond_18 && ~cond_16)? (`TRUE) :
    (cond_51 && cond_52)? (`TRUE) :
    (cond_53 && cond_50)? (`TRUE) :
    (cond_55 && cond_56 && cond_1 && cond_57)? (`TRUE) :
    (cond_55 && cond_56 && cond_1 && cond_58)? (`TRUE) :
    (cond_55 && cond_56 && cond_1 && cond_59)? (`TRUE) :
    (cond_55 && cond_56 && cond_3 && ~cond_9 && cond_57)? (`TRUE) :
    (cond_55 && cond_56 && cond_3 && ~cond_9 && cond_58)? (`TRUE) :
    (cond_55 && cond_56 && cond_3 && ~cond_9 && cond_59)? (`TRUE) :
    (cond_61 && ~cond_16)? (`TRUE) :
    (cond_65)? (`TRUE) :
    (cond_75)? (`TRUE) :
    (cond_79 && cond_82)? (`TRUE) :
    (cond_88)? (`TRUE) :
    (cond_91 && cond_93)? (`TRUE) :
    (cond_97)? ( rd_ready) :
    (cond_157)? ( rd_ready) :
    (cond_158 && ~cond_9 && cond_72)? (`TRUE) :
    (cond_160 && ~cond_9 && cond_159)? (`TRUE) :
    (cond_178 && cond_1 && ~cond_8)? (`TRUE) :
    (cond_178 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_203 && ~cond_16)? (`TRUE) :
    (cond_210 && ~cond_16)? (`TRUE) :
    1'd0;
assign rd_glob_param_4_set =
    (cond_98 && cond_99)? (`TRUE) :
    (cond_161)? (`TRUE) :
    (cond_189)? (`TRUE) :
    1'd0;
assign address_stack_pop_next =
    (cond_22)? (`TRUE) :
    (cond_91)? (`TRUE) :
    (cond_95)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_98)? (`TRUE) :
    (cond_157)? (`TRUE) :
    (cond_158)? (  protected_mode) :
    (cond_160)? (     protected_mode) :
    (cond_161)? (`TRUE) :
    1'd0;
assign rd_req_edi =
    (cond_37 && ~cond_38 && cond_39 && ~cond_5)? (`TRUE) :
    (cond_114 && ~cond_38 && cond_39)? (`TRUE) :
    (cond_115 && cond_39)? (`TRUE) :
    (cond_191 && ~cond_192 && cond_39)? (`TRUE) :
    (cond_196 && ~cond_197 && cond_195)? (`TRUE) :
    (cond_249 && ~cond_38 && cond_39)? (`TRUE) :
    1'd0;
assign rd_glob_descriptor_set =
    (cond_15 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_19 && cond_20)? (`TRUE) :
    (cond_21 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_62 && cond_20)? (`TRUE) :
    (cond_63 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_66)? (`TRUE) :
    (cond_69 && cond_70)? (`TRUE) :
    (cond_69 && cond_71)? (`TRUE) :
    (cond_69 && cond_72)? (`TRUE) :
    (cond_73 && cond_74)? (`TRUE) :
    (cond_89 && ~cond_16 && cond_90)? (`TRUE) :
    (cond_179 && cond_180 && ~cond_9)? (`TRUE) :
    (cond_190 && ~cond_16 && cond_90)? (`TRUE) :
    (cond_204 && cond_17)? (`TRUE) :
    (cond_209 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_211 && cond_20)? (`TRUE) :
    (cond_241 && ~cond_16 && cond_242)? (`TRUE) :
    (cond_243 && ~cond_16 && cond_70)? (`TRUE) :
    (cond_243 && ~cond_16 && ~cond_70 && cond_244)? (`TRUE) :
    1'd0;
assign read_system_word =
    (cond_33 && ~cond_34)? (`TRUE) :
    (cond_35 && ~cond_36)? (`TRUE) :
    (cond_64 && ~cond_16)? (`TRUE) :
    (cond_65 && ~cond_16)? (`TRUE) :
    (cond_88)? (`TRUE) :
    (cond_187 && ~cond_188)? (`TRUE) :
    (cond_189)? (  ~(rd_ss_esp_from_tss_386)) :
    (cond_232 && cond_236 && ~cond_9)? (  glob_descriptor[`DESC_BITS_TYPE] <= 4'd3) :
    (cond_237 && cond_238)? (  glob_descriptor[`DESC_BITS_TYPE] <= 4'd3 || rd_cmdex > `CMDEX_task_switch_3_STEP_7) :
    1'd0;
assign address_enter_last =
    (cond_130)? (`TRUE) :
    1'd0;
assign rd_dst_is_memory_last =
    (cond_115 && cond_39)? (`TRUE) :
    1'd0;
assign read_system_descriptor =
    (cond_15 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_19 && cond_20)? (`TRUE) :
    (cond_21 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_62 && cond_20)? (`TRUE) :
    (cond_63 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_73 && cond_74 && ~cond_16)? (`TRUE) :
    (cond_89 && ~cond_16 && cond_90)? (`TRUE) :
    (cond_179 && cond_180 && ~cond_9)? (`TRUE) :
    (cond_190 && ~cond_16 && cond_90)? (`TRUE) :
    (cond_204 && cond_17)? (`TRUE) :
    (cond_209 && ~cond_16 && cond_17)? (`TRUE) :
    (cond_211 && cond_20)? (`TRUE) :
    (cond_241 && ~cond_16 && cond_242)? (`TRUE) :
    (cond_243 && ~cond_16 && ~cond_70 && cond_244)? (`TRUE) :
    1'd0;
assign address_edi =
    (cond_37)? (`TRUE) :
    (cond_115)? (`TRUE) :
    (cond_193)? (`TRUE) :
    1'd0;
assign rd_waiting =
    (cond_0 && cond_1 && cond_2)? (`TRUE) :
    (cond_0 && cond_3 && cond_4)? (`TRUE) :
    (cond_0 && cond_3 && ~cond_4 && cond_5)? (`TRUE) :
    (cond_7 && cond_1 && cond_8)? (`TRUE) :
    (cond_7 && cond_3 && cond_9)? (`TRUE) :
    (cond_7 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_11 && cond_9)? (`TRUE) :
    (cond_11 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_15 && cond_16)? (`TRUE) :
    (cond_15 && ~cond_16 && cond_17 && cond_5)? (`TRUE) :
    (cond_18 && cond_16)? (`TRUE) :
    (cond_19 && cond_20 && cond_5)? (`TRUE) :
    (cond_21 && cond_16)? (`TRUE) :
    (cond_21 && ~cond_16 && cond_17 && cond_5)? (`TRUE) :
    (cond_22 && cond_16)? (`TRUE) :
    (cond_22 && ~cond_16 && cond_5)? (`TRUE) :
    (cond_28 && cond_3 && cond_9)? (`TRUE) :
    (cond_28 && cond_3 && ~cond_9 && cond_29)? (`TRUE) :
    (cond_30 && cond_1 && cond_8)? (`TRUE) :
    (cond_30 && cond_3 && cond_9)? (`TRUE) :
    (cond_30 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_31 && cond_32)? (`TRUE) :
    (cond_33 && cond_34)? (`TRUE) :
    (cond_33 && ~cond_34 && cond_5)? (`TRUE) :
    (cond_35 && cond_36)? (`TRUE) :
    (cond_35 && ~cond_36 && cond_5)? (`TRUE) :
    (cond_37 && cond_38)? (`TRUE) :
    (cond_37 && ~cond_38 && cond_39 && cond_5)? (`TRUE) :
    (cond_40 && cond_1 && cond_8)? (`TRUE) :
    (cond_40 && cond_3 && cond_9)? (`TRUE) :
    (cond_40 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_41 && cond_42)? (`TRUE) :
    (cond_43 && cond_9)? (`TRUE) :
    (cond_43 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_44 && cond_1 && cond_45)? (`TRUE) :
    (cond_44 && cond_3 && cond_46)? (`TRUE) :
    (cond_44 && cond_3 && ~cond_46 && cond_5)? (`TRUE) :
    (cond_47 && cond_42)? (`TRUE) :
    (cond_48 && cond_49)? (`TRUE) :
    (cond_48 && ~cond_49 && cond_50 && cond_5)? (`TRUE) :
    (cond_51 && cond_52 && cond_5)? (`TRUE) :
    (cond_53 && cond_5)? (`TRUE) :
    (cond_55 && cond_56 && cond_1 && cond_8)? (`TRUE) :
    (cond_55 && cond_56 && cond_3 && cond_9)? (`TRUE) :
    (cond_55 && cond_56 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_61 && cond_16)? (`TRUE) :
    (cond_62 && cond_20 && cond_5)? (`TRUE) :
    (cond_63 && cond_16)? (`TRUE) :
    (cond_63 && ~cond_16 && cond_17 && cond_5)? (`TRUE) :
    (cond_64 && cond_16)? (`TRUE) :
    (cond_64 && ~cond_16 && cond_5)? (`TRUE) :
    (cond_65 && cond_16)? (`TRUE) :
    (cond_65 && ~cond_16 && cond_5)? (`TRUE) :
    (cond_66 && cond_16)? (`TRUE) :
    (cond_66 && ~cond_16 && cond_5)? (`TRUE) :
    (cond_67 && cond_68)? (`TRUE) :
    (cond_73 && cond_74 && cond_16)? (`TRUE) :
    (cond_73 && cond_74 && ~cond_16 && cond_5)? (`TRUE) :
    (cond_75 && cond_9)? (`TRUE) :
    (cond_75 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_76 && cond_1 && cond_77)? (`TRUE) :
    (cond_76 && cond_3 && cond_78)? (`TRUE) :
    (cond_76 && cond_3 && ~cond_78 && cond_5)? (`TRUE) :
    (cond_79 && cond_84)? (`TRUE) :
    (cond_79 && ~cond_84 && cond_85 && cond_5)? (`TRUE) :
    (cond_86 && cond_87)? (`TRUE) :
    (cond_88 && cond_5)? (`TRUE) :
    (cond_89 && cond_16)? (`TRUE) :
    (cond_89 && ~cond_16 && cond_90 && cond_5)? (`TRUE) :
    (cond_91 && cond_5)? (`TRUE) :
    (cond_95 && cond_5)? (`TRUE) :
    (cond_97 && cond_5)? (`TRUE) :
    (cond_98 && cond_5)? (`TRUE) :
    (cond_102 && cond_16)? (`TRUE) :
    (cond_103 && cond_104)? (`TRUE) :
    (cond_103 && ~cond_104 && cond_5)? (`TRUE) :
    (cond_105 && cond_104)? (`TRUE) :
    (cond_105 && ~cond_104 && cond_5)? (`TRUE) :
    (cond_106 && cond_3 && cond_29)? (`TRUE) :
    (cond_107 && cond_1 && cond_108)? (`TRUE) :
    (cond_107 && cond_3 && cond_109)? (`TRUE) :
    (cond_107 && cond_3 && ~cond_109 && cond_5)? (`TRUE) :
    (cond_110 && cond_1 && cond_8)? (`TRUE) :
    (cond_110 && cond_3 && cond_9)? (`TRUE) :
    (cond_110 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_111 && cond_1 && cond_112)? (`TRUE) :
    (cond_111 && cond_3 && cond_113)? (`TRUE) :
    (cond_111 && cond_3 && ~cond_113 && cond_5)? (`TRUE) :
    (cond_114 && cond_38)? (`TRUE) :
    (cond_114 && ~cond_38 && cond_39 && cond_5)? (`TRUE) :
    (cond_115 && cond_39 && cond_5)? (`TRUE) :
    (cond_116 && cond_3 && cond_29)? (`TRUE) :
    (cond_117 && cond_118 && cond_1 && cond_8)? (`TRUE) :
    (cond_117 && cond_118 && cond_3 && cond_9)? (`TRUE) :
    (cond_117 && cond_118 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_119 && cond_8)? (`TRUE) :
    (cond_121 && cond_118 && cond_9)? (`TRUE) :
    (cond_121 && cond_118 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_124 && cond_125)? (`TRUE) :
    (cond_126 && cond_3 && cond_29)? (`TRUE) :
    (cond_127 && cond_1 && cond_2)? (`TRUE) :
    (cond_127 && cond_3 && cond_4)? (`TRUE) :
    (cond_127 && cond_3 && ~cond_4 && cond_5)? (`TRUE) :
    (cond_128 && cond_129)? (`TRUE) :
    (cond_130 && cond_5)? (`TRUE) :
    (cond_132 && cond_5)? (`TRUE) :
    (cond_133 && cond_1 && cond_8)? (`TRUE) :
    (cond_133 && cond_3 && cond_9)? (`TRUE) :
    (cond_133 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_135 && cond_1 && cond_136)? (`TRUE) :
    (cond_135 && cond_3 && cond_137)? (`TRUE) :
    (cond_135 && cond_3 && ~cond_137 && cond_5)? (`TRUE) :
    (cond_138 && cond_9)? (`TRUE) :
    (cond_138 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_139 && cond_1 && cond_45)? (`TRUE) :
    (cond_139 && cond_3 && cond_46)? (`TRUE) :
    (cond_139 && cond_3 && ~cond_46 && cond_5)? (`TRUE) :
    (cond_140 && cond_1 && cond_141)? (`TRUE) :
    (cond_140 && cond_3 && cond_142)? (`TRUE) :
    (cond_140 && cond_3 && ~cond_142 && cond_5)? (`TRUE) :
    (cond_143 && cond_1 && cond_2)? (`TRUE) :
    (cond_143 && cond_3 && cond_46)? (`TRUE) :
    (cond_143 && cond_3 && ~cond_46 && cond_5)? (`TRUE) :
    (cond_147 && cond_1 && cond_8)? (`TRUE) :
    (cond_147 && cond_3 && cond_9)? (`TRUE) :
    (cond_147 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_149 && cond_68)? (`TRUE) :
    (cond_150 && cond_1 && cond_151)? (`TRUE) :
    (cond_150 && cond_3 && cond_152)? (`TRUE) :
    (cond_150 && cond_3 && ~cond_152 && cond_5)? (`TRUE) :
    (cond_154 && cond_1 && cond_2)? (`TRUE) :
    (cond_154 && cond_3 && cond_46)? (`TRUE) :
    (cond_154 && cond_3 && ~cond_46 && cond_5)? (`TRUE) :
    (cond_155 && cond_1 && cond_8)? (`TRUE) :
    (cond_155 && cond_3 && cond_9)? (`TRUE) :
    (cond_155 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_156 && cond_68)? (`TRUE) :
    (cond_157 && cond_5)? (`TRUE) :
    (cond_158 && cond_9)? (`TRUE) :
    (cond_158 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_160 && cond_9)? (`TRUE) :
    (cond_160 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_161 && cond_5)? (`TRUE) :
    (cond_162 && cond_38)? (`TRUE) :
    (cond_162 && ~cond_38 && cond_39 && cond_5)? (`TRUE) :
    (cond_163 && cond_164)? (`TRUE) :
    (cond_165 && cond_1 && cond_2)? (`TRUE) :
    (cond_165 && cond_3 && cond_4)? (`TRUE) :
    (cond_165 && cond_3 && ~cond_4 && cond_5)? (`TRUE) :
    (cond_168 && cond_42)? (`TRUE) :
    (cond_169 && cond_1 && cond_8)? (`TRUE) :
    (cond_169 && cond_3 && cond_9)? (`TRUE) :
    (cond_169 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_170 && cond_171)? (`TRUE) :
    (cond_172 && cond_68)? (`TRUE) :
    (cond_173 && cond_174)? (`TRUE) :
    (cond_173 && ~cond_174 && cond_175 && cond_176)? (`TRUE) :
    (cond_177 && cond_1 && cond_8)? (`TRUE) :
    (cond_177 && cond_3 && cond_9)? (`TRUE) :
    (cond_177 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_178 && cond_1 && cond_8)? (`TRUE) :
    (cond_178 && cond_3 && cond_9)? (`TRUE) :
    (cond_178 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_179 && cond_180 && cond_9)? (`TRUE) :
    (cond_179 && cond_180 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_181 && cond_183)? (`TRUE) :
    (cond_185 && cond_183)? (`TRUE) :
    (cond_187 && cond_188)? (`TRUE) :
    (cond_187 && ~cond_188 && cond_5)? (`TRUE) :
    (cond_189 && cond_5)? (`TRUE) :
    (cond_190 && cond_16)? (`TRUE) :
    (cond_190 && ~cond_16 && cond_90 && cond_5)? (`TRUE) :
    (cond_191 && cond_192)? (`TRUE) :
    (cond_193 && cond_194)? (`TRUE) :
    (cond_193 && ~cond_194 && cond_195 && cond_5)? (`TRUE) :
    (cond_196 && cond_197)? (`TRUE) :
    (cond_196 && ~cond_197 && cond_195 && cond_176)? (`TRUE) :
    (cond_198 && cond_38)? (`TRUE) :
    (cond_198 && ~cond_38 && cond_199 && cond_5)? (`TRUE) :
    (cond_203 && cond_16)? (`TRUE) :
    (cond_204 && cond_17 && cond_5)? (`TRUE) :
    (cond_205 && cond_1 && cond_8)? (`TRUE) :
    (cond_205 && cond_3 && cond_9)? (`TRUE) :
    (cond_205 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_206 && cond_9)? (`TRUE) :
    (cond_206 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_209 && cond_16)? (`TRUE) :
    (cond_209 && ~cond_16 && cond_17 && cond_5)? (`TRUE) :
    (cond_210 && cond_16)? (`TRUE) :
    (cond_211 && cond_20 && cond_5)? (`TRUE) :
    (cond_212 && cond_68)? (`TRUE) :
    (cond_213 && cond_214 && cond_9)? (`TRUE) :
    (cond_213 && cond_214 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_213 && ~cond_214 && cond_215)? (`TRUE) :
    (cond_216 && cond_1 && cond_8)? (`TRUE) :
    (cond_216 && cond_3 && cond_9)? (`TRUE) :
    (cond_216 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_217 && cond_1 && cond_218)? (`TRUE) :
    (cond_217 && cond_3 && cond_218)? (`TRUE) :
    (cond_217 && cond_3 && ~cond_218 && cond_29)? (`TRUE) :
    (cond_219 && cond_1 && cond_218)? (`TRUE) :
    (cond_219 && cond_3 && cond_218)? (`TRUE) :
    (cond_219 && cond_3 && ~cond_218 && cond_29)? (`TRUE) :
    (cond_222 && cond_9)? (`TRUE) :
    (cond_222 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_224 && cond_9)? (`TRUE) :
    (cond_224 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_225 && cond_9)? (`TRUE) :
    (cond_225 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_227 && cond_16)? (`TRUE) :
    (cond_227 && ~cond_16 && cond_228 && cond_9)? (`TRUE) :
    (cond_227 && ~cond_16 && cond_228 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_229 && cond_9)? (`TRUE) :
    (cond_232 && cond_236 && cond_9)? (`TRUE) :
    (cond_232 && cond_236 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_237 && cond_238 && cond_5)? (`TRUE) :
    (cond_239 && cond_16)? (`TRUE) :
    (cond_239 && ~cond_16 && cond_240 && cond_5)? (`TRUE) :
    (cond_241 && cond_16)? (`TRUE) :
    (cond_241 && ~cond_16 && cond_242 && cond_5)? (`TRUE) :
    (cond_243 && cond_16)? (`TRUE) :
    (cond_243 && ~cond_16 && ~cond_70 && cond_244 && cond_5)? (`TRUE) :
    (cond_245 && cond_32)? (`TRUE) :
    (cond_246 && cond_29)? (`TRUE) :
    (cond_249 && cond_38)? (`TRUE) :
    (cond_249 && ~cond_38 && cond_39 && cond_5)? (`TRUE) :
    (cond_250 && cond_1 && cond_8)? (`TRUE) :
    (cond_250 && cond_3 && cond_9)? (`TRUE) :
    (cond_250 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_251 && cond_104)? (`TRUE) :
    (cond_251 && ~cond_104 && cond_5)? (`TRUE) :
    (cond_254 && cond_16)? (`TRUE) :
    (cond_255 && cond_16)? (`TRUE) :
    (cond_256 && cond_9)? (`TRUE) :
    (cond_256 && ~cond_9 && cond_5)? (`TRUE) :
    (cond_257 && cond_68)? (`TRUE) :
    (cond_258 && cond_1 && cond_8)? (`TRUE) :
    (cond_258 && cond_3 && cond_9)? (`TRUE) :
    (cond_258 && cond_3 && ~cond_9 && cond_5)? (`TRUE) :
    1'd0;
assign address_ea_buffer =
    (cond_11 && cond_12)? (`TRUE) :
    (cond_51)? (`TRUE) :
    (cond_53 && cond_50)? (`TRUE) :
    (cond_121 && cond_123)? (`TRUE) :
    (cond_206 && cond_207)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_246 && cond_248)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_to_v86 =
    (cond_95 && cond_96)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_second =
    (cond_97)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_first =
    (cond_91 && cond_92)? (`TRUE) :
    1'd0;
assign rd_req_ecx =
    (cond_153)? (`TRUE) :
    (cond_172)? (`TRUE) :
    1'd0;
assign read_rmw_system_dword =
    (cond_227 && ~cond_16 && cond_228 && ~cond_9)? (`TRUE) :
    (cond_239 && ~cond_16 && cond_240)? (`TRUE) :
    1'd0;
assign rd_src_is_imm_se =
    (cond_201)? (`TRUE) :
    1'd0;
assign rd_glob_param_2_value =
    (cond_43)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_48 && ~cond_49 && cond_50)? ( read_4) :
    (cond_53 && ~cond_50)? ( read_4) :
    (cond_64)? ( { 16'd0, read_4[15:0] }) :
    (cond_79 && cond_81)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_89 && ~cond_16 && cond_90)? ( 32'd0) :
    (cond_89 && ~cond_16 && ~cond_90)? ( { 30'd0, rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    (cond_91 && cond_94)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_98 && cond_101)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_158 && ~cond_9 && cond_159)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_160 && ~cond_9 && cond_72)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_179 && cond_180 && ~cond_9)? ( 32'd0) :
    (cond_179 && ~cond_180)? ( { 30'd0, rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    (cond_203 && ~cond_16)? ( (glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_386)? { glob_descriptor[63:48], glob_descriptor[15:0] } : { 16'd0, glob_descriptor[15:0] }) :
    (cond_227 && ~cond_16 && cond_228)? ( read_4) :
    (cond_241 && ~cond_16 && cond_242)? ( 32'd0) :
    (cond_241 && ~cond_16 && ~cond_242)? ( { 29'd0, glob_param_1[`SELECTOR_BIT_TI], rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    (cond_243 && ~cond_16 && cond_70)? ( 32'd0) :
    (cond_243 && ~cond_16 && ~cond_70 && cond_244)? ( 32'd0) :
    (cond_243 && ~cond_16 && ~cond_70 && ~cond_244)? ( { 30'd0, rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    32'd0;
assign address_stack_pop_esp_prev =
    (cond_157)? (`TRUE) :
    1'd0;
assign read_length_word =
    (cond_11 && cond_12)? (`TRUE) :
    (cond_22 && cond_23)? (`TRUE) :
    (cond_44 && cond_3)? (`TRUE) :
    (cond_51 && cond_52)? (`TRUE) :
    (cond_55 && cond_56 && cond_3)? (`TRUE) :
    (cond_75)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_117 && cond_118 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_121 && cond_122)? (`TRUE) :
    (cond_157)? (`TRUE) :
    (cond_178 && cond_3)? (`TRUE) :
    (cond_179 && cond_180)? (`TRUE) :
    (cond_206 && cond_207)? (`TRUE) :
    (cond_246 && cond_247)? (`TRUE) :
    (cond_250 && cond_3)? (`TRUE) :
    1'd0;
assign address_xlat_transform =
    (cond_256)? (`TRUE) :
    1'd0;
assign address_enter =
    (cond_132)? (`TRUE) :
    1'd0;
assign rd_src_is_rm =
    (cond_7 && cond_1)? (`TRUE) :
    (cond_30 && cond_1)? (`TRUE) :
    (cond_107 && cond_1)? (`TRUE) :
    (cond_117 && cond_118 && cond_1)? (`TRUE) :
    (cond_119)? (`TRUE) :
    (cond_133 && cond_1)? (`TRUE) :
    (cond_135 && cond_1)? (`TRUE) :
    (cond_143 && cond_1)? (   rd_arith_modregrm_to_reg) :
    (cond_150 && cond_1)? (`TRUE) :
    (cond_169 && cond_1)? (`TRUE) :
    (cond_205 && cond_1)? (`TRUE) :
    (cond_216 && cond_1)? (`TRUE) :
    (cond_250 && cond_1)? (`TRUE) :
    (cond_255)? (`TRUE) :
    (cond_258 && cond_1)? (`TRUE) :
    1'd0;
assign rd_system_linear =
    (cond_33)? ( tr_base + 32'd102) :
    (cond_35)? ( tr_base + { 16'd0, rd_memory_last[15:0] } + { 16'd0, 3'd0, glob_param_1[15:3] }) :
    (cond_64)? ( idtr_base + { 22'd0, exc_vector[7:0], 2'b00 }) :
    (cond_65)? ( idtr_base + { 22'd0, exc_vector[7:0], 2'b10 }) :
    (cond_66)? ( idtr_base + { 21'd0, exc_vector[7:0], 3'b000 }) :
    (cond_88)? ( tr_base) :
    (cond_187)? ( tr_base + rd_offset_for_ss_from_tss) :
    (cond_189)? ( tr_base + rd_offset_for_esp_from_tss) :
    (cond_227)? ( gdtr_base + { 16'd0, tr[15:3], 3'd0 } + 32'd4) :
    (cond_232 && cond_233)? ( glob_desc_base + 32'd12) :
    (cond_232 && cond_234)? ( glob_desc_base + 32'h1C) :
    (cond_232 && cond_235)? ( rd_task_switch_linear_next) :
    (cond_237)? ( rd_task_switch_linear_next) :
    (cond_239)? ( gdtr_base + { 16'd0, glob_param_1[15:3], 3'd0 } + 32'd4) :
    32'd0;
assign rd_glob_param_1_value =
    (cond_18 && ~cond_16)? ( { 16'd0, glob_descriptor[31:16] }) :
    (cond_51 && cond_52)? ( { 13'd0, rd_decoder[4] & rd_decoder[2], (rd_decoder[6] & rd_decoder[0]) | rd_decoder[1], rd_decoder[0], read_4[15:0] }) :
    (cond_53 && cond_50)? ( { 13'd0, rd_decoder[4] & rd_decoder[2], (rd_decoder[6] & rd_decoder[0]) | rd_decoder[1], rd_decoder[0], read_4[15:0] }) :
    (cond_55 && cond_56 && cond_1 && cond_57)? ( { 13'd0, rd_decoder[13:11], dst_wire[15:0] }) :
    (cond_55 && cond_56 && cond_1 && cond_58)? ( { 13'd0, `SEGMENT_LDT, dst_wire[15:0] }) :
    (cond_55 && cond_56 && cond_1 && cond_59)? ( { 13'd0, `SEGMENT_TR, dst_wire[15:0] }) :
    (cond_55 && cond_56 && cond_3 && ~cond_9 && cond_57)? ( { 13'd0, rd_decoder[13:11], read_4[15:0] }) :
    (cond_55 && cond_56 && cond_3 && ~cond_9 && cond_58)? ( { 13'd0, `SEGMENT_LDT, read_4[15:0] }) :
    (cond_55 && cond_56 && cond_3 && ~cond_9 && cond_59)? ( { 13'd0, `SEGMENT_TR, read_4[15:0] }) :
    (cond_61 && ~cond_16)? ( { 16'd0, glob_descriptor[31:16] }) :
    (cond_65)? ( { 13'd0, `SEGMENT_CS, read_4[15:0] }) :
    (cond_75)? ( { 13'd0, rd_decoder[5:3], read_4[15:0] }) :
    (cond_79 && cond_82)? ( { 13'd0, `SEGMENT_CS, read_4[15:0] }) :
    (cond_88)? ( { 14'd0, `TASK_SWITCH_FROM_IRET, read_4[15:0] }) :
    (cond_91 && cond_93)? ( { `MC_PARAM_1_FLAG_NO_WRITE, `SEGMENT_CS, read_4[15:0] }) :
    (cond_97)? ( { `MC_PARAM_1_FLAG_NP_NOT_SS | `MC_PARAM_1_FLAG_CPL_FROM_PARAM_3, `SEGMENT_SS, read_4[15:0] }) :
    (cond_157)? ( { `MC_PARAM_1_FLAG_CPL_FROM_PARAM_3, `SEGMENT_SS, read_4[15:0] }) :
    (cond_158 && ~cond_9 && cond_72)? ( { `MC_PARAM_1_FLAG_NO_WRITE, `SEGMENT_CS, read_4[15:0] }) :
    (cond_160 && ~cond_9 && cond_159)? ( { `MC_PARAM_1_FLAG_NO_WRITE, `SEGMENT_CS, read_4[15:0] }) :
    (cond_178 && cond_1 && ~cond_8)? ( { 16'd0, dst_wire[15:0] }) :
    (cond_178 && cond_3 && ~cond_9)? ( { 16'd0, read_4[15:0] }) :
    (cond_203 && ~cond_16)? ( { 13'd0, `SEGMENT_CS, glob_descriptor[31:16] }) :
    (cond_210 && ~cond_16)? ( { 16'd0, glob_descriptor[31:16] }) :
    32'd0;
assign rd_glob_descriptor_2_value =
    (cond_97)? ( glob_descriptor) :
    (cond_157)? ( glob_descriptor) :
    64'd0;
assign rd_dst_is_modregrm_imm_se =
    (cond_133 && cond_134)? (`TRUE) :
    1'd0;
assign rd_dst_is_reg =
    (cond_6)? (`TRUE) :
    (cond_54)? (`TRUE) :
    (cond_133)? (`TRUE) :
    (cond_135)? (          rd_decoder[3]) :
    (cond_143)? (  rd_arith_modregrm_to_reg) :
    (cond_166)? (`TRUE) :
    (cond_181 && ~cond_183 && cond_184)? (`TRUE) :
    (cond_185 && ~cond_183 && cond_186)? (`TRUE) :
    (cond_216)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_245)? (`TRUE) :
    (cond_250)? (`TRUE) :
    (cond_258)? (`TRUE) :
    1'd0;
assign rd_src_is_implicit_reg =
    (cond_168)? (`TRUE) :
    1'd0;
assign address_enter_init =
    (cond_128)? (`TRUE) :
    1'd0;
assign rd_dst_is_memory =
    (cond_0 && cond_3)? (`TRUE) :
    (cond_28 && cond_3)? (`TRUE) :
    (cond_30 && cond_3 && ~cond_9)? (`TRUE) :
    (cond_40 && cond_3)? (`TRUE) :
    (cond_44 && cond_3)? (`TRUE) :
    (cond_76 && cond_3)? (`TRUE) :
    (cond_106 && cond_3)? (`TRUE) :
    (cond_110 && cond_3)? (`TRUE) :
    (cond_111 && cond_3)? (`TRUE) :
    (cond_116 && cond_3)? (`TRUE) :
    (cond_126 && cond_3)? (`TRUE) :
    (cond_127 && cond_3 && ~cond_4)? (`TRUE) :
    (cond_139 && cond_3)? (`TRUE) :
    (cond_140 && cond_3)? (`TRUE) :
    (cond_143 && cond_3)? (   rd_arith_modregrm_to_rm) :
    (cond_147 && cond_3)? (`TRUE) :
    (cond_154 && cond_3)? (`TRUE) :
    (cond_155 && cond_3)? (`TRUE) :
    (cond_165 && cond_3)? (`TRUE) :
    (cond_177 && cond_3)? (`TRUE) :
    (cond_213 && ~cond_214)? (`TRUE) :
    (cond_217 && cond_3)? (`TRUE) :
    (cond_219 && cond_3)? (`TRUE) :
    1'd0;
assign rd_glob_descriptor_2_set =
    (cond_97)? (`TRUE) :
    (cond_157)? (`TRUE) :
    1'd0;
assign rd_error_code =
    (cond_15 && ~cond_16 && cond_17)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_19 && cond_20)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_21 && ~cond_16 && cond_17)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_62 && cond_20)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_63 && ~cond_16 && cond_17)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_73 && cond_74)? ( { glob_param_1[15:2], 2'd0 }) :
    (cond_187)? ( `SELECTOR_FOR_CODE(tr)) :
    (cond_204 && cond_17)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_209 && ~cond_16 && cond_17)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_211 && cond_20)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    16'd0;
assign rd_dst_is_edx_eax =
    (cond_107)? (`TRUE) :
    (cond_135)? (    ~(rd_decoder[3])) :
    (cond_150)? (`TRUE) :
    1'd0;
assign rd_src_is_modregrm_imm =
    (cond_76)? (  rd_cmdex == `CMDEX_BTx_modregrm_imm) :
    (cond_110)? ( rd_cmdex == `CMDEX_Shift_modregrm_imm) :
    (cond_147 && cond_1 && ~cond_134)? (`TRUE) :
    (cond_147 && cond_3 && ~cond_134)? (`TRUE) :
    (cond_155)? (`TRUE) :
    (cond_219)? (`TRUE) :
    1'd0;
assign address_stack_for_call_param_first =
    (cond_22 && cond_26)? (`TRUE) :
    1'd0;
assign rd_req_ebx =
    (cond_172)? (`TRUE) :
    1'd0;
assign address_ea_buffer_plus_2 =
    (cond_121)? (`TRUE) :
    (cond_246)? (`TRUE) :
    1'd0;
assign rd_req_edx_eax =
    (cond_107)? ( rd_decoder[0]) :
    (cond_135)? (      ~(rd_decoder[3]) && rd_decoder[0]) :
    (cond_150)? ( rd_decoder[0]) :
    1'd0;
assign address_stack_for_iret_third =
    (cond_98 && cond_99)? (`TRUE) :
    1'd0;
assign rd_src_is_ecx =
    (cond_111)? (`TRUE) :
    1'd0;
assign rd_req_ebp =
    (cond_130)? (`TRUE) :
    (cond_138 && ~cond_9)? (`TRUE) :
    1'd0;
assign rd_req_rm =
    (cond_6)? (      rd_modregrm_mod == 2'b11) :
    (cond_28 && cond_1)? (`TRUE) :
    (cond_30 && cond_1)? (`TRUE) :
    (cond_40 && cond_1 && ~cond_8)? (`TRUE) :
    (cond_44 && cond_1)? (`TRUE) :
    (cond_76 && cond_1)? ( rd_cmd[1:0] != 2'd0) :
    (cond_106 && cond_1)? (`TRUE) :
    (cond_110 && cond_1)? (`TRUE) :
    (cond_111 && cond_1)? (`TRUE) :
    (cond_116 && cond_1)? (`TRUE) :
    (cond_120)? (`TRUE) :
    (cond_126 && cond_1)? (`TRUE) :
    (cond_127 && cond_1 && ~cond_2)? (`TRUE) :
    (cond_139 && cond_1)? (`TRUE) :
    (cond_140 && cond_1)? (`TRUE) :
    (cond_143 && cond_1 && cond_144)? (  rd_arith_modregrm_to_rm) :
    (cond_147 && cond_1 && cond_148)? (`TRUE) :
    (cond_166 && cond_1)? (`TRUE) :
    (cond_177 && cond_1)? (`TRUE) :
    (cond_217 && cond_1)? (`TRUE) :
    (cond_219 && cond_1)? (`TRUE) :
    (cond_254)? (`TRUE) :
    1'd0;
assign rd_src_is_modregrm_imm_se =
    (cond_147 && cond_1 && cond_134)? (`TRUE) :
    (cond_147 && cond_3 && cond_134)? (`TRUE) :
    1'd0;
assign read_length_dword =
    (cond_22 && cond_24)? (`TRUE) :
    (cond_121 && cond_123)? (`TRUE) :
    (cond_246 && cond_248)? (`TRUE) :
    1'd0;
