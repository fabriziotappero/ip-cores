onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /light52_tb/clk
add wave -noupdate -divider CPU
add wave -noupdate -color Gray75 -format Literal -radix hexadecimal /light52_tb/uut/cpu/pc_reg
add wave -noupdate -color Gray90 -format Literal -radix hexadecimal /light52_tb/uut/code_addr
add wave -noupdate -color {Lime Green} -format Literal -radix hexadecimal /light52_tb/uut/code_rd
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /light52_tb/uut/cpu/a_reg
add wave -noupdate -group SFR
add wave -noupdate -group SFR -color Magenta -format Literal -radix hexadecimal /light52_tb/uut/cpu/sfr_addr
add wave -noupdate -group SFR -format Logic /light52_tb/uut/cpu/sfr_vma
add wave -noupdate -group SFR -format Logic /light52_tb/uut/cpu/sfr_we
add wave -noupdate -group SFR -color Orchid -format Literal -radix hexadecimal /light52_tb/uut/cpu/sfr_wr
add wave -noupdate -group SFR -color {Sky Blue} -format Literal -radix hexadecimal /light52_tb/uut/cpu/sfr_rd
add wave -noupdate -format Literal -radix hexadecimal /light52_tb/uut/cpu/ie_reg
add wave -noupdate -format Literal -radix hexadecimal /light52_tb/uut/cpu/addr0_reg
add wave -noupdate -format Literal -radix hexadecimal /light52_tb/uut/cpu/addr1_reg
add wave -noupdate -format Literal -radix hexadecimal /light52_tb/uut/cpu/jump_target
add wave -noupdate -divider Debug
add wave -noupdate -format Literal -radix unsigned /light52_tb/uut/timer/compare_reg
add wave -noupdate -format Literal -radix unsigned /light52_tb/uut/timer/counter_reg
add wave -noupdate -format Literal -radix unsigned /light52_tb/uut/timer/prescaler_ctr_reg
add wave -noupdate -format Logic /light52_tb/uut/timer/counter_match
add wave -noupdate -format Logic /light52_tb/uut/timer_irq
add wave -noupdate -format Logic /light52_tb/uut/cpu/irq_active
add wave -noupdate -format Logic /light52_tb/uut/cpu/irq_restore_level
add wave -noupdate -format Logic /light52_tb/uut/cpu/irq_active_hip
add wave -noupdate -format Logic /light52_tb/uut/cpu/irq_serving_hip
add wave -noupdate -format Logic /light52_tb/uut/cpu/irq_serving_lop
add wave -noupdate -format Literal /light52_tb/uut/cpu/irq_level_inputs
add wave -noupdate -group {External Interrupts}
add wave -noupdate -group {External Interrupts} -format Literal /light52_tb/uut/external_irq
add wave -noupdate -group {External Interrupts} -format Logic /light52_tb/uut/ext_irq
add wave -noupdate -group {External Interrupts} -format Literal /light52_tb/uut/external_irq_reg
add wave -noupdate -group Timer
add wave -noupdate -group Timer -format Literal -radix hexadecimal /light52_tb/uut/timer/data_o
add wave -noupdate -group Timer -format Literal -radix hexadecimal /light52_tb/uut/timer/compare_reg
add wave -noupdate -group Timer -format Literal -radix hexadecimal /light52_tb/uut/timer/counter_reg
add wave -noupdate -group Timer -format Logic /light52_tb/uut/timer/counter_match
add wave -noupdate -group Timer -format Literal /light52_tb/uut/timer/status_reg
add wave -noupdate -group Timer -format Logic /light52_tb/uut/timer/irq_o
add wave -noupdate -group Timer -format Literal /light52_tb/uut/timer/addr_i
add wave -noupdate -format Logic /light52_tb/uut/timer/ce_i
add wave -noupdate -format Logic /light52_tb/uut/timer/wr_i
add wave -noupdate -format Literal /light52_tb/uut/timer/addr_i
add wave -noupdate -format Logic /light52_tb/uut/timer/irq_o
add wave -noupdate -format Literal -radix hexadecimal /light52_tb/uut/timer/data_i
add wave -noupdate -format Literal -radix hexadecimal /light52_tb/uut/timer/status_reg
add wave -noupdate -color Pink -format Literal /light52_tb/uut/cpu/ps
add wave -noupdate -divider Internal
add wave -noupdate -group Datapath
add wave -noupdate -group Datapath -color Goldenrod -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu_result
add wave -noupdate -group Datapath -color Wheat -format Literal -radix hexadecimal /light52_tb/uut/cpu/nobit_alu_result
add wave -noupdate -group Datapath -color Gold -format Literal /light52_tb/uut/cpu/alu_fn_reg
add wave -noupdate -group Datapath -group MUL-DIV
add wave -noupdate -group MUL-DIV -color {Violet Red} -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/b_reg
add wave -noupdate -group MUL-DIV -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/quotient
add wave -noupdate -group MUL-DIV -format Logic /light52_tb/uut/cpu/alu/div_ready
add wave -noupdate -group MUL-DIV -format Logic /light52_tb/uut/cpu/load_b_sfr
add wave -noupdate -group MUL-DIV -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/remainder
add wave -noupdate -group MUL-DIV -format Literal /light52_tb/uut/cpu/alu/muldiv/bit_ctr
add wave -noupdate -group Datapath -group {Int. results}
add wave -noupdate -group {Int. results} -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/alu_adder_result
add wave -noupdate -group {Int. results} -format Literal /light52_tb/uut/cpu/alu/alu_logic_result
add wave -noupdate -group Datapath -group Inputs
add wave -noupdate -group Inputs -color {Cornflower Blue} -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/t_reg
add wave -noupdate -group Inputs -color {Sky Blue} -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/v_reg
add wave -noupdate -group Inputs -format Literal /light52_tb/uut/cpu/alu/load_t
add wave -noupdate -group Inputs -format Logic /light52_tb/uut/cpu/alu/load_v
add wave -noupdate -group Inputs -format Literal /light52_tb/uut/cpu/alu/alu_op_sel
add wave -noupdate -group Inputs -color Sienna -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/adder_op_0
add wave -noupdate -group Inputs -color {Indian Red} -format Literal -radix hexadecimal /light52_tb/uut/cpu/alu/adder_op_1
add wave -noupdate -group Datapath -format Logic /light52_tb/uut/cpu/alu/div_ready
add wave -noupdate -group Datapath -format Logic /light52_tb/uut/cpu/alu/mul_ready
add wave -noupdate -group Datapath -group Flags
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/alu_p
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/acc_is_zero
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/alu_result_is_zero
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/update_psw_flags
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/psw_reg(7)
add wave -noupdate -group Flags -format Literal /light52_tb/uut/cpu/psw_reg
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/alu_ov
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/alu/adder_cy_in
add wave -noupdate -group Flags -format Logic /light52_tb/uut/cpu/alu_cy
add wave -noupdate -group Decoding
add wave -noupdate -group Decoding -format Literal -radix hexadecimal /light52_tb/uut/cpu/bram_addr_p0
add wave -noupdate -group Decoding -format Literal -radix hexadecimal /light52_tb/uut/cpu/ucode_index
add wave -noupdate -group Decoding -format Literal /light52_tb/uut/cpu/uc_class_decode_0
add wave -noupdate -group Decoding -format Literal /light52_tb/uut/cpu/uc_alu_class_reg
add wave -noupdate -group Decoding -format Literal /light52_tb/uut/cpu/uc_alu_class_decode_0
add wave -noupdate -group Decoding -format Literal /light52_tb/uut/cpu/ucode
add wave -noupdate -group Decoding -format Literal /light52_tb/uut/cpu/ucode_1st_half
add wave -noupdate -group Decoding -format Logic /light52_tb/uut/cpu/ucode_is_2nd_half
add wave -noupdate -group Decoding -format Literal /light52_tb/uut/cpu/ucode_2nd_half_reg
add wave -noupdate -group Decoding -format Logic /light52_tb/uut/cpu/code_rd(3)
add wave -noupdate -group XDATA
add wave -noupdate -group XDATA -color {Medium Sea Green} -format Logic /light52_tb/uut/xdata_vma
add wave -noupdate -group XDATA -color {Sky Blue} -format Logic /light52_tb/uut/xdata_we
add wave -noupdate -group XDATA -color Wheat -format Literal -radix hexadecimal /light52_tb/uut/xdata_addr
add wave -noupdate -group XDATA -format Literal -radix hexadecimal /light52_tb/uut/xdata_rd
add wave -noupdate -group XDATA -color Thistle -format Literal -radix hexadecimal /light52_tb/uut/xdata_wr
add wave -noupdate -group {IRAM - SFR}
add wave -noupdate -group {IRAM - SFR} -format Logic /light52_tb/uut/cpu/sfr_addressing
add wave -noupdate -group {IRAM - SFR} -format Logic /light52_tb/uut/cpu/direct_addressing
add wave -noupdate -group {IRAM - SFR} -format Literal /light52_tb/uut/cpu/alu/load_t
add wave -noupdate -group {IRAM - SFR} -format Logic /light52_tb/uut/cpu/sfr_vma_internal
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /light52_tb/uut/cpu/sfr_rd_internal_reg
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /light52_tb/uut/cpu/sfr_addr_internal
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /light52_tb/uut/cpu/addr0_reg_input
add wave -noupdate -group {IRAM - SFR} -format Logic /light52_tb/uut/cpu/load_addr0
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /light52_tb/uut/cpu/ri_addr
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /light52_tb/uut/cpu/rn_addr
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /light52_tb/uut/cpu/rx_addr
add wave -noupdate -group {IRAM - SFR} -color Plum -format Literal -radix hexadecimal /light52_tb/uut/cpu/iram_sfr_addr
add wave -noupdate -group {IRAM - SFR} -color Magenta -format Literal -radix hexadecimal /light52_tb/uut/cpu/iram_sfr_rd
add wave -noupdate -group {IRAM - SFR} -color {Indian Red} -format Literal -radix hexadecimal /light52_tb/uut/cpu/bram_data_p0
add wave -noupdate -group {IRAM - SFR} -color Tan -format Literal -radix hexadecimal /light52_tb/uut/cpu/bram_addr_p0
add wave -noupdate -group {IRAM - SFR} -color Khaki -format Literal -radix hexadecimal /light52_tb/uut/cpu/bram_wr_data_p0
add wave -noupdate -group {IRAM - SFR} -color Gold -format Logic /light52_tb/uut/cpu/bram_we
add wave -noupdate -group {IRAM - SFR} -color Orange -format Logic /light52_tb/uut/cpu/sfr_we
add wave -noupdate -group {IRAM - SFR} -color {Cornflower Blue} -format Literal -radix hexadecimal /light52_tb/uut/cpu/sp_reg
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /light52_tb/uut/cpu/iram_sfr_addr
add wave -noupdate -group {IRAM - SFR} -format Logic /light52_tb/uut/cpu/iram_sfr_addr(7)
add wave -noupdate -group {IRAM - SFR} -format Logic /light52_tb/uut/cpu/direct_addressing
add wave -noupdate -group Jumps
add wave -noupdate -group Jumps -color Salmon -format Logic /light52_tb/uut/cpu/jump_condition
add wave -noupdate -group Jumps -format Logic /light52_tb/uut/cpu/load_addr0
add wave -noupdate -group Jumps -format Logic /light52_tb/uut/cpu/cjne_condition
add wave -noupdate -group Jumps -format Literal /light52_tb/uut/cpu/jump_cond_sel_reg
add wave -noupdate -group Jumps -format Literal -radix hexadecimal /light52_tb/uut/cpu/rel_jump_delta
add wave -noupdate -group Jumps -format Literal -radix hexadecimal /light52_tb/uut/cpu/rel_jump_target
add wave -noupdate -group Jumps -format Literal -radix hexadecimal /light52_tb/uut/cpu/jump_target
add wave -noupdate -group Jumps -color White -format Literal -radix hexadecimal /light52_tb/uut/cpu/addr1_reg
add wave -noupdate -group Jumps -color Gray65 -format Literal -radix hexadecimal /light52_tb/uut/cpu/addr0_reg
add wave -noupdate -group {Bit Ops}
add wave -noupdate -group {Bit Ops} -format Literal /light52_tb/uut/cpu/alu/alu_bit_fn_reg
add wave -noupdate -group {Bit Ops} -format Logic /light52_tb/uut/cpu/update_psw_flags
add wave -noupdate -group {Bit Ops} -color {Sky Blue} -format Logic /light52_tb/uut/cpu/alu/alu_bit_result
add wave -noupdate -group {Bit Ops} -color Wheat -format Logic /light52_tb/uut/cpu/bit_input
add wave -noupdate -group {Bit Ops} -color Tan -format Logic /light52_tb/uut/cpu/psw_reg(7)
add wave -noupdate -divider {To be removed}
add wave -noupdate -color White -format Literal -label CONSOLE /light52_tb/log_info.con_line_buf
add wave -noupdate -group {Register Bank}
add wave -noupdate -group {Register Bank} -format Logic /light52_tb/uut/cpu/bram_we
add wave -noupdate -group {Register Bank} -color Wheat -format Literal -label R0 -radix hexadecimal /light52_tb/uut/cpu/bram(256)
add wave -noupdate -group {Register Bank} -color Wheat -format Literal -label R1 -radix hexadecimal /light52_tb/uut/cpu/bram(257)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R2 -radix hexadecimal /light52_tb/uut/cpu/bram(258)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R3 -radix hexadecimal /light52_tb/uut/cpu/bram(259)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R4 -radix hexadecimal /light52_tb/uut/cpu/bram(260)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R5 -radix hexadecimal /light52_tb/uut/cpu/bram(261)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R6 -radix hexadecimal /light52_tb/uut/cpu/bram(262)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R7 -radix hexadecimal /light52_tb/uut/cpu/bram(263)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59430000 ps} 0}
configure wave -namecolwidth 183
configure wave -valuecolwidth 50
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ps} {130189500 ps}
