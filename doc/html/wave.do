onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /test_pavr/main_clk_cnt
add wave -noupdate -radix default -format Logic /test_pavr/pm_sel
add wave -noupdate -radix hexadecimal /test_pavr/pm_di
add wave -noupdate -radix default -format Logic /test_pavr/pm_wr
add wave -noupdate -radix unsigned /test_pavr/pm_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_clk
add wave -noupdate -radix unsigned /test_pavr/run_clk_cnt
add wave -noupdate -radix unsigned /test_pavr/instr_cnt
add wave -noupdate -radix default /test_pavr/pavr_pavr_inc_instr_cnt
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_res
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_syncres
add wave -noupdate -radix default -format Logic /test_pavr/pavr_pavr_res
add wave -noupdate -radix default -format Logic /test_pavr/pavr_pavr_syncres
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_addr_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s1_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s2_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s3_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_pavr_pm_do
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s3_instr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s3_instr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_instr32bits
add wave -noupdate -radix default -format Logic /test_pavr/pavr_pavr_pm_wr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_pcinc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_pcinc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_grant_s2_pm_access
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_grant_control_flow_access
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_freeze_control_flow
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_k12rel_23b
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_do
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_pm_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s1_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s1_pc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s2_pmdo_valid
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s2_pmdo_valid
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s2_pmdo_valid_shadow
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_pm_do_shadow_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd1_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd2_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_do_shadow
add wave -noupdate -radix default /test_pavr/pavr_instance1/rfrd1_manager/v_rfrd1rq_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_rfrd1_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_rfrd2_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s3_rfrd1_addr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s3_rfrd2_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_rfrd1_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_rfwr_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/next_pavr_s4_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/next_pavr_s4_s61_rfwr_addr2
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_bpr0wr_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr0
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr0_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_bpr0_active
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_bpr1wr_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr1_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_bpr1_active
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_iof_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_s5s6_iof_addr
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5s6_iof_bitaddr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_clriflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_setiflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_inc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51s52_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51_retinc_spwr_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_opcode
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_op1_hi8_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_op2_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_s5_k8
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_do_shadow_active
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_dacu_do_shadow_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dacu_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd1_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd2_do_shadow
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_op1_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op1bpu
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_op2_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op2bpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_flagsin
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_flagsout
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_alu_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_out
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/next_pavr_s4_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_iof_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_dm_dacu_q
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_dacudo_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_dacu_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_dacu_dm_addr
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_dacu_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dacu_do
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp10_1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp10_2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp10_3
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp18_1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp18_2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp18_3
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s6_alu_out
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s61_alu_out_hi8
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_x_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_y_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_z_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_sp_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_k16_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51s52_pc_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_sp_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_k16_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_x_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_y_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_z_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51s52_pc_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_dmrd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_dmwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_lpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_elpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_z_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_zeind_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_k22abs_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_k12rel_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_k22int_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_branch_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_skip_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr00_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr00_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr00
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr01_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr01_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr01
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr02_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr02_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr02
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr03_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr03_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr03
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr10_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr10_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr10
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr11_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr11_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr11
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr12_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr12_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr12
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr13_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr13_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr13
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr20
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr20_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr20_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr21
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr21_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr21_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr22
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr22_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr22_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr23
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr23_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr23_active
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_k6
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_k12
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_k22int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_k12rel_23b
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_addr_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_zlsb
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s51s52s53_retpc_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s6_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s61_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s6_branch_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_nop_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_skip_en
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_skip_bitrf_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s6_skip_bitiof_sel
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/next_pavr_s4_s5_k7_branch_offset
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_branch_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_branch_en
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_branch_bitsreg_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_branch_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_nop_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s53_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s54_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s55_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s1_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s2_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s1
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s2
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s3
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s4
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s5
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s6
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s1
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s2
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s3
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s4
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s5
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s6
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_instr32bits
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_int_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_int_vec
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_rf_rd1_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_rd1_rd
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd1_do
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_rf_rd2_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_rd2_rd
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd2_do
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_rf_wr_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_wr_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_wr_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_x
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_x_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_x_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_y
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_y_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_y_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_z
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_z_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_z_di
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_do
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_bitaddr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_bitout
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sreg
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_sreg_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sreg_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_spl
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_spl_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_spl_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sph
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_sph_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sph_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampx
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampx_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampx_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampy
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampy_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampy_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampz
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampz_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampz_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampd
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampd_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampd_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_eind
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_eind_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_eind_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_do
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_dm_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_di
add wave -noupdate -radix binary /test_pavr/pavr_instance1/dacu_manager/tmpv_rd
add wave -noupdate -radix binary /test_pavr/pavr_instance1/dacu_manager/tmpv_wr
add wave -noupdate -radix binary /test_pavr/pavr_instance1/dacu_manager/tmpv_rdwr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_dacu_wr_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_dacu_ptr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_rf_dacu_addrtest
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_iof_dacu_addrtest
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_dm_dacu_addrtest
add wave -noupdate -radix default /test_pavr/pavr_instance1/dacu_manager/v_pavr_dacu_device_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_iof_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_iof_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_iof_rfwr_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s61_rfwr_addr2
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_s61_rfwr_addr2
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_s61_rfwr_addr2
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s61_rfwr_addr2
add wave -noupdate -radix default /test_pavr/pavr_instance1/bpr0wr_manager/v_bpr0wrrq_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_alu_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_daculd_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_iof_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_iof_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_daculd_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_alu_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_iof_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_daculd_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacust_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_pmdo_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_alu_bpr1wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_alu_bpr1wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dacux_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dacuy_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dacuz_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dacux_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacux_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dacuy_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacuy_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dacuz_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacuz_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_iof_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s5_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s6_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_s6_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s6_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_s5s6_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s6_iof_addr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s5s6_iof_bitaddr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_iof_bitaddr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_iof_bitaddr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_alu_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_alu_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_clriflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_clriflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_setiflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_setiflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_inc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_inc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51s52_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51_retinc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_retinc2_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_retinc_spwr_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_k8
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s5_rf_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s5_iof_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s5_dm_dacu_q
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s6_dacudo_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_k16
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_x_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_x_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_y_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_y_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_z_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_z_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_sp_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_sp_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_k16_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_k16_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51s52_pc_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_pchi8_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_pcmid8_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_pclo8_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_sp_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_sp_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_k16_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_k16_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_x_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_x_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_y_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_y_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_z_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_z_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51s52_pc_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_pclo8_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_pcmid8_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_pchi8_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_lpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_lpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_elpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_elpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_z_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_zeind_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_k22abs_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_k12rel_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_k22int_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s53_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s54_ret_pm_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_k6
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_k12
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_k22int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s2_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s3_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s51_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s52_pc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s51s52s53_retpc_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s51s52s53_retpc_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_retpchi8_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_retpcmid8_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s53_retpclo8_ld
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s52_retpchi8
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s53_retpcmid8
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s54_retpclo8
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s5_skip_cond_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_en
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s5_skip_bitrf_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_skip_bitrf_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s6_skip_bitiof_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_s6_skip_bitiof_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_skip_bitiof_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_s5_k7_branch_offset
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_k7_branch_offset
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s6_branch_pc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_branch_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_branch_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_branch_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_branch_en
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s5_branch_bitsreg_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_clk
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_res
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_syncres
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_opcode
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_do
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_bitout
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_bitaddr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_pa
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_vec
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_branch_bitsreg_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_nop_ack
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_instr32bits
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_disable_int
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_instance1/clk_t0_cnt
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/next_pavr_t0_clk
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_t0_clk
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int0_clk
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_mcucr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_gimsk
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_gifr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_tcnt0
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_tccr0
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_tifr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_timsk
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_porta
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_ddra
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_pina
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_tmpdi
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_flgs
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_flgs_dcd
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sreg
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_xbpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_ybpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_zbpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_instance1/data_array
add wave -noupdate -radix hexadecimal -expand /test_pavr/pavr_instance1/pavr_rf_instance1/pavr_rf_data_array
add wave -noupdate -radix default -format Logic /test_pavr/pm_sel
add wave -noupdate -radix hexadecimal /test_pavr/pm_di
add wave -noupdate -radix default -format Logic /test_pavr/pm_wr
add wave -noupdate -radix unsigned /test_pavr/pm_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_clk
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_res
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_syncres
add wave -noupdate -radix default -format Logic /test_pavr/pavr_pavr_res
add wave -noupdate -radix default -format Logic /test_pavr/pavr_pavr_syncres
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_addr_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s1_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s2_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s3_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_pavr_pm_do
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s3_instr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s3_instr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_instr32bits
add wave -noupdate -radix default -format Logic /test_pavr/pavr_pavr_pm_wr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_pcinc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_pcinc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_grant_s2_pm_access
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_grant_control_flow_access
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_freeze_control_flow
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_k12rel_23b
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_do
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_pm_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s1_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s1_pc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s2_pmdo_valid
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s2_pmdo_valid
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s2_pmdo_valid_shadow
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_pm_do_shadow_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd1_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd2_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_do_shadow
add wave -noupdate -radix default /test_pavr/pavr_instance1/rfrd1_manager/v_rfrd1rq_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_rfrd1_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_rfrd2_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s3_rfrd1_addr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s3_rfrd2_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_rfrd1_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_rfwr_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/next_pavr_s4_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/next_pavr_s4_s61_rfwr_addr2
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_bpr0wr_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr0
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr0_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_bpr0_active
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_bpr1wr_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_bpr1_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_bpr1_active
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_iof_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s6_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_s5s6_iof_addr
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5s6_iof_bitaddr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_clriflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_setiflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_inc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51s52_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51_retinc_spwr_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_opcode
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_op1_hi8_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_alu_op2_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_s5_k8
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_do_shadow_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd1_do_shadow
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd2_do_shadow
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_op1_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op1bpu
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_op2_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_op2bpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_flagsin
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_flagsout
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_alu_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_alu_out
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/next_pavr_s4_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_iof_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_dm_dacu_q
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_dacudo_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_dacu_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_dacu_dm_addr
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_dacu_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dacu_do
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp10_1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp10_2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp10_3
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp18_1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp18_2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_alu_instance1/tmp18_3
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s6_alu_out
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s61_alu_out_hi8
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_x_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_y_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_z_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_sp_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_k16_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51s52_pc_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_sp_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_k16_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_x_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_y_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_z_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5s51s52_pc_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_dmrd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacu_dmwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_lpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_elpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_z_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_zeind_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_k22abs_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_k12rel_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_k22int_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_branch_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_skip_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr00_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr00_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr00
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr01_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr01_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr01
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr02_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr02_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr02
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr03_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr03_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr03
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr10_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr10_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr10
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr11_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr11_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr11
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr12_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr12_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr12
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr13_active
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr13_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr13
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr20
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr20_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr20_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr21
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr21_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr21_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr22
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr22_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr22_active
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_bpr23
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_bpr23_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_bpr23_active
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_k6
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_k12
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/next_pavr_s4_k22int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op1
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_22b_op2
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pm_manager/v_pavr_pc_k12rel_23b
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_pm_addr_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_zlsb
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s51s52s53_retpc_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s6_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s61_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s6_branch_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_nop_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s6_skip_en
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_skip_bitrf_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s6_skip_bitiof_sel
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/next_pavr_s4_s5_k7_branch_offset
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_branch_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_branch_en
add wave -noupdate -radix default /test_pavr/pavr_instance1/next_pavr_s4_s5_branch_bitsreg_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_stall_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_branch_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_nop_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s53_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s54_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s55_ret_flush_s2_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s1_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s2_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s3_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_hwrq_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s1
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s2
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s3
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s4
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s5
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_stall_s6
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s1
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s2
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s3
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s4
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s5
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_flush_s6
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_instr32bits
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_int_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_int_vec
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_rf_rd1_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_rd1_rd
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd1_do
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_rf_rd2_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_rd2_rd
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_rd2_do
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_rf_wr_addr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_wr_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_wr_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_x
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_x_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_x_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_y
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_y_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_y_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_z
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_rf_z_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_rf_z_di
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_do
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_bitaddr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_bitout
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sreg
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_sreg_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sreg_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_spl
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_spl_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_spl_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sph
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_sph_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sph_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampx
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampx_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampx_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampy
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampy_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampy_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampz
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampz_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampz_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampd
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_rampd_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_rampd_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_eind
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_iof_eind_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_eind_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_do
add wave -noupdate -radix hexadecimal -format Logic /test_pavr/pavr_instance1/pavr_dm_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_di
add wave -noupdate -radix binary /test_pavr/pavr_instance1/dacu_manager/tmpv_rd
add wave -noupdate -radix binary /test_pavr/pavr_instance1/dacu_manager/tmpv_wr
add wave -noupdate -radix binary /test_pavr/pavr_instance1/dacu_manager/tmpv_rdwr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_dacu_wr_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_dacu_ptr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_rf_dacu_addrtest
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_iof_dacu_addrtest
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/dacu_manager/v_pavr_s5_dm_dacu_addrtest
add wave -noupdate -radix default /test_pavr/pavr_instance1/dacu_manager/v_pavr_dacu_device_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_aluoutlo8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s61_aluouthi8_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_iof_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_iof_rfwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_iof_rfwr_rq
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_rfwr_addr1
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s61_rfwr_addr2
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_s61_rfwr_addr2
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_s61_rfwr_addr2
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s61_rfwr_addr2
add wave -noupdate -radix default /test_pavr/pavr_instance1/bpr0wr_manager/v_bpr0wrrq_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_alu_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_daculd_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_iof_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_iof_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_daculd_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_alu_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_iof_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_daculd_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacust_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_pmdo_bpr0wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_alu_bpr1wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_alu_bpr1wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dacux_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dacuy_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/next_pavr_s4_s5_dacuz_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dacux_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacux_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dacuy_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacuy_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dacuz_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dacuz_bpr12wr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_iof_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_iof_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s5_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s6_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_s6_iof_opcode
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s6_iof_opcode
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_s5s6_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s6_iof_addr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s5s6_iof_bitaddr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_iof_bitaddr
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_iof_bitaddr
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_alu_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_alu_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_clriflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_clriflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_setiflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_setiflag_sregwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_inc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_inc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_dec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_dec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51s52_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_calldec_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51_retinc_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_retinc2_spwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_retinc_spwr_rq
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_k8
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s5_rf_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s5_iof_dacu_q
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s5_dm_dacu_q
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s6_dacudo_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_k16
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_x_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_x_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_y_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_y_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_z_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_z_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_sp_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_sp_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_k16_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_k16_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51s52_pc_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_pchi8_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_pcmid8_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_pclo8_dacurd_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_sp_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_sp_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_k16_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_k16_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_x_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_x_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_y_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_y_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_z_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_z_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5s51s52_pc_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_pclo8_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_pcmid8_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_pchi8_dacuwr_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_lpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_lpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_elpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_elpm_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_z_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_zeind_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_k22abs_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_k12rel_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_k22int_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s53_s54_ret_pm_rq
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s54_ret_pm_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_k6
add wave -noupdate -radix decimal /test_pavr/pavr_instance1/pavr_s4_k12
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_k22int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s2_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s3_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s51_pc
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s52_pc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s51s52s53_retpc_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s51s52s53_retpc_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_retpchi8_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_retpcmid8_ld
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s53_retpclo8_ld
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s52_retpchi8
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s53_retpcmid8
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s54_retpclo8
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s5_skip_cond_sel
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s6_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_s6_skip_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s6_skip_en
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s5_skip_bitrf_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_skip_bitrf_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s4_s6_skip_bitiof_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s5_s6_skip_bitiof_sel
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_s6_skip_bitiof_sel
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s4_s5_k7_branch_offset
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s5_k7_branch_offset
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_s6_branch_pc
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_branch_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_branch_cond_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_s5_branch_en
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_branch_en
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s4_s5_branch_bitsreg_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_clk
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_res
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_syncres
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_opcode
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_addr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_do
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_bitout
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_bitaddr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind_wr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind_di
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_pa
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_rq
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_vec
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_s5_branch_bitsreg_sel
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_nop_ack
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_instr32bits
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s4_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s5_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s51_disable_int
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_s52_disable_int
add wave -noupdate -radix unsigned /test_pavr/pavr_instance1/pavr_iof_instance1/clk_t0_cnt
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/next_pavr_t0_clk
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_t0_clk
add wave -noupdate -radix default -format Logic /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int0_clk
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sreg_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_sph_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_spl_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampx_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampy_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampz_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_rampd_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_eind_int
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_mcucr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_gimsk
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_gifr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_tcnt0
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_tccr0
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_tifr
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_timsk
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_porta
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_ddra
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_iof_pina
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_tmpdi
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_flgs
add wave -noupdate -radix default /test_pavr/pavr_instance1/pavr_iof_instance1/pavr_int_flgs_dcd
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_iof_sreg
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_xbpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_ybpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_zbpu
add wave -noupdate -radix hexadecimal /test_pavr/pavr_instance1/pavr_dm_instance1/data_array
add wave -noupdate -radix hexadecimal -expand /test_pavr/pavr_instance1/pavr_rf_instance1/pavr_rf_data_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {47832250 ns}
WaveRestoreZoom {47831259 ns} {47832564 ns}
