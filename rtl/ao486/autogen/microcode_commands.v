//======================================================== conditions
wire cond_0 = mc_cmd == `CMD_XADD && mc_cmdex_last == `CMDEX_XADD_FIRST;
wire cond_1 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_Ev_STEP_0;
wire cond_2 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_Jv_STEP_0;
wire cond_3 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_Ep_STEP_0;
wire cond_4 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_Ap_STEP_0;
wire cond_5 = mc_cmd == `CMD_CALL && (mc_cmdex_last == `CMDEX_CALL_Ep_STEP_1 || mc_cmdex_last == `CMDEX_CALL_Ap_STEP_1) && (real_mode || v8086_mode);
wire cond_6 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_real_v8086_STEP_0;
wire cond_7 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_real_v8086_STEP_1;
wire cond_8 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_real_v8086_STEP_2;
wire cond_9 = mc_cmd == `CMD_CALL && (mc_cmdex_last == `CMDEX_CALL_Ep_STEP_1 || mc_cmdex_last == `CMDEX_CALL_Ap_STEP_1) && (protected_mode);
wire cond_10 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_STEP_0;
wire cond_11 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG];
wire cond_12 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_seg_STEP_0;
wire cond_13 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_seg_STEP_1;
wire cond_14 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_seg_STEP_2;
wire cond_15 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_protected_seg_STEP_3;
wire cond_16 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG] == `FALSE && (glob_descriptor[`DESC_BITS_TYPE] == `DESC_TSS_AVAIL_386 || glob_descriptor[`DESC_BITS_TYPE] == `DESC_TSS_AVAIL_286);
wire cond_17 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_task_switch_STEP_0 && glob_param_3[21:18] == 4'd0;
wire cond_18 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_task_switch_STEP_0 && glob_param_3[21:18] != 4'd0;
wire cond_19 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG] == `FALSE && glob_descriptor[`DESC_BITS_TYPE] == `DESC_TASK_GATE;
wire cond_20 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_task_gate_STEP_0;
wire cond_21 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_task_gate_STEP_1;
wire cond_22 = mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG] == `FALSE && (glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_386 || glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_286);
wire cond_23 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_STEP_0;
wire cond_24 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_STEP_1;
wire cond_25 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_STEP_2 && `DESC_IS_CODE_NON_CONFORMING(glob_descriptor) && glob_descriptor[`DESC_BITS_DPL] < cpl;
wire cond_26 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_more_STEP_0;
wire cond_27 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_more_STEP_1;
wire cond_28 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_more_STEP_2;
wire cond_29 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_more_STEP_3 && glob_param_3[24:20] != 5'd0;
wire cond_30 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_4 && glob_param_3[24:20] == 5'd1;
wire cond_31 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_4 && glob_param_3[24:20] != 5'd1;
wire cond_32 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_5 && glob_param_3[24:20] == 5'd1;
wire cond_33 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_5 && glob_param_3[24:20] != 5'd1;
wire cond_34 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_more_STEP_3 && glob_param_3[24:20] == 5'd0;
wire cond_35 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_6;
wire cond_36 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_7;
wire cond_37 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_8;
wire cond_38 = mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_9;
wire cond_39 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_STEP_2 && ~(`DESC_IS_CODE_NON_CONFORMING(glob_descriptor) && glob_descriptor[`DESC_BITS_DPL] < cpl);
wire cond_40 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_same_STEP_0;
wire cond_41 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_same_STEP_1;
wire cond_42 = mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_same_STEP_2;
wire cond_43 = mc_cmd == `CMD_INVD && mc_cmdex_last == `CMDEX_INVD_STEP_0;
wire cond_44 = mc_cmd == `CMD_INVD && mc_cmdex_last == `CMDEX_INVD_STEP_1;
wire cond_45 = mc_cmd == `CMD_INVLPG && mc_cmdex_last == `CMDEX_INVLPG_STEP_0;
wire cond_46 = mc_cmd == `CMD_INVLPG && mc_cmdex_last == `CMDEX_INVLPG_STEP_1;
wire cond_47 = mc_cmd == `CMD_io_allow && mc_cmdex_last == `CMDEX_io_allow_1;
wire cond_48 = mc_cmd == `CMD_io_allow && mc_cmdex_last == `CMDEX_io_allow_2;
wire cond_49 = mc_cmd == `CMD_RET_near && mc_cmdex_last == `CMDEX_RET_near_imm;
wire cond_50 = mc_cmd == `CMD_RET_near && mc_cmdex_last == `CMDEX_RET_near;
wire cond_51 = mc_cmd == `CMD_LxS && mc_cmdex_last == `CMDEX_LxS_STEP_1;
wire cond_52 = mc_cmd == `CMD_LxS && mc_cmdex_last == `CMDEX_LxS_STEP_2;
wire cond_53 = mc_cmd == `CMD_LxS && mc_cmdex_last == `CMDEX_LxS_STEP_3;
wire cond_54 = (mc_cmd == `CMD_MOV_to_seg || mc_cmd == `CMD_LLDT || mc_cmd == `CMD_LTR) && mc_cmdex_last != `CMDEX_MOV_to_seg_LLDT_LTR_STEP_LAST;
wire cond_55 = (mc_cmd == `CMD_MOV_to_seg || mc_cmd == `CMD_LLDT || mc_cmd == `CMD_LTR) && mc_cmdex_last == `CMDEX_MOV_to_seg_LLDT_LTR_STEP_LAST;
wire cond_56 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_STEP_0;
wire cond_57 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_STEP_1 && real_mode;
wire cond_58 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_real_STEP_0;
wire cond_59 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_real_STEP_1;
wire cond_60 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_real_STEP_2;
wire cond_61 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_real_STEP_3;
wire cond_62 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_real_STEP_4;
wire cond_63 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_STEP_1 && ~(real_mode);
wire cond_64 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_protected_STEP_0;
wire cond_65 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_protected_STEP_1;
wire cond_66 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_protected_STEP_2 && glob_descriptor[`DESC_BITS_TYPE] == `DESC_TASK_GATE;
wire cond_67 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_task_gate_STEP_0;
wire cond_68 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_task_gate_STEP_1;
wire cond_69 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_protected_STEP_2 && glob_descriptor[`DESC_BITS_TYPE] != `DESC_TASK_GATE;
wire cond_70 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_int_trap_gate_STEP_0;
wire cond_71 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_int_trap_gate_STEP_1;
wire cond_72 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_int_trap_gate_STEP_2 && `DESC_IS_CODE_NON_CONFORMING(glob_descriptor) && glob_descriptor[`DESC_BITS_DPL] < cpl;
wire cond_73 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_0;
wire cond_74 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_1;
wire cond_75 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_2;
wire cond_76 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_3 && v8086_mode;
wire cond_77 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_4;
wire cond_78 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_5;
wire cond_79 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_6;
wire cond_80 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_7;
wire cond_81 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_3 && ~(v8086_mode);
wire cond_82 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_8;
wire cond_83 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_more_STEP_9;
wire cond_84 = mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_0;
wire cond_85 = mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_1;
wire cond_86 = mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_2 && exc_push_error;
wire cond_87 = mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_3;
wire cond_88 = mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_2 && ~(exc_push_error);
wire cond_89 = mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_4;
wire cond_90 = mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_5;
wire cond_91 = mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_int_trap_gate_STEP_2 && ~(`DESC_IS_CODE_NON_CONFORMING(glob_descriptor) && glob_descriptor[`DESC_BITS_DPL] < cpl);
wire cond_92 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_same_STEP_0;
wire cond_93 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_same_STEP_1;
wire cond_94 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_same_STEP_2 && exc_push_error;
wire cond_95 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_same_STEP_3;
wire cond_96 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_same_STEP_2 && ~(exc_push_error);
wire cond_97 = mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_same_STEP_4;
wire cond_98 = mc_cmd == `CMD_load_seg && (~(protected_mode) || (protected_mode && mc_cmdex_last == `CMDEX_load_seg_STEP_2));
wire cond_99 = mc_cmd == `CMD_load_seg && protected_mode && mc_cmdex_last == `CMDEX_load_seg_STEP_1;
wire cond_100 = mc_cmd == `CMD_POP_seg && mc_cmdex_last == `CMDEX_POP_seg_STEP_1;
wire cond_101 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_real_v86_STEP_0;
wire cond_102 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_real_v86_STEP_1;
wire cond_103 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_real_v86_STEP_2;
wire cond_104 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_protected_STEP_0 && ntflag;
wire cond_105 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_task_switch_STEP_0;
wire cond_106 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_task_switch_STEP_1;
wire cond_107 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_protected_STEP_0 && ~(ntflag);
wire cond_108 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_protected_STEP_1;
wire cond_109 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_protected_STEP_2;
wire cond_110 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_protected_STEP_3 && mc_operand_32bit && glob_param_3[`EFLAGS_BIT_VM] && cpl == 2'd0;
wire cond_111 = mc_cmd == `CMD_IRET && mc_cmdex_last >= `CMDEX_IRET_protected_to_v86_STEP_0 && mc_cmdex_last < `CMDEX_IRET_protected_to_v86_STEP_5;
wire cond_112 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_protected_to_v86_STEP_5;
wire cond_113 = mc_cmd == `CMD_IRET_2 && mc_cmdex_last == `CMDEX_IRET_2_protected_to_v86_STEP_6;
wire cond_114 = mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_protected_STEP_3 && ~(mc_operand_32bit && glob_param_3[`EFLAGS_BIT_VM] && cpl == 2'd0);
wire cond_115 = mc_cmd == `CMD_IRET_2 && mc_cmdex_last == `CMDEX_IRET_2_protected_same_STEP_0;
wire cond_116 = mc_cmd == `CMD_IRET_2 && mc_cmdex_last == `CMDEX_IRET_2_protected_same_STEP_1;
wire cond_117 = mc_cmd == `CMD_IRET_2 && mc_cmdex_last == `CMDEX_IRET_2_protected_outer_STEP_0;
wire cond_118 = mc_cmd == `CMD_IRET_2 && mc_cmdex_last >= `CMDEX_IRET_2_protected_outer_STEP_1 && mc_cmdex_last < `CMDEX_IRET_2_protected_outer_STEP_6;
wire cond_119 = mc_cmd == `CMD_IRET_2 && mc_cmdex_last == `CMDEX_IRET_2_protected_outer_STEP_6;
wire cond_120 = mc_cmd == `CMD_POP && mc_cmdex_last == `CMDEX_POP_modregrm_STEP_0;
wire cond_121 = mc_cmd == `CMD_CMPS && mc_cmdex_last == `CMDEX_CMPS_FIRST;
wire cond_122 = mc_cmd == `CMD_CMPS && mc_cmdex_last == `CMDEX_CMPS_LAST;
wire cond_123 = mc_cmd == `CMD_control_reg && mc_cmdex_last == `CMDEX_control_reg_LMSW_STEP_0;
wire cond_124 = mc_cmd == `CMD_control_reg && mc_cmdex_last == `CMDEX_control_reg_MOV_load_STEP_0;
wire cond_125 = (mc_cmd == `CMD_LGDT || mc_cmd == `CMD_LIDT) && mc_cmdex_last == `CMDEX_LGDT_LIDT_STEP_1;
wire cond_126 = (mc_cmd == `CMD_LGDT || mc_cmd == `CMD_LIDT) && mc_cmdex_last == `CMDEX_LGDT_LIDT_STEP_2;
wire cond_127 = (mc_cmd == `CMD_LGDT || mc_cmd == `CMD_LIDT) && mc_cmdex_last == `CMDEX_LGDT_LIDT_STEP_LAST;
wire cond_128 = mc_cmd == `CMD_PUSHA && mc_step < 6'd7;
wire cond_129 = mc_cmd == `CMD_PUSHA && mc_step == 6'd7;
wire cond_130 = mc_cmd == `CMD_ENTER && ((mc_step == 6'd1 && mc_decoder[28:24] == 5'd0) || (mc_step == 6'd2 && mc_decoder[28:24] == 5'd1) || (mc_step > { 1'b0, mc_decoder[28:24] } && mc_decoder[28:24] > 5'd1));
wire cond_131 = mc_cmd == `CMD_ENTER && ((mc_step == 6'd1 && mc_decoder[28:24] == 5'd1) || (mc_step == { 1'b0, mc_decoder[28:24] } && mc_decoder[28:24] > 5'd1));
wire cond_132 = mc_cmd == `CMD_ENTER && (mc_step < { 1'b0, mc_decoder[28:24] } && mc_decoder[28:24] > 5'd1);
wire cond_133 = mc_cmd == `CMD_WBINVD && mc_cmdex_last == `CMDEX_WBINVD_STEP_0;
wire cond_134 = mc_cmd == `CMD_WBINVD && mc_cmdex_last == `CMDEX_WBINVD_STEP_1;
wire cond_135 = mc_cmd == `CMD_CLTS && mc_cmdex_last == `CMDEX_CLTS_STEP_FIRST;
wire cond_136 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_STEP_1;
wire cond_137 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_STEP_2;
wire cond_138 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_real_STEP_3;
wire cond_139 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_same_STEP_3;
wire cond_140 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_outer_STEP_3;
wire cond_141 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_outer_STEP_4;
wire cond_142 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_outer_STEP_5;
wire cond_143 = mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_outer_STEP_6;
wire cond_144 = mc_cmd == `CMD_XCHG && mc_cmdex_last == `CMDEX_XCHG_modregrm;
wire cond_145 = mc_cmd == `CMD_INT_INTO && (mc_cmdex_last == `CMDEX_INT_INTO_INT_STEP_0 || mc_cmdex_last == `CMDEX_INT_INTO_INT3_STEP_0 || mc_cmdex_last == `CMDEX_INT_INTO_INT1_STEP_0);
wire cond_146 = mc_cmd == `CMD_INT_INTO && mc_cmdex_last == `CMDEX_INT_INTO_INTO_STEP_0 && oflag;
wire cond_147 = mc_cmd == `CMD_INT_INTO && mc_cmdex_last == `CMDEX_INT_INTO_INTO_STEP_0 && ~(oflag);
wire cond_148 = mc_cmd == `CMD_IN && (mc_cmdex_last == `CMDEX_IN_imm || mc_cmdex_last == `CMDEX_IN_dx) && ~(io_allow_check_needed);
wire cond_149 = mc_cmd == `CMD_IN && (mc_cmdex_last == `CMDEX_IN_imm || mc_cmdex_last == `CMDEX_IN_dx) && io_allow_check_needed;
wire cond_150 = mc_cmd == `CMD_IN && mc_cmdex_last == `CMDEX_IN_protected;
wire cond_151 = (mc_cmd == `CMD_LAR || mc_cmd == `CMD_LSL || mc_cmd == `CMD_VERR || mc_cmd == `CMD_VERW) && mc_cmdex_last == `CMDEX_LAR_LSL_VERR_VERW_STEP_1;
wire cond_152 = (mc_cmd == `CMD_LAR || mc_cmd == `CMD_LSL || mc_cmd == `CMD_VERR || mc_cmd == `CMD_VERW) && mc_cmdex_last == `CMDEX_LAR_LSL_VERR_VERW_STEP_2;
wire cond_153 = mc_cmd == `CMD_INS && mc_cmdex_last == `CMDEX_INS_real_1 && ~(io_allow_check_needed);
wire cond_154 = mc_cmd == `CMD_INS && mc_cmdex_last == `CMDEX_INS_real_2;
wire cond_155 = mc_cmd == `CMD_INS && mc_cmdex_last == `CMDEX_INS_real_1 && io_allow_check_needed;
wire cond_156 = mc_cmd == `CMD_INS && mc_cmdex_last == `CMDEX_INS_protected_1;
wire cond_157 = mc_cmd == `CMD_INS && mc_cmdex_last == `CMDEX_INS_protected_2;
wire cond_158 = mc_cmd == `CMD_OUTS && mc_cmdex_last == `CMDEX_OUTS_first && ~(io_allow_check_needed);
wire cond_159 = mc_cmd == `CMD_OUTS && mc_cmdex_last == `CMDEX_OUTS_first && io_allow_check_needed;
wire cond_160 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_Jv_STEP_0;
wire cond_161 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_Ev_STEP_0;
wire cond_162 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_Ep_STEP_0;
wire cond_163 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_Ap_STEP_0;
wire cond_164 = mc_cmd == `CMD_JMP && (mc_cmdex_last == `CMDEX_JMP_Ep_STEP_1 || mc_cmdex_last == `CMDEX_JMP_Ap_STEP_1) && (real_mode || v8086_mode);
wire cond_165 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_real_v8086_STEP_0;
wire cond_166 = mc_cmd == `CMD_JMP && (mc_cmdex_last == `CMDEX_JMP_Ep_STEP_1 || mc_cmdex_last == `CMDEX_JMP_Ap_STEP_1) && (protected_mode);
wire cond_167 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_protected_STEP_0;
wire cond_168 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG];
wire cond_169 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_protected_seg_STEP_0;
wire cond_170 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG] == `FALSE && (glob_descriptor[`DESC_BITS_TYPE] == `DESC_TSS_AVAIL_386 || glob_descriptor[`DESC_BITS_TYPE] == `DESC_TSS_AVAIL_286);
wire cond_171 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_task_switch_STEP_0 && glob_param_3[21:18] == 4'd0;
wire cond_172 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_task_switch_STEP_0 && glob_param_3[21:18] != 4'd0;
wire cond_173 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG] == `FALSE && glob_descriptor[`DESC_BITS_TYPE] == `DESC_TASK_GATE;
wire cond_174 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_task_gate_STEP_0;
wire cond_175 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_task_gate_STEP_1;
wire cond_176 = mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_protected_STEP_1 && glob_descriptor[`DESC_BIT_SEG] == `FALSE && (glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_386 || glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_286);
wire cond_177 = mc_cmd == `CMD_JMP_2 && mc_cmdex_last == `CMDEX_JMP_2_call_gate_STEP_0;
wire cond_178 = mc_cmd == `CMD_JMP_2 && mc_cmdex_last == `CMDEX_JMP_2_call_gate_STEP_1;
wire cond_179 = mc_cmd == `CMD_JMP_2 && mc_cmdex_last == `CMDEX_JMP_2_call_gate_STEP_2;
wire cond_180 = mc_cmd == `CMD_OUT && (mc_cmdex_last == `CMDEX_OUT_imm || mc_cmdex_last == `CMDEX_OUT_dx) && ~(io_allow_check_needed);
wire cond_181 = mc_cmd == `CMD_OUT && (mc_cmdex_last == `CMDEX_OUT_imm || mc_cmdex_last == `CMDEX_OUT_dx) && io_allow_check_needed;
wire cond_182 = mc_cmd == `CMD_OUT && mc_cmdex_last == `CMDEX_OUT_protected;
wire cond_183 = mc_cmd == `CMD_POPF && mc_cmdex_last == `CMDEX_POPF_STEP_0;
wire cond_184 = mc_cmd == `CMD_BOUND && mc_cmdex_last == `CMDEX_BOUND_STEP_FIRST;
wire cond_185 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_1 && cr0_pg;
wire cond_186 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_2;
wire cond_187 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_3 && (glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_CALL || glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_INT);
wire cond_188 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_4;
wire cond_189 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_5;
wire cond_190 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_3 && ~(glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_CALL || glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_INT);
wire cond_191 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_1 && ~(cr0_pg);
wire cond_192 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_6 && cr0_pg;
wire cond_193 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_7;
wire cond_194 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_8;
wire cond_195 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_6 && ~(cr0_pg);
wire cond_196 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_9;
wire cond_197 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_10;
wire cond_198 = mc_cmd == `CMD_task_switch_2 && mc_cmdex_last < `CMDEX_task_switch_2_STEP_13;
wire cond_199 = mc_cmd == `CMD_task_switch_2 && mc_cmdex_last == `CMDEX_task_switch_2_STEP_13;
wire cond_200 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_11;
wire cond_201 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_12;
wire cond_202 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_13;
wire cond_203 = mc_cmd == `CMD_task_switch && mc_cmdex_last == `CMDEX_task_switch_STEP_14;
wire cond_204 = mc_cmd == `CMD_task_switch_3;
wire cond_205 = mc_cmd == `CMD_task_switch_3 && mc_cmdex_last == `CMDEX_task_switch_3_STEP_15;
wire cond_206 = mc_cmd == `CMD_task_switch_4 && mc_cmdex_last < `CMDEX_task_switch_4_STEP_10;
wire cond_207 = mc_cmd == `CMD_SGDT || mc_cmd == `CMD_SIDT;
wire cond_208 = mc_cmd == `CMD_POPA && mc_step < 6'd7;
wire cond_209 = mc_cmd == `CMD_POPA && mc_step == 6'd7;
wire cond_210 = mc_cmd == `CMD_debug_reg && mc_cmdex_last == `CMDEX_debug_reg_MOV_load_STEP_0;
wire cond_211 = 
(mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_Ev_Jv_STEP_1) ||
(mc_cmd == `CMD_CALL && mc_cmdex_last == `CMDEX_CALL_real_v8086_STEP_3) ||
(mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_protected_seg_STEP_4) ||
(mc_cmd == `CMD_CALL_3 && mc_cmdex_last == `CMDEX_CALL_3_call_gate_more_STEP_10) ||
(mc_cmd == `CMD_CALL_2 && mc_cmdex_last == `CMDEX_CALL_2_call_gate_same_STEP_3) ||
(mc_cmd == `CMD_INVD && mc_cmdex_last == `CMDEX_INVD_STEP_2) ||
(mc_cmd == `CMD_INVLPG && mc_cmdex_last == `CMDEX_INVLPG_STEP_2) ||
(mc_cmd == `CMD_HLT && mc_cmdex_last == `CMDEX_HLT_STEP_0) ||
(mc_cmd == `CMD_SCAS && mc_cmdex_last == `CMDEX_SCAS_STEP_0) ||
(mc_cmd == `CMD_LxS && mc_cmdex_last == `CMDEX_LxS_STEP_LAST) ||
(mc_cmd == `CMD_int && mc_cmdex_last == `CMDEX_int_real_STEP_5) ||
(mc_cmd == `CMD_int_3 && mc_cmdex_last == `CMDEX_int_3_int_trap_gate_more_STEP_6) ||
(mc_cmd == `CMD_int_2 && mc_cmdex_last == `CMDEX_int_2_int_trap_gate_same_STEP_5) ||
(mc_cmd == `CMD_POP_seg && mc_cmdex_last == `CMDEX_POP_seg_STEP_LAST) ||
(mc_cmd == `CMD_IRET && mc_cmdex_last == `CMDEX_IRET_real_v86_STEP_3) ||
(mc_cmd == `CMD_IRET_2 && mc_cmdex_last == `CMDEX_IRET_2_idle) ||
(mc_cmd == `CMD_control_reg && mc_cmdex_last == `CMDEX_control_reg_LMSW_STEP_1) ||
(mc_cmd == `CMD_control_reg && mc_cmdex_last == `CMDEX_control_reg_MOV_load_STEP_1) ||
(mc_cmd == `CMD_WBINVD && mc_cmdex_last == `CMDEX_WBINVD_STEP_2) ||
(mc_cmd == `CMD_CLTS && mc_cmdex_last == `CMDEX_CLTS_STEP_LAST) ||
(mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_real_STEP_3) ||
(mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_same_STEP_4) ||
(mc_cmd == `CMD_RET_far && mc_cmdex_last == `CMDEX_RET_far_outer_STEP_7) ||
(mc_cmd == `CMD_LODS && mc_cmdex_last == `CMDEX_LODS_STEP_0) ||
(mc_cmd == `CMD_CPUID && mc_cmdex_last == `CMDEX_CPUID_STEP_LAST) ||
(mc_cmd == `CMD_IN && mc_cmdex_last == `CMDEX_IN_idle) ||
(mc_cmd == `CMD_STOS && mc_cmdex_last == `CMDEX_STOS_STEP_0) ||
(mc_cmd == `CMD_OUTS && mc_cmdex_last == `CMDEX_OUTS_protected) ||
(mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_Ev_Jv_STEP_1) ||
(mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_real_v8086_STEP_1) ||
(mc_cmd == `CMD_JMP && mc_cmdex_last == `CMDEX_JMP_protected_seg_STEP_1) ||
(mc_cmd == `CMD_JMP_2 && mc_cmdex_last == `CMDEX_JMP_2_call_gate_STEP_3) ||
(mc_cmd == `CMD_OUT && mc_cmdex_last == `CMDEX_OUT_idle) ||
(mc_cmd == `CMD_POPF && mc_cmdex_last == `CMDEX_POPF_STEP_1) ||
(mc_cmd == `CMD_MOVS && mc_cmdex_last == `CMDEX_MOVS_STEP_0) ||
(mc_cmd == `CMD_debug_reg && mc_cmdex_last == `CMDEX_debug_reg_MOV_load_STEP_1)
;
//======================================================== saves
wire [6:0] mc_saved_command_to_reg =
    (cond_8)? ( `CMD_CALL) :
    (cond_53)? ( `CMD_LxS) :
    (cond_54)? ( `CMD_MOV_to_seg) :
    (cond_62)? ( `CMD_int) :
    (cond_100)? ( `CMD_POP_seg) :
    (cond_103)? ( `CMD_IRET) :
    (cond_114)? ( `CMD_IRET_2) :
    (cond_117)? ( `CMD_IRET_2) :
    (cond_137)? ( `CMD_RET_far) :
    (cond_141)? ( `CMD_RET_far) :
    (cond_149)? ( `CMD_IN) :
    (cond_155)? ( `CMD_INS) :
    (cond_159)? ( `CMD_OUTS) :
    (cond_165)? ( `CMD_JMP) :
    (cond_181)? ( `CMD_OUT) :
    mc_saved_command;
wire [3:0] mc_saved_cmdex_to_reg =
    (cond_8)? (   `CMDEX_CALL_real_v8086_STEP_3) :
    (cond_53)? (   `CMDEX_LxS_STEP_LAST) :
    (cond_54)? (   `CMDEX_MOV_to_seg_LLDT_LTR_STEP_LAST) :
    (cond_62)? (   `CMDEX_int_real_STEP_5) :
    (cond_100)? (   `CMDEX_POP_seg_STEP_LAST) :
    (cond_103)? (   `CMDEX_IRET_real_v86_STEP_3) :
    (cond_114)? (    (glob_param_1[`SELECTOR_BITS_RPL] == cpl)? `CMDEX_IRET_2_protected_same_STEP_0 : `CMDEX_IRET_2_protected_outer_STEP_0) :
    (cond_117)? (   `CMDEX_IRET_2_protected_outer_STEP_1) :
    (cond_137)? (    (real_mode || v8086_mode)? `CMDEX_RET_far_real_STEP_3 : (glob_param_1[`SELECTOR_BITS_RPL] == cpl)? `CMDEX_RET_far_same_STEP_3 : `CMDEX_RET_far_outer_STEP_3) :
    (cond_141)? (   `CMDEX_RET_far_outer_STEP_5) :
    (cond_149)? (   `CMDEX_IN_protected) :
    (cond_155)? (   `CMDEX_INS_protected_1) :
    (cond_159)? (   `CMDEX_OUTS_protected) :
    (cond_165)? (   `CMDEX_JMP_real_v8086_STEP_1) :
    (cond_181)? (   `CMDEX_OUT_protected) :
    mc_saved_cmdex;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) mc_saved_command <= 7'd0;
    else              mc_saved_command <= mc_saved_command_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) mc_saved_cmdex <= 4'd0;
    else              mc_saved_cmdex <= mc_saved_cmdex_to_reg;
end
//======================================================== sets
assign mc_cmd_next =
    (cond_1)? (      `CMD_CALL) :
    (cond_2)? (      `CMD_CALL) :
    (cond_3)? (      `CMD_CALL) :
    (cond_4)? (      `CMD_CALL) :
    (cond_5)? (      `CMD_CALL) :
    (cond_6)? (      `CMD_CALL) :
    (cond_7)? (      `CMD_CALL) :
    (cond_8)? (      `CMD_load_seg) :
    (cond_9)? (      `CMD_CALL) :
    (cond_10)? (      `CMD_CALL) :
    (cond_11)? (      `CMD_CALL) :
    (cond_12)? (      `CMD_CALL) :
    (cond_13)? (      `CMD_CALL) :
    (cond_14)? (      `CMD_CALL_2) :
    (cond_15)? (      `CMD_CALL_2) :
    (cond_16)? (      `CMD_CALL_2) :
    (cond_17)? (      `CMD_CALL_2) :
    (cond_18)? (      `CMD_task_switch) :
    (cond_19)? (      `CMD_CALL_2) :
    (cond_20)? (      `CMD_CALL_2) :
    (cond_21)? (      `CMD_task_switch) :
    (cond_22)? (      `CMD_CALL_2) :
    (cond_23)? (      `CMD_CALL_2) :
    (cond_24)? (      `CMD_CALL_2) :
    (cond_25)? (      `CMD_CALL_2) :
    (cond_26)? (      `CMD_CALL_2) :
    (cond_27)? (      `CMD_CALL_2) :
    (cond_28)? (      `CMD_CALL_2) :
    (cond_29)? (      `CMD_CALL_3) :
    (cond_30)? (      `CMD_CALL_3) :
    (cond_31)? (      `CMD_CALL_3) :
    (cond_32)? (      `CMD_CALL_3) :
    (cond_33)? (      `CMD_CALL_3) :
    (cond_34)? (      `CMD_CALL_3) :
    (cond_35)? (      `CMD_CALL_3) :
    (cond_36)? (      `CMD_CALL_3) :
    (cond_37)? (      `CMD_CALL_3) :
    (cond_38)? (      `CMD_CALL_3) :
    (cond_39)? (      `CMD_CALL_2) :
    (cond_40)? (      `CMD_CALL_2) :
    (cond_41)? (      `CMD_CALL_2) :
    (cond_42)? (      `CMD_CALL_2) :
    (cond_43)? (      `CMD_INVD) :
    (cond_44)? (      `CMD_INVD) :
    (cond_45)? (      `CMD_INVLPG) :
    (cond_46)? (      `CMD_INVLPG) :
    (cond_47)? (      `CMD_io_allow) :
    (cond_48)? (      mc_saved_command) :
    (cond_51)? (      `CMD_LxS) :
    (cond_52)? (      `CMD_LxS) :
    (cond_53)? (      `CMD_load_seg) :
    (cond_54)? (      `CMD_load_seg) :
    (cond_55)? (      `CMD_MOV_to_seg) :
    (cond_56)? (      `CMD_int) :
    (cond_57)? (      `CMD_int) :
    (cond_58)? (      `CMD_int) :
    (cond_59)? (      `CMD_int) :
    (cond_60)? (      `CMD_int) :
    (cond_61)? (      `CMD_int) :
    (cond_62)? (      `CMD_load_seg) :
    (cond_63)? (      `CMD_int) :
    (cond_64)? (      `CMD_int) :
    (cond_65)? (      `CMD_int) :
    (cond_66)? (      `CMD_int) :
    (cond_67)? (      `CMD_int) :
    (cond_68)? (      `CMD_task_switch) :
    (cond_69)? (      `CMD_int) :
    (cond_70)? (      `CMD_int) :
    (cond_71)? (      `CMD_int) :
    (cond_72)? (      `CMD_int_2) :
    (cond_73)? (      `CMD_int_2) :
    (cond_74)? (      `CMD_int_2) :
    (cond_75)? (      `CMD_int_2) :
    (cond_76)? (      `CMD_int_2) :
    (cond_77)? (      `CMD_int_2) :
    (cond_78)? (      `CMD_int_2) :
    (cond_79)? (      `CMD_int_2) :
    (cond_80)? (      `CMD_int_2) :
    (cond_81)? (      `CMD_int_2) :
    (cond_82)? (      `CMD_int_2) :
    (cond_83)? (      `CMD_int_3) :
    (cond_84)? (      `CMD_int_3) :
    (cond_85)? (      `CMD_int_3) :
    (cond_86)? (      `CMD_int_3) :
    (cond_87)? (      `CMD_int_3) :
    (cond_88)? (      `CMD_int_3) :
    (cond_89)? (      `CMD_int_3) :
    (cond_90)? (      `CMD_int_3) :
    (cond_91)? (      `CMD_int_2) :
    (cond_92)? (      `CMD_int_2) :
    (cond_93)? (      `CMD_int_2) :
    (cond_94)? (      `CMD_int_2) :
    (cond_95)? (      `CMD_int_2) :
    (cond_96)? (      `CMD_int_2) :
    (cond_97)? (      `CMD_int_2) :
    (cond_98)? (      mc_saved_command) :
    (cond_99)? (      `CMD_load_seg) :
    (cond_100)? (      `CMD_load_seg) :
    (cond_101)? (      `CMD_IRET) :
    (cond_102)? (      `CMD_IRET) :
    (cond_103)? (      `CMD_load_seg) :
    (cond_104)? (      `CMD_IRET) :
    (cond_105)? (      `CMD_IRET) :
    (cond_106)? (      `CMD_task_switch) :
    (cond_107)? (      `CMD_IRET) :
    (cond_108)? (      `CMD_IRET) :
    (cond_109)? (      `CMD_IRET) :
    (cond_110)? (      `CMD_IRET) :
    (cond_111)? (      `CMD_IRET) :
    (cond_112)? (      `CMD_IRET_2) :
    (cond_113)? (      `CMD_IRET_2) :
    (cond_114)? (      `CMD_load_seg) :
    (cond_115)? (      `CMD_IRET_2) :
    (cond_116)? (      `CMD_IRET_2) :
    (cond_117)? (      `CMD_load_seg) :
    (cond_118)? (      `CMD_IRET_2) :
    (cond_119)? (      `CMD_IRET_2) :
    (cond_121)? (      `CMD_CMPS) :
    (cond_122)? (      `CMD_CMPS) :
    (cond_123)? (      `CMD_control_reg) :
    (cond_124)? (      `CMD_control_reg) :
    (cond_125)? (      mc_cmd) :
    (cond_126)? (      mc_cmd) :
    (cond_127)? (      mc_cmd) :
    (cond_128)? (      mc_cmd) :
    (cond_131)? (      `CMD_ENTER) :
    (cond_132)? (      `CMD_ENTER) :
    (cond_133)? (      `CMD_WBINVD) :
    (cond_134)? (      `CMD_WBINVD) :
    (cond_135)? (      `CMD_CLTS) :
    (cond_136)? (      `CMD_RET_far) :
    (cond_137)? (      `CMD_load_seg) :
    (cond_138)? (      `CMD_RET_far) :
    (cond_139)? (      `CMD_RET_far) :
    (cond_140)? (      `CMD_RET_far) :
    (cond_141)? (      `CMD_load_seg) :
    (cond_142)? (      `CMD_RET_far) :
    (cond_143)? (      `CMD_RET_far) :
    (cond_145)? (      `CMD_int) :
    (cond_146)? (      `CMD_int) :
    (cond_147)? (      `CMD_INT_INTO) :
    (cond_148)? (      `CMD_IN) :
    (cond_149)? (      `CMD_io_allow) :
    (cond_150)? (      `CMD_IN) :
    (cond_151)? (      mc_cmd) :
    (cond_153)? (      `CMD_INS) :
    (cond_154)? (      `CMD_INS) :
    (cond_155)? (      `CMD_io_allow) :
    (cond_156)? (      `CMD_INS) :
    (cond_157)? (      `CMD_INS) :
    (cond_158)? (      `CMD_OUTS) :
    (cond_159)? (      `CMD_io_allow) :
    (cond_160)? (      `CMD_JMP) :
    (cond_161)? (      `CMD_JMP) :
    (cond_162)? (      `CMD_JMP) :
    (cond_163)? (      `CMD_JMP) :
    (cond_164)? (      `CMD_JMP) :
    (cond_165)? (      `CMD_load_seg) :
    (cond_166)? (      `CMD_JMP) :
    (cond_167)? (      `CMD_JMP) :
    (cond_168)? (      `CMD_JMP) :
    (cond_169)? (      `CMD_JMP) :
    (cond_170)? (      `CMD_JMP) :
    (cond_171)? (      `CMD_JMP) :
    (cond_172)? (      `CMD_task_switch) :
    (cond_173)? (      `CMD_JMP) :
    (cond_174)? (      `CMD_JMP) :
    (cond_175)? (      `CMD_task_switch) :
    (cond_176)? (      `CMD_JMP_2) :
    (cond_177)? (      `CMD_JMP_2) :
    (cond_178)? (      `CMD_JMP_2) :
    (cond_179)? (      `CMD_JMP_2) :
    (cond_180)? (      `CMD_OUT) :
    (cond_181)? (      `CMD_io_allow) :
    (cond_182)? (      `CMD_OUT) :
    (cond_183)? (      `CMD_POPF) :
    (cond_185)? (      `CMD_task_switch) :
    (cond_186)? (      `CMD_task_switch) :
    (cond_187)? (      `CMD_task_switch) :
    (cond_188)? (      `CMD_task_switch) :
    (cond_189)? (      `CMD_task_switch) :
    (cond_190)? (      `CMD_task_switch) :
    (cond_191)? (      `CMD_task_switch) :
    (cond_192)? (      `CMD_task_switch) :
    (cond_193)? (      `CMD_task_switch) :
    (cond_194)? (      `CMD_task_switch) :
    (cond_195)? (      `CMD_task_switch) :
    (cond_196)? (      `CMD_task_switch) :
    (cond_197)? (      `CMD_task_switch_2) :
    (cond_198)? (      mc_cmd) :
    (cond_199)? (      `CMD_task_switch) :
    (cond_200)? (      `CMD_task_switch) :
    (cond_201)? (      `CMD_task_switch) :
    (cond_202)? (      `CMD_task_switch) :
    (cond_203)? (      `CMD_task_switch_3) :
    (cond_204)? (      mc_cmd) :
    (cond_205)? (      `CMD_task_switch_4) :
    (cond_206)? (      mc_cmd) :
    (cond_208)? (      mc_cmd) :
    (cond_210)? (      `CMD_debug_reg) :
    (cond_211)? (      mc_cmd) :
    7'd0;
assign mc_cmdex_current =
    (cond_0)? ( `CMDEX_XADD_LAST) :
    (cond_1)? ( `CMDEX_CALL_Ev_Jv_STEP_1) :
    (cond_2)? ( `CMDEX_CALL_Ev_Jv_STEP_1) :
    (cond_3)? ( `CMDEX_CALL_Ep_STEP_1) :
    (cond_4)? ( `CMDEX_CALL_Ap_STEP_1) :
    (cond_5)? ( `CMDEX_CALL_real_v8086_STEP_0) :
    (cond_6)? ( `CMDEX_CALL_real_v8086_STEP_1) :
    (cond_7)? ( `CMDEX_CALL_real_v8086_STEP_2) :
    (cond_8)? ( `CMDEX_load_seg_STEP_1) :
    (cond_9)? ( `CMDEX_CALL_protected_STEP_0) :
    (cond_10)? ( `CMDEX_CALL_protected_STEP_1) :
    (cond_11)? ( `CMDEX_CALL_protected_seg_STEP_0) :
    (cond_12)? ( `CMDEX_CALL_protected_seg_STEP_1) :
    (cond_13)? ( `CMDEX_CALL_protected_seg_STEP_2) :
    (cond_14)? ( `CMDEX_CALL_2_protected_seg_STEP_3) :
    (cond_15)? ( `CMDEX_CALL_2_protected_seg_STEP_4) :
    (cond_16)? ( `CMDEX_CALL_2_task_switch_STEP_0) :
    (cond_17)? ( `CMDEX_CALL_2_task_switch_STEP_0) :
    (cond_18)? ( `CMDEX_task_switch_STEP_1) :
    (cond_19)? ( `CMDEX_CALL_2_task_gate_STEP_0) :
    (cond_20)? ( `CMDEX_CALL_2_task_gate_STEP_1) :
    (cond_21)? ( `CMDEX_task_switch_STEP_1) :
    (cond_22)? ( `CMDEX_CALL_2_call_gate_STEP_0) :
    (cond_23)? ( `CMDEX_CALL_2_call_gate_STEP_1) :
    (cond_24)? ( `CMDEX_CALL_2_call_gate_STEP_2) :
    (cond_25)? ( `CMDEX_CALL_2_call_gate_more_STEP_0) :
    (cond_26)? ( `CMDEX_CALL_2_call_gate_more_STEP_1) :
    (cond_27)? ( `CMDEX_CALL_2_call_gate_more_STEP_2) :
    (cond_28)? ( `CMDEX_CALL_2_call_gate_more_STEP_3) :
    (cond_29)? ( `CMDEX_CALL_3_call_gate_more_STEP_4) :
    (cond_30)? ( `CMDEX_CALL_3_call_gate_more_STEP_6) :
    (cond_31)? ( `CMDEX_CALL_3_call_gate_more_STEP_5) :
    (cond_32)? ( `CMDEX_CALL_3_call_gate_more_STEP_6) :
    (cond_33)? ( `CMDEX_CALL_3_call_gate_more_STEP_5) :
    (cond_34)? ( `CMDEX_CALL_3_call_gate_more_STEP_6) :
    (cond_35)? ( `CMDEX_CALL_3_call_gate_more_STEP_7) :
    (cond_36)? ( `CMDEX_CALL_3_call_gate_more_STEP_8) :
    (cond_37)? ( `CMDEX_CALL_3_call_gate_more_STEP_9) :
    (cond_38)? ( `CMDEX_CALL_3_call_gate_more_STEP_10) :
    (cond_39)? ( `CMDEX_CALL_2_call_gate_same_STEP_0) :
    (cond_40)? ( `CMDEX_CALL_2_call_gate_same_STEP_1) :
    (cond_41)? ( `CMDEX_CALL_2_call_gate_same_STEP_2) :
    (cond_42)? ( `CMDEX_CALL_2_call_gate_same_STEP_3) :
    (cond_43)? ( `CMDEX_INVD_STEP_1) :
    (cond_44)? ( `CMDEX_INVD_STEP_2) :
    (cond_45)? ( `CMDEX_INVLPG_STEP_1) :
    (cond_46)? ( `CMDEX_INVLPG_STEP_2) :
    (cond_47)? ( `CMDEX_io_allow_2) :
    (cond_48)? ( mc_saved_cmdex) :
    (cond_49)? ( `CMDEX_RET_near_LAST) :
    (cond_50)? ( `CMDEX_RET_near_LAST) :
    (cond_51)? ( `CMDEX_LxS_STEP_2) :
    (cond_52)? ( `CMDEX_LxS_STEP_3) :
    (cond_53)? ( `CMDEX_load_seg_STEP_1) :
    (cond_54)? ( `CMDEX_load_seg_STEP_1) :
    (cond_55)? ( `CMDEX_MOV_to_seg_LLDT_LTR_STEP_LAST) :
    (cond_56)? ( `CMDEX_int_STEP_1) :
    (cond_57)? ( `CMDEX_int_real_STEP_0) :
    (cond_58)? ( `CMDEX_int_real_STEP_1) :
    (cond_59)? ( `CMDEX_int_real_STEP_2) :
    (cond_60)? ( `CMDEX_int_real_STEP_3) :
    (cond_61)? ( `CMDEX_int_real_STEP_4) :
    (cond_62)? ( `CMDEX_load_seg_STEP_1) :
    (cond_63)? ( `CMDEX_int_protected_STEP_0) :
    (cond_64)? ( `CMDEX_int_protected_STEP_1) :
    (cond_65)? ( `CMDEX_int_protected_STEP_2) :
    (cond_66)? ( `CMDEX_int_task_gate_STEP_0) :
    (cond_67)? ( `CMDEX_int_task_gate_STEP_1) :
    (cond_68)? ( `CMDEX_task_switch_STEP_1) :
    (cond_69)? ( `CMDEX_int_int_trap_gate_STEP_0) :
    (cond_70)? ( `CMDEX_int_int_trap_gate_STEP_1) :
    (cond_71)? ( `CMDEX_int_int_trap_gate_STEP_2) :
    (cond_72)? ( `CMDEX_int_2_int_trap_gate_more_STEP_0) :
    (cond_73)? ( `CMDEX_int_2_int_trap_gate_more_STEP_1) :
    (cond_74)? ( `CMDEX_int_2_int_trap_gate_more_STEP_2) :
    (cond_75)? ( `CMDEX_int_2_int_trap_gate_more_STEP_3) :
    (cond_76)? ( `CMDEX_int_2_int_trap_gate_more_STEP_4) :
    (cond_77)? ( `CMDEX_int_2_int_trap_gate_more_STEP_5) :
    (cond_78)? ( `CMDEX_int_2_int_trap_gate_more_STEP_6) :
    (cond_79)? ( `CMDEX_int_2_int_trap_gate_more_STEP_7) :
    (cond_80)? ( `CMDEX_int_2_int_trap_gate_more_STEP_8) :
    (cond_81)? ( `CMDEX_int_2_int_trap_gate_more_STEP_8) :
    (cond_82)? ( `CMDEX_int_2_int_trap_gate_more_STEP_9) :
    (cond_83)? ( `CMDEX_int_3_int_trap_gate_more_STEP_0) :
    (cond_84)? ( `CMDEX_int_3_int_trap_gate_more_STEP_1) :
    (cond_85)? ( `CMDEX_int_3_int_trap_gate_more_STEP_2) :
    (cond_86)? ( `CMDEX_int_3_int_trap_gate_more_STEP_3) :
    (cond_87)? ( `CMDEX_int_3_int_trap_gate_more_STEP_4) :
    (cond_88)? ( `CMDEX_int_3_int_trap_gate_more_STEP_4) :
    (cond_89)? ( `CMDEX_int_3_int_trap_gate_more_STEP_5) :
    (cond_90)? ( `CMDEX_int_3_int_trap_gate_more_STEP_6) :
    (cond_91)? ( `CMDEX_int_2_int_trap_gate_same_STEP_0) :
    (cond_92)? ( `CMDEX_int_2_int_trap_gate_same_STEP_1) :
    (cond_93)? ( `CMDEX_int_2_int_trap_gate_same_STEP_2) :
    (cond_94)? ( `CMDEX_int_2_int_trap_gate_same_STEP_3) :
    (cond_95)? ( `CMDEX_int_2_int_trap_gate_same_STEP_4) :
    (cond_96)? ( `CMDEX_int_2_int_trap_gate_same_STEP_4) :
    (cond_97)? ( `CMDEX_int_2_int_trap_gate_same_STEP_5) :
    (cond_98)? ( mc_saved_cmdex) :
    (cond_99)? ( `CMDEX_load_seg_STEP_2) :
    (cond_100)? ( `CMDEX_load_seg_STEP_1) :
    (cond_101)? ( `CMDEX_IRET_real_v86_STEP_1) :
    (cond_102)? ( `CMDEX_IRET_real_v86_STEP_2) :
    (cond_103)? ( `CMDEX_load_seg_STEP_1) :
    (cond_104)? ( `CMDEX_IRET_task_switch_STEP_0) :
    (cond_105)? ( `CMDEX_IRET_task_switch_STEP_1) :
    (cond_106)? ( `CMDEX_task_switch_STEP_1) :
    (cond_107)? ( `CMDEX_IRET_protected_STEP_1) :
    (cond_108)? ( `CMDEX_IRET_protected_STEP_2) :
    (cond_109)? ( `CMDEX_IRET_protected_STEP_3) :
    (cond_110)? ( `CMDEX_IRET_protected_to_v86_STEP_0) :
    (cond_111)? (  mc_cmdex_last + 4'd1) :
    (cond_112)? ( `CMDEX_IRET_2_protected_to_v86_STEP_6) :
    (cond_113)? ( `CMDEX_IRET_2_idle) :
    (cond_114)? ( `CMDEX_load_seg_STEP_1) :
    (cond_115)? ( `CMDEX_IRET_2_protected_same_STEP_1) :
    (cond_116)? ( `CMDEX_IRET_2_idle) :
    (cond_117)? ( `CMDEX_load_seg_STEP_1) :
    (cond_118)? (  mc_cmdex_last + 4'd1) :
    (cond_119)? ( `CMDEX_IRET_2_idle) :
    (cond_120)? ( `CMDEX_POP_modregrm_STEP_1) :
    (cond_121)? ( `CMDEX_CMPS_LAST) :
    (cond_122)? ( `CMDEX_CMPS_FIRST) :
    (cond_123)? ( `CMDEX_control_reg_LMSW_STEP_1) :
    (cond_124)? ( `CMDEX_control_reg_MOV_load_STEP_1) :
    (cond_125)? (  `CMDEX_LGDT_LIDT_STEP_2) :
    (cond_126)? (  `CMDEX_LGDT_LIDT_STEP_LAST) :
    (cond_127)? (  `CMDEX_LGDT_LIDT_STEP_LAST) :
    (cond_128)? (  mc_step[3:0]) :
    (cond_129)? ( `CMDEX_PUSHA_STEP_7) :
    (cond_130)? ( `CMDEX_ENTER_LAST) :
    (cond_131)? ( `CMDEX_ENTER_PUSH) :
    (cond_132)? ( `CMDEX_ENTER_LOOP) :
    (cond_133)? ( `CMDEX_WBINVD_STEP_1) :
    (cond_134)? ( `CMDEX_WBINVD_STEP_2) :
    (cond_135)? ( `CMDEX_CLTS_STEP_LAST) :
    (cond_136)? ( `CMDEX_RET_far_STEP_2) :
    (cond_137)? ( `CMDEX_load_seg_STEP_1) :
    (cond_138)? ( `CMDEX_RET_far_real_STEP_3) :
    (cond_139)? ( `CMDEX_RET_far_same_STEP_4) :
    (cond_140)? ( `CMDEX_RET_far_outer_STEP_4) :
    (cond_141)? ( `CMDEX_load_seg_STEP_1) :
    (cond_142)? ( `CMDEX_RET_far_outer_STEP_6) :
    (cond_143)? ( `CMDEX_RET_far_outer_STEP_7) :
    (cond_144)? ( `CMDEX_XCHG_modregrm_LAST) :
    (cond_145)? ( `CMDEX_int_STEP_0) :
    (cond_146)? ( `CMDEX_int_STEP_0) :
    (cond_147)? ( `CMDEX_INT_INTO_INTO_STEP_0) :
    (cond_148)? ( `CMDEX_IN_idle) :
    (cond_149)? ( `CMDEX_io_allow_1) :
    (cond_150)? ( `CMDEX_IN_idle) :
    (cond_151)? (  `CMDEX_LAR_LSL_VERR_VERW_STEP_2) :
    (cond_152)? (  `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST) :
    (cond_153)? ( `CMDEX_INS_real_2) :
    (cond_154)? ( `CMDEX_INS_real_1) :
    (cond_155)? ( `CMDEX_io_allow_1) :
    (cond_156)? ( `CMDEX_INS_protected_2) :
    (cond_157)? ( `CMDEX_INS_protected_1) :
    (cond_158)? ( `CMDEX_OUTS_first) :
    (cond_159)? ( `CMDEX_io_allow_1) :
    (cond_160)? ( `CMDEX_JMP_Ev_Jv_STEP_1) :
    (cond_161)? ( `CMDEX_JMP_Ev_Jv_STEP_1) :
    (cond_162)? ( `CMDEX_JMP_Ep_STEP_1) :
    (cond_163)? ( `CMDEX_JMP_Ap_STEP_1) :
    (cond_164)? ( `CMDEX_JMP_real_v8086_STEP_0) :
    (cond_165)? ( `CMDEX_load_seg_STEP_1) :
    (cond_166)? ( `CMDEX_JMP_protected_STEP_0) :
    (cond_167)? ( `CMDEX_JMP_protected_STEP_1) :
    (cond_168)? ( `CMDEX_JMP_protected_seg_STEP_0) :
    (cond_169)? ( `CMDEX_JMP_protected_seg_STEP_1) :
    (cond_170)? ( `CMDEX_JMP_task_switch_STEP_0) :
    (cond_171)? ( `CMDEX_JMP_task_switch_STEP_0) :
    (cond_172)? ( `CMDEX_task_switch_STEP_1) :
    (cond_173)? ( `CMDEX_JMP_task_gate_STEP_0) :
    (cond_174)? ( `CMDEX_JMP_task_gate_STEP_1) :
    (cond_175)? ( `CMDEX_task_switch_STEP_1) :
    (cond_176)? ( `CMDEX_JMP_2_call_gate_STEP_0) :
    (cond_177)? ( `CMDEX_JMP_2_call_gate_STEP_1) :
    (cond_178)? ( `CMDEX_JMP_2_call_gate_STEP_2) :
    (cond_179)? ( `CMDEX_JMP_2_call_gate_STEP_3) :
    (cond_180)? ( `CMDEX_OUT_idle) :
    (cond_181)? ( `CMDEX_io_allow_1) :
    (cond_182)? ( `CMDEX_OUT_idle) :
    (cond_183)? ( `CMDEX_POPF_STEP_1) :
    (cond_184)? ( `CMDEX_BOUND_STEP_LAST) :
    (cond_185)? ( `CMDEX_task_switch_STEP_2) :
    (cond_186)? ( `CMDEX_task_switch_STEP_3) :
    (cond_187)? ( `CMDEX_task_switch_STEP_4) :
    (cond_188)? ( `CMDEX_task_switch_STEP_5) :
    (cond_189)? ( `CMDEX_task_switch_STEP_6) :
    (cond_190)? ( `CMDEX_task_switch_STEP_6) :
    (cond_191)? ( `CMDEX_task_switch_STEP_6) :
    (cond_192)? ( `CMDEX_task_switch_STEP_7) :
    (cond_193)? ( `CMDEX_task_switch_STEP_8) :
    (cond_194)? ( `CMDEX_task_switch_STEP_9) :
    (cond_195)? ( `CMDEX_task_switch_STEP_9) :
    (cond_196)? ( `CMDEX_task_switch_STEP_10) :
    (cond_197)? ( `CMDEX_task_switch_2_STEP_0) :
    (cond_198)? (  mc_cmdex_last + 4'd1) :
    (cond_199)? ( `CMDEX_task_switch_STEP_11) :
    (cond_200)? ( `CMDEX_task_switch_STEP_12) :
    (cond_201)? ( `CMDEX_task_switch_STEP_13) :
    (cond_202)? ( `CMDEX_task_switch_STEP_14) :
    (cond_203)? ( `CMDEX_task_switch_3_STEP_0) :
    (cond_204)? (  mc_cmdex_last + 4'd1) :
    (cond_205)? ( `CMDEX_task_switch_4_STEP_0) :
    (cond_206)? (  mc_cmdex_last + 4'd1) :
    (cond_207)? (  `CMDEX_SGDT_SIDT_STEP_2) :
    (cond_208)? (  mc_step[3:0]) :
    (cond_209)? ( `CMDEX_POPA_STEP_7) :
    (cond_210)? ( `CMDEX_debug_reg_MOV_load_STEP_1) :
    (cond_211)? ( mc_cmdex_last) :
    4'd0;
assign mc_cmd_current =
    (cond_0)? (   `CMD_XADD) :
    (cond_1)? (   `CMD_CALL) :
    (cond_2)? (   `CMD_CALL) :
    (cond_3)? (   `CMD_CALL) :
    (cond_4)? (   `CMD_CALL) :
    (cond_5)? (   `CMD_CALL) :
    (cond_6)? (   `CMD_CALL) :
    (cond_7)? (   `CMD_CALL) :
    (cond_8)? (   `CMD_load_seg) :
    (cond_9)? (   `CMD_CALL) :
    (cond_10)? (   `CMD_CALL) :
    (cond_11)? (   `CMD_CALL) :
    (cond_12)? (   `CMD_CALL) :
    (cond_13)? (   `CMD_CALL) :
    (cond_14)? (   `CMD_CALL_2) :
    (cond_15)? (   `CMD_CALL_2) :
    (cond_16)? (   `CMD_CALL_2) :
    (cond_17)? (   `CMD_CALL_2) :
    (cond_18)? (   `CMD_task_switch) :
    (cond_19)? (   `CMD_CALL_2) :
    (cond_20)? (   `CMD_CALL_2) :
    (cond_21)? (   `CMD_task_switch) :
    (cond_22)? (   `CMD_CALL_2) :
    (cond_23)? (   `CMD_CALL_2) :
    (cond_24)? (   `CMD_CALL_2) :
    (cond_25)? (   `CMD_CALL_2) :
    (cond_26)? (   `CMD_CALL_2) :
    (cond_27)? (   `CMD_CALL_2) :
    (cond_28)? (   `CMD_CALL_2) :
    (cond_29)? (   `CMD_CALL_3) :
    (cond_30)? (   `CMD_CALL_3) :
    (cond_31)? (   `CMD_CALL_3) :
    (cond_32)? (   `CMD_CALL_3) :
    (cond_33)? (   `CMD_CALL_3) :
    (cond_34)? (   `CMD_CALL_3) :
    (cond_35)? (   `CMD_CALL_3) :
    (cond_36)? (   `CMD_CALL_3) :
    (cond_37)? (   `CMD_CALL_3) :
    (cond_38)? (   `CMD_CALL_3) :
    (cond_39)? (   `CMD_CALL_2) :
    (cond_40)? (   `CMD_CALL_2) :
    (cond_41)? (   `CMD_CALL_2) :
    (cond_42)? (   `CMD_CALL_2) :
    (cond_43)? (   `CMD_INVD) :
    (cond_44)? (   `CMD_INVD) :
    (cond_45)? (   `CMD_INVLPG) :
    (cond_46)? (   `CMD_INVLPG) :
    (cond_47)? (   `CMD_io_allow) :
    (cond_48)? (   mc_saved_command) :
    (cond_49)? (   `CMD_RET_near) :
    (cond_50)? (   `CMD_RET_near) :
    (cond_51)? (   `CMD_LxS) :
    (cond_52)? (   `CMD_LxS) :
    (cond_53)? (   `CMD_load_seg) :
    (cond_54)? (   `CMD_load_seg) :
    (cond_55)? (   `CMD_MOV_to_seg) :
    (cond_56)? (   `CMD_int) :
    (cond_57)? (   `CMD_int) :
    (cond_58)? (   `CMD_int) :
    (cond_59)? (   `CMD_int) :
    (cond_60)? (   `CMD_int) :
    (cond_61)? (   `CMD_int) :
    (cond_62)? (   `CMD_load_seg) :
    (cond_63)? (   `CMD_int) :
    (cond_64)? (   `CMD_int) :
    (cond_65)? (   `CMD_int) :
    (cond_66)? (   `CMD_int) :
    (cond_67)? (   `CMD_int) :
    (cond_68)? (   `CMD_task_switch) :
    (cond_69)? (   `CMD_int) :
    (cond_70)? (   `CMD_int) :
    (cond_71)? (   `CMD_int) :
    (cond_72)? (   `CMD_int_2) :
    (cond_73)? (   `CMD_int_2) :
    (cond_74)? (   `CMD_int_2) :
    (cond_75)? (   `CMD_int_2) :
    (cond_76)? (   `CMD_int_2) :
    (cond_77)? (   `CMD_int_2) :
    (cond_78)? (   `CMD_int_2) :
    (cond_79)? (   `CMD_int_2) :
    (cond_80)? (   `CMD_int_2) :
    (cond_81)? (   `CMD_int_2) :
    (cond_82)? (   `CMD_int_2) :
    (cond_83)? (   `CMD_int_3) :
    (cond_84)? (   `CMD_int_3) :
    (cond_85)? (   `CMD_int_3) :
    (cond_86)? (   `CMD_int_3) :
    (cond_87)? (   `CMD_int_3) :
    (cond_88)? (   `CMD_int_3) :
    (cond_89)? (   `CMD_int_3) :
    (cond_90)? (   `CMD_int_3) :
    (cond_91)? (   `CMD_int_2) :
    (cond_92)? (   `CMD_int_2) :
    (cond_93)? (   `CMD_int_2) :
    (cond_94)? (   `CMD_int_2) :
    (cond_95)? (   `CMD_int_2) :
    (cond_96)? (   `CMD_int_2) :
    (cond_97)? (   `CMD_int_2) :
    (cond_98)? (   mc_saved_command) :
    (cond_99)? (   `CMD_load_seg) :
    (cond_100)? (   `CMD_load_seg) :
    (cond_101)? (   `CMD_IRET) :
    (cond_102)? (   `CMD_IRET) :
    (cond_103)? (   `CMD_load_seg) :
    (cond_104)? (   `CMD_IRET) :
    (cond_105)? (   `CMD_IRET) :
    (cond_106)? (   `CMD_task_switch) :
    (cond_107)? (   `CMD_IRET) :
    (cond_108)? (   `CMD_IRET) :
    (cond_109)? (   `CMD_IRET) :
    (cond_110)? (   `CMD_IRET) :
    (cond_111)? (   `CMD_IRET) :
    (cond_112)? (   `CMD_IRET_2) :
    (cond_113)? (   `CMD_IRET_2) :
    (cond_114)? (   `CMD_load_seg) :
    (cond_115)? (   `CMD_IRET_2) :
    (cond_116)? (   `CMD_IRET_2) :
    (cond_117)? (   `CMD_load_seg) :
    (cond_118)? (   `CMD_IRET_2) :
    (cond_119)? (   `CMD_IRET_2) :
    (cond_120)? (   `CMD_POP) :
    (cond_121)? (   `CMD_CMPS) :
    (cond_122)? (   `CMD_CMPS) :
    (cond_123)? (   `CMD_control_reg) :
    (cond_124)? (   `CMD_control_reg) :
    (cond_125)? (   mc_cmd) :
    (cond_126)? (   mc_cmd) :
    (cond_127)? (   mc_cmd) :
    (cond_128)? (   mc_cmd) :
    (cond_129)? (   `CMD_PUSHA) :
    (cond_130)? (   `CMD_ENTER) :
    (cond_131)? (   `CMD_ENTER) :
    (cond_132)? (   `CMD_ENTER) :
    (cond_133)? (   `CMD_WBINVD) :
    (cond_134)? (   `CMD_WBINVD) :
    (cond_135)? (   `CMD_CLTS) :
    (cond_136)? (   `CMD_RET_far) :
    (cond_137)? (   `CMD_load_seg) :
    (cond_138)? (   `CMD_RET_far) :
    (cond_139)? (   `CMD_RET_far) :
    (cond_140)? (   `CMD_RET_far) :
    (cond_141)? (   `CMD_load_seg) :
    (cond_142)? (   `CMD_RET_far) :
    (cond_143)? (   `CMD_RET_far) :
    (cond_144)? (   `CMD_XCHG) :
    (cond_145)? (   `CMD_int) :
    (cond_146)? (   `CMD_int) :
    (cond_147)? (   `CMD_INT_INTO) :
    (cond_148)? (   `CMD_IN) :
    (cond_149)? (   `CMD_io_allow) :
    (cond_150)? (   `CMD_IN) :
    (cond_151)? (   mc_cmd) :
    (cond_152)? (   mc_cmd) :
    (cond_153)? (   `CMD_INS) :
    (cond_154)? (   `CMD_INS) :
    (cond_155)? (   `CMD_io_allow) :
    (cond_156)? (   `CMD_INS) :
    (cond_157)? (   `CMD_INS) :
    (cond_158)? (   `CMD_OUTS) :
    (cond_159)? (   `CMD_io_allow) :
    (cond_160)? (   `CMD_JMP) :
    (cond_161)? (   `CMD_JMP) :
    (cond_162)? (   `CMD_JMP) :
    (cond_163)? (   `CMD_JMP) :
    (cond_164)? (   `CMD_JMP) :
    (cond_165)? (   `CMD_load_seg) :
    (cond_166)? (   `CMD_JMP) :
    (cond_167)? (   `CMD_JMP) :
    (cond_168)? (   `CMD_JMP) :
    (cond_169)? (   `CMD_JMP) :
    (cond_170)? (   `CMD_JMP) :
    (cond_171)? (   `CMD_JMP) :
    (cond_172)? (   `CMD_task_switch) :
    (cond_173)? (   `CMD_JMP) :
    (cond_174)? (   `CMD_JMP) :
    (cond_175)? (   `CMD_task_switch) :
    (cond_176)? (   `CMD_JMP_2) :
    (cond_177)? (   `CMD_JMP_2) :
    (cond_178)? (   `CMD_JMP_2) :
    (cond_179)? (   `CMD_JMP_2) :
    (cond_180)? (   `CMD_OUT) :
    (cond_181)? (   `CMD_io_allow) :
    (cond_182)? (   `CMD_OUT) :
    (cond_183)? (   `CMD_POPF) :
    (cond_184)? (   `CMD_BOUND) :
    (cond_185)? (   `CMD_task_switch) :
    (cond_186)? (   `CMD_task_switch) :
    (cond_187)? (   `CMD_task_switch) :
    (cond_188)? (   `CMD_task_switch) :
    (cond_189)? (   `CMD_task_switch) :
    (cond_190)? (   `CMD_task_switch) :
    (cond_191)? (   `CMD_task_switch) :
    (cond_192)? (   `CMD_task_switch) :
    (cond_193)? (   `CMD_task_switch) :
    (cond_194)? (   `CMD_task_switch) :
    (cond_195)? (   `CMD_task_switch) :
    (cond_196)? (   `CMD_task_switch) :
    (cond_197)? (   `CMD_task_switch_2) :
    (cond_198)? (   mc_cmd) :
    (cond_199)? (   `CMD_task_switch) :
    (cond_200)? (   `CMD_task_switch) :
    (cond_201)? (   `CMD_task_switch) :
    (cond_202)? (   `CMD_task_switch) :
    (cond_203)? (   `CMD_task_switch_3) :
    (cond_204)? (   mc_cmd) :
    (cond_205)? (   `CMD_task_switch_4) :
    (cond_206)? (   mc_cmd) :
    (cond_207)? (   mc_cmd) :
    (cond_208)? (   mc_cmd) :
    (cond_209)? (   `CMD_POPA) :
    (cond_210)? (   `CMD_debug_reg) :
    (cond_211)? (   mc_cmd) :
    7'd0;
