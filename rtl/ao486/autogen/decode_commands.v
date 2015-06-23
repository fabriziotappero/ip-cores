//======================================================== conditions
wire cond_0 = dec_ready_2byte_modregrm && { decoder[7:1], 1'b0 } == 8'hC0;
wire cond_1 = prefix_group_1_lock  && `DEC_MODREGRM_IS_MOD_11;
wire cond_2 = decoder[0] == 1'b0;
wire cond_3 = dec_ready_one_one && decoder[7:0] == 8'hE3;
wire cond_4 = prefix_group_1_lock ;
wire cond_5 = dec_ready_call_jmp_imm && (decoder[7:0] == 8'h9A || decoder[7:0] == 8'hE8);
wire cond_6 = decoder[1] == 1'b0;
wire cond_7 = dec_ready_modregrm_one && decoder[7:0] == 8'hFF && (decoder[13:11] == 3'd2 || decoder[13:11] == 3'd3);
wire cond_8 = prefix_group_1_lock  || (decoder[13:11] == 3'd3 && `DEC_MODREGRM_IS_MOD_11);
wire cond_9 = decoder[11] == 1'b0;
wire cond_10 = (dec_ready_one && (decoder[7:0] == 8'h06 || decoder[7:0] == 8'h16 || decoder[7:0] == 8'h0E || decoder[7:0] == 8'h1E)) || (dec_ready_2byte_one && (decoder[7:0] == 8'hA0 || decoder[7:0] == 8'hA8));
wire cond_11 = dec_ready_modregrm_one && decoder[7:0] == 8'h8C;
wire cond_12 = prefix_group_1_lock  || decoder[13:11] >= 3'd6;
wire cond_13 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h00 && decoder[13:11] == 3'd0;
wire cond_14 = prefix_group_1_lock  || ~(protected_mode);
wire cond_15 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h00 && decoder[13:11] == 3'd1;
wire cond_16 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'hF6 && decoder[13:11] == 3'd3;
wire cond_17 = (dec_ready_one_one && decoder[7:4] == 4'h7) || (dec_ready_2byte_imm && decoder[7:4] == 4'h8);
wire cond_18 = ~(dec_prefix_2byte);
wire cond_19 = dec_prefix_2byte;
wire cond_20 = dec_ready_2byte_one && decoder[7:0] == 8'h08;
wire cond_21 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h01 && decoder[13:11] == 3'd7;
wire cond_22 = prefix_group_1_lock  || `DEC_MODREGRM_IS_MOD_11;
wire cond_23 = dec_ready_one && decoder[7:0] == 8'hF4;
wire cond_24 = dec_ready_one && { decoder[7:1], 1'b0 } == 8'hAE;
wire cond_25 = dec_prefix_group_1_rep != 2'd0;
wire cond_26 = dec_ready_one && decoder[7:4] == 4'h4;
wire cond_27 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'hFE && { decoder[13:12], 1'b0 } == 3'b000;
wire cond_28 = (dec_ready_one && decoder[7:0] == 8'hC3) || (dec_ready_one_two && decoder[7:0] == 8'hC2);
wire cond_29 = dec_ready_modregrm_one && decoder[7:0] == 8'h63;
wire cond_30 = dec_ready_2byte_one && { decoder[7:3], 3'b000 } == 8'hC8;
wire cond_31 = (dec_ready_modregrm_one && (decoder[7:0] == 8'hC4 || decoder[7:0] == 8'hC5)) || (dec_ready_2byte_modregrm && (decoder[7:0] == 8'hB2 || decoder[7:0] == 8'hB4 || decoder[7:0] == 8'hB5));
wire cond_32 = dec_ready_modregrm_one && decoder[7:0] == 8'h8E;
wire cond_33 = prefix_group_1_lock  || decoder[13:11] >= 3'd6 || decoder[13:11] == 3'd1;
wire cond_34 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h00 && decoder[13:11] == 3'd2;
wire cond_35 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h00 && decoder[13:11] == 3'd3;
wire cond_36 = dec_ready_one && decoder[7:0] == 8'hF8;
wire cond_37 = dec_ready_one && decoder[7:0] == 8'hFC;
wire cond_38 = dec_ready_one && decoder[7:0] == 8'hF5;
wire cond_39 = dec_ready_one && decoder[7:0] == 8'hF9;
wire cond_40 = dec_ready_one && decoder[7:0] == 8'hFD;
wire cond_41 = dec_ready_one && decoder[7:0] == 8'h9E;
wire cond_42 = dec_ready_one_one && decoder[7:0] == 8'hD5;
wire cond_43 = dec_ready_one_one && decoder[7:0] == 8'hD4;
wire cond_44 = (dec_ready_one && (decoder[7:0] == 8'h07 || decoder[7:0] == 8'h17 || decoder[7:0] == 8'h1F)) || (dec_ready_2byte_one && (decoder[7:0] == 8'hA1 || decoder[7:0] == 8'hA9));
wire cond_45 = (dec_ready_2byte_modregrm && decoder[7:0] == 8'hA3) || (dec_ready_2byte_modregrm_imm && decoder[7:0] == 8'hBA && decoder[13:11] == 3'd4);
wire cond_46 = (dec_ready_2byte_modregrm && decoder[7:0] == 8'hB3) || (dec_ready_2byte_modregrm_imm && decoder[7:0] == 8'hBA && decoder[13:11] == 3'd6);
wire cond_47 = (dec_ready_2byte_modregrm && decoder[7:0] == 8'hAB) || (dec_ready_2byte_modregrm_imm && decoder[7:0] == 8'hBA && decoder[13:11] == 3'd5);
wire cond_48 = (dec_ready_2byte_modregrm && decoder[7:0] == 8'hBB) || (dec_ready_2byte_modregrm_imm && decoder[7:0] == 8'hBA && decoder[13:11] == 3'd7);
wire cond_49 = dec_ready_one && decoder[7:0] == 8'hCF;
wire cond_50 = ~(protected_mode);
wire cond_51 = dec_ready_one && { decoder[7:3], 3'b0 } == 8'h58;
wire cond_52 = dec_ready_modregrm_one && decoder[7:0] == 8'h8F && decoder[13:11] == 3'd0;
wire cond_53 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'hF6 && decoder[13:11] == 3'd6;
wire cond_54 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'hF6 && decoder[13:11] == 3'd7;
wire cond_55 = dec_ready_modregrm_one && { decoder[7:2], 2'b0 } == 8'hD0;
wire cond_56 = decoder[1];
wire cond_57 = dec_ready_modregrm_imm && { decoder[7:1], 1'b0 } == 8'hC0;
wire cond_58 = dec_ready_one && { decoder[7:1], 1'b0 } == 8'hA6;
wire cond_59 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h01 && decoder[13:11] == 3'd4;
wire cond_60 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h01 && decoder[13:11] == 3'd6;
wire cond_61 = dec_ready_2byte_modregrm && { decoder[7:2], 1'b0, decoder[0] } == 8'h20;
wire cond_62 = prefix_group_1_lock  || (decoder[13:11] != 3'd0 && decoder[13:11] != 3'd2 && decoder[13:11] != 3'd3);
wire cond_63 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h01 && decoder[13:11] == 3'd2;
wire cond_64 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h01 && decoder[13:11] == 3'd3;
wire cond_65 = dec_ready_one && decoder[7:0] == 8'h60;
wire cond_66 = dec_ready_one && decoder[7:0] == 8'h9B;
wire cond_67 = dec_ready_modregrm_one && { decoder[7:3], 3'b0 } == 8'hD8;
wire cond_68 = dec_ready_2byte_modregrm && decoder[7:4] == 4'h9;
wire cond_69 = dec_ready_2byte_modregrm && { decoder[7:1], 1'b0 } == 8'hB0;
wire cond_70 = dec_ready_one_three && decoder[7:0] == 8'hC8;
wire cond_71 = (dec_ready_modregrm_one && ({ decoder[7:1], 1'b0 } == 8'hF6 && decoder[13:11] == 3'd5)) || (dec_ready_2byte_modregrm && decoder[7:0] == 8'hAF);
wire cond_72 = dec_ready_modregrm_imm && (decoder[7:0] == 8'h69 || decoder[7:0] == 8'h6B);
wire cond_73 = dec_ready_one && decoder[7:0] == 8'hC9;
wire cond_74 = (dec_ready_2byte_modregrm && decoder[7:0] == 8'hA5) || (dec_ready_2byte_modregrm_imm && decoder[7:0] == 8'hA4);
wire cond_75 = decoder[0];
wire cond_76 = (dec_ready_2byte_modregrm && decoder[7:0] == 8'hAD) || (dec_ready_2byte_modregrm_imm && decoder[7:0] == 8'hAC);
wire cond_77 = dec_ready_2byte_one && decoder[7:0] == 8'h09;
wire cond_78 = dec_ready_one_imm && decoder[7:6] == 2'b00 && decoder[2:1] == 2'b10;
wire cond_79 = dec_ready_modregrm_one && decoder[7:6] == 2'b00 && decoder[2] == 1'b0;
wire cond_80 = prefix_group_1_lock  && (decoder[1] == 1'b1 || `DEC_MODREGRM_IS_MOD_11 || decoder[5:3] == 3'b111);
wire cond_81 = dec_ready_modregrm_imm && { decoder[7:2], 2'b00 } == 8'h80;
wire cond_82 = prefix_group_1_lock  && (decoder[13:11] == 3'b111 || `DEC_MODREGRM_IS_MOD_11);
wire cond_83 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'hF6 && decoder[13:11] == 3'd4;
wire cond_84 = dec_ready_one_one && (decoder[7:0] == 8'hE0 || decoder[7:0] == 8'hE1 || decoder[7:0] == 8'hE2);
wire cond_85 = dec_ready_one_imm && { decoder[7:1], 1'b0 } == 8'hA8;
wire cond_86 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'h84;
wire cond_87 = dec_ready_modregrm_imm && { decoder[7:1], 1'b0 } == 8'hF6 && { decoder[13:12], 1'b0 } == 3'd0;
wire cond_88 = dec_ready_2byte_one && decoder[7:0] == 8'h06;
wire cond_89 = (dec_ready_one && decoder[7:0] == 8'hCB) || (dec_ready_one_two && decoder[7:0] == 8'hCA);
wire cond_90 = dec_ready_one && { decoder[7:1], 1'b0 } == 8'hAC;
wire cond_91 = dec_ready_one && { decoder[7:3], 3'b0 } == 8'h90;
wire cond_92 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'h86;
wire cond_93 = dec_ready_one && { decoder[7:3], 3'b0 } == 8'h50;
wire cond_94 = dec_ready_one_imm && (decoder[7:0] == 8'h6A || decoder[7:0] == 8'h68);
wire cond_95 = dec_ready_modregrm_one && decoder[7:0] == 8'hFF && decoder[13:11] == 3'd6;
wire cond_96 = (dec_ready_one && (decoder[7:0] == 8'hCC || decoder[7:0] == 8'hCE || decoder[7:0] == 8'hF1)) || (dec_ready_one_one && decoder[7:0] == 8'hCD);
wire cond_97 = (decoder[0] ^ decoder[2]) == 1'b1;
wire cond_98 = dec_ready_2byte_one && decoder[7:0] == 8'hA2;
wire cond_99 = (dec_ready_one && { decoder[7:1], 1'b0 } == 8'hEC) || (dec_ready_one_one && { decoder[7:1], 1'b0 } == 8'hE4);
wire cond_100 = decoder[3];
wire cond_101 = decoder[3] == 1'b1;
wire cond_102 = dec_ready_modregrm_one && { decoder[7:1], 1'b0 } == 8'hF6 && decoder[13:11] == 3'd2;
wire cond_103 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h00 && decoder[13:11] == 3'd4;
wire cond_104 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h00 && decoder[13:11] == 3'd5;
wire cond_105 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h02;
wire cond_106 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h03;
wire cond_107 = dec_ready_one && { decoder[7:1], 1'b0 } == 8'hAA;
wire cond_108 = dec_ready_one && { decoder[7:1], 1'b0 } == 8'h6C;
wire cond_109 = dec_ready_one && { decoder[7:1], 1'b0 } == 8'h6E;
wire cond_110 = dec_ready_one && decoder[7:0] == 8'h9C;
wire cond_111 = dec_ready_call_jmp_imm && (decoder[7:0] == 8'hEA || decoder[7:0] == 8'hE9 || decoder[7:0] == 8'hEB);
wire cond_112 = decoder[3:0] == 4'hB;
wire cond_113 = dec_ready_modregrm_one && decoder[7:0] == 8'hFF && (decoder[13:11] == 3'd4 || decoder[13:11] == 3'd5);
wire cond_114 = prefix_group_1_lock  || (decoder[13:11] == 3'd5 && `DEC_MODREGRM_IS_MOD_11);
wire cond_115 = (dec_ready_one && { decoder[7:1], 1'b0 } == 8'hEE) || (dec_ready_one_one && { decoder[7:1], 1'b0 } == 8'hE6);
wire cond_116 = dec_ready_mem_offset && { decoder[7:2], 2'b0 } == 8'hA0;
wire cond_117 = dec_ready_one_imm && decoder[7:4] == 4'hB;
wire cond_118 = decoder[3] == 1'b0;
wire cond_119 = dec_ready_modregrm_one && { decoder[7:2], 2'b0 } == 8'h88;
wire cond_120 = dec_ready_modregrm_imm && { decoder[7:1], 1'b0 } == 8'hC6 && decoder[13:11] == 3'd0;
wire cond_121 = dec_ready_one && decoder[7:0] == 8'h9F;
wire cond_122 = dec_ready_one && decoder[7:0] == 8'h98;
wire cond_123 = dec_ready_one && decoder[7:0] == 8'h99;
wire cond_124 = dec_ready_one && decoder[7:0] == 8'h9D;
wire cond_125 = dec_ready_one && decoder[7:0] == 8'hFA;
wire cond_126 = dec_ready_one && decoder[7:0] == 8'hFB;
wire cond_127 = dec_ready_modregrm_one && decoder[7:0] == 8'h62;
wire cond_128 = dec_ready_one && decoder[7:0] == 8'hD6;
wire cond_129 = dec_ready_modregrm_one && decoder[7:0] == 8'h8D;
wire cond_130 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h01 && decoder[13:11] == 3'd0;
wire cond_131 = dec_ready_2byte_modregrm && decoder[7:0] == 8'h01 && decoder[13:11] == 3'd1;
wire cond_132 = dec_ready_one && { decoder[7:1], 1'b0 } == 8'hA4;
wire cond_133 = dec_ready_2byte_modregrm && { decoder[7:1], 1'b0 } == 8'hB6;
wire cond_134 = dec_ready_2byte_modregrm && { decoder[7:1], 1'b0 } == 8'hBE;
wire cond_135 = dec_ready_one && decoder[7:0] == 8'h61;
wire cond_136 = dec_ready_2byte_modregrm && { decoder[7:2], 1'b0, decoder[0] } == 8'h21;
wire cond_137 = dec_ready_one && decoder[7:0] == 8'hD7;
wire cond_138 = dec_ready_one && decoder[7:0] == 8'h37;
wire cond_139 = dec_ready_one && decoder[7:0] == 8'h3F;
wire cond_140 = dec_ready_one && decoder[7:0] == 8'h27;
wire cond_141 = dec_ready_one && decoder[7:0] == 8'h2F;
wire cond_142 = dec_ready_2byte_modregrm && decoder[7:0] == 8'hBC;
wire cond_143 = dec_ready_2byte_modregrm && decoder[7:0] == 8'hBD;
//======================================================== saves
//======================================================== always
//======================================================== sets
assign consume_mem_offset =
    (cond_116 && ~cond_4)? (`TRUE) :
    1'd0;
assign dec_cmd =
    (cond_0 && ~cond_1)? ( `CMD_XADD) :
    (cond_3 && ~cond_4)? ( `CMD_JCXZ) :
    (cond_5 && ~cond_4)? ( `CMD_CALL) :
    (cond_7 && ~cond_8)? ( `CMD_CALL) :
    (cond_10 && ~cond_4)? ( `CMD_PUSH_MOV_SEG) :
    (cond_11 && ~cond_12)? ( `CMD_PUSH_MOV_SEG) :
    (cond_13 && ~cond_14)? ( `CMD_PUSH_MOV_SEG) :
    (cond_15 && ~cond_14)? ( `CMD_PUSH_MOV_SEG) :
    (cond_16 && ~cond_1)? ( `CMD_NEG) :
    (cond_17 && ~cond_4)? ( `CMD_Jcc) :
    (cond_20 && ~cond_4)? ( `CMD_INVD) :
    (cond_21 && ~cond_22)? ( `CMD_INVLPG) :
    (cond_23 && ~cond_4)? ( `CMD_HLT) :
    (cond_24 && ~cond_4)? ( `CMD_SCAS) :
    (cond_26 && ~cond_4)? ( `CMD_INC_DEC) :
    (cond_27 && ~cond_1)? ( `CMD_INC_DEC) :
    (cond_28 && ~cond_4)? ( `CMD_RET_near) :
    (cond_29 && ~cond_14)? ( `CMD_ARPL) :
    (cond_30 && ~cond_4)? ( `CMD_BSWAP) :
    (cond_31 && ~cond_22)? ( `CMD_LxS) :
    (cond_32 && ~cond_33)? ( `CMD_MOV_to_seg) :
    (cond_34 && ~cond_14)? ( `CMD_LLDT) :
    (cond_35 && ~cond_14)? ( `CMD_LTR) :
    (cond_36 && ~cond_4)? ( `CMD_CLC) :
    (cond_37 && ~cond_4)? ( `CMD_CLD) :
    (cond_38 && ~cond_4)? ( `CMD_CMC) :
    (cond_39 && ~cond_4)? ( `CMD_STC) :
    (cond_40 && ~cond_4)? ( `CMD_STD) :
    (cond_41 && ~cond_4)? ( `CMD_SAHF) :
    (cond_42 && ~cond_4)? ( `CMD_AAD) :
    (cond_43 && ~cond_4)? ( `CMD_AAM) :
    (cond_44 && ~cond_4)? ( `CMD_POP_seg) :
    (cond_45 && ~cond_4)? ( `CMD_BT) :
    (cond_46 && ~cond_1)? ( `CMD_BTR) :
    (cond_47 && ~cond_1)? ( `CMD_BTS) :
    (cond_48 && ~cond_1)? ( `CMD_BTC) :
    (cond_49 && ~cond_4)? ( `CMD_IRET) :
    (cond_51 && ~cond_4)? ( `CMD_POP) :
    (cond_52 && ~cond_4)? ( `CMD_POP) :
    (cond_53 && ~cond_4)? ( `CMD_DIV) :
    (cond_54 && ~cond_4)? ( `CMD_IDIV) :
    (cond_55 && ~cond_4)? ( `CMD_Shift) :
    (cond_57 && ~cond_4)? ( `CMD_Shift) :
    (cond_58 && ~cond_4)? ( `CMD_CMPS) :
    (cond_59 && ~cond_4)? ( `CMD_control_reg) :
    (cond_60 && ~cond_4)? ( `CMD_control_reg) :
    (cond_61 && ~cond_62)? ( `CMD_control_reg) :
    (cond_63 && ~cond_22)? ( `CMD_LGDT) :
    (cond_64 && ~cond_22)? ( `CMD_LIDT) :
    (cond_65 && ~cond_4)? ( `CMD_PUSHA) :
    (cond_66 && ~cond_4)? ( `CMD_fpu) :
    (cond_67 && ~cond_4)? ( `CMD_fpu) :
    (cond_68 && ~cond_4)? ( `CMD_SETcc) :
    (cond_69 && ~cond_1)? ( `CMD_CMPXCHG) :
    (cond_70 && ~cond_4)? ( `CMD_ENTER) :
    (cond_71 && ~cond_4)? ( `CMD_IMUL) :
    (cond_72 && ~cond_4)? ( `CMD_IMUL) :
    (cond_73 && ~cond_4)? ( `CMD_LEAVE) :
    (cond_74 && ~cond_4)? ( `CMD_SHLD) :
    (cond_76 && ~cond_4)? ( `CMD_SHRD) :
    (cond_77 && ~cond_4)? ( `CMD_WBINVD) :
    (cond_78 && ~cond_4)? ( {`CMD_Arith | { 4'd0, decoder[5:3] } }) :
    (cond_79 && ~cond_80)? ( {`CMD_Arith | { 4'd0, decoder[5:3] } }) :
    (cond_81 && ~cond_82)? ( {`CMD_Arith | { 4'd0, decoder[13:11] } }) :
    (cond_83 && ~cond_4)? ( `CMD_MUL) :
    (cond_84 && ~cond_4)? ( `CMD_LOOP) :
    (cond_85 && ~cond_4)? ( `CMD_TEST) :
    (cond_86 && ~cond_4)? ( `CMD_TEST) :
    (cond_87 && ~cond_4)? ( `CMD_TEST) :
    (cond_88 && ~cond_4)? ( `CMD_CLTS) :
    (cond_89 && ~cond_4)? ( `CMD_RET_far) :
    (cond_90 && ~cond_4)? ( `CMD_LODS) :
    (cond_91 && ~cond_4)? ( `CMD_XCHG) :
    (cond_92 && ~cond_1)? ( `CMD_XCHG) :
    (cond_93 && ~cond_4)? ( `CMD_PUSH) :
    (cond_94 && ~cond_4)? ( `CMD_PUSH) :
    (cond_95 && ~cond_4)? ( `CMD_PUSH) :
    (cond_96 && ~cond_4)? ( `CMD_INT_INTO) :
    (cond_98 && ~cond_4)? ( `CMD_CPUID) :
    (cond_99 && ~cond_4)? ( `CMD_IN) :
    (cond_102 && ~cond_1)? ( `CMD_NOT) :
    (cond_103 && ~cond_14)? ( `CMD_VERR) :
    (cond_104 && ~cond_14)? ( `CMD_VERW) :
    (cond_105 && ~cond_14)? ( `CMD_LAR) :
    (cond_106 && ~cond_14)? ( `CMD_LSL) :
    (cond_107 && ~cond_4)? ( `CMD_STOS) :
    (cond_108 && ~cond_4)? ( `CMD_INS) :
    (cond_109 && ~cond_4)? ( `CMD_OUTS) :
    (cond_110 && ~cond_4)? ( `CMD_PUSHF) :
    (cond_111 && ~cond_4)? ( `CMD_JMP) :
    (cond_113 && ~cond_114)? ( `CMD_JMP) :
    (cond_115 && ~cond_4)? ( `CMD_OUT) :
    (cond_116 && ~cond_4)? ( `CMD_MOV) :
    (cond_117 && ~cond_4)? ( `CMD_MOV) :
    (cond_119 && ~cond_4)? ( `CMD_MOV) :
    (cond_120 && ~cond_4)? ( `CMD_MOV) :
    (cond_121 && ~cond_4)? ( `CMD_LAHF) :
    (cond_122 && ~cond_4)? ( `CMD_CBW) :
    (cond_123 && ~cond_4)? ( `CMD_CWD) :
    (cond_124 && ~cond_4)? ( `CMD_POPF) :
    (cond_125 && ~cond_4)? ( `CMD_CLI) :
    (cond_126 && ~cond_4)? ( `CMD_STI) :
    (cond_127 && ~cond_22)? ( `CMD_BOUND) :
    (cond_128 && ~cond_4)? ( `CMD_SALC) :
    (cond_129 && ~cond_22)? ( `CMD_LEA) :
    (cond_130 && ~cond_22)? ( `CMD_SGDT) :
    (cond_131 && ~cond_22)? ( `CMD_SIDT) :
    (cond_132 && ~cond_4)? ( `CMD_MOVS) :
    (cond_133 && ~cond_4)? ( `CMD_MOVZX) :
    (cond_134 && ~cond_4)? ( `CMD_MOVSX) :
    (cond_135 && ~cond_4)? ( `CMD_POPA) :
    (cond_136 && ~cond_4)? ( `CMD_debug_reg) :
    (cond_137 && ~cond_4)? ( `CMD_XLAT) :
    (cond_138 && ~cond_4)? ( `CMD_AAA) :
    (cond_139 && ~cond_4)? ( `CMD_AAS) :
    (cond_140 && ~cond_4)? ( `CMD_DAA) :
    (cond_141 && ~cond_4)? ( `CMD_DAS) :
    (cond_142 && ~cond_4)? ( `CMD_BSF) :
    (cond_143 && ~cond_4)? ( `CMD_BSR) :
    7'd0;
assign dec_is_complex =
    (cond_0 && ~cond_1)? (`TRUE) :
    (cond_5 && ~cond_4)? (`TRUE) :
    (cond_7 && ~cond_8)? (`TRUE) :
    (cond_20 && ~cond_4)? (`TRUE) :
    (cond_21 && ~cond_22)? (`TRUE) :
    (cond_23 && ~cond_4)? (`TRUE) :
    (cond_24 && ~cond_4 && cond_25)? (`TRUE) :
    (cond_28 && ~cond_4)? (`TRUE) :
    (cond_31 && ~cond_22)? (`TRUE) :
    (cond_32 && ~cond_33)? (`TRUE) :
    (cond_34 && ~cond_14)? (`TRUE) :
    (cond_35 && ~cond_14)? (`TRUE) :
    (cond_44 && ~cond_4)? (`TRUE) :
    (cond_49 && ~cond_4)? (`TRUE) :
    (cond_52 && ~cond_4)? (`TRUE) :
    (cond_58 && ~cond_4)? (`TRUE) :
    (cond_60 && ~cond_4)? (`TRUE) :
    (cond_61 && ~cond_62 && cond_56)? (`TRUE) :
    (cond_63 && ~cond_22)? (`TRUE) :
    (cond_64 && ~cond_22)? (`TRUE) :
    (cond_65 && ~cond_4)? (`TRUE) :
    (cond_70 && ~cond_4)? (`TRUE) :
    (cond_77 && ~cond_4)? (`TRUE) :
    (cond_88 && ~cond_4)? (`TRUE) :
    (cond_89 && ~cond_4)? (`TRUE) :
    (cond_90 && ~cond_4 && cond_25)? (`TRUE) :
    (cond_92 && ~cond_1)? (`TRUE) :
    (cond_96 && ~cond_4)? (`TRUE) :
    (cond_98 && ~cond_4)? (`TRUE) :
    (cond_99 && ~cond_4)? (`TRUE) :
    (cond_103 && ~cond_14)? (`TRUE) :
    (cond_104 && ~cond_14)? (`TRUE) :
    (cond_105 && ~cond_14)? (`TRUE) :
    (cond_106 && ~cond_14)? (`TRUE) :
    (cond_107 && ~cond_4 && cond_25)? (`TRUE) :
    (cond_108 && ~cond_4)? (`TRUE) :
    (cond_109 && ~cond_4)? (`TRUE) :
    (cond_111 && ~cond_4)? (`TRUE) :
    (cond_113 && ~cond_114)? (`TRUE) :
    (cond_115 && ~cond_4)? (`TRUE) :
    (cond_124 && ~cond_4)? (`TRUE) :
    (cond_127 && ~cond_22)? (`TRUE) :
    (cond_130 && ~cond_22)? (`TRUE) :
    (cond_131 && ~cond_22)? (`TRUE) :
    (cond_132 && ~cond_4 && cond_25)? (`TRUE) :
    (cond_135 && ~cond_4)? (`TRUE) :
    (cond_136 && ~cond_4 && cond_56)? (`TRUE) :
    1'd0;
assign consume_one_two =
    (cond_28 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_89 && ~cond_4 && cond_2)? (`TRUE) :
    1'd0;
assign consume_modregrm_imm =
    (cond_45 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_46 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_47 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_48 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_57 && ~cond_4)? (`TRUE) :
    (cond_72 && ~cond_4)? (`TRUE) :
    (cond_74 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_76 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_81 && ~cond_82)? (`TRUE) :
    (cond_87 && ~cond_4)? (`TRUE) :
    (cond_120 && ~cond_4)? (`TRUE) :
    1'd0;
assign consume_one =
    (cond_10 && ~cond_4)? (`TRUE) :
    (cond_20 && ~cond_4)? (`TRUE) :
    (cond_23 && ~cond_4)? (`TRUE) :
    (cond_24 && ~cond_4)? (`TRUE) :
    (cond_26 && ~cond_4)? (`TRUE) :
    (cond_28 && ~cond_4 && ~cond_2)? (`TRUE) :
    (cond_30 && ~cond_4)? (`TRUE) :
    (cond_36 && ~cond_4)? (`TRUE) :
    (cond_37 && ~cond_4)? (`TRUE) :
    (cond_38 && ~cond_4)? (`TRUE) :
    (cond_39 && ~cond_4)? (`TRUE) :
    (cond_40 && ~cond_4)? (`TRUE) :
    (cond_41 && ~cond_4)? (`TRUE) :
    (cond_44 && ~cond_4)? (`TRUE) :
    (cond_49 && ~cond_4)? (`TRUE) :
    (cond_51 && ~cond_4)? (`TRUE) :
    (cond_58 && ~cond_4)? (`TRUE) :
    (cond_65 && ~cond_4)? (`TRUE) :
    (cond_66 && ~cond_4)? (`TRUE) :
    (cond_73 && ~cond_4)? (`TRUE) :
    (cond_77 && ~cond_4)? (`TRUE) :
    (cond_88 && ~cond_4)? (`TRUE) :
    (cond_89 && ~cond_4 && ~cond_2)? (`TRUE) :
    (cond_90 && ~cond_4)? (`TRUE) :
    (cond_91 && ~cond_4)? (`TRUE) :
    (cond_93 && ~cond_4)? (`TRUE) :
    (cond_96 && ~cond_4 && cond_97)? (`TRUE) :
    (cond_98 && ~cond_4)? (`TRUE) :
    (cond_99 && ~cond_4 && cond_101)? (`TRUE) :
    (cond_107 && ~cond_4)? (`TRUE) :
    (cond_108 && ~cond_4)? (`TRUE) :
    (cond_109 && ~cond_4)? (`TRUE) :
    (cond_110 && ~cond_4)? (`TRUE) :
    (cond_115 && ~cond_4 && cond_101)? (`TRUE) :
    (cond_121 && ~cond_4)? (`TRUE) :
    (cond_122 && ~cond_4)? (`TRUE) :
    (cond_123 && ~cond_4)? (`TRUE) :
    (cond_124 && ~cond_4)? (`TRUE) :
    (cond_125 && ~cond_4)? (`TRUE) :
    (cond_126 && ~cond_4)? (`TRUE) :
    (cond_128 && ~cond_4)? (`TRUE) :
    (cond_132 && ~cond_4)? (`TRUE) :
    (cond_135 && ~cond_4)? (`TRUE) :
    (cond_137 && ~cond_4)? (`TRUE) :
    (cond_138 && ~cond_4)? (`TRUE) :
    (cond_139 && ~cond_4)? (`TRUE) :
    (cond_140 && ~cond_4)? (`TRUE) :
    (cond_141 && ~cond_4)? (`TRUE) :
    1'd0;
assign consume_one_one =
    (cond_3 && ~cond_4)? (`TRUE) :
    (cond_17 && ~cond_4 && ~cond_19)? (`TRUE) :
    (cond_42 && ~cond_4)? (`TRUE) :
    (cond_43 && ~cond_4)? (`TRUE) :
    (cond_84 && ~cond_4)? (`TRUE) :
    (cond_96 && ~cond_4 && ~cond_97)? (`TRUE) :
    (cond_99 && ~cond_4 && ~cond_101)? (`TRUE) :
    (cond_115 && ~cond_4 && ~cond_101)? (`TRUE) :
    1'd0;
assign exception_ud =
    (cond_0 && cond_1)? (`TRUE) :
    (cond_3 && cond_4)? (`TRUE) :
    (cond_5 && cond_4)? (`TRUE) :
    (cond_7 && cond_8)? (`TRUE) :
    (cond_10 && cond_4)? (`TRUE) :
    (cond_11 && cond_12)? (`TRUE) :
    (cond_13 && cond_14)? (`TRUE) :
    (cond_15 && cond_14)? (`TRUE) :
    (cond_16 && cond_1)? (`TRUE) :
    (cond_17 && cond_4)? (`TRUE) :
    (cond_20 && cond_4)? (`TRUE) :
    (cond_21 && cond_22)? (`TRUE) :
    (cond_23 && cond_4)? (`TRUE) :
    (cond_24 && cond_4)? (`TRUE) :
    (cond_26 && cond_4)? (`TRUE) :
    (cond_27 && cond_1)? (`TRUE) :
    (cond_28 && cond_4)? (`TRUE) :
    (cond_29 && cond_14)? (`TRUE) :
    (cond_30 && cond_4)? (`TRUE) :
    (cond_31 && cond_22)? (`TRUE) :
    (cond_32 && cond_33)? (`TRUE) :
    (cond_34 && cond_14)? (`TRUE) :
    (cond_35 && cond_14)? (`TRUE) :
    (cond_36 && cond_4)? (`TRUE) :
    (cond_37 && cond_4)? (`TRUE) :
    (cond_38 && cond_4)? (`TRUE) :
    (cond_39 && cond_4)? (`TRUE) :
    (cond_40 && cond_4)? (`TRUE) :
    (cond_41 && cond_4)? (`TRUE) :
    (cond_42 && cond_4)? (`TRUE) :
    (cond_43 && cond_4)? (`TRUE) :
    (cond_44 && cond_4)? (`TRUE) :
    (cond_45 && cond_4)? (`TRUE) :
    (cond_46 && cond_1)? (`TRUE) :
    (cond_47 && cond_1)? (`TRUE) :
    (cond_48 && cond_1)? (`TRUE) :
    (cond_49 && cond_4)? (`TRUE) :
    (cond_51 && cond_4)? (`TRUE) :
    (cond_52 && cond_4)? (`TRUE) :
    (cond_53 && cond_4)? (`TRUE) :
    (cond_54 && cond_4)? (`TRUE) :
    (cond_55 && cond_4)? (`TRUE) :
    (cond_57 && cond_4)? (`TRUE) :
    (cond_58 && cond_4)? (`TRUE) :
    (cond_59 && cond_4)? (`TRUE) :
    (cond_60 && cond_4)? (`TRUE) :
    (cond_61 && cond_62)? (`TRUE) :
    (cond_63 && cond_22)? (`TRUE) :
    (cond_64 && cond_22)? (`TRUE) :
    (cond_65 && cond_4)? (`TRUE) :
    (cond_66 && cond_4)? (`TRUE) :
    (cond_67 && cond_4)? (`TRUE) :
    (cond_68 && cond_4)? (`TRUE) :
    (cond_69 && cond_1)? (`TRUE) :
    (cond_70 && cond_4)? (`TRUE) :
    (cond_71 && cond_4)? (`TRUE) :
    (cond_72 && cond_4)? (`TRUE) :
    (cond_73 && cond_4)? (`TRUE) :
    (cond_74 && cond_4)? (`TRUE) :
    (cond_76 && cond_4)? (`TRUE) :
    (cond_77 && cond_4)? (`TRUE) :
    (cond_78 && cond_4)? (`TRUE) :
    (cond_79 && cond_80)? (`TRUE) :
    (cond_81 && cond_82)? (`TRUE) :
    (cond_83 && cond_4)? (`TRUE) :
    (cond_84 && cond_4)? (`TRUE) :
    (cond_85 && cond_4)? (`TRUE) :
    (cond_86 && cond_4)? (`TRUE) :
    (cond_87 && cond_4)? (`TRUE) :
    (cond_88 && cond_4)? (`TRUE) :
    (cond_89 && cond_4)? (`TRUE) :
    (cond_90 && cond_4)? (`TRUE) :
    (cond_91 && cond_4)? (`TRUE) :
    (cond_92 && cond_1)? (`TRUE) :
    (cond_93 && cond_4)? (`TRUE) :
    (cond_94 && cond_4)? (`TRUE) :
    (cond_95 && cond_4)? (`TRUE) :
    (cond_96 && cond_4)? (`TRUE) :
    (cond_98 && cond_4)? (`TRUE) :
    (cond_99 && cond_4)? (`TRUE) :
    (cond_102 && cond_1)? (`TRUE) :
    (cond_103 && cond_14)? (`TRUE) :
    (cond_104 && cond_14)? (`TRUE) :
    (cond_105 && cond_14)? (`TRUE) :
    (cond_106 && cond_14)? (`TRUE) :
    (cond_107 && cond_4)? (`TRUE) :
    (cond_108 && cond_4)? (`TRUE) :
    (cond_109 && cond_4)? (`TRUE) :
    (cond_110 && cond_4)? (`TRUE) :
    (cond_111 && cond_4)? (`TRUE) :
    (cond_113 && cond_114)? (`TRUE) :
    (cond_115 && cond_4)? (`TRUE) :
    (cond_116 && cond_4)? (`TRUE) :
    (cond_117 && cond_4)? (`TRUE) :
    (cond_119 && cond_4)? (`TRUE) :
    (cond_120 && cond_4)? (`TRUE) :
    (cond_121 && cond_4)? (`TRUE) :
    (cond_122 && cond_4)? (`TRUE) :
    (cond_123 && cond_4)? (`TRUE) :
    (cond_124 && cond_4)? (`TRUE) :
    (cond_125 && cond_4)? (`TRUE) :
    (cond_126 && cond_4)? (`TRUE) :
    (cond_127 && cond_22)? (`TRUE) :
    (cond_128 && cond_4)? (`TRUE) :
    (cond_129 && cond_22)? (`TRUE) :
    (cond_130 && cond_22)? (`TRUE) :
    (cond_131 && cond_22)? (`TRUE) :
    (cond_132 && cond_4)? (`TRUE) :
    (cond_133 && cond_4)? (`TRUE) :
    (cond_134 && cond_4)? (`TRUE) :
    (cond_135 && cond_4)? (`TRUE) :
    (cond_136 && cond_4)? (`TRUE) :
    (cond_137 && cond_4)? (`TRUE) :
    (cond_138 && cond_4)? (`TRUE) :
    (cond_139 && cond_4)? (`TRUE) :
    (cond_140 && cond_4)? (`TRUE) :
    (cond_141 && cond_4)? (`TRUE) :
    (cond_142 && cond_4)? (`TRUE) :
    (cond_143 && cond_4)? (`TRUE) :
    1'd0;
assign consume_one_imm =
    (cond_17 && ~cond_4 && cond_19)? (`TRUE) :
    (cond_78 && ~cond_4)? (`TRUE) :
    (cond_85 && ~cond_4)? (`TRUE) :
    (cond_94 && ~cond_4)? (`TRUE) :
    (cond_117 && ~cond_4)? (`TRUE) :
    1'd0;
assign consume_call_jmp_imm =
    (cond_5 && ~cond_4)? (`TRUE) :
    (cond_111 && ~cond_4)? (`TRUE) :
    1'd0;
assign consume_modregrm_one =
    (cond_0 && ~cond_1)? (`TRUE) :
    (cond_7 && ~cond_8)? (`TRUE) :
    (cond_11 && ~cond_12)? (`TRUE) :
    (cond_13 && ~cond_14)? (`TRUE) :
    (cond_15 && ~cond_14)? (`TRUE) :
    (cond_16 && ~cond_1)? (`TRUE) :
    (cond_21 && ~cond_22)? (`TRUE) :
    (cond_27 && ~cond_1)? (`TRUE) :
    (cond_29 && ~cond_14)? (`TRUE) :
    (cond_31 && ~cond_22)? (`TRUE) :
    (cond_32 && ~cond_33)? (`TRUE) :
    (cond_34 && ~cond_14)? (`TRUE) :
    (cond_35 && ~cond_14)? (`TRUE) :
    (cond_45 && ~cond_4 && ~cond_2)? (`TRUE) :
    (cond_46 && ~cond_1 && ~cond_2)? (`TRUE) :
    (cond_47 && ~cond_1 && ~cond_2)? (`TRUE) :
    (cond_48 && ~cond_1 && ~cond_2)? (`TRUE) :
    (cond_52 && ~cond_4)? (`TRUE) :
    (cond_53 && ~cond_4)? (`TRUE) :
    (cond_54 && ~cond_4)? (`TRUE) :
    (cond_55 && ~cond_4)? (`TRUE) :
    (cond_59 && ~cond_4)? (`TRUE) :
    (cond_60 && ~cond_4)? (`TRUE) :
    (cond_61 && ~cond_62)? (`TRUE) :
    (cond_63 && ~cond_22)? (`TRUE) :
    (cond_64 && ~cond_22)? (`TRUE) :
    (cond_67 && ~cond_4)? (`TRUE) :
    (cond_68 && ~cond_4)? (`TRUE) :
    (cond_69 && ~cond_1)? (`TRUE) :
    (cond_71 && ~cond_4)? (`TRUE) :
    (cond_74 && ~cond_4 && ~cond_2)? (`TRUE) :
    (cond_76 && ~cond_4 && ~cond_2)? (`TRUE) :
    (cond_79 && ~cond_80)? (`TRUE) :
    (cond_83 && ~cond_4)? (`TRUE) :
    (cond_86 && ~cond_4)? (`TRUE) :
    (cond_92 && ~cond_1)? (`TRUE) :
    (cond_95 && ~cond_4)? (`TRUE) :
    (cond_102 && ~cond_1)? (`TRUE) :
    (cond_103 && ~cond_14)? (`TRUE) :
    (cond_104 && ~cond_14)? (`TRUE) :
    (cond_105 && ~cond_14)? (`TRUE) :
    (cond_106 && ~cond_14)? (`TRUE) :
    (cond_113 && ~cond_114)? (`TRUE) :
    (cond_119 && ~cond_4)? (`TRUE) :
    (cond_127 && ~cond_22)? (`TRUE) :
    (cond_129 && ~cond_22)? (`TRUE) :
    (cond_130 && ~cond_22)? (`TRUE) :
    (cond_131 && ~cond_22)? (`TRUE) :
    (cond_133 && ~cond_4)? (`TRUE) :
    (cond_134 && ~cond_4)? (`TRUE) :
    (cond_136 && ~cond_4)? (`TRUE) :
    (cond_142 && ~cond_4)? (`TRUE) :
    (cond_143 && ~cond_4)? (`TRUE) :
    1'd0;
assign consume_one_three =
    (cond_70 && ~cond_4)? (`TRUE) :
    1'd0;
assign dec_is_8bit =
    (cond_0 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_3 && ~cond_4)? (`TRUE) :
    (cond_16 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_17 && ~cond_4 && cond_18)? (`TRUE) :
    (cond_24 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_27 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_42 && ~cond_4)? (`TRUE) :
    (cond_43 && ~cond_4)? (`TRUE) :
    (cond_53 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_54 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_55 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_57 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_58 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_68 && ~cond_4)? (`TRUE) :
    (cond_69 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_71 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_78 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_79 && ~cond_80 && cond_2)? (`TRUE) :
    (cond_81 && ~cond_82 && cond_2)? (`TRUE) :
    (cond_83 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_84 && ~cond_4)? (`TRUE) :
    (cond_85 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_86 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_87 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_90 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_92 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_99 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_102 && ~cond_1 && cond_2)? (`TRUE) :
    (cond_107 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_108 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_109 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_111 && ~cond_4 && cond_112)? (`TRUE) :
    (cond_115 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_116 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_117 && ~cond_4 && cond_118)? (`TRUE) :
    (cond_119 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_120 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_132 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_133 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_134 && ~cond_4 && cond_2)? (`TRUE) :
    (cond_137 && ~cond_4)? (`TRUE) :
    (cond_138 && ~cond_4)? (`TRUE) :
    (cond_139 && ~cond_4)? (`TRUE) :
    (cond_140 && ~cond_4)? (`TRUE) :
    (cond_141 && ~cond_4)? (`TRUE) :
    1'd0;
assign dec_cmdex =
    (cond_5 && ~cond_4 && cond_6)? ( `CMDEX_CALL_Jv_STEP_0) :
    (cond_5 && ~cond_4 && ~cond_6)? ( `CMDEX_CALL_Ap_STEP_0) :
    (cond_7 && ~cond_8 && cond_9)? ( `CMDEX_CALL_Ev_STEP_0) :
    (cond_7 && ~cond_8 && ~cond_9)? ( `CMDEX_CALL_Ep_STEP_0) :
    (cond_10 && ~cond_4)? ( `CMDEX_PUSH_MOV_SEG_implicit | { 1'b0, decoder[5:3] }) :
    (cond_11 && ~cond_12)? ( `CMDEX_PUSH_MOV_SEG_modregrm | { 1'b0, decoder[13:11] }) :
    (cond_13 && ~cond_14)? ( `CMDEX_PUSH_MOV_SEG_modregrm_LDT) :
    (cond_15 && ~cond_14)? ( `CMDEX_PUSH_MOV_SEG_modregrm_TR) :
    (cond_20 && ~cond_4)? ( `CMDEX_INVD_STEP_0) :
    (cond_21 && ~cond_22)? ( `CMDEX_INVLPG_STEP_0) :
    (cond_23 && ~cond_4)? ( `CMDEX_HLT_STEP_0) :
    (cond_24 && ~cond_4)? ( `CMDEX_SCAS_STEP_0) :
    (cond_26 && ~cond_4)? ( `CMDEX_INC_DEC_increment_implicit | { 3'd0, decoder[3] }) :
    (cond_27 && ~cond_1)? ( `CMDEX_INC_DEC_increment_modregrm | { 3'd0, decoder[11] }) :
    (cond_28 && ~cond_4 && cond_2)? ( `CMDEX_RET_near_imm) :
    (cond_28 && ~cond_4 && ~cond_2)? ( `CMDEX_RET_near) :
    (cond_31 && ~cond_22)? ( `CMDEX_LxS_STEP_1) :
    (cond_32 && ~cond_33)? ( `CMDEX_MOV_to_seg_LLDT_LTR_STEP_1) :
    (cond_34 && ~cond_14)? ( `CMDEX_MOV_to_seg_LLDT_LTR_STEP_1) :
    (cond_35 && ~cond_14)? ( `CMDEX_MOV_to_seg_LLDT_LTR_STEP_1) :
    (cond_44 && ~cond_4)? ( `CMDEX_POP_seg_STEP_1) :
    (cond_45 && ~cond_4 && cond_2)? ( `CMDEX_BTx_modregrm_imm) :
    (cond_45 && ~cond_4 && ~cond_2)? ( `CMDEX_BTx_modregrm) :
    (cond_46 && ~cond_1 && cond_2)? ( `CMDEX_BTx_modregrm_imm) :
    (cond_46 && ~cond_1 && ~cond_2)? ( `CMDEX_BTx_modregrm) :
    (cond_47 && ~cond_1 && cond_2)? ( `CMDEX_BTx_modregrm_imm) :
    (cond_47 && ~cond_1 && ~cond_2)? ( `CMDEX_BTx_modregrm) :
    (cond_48 && ~cond_1 && cond_2)? ( `CMDEX_BTx_modregrm_imm) :
    (cond_48 && ~cond_1 && ~cond_2)? ( `CMDEX_BTx_modregrm) :
    (cond_49 && ~cond_4 && cond_50)? ( `CMDEX_IRET_real_v86_STEP_0) :
    (cond_49 && ~cond_4 && ~cond_50)? ( `CMDEX_IRET_protected_STEP_0) :
    (cond_51 && ~cond_4)? ( `CMDEX_POP_implicit) :
    (cond_52 && ~cond_4)? ( `CMDEX_POP_modregrm_STEP_0) :
    (cond_55 && ~cond_4 && cond_56)? ( `CMDEX_Shift_implicit) :
    (cond_55 && ~cond_4 && ~cond_56)? ( `CMDEX_Shift_modregrm) :
    (cond_57 && ~cond_4)? ( `CMDEX_Shift_modregrm_imm) :
    (cond_58 && ~cond_4)? (`CMDEX_CMPS_FIRST) :
    (cond_59 && ~cond_4)? ( `CMDEX_control_reg_SMSW_STEP_0) :
    (cond_60 && ~cond_4)? ( `CMDEX_control_reg_LMSW_STEP_0) :
    (cond_61 && ~cond_62 && cond_56)? ( `CMDEX_control_reg_MOV_load_STEP_0) :
    (cond_61 && ~cond_62 && ~cond_56)? ( `CMDEX_control_reg_MOV_store_STEP_0) :
    (cond_63 && ~cond_22)? ( `CMDEX_LGDT_LIDT_STEP_1) :
    (cond_64 && ~cond_22)? ( `CMDEX_LGDT_LIDT_STEP_1) :
    (cond_65 && ~cond_4)? ( `CMDEX_PUSHA_STEP_0) :
    (cond_66 && ~cond_4)? ( `CMDEX_WAIT_STEP_0) :
    (cond_67 && ~cond_4)? ( `CMDEX_ESC_STEP_0) :
    (cond_70 && ~cond_4)? ( `CMDEX_ENTER_FIRST) :
    (cond_71 && ~cond_4)? ( `CMDEX_IMUL_modregrm) :
    (cond_72 && ~cond_4)? ( `CMDEX_IMUL_modregrm_imm) :
    (cond_74 && ~cond_4 && cond_75)? ( `CMDEX_SHxD_implicit) :
    (cond_74 && ~cond_4 && ~cond_75)? ( `CMDEX_SHxD_modregrm_imm) :
    (cond_76 && ~cond_4 && cond_75)? ( `CMDEX_SHxD_implicit) :
    (cond_76 && ~cond_4 && ~cond_75)? ( `CMDEX_SHxD_modregrm_imm) :
    (cond_77 && ~cond_4)? ( `CMDEX_WBINVD_STEP_0) :
    (cond_78 && ~cond_4)? ( `CMDEX_Arith_immediate) :
    (cond_79 && ~cond_80)? ( `CMDEX_Arith_modregrm) :
    (cond_81 && ~cond_82)? ( `CMDEX_Arith_modregrm_imm) :
    (cond_84 && ~cond_4)? ( (decoder[1:0] == 2'b00)? `CMDEX_LOOP_NE : (decoder[1:0] == 2'b01)? `CMDEX_LOOP_E : `CMDEX_LOOP) :
    (cond_85 && ~cond_4)? ( `CMDEX_TEST_immediate) :
    (cond_86 && ~cond_4)? ( `CMDEX_TEST_modregrm) :
    (cond_87 && ~cond_4)? ( `CMDEX_TEST_modregrm_imm) :
    (cond_88 && ~cond_4)? (`CMDEX_CLTS_STEP_FIRST) :
    (cond_89 && ~cond_4)? ( `CMDEX_RET_far_STEP_1) :
    (cond_90 && ~cond_4)? ( `CMDEX_LODS_STEP_0) :
    (cond_91 && ~cond_4)? ( `CMDEX_XCHG_implicit) :
    (cond_92 && ~cond_1)? ( `CMDEX_XCHG_modregrm) :
    (cond_93 && ~cond_4)? ( `CMDEX_PUSH_implicit) :
    (cond_94 && ~cond_4 && cond_56)? ( `CMDEX_PUSH_immediate_se) :
    (cond_94 && ~cond_4 && ~cond_56)? ( `CMDEX_PUSH_immediate) :
    (cond_95 && ~cond_4)? ( `CMDEX_PUSH_modregrm) :
    (cond_96 && ~cond_4)? ( (decoder[2:0] == 3'b100)? `CMDEX_INT_INTO_INT3_STEP_0 : (decoder[2:0] == 3'b101)? `CMDEX_INT_INTO_INT_STEP_0 : (decoder[2:0] == 3'b110)? `CMDEX_INT_INTO_INTO_STEP_0 : `CMDEX_INT_INTO_INT1_STEP_0) :
    (cond_98 && ~cond_4)? ( `CMDEX_CPUID_STEP_LAST) :
    (cond_99 && ~cond_4 && cond_100)? ( `CMDEX_IN_dx) :
    (cond_99 && ~cond_4 && ~cond_100)? ( `CMDEX_IN_imm) :
    (cond_103 && ~cond_14)? ( `CMDEX_LAR_LSL_VERR_VERW_STEP_1) :
    (cond_104 && ~cond_14)? ( `CMDEX_LAR_LSL_VERR_VERW_STEP_1) :
    (cond_105 && ~cond_14)? (`CMDEX_LAR_LSL_VERR_VERW_STEP_1) :
    (cond_106 && ~cond_14)? ( `CMDEX_LAR_LSL_VERR_VERW_STEP_1) :
    (cond_107 && ~cond_4)? ( `CMDEX_STOS_STEP_0) :
    (cond_108 && ~cond_4)? ( `CMDEX_INS_real_1) :
    (cond_109 && ~cond_4)? ( `CMDEX_OUTS_first) :
    (cond_111 && ~cond_4 && cond_2)? ( `CMDEX_JMP_Ap_STEP_0) :
    (cond_111 && ~cond_4 && ~cond_2)? ( `CMDEX_JMP_Jv_STEP_0) :
    (cond_113 && ~cond_114 && cond_9)? ( `CMDEX_JMP_Ev_STEP_0) :
    (cond_113 && ~cond_114 && ~cond_9)? ( `CMDEX_JMP_Ep_STEP_0) :
    (cond_115 && ~cond_4 && cond_100)? ( `CMDEX_OUT_dx) :
    (cond_115 && ~cond_4 && ~cond_100)? ( `CMDEX_OUT_imm) :
    (cond_116 && ~cond_4)? ( `CMDEX_MOV_memoffset) :
    (cond_117 && ~cond_4)? ( `CMDEX_MOV_immediate) :
    (cond_119 && ~cond_4)? ( `CMDEX_MOV_modregrm) :
    (cond_120 && ~cond_4)? ( `CMDEX_MOV_modregrm_imm) :
    (cond_124 && ~cond_4)? ( `CMDEX_POPF_STEP_0) :
    (cond_127 && ~cond_22)? ( `CMDEX_BOUND_STEP_FIRST) :
    (cond_128 && ~cond_4)? ( `CMDEX_SALC_STEP_0) :
    (cond_130 && ~cond_22)? ( `CMDEX_SGDT_SIDT_STEP_1) :
    (cond_131 && ~cond_22)? ( `CMDEX_SGDT_SIDT_STEP_1) :
    (cond_132 && ~cond_4)? ( `CMDEX_MOVS_STEP_0) :
    (cond_135 && ~cond_4)? ( `CMDEX_POPA_STEP_0) :
    (cond_136 && ~cond_4 && cond_56)? ( `CMDEX_debug_reg_MOV_load_STEP_0) :
    (cond_136 && ~cond_4 && ~cond_56)? ( `CMDEX_debug_reg_MOV_store_STEP_0) :
    4'd0;
