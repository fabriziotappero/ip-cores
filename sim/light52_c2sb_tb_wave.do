onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /c2sb_soc_tb/clk
add wave -noupdate -format Logic /c2sb_soc_tb/uut/mcu/cpu/reset
add wave -noupdate -divider CPU
add wave -noupdate -color Gray75 -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/pc_reg
add wave -noupdate -color Gray90 -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/code_addr
add wave -noupdate -color {Lime Green} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/code_rd
add wave -noupdate -color {Cornflower Blue} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/a_reg
add wave -noupdate -divider Debug
add wave -noupdate -format Logic /c2sb_soc_tb/log_info.bram_we
add wave -noupdate -format Literal -radix hexadecimal /c2sb_soc_tb/log_info.bram_wr_addr
add wave -noupdate -format Literal -radix hexadecimal /c2sb_soc_tb/log_info.bram_wr_data_p0
add wave -noupdate -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/addr0_reg
add wave -noupdate -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/addr1_reg
add wave -noupdate -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/jump_target
add wave -noupdate -divider Peripherals
add wave -noupdate -group {External Interrupts}
add wave -noupdate -group {External Interrupts} -format Literal /c2sb_soc_tb/uut/mcu/external_irq
add wave -noupdate -group {External Interrupts} -format Logic /c2sb_soc_tb/uut/mcu/ext_irq
add wave -noupdate -group {External Interrupts} -format Literal /c2sb_soc_tb/uut/mcu/external_irq_reg
add wave -noupdate -group Timer
add wave -noupdate -group Timer -format Logic /c2sb_soc_tb/uut/mcu/timer/ce_i
add wave -noupdate -group Timer -format Literal /c2sb_soc_tb/uut/mcu/timer/addr_i
add wave -noupdate -group Timer -format Logic /c2sb_soc_tb/uut/mcu/timer/wr_i
add wave -noupdate -group Timer -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/timer/data_i
add wave -noupdate -group Timer -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/timer/compare_reg
add wave -noupdate -group Timer -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/timer/counter_reg
add wave -noupdate -group Timer -format Logic /c2sb_soc_tb/uut/mcu/timer/counter_match
add wave -noupdate -group Timer -format Literal /c2sb_soc_tb/uut/mcu/timer/status_reg
add wave -noupdate -group Timer -format Logic /c2sb_soc_tb/uut/mcu/timer/irq_o
add wave -noupdate -divider Internal
add wave -noupdate -color Pink -format Literal /c2sb_soc_tb/uut/mcu/cpu/ps
add wave -noupdate -group Interrupts
add wave -noupdate -group Interrupts -color {Orange Red} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/ie_reg
add wave -noupdate -group Datapath
add wave -noupdate -group Datapath -group MUL-DIV
add wave -noupdate -group MUL-DIV -color {Violet Red} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/b_reg
add wave -noupdate -group MUL-DIV -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/quotient
add wave -noupdate -group MUL-DIV -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu/div_ready
add wave -noupdate -group MUL-DIV -format Logic /c2sb_soc_tb/uut/mcu/cpu/load_b_sfr
add wave -noupdate -group MUL-DIV -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/remainder
add wave -noupdate -group MUL-DIV -format Literal /c2sb_soc_tb/uut/mcu/cpu/alu/muldiv/bit_ctr
add wave -noupdate -group Datapath -group {Int. results}
add wave -noupdate -group {Int. results} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/alu_adder_result
add wave -noupdate -group {Int. results} -format Literal /c2sb_soc_tb/uut/mcu/cpu/alu/alu_logic_result
add wave -noupdate -group Datapath -group Inputs
add wave -noupdate -group Inputs -color {Cornflower Blue} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/t_reg
add wave -noupdate -group Inputs -color {Sky Blue} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/v_reg
add wave -noupdate -group Inputs -format Literal /c2sb_soc_tb/uut/mcu/cpu/alu/load_t
add wave -noupdate -group Inputs -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu/load_v
add wave -noupdate -group Inputs -format Literal /c2sb_soc_tb/uut/mcu/cpu/alu/alu_op_sel
add wave -noupdate -group Inputs -color Sienna -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/adder_op_0
add wave -noupdate -group Inputs -color {Indian Red} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu/adder_op_1
add wave -noupdate -group Datapath -group Flags
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu_p
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/acc_is_zero
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu_result_is_zero
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/update_psw_flags
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/psw_reg(7)
add wave -noupdate -group Flags -format Literal /c2sb_soc_tb/uut/mcu/cpu/psw_reg
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu_ov
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu/adder_cy_in
add wave -noupdate -group Flags -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu_cy
add wave -noupdate -group Datapath -color Goldenrod -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/alu_result
add wave -noupdate -group Datapath -color Wheat -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/nobit_alu_result
add wave -noupdate -group Datapath -color Gold -format Literal /c2sb_soc_tb/uut/mcu/cpu/alu_fn_reg
add wave -noupdate -group Datapath -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu/div_ready
add wave -noupdate -group Datapath -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu/mul_ready
add wave -noupdate -group Decoding
add wave -noupdate -group Decoding -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram_addr_p0
add wave -noupdate -group Decoding -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/ucode_index
add wave -noupdate -group Decoding -format Literal /c2sb_soc_tb/uut/mcu/cpu/uc_class_decode_0
add wave -noupdate -group Decoding -format Literal /c2sb_soc_tb/uut/mcu/cpu/uc_alu_class_reg
add wave -noupdate -group Decoding -format Literal /c2sb_soc_tb/uut/mcu/cpu/uc_alu_class_decode_0
add wave -noupdate -group Decoding -format Literal /c2sb_soc_tb/uut/mcu/cpu/ucode
add wave -noupdate -group Decoding -format Literal /c2sb_soc_tb/uut/mcu/cpu/ucode_1st_half
add wave -noupdate -group Decoding -format Logic /c2sb_soc_tb/uut/mcu/cpu/ucode_is_2nd_half
add wave -noupdate -group Decoding -format Literal /c2sb_soc_tb/uut/mcu/cpu/ucode_2nd_half_reg
add wave -noupdate -group Decoding -format Logic /c2sb_soc_tb/uut/mcu/cpu/code_rd(3)
add wave -noupdate -group XDATA
add wave -noupdate -group XDATA -color {Medium Sea Green} -format Logic /c2sb_soc_tb/uut/mcu/xdata_vma
add wave -noupdate -group XDATA -color {Sky Blue} -format Logic /c2sb_soc_tb/uut/mcu/xdata_we
add wave -noupdate -group XDATA -color Wheat -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/xdata_addr
add wave -noupdate -group XDATA -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/xdata_rd
add wave -noupdate -group XDATA -color Thistle -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/xdata_wr
add wave -noupdate -group {IRAM - SFR}
add wave -noupdate -group {IRAM - SFR} -format Logic /c2sb_soc_tb/uut/mcu/cpu/sfr_addressing
add wave -noupdate -group {IRAM - SFR} -format Logic /c2sb_soc_tb/uut/mcu/cpu/direct_addressing
add wave -noupdate -group {IRAM - SFR} -format Literal /c2sb_soc_tb/uut/mcu/cpu/alu/load_t
add wave -noupdate -group {IRAM - SFR} -format Logic /c2sb_soc_tb/uut/mcu/cpu/sfr_vma_internal
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/sfr_rd_internal_reg
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/sfr_addr_internal
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/addr0_reg_input
add wave -noupdate -group {IRAM - SFR} -format Logic /c2sb_soc_tb/uut/mcu/cpu/load_addr0
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/ri_addr
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/rn_addr
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/rx_addr
add wave -noupdate -group {IRAM - SFR} -color Plum -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/iram_sfr_addr
add wave -noupdate -group {IRAM - SFR} -color Magenta -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/iram_sfr_rd
add wave -noupdate -group {IRAM - SFR} -color {Indian Red} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram_data_p0
add wave -noupdate -group {IRAM - SFR} -color Tan -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram_addr_p0
add wave -noupdate -group {IRAM - SFR} -color Khaki -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram_wr_data_p0
add wave -noupdate -group {IRAM - SFR} -color Gold -format Logic /c2sb_soc_tb/uut/mcu/cpu/bram_we
add wave -noupdate -group {IRAM - SFR} -color Orange -format Logic /c2sb_soc_tb/uut/mcu/cpu/sfr_we
add wave -noupdate -group {IRAM - SFR} -color {Cornflower Blue} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/sp_reg
add wave -noupdate -group {IRAM - SFR} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/iram_sfr_addr
add wave -noupdate -group {IRAM - SFR} -format Logic /c2sb_soc_tb/uut/mcu/cpu/iram_sfr_addr(7)
add wave -noupdate -group {IRAM - SFR} -format Logic /c2sb_soc_tb/uut/mcu/cpu/direct_addressing
add wave -noupdate -group Jumps
add wave -noupdate -group Jumps -color Salmon -format Logic /c2sb_soc_tb/uut/mcu/cpu/jump_condition
add wave -noupdate -group Jumps -format Logic /c2sb_soc_tb/uut/mcu/cpu/load_addr0
add wave -noupdate -group Jumps -format Logic /c2sb_soc_tb/uut/mcu/cpu/cjne_condition
add wave -noupdate -group Jumps -format Literal /c2sb_soc_tb/uut/mcu/cpu/jump_cond_sel_reg
add wave -noupdate -group Jumps -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/rel_jump_delta
add wave -noupdate -group Jumps -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/rel_jump_target
add wave -noupdate -group Jumps -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/jump_target
add wave -noupdate -group Jumps -color White -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/addr1_reg
add wave -noupdate -group Jumps -color Gray65 -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/addr0_reg
add wave -noupdate -group {Bit Ops}
add wave -noupdate -group {Bit Ops} -format Literal /c2sb_soc_tb/uut/mcu/cpu/alu/alu_bit_fn_reg
add wave -noupdate -group {Bit Ops} -format Logic /c2sb_soc_tb/uut/mcu/cpu/update_psw_flags
add wave -noupdate -group {Bit Ops} -color {Sky Blue} -format Logic /c2sb_soc_tb/uut/mcu/cpu/alu/alu_bit_result
add wave -noupdate -group {Bit Ops} -color Wheat -format Logic /c2sb_soc_tb/uut/mcu/cpu/bit_input
add wave -noupdate -group {Bit Ops} -color Tan -format Logic /c2sb_soc_tb/uut/mcu/cpu/psw_reg(7)
add wave -noupdate -group SFR
add wave -noupdate -group SFR -color Magenta -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/sfr_addr
add wave -noupdate -group SFR -format Logic /c2sb_soc_tb/uut/mcu/cpu/sfr_vma
add wave -noupdate -group SFR -format Logic /c2sb_soc_tb/uut/mcu/cpu/sfr_we
add wave -noupdate -group SFR -color Orchid -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/sfr_wr
add wave -noupdate -group SFR -color {Sky Blue} -format Literal -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/sfr_rd
add wave -noupdate -divider {To be removed}
add wave -noupdate -group {Register Bank}
add wave -noupdate -group {Register Bank} -format Logic /c2sb_soc_tb/uut/mcu/cpu/bram_we
add wave -noupdate -group {Register Bank} -color Wheat -format Literal -label R0 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(256)
add wave -noupdate -group {Register Bank} -color Wheat -format Literal -label R1 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(257)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R2 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(258)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R3 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(259)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R4 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(260)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R5 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(261)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R6 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(262)
add wave -noupdate -group {Register Bank} -color {Indian Red} -format Literal -label R7 -radix hexadecimal /c2sb_soc_tb/uut/mcu/cpu/bram(263)
add wave -noupdate -color White -format Literal -label CONSOLE /c2sb_soc_tb/log_info.con_line_buf
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68850000 ps} 0} {{Cursor 2} {632590000 ps} 0}
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
WaveRestoreZoom {632455977 ps} {632967861 ps}
