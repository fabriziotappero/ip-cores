/* Generated automatically by the program `genflags'
   from the machine description file `md'.  */

#ifndef GCC_INSN_FLAGS_H
#define GCC_INSN_FLAGS_H

#define HAVE_frame_alloc_fp 1
#define HAVE_frame_dealloc_fp 1
#define HAVE_frame_dealloc_sp 1
#define HAVE_return_internal 1
#define HAVE_movsi_lo_sum 1
#define HAVE_movsi_high 1
#define HAVE_movsi_gotofflo (flag_pic)
#define HAVE_movsi_gotoffhi (flag_pic)
#define HAVE_movsi_got (flag_pic)
#define HAVE_movsi_tlsgdlo 1
#define HAVE_movsi_tlsgdhi 1
#define HAVE_movsi_gottpofflo 1
#define HAVE_movsi_gottpoffhi 1
#define HAVE_load_gottpoff 1
#define HAVE_movsi_tpofflo 1
#define HAVE_movsi_tpoffhi 1
#define HAVE_movsi_insn_big (GET_CODE (operands[1]) != CONST_INT)
#define HAVE_cmov (TARGET_MASK_CMOV)
#define HAVE_movdi 1
#define HAVE_movdf 1
#define HAVE_movsf 1
#define HAVE_extendqisi2_sext (TARGET_MASK_SEXT)
#define HAVE_extendqisi2_no_sext_mem (!TARGET_MASK_SEXT)
#define HAVE_extendhisi2_sext (TARGET_MASK_SEXT)
#define HAVE_extendhisi2_no_sext_mem (!TARGET_MASK_SEXT)
#define HAVE_zero_extendqisi2 1
#define HAVE_zero_extendhisi2 1
#define HAVE_ashlsi3 1
#define HAVE_ashrsi3 1
#define HAVE_lshrsi3 1
#define HAVE_rotrsi3 (TARGET_MASK_ROR)
#define HAVE_andsi3 1
#define HAVE_iorsi3 1
#define HAVE_xorsi3 1
#define HAVE_one_cmplqi2 1
#define HAVE_one_cmplsi2 1
#define HAVE_negsi2 1
#define HAVE_addsi3 1
#define HAVE_subsi3 1
#define HAVE_mulsi3 (TARGET_HARD_MUL)
#define HAVE_divsi3 (TARGET_HARD_DIV)
#define HAVE_udivsi3 (TARGET_HARD_DIV)
#define HAVE_jump_internal 1
#define HAVE_indirect_jump_internal 1
#define HAVE_call_internal 1
#define HAVE_call_value_internal 1
#define HAVE_call_value_indirect_internal 1
#define HAVE_call_indirect_internal 1
#define HAVE_tablejump_internal 1
#define HAVE_nop 1
#define HAVE_addsf3 (TARGET_HARD_FLOAT)
#define HAVE_adddf3 (TARGET_HARD_FLOAT && TARGET_DOUBLE_FLOAT)
#define HAVE_subsf3 (TARGET_HARD_FLOAT)
#define HAVE_subdf3 (TARGET_HARD_FLOAT && TARGET_DOUBLE_FLOAT)
#define HAVE_mulsf3 (TARGET_HARD_FLOAT)
#define HAVE_muldf3 (TARGET_HARD_FLOAT && TARGET_DOUBLE_FLOAT)
#define HAVE_divsf3 (TARGET_HARD_FLOAT)
#define HAVE_divdf3 (TARGET_HARD_FLOAT && TARGET_DOUBLE_FLOAT)
#define HAVE_floatsisf2 (TARGET_HARD_FLOAT)
#define HAVE_fixunssfsi2 (TARGET_HARD_FLOAT)
#define HAVE_set_got 1
#define HAVE_prologue 1
#define HAVE_epilogue 1
#define HAVE_movqi 1
#define HAVE_movhi 1
#define HAVE_movsi 1
#define HAVE_addsicc 1
#define HAVE_addhicc 1
#define HAVE_addqicc 1
#define HAVE_movsicc (TARGET_MASK_CMOV)
#define HAVE_movhicc 1
#define HAVE_movqicc 1
#define HAVE_cbranchsi4 1
#define HAVE_cbranchsf4 (TARGET_HARD_FLOAT)
#define HAVE_extendqisi2 1
#define HAVE_extendqisi2_no_sext_reg (!TARGET_MASK_SEXT)
#define HAVE_extendhisi2 1
#define HAVE_extendhisi2_no_sext_reg (!TARGET_MASK_SEXT)
#define HAVE_jump 1
#define HAVE_indirect_jump 1
#define HAVE_call 1
#define HAVE_call_value 1
#define HAVE_call_value_indirect 1
#define HAVE_call_indirect 1
#define HAVE_tablejump 1
extern rtx        gen_frame_alloc_fp               (rtx);
extern rtx        gen_frame_dealloc_fp             (void);
extern rtx        gen_frame_dealloc_sp             (rtx);
extern rtx        gen_return_internal              (rtx);
extern rtx        gen_movsi_lo_sum                 (rtx, rtx, rtx);
extern rtx        gen_movsi_high                   (rtx, rtx);
extern rtx        gen_movsi_gotofflo               (rtx, rtx, rtx);
extern rtx        gen_movsi_gotoffhi               (rtx, rtx);
extern rtx        gen_movsi_got                    (rtx, rtx);
extern rtx        gen_movsi_tlsgdlo                (rtx, rtx, rtx);
extern rtx        gen_movsi_tlsgdhi                (rtx, rtx);
extern rtx        gen_movsi_gottpofflo             (rtx, rtx, rtx);
extern rtx        gen_movsi_gottpoffhi             (rtx, rtx);
extern rtx        gen_load_gottpoff                (rtx, rtx);
extern rtx        gen_movsi_tpofflo                (rtx, rtx, rtx);
extern rtx        gen_movsi_tpoffhi                (rtx, rtx);
extern rtx        gen_movsi_insn_big               (rtx, rtx);
extern rtx        gen_cmov                         (rtx, rtx, rtx, rtx, rtx);
extern rtx        gen_movdi                        (rtx, rtx);
extern rtx        gen_movdf                        (rtx, rtx);
extern rtx        gen_movsf                        (rtx, rtx);
extern rtx        gen_extendqisi2_sext             (rtx, rtx);
extern rtx        gen_extendqisi2_no_sext_mem      (rtx, rtx);
extern rtx        gen_extendhisi2_sext             (rtx, rtx);
extern rtx        gen_extendhisi2_no_sext_mem      (rtx, rtx);
extern rtx        gen_zero_extendqisi2             (rtx, rtx);
extern rtx        gen_zero_extendhisi2             (rtx, rtx);
extern rtx        gen_ashlsi3                      (rtx, rtx, rtx);
extern rtx        gen_ashrsi3                      (rtx, rtx, rtx);
extern rtx        gen_lshrsi3                      (rtx, rtx, rtx);
extern rtx        gen_rotrsi3                      (rtx, rtx, rtx);
extern rtx        gen_andsi3                       (rtx, rtx, rtx);
extern rtx        gen_iorsi3                       (rtx, rtx, rtx);
extern rtx        gen_xorsi3                       (rtx, rtx, rtx);
extern rtx        gen_one_cmplqi2                  (rtx, rtx);
extern rtx        gen_one_cmplsi2                  (rtx, rtx);
extern rtx        gen_negsi2                       (rtx, rtx);
extern rtx        gen_addsi3                       (rtx, rtx, rtx);
extern rtx        gen_subsi3                       (rtx, rtx, rtx);
extern rtx        gen_mulsi3                       (rtx, rtx, rtx);
extern rtx        gen_divsi3                       (rtx, rtx, rtx);
extern rtx        gen_udivsi3                      (rtx, rtx, rtx);
extern rtx        gen_jump_internal                (rtx);
extern rtx        gen_indirect_jump_internal       (rtx);
extern rtx        gen_call_internal                (rtx, rtx);
extern rtx        gen_call_value_internal          (rtx, rtx, rtx);
extern rtx        gen_call_value_indirect_internal (rtx, rtx, rtx);
extern rtx        gen_call_indirect_internal       (rtx, rtx);
extern rtx        gen_tablejump_internal           (rtx, rtx);
extern rtx        gen_nop                          (void);
extern rtx        gen_addsf3                       (rtx, rtx, rtx);
extern rtx        gen_adddf3                       (rtx, rtx, rtx);
extern rtx        gen_subsf3                       (rtx, rtx, rtx);
extern rtx        gen_subdf3                       (rtx, rtx, rtx);
extern rtx        gen_mulsf3                       (rtx, rtx, rtx);
extern rtx        gen_muldf3                       (rtx, rtx, rtx);
extern rtx        gen_divsf3                       (rtx, rtx, rtx);
extern rtx        gen_divdf3                       (rtx, rtx, rtx);
extern rtx        gen_floatsisf2                   (rtx, rtx);
extern rtx        gen_fixunssfsi2                  (rtx, rtx);
extern rtx        gen_set_got                      (rtx);
extern rtx        gen_prologue                     (void);
extern rtx        gen_epilogue                     (void);
extern rtx        gen_movqi                        (rtx, rtx);
extern rtx        gen_movhi                        (rtx, rtx);
extern rtx        gen_movsi                        (rtx, rtx);
extern rtx        gen_addsicc                      (rtx, rtx, rtx, rtx);
extern rtx        gen_addhicc                      (rtx, rtx, rtx, rtx);
extern rtx        gen_addqicc                      (rtx, rtx, rtx, rtx);
extern rtx        gen_movsicc                      (rtx, rtx, rtx, rtx);
extern rtx        gen_movhicc                      (rtx, rtx, rtx, rtx);
extern rtx        gen_movqicc                      (rtx, rtx, rtx, rtx);
extern rtx        gen_cbranchsi4                   (rtx, rtx, rtx, rtx);
extern rtx        gen_cbranchsf4                   (rtx, rtx, rtx, rtx);
extern rtx        gen_extendqisi2                  (rtx, rtx);
extern rtx        gen_extendqisi2_no_sext_reg      (rtx, rtx);
extern rtx        gen_extendhisi2                  (rtx, rtx);
extern rtx        gen_extendhisi2_no_sext_reg      (rtx, rtx);
extern rtx        gen_jump                         (rtx);
extern rtx        gen_indirect_jump                (rtx);
#define GEN_CALL(A, B, C, D) gen_call ((A), (B))
extern rtx        gen_call                         (rtx, rtx);
#define GEN_CALL_VALUE(A, B, C, D, E) gen_call_value ((A), (B), (C))
extern rtx        gen_call_value                   (rtx, rtx, rtx);
extern rtx        gen_call_value_indirect          (rtx, rtx, rtx);
extern rtx        gen_call_indirect                (rtx, rtx);
extern rtx        gen_tablejump                    (rtx, rtx);

#endif /* GCC_INSN_FLAGS_H */
